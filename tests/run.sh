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
"$BIN" verify "$ROOT/tests/valid_ptr_type.l0" >/tmp/l0_ok_ptr.out
if ! grep -q '^ok$' /tmp/l0_ok_ptr.out; then
  echo "FAIL: verify valid_ptr_type"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_const.l0" >/tmp/l0_ok_const.out
if ! grep -q '^ok$' /tmp/l0_ok_const.out; then
  echo "FAIL: verify valid_const"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_const_neg.l0" >/tmp/l0_ok_const_neg.out
if ! grep -q '^ok$' /tmp/l0_ok_const_neg.out; then
  echo "FAIL: verify valid_const_neg"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_sub.l0" >/tmp/l0_ok_sub.out
if ! grep -q '^ok$' /tmp/l0_ok_sub.out; then
  echo "FAIL: verify valid_sub"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_shl.l0" >/tmp/l0_ok_shl.out
if ! grep -q '^ok$' /tmp/l0_ok_shl.out; then
  echo "FAIL: verify valid_shl"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mul.l0" >/tmp/l0_ok_mul.out
if ! grep -q '^ok$' /tmp/l0_ok_mul.out; then
  echo "FAIL: verify valid_mul"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_and.l0" >/tmp/l0_ok_and.out
if ! grep -q '^ok$' /tmp/l0_ok_and.out; then
  echo "FAIL: verify valid_and"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_or.l0" >/tmp/l0_ok_or.out
if ! grep -q '^ok$' /tmp/l0_ok_or.out; then
  echo "FAIL: verify valid_or"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_xor.l0" >/tmp/l0_ok_xor.out
if ! grep -q '^ok$' /tmp/l0_ok_xor.out; then
  echo "FAIL: verify valid_xor"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_shr.l0" >/tmp/l0_ok_shr.out
if ! grep -q '^ok$' /tmp/l0_ok_shr.out; then
  echo "FAIL: verify valid_shr"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_icmp_eq.l0" >/tmp/l0_ok_icmp_eq.out
if ! grep -q '^ok$' /tmp/l0_ok_icmp_eq.out; then
  echo "FAIL: verify valid_icmp_eq"
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
expected_size=$((80 + in_size + 7 + 32))
if [ "$img_size" -ne "$expected_size" ]; then
  echo "FAIL: build image size mismatch"
  exit 1
fi
version=$(od -An -t u8 -j 8 -N 8 /tmp/l0_test.img | tr -d ' ')
hdr_size=$(od -An -t u8 -j 16 -N 8 /tmp/l0_test.img | tr -d ' ')
src_off=$(od -An -t u8 -j 32 -N 8 /tmp/l0_test.img | tr -d ' ')
src_size=$(od -An -t u8 -j 40 -N 8 /tmp/l0_test.img | tr -d ' ')
code_off=$(od -An -t u8 -j 48 -N 8 /tmp/l0_test.img | tr -d ' ')
code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test.img | tr -d ' ')
dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test.img | tr -d ' ')
dbg_size=$(od -An -t u8 -j 72 -N 8 /tmp/l0_test.img | tr -d ' ')
if [ "$version" != "1" ] || [ "$hdr_size" != "80" ] || [ "$src_off" != "80" ] || [ "$src_size" != "$in_size" ]; then
  echo "FAIL: build header fields"
  exit 1
fi
if [ "$code_off" != "$((80 + in_size))" ] || [ "$code_size" != "7" ]; then
  echo "FAIL: build code header fields"
  exit 1
fi
if [ "$dbg_off" != "$((80 + in_size + 7))" ] || [ "$dbg_size" != "32" ]; then
  echo "FAIL: build debug header fields"
  exit 1
fi
if [ "$(od -An -t x1 -j "$code_off" -N 7 /tmp/l0_test.img | tr -d ' \n')" != "4889f84801f0c3" ]; then
  echo "FAIL: build code stub bytes"
  exit 1
fi
if [ "$(od -An -t x1 -j "$dbg_off" -N 4 /tmp/l0_test.img | tr -d ' \n')" != "4c304958" ]; then
  echo "FAIL: build debug index magic"
  exit 1
fi
"$BIN" imgcheck /tmp/l0_test.img >/tmp/l0_imgcheck.out
if ! grep -q '^ok$' /tmp/l0_imgcheck.out; then
  echo "FAIL: imgcheck valid image"
  exit 1
fi
"$BIN" run /tmp/l0_test.img 7 5 >/tmp/l0_run_add2.out
if [ "$(tr -d '\n' < /tmp/l0_run_add2.out)" != "12" ]; then
  echo "FAIL: run add2 image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_const.l0" /tmp/l0_test_const.img >/tmp/l0_build_const.out
if ! grep -q '^ok$' /tmp/l0_build_const.out; then
  echo "FAIL: build valid_const"
  exit 1
fi
"$BIN" run /tmp/l0_test_const.img >/tmp/l0_run_const.out
if [ "$(tr -d '\n' < /tmp/l0_run_const.out)" != "42" ]; then
  echo "FAIL: run const image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_const_neg.l0" /tmp/l0_test_const_neg.img >/tmp/l0_build_const_neg.out
if ! grep -q '^ok$' /tmp/l0_build_const_neg.out; then
  echo "FAIL: build valid_const_neg"
  exit 1
fi
"$BIN" run /tmp/l0_test_const_neg.img >/tmp/l0_run_const_neg.out
if [ "$(tr -d '\n' < /tmp/l0_run_const_neg.out)" != "18446744073709551611" ]; then
  echo "FAIL: run const negative image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_sub.l0" /tmp/l0_test_sub.img >/tmp/l0_build_sub.out
if ! grep -q '^ok$' /tmp/l0_build_sub.out; then
  echo "FAIL: build valid_sub"
  exit 1
fi
"$BIN" run /tmp/l0_test_sub.img 9 2 >/tmp/l0_run_sub.out
if [ "$(tr -d '\n' < /tmp/l0_run_sub.out)" != "7" ]; then
  echo "FAIL: run sub image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_shl.l0" /tmp/l0_test_shl.img >/tmp/l0_build_shl.out
if ! grep -q '^ok$' /tmp/l0_build_shl.out; then
  echo "FAIL: build valid_shl"
  exit 1
fi
"$BIN" run /tmp/l0_test_shl.img 3 4 >/tmp/l0_run_shl.out
if [ "$(tr -d '\n' < /tmp/l0_run_shl.out)" != "48" ]; then
  echo "FAIL: run shl image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mul.l0" /tmp/l0_test_mul.img >/tmp/l0_build_mul.out
if ! grep -q '^ok$' /tmp/l0_build_mul.out; then
  echo "FAIL: build valid_mul"
  exit 1
fi
"$BIN" run /tmp/l0_test_mul.img 7 6 >/tmp/l0_run_mul.out
if [ "$(tr -d '\n' < /tmp/l0_run_mul.out)" != "42" ]; then
  echo "FAIL: run mul image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_and.l0" /tmp/l0_test_and.img >/tmp/l0_build_and.out
if ! grep -q '^ok$' /tmp/l0_build_and.out; then
  echo "FAIL: build valid_and"
  exit 1
fi
"$BIN" run /tmp/l0_test_and.img 14 11 >/tmp/l0_run_and.out
if [ "$(tr -d '\n' < /tmp/l0_run_and.out)" != "10" ]; then
  echo "FAIL: run and image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_or.l0" /tmp/l0_test_or.img >/tmp/l0_build_or.out
if ! grep -q '^ok$' /tmp/l0_build_or.out; then
  echo "FAIL: build valid_or"
  exit 1
fi
"$BIN" run /tmp/l0_test_or.img 10 5 >/tmp/l0_run_or.out
if [ "$(tr -d '\n' < /tmp/l0_run_or.out)" != "15" ]; then
  echo "FAIL: run or image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_xor.l0" /tmp/l0_test_xor.img >/tmp/l0_build_xor.out
if ! grep -q '^ok$' /tmp/l0_build_xor.out; then
  echo "FAIL: build valid_xor"
  exit 1
fi
"$BIN" run /tmp/l0_test_xor.img 10 5 >/tmp/l0_run_xor.out
if [ "$(tr -d '\n' < /tmp/l0_run_xor.out)" != "15" ]; then
  echo "FAIL: run xor image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_shr.l0" /tmp/l0_test_shr.img >/tmp/l0_build_shr.out
if ! grep -q '^ok$' /tmp/l0_build_shr.out; then
  echo "FAIL: build valid_shr"
  exit 1
fi
"$BIN" run /tmp/l0_test_shr.img 48 4 >/tmp/l0_run_shr.out
if [ "$(tr -d '\n' < /tmp/l0_run_shr.out)" != "3" ]; then
  echo "FAIL: run shr image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_icmp_eq.l0" /tmp/l0_test_icmp_eq.img >/tmp/l0_build_icmp_eq.out
if ! grep -q '^ok$' /tmp/l0_build_icmp_eq.out; then
  echo "FAIL: build valid_icmp_eq"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq.img 9 9 >/tmp/l0_run_icmp_eq_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_t.out)" != "1" ]; then
  echo "FAIL: run icmp.eq true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq.img 9 8 >/tmp/l0_run_icmp_eq_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_f.out)" != "0" ]; then
  echo "FAIL: run icmp.eq false result"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_branch.l0" /tmp/l0_test_branch.img >/tmp/l0_build_branch.out
if ! grep -q '^ok$' /tmp/l0_build_branch.out; then
  echo "FAIL: build valid_branch"
  exit 1
fi
branch_in_size=$(wc -c < "$ROOT/tests/valid_branch.l0")
branch_code_off=$(od -An -t u8 -j 48 -N 8 /tmp/l0_test_branch.img | tr -d ' ')
branch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_branch.img | tr -d ' ')
if [ "$branch_code_off" != "$((80 + branch_in_size))" ] || [ "$branch_code_size" != "1" ]; then
  echo "FAIL: build valid_branch fallback code header fields"
  exit 1
fi
if [ "$(od -An -t x1 -j "$branch_code_off" -N 1 /tmp/l0_test_branch.img | tr -d ' \n')" != "c3" ]; then
  echo "FAIL: build valid_branch fallback code bytes"
  exit 1
fi
if "$BIN" run /tmp/l0_test.img X 5 >/tmp/l0_run_badarg.out 2>/tmp/l0_run_badarg.err; then
  echo "FAIL: run accepted invalid numeric argument"
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
if "$BIN" verify "$ROOT/tests/invalid_cbr_cond_not_i1.l0" >/tmp/l0_bad20b.out 2>/tmp/l0_bad20b.err; then
  echo "FAIL: invalid_cbr_cond_not_i1 unexpectedly passed"
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
if "$BIN" verify "$ROOT/tests/invalid_call_target_missing_fn.l0" >/tmp/l0_bad26.out 2>/tmp/l0_bad26.err; then
  echo "FAIL: invalid_call_target_missing_fn unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_types_noncontiguous_id.l0" >/tmp/l0_bad27.out 2>/tmp/l0_bad27.err; then
  echo "FAIL: invalid_types_noncontiguous_id unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_types_bad_token.l0" >/tmp/l0_bad27b.out 2>/tmp/l0_bad27b.err; then
  echo "FAIL: invalid_types_bad_token unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_types_bad_pointer_space.l0" >/tmp/l0_bad27c.out 2>/tmp/l0_bad27c.err; then
  echo "FAIL: invalid_types_bad_pointer_space unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_fn_type_unknown.l0" >/tmp/l0_bad28.out 2>/tmp/l0_bad28.err; then
  echo "FAIL: invalid_fn_type_unknown unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_value_type_unknown.l0" >/tmp/l0_bad29.out 2>/tmp/l0_bad29.err; then
  echo "FAIL: invalid_value_type_unknown unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_call_arity_mismatch.l0" >/tmp/l0_bad30.out 2>/tmp/l0_bad30.err; then
  echo "FAIL: invalid_call_arity_mismatch unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_arg_result_type_mismatch.l0" >/tmp/l0_bad31.out 2>/tmp/l0_bad31.err; then
  echo "FAIL: invalid_arg_result_type_mismatch unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_ret_value_type_mismatch.l0" >/tmp/l0_bad33.out 2>/tmp/l0_bad33.err; then
  echo "FAIL: invalid_ret_value_type_mismatch unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_binary_result_type_mismatch.l0" >/tmp/l0_bad33b.out 2>/tmp/l0_bad33b.err; then
  echo "FAIL: invalid_binary_result_type_mismatch unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_binary_operand_type_mismatch.l0" >/tmp/l0_bad33c.out 2>/tmp/l0_bad33c.err; then
  echo "FAIL: invalid_binary_operand_type_mismatch unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_call_return_type_mismatch.l0" >/tmp/l0_bad34.out 2>/tmp/l0_bad34.err; then
  echo "FAIL: invalid_call_return_type_mismatch unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_const_bad_operand.l0" >/tmp/l0_bad35.out 2>/tmp/l0_bad35.err; then
  echo "FAIL: invalid_const_bad_operand unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_icmp_result_not_i1.l0" >/tmp/l0_bad36.out 2>/tmp/l0_bad36.err; then
  echo "FAIL: invalid_icmp_result_not_i1 unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_icmp_operand_type_mismatch.l0" >/tmp/l0_bad37.out 2>/tmp/l0_bad37.err; then
  echo "FAIL: invalid_icmp_operand_type_mismatch unexpectedly passed"
  exit 1
fi

echo "PASS"
