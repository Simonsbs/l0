#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"

PARSER_SEEDS_DIR="$ROOT/tests/fuzz/parser_seeds"
VERIFIER_SEEDS_DIR="$ROOT/tests/fuzz/verifier_seeds"
REGRESSIONS_DIR="$ROOT/tests/fuzz/m65_regressions"

TMP_BASE="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "$TMP_BASE/l0_m65_fuzz.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

check_no_crash() {
  local tag="$1"
  shift
  local out="$WORK_DIR/${tag}.out"
  local err="$WORK_DIR/${tag}.err"
  local rc

  set +e
  "$@" >"$out" 2>"$err"
  rc=$?
  set -e

  if [ "$rc" -ge 128 ]; then
    echo "FAIL: M65 crash detected for $tag (rc=$rc)"
    echo "command: $*"
    exit 1
  fi

  return "$rc"
}

must_fail() {
  local tag="$1"
  shift
  if check_no_crash "$tag" "$@"; then
    echo "FAIL: M65 expected failure but command succeeded for $tag"
    echo "command: $*"
    exit 1
  fi
}

make_text_mutants() {
  local seed="$1"
  local outdir="$2"
  local base size half mid last

  base="$(basename "$seed")"
  size=$(wc -c < "$seed")
  half=$((size / 2))
  mid=$((size / 2))
  last=$((size - 1))

  if [ "$half" -lt 1 ]; then
    half=1
  fi
  if [ "$last" -lt 0 ]; then
    last=0
  fi

  cp "$seed" "$outdir/${base}.mut_append_garbage"
  printf '\n@@@\n' >> "$outdir/${base}.mut_append_garbage"

  { printf '@@@\n'; cat "$seed"; } > "$outdir/${base}.mut_prepend_garbage"

  head -c "$half" "$seed" > "$outdir/${base}.mut_truncate_half"

  if [ "$size" -gt 1 ]; then
    head -c "$last" "$seed" > "$outdir/${base}.mut_drop_last"
  else
    cp "$seed" "$outdir/${base}.mut_drop_last"
  fi

  cp "$seed" "$outdir/${base}.mut_first_nul"
  printf '\0' | dd of="$outdir/${base}.mut_first_nul" bs=1 seek=0 conv=notrunc status=none

  cp "$seed" "$outdir/${base}.mut_mid_ff"
  printf '\xff' | dd of="$outdir/${base}.mut_mid_ff" bs=1 seek="$mid" conv=notrunc status=none

  cp "$seed" "$outdir/${base}.mut_mid_lbrace"
  printf '{' | dd of="$outdir/${base}.mut_mid_lbrace" bs=1 seek="$mid" conv=notrunc status=none

  cp "$seed" "$outdir/${base}.mut_last_hash"
  printf '#' | dd of="$outdir/${base}.mut_last_hash" bs=1 seek="$last" conv=notrunc status=none

  cp "$seed" "$outdir/${base}.mut_first_upper_v"
  printf 'V' | dd of="$outdir/${base}.mut_first_upper_v" bs=1 seek=0 conv=notrunc status=none
}

make_binary_mutants() {
  local seed="$1"
  local outdir="$2"
  local base size mid last

  base="$(basename "$seed")"
  size=$(wc -c < "$seed")
  mid=$((size / 2))
  last=$((size - 1))

  if [ "$last" -lt 0 ]; then
    last=0
  fi

  cp "$seed" "$outdir/${base}.mut_truncate_half"
  if [ "$size" -gt 1 ]; then
    head -c "$mid" "$seed" > "$outdir/${base}.mut_truncate_half"
  fi

  cp "$seed" "$outdir/${base}.mut_append_16_ff"
  printf '\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff\xff' >> "$outdir/${base}.mut_append_16_ff"

  cp "$seed" "$outdir/${base}.mut_first_8_zero"
  printf '\0\0\0\0\0\0\0\0' | dd of="$outdir/${base}.mut_first_8_zero" bs=1 seek=0 conv=notrunc status=none

  cp "$seed" "$outdir/${base}.mut_mid_8_ff"
  printf '\xff\xff\xff\xff\xff\xff\xff\xff' | dd of="$outdir/${base}.mut_mid_8_ff" bs=1 seek="$mid" conv=notrunc status=none

  cp "$seed" "$outdir/${base}.mut_last_8_aa"
  printf '\xaa\xaa\xaa\xaa\xaa\xaa\xaa\xaa' | dd of="$outdir/${base}.mut_last_8_aa" bs=1 seek="$last" conv=notrunc status=none

  cp "$seed" "$outdir/${base}.mut_second_8_zero"
  printf '\0\0\0\0\0\0\0\0' | dd of="$outdir/${base}.mut_second_8_zero" bs=1 seek=8 conv=notrunc status=none

  cp "$seed" "$outdir/${base}.mut_mid_ascii"
  printf 'M65M65!!' | dd of="$outdir/${base}.mut_mid_ascii" bs=1 seek="$mid" conv=notrunc status=none

  cp "$seed" "$outdir/${base}.mut_tail_zero"
  printf '\0\0\0\0\0\0\0\0' | dd of="$outdir/${base}.mut_tail_zero" bs=1 seek="$last" conv=notrunc status=none
}

parser_cmds=0
verifier_cmds=0
image_cmds=0
trace_cmds=0

# Parser surface: verify + canon over seeds and deterministic mutants.
mkdir -p "$WORK_DIR/parser_mut"
for seed in "$PARSER_SEEDS_DIR"/*.l0; do
  check_no_crash "parser_seed_verify_$(basename "$seed")" "$BIN" verify "$seed" || true
  parser_cmds=$((parser_cmds + 1))
  check_no_crash "parser_seed_canon_$(basename "$seed")" "$BIN" canon "$seed" || true
  parser_cmds=$((parser_cmds + 1))
  make_text_mutants "$seed" "$WORK_DIR/parser_mut"
done

for mut in "$WORK_DIR"/parser_mut/*; do
  check_no_crash "parser_mut_verify_$(basename "$mut")" "$BIN" verify "$mut" || true
  parser_cmds=$((parser_cmds + 1))
  check_no_crash "parser_mut_canon_$(basename "$mut")" "$BIN" canon "$mut" || true
  parser_cmds=$((parser_cmds + 1))
done

# Verifier surface: verify over dedicated seeds and deterministic mutants.
mkdir -p "$WORK_DIR/verifier_mut"
for seed in "$VERIFIER_SEEDS_DIR"/*.l0; do
  check_no_crash "verifier_seed_verify_$(basename "$seed")" "$BIN" verify "$seed" || true
  verifier_cmds=$((verifier_cmds + 1))
  make_text_mutants "$seed" "$WORK_DIR/verifier_mut"
done

for mut in "$WORK_DIR"/verifier_mut/*; do
  check_no_crash "verifier_mut_verify_$(basename "$mut")" "$BIN" verify "$mut" || true
  verifier_cmds=$((verifier_cmds + 1))
done

# Locked malformed regressions discovered during M65 fuzz expansion.
for reg in "$REGRESSIONS_DIR"/*.l0; do
  must_fail "regression_verify_$(basename "$reg")" "$BIN" verify "$reg"
  verifier_cmds=$((verifier_cmds + 1))
  must_fail "regression_canon_$(basename "$reg")" "$BIN" canon "$reg"
  parser_cmds=$((parser_cmds + 1))
done

# Image + trace baselines for binary mutation surfaces.
"$BIN" build "$ROOT/tests/valid_min.l0" "$WORK_DIR/min.img" >"$WORK_DIR/build_min.out"
if ! grep -q '^ok$' "$WORK_DIR/build_min.out"; then
  echo "FAIL: M65 could not build valid_min baseline"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_trace_noop.l0" "$WORK_DIR/trace.img" --debug-map "$WORK_DIR/trace.map" --trace-schema "$WORK_DIR/trace.schema" >"$WORK_DIR/build_trace.out"
if ! grep -q '^ok$' "$WORK_DIR/build_trace.out"; then
  echo "FAIL: M65 could not build trace baseline"
  exit 1
fi
"$BIN" run "$WORK_DIR/trace.img" 123 >"$WORK_DIR/trace_run.out" 2>"$WORK_DIR/trace.bin"
if [ "$(cat "$WORK_DIR/trace_run.out")" != "0" ]; then
  echo "FAIL: M65 trace baseline run output mismatch"
  exit 1
fi

# Image surface: imgcheck + imgmeta over baseline and deterministic mutants.
mkdir -p "$WORK_DIR/image_mut"
for seed in "$WORK_DIR/min.img" "$WORK_DIR/trace.img"; do
  check_no_crash "image_seed_imgcheck_$(basename "$seed")" "$BIN" imgcheck "$seed" || true
  image_cmds=$((image_cmds + 1))
  check_no_crash "image_seed_imgmeta_$(basename "$seed")" "$BIN" imgmeta "$seed" || true
  image_cmds=$((image_cmds + 1))
  make_binary_mutants "$seed" "$WORK_DIR/image_mut"
done

for mut in "$WORK_DIR"/image_mut/*; do
  check_no_crash "image_mut_imgcheck_$(basename "$mut")" "$BIN" imgcheck "$mut" || true
  image_cmds=$((image_cmds + 1))
  check_no_crash "image_mut_imgmeta_$(basename "$mut")" "$BIN" imgmeta "$mut" || true
  image_cmds=$((image_cmds + 1))
done

# Trace surface: schemacat/mapcat/tracecat/tracejoin over baseline and deterministic mutants.
check_no_crash "trace_seed_schemacat" "$BIN" schemacat "$WORK_DIR/trace.schema" || true
trace_cmds=$((trace_cmds + 1))
check_no_crash "trace_seed_mapcat" "$BIN" mapcat "$WORK_DIR/trace.map" || true
trace_cmds=$((trace_cmds + 1))
check_no_crash "trace_seed_tracecat" "$BIN" tracecat "$WORK_DIR/trace.bin" || true
trace_cmds=$((trace_cmds + 1))
check_no_crash "trace_seed_tracejoin" "$BIN" tracejoin "$WORK_DIR/trace.bin" "$WORK_DIR/trace.map" || true
trace_cmds=$((trace_cmds + 1))

mkdir -p "$WORK_DIR/map_mut" "$WORK_DIR/schema_mut" "$WORK_DIR/tracebin_mut"
make_binary_mutants "$WORK_DIR/trace.map" "$WORK_DIR/map_mut"
make_binary_mutants "$WORK_DIR/trace.schema" "$WORK_DIR/schema_mut"
make_binary_mutants "$WORK_DIR/trace.bin" "$WORK_DIR/tracebin_mut"

for mut in "$WORK_DIR"/map_mut/*; do
  check_no_crash "trace_mut_mapcat_$(basename "$mut")" "$BIN" mapcat "$mut" || true
  trace_cmds=$((trace_cmds + 1))
  check_no_crash "trace_mut_tracejoin_map_$(basename "$mut")" "$BIN" tracejoin "$WORK_DIR/trace.bin" "$mut" || true
  trace_cmds=$((trace_cmds + 1))
done

for mut in "$WORK_DIR"/schema_mut/*; do
  check_no_crash "trace_mut_schemacat_$(basename "$mut")" "$BIN" schemacat "$mut" || true
  trace_cmds=$((trace_cmds + 1))
done

for mut in "$WORK_DIR"/tracebin_mut/*; do
  check_no_crash "trace_mut_tracecat_$(basename "$mut")" "$BIN" tracecat "$mut" || true
  trace_cmds=$((trace_cmds + 1))
  check_no_crash "trace_mut_tracejoin_trace_$(basename "$mut")" "$BIN" tracejoin "$mut" "$WORK_DIR/trace.map" || true
  trace_cmds=$((trace_cmds + 1))
done

# Fixed budgets to keep this gate deterministic and measurable.
if [ "$parser_cmds" -lt 120 ]; then
  echo "FAIL: M65 parser stress budget too small ($parser_cmds)"
  exit 1
fi
if [ "$verifier_cmds" -lt 30 ]; then
  echo "FAIL: M65 verifier stress budget too small ($verifier_cmds)"
  exit 1
fi
if [ "$image_cmds" -lt 20 ]; then
  echo "FAIL: M65 image stress budget too small ($image_cmds)"
  exit 1
fi
if [ "$trace_cmds" -lt 35 ]; then
  echo "FAIL: M65 trace stress budget too small ($trace_cmds)"
  exit 1
fi

echo "ok"
