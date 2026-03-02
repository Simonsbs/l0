#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"

TMP_BASE="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "$TMP_BASE/l0_m67_err.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

run_case() {
  local name="$1"
  local expect_rc="$2"
  local expect_err="$3"
  shift 3

  set +e
  "$@" >"$WORK_DIR/${name}.out" 2>"$WORK_DIR/${name}.err"
  local rc=$?
  set -e

  if [ "$rc" -ne "$expect_rc" ]; then
    echo "FAIL: M67 $name unexpected rc=$rc (expected $expect_rc)"
    exit 1
  fi

  local err
  err="$(cat "$WORK_DIR/${name}.err")"
  if [ "$err" != "$expect_err" ]; then
    echo "FAIL: M67 $name unexpected stderr"
    echo "got:      $err"
    echo "expected: $expect_err"
    exit 1
  fi

  if [ "$expect_rc" -ne 2 ] && [[ "$err" != error:* ]]; then
    echo "FAIL: M67 $name stderr is not normalized to error prefix"
    exit 1
  fi
}

USAGE='usage: l0c <canon|verify> <input.l0> | l0c canon <input.l0> -o <out.l0> | l0c build <input.l0> <out.l0img> [--trace-schema <out.bin>] [--debug-map <out.bin>] | l0c build <input.l0> -o <out.l0img> [--trace-schema <out.bin>] [--debug-map <out.bin>] | l0c build-elf <input.l0> <out.o> | l0c imgcheck <file.l0img> | l0c imgmeta <file.l0img> | l0c run <file.l0img> [u64_a] [u64_b] [u64_c] [u64_d] [u64_e] [u64_f] | l0c tracecat <trace.bin> | l0c mapcat <debug_map.bin> | l0c schemacat <trace_schema.bin> | l0c tracejoin <trace.bin> <debug_map.bin>'
ERR_OPEN='error: cannot open input'
ERR_READ='error: cannot read input'
ERR_PARSE='error: invalid module shape or non-canonical input'
ERR_BUILD='error: cannot write output image'
ERR_IMG='error: invalid or corrupt L0IMG'
ERR_RUN_ARG='error: invalid run argument (expected unsigned decimal)'

# Category: usage (exit 2)
run_case usage_no_args 2 "$USAGE" "$BIN"
run_case usage_unknown_cmd 2 "$USAGE" "$BIN" unknown
run_case usage_verify_missing_arg 2 "$USAGE" "$BIN" verify

# Category: cannot open input (exit 3)
run_case open_verify_missing_file 3 "$ERR_OPEN" "$BIN" verify "$WORK_DIR/no_such_input.l0"
run_case open_tracecat_missing_file 3 "$ERR_OPEN" "$BIN" tracecat "$WORK_DIR/no_trace.bin"

# Category: cannot read input (exit 4)
run_case read_verify_directory_input 4 "$ERR_READ" "$BIN" verify /tmp

# Category: parse/non-canonical (exit 5)
run_case parse_verify_invalid_module 5 "$ERR_PARSE" "$BIN" verify "$ROOT/tests/invalid_order.l0"
printf '\x01' >"$WORK_DIR/truncated.trace"
run_case parse_tracecat_truncated 5 "$ERR_PARSE" "$BIN" tracecat "$WORK_DIR/truncated.trace"
printf 'BAD!' >"$WORK_DIR/bad.map"
run_case parse_mapcat_bad_magic 5 "$ERR_PARSE" "$BIN" mapcat "$WORK_DIR/bad.map"
printf 'BAD!' >"$WORK_DIR/bad.schema"
run_case parse_schemacat_bad_magic 5 "$ERR_PARSE" "$BIN" schemacat "$WORK_DIR/bad.schema"

# Category: write output image failure (exit 6)
run_case build_write_output_denied 6 "$ERR_BUILD" "$BIN" build "$ROOT/tests/valid_min.l0" /proc/l0_m67_denied.img

# Category: invalid/corrupt image (exit 7)
printf 'BADIMGDATA' >"$WORK_DIR/bad.img"
run_case imgcheck_corrupt 7 "$ERR_IMG" "$BIN" imgcheck "$WORK_DIR/bad.img"
run_case imgmeta_corrupt 7 "$ERR_IMG" "$BIN" imgmeta "$WORK_DIR/bad.img"
run_case run_corrupt 7 "$ERR_IMG" "$BIN" run "$WORK_DIR/bad.img"

# Category: run argument error (exit 9)
"$BIN" build "$ROOT/tests/valid_min.l0" "$WORK_DIR/min.img" >"$WORK_DIR/build_min.out"
if ! grep -q '^ok$' "$WORK_DIR/build_min.out"; then
  echo "FAIL: M67 could not build min image for run-arg check"
  exit 1
fi
run_case run_bad_arg 9 "$ERR_RUN_ARG" "$BIN" run "$WORK_DIR/min.img" not_a_u64

echo "ok"
