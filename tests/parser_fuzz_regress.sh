#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DEFAULT="$ROOT/bin/l0c"
SEED_DIR_DEFAULT="$ROOT/tests/fuzz/parser_seeds"

check_no_crash() {
  local label="$1"
  shift
  local out="/tmp/l0_m52_${label}.out"
  local err="/tmp/l0_m52_${label}.err"
  local rc

  set +e
  "$@" >"$out" 2>"$err"
  rc=$?
  set -e

  if [ "$rc" -ne 0 ] && [ "$rc" -ne 5 ]; then
    echo "FAIL: parser crash/non-deterministic exit for $label (rc=$rc)"
    echo "command: $*"
    exit 1
  fi
}

run_one_file() {
  local bin="$1"
  local path="$2"
  local tag

  tag="$(basename "$path" | tr -c '[:alnum:]' '_')"
  check_no_crash "verify_${tag}" "$bin" verify "$path"
  check_no_crash "canon_${tag}" "$bin" canon "$path"
}

make_mutants() {
  local seed="$1"
  local outdir="$2"
  local base size half

  base="$(basename "$seed")"
  size=$(wc -c < "$seed")
  half=$((size / 2))
  if [ "$half" -lt 1 ]; then
    half=1
  fi

  cp "$seed" "$outdir/${base}.mut_append_garbage.l0"
  printf '\n@@@\n' >> "$outdir/${base}.mut_append_garbage.l0"

  { printf '@@@\n'; cat "$seed"; } > "$outdir/${base}.mut_prepend_garbage.l0"

  head -c "$half" "$seed" > "$outdir/${base}.mut_truncate_half.l0"

  if [ "$size" -gt 1 ]; then
    head -c $((size - 1)) "$seed" > "$outdir/${base}.mut_drop_last_byte.l0"
  else
    cp "$seed" "$outdir/${base}.mut_drop_last_byte.l0"
  fi

  cp "$seed" "$outdir/${base}.mut_first_byte_nul.l0"
  printf '\0' | dd of="$outdir/${base}.mut_first_byte_nul.l0" bs=1 seek=0 conv=notrunc status=none

  cp "$seed" "$outdir/${base}.mut_mid_byte_ff.l0"
  printf '\xff' | dd of="$outdir/${base}.mut_mid_byte_ff.l0" bs=1 seek=$((size / 2)) conv=notrunc status=none
}

run_suite() {
  local bin="$1"
  local seed_dir="$2"
  local tmp_dir seed mut

  tmp_dir="/tmp/l0_m52_fuzz"
  rm -rf "$tmp_dir"
  mkdir -p "$tmp_dir"

  for seed in "$seed_dir"/*.l0; do
    run_one_file "$bin" "$seed"
    make_mutants "$seed" "$tmp_dir"
  done

  for mut in "$tmp_dir"/*.l0; do
    run_one_file "$bin" "$mut"
  done

  echo "ok"
}

if [ "${1:-}" = "--repro" ]; then
  if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "usage: $0 --repro <input.l0> [bin]" >&2
    exit 2
  fi
  input="$2"
  bin="${3:-$BIN_DEFAULT}"
  run_one_file "$bin" "$input"
  echo "ok"
  exit 0
fi

if [ "$#" -gt 2 ]; then
  echo "usage: $0 [bin] [seed_dir]" >&2
  exit 2
fi

bin="${1:-$BIN_DEFAULT}"
seed_dir="${2:-$SEED_DIR_DEFAULT}"

run_suite "$bin" "$seed_dir"
