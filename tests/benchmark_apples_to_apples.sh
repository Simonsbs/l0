#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"
OUT_MD="${3:-$ROOT/docs/PERFORMANCE_COMPARISON_APPLES_TO_APPLES.md}"

BUILD_ITERS="${L0_A2A_BUILD_ITERS:-80}"
RUNTIME_ITERS="${L0_A2A_RUNTIME_ITERS:-5000000}"

TMP_BASE="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "$TMP_BASE/l0_a2a.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

bench_ops() {
  local iters="$1"
  shift
  local start end dur_ms i

  start=$(date +%s%N)
  i=0
  while [ "$i" -lt "$iters" ]; do
    "$@" >/dev/null 2>/dev/null
    i=$((i + 1))
  done
  end=$(date +%s%N)

  dur_ms=$(((end - start) / 1000000))
  if [ "$dur_ms" -le 0 ]; then
    dur_ms=1
  fi
  echo $((iters * 1000 / dur_ms))
}

median3() {
  local a="$1" b="$2" c="$3"
  printf '%s\n%s\n%s\n' "$a" "$b" "$c" | sort -n | sed -n '2p'
}

secs_for_exec() {
  local exe="$1"
  local start end
  start=$(date +%s%N)
  "$exe" >/dev/null 2>/dev/null
  end=$(date +%s%N)
  awk -v s="$start" -v e="$end" 'BEGIN { printf "%.9f", (e-s)/1000000000.0 }'
}

ratio_or_na() {
  local num="$1"
  local den="$2"
  awk -v n="$num" -v d="$den" 'BEGIN { if (d <= 0) print "n/a"; else printf "%.4f", n/d }'
}

mops_or_na() {
  local iters="$1"
  local secs="$2"
  awk -v n="$iters" -v s="$secs" 'BEGIN { if (s <= 0) print "n/a"; else printf "%.2f", (n/s)/1000000.0 }'
}

geo_mean_or_na() {
  # Input: newline-delimited numeric values (n/a filtered out by caller)
  awk 'NF>0 { s += log($1); c += 1 } END { if (c == 0) print "n/a"; else printf "%.4f", exp(s/c) }'
}

date_utc="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
host_name="$(hostname)"
kernel_name="$(uname -srm)"

gcc_ver="missing"
if command -v gcc >/dev/null 2>&1; then
  gcc_ver="$(gcc --version | head -n1)"
fi

cat > "$WORK_DIR/kernels.tsv" <<'EOF_KERNELS'
#id|label|l0_fixture|c_expr
k01|add.wrap (2-arg)|tests/valid_add_v7.l0|a + b
k02|sub.wrap (2-arg)|tests/valid_sub.l0|a - b
k03|mul.wrap (2-arg)|tests/valid_mul.l0|a * b
k04|and (2-arg)|tests/valid_and.l0|a & b
k05|xor (2-arg)|tests/valid_xor.l0|a ^ b
k06|cbr select (eq ? a : b)|tests/valid_cbr_eq_select_v7.l0|(a == b) ? a : b
k07|memory roundtrip|tests/valid_mem_roundtrip_v7.l0|a
k08|call add (f0->f1)|tests/valid_call_add_v7_lowered.l0|a + b
k09|sum6 sysv|tests/valid_sysv_abi_sum6_lowered.l0|a + b + c + d + e + f
EOF_KERNELS

rows_tsv="$WORK_DIR/results.tsv"
: > "$rows_tsv"

while IFS='|' read -r kid label l0_rel c_expr; do
  [ -n "$kid" ] || continue
  case "$kid" in
    \#*) continue ;;
  esac

  l0_path="$ROOT/$l0_rel"
  if [ ! -f "$l0_path" ]; then
    echo "FAIL: missing L0 fixture $l0_rel"
    exit 1
  fi

  harness_s="$WORK_DIR/$kid.harness.s"
  l0_obj="$WORK_DIR/$kid.l0.o"
  l0_exec="$WORK_DIR/$kid.l0.exec"
  gcc_c="$WORK_DIR/$kid.c"
  gcc_obj="$WORK_DIR/$kid.gcc.o"
  gcc_exec="$WORK_DIR/$kid.gcc.exec"
  harness_o="$WORK_DIR/$kid.harness.o"

  cat > "$harness_s" <<EOF_H
.intel_syntax noprefix
.global _start
.extern f0

.bss
.align 8
counter: .zero 8
acc: .zero 8

.text
_start:
  mov rax, $RUNTIME_ITERS
  mov [counter], rax
  xor rax, rax
  mov [acc], rax

.L_loop:
  mov rdi, 11
  mov rsi, 11
  mov rdx, 3
  mov rcx, 4
  mov r8, 5
  mov r9, 6
  call f0

  mov r10, [acc]
  add r10, rax
  mov [acc], r10

  mov r11, [counter]
  sub r11, 1
  mov [counter], r11
  jne .L_loop

  mov rdi, [acc]
  and rdi, 255
  mov rax, 60
  syscall

.section .note.GNU-stack,"",@progbits
EOF_H

  "$BIN" build-elf "$l0_path" "$l0_obj" >"$WORK_DIR/$kid.l0.build.once.out"
  if ! grep -q '^ok$' "$WORK_DIR/$kid.l0.build.once.out"; then
    echo "FAIL: could not build L0 ELF object for $kid ($l0_rel)"
    exit 1
  fi

  as --64 -o "$harness_o" "$harness_s"
  ld -o "$l0_exec" "$harness_o" "$l0_obj"

  cat > "$gcc_c" <<EOF_C
#include <stdint.h>
uint64_t f0(uint64_t a, uint64_t b, uint64_t c, uint64_t d, uint64_t e, uint64_t f) {
  return (uint64_t)($c_expr);
}
EOF_C

  l0_build_ops="$(bench_ops "$BUILD_ITERS" "$BIN" build-elf "$l0_path" "$WORK_DIR/$kid.l0.loop.o")"

  gcc_build_ops="n/a"
  gcc_runtime_mops="n/a"
  if [ "$gcc_ver" != "missing" ]; then
    gcc -O2 -c -o "$gcc_obj" "$gcc_c"
    ld -o "$gcc_exec" "$harness_o" "$gcc_obj"
    gcc_build_ops="$(bench_ops "$BUILD_ITERS" gcc -O2 -c -o "$WORK_DIR/$kid.gcc.loop.o" "$gcc_c")"
  fi

  l0_t1="$(secs_for_exec "$l0_exec")"
  l0_t2="$(secs_for_exec "$l0_exec")"
  l0_t3="$(secs_for_exec "$l0_exec")"
  l0_tmed="$(median3 "$l0_t1" "$l0_t2" "$l0_t3")"
  l0_runtime_mops="$(mops_or_na "$RUNTIME_ITERS" "$l0_tmed")"

  if [ "$gcc_ver" != "missing" ]; then
    g_t1="$(secs_for_exec "$gcc_exec")"
    g_t2="$(secs_for_exec "$gcc_exec")"
    g_t3="$(secs_for_exec "$gcc_exec")"
    g_tmed="$(median3 "$g_t1" "$g_t2" "$g_t3")"
    gcc_runtime_mops="$(mops_or_na "$RUNTIME_ITERS" "$g_tmed")"
  fi

  build_ratio="n/a"
  runtime_ratio="n/a"
  if [ "$gcc_build_ops" != "n/a" ]; then
    build_ratio="$(ratio_or_na "$l0_build_ops" "$gcc_build_ops")"
  fi
  if [ "$gcc_runtime_mops" != "n/a" ]; then
    runtime_ratio="$(ratio_or_na "$l0_runtime_mops" "$gcc_runtime_mops")"
  fi

  printf '%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
    "$kid" "$label" "$l0_rel" "$l0_build_ops" "$gcc_build_ops" "$l0_runtime_mops" "$gcc_runtime_mops" "$build_ratio" "$runtime_ratio" \
    >> "$rows_tsv"
done < "$WORK_DIR/kernels.tsv"

build_geo="$(awk -F'|' '{ if ($8 != "n/a") print $8 }' "$rows_tsv" | geo_mean_or_na)"
runtime_geo="$(awk -F'|' '{ if ($9 != "n/a") print $9 }' "$rows_tsv" | geo_mean_or_na)"

{
  echo "# Apples-to-Apples Performance Comparison"
  echo
  echo "I generated this snapshot automatically with \`tests/benchmark_apples_to_apples.sh\`."
  echo
  echo "- generated_utc: \`$date_utc\`"
  echo "- host: \`$host_name\`"
  echo "- kernel: \`$kernel_name\`"
  echo "- l0c: \`$BIN\`"
  echo "- gcc: \`$gcc_ver\`"
  echo "- build iterations per kernel: \`$BUILD_ITERS\`"
  echo "- runtime iterations per run: \`$RUNTIME_ITERS\`"
  echo "- runtime repeats per kernel: \`3 (median)\`"
  echo
  echo "## Method"
  echo
  echo "I compare multiple equivalent \`f0(uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t)->uint64_t\` implementations:"
  echo "- L0: each listed fixture built via \`l0c build-elf\`"
  echo "- GCC: generated equivalent C function built with \`gcc -O2 -c\`"
  echo "- Runtime harness: same assembly \`_start\` loop calling \`f0\` with fixed args for both variants"
  echo "- Runtime metric: median of 3 runs in Mops/s"
  echo "- Build metric: repeated object build throughput (ops/s)"
  echo
  echo "## Per-Kernel Results"
  echo
  echo '| Kernel | L0 fixture | Build ops/s L0 | Build ops/s GCC | Build ratio L0/GCC | Runtime Mops/s L0 | Runtime Mops/s GCC | Runtime ratio L0/GCC |'
  echo '|---|---|---:|---:|---:|---:|---:|---:|'
  awk -F'|' '{ printf("| %s | `%s` | %s | %s | %s | %s | %s | %s |\n", $2, $3, $4, $5, $8, $6, $7, $9); }' "$rows_tsv"
  echo
  echo "## Aggregate"
  echo
  echo '| Metric | Value |'
  echo '|---|---:|'
  echo "| Geometric mean build ratio (L0/GCC) | $build_geo |"
  echo "| Geometric mean runtime ratio (L0/GCC) | $runtime_geo |"
  echo
  echo "## Interpretation"
  echo
  echo "- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel."
  echo "- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC."
  echo "- Build ratio reflects compiler throughput, not generated-code quality."
} > "$OUT_MD"

echo "ok"
