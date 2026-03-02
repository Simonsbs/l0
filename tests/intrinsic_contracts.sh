#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"

get_kernel_kind() {
  local img="$1"
  local dbg_off
  dbg_off=$(od -An -t u8 -j 64 -N 8 "$img" | tr -d ' ')
  od -An -t u8 -j "$((dbg_off + 32))" -N 8 "$img" | tr -d ' '
}

get_code_size() {
  local img="$1"
  od -An -t u8 -j 56 -N 8 "$img" | tr -d ' '
}

# malloc contract: lowered kernel, returns nonzero pointer-like value, mismatch shape falls back.
"$BIN" verify "$ROOT/tests/valid_malloc.l0" >/tmp/l0_m60_verify_malloc.out
if ! grep -q '^ok$' /tmp/l0_m60_verify_malloc.out; then
  echo "FAIL: M60 verify valid_malloc"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_malloc.l0" /tmp/l0_m60_malloc.img >/tmp/l0_m60_build_malloc.out
if ! grep -q '^ok$' /tmp/l0_m60_build_malloc.out; then
  echo "FAIL: M60 build valid_malloc"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_m60_malloc.img)" != "20" ] || [ "$(get_code_size /tmp/l0_m60_malloc.img)" != "40" ]; then
  echo "FAIL: M60 malloc kernel metadata"
  exit 1
fi
"$BIN" run /tmp/l0_m60_malloc.img 4096 >/tmp/l0_m60_run_malloc.out
if [ "$(tr -d '\n' < /tmp/l0_m60_run_malloc.out)" = "0" ]; then
  echo "FAIL: M60 malloc returned null"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_malloc_mismatch_unlowered.l0" /tmp/l0_m60_malloc_mismatch.img >/tmp/l0_m60_build_malloc_mismatch.out
if ! grep -q '^ok$' /tmp/l0_m60_build_malloc_mismatch.out; then
  echo "FAIL: M60 build valid_malloc_mismatch_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_m60_malloc_mismatch.img)" != "0" ] || [ "$(get_code_size /tmp/l0_m60_malloc_mismatch.img)" != "1" ]; then
  echo "FAIL: M60 malloc mismatch fallback contract"
  exit 1
fi

# free contract: lowered no-op kernel returns 0 and remains lowered for current mismatch fixture.
"$BIN" build "$ROOT/tests/valid_free_noop.l0" /tmp/l0_m60_free.img >/tmp/l0_m60_build_free.out
if ! grep -q '^ok$' /tmp/l0_m60_build_free.out; then
  echo "FAIL: M60 build valid_free_noop"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_m60_free.img)" != "21" ] || [ "$(get_code_size /tmp/l0_m60_free.img)" != "4" ]; then
  echo "FAIL: M60 free kernel metadata"
  exit 1
fi
"$BIN" run /tmp/l0_m60_free.img 123 >/tmp/l0_m60_run_free.out
if [ "$(tr -d '\n' < /tmp/l0_m60_run_free.out)" != "0" ]; then
  echo "FAIL: M60 free runtime contract"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_free_noop_mismatch_unlowered.l0" /tmp/l0_m60_free_mismatch.img >/tmp/l0_m60_build_free_mismatch.out
if ! grep -q '^ok$' /tmp/l0_m60_build_free_mismatch.out; then
  echo "FAIL: M60 build valid_free_noop_mismatch_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_m60_free_mismatch.img)" != "21" ]; then
  echo "FAIL: M60 free mismatch current contract"
  exit 1
fi

# exit contract: lowered syscall kernel exits with provided code and remains lowered for current mismatch fixture.
"$BIN" build "$ROOT/tests/valid_exit.l0" /tmp/l0_m60_exit.img >/tmp/l0_m60_build_exit.out
if ! grep -q '^ok$' /tmp/l0_m60_build_exit.out; then
  echo "FAIL: M60 build valid_exit"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_m60_exit.img)" != "23" ] || [ "$(get_code_size /tmp/l0_m60_exit.img)" != "9" ]; then
  echo "FAIL: M60 exit kernel metadata"
  exit 1
fi
set +e
"$BIN" run /tmp/l0_m60_exit.img 7 >/tmp/l0_m60_run_exit.out 2>/tmp/l0_m60_run_exit.err
exit_rc=$?
set -e
if [ "$exit_rc" -ne 7 ]; then
  echo "FAIL: M60 exit runtime contract"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_exit_mismatch_unlowered.l0" /tmp/l0_m60_exit_mismatch.img >/tmp/l0_m60_build_exit_mismatch.out
if ! grep -q '^ok$' /tmp/l0_m60_build_exit_mismatch.out; then
  echo "FAIL: M60 build valid_exit_mismatch_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_m60_exit_mismatch.img)" != "23" ]; then
  echo "FAIL: M60 exit mismatch current contract"
  exit 1
fi

# write contract: newline write kernel returns 0 with deterministic stdout bytes; alloca0 guardrail fallback.
"$BIN" build "$ROOT/tests/valid_write_newline.l0" /tmp/l0_m60_write.img >/tmp/l0_m60_build_write.out
if ! grep -q '^ok$' /tmp/l0_m60_build_write.out; then
  echo "FAIL: M60 build valid_write_newline"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_m60_write.img)" != "22" ] || [ "$(get_code_size /tmp/l0_m60_write.img)" != "46" ]; then
  echo "FAIL: M60 write kernel metadata"
  exit 1
fi
"$BIN" run /tmp/l0_m60_write.img >/tmp/l0_m60_run_write.out
if [ "$(od -An -t x1 /tmp/l0_m60_run_write.out | tr -d ' \n')" != "0a300a" ]; then
  echo "FAIL: M60 write runtime bytes"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_write_newline_mismatch_unlowered.l0" /tmp/l0_m60_write_mismatch.img >/tmp/l0_m60_build_write_mismatch.out
if ! grep -q '^ok$' /tmp/l0_m60_build_write_mismatch.out; then
  echo "FAIL: M60 build valid_write_newline_mismatch_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_m60_write_mismatch.img)" != "22" ]; then
  echo "FAIL: M60 write mismatch current contract"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_write_newline_alloca0_unlowered.l0" /tmp/l0_m60_write_alloca0.img >/tmp/l0_m60_build_write_alloca0.out
if ! grep -q '^ok$' /tmp/l0_m60_build_write_alloca0.out; then
  echo "FAIL: M60 build valid_write_newline_alloca0_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_m60_write_alloca0.img)" != "0" ] || [ "$(get_code_size /tmp/l0_m60_write_alloca0.img)" != "1" ]; then
  echo "FAIL: M60 write alloca0 guardrail contract"
  exit 1
fi

# trace contract: fixed 16-byte record (id=1,value=input), returns 0, mismatch fixture remains lowered.
"$BIN" build "$ROOT/tests/valid_trace_noop.l0" /tmp/l0_m60_trace.img >/tmp/l0_m60_build_trace.out
if ! grep -q '^ok$' /tmp/l0_m60_build_trace.out; then
  echo "FAIL: M60 build valid_trace_noop"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_m60_trace.img)" != "24" ] || [ "$(get_code_size /tmp/l0_m60_trace.img)" != "51" ]; then
  echo "FAIL: M60 trace kernel metadata"
  exit 1
fi
"$BIN" run /tmp/l0_m60_trace.img 123 >/tmp/l0_m60_run_trace.out 2>/tmp/l0_m60_run_trace.err
if [ "$(tr -d '\n' < /tmp/l0_m60_run_trace.out)" != "0" ]; then
  echo "FAIL: M60 trace return contract"
  exit 1
fi
if [ "$(od -An -t x1 /tmp/l0_m60_run_trace.err | tr -d ' \n')" != "01000000000000007b00000000000000" ]; then
  echo "FAIL: M60 trace record bytes"
  exit 1
fi
"$BIN" tracecat /tmp/l0_m60_run_trace.err >/tmp/l0_m60_tracecat.out
if [ "$(cat /tmp/l0_m60_tracecat.out)" != $'id 1\nval 123' ]; then
  echo "FAIL: M60 tracecat decode contract"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_trace_noop_mismatch_unlowered.l0" /tmp/l0_m60_trace_mismatch.img >/tmp/l0_m60_build_trace_mismatch.out
if ! grep -q '^ok$' /tmp/l0_m60_build_trace_mismatch.out; then
  echo "FAIL: M60 build valid_trace_noop_mismatch_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_m60_trace_mismatch.img)" != "24" ]; then
  echo "FAIL: M60 trace mismatch current contract"
  exit 1
fi

# verifier negative guarantees for intrinsic typing/def-use contracts.
for bad in \
  invalid_malloc_result_not_pointer.l0 \
  invalid_malloc_size_undefined.l0 \
  invalid_malloc_size_pointer.l0 \
  invalid_free_ptr_not_pointer.l0 \
  invalid_exit_undefined.l0 \
  invalid_exit_code_pointer.l0 \
  invalid_write_ptr_not_pointer.l0 \
  invalid_write_len_undefined.l0 \
  invalid_write_len_pointer.l0 \
  invalid_trace_undefined.l0 \
  invalid_trace_second_undefined.l0
  do
  if "$BIN" verify "$ROOT/tests/$bad" >/tmp/l0_m60_bad_verify.out 2>/tmp/l0_m60_bad_verify.err; then
    echo "FAIL: M60 intrinsic negative contract unexpectedly passed: $bad"
    exit 1
  fi
done

echo "ok"
