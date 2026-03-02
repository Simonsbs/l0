#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"
OUT_MD="${3:-$ROOT/docs/PERFORMANCE_COMPARISON_APPLES_TO_APPLES.md}"

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

date_utc="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
host_name="$(hostname)"
kernel_name="$(uname -srm)"

iters=20000000

# Shared loop harness: calls f0(iters times) with fixed six integer args.
cat > "$WORK_DIR/harness.s" <<EOF
.intel_syntax noprefix
.global _start
.extern f0

.bss
.align 8
counter: .zero 8
acc: .zero 8

.text
_start:
  mov rax, $iters
  mov [counter], rax
  xor rax, rax
  mov [acc], rax

.L_loop:
  mov rdi, 1
  mov rsi, 2
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
EOF

# L0 object path.
"$BIN" build-elf "$ROOT/tests/valid_sysv_abi_sum6_lowered.l0" "$WORK_DIR/l0_sum6.o" >"$WORK_DIR/l0_build_elf_once.out"
if ! grep -q '^ok$' "$WORK_DIR/l0_build_elf_once.out"; then
  echo "FAIL: could not build L0 ELF object"
  exit 1
fi
as --64 -o "$WORK_DIR/harness.o" "$WORK_DIR/harness.s"
ld -o "$WORK_DIR/l0_exec" "$WORK_DIR/harness.o" "$WORK_DIR/l0_sum6.o"

# GCC object path with equivalent f0 signature/semantics.
gcc_ver="missing"
gcc_build_ops="n/a"
gcc_runtime_mops="n/a"
if command -v gcc >/dev/null 2>&1; then
  gcc_ver="$(gcc --version | head -n1)"
  cat > "$WORK_DIR/sum6.c" <<'EOF'
#include <stdint.h>
uint64_t f0(uint64_t a, uint64_t b, uint64_t c, uint64_t d, uint64_t e, uint64_t f) {
  return a + b + c + d + e + f;
}
EOF
  gcc -O2 -c -o "$WORK_DIR/gcc_sum6.o" "$WORK_DIR/sum6.c"
  ld -o "$WORK_DIR/gcc_exec" "$WORK_DIR/harness.o" "$WORK_DIR/gcc_sum6.o"
  gcc_build_ops="$(bench_ops 120 gcc -O2 -c -o "$WORK_DIR/gcc_loop.o" "$WORK_DIR/sum6.c")"
fi

# L0 compile throughput for the same f0 shape.
l0_build_ops="$(bench_ops 120 "$BIN" build-elf "$ROOT/tests/valid_sysv_abi_sum6_lowered.l0" "$WORK_DIR/l0_loop.o")"

# Runtime median over 3 runs.
l0_t1="$(secs_for_exec "$WORK_DIR/l0_exec")"
l0_t2="$(secs_for_exec "$WORK_DIR/l0_exec")"
l0_t3="$(secs_for_exec "$WORK_DIR/l0_exec")"
l0_tmed="$(median3 "$l0_t1" "$l0_t2" "$l0_t3")"
l0_runtime_mops="$(awk -v n="$iters" -v s="$l0_tmed" 'BEGIN { if (s <= 0) { print "n/a"; } else { printf "%.2f", (n/s)/1000000.0; } }')"

if [ "$gcc_ver" != "missing" ]; then
  g_t1="$(secs_for_exec "$WORK_DIR/gcc_exec")"
  g_t2="$(secs_for_exec "$WORK_DIR/gcc_exec")"
  g_t3="$(secs_for_exec "$WORK_DIR/gcc_exec")"
  g_tmed="$(median3 "$g_t1" "$g_t2" "$g_t3")"
  gcc_runtime_mops="$(awk -v n="$iters" -v s="$g_tmed" 'BEGIN { if (s <= 0) { print "n/a"; } else { printf "%.2f", (n/s)/1000000.0; } }')"
fi

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
  echo "- runtime iterations per run: \`$iters\`"
  echo
  echo "## Method"
  echo
  echo "I compare equivalent \`f0(uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t)->uint64_t\` implementations:"
  echo "- L0: \`tests/valid_sysv_abi_sum6_lowered.l0\` built via \`l0c build-elf\`"
  echo "- GCC: equivalent C function built with \`gcc -O2 -c\`"
  echo "- Runtime harness: same assembly \`_start\` loop calling \`f0\` with fixed args for both variants"
  echo "- Runtime metric: median of 3 runs in Mops/s"
  echo "- Build metric: repeated object build throughput (ops/s)"
  echo
  echo "## Results"
  echo
  echo '| Metric | L0 (`l0c`) | GCC (`-O2`) |'
  echo "|---|---:|---:|"
  echo "| Build throughput (sum6 object) ops/s | $l0_build_ops | $gcc_build_ops |"
  echo "| Runtime throughput (sum6 harness) Mops/s | $l0_runtime_mops | $gcc_runtime_mops |"
  echo
  echo "## Interpretation"
  echo
  echo "- This is tighter than process-I/O comparisons because both variants use the same loop harness."
  echo "- It still represents one kernel shape; broader conclusions require additional kernels."
} > "$OUT_MD"

echo "ok"
