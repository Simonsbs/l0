#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"

TMP_BASE="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "$TMP_BASE/l0_m66_perf.XXXXXX")"
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

require_min_ops() {
  local metric="$1"
  local got="$2"
  local min="$3"

  if [ "$got" -lt "$min" ]; then
    echo "FAIL: M66 performance regression for $metric (got ${got} ops/s, min ${min} ops/s)"
    exit 1
  fi
}

"$BIN" build "$ROOT/tests/valid_min.l0" "$WORK_DIR/min.img" >"$WORK_DIR/build_min.out"
if ! grep -q '^ok$' "$WORK_DIR/build_min.out"; then
  echo "FAIL: M66 could not build min baseline"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_sysv_abi_sum6_lowered.l0" "$WORK_DIR/sum6.img" >"$WORK_DIR/build_sum6.out"
if ! grep -q '^ok$' "$WORK_DIR/build_sum6.out"; then
  echo "FAIL: M66 could not build sum6 baseline"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_trace_noop.l0" "$WORK_DIR/trace.img" --debug-map "$WORK_DIR/trace.map" --trace-schema "$WORK_DIR/trace.schema" >"$WORK_DIR/build_trace.out"
if ! grep -q '^ok$' "$WORK_DIR/build_trace.out"; then
  echo "FAIL: M66 could not build trace baseline"
  exit 1
fi
"$BIN" run "$WORK_DIR/trace.img" 123 >"$WORK_DIR/trace_run.out" 2>"$WORK_DIR/trace.bin"
if [ "$(cat "$WORK_DIR/trace_run.out")" != "0" ]; then
  echo "FAIL: M66 trace baseline run output mismatch"
  exit 1
fi

verify_ops=$(bench_ops 300 "$BIN" verify "$ROOT/tests/valid_min.l0")
build_ops=$(bench_ops 200 "$BIN" build "$ROOT/tests/valid_min.l0" "$WORK_DIR/loop.img")
run_add_ops=$(bench_ops 1200 "$BIN" run "$WORK_DIR/min.img" 7 9)
run_sum6_ops=$(bench_ops 1200 "$BIN" run "$WORK_DIR/sum6.img" 1 2 3 4 5 6)
build_elf_ops=$(bench_ops 120 "$BIN" build-elf "$ROOT/tests/valid_sysv_abi_sum6_lowered.l0" "$WORK_DIR/loop.o")
mapcat_ops=$(bench_ops 1200 "$BIN" mapcat "$WORK_DIR/trace.map")
schemacat_ops=$(bench_ops 1200 "$BIN" schemacat "$WORK_DIR/trace.schema")
tracecat_ops=$(bench_ops 1200 "$BIN" tracecat "$WORK_DIR/trace.bin")
tracejoin_ops=$(bench_ops 1200 "$BIN" tracejoin "$WORK_DIR/trace.bin" "$WORK_DIR/trace.map")

# perfbase.v1 pinned throughput floors (Linux x86-64 bootstrap environment).
profile="${L0_PERF_PROFILE:-local}"
if [ "$profile" = "ci" ]; then
  # Conservative floors for shared hosted runners.
  require_min_ops "verify.valid_min" "$verify_ops" 1000
  require_min_ops "build.valid_min" "$build_ops" 700
  require_min_ops "run.add" "$run_add_ops" 1200
  require_min_ops "run.sum6" "$run_sum6_ops" 1100
  require_min_ops "build-elf.sum6" "$build_elf_ops" 500
  require_min_ops "mapcat.trace_map" "$mapcat_ops" 1200
  require_min_ops "schemacat.trace_schema" "$schemacat_ops" 1200
  require_min_ops "tracecat.trace_bin" "$tracecat_ops" 1200
  require_min_ops "tracejoin.trace_bin+map" "$tracejoin_ops" 1000
else
  require_min_ops "verify.valid_min" "$verify_ops" 1800
  require_min_ops "build.valid_min" "$build_ops" 1300
  require_min_ops "run.add" "$run_add_ops" 2400
  require_min_ops "run.sum6" "$run_sum6_ops" 2200
  require_min_ops "build-elf.sum6" "$build_elf_ops" 1100
  require_min_ops "mapcat.trace_map" "$mapcat_ops" 2500
  require_min_ops "schemacat.trace_schema" "$schemacat_ops" 2500
  require_min_ops "tracecat.trace_bin" "$tracecat_ops" 2500
  require_min_ops "tracejoin.trace_bin+map" "$tracejoin_ops" 2300
fi

echo "ok"
