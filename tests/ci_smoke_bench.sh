#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"

TMP_BASE="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "$TMP_BASE/l0_ci_smoke.XXXXXX")"
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
    echo "FAIL: CI smoke benchmark regression for $metric (got ${got} ops/s, min ${min} ops/s)"
    exit 1
  fi
}

"$BIN" verify "$ROOT/tests/valid_min.l0" >"$WORK_DIR/verify.out"
if ! grep -q '^ok$' "$WORK_DIR/verify.out"; then
  echo "FAIL: smoke verify baseline"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_min.l0" "$WORK_DIR/min.img" >"$WORK_DIR/build.out"
if ! grep -q '^ok$' "$WORK_DIR/build.out"; then
  echo "FAIL: smoke build baseline"
  exit 1
fi
"$BIN" run "$WORK_DIR/min.img" 5 8 >"$WORK_DIR/run.out"
if [ "$(cat "$WORK_DIR/run.out")" != "13" ]; then
  echo "FAIL: smoke run baseline"
  exit 1
fi

verify_ops=$(bench_ops 80 "$BIN" verify "$ROOT/tests/valid_min.l0")
build_ops=$(bench_ops 50 "$BIN" build "$ROOT/tests/valid_min.l0" "$WORK_DIR/loop.img")
run_ops=$(bench_ops 300 "$BIN" run "$WORK_DIR/min.img" 7 9)

# CI smoke floors are intentionally conservative for shared hosted runners.
require_min_ops "verify.valid_min" "$verify_ops" 300
require_min_ops "build.valid_min" "$build_ops" 180
require_min_ops "run.add" "$run_ops" 350

echo "ok"
