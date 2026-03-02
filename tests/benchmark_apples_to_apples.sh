#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"
OUT_MD="${3:-$ROOT/docs/PERFORMANCE_COMPARISON_APPLES_TO_APPLES.md}"
OUT_JSON="${4:-$ROOT/docs/PERFORMANCE_COMPARISON_APPLES_TO_APPLES.json}"

BUILD_ITERS="${L0_A2A_BUILD_ITERS:-80}"
BUILD_SAMPLES="${L0_A2A_BUILD_SAMPLES:-3}"
RUNTIME_ITERS="${L0_A2A_RUNTIME_ITERS:-5000000}"
RUNTIME_SAMPLES="${L0_A2A_RUNTIME_SAMPLES:-5}"
WARMUP_RUNS="${L0_A2A_WARMUP_RUNS:-1}"
PIN_CPU="${L0_A2A_PIN_CPU:-}"

TMP_BASE="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "$TMP_BASE/l0_a2a.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

RUN_PREFIX=()
if [ -n "$PIN_CPU" ] && command -v taskset >/dev/null 2>&1; then
  RUN_PREFIX=(taskset -c "$PIN_CPU")
fi

run_cmd() {
  if [ "${#RUN_PREFIX[@]}" -gt 0 ]; then
    "${RUN_PREFIX[@]}" "$@"
  else
    "$@"
  fi
}

bench_ops_once() {
  local iters="$1"
  shift
  local start end dur_ms i

  start=$(date +%s%N)
  i=0
  while [ "$i" -lt "$iters" ]; do
    run_cmd "$@" >/dev/null 2>/dev/null
    i=$((i + 1))
  done
  end=$(date +%s%N)

  dur_ms=$(((end - start) / 1000000))
  if [ "$dur_ms" -le 0 ]; then
    dur_ms=1
  fi
  echo $((iters * 1000 / dur_ms))
}

secs_for_exec() {
  local exe="$1"
  local start end
  start=$(date +%s%N)
  run_cmd "$exe" >/dev/null 2>/dev/null || true
  end=$(date +%s%N)
  awk -v s="$start" -v e="$end" 'BEGIN { printf "%.9f", (e-s)/1000000000.0 }'
}

mops_or_na() {
  local iters="$1"
  local secs="$2"
  awk -v n="$iters" -v s="$secs" 'BEGIN { if (s <= 0) print "n/a"; else printf "%.4f\n", (n/s)/1000000.0 }'
}

stats_from_file() {
  # Prints: mean|median|stddev|ci95|n
  local file="$1"
  local n
  n="$(wc -l < "$file" | tr -d ' ')"
  if [ -z "$n" ] || [ "$n" -eq 0 ]; then
    echo "n/a|n/a|n/a|n/a|0"
    return 0
  fi

  local mean stddev ci95 median
  read -r mean stddev ci95 <<EOF_STATS
$(awk '{x[NR]=$1; s+=$1} END {n=NR; if(n==0){print "n/a n/a n/a"; exit} mean=s/n; v=0; for(i=1;i<=n;i++){d=x[i]-mean; v+=d*d} if(n>1){std=sqrt(v/(n-1))} else {std=0} ci=(n>0)?(1.96*std/sqrt(n)):0; printf "%.4f %.4f %.4f", mean, std, ci }' "$file")
EOF_STATS
  median="$(sort -n "$file" | awk ' {a[NR]=$1} END {n=NR; if(n==0){print "n/a"} else if(n%2==1){printf "%.4f", a[(n+1)/2]} else {printf "%.4f", (a[n/2]+a[n/2+1])/2} }')"

  echo "$mean|$median|$stddev|$ci95|$n"
}

ratio_or_na() {
  local num="$1"
  local den="$2"
  awk -v n="$num" -v d="$den" 'BEGIN { if (d <= 0) print "n/a"; else printf "%.4f", n/d }'
}

geo_mean_or_na() {
  awk 'NF>0 { s += log($1); c += 1 } END { if (c == 0) print "n/a"; else printf "%.4f", exp(s/c) }'
}

date_utc="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
host_name="$(hostname)"
kernel_name="$(uname -srm)"

cpu_model="n/a"
cpu_topology="n/a"
if command -v lscpu >/dev/null 2>&1; then
  cpu_model="$(lscpu | sed -n 's/^Model name:[[:space:]]*//p' | head -n1 | xargs)"
  cpu_topology="$(lscpu | awk -F: '/^CPU\(s\):|^Thread\(s\) per core:|^Core\(s\) per socket:|^Socket\(s\):/{gsub(/^[ \t]+/ , "", $2); printf "%s=%s ", $1, $2}' | sed 's/[[:space:]]*$//')"
fi

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

  gcc_build_stats="n/a|n/a|n/a|n/a|0"
  gcc_runtime_stats="n/a|n/a|n/a|n/a|0"
  if [ "$gcc_ver" != "missing" ]; then
    gcc -O2 -c -o "$gcc_obj" "$gcc_c"
    ld -o "$gcc_exec" "$harness_o" "$gcc_obj"
  fi

  l0_build_samples="$WORK_DIR/$kid.l0.build.samples"
  gcc_build_samples="$WORK_DIR/$kid.gcc.build.samples"
  l0_runtime_samples="$WORK_DIR/$kid.l0.runtime.samples"
  gcc_runtime_samples="$WORK_DIR/$kid.gcc.runtime.samples"
  : > "$l0_build_samples"
  : > "$gcc_build_samples"
  : > "$l0_runtime_samples"
  : > "$gcc_runtime_samples"

  # Warmups (compile + run) to reduce first-hit skew.
  i=0
  while [ "$i" -lt "$WARMUP_RUNS" ]; do
    "$BIN" build-elf "$l0_path" "$WORK_DIR/$kid.l0.warmup.o" >/dev/null 2>/dev/null || true
    run_cmd "$l0_exec" >/dev/null 2>/dev/null || true
    if [ "$gcc_ver" != "missing" ]; then
      gcc -O2 -c -o "$WORK_DIR/$kid.gcc.warmup.o" "$gcc_c" >/dev/null 2>/dev/null || true
      run_cmd "$gcc_exec" >/dev/null 2>/dev/null || true
    fi
    i=$((i + 1))
  done

  i=0
  while [ "$i" -lt "$BUILD_SAMPLES" ]; do
    bench_ops_once "$BUILD_ITERS" "$BIN" build-elf "$l0_path" "$WORK_DIR/$kid.l0.loop.o" >> "$l0_build_samples"
    if [ "$gcc_ver" != "missing" ]; then
      bench_ops_once "$BUILD_ITERS" gcc -O2 -c -o "$WORK_DIR/$kid.gcc.loop.o" "$gcc_c" >> "$gcc_build_samples"
    fi
    i=$((i + 1))
  done

  i=0
  while [ "$i" -lt "$RUNTIME_SAMPLES" ]; do
    l0_sec="$(secs_for_exec "$l0_exec")"
    mops_or_na "$RUNTIME_ITERS" "$l0_sec" >> "$l0_runtime_samples"
    if [ "$gcc_ver" != "missing" ]; then
      g_sec="$(secs_for_exec "$gcc_exec")"
      mops_or_na "$RUNTIME_ITERS" "$g_sec" >> "$gcc_runtime_samples"
    fi
    i=$((i + 1))
  done

  l0_build_stats="$(stats_from_file "$l0_build_samples")"
  l0_runtime_stats="$(stats_from_file "$l0_runtime_samples")"
  if [ "$gcc_ver" != "missing" ]; then
    gcc_build_stats="$(stats_from_file "$gcc_build_samples")"
    gcc_runtime_stats="$(stats_from_file "$gcc_runtime_samples")"
  fi

  IFS='|' read -r _l0b_mean l0b_median _l0b_std _l0b_ci _l0b_n <<< "$l0_build_stats"
  IFS='|' read -r _l0r_mean l0r_median _l0r_std l0r_ci _l0r_n <<< "$l0_runtime_stats"
  IFS='|' read -r _gcb_mean gcb_median _gcb_std _gcb_ci _gcb_n <<< "$gcc_build_stats"
  IFS='|' read -r _gcr_mean gcr_median _gcr_std gcr_ci _gcr_n <<< "$gcc_runtime_stats"

  build_ratio="n/a"
  runtime_ratio="n/a"
  if [ "$gcb_median" != "n/a" ]; then
    build_ratio="$(ratio_or_na "$l0b_median" "$gcb_median")"
  fi
  if [ "$gcr_median" != "n/a" ]; then
    runtime_ratio="$(ratio_or_na "$l0r_median" "$gcr_median")"
  fi

  printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
    "$kid" "$label" "$l0_rel" "$l0b_median" "$gcb_median" "$build_ratio" "$l0r_median" "$l0r_ci" "$gcr_median" "$gcr_ci" "$runtime_ratio" \
    >> "$rows_tsv"
done < "$WORK_DIR/kernels.tsv"

build_geo="$(awk -F'|' '{ if ($6 != "n/a") print $6 }' "$rows_tsv" | geo_mean_or_na)"
runtime_geo="$(awk -F'|' '{ if ($11 != "n/a") print $11 }' "$rows_tsv" | geo_mean_or_na)"

jq -Rn \
  --arg generated_utc "$date_utc" \
  --arg host "$host_name" \
  --arg kernel "$kernel_name" \
  --arg l0c "$BIN" \
  --arg gcc "$gcc_ver" \
  --arg cpu_model "$cpu_model" \
  --arg cpu_topology "$cpu_topology" \
  --arg pin_cpu "$PIN_CPU" \
  --argjson build_iters "$BUILD_ITERS" \
  --argjson build_samples "$BUILD_SAMPLES" \
  --argjson runtime_iters "$RUNTIME_ITERS" \
  --argjson runtime_samples "$RUNTIME_SAMPLES" \
  --argjson warmup_runs "$WARMUP_RUNS" \
  --arg build_geo "$build_geo" \
  --arg runtime_geo "$runtime_geo" \
  --rawfile rows "$rows_tsv" '
  {
    generated_utc: $generated_utc,
    host: $host,
    kernel: $kernel,
    l0c: $l0c,
    gcc: $gcc,
    cpu_model: $cpu_model,
    cpu_topology: $cpu_topology,
    pin_cpu: (if $pin_cpu == "" then null else $pin_cpu end),
    build_iters: $build_iters,
    build_samples: $build_samples,
    runtime_iters: $runtime_iters,
    runtime_samples: $runtime_samples,
    warmup_runs: $warmup_runs,
    build_ratio_geomean_l0_over_gcc: (if $build_geo=="n/a" then null else ($build_geo|tonumber) end),
    runtime_ratio_geomean_l0_over_gcc: (if $runtime_geo=="n/a" then null else ($runtime_geo|tonumber) end),
    kernels: (
      ($rows | split("\n") | map(select(length>0)))
      | map(split("|"))
      | map({
          id: .[0],
          label: .[1],
          l0_fixture: .[2],
          build_ops_l0_median: (if .[3]=="n/a" then null else (.[3]|tonumber) end),
          build_ops_gcc_median: (if .[4]=="n/a" then null else (.[4]|tonumber) end),
          build_ratio_l0_over_gcc: (if .[5]=="n/a" then null else (.[5]|tonumber) end),
          runtime_mops_l0_median: (if .[6]=="n/a" then null else (.[6]|tonumber) end),
          runtime_mops_l0_ci95: (if .[7]=="n/a" then null else (.[7]|tonumber) end),
          runtime_mops_gcc_median: (if .[8]=="n/a" then null else (.[8]|tonumber) end),
          runtime_mops_gcc_ci95: (if .[9]=="n/a" then null else (.[9]|tonumber) end),
          runtime_ratio_l0_over_gcc: (if .[10]=="n/a" then null else (.[10]|tonumber) end)
      })
    )
  }
' > "$OUT_JSON"

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
  echo "- cpu_model: \`$cpu_model\`"
  echo "- cpu_topology: \`$cpu_topology\`"
  if [ -n "$PIN_CPU" ]; then
    echo "- cpu_affinity: \`$PIN_CPU\`"
  else
    echo "- cpu_affinity: \`not pinned\`"
  fi
  echo "- build iterations per sample: \`$BUILD_ITERS\`"
  echo "- build samples per kernel: \`$BUILD_SAMPLES\`"
  echo "- runtime iterations per sample: \`$RUNTIME_ITERS\`"
  echo "- runtime samples per kernel: \`$RUNTIME_SAMPLES\`"
  echo "- warmup runs per kernel: \`$WARMUP_RUNS\`"
  echo
  echo "## Method"
  echo
  echo "I compare multiple equivalent \`f0(uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t)->uint64_t\` implementations:"
  echo "- L0: each listed fixture built via \`l0c build-elf\`"
  echo "- GCC: generated equivalent C function built with \`gcc -O2 -c\`"
  echo "- Runtime harness: same assembly \`_start\` loop calling \`f0\` with fixed args for both variants"
  echo "- Runtime metric: median Mops/s across samples + CI95 on sample mean"
  echo "- Build metric: median build throughput (ops/s) across samples"
  echo "- Machine-readable artifact: \`docs/PERFORMANCE_COMPARISON_APPLES_TO_APPLES.json\`"
  echo
  echo "## Per-Kernel Results"
  echo
  echo '| Kernel | L0 fixture | Build ops/s L0 (median) | Build ops/s GCC (median) | Build ratio L0/GCC | Runtime Mops/s L0 (median ± CI95) | Runtime Mops/s GCC (median ± CI95) | Runtime ratio L0/GCC |'
  echo '|---|---|---:|---:|---:|---:|---:|---:|'
  awk -F'|' '{ printf("| %s | `%s` | %s | %s | %s | %s ± %s | %s ± %s | %s |\n", $2, $3, $4, $5, $6, $7, $8, $9, $10, $11); }' "$rows_tsv"
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
  echo "- CI95 is reported to make run-to-run variability explicit."
  echo "- Build ratio reflects compiler throughput, not generated-code quality."
} > "$OUT_MD"

echo "ok"
