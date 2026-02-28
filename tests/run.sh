#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$ROOT/bin/l0c"

"$BIN" verify "$ROOT/tests/valid_min.l0" >/tmp/l0_ok.out
if ! grep -q '^ok$' /tmp/l0_ok.out; then
  echo "FAIL: verify valid_min"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_branch.l0" >/tmp/l0_ok_branch.out
if ! grep -q '^ok$' /tmp/l0_ok_branch.out; then
  echo "FAIL: verify valid_branch"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call.l0" >/tmp/l0_ok_call.out
if ! grep -q '^ok$' /tmp/l0_ok_call.out; then
  echo "FAIL: verify valid_call"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_min.l0" /tmp/l0_test.img >/tmp/l0_build.out
if ! grep -q '^ok$' /tmp/l0_build.out; then
  echo "FAIL: build valid_min"
  exit 1
fi
if [ ! -s /tmp/l0_test.img ]; then
  echo "FAIL: build output missing"
  exit 1
fi
if [ "$(head -c 4 /tmp/l0_test.img)" != "L0IM" ]; then
  echo "FAIL: build header magic"
  exit 1
fi
in_size=$(wc -c < "$ROOT/tests/valid_min.l0")
img_size=$(wc -c < /tmp/l0_test.img)
expected_size=$((80 + in_size))
if [ "$img_size" -ne "$expected_size" ]; then
  echo "FAIL: build image size mismatch"
  exit 1
fi
version=$(od -An -t u8 -j 8 -N 8 /tmp/l0_test.img | tr -d ' ')
hdr_size=$(od -An -t u8 -j 16 -N 8 /tmp/l0_test.img | tr -d ' ')
src_off=$(od -An -t u8 -j 32 -N 8 /tmp/l0_test.img | tr -d ' ')
src_size=$(od -An -t u8 -j 40 -N 8 /tmp/l0_test.img | tr -d ' ')
if [ "$version" != "1" ] || [ "$hdr_size" != "80" ] || [ "$src_off" != "80" ] || [ "$src_size" != "$in_size" ]; then
  echo "FAIL: build header fields"
  exit 1
fi
"$BIN" imgcheck /tmp/l0_test.img >/tmp/l0_imgcheck.out
if ! grep -q '^ok$' /tmp/l0_imgcheck.out; then
  echo "FAIL: imgcheck valid image"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_badver.img
printf '\x02\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_badver.img bs=1 seek=8 conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_badver.img >/tmp/l0_badver.out 2>/tmp/l0_badver.err; then
  echo "FAIL: imgcheck accepted bad version"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_badflags.img
printf '\x01\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_badflags.img bs=1 seek=24 conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_badflags.img >/tmp/l0_badflags.out 2>/tmp/l0_badflags.err; then
  echo "FAIL: imgcheck accepted nonzero flags"
  exit 1
fi
printf 'BADIMG' >/tmp/l0_bad.img
if "$BIN" imgcheck /tmp/l0_bad.img >/tmp/l0_badimg.out 2>/tmp/l0_badimg.err; then
  echo "FAIL: imgcheck accepted invalid image"
  exit 1
fi

if "$BIN" verify "$ROOT/tests/invalid_order.l0" >/tmp/l0_bad.out 2>/tmp/l0_bad.err; then
  echo "FAIL: invalid_order unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_no_terminator.l0" >/tmp/l0_bad2.out 2>/tmp/l0_bad2.err; then
  echo "FAIL: invalid_no_terminator unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_instr_before_block.l0" >/tmp/l0_bad3.out 2>/tmp/l0_bad3.err; then
  echo "FAIL: invalid_instr_before_block unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_instr_after_terminator.l0" >/tmp/l0_bad4.out 2>/tmp/l0_bad4.err; then
  echo "FAIL: invalid_instr_after_terminator unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_fn_missing_arrow.l0" >/tmp/l0_bad5.out 2>/tmp/l0_bad5.err; then
  echo "FAIL: invalid_fn_missing_arrow unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_fn_bad_arg_list.l0" >/tmp/l0_bad6.out 2>/tmp/l0_bad6.err; then
  echo "FAIL: invalid_fn_bad_arg_list unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_value_missing_type_suffix.l0" >/tmp/l0_bad7.out 2>/tmp/l0_bad7.err; then
  echo "FAIL: invalid_value_missing_type_suffix unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_value_bad_opcode_token.l0" >/tmp/l0_bad8.out 2>/tmp/l0_bad8.err; then
  echo "FAIL: invalid_value_bad_opcode_token unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_first_block_not_b0.l0" >/tmp/l0_bad9.out 2>/tmp/l0_bad9.err; then
  echo "FAIL: invalid_first_block_not_b0 unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_duplicate_b0.l0" >/tmp/l0_bad10.out 2>/tmp/l0_bad10.err; then
  echo "FAIL: invalid_duplicate_b0 unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_duplicate_block_label.l0" >/tmp/l0_bad11.out 2>/tmp/l0_bad11.err; then
  echo "FAIL: invalid_duplicate_block_label unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_arg_operand.l0" >/tmp/l0_bad12.out 2>/tmp/l0_bad12.err; then
  echo "FAIL: invalid_arg_operand unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_binary_operands.l0" >/tmp/l0_bad13.out 2>/tmp/l0_bad13.err; then
  echo "FAIL: invalid_binary_operands unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_arg_out_of_range.l0" >/tmp/l0_bad14.out 2>/tmp/l0_bad14.err; then
  echo "FAIL: invalid_arg_out_of_range unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_duplicate_value_def.l0" >/tmp/l0_bad15.out 2>/tmp/l0_bad15.err; then
  echo "FAIL: invalid_duplicate_value_def unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_br_target_missing.l0" >/tmp/l0_bad16.out 2>/tmp/l0_bad16.err; then
  echo "FAIL: invalid_br_target_missing unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_cbr_target_missing.l0" >/tmp/l0_bad17.out 2>/tmp/l0_bad17.err; then
  echo "FAIL: invalid_cbr_target_missing unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_ret_undefined_value.l0" >/tmp/l0_bad18.out 2>/tmp/l0_bad18.err; then
  echo "FAIL: invalid_ret_undefined_value unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_binary_use_before_def.l0" >/tmp/l0_bad19.out 2>/tmp/l0_bad19.err; then
  echo "FAIL: invalid_binary_use_before_def unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_cbr_cond_undefined.l0" >/tmp/l0_bad20.out 2>/tmp/l0_bad20.err; then
  echo "FAIL: invalid_cbr_cond_undefined unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_call_bad_shape.l0" >/tmp/l0_bad21.out 2>/tmp/l0_bad21.err; then
  echo "FAIL: invalid_call_bad_shape unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_call_use_before_def.l0" >/tmp/l0_bad22.out 2>/tmp/l0_bad22.err; then
  echo "FAIL: invalid_call_use_before_def unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_noncontiguous_block_id.l0" >/tmp/l0_bad23.out 2>/tmp/l0_bad23.err; then
  echo "FAIL: invalid_noncontiguous_block_id unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_first_fn_not_f0.l0" >/tmp/l0_bad24.out 2>/tmp/l0_bad24.err; then
  echo "FAIL: invalid_first_fn_not_f0 unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_noncontiguous_fn_id.l0" >/tmp/l0_bad25.out 2>/tmp/l0_bad25.err; then
  echo "FAIL: invalid_noncontiguous_fn_id unexpectedly passed"
  exit 1
fi

echo "PASS"
