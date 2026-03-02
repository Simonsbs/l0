#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"
MATRIX="${3:-$ROOT/tests/compat/m69_matrix.tsv}"

TMP_BASE="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "$TMP_BASE/l0_m69_compat.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

row_count=0

while IFS='|' read -r name fixture args expected; do
  [ -n "$name" ] || continue
  case "$name" in
    \#*) continue ;;
  esac

  row_count=$((row_count + 1))

  src="$ROOT/$fixture"
  img="$WORK_DIR/${name}.img"

  "$BIN" verify "$src" >"$WORK_DIR/${name}.verify.out"
  if ! grep -q '^ok$' "$WORK_DIR/${name}.verify.out"; then
    echo "FAIL: M69 verify failed for $name"
    exit 1
  fi

  "$BIN" build "$src" "$img" >"$WORK_DIR/${name}.build.out"
  if ! grep -q '^ok$' "$WORK_DIR/${name}.build.out"; then
    echo "FAIL: M69 build failed for $name"
    exit 1
  fi

  "$BIN" imgcheck "$img" >"$WORK_DIR/${name}.imgcheck.out"
  if ! grep -q '^ok$' "$WORK_DIR/${name}.imgcheck.out"; then
    echo "FAIL: M69 imgcheck failed for $name"
    exit 1
  fi

  if [ "$args" = "-" ]; then
    "$BIN" run "$img" >"$WORK_DIR/${name}.run.out"
  else
    read -r -a run_args <<<"$args"
    "$BIN" run "$img" "${run_args[@]}" >"$WORK_DIR/${name}.run.out"
  fi

  if [ "$(cat "$WORK_DIR/${name}.run.out")" != "$expected" ]; then
    echo "FAIL: M69 run output mismatch for $name"
    exit 1
  fi
done < "$MATRIX"

if [ "$row_count" -lt 8 ]; then
  echo "FAIL: M69 compatibility matrix unexpectedly small"
  exit 1
fi

# Trace/debug compatibility slice against prior fixture contracts.
"$BIN" verify "$ROOT/tests/valid_trace_noop.l0" >"$WORK_DIR/trace.verify.out"
if ! grep -q '^ok$' "$WORK_DIR/trace.verify.out"; then
  echo "FAIL: M69 trace fixture verify"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_trace_noop.l0" "$WORK_DIR/trace.img" --debug-map "$WORK_DIR/trace.map" --trace-schema "$WORK_DIR/trace.schema" >"$WORK_DIR/trace.build.out"
if ! grep -q '^ok$' "$WORK_DIR/trace.build.out"; then
  echo "FAIL: M69 trace fixture build"
  exit 1
fi
"$BIN" imgcheck "$WORK_DIR/trace.img" >"$WORK_DIR/trace.imgcheck.out"
if ! grep -q '^ok$' "$WORK_DIR/trace.imgcheck.out"; then
  echo "FAIL: M69 trace fixture imgcheck"
  exit 1
fi
"$BIN" run "$WORK_DIR/trace.img" 123 >"$WORK_DIR/trace.run.out" 2>"$WORK_DIR/trace.bin"
if [ "$(cat "$WORK_DIR/trace.run.out")" != "0" ]; then
  echo "FAIL: M69 trace fixture run output"
  exit 1
fi
"$BIN" schemacat "$WORK_DIR/trace.schema" >"$WORK_DIR/trace.schemacat.out"
if [ "$(cat "$WORK_DIR/trace.schemacat.out")" != $'version 1\nrecord_size 16\nfields 2' ]; then
  echo "FAIL: M69 trace schema compatibility output mismatch"
  exit 1
fi
"$BIN" mapcat "$WORK_DIR/trace.map" >"$WORK_DIR/trace.mapcat.out"
if [ "$(cat "$WORK_DIR/trace.mapcat.out")" != $'entries 2\ncode_size 51\ninst_id 1\nstart 0\nend 17\ninst_id 2\nstart 17\nend 51' ]; then
  echo "FAIL: M69 debug map compatibility output mismatch"
  exit 1
fi
"$BIN" tracecat "$WORK_DIR/trace.bin" >"$WORK_DIR/trace.tracecat.out"
if [ "$(cat "$WORK_DIR/trace.tracecat.out")" != $'id 1\nval 123' ]; then
  echo "FAIL: M69 tracecat compatibility output mismatch"
  exit 1
fi
"$BIN" tracejoin "$WORK_DIR/trace.bin" "$WORK_DIR/trace.map" >"$WORK_DIR/trace.tracejoin.out"
if [ "$(cat "$WORK_DIR/trace.tracejoin.out")" != $'id 1\nval 123\nstart 0\nend 17' ]; then
  echo "FAIL: M69 tracejoin compatibility output mismatch"
  exit 1
fi

# ELF object compatibility slice.
"$BIN" build-elf "$ROOT/tests/valid_sysv_abi_sum6_lowered.l0" "$WORK_DIR/sum6.o" >"$WORK_DIR/sum6.buildelf.out"
if ! grep -q '^ok$' "$WORK_DIR/sum6.buildelf.out"; then
  echo "FAIL: M69 build-elf compatibility slice"
  exit 1
fi
cat >"$WORK_DIR/sum6_harness.s" <<'ASM'
.intel_syntax noprefix
.global _start
.extern f0
_start:
  mov rdi, 1
  mov rsi, 2
  mov rdx, 3
  mov rcx, 4
  mov r8, 5
  mov r9, 6
  call f0
  mov rdi, rax
  mov rax, 60
  syscall
ASM
as --64 -o "$WORK_DIR/sum6_harness.o" "$WORK_DIR/sum6_harness.s"
ld -o "$WORK_DIR/sum6_exec" "$WORK_DIR/sum6_harness.o" "$WORK_DIR/sum6.o"
set +e
"$WORK_DIR/sum6_exec"
rc=$?
set -e
if [ "$rc" -ne 21 ]; then
  echo "FAIL: M69 ELF compatibility exit code mismatch"
  exit 1
fi

echo "ok"
