#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="${1:-$ROOT/bin/l0c}"
MATRIX="${2:-$ROOT/tests/verifier_matrix.tsv}"

run_positive() {
  local rule="$1"
  local file="$2"
  local out="/tmp/l0_m53_${rule}_pos.out"
  if ! "$BIN" verify "$ROOT/tests/$file" >"$out" 2>/tmp/l0_m53_pos.err; then
    echo "FAIL: $rule positive fixture rejected: $file"
    exit 1
  fi
  if ! grep -q '^ok$' "$out"; then
    echo "FAIL: $rule positive fixture missing ok output: $file"
    exit 1
  fi
}

run_negative() {
  local rule="$1"
  local file="$2"
  local rc
  set +e
  "$BIN" verify "$ROOT/tests/$file" >/tmp/l0_m53_neg.out 2>/tmp/l0_m53_neg.err
  rc=$?
  set -e
  if [ "$rc" -eq 0 ]; then
    echo "FAIL: $rule negative fixture unexpectedly accepted: $file"
    exit 1
  fi
  if [ "$rc" -ne 5 ]; then
    echo "FAIL: $rule negative fixture exit code drift: $file rc=$rc"
    exit 1
  fi
}

while IFS='|' read -r rule desc pos neg; do
  [ -z "${rule}" ] && continue
  run_positive "$rule" "$pos"
  run_negative "$rule" "$neg"
done < "$MATRIX"

echo "ok"
