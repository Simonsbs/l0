#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"
OUT_MD="${3:-$ROOT/docs/PERFORMANCE_COMPARISON.md}"

TMP_BASE="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "$TMP_BASE/l0_cmp.XXXXXX")"
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

date_utc="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
host_name="$(hostname)"
kernel_name="$(uname -srm)"

# L0 baseline artifacts.
"$BIN" build "$ROOT/tests/valid_min.l0" "$WORK_DIR/l0_min.img" >"$WORK_DIR/l0_build_once.out"
if ! grep -q '^ok$' "$WORK_DIR/l0_build_once.out"; then
  echo "FAIL: could not build L0 baseline artifact"
  exit 1
fi

l0_build_ops="$(bench_ops 200 "$BIN" build "$ROOT/tests/valid_min.l0" "$WORK_DIR/l0_loop.img")"
l0_run_ops="$(bench_ops 1200 "$BIN" run "$WORK_DIR/l0_min.img" 7 9)"

gcc_build_ops="n/a"
gcc_run_ops="n/a"
gcc_ver="missing"

if command -v gcc >/dev/null 2>&1; then
  gcc_ver="$(gcc --version | head -n1)"
  cat > "$WORK_DIR/add.c" <<'EOF'
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char **argv) {
  if (argc < 3) return 2;
  unsigned long long a = strtoull(argv[1], 0, 10);
  unsigned long long b = strtoull(argv[2], 0, 10);
  printf("%llu\n", (unsigned long long)(a + b));
  return 0;
}
EOF
  gcc -O2 -s -o "$WORK_DIR/add_gcc" "$WORK_DIR/add.c"
  gcc_build_ops="$(bench_ops 200 gcc -O2 -s -o "$WORK_DIR/add_gcc_loop" "$WORK_DIR/add.c")"
  gcc_run_ops="$(bench_ops 1200 "$WORK_DIR/add_gcc" 7 9)"
fi

{
  echo "# Performance Comparison Snapshot"
  echo
  echo "I generated this snapshot automatically with \`tests/benchmark_compare.sh\`."
  echo
  echo "- generated_utc: \`$date_utc\`"
  echo "- host: \`$host_name\`"
  echo "- kernel: \`$kernel_name\`"
  echo "- l0c: \`$BIN\`"
  echo "- gcc: \`$gcc_ver\`"
  echo
  echo "## Method"
  echo
  echo "I compare process-level throughput (ops/s) for equivalent minimal tasks:"
  echo "- build throughput: compile/build a minimal add kernel/program repeatedly"
  echo "- run throughput: execute add with two decimal args repeatedly"
  echo
  echo "This is an operational comparison, not a language-runtime microbenchmark."
  echo
  echo "## Results"
  echo
  echo '| Workload | L0 (`l0c`) ops/s | GCC C ops/s |'
  echo "|---|---:|---:|"
  echo "| Build minimal add artifact | $l0_build_ops | $gcc_build_ops |"
  echo "| Run minimal add artifact/program | $l0_run_ops | $gcc_run_ops |"
  echo
  echo "## Notes"
  echo
  echo "- I run this on the local host, so values are machine-dependent."
  echo "- CI smoke/full perf gates remain the enforcement source for regressions."
} > "$OUT_MD"

echo "ok"
