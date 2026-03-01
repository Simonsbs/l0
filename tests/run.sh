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
"$BIN" canon "$ROOT/tests/valid_min.l0" -o /tmp/l0_canon_min.l0 >/tmp/l0_canon_min_cmd.out
if ! grep -q '^ok$' /tmp/l0_canon_min_cmd.out; then
  echo "FAIL: canon -o valid_min"
  exit 1
fi
if ! cmp -s "$ROOT/tests/valid_min.l0" /tmp/l0_canon_min.l0; then
  echo "FAIL: canon -o output mismatch"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call.l0" >/tmp/l0_ok_call.out
if ! grep -q '^ok$' /tmp/l0_ok_call.out; then
  echo "FAIL: verify valid_call"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_add_lowered.l0" >/tmp/l0_ok_call_add_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_add_lowered.out; then
  echo "FAIL: verify valid_call_add_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_add_swapped_lowered.l0" >/tmp/l0_ok_call_add_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_add_swapped_lowered.out; then
  echo "FAIL: verify valid_call_add_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_add_v7_lowered.l0" >/tmp/l0_ok_call_add_v7_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_add_v7_lowered.out; then
  echo "FAIL: verify valid_call_add_v7_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_add_f1v7_lowered.l0" >/tmp/l0_ok_call_add_f1v7_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_add_f1v7_lowered.out; then
  echo "FAIL: verify valid_call_add_f1v7_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_add_f1_swapped_lowered.l0" >/tmp/l0_ok_call_add_f1_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_add_f1_swapped_lowered.out; then
  echo "FAIL: verify valid_call_add_f1_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_sub_lowered.l0" >/tmp/l0_ok_call_sub_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_sub_lowered.out; then
  echo "FAIL: verify valid_call_sub_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_sub_v7_lowered.l0" >/tmp/l0_ok_call_sub_v7_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_sub_v7_lowered.out; then
  echo "FAIL: verify valid_call_sub_v7_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_sub_f1v123_lowered.l0" >/tmp/l0_ok_call_sub_f1v123_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_sub_f1v123_lowered.out; then
  echo "FAIL: verify valid_call_sub_f1v123_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_add_f1_argdef_order_swapped_lowered.l0" >/tmp/l0_ok_call_add_f1_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_add_f1_argdef_order_swapped_lowered.out; then
  echo "FAIL: verify valid_call_add_f1_argdef_order_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_mul_f1_argdef_order_swapped_lowered.l0" >/tmp/l0_ok_call_mul_f1_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_mul_f1_argdef_order_swapped_lowered.out; then
  echo "FAIL: verify valid_call_mul_f1_argdef_order_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_sub_f1_argdef_order_swapped_lowered.l0" >/tmp/l0_ok_call_sub_f1_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_sub_f1_argdef_order_swapped_lowered.out; then
  echo "FAIL: verify valid_call_sub_f1_argdef_order_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_sub_f1_argdef_order_swapped_unlowered.l0" >/tmp/l0_ok_call_sub_f1_argdef_order_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_sub_f1_argdef_order_swapped_unlowered.out; then
  echo "FAIL: verify valid_call_sub_f1_argdef_order_swapped_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_mul_lowered.l0" >/tmp/l0_ok_call_mul_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_mul_lowered.out; then
  echo "FAIL: verify valid_call_mul_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_mul_swapped_lowered.l0" >/tmp/l0_ok_call_mul_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_mul_swapped_lowered.out; then
  echo "FAIL: verify valid_call_mul_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_mul_v7_swapped_lowered.l0" >/tmp/l0_ok_call_mul_v7_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_mul_v7_swapped_lowered.out; then
  echo "FAIL: verify valid_call_mul_v7_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_mul_f1v77_swapped_lowered.l0" >/tmp/l0_ok_call_mul_f1v77_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_mul_f1v77_swapped_lowered.out; then
  echo "FAIL: verify valid_call_mul_f1v77_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_mul_f1_swapped_lowered.l0" >/tmp/l0_ok_call_mul_f1_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_mul_f1_swapped_lowered.out; then
  echo "FAIL: verify valid_call_mul_f1_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_add_argdef_order_swapped_lowered.l0" >/tmp/l0_ok_call_add_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_add_argdef_order_swapped_lowered.out; then
  echo "FAIL: verify valid_call_add_argdef_order_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_add_argdef_order_swapped_comm_swapped_lowered.l0" >/tmp/l0_ok_call_add_argdef_order_swapped_comm_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_add_argdef_order_swapped_comm_swapped_lowered.out; then
  echo "FAIL: verify valid_call_add_argdef_order_swapped_comm_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_mul_argdef_order_swapped_lowered.l0" >/tmp/l0_ok_call_mul_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_mul_argdef_order_swapped_lowered.out; then
  echo "FAIL: verify valid_call_mul_argdef_order_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_sub_argdef_order_swapped_lowered.l0" >/tmp/l0_ok_call_sub_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_sub_argdef_order_swapped_lowered.out; then
  echo "FAIL: verify valid_call_sub_argdef_order_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_sub_argdef_order_swapped_unlowered.l0" >/tmp/l0_ok_call_sub_argdef_order_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_sub_argdef_order_swapped_unlowered.out; then
  echo "FAIL: verify valid_call_sub_argdef_order_swapped_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_add_mismatch_unlowered.l0" >/tmp/l0_ok_call_add_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_add_mismatch_unlowered.out; then
  echo "FAIL: verify valid_call_add_mismatch_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_sub_f1_swapped_unlowered.l0" >/tmp/l0_ok_call_sub_f1_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_sub_f1_swapped_unlowered.out; then
  echo "FAIL: verify valid_call_sub_f1_swapped_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_add_f1_ret_mismatch_unlowered.l0" >/tmp/l0_ok_call_add_f1_ret_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_add_f1_ret_mismatch_unlowered.out; then
  echo "FAIL: verify valid_call_add_f1_ret_mismatch_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_add_with_dead_const_general_lowered.l0" >/tmp/l0_ok_call_add_with_dead_const_general_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_add_with_dead_const_general_lowered.out; then
  echo "FAIL: verify valid_call_add_with_dead_const_general_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_sub_f1_swapped_with_dead_const_unlowered.l0" >/tmp/l0_ok_call_sub_f1_swapped_with_dead_const_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_sub_f1_swapped_with_dead_const_unlowered.out; then
  echo "FAIL: verify valid_call_sub_f1_swapped_with_dead_const_unlowered"
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
"$BIN" verify "$ROOT/tests/valid_const_v7.l0" >/tmp/l0_ok_const_v7.out
if ! grep -q '^ok$' /tmp/l0_ok_const_v7.out; then
  echo "FAIL: verify valid_const_v7"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_const_v123.l0" >/tmp/l0_ok_const_v123.out
if ! grep -q '^ok$' /tmp/l0_ok_const_v123.out; then
  echo "FAIL: verify valid_const_v123"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_sub.l0" >/tmp/l0_ok_sub.out
if ! grep -q '^ok$' /tmp/l0_ok_sub.out; then
  echo "FAIL: verify valid_sub"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_sub_swapped_unlowered.l0" >/tmp/l0_ok_sub_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_sub_swapped_unlowered.out; then
  echo "FAIL: verify valid_sub_swapped_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_sub_argids_v7_v9_swapped_unlowered.l0" >/tmp/l0_ok_sub_argids_v7_v9_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_sub_argids_v7_v9_swapped_unlowered.out; then
  echo "FAIL: verify valid_sub_argids_v7_v9_swapped_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_add_swapped.l0" >/tmp/l0_ok_add_swapped.out
if ! grep -q '^ok$' /tmp/l0_ok_add_swapped.out; then
  echo "FAIL: verify valid_add_swapped"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_add_v7.l0" >/tmp/l0_ok_add_v7.out
if ! grep -q '^ok$' /tmp/l0_ok_add_v7.out; then
  echo "FAIL: verify valid_add_v7"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_add_argids_v7_v9_lowered.l0" >/tmp/l0_ok_add_argids_v7_v9_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_add_argids_v7_v9_lowered.out; then
  echo "FAIL: verify valid_add_argids_v7_v9_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_add_argids_v7_v9_swapped_lowered.l0" >/tmp/l0_ok_add_argids_v7_v9_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_add_argids_v7_v9_swapped_lowered.out; then
  echo "FAIL: verify valid_add_argids_v7_v9_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_add_argids_v77_v123_lowered.l0" >/tmp/l0_ok_add_argids_v77_v123_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_add_argids_v77_v123_lowered.out; then
  echo "FAIL: verify valid_add_argids_v77_v123_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_add_argdef_order_swapped_lowered.l0" >/tmp/l0_ok_add_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_add_argdef_order_swapped_lowered.out; then
  echo "FAIL: verify valid_add_argdef_order_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_add_argdef_order_swapped_comm_swapped_lowered.l0" >/tmp/l0_ok_add_argdef_order_swapped_comm_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_add_argdef_order_swapped_comm_swapped_lowered.out; then
  echo "FAIL: verify valid_add_argdef_order_swapped_comm_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_sub_argdef_order_swapped_unlowered.l0" >/tmp/l0_ok_sub_argdef_order_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_sub_argdef_order_swapped_unlowered.out; then
  echo "FAIL: verify valid_sub_argdef_order_swapped_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_add_with_dead_const_general_lowered.l0" >/tmp/l0_ok_add_with_dead_const_general_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_add_with_dead_const_general_lowered.out; then
  echo "FAIL: verify valid_add_with_dead_const_general_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_sub_with_dead_const_swapped_unlowered.l0" >/tmp/l0_ok_sub_with_dead_const_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_sub_with_dead_const_swapped_unlowered.out; then
  echo "FAIL: verify valid_sub_with_dead_const_swapped_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_add_trap.l0" >/tmp/l0_ok_add_trap.out
if ! grep -q '^ok$' /tmp/l0_ok_add_trap.out; then
  echo "FAIL: verify valid_add_trap"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_sub_trap.l0" >/tmp/l0_ok_sub_trap.out
if ! grep -q '^ok$' /tmp/l0_ok_sub_trap.out; then
  echo "FAIL: verify valid_sub_trap"
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
"$BIN" verify "$ROOT/tests/valid_mul_trap.l0" >/tmp/l0_ok_mul_trap.out
if ! grep -q '^ok$' /tmp/l0_ok_mul_trap.out; then
  echo "FAIL: verify valid_mul_trap"
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
"$BIN" verify "$ROOT/tests/valid_icmp_eq_swapped.l0" >/tmp/l0_ok_icmp_eq_swapped.out
if ! grep -q '^ok$' /tmp/l0_ok_icmp_eq_swapped.out; then
  echo "FAIL: verify valid_icmp_eq_swapped"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_icmp_eq_v7.l0" >/tmp/l0_ok_icmp_eq_v7.out
if ! grep -q '^ok$' /tmp/l0_ok_icmp_eq_v7.out; then
  echo "FAIL: verify valid_icmp_eq_v7"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_icmp_eq_argids_v7_v9_lowered.l0" >/tmp/l0_ok_icmp_eq_argids_v7_v9_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_icmp_eq_argids_v7_v9_lowered.out; then
  echo "FAIL: verify valid_icmp_eq_argids_v7_v9_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_icmp_eq_argids_v7_v9_swapped_lowered.l0" >/tmp/l0_ok_icmp_eq_argids_v7_v9_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_icmp_eq_argids_v7_v9_swapped_lowered.out; then
  echo "FAIL: verify valid_icmp_eq_argids_v7_v9_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_icmp_eq_argdef_order_swapped_lowered.l0" >/tmp/l0_ok_icmp_eq_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_icmp_eq_argdef_order_swapped_lowered.out; then
  echo "FAIL: verify valid_icmp_eq_argdef_order_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_icmp_eq_argdef_order_swapped_cmp_swapped_lowered.l0" >/tmp/l0_ok_icmp_eq_argdef_order_swapped_cmp_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_icmp_eq_argdef_order_swapped_cmp_swapped_lowered.out; then
  echo "FAIL: verify valid_icmp_eq_argdef_order_swapped_cmp_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_icmp_eq_with_dead_const_general_lowered.l0" >/tmp/l0_ok_icmp_eq_with_dead_const_general_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_icmp_eq_with_dead_const_general_lowered.out; then
  echo "FAIL: verify valid_icmp_eq_with_dead_const_general_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select.l0" >/tmp/l0_ok_cbr_eq_select.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select.out; then
  echo "FAIL: verify valid_cbr_eq_select"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select_swapped.l0" >/tmp/l0_ok_cbr_eq_select_swapped.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select_swapped.out; then
  echo "FAIL: verify valid_cbr_eq_select_swapped"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select_v7.l0" >/tmp/l0_ok_cbr_eq_select_v7.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select_v7.out; then
  echo "FAIL: verify valid_cbr_eq_select_v7"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select_v7_swapped.l0" >/tmp/l0_ok_cbr_eq_select_v7_swapped.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select_v7_swapped.out; then
  echo "FAIL: verify valid_cbr_eq_select_v7_swapped"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select_mismatch_unlowered.l0" >/tmp/l0_ok_cbr_eq_select_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select_mismatch_unlowered.out; then
  echo "FAIL: verify valid_cbr_eq_select_mismatch_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select_argids_v7_v9_lowered.l0" >/tmp/l0_ok_cbr_eq_select_argids_v7_v9_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select_argids_v7_v9_lowered.out; then
  echo "FAIL: verify valid_cbr_eq_select_argids_v7_v9_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select_argids_v7_v9_swapped_lowered.l0" >/tmp/l0_ok_cbr_eq_select_argids_v7_v9_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select_argids_v7_v9_swapped_lowered.out; then
  echo "FAIL: verify valid_cbr_eq_select_argids_v7_v9_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select_argids_ret_mismatch_unlowered.l0" >/tmp/l0_ok_cbr_eq_select_argids_ret_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select_argids_ret_mismatch_unlowered.out; then
  echo "FAIL: verify valid_cbr_eq_select_argids_ret_mismatch_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select_argdef_order_swapped_lowered.l0" >/tmp/l0_ok_cbr_eq_select_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select_argdef_order_swapped_lowered.out; then
  echo "FAIL: verify valid_cbr_eq_select_argdef_order_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered.l0" >/tmp/l0_ok_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered.out; then
  echo "FAIL: verify valid_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select_argdef_order_swapped_ret_mismatch_unlowered.l0" >/tmp/l0_ok_cbr_eq_select_argdef_order_swapped_ret_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select_argdef_order_swapped_ret_mismatch_unlowered.out; then
  echo "FAIL: verify valid_cbr_eq_select_argdef_order_swapped_ret_mismatch_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select_with_dead_const_general_lowered.l0" >/tmp/l0_ok_cbr_eq_select_with_dead_const_general_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select_with_dead_const_general_lowered.out; then
  echo "FAIL: verify valid_cbr_eq_select_with_dead_const_general_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select_ret_mismatch_with_dead_const_unlowered.l0" >/tmp/l0_ok_cbr_eq_select_ret_mismatch_with_dead_const_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select_ret_mismatch_with_dead_const_unlowered.out; then
  echo "FAIL: verify valid_cbr_eq_select_ret_mismatch_with_dead_const_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_memory_ops.l0" >/tmp/l0_ok_memory_ops.out
if ! grep -q '^ok$' /tmp/l0_ok_memory_ops.out; then
  echo "FAIL: verify valid_memory_ops"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_roundtrip.l0" >/tmp/l0_ok_mem_roundtrip.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_roundtrip.out; then
  echo "FAIL: verify valid_mem_roundtrip"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_roundtrip_v7.l0" >/tmp/l0_ok_mem_roundtrip_v7.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_roundtrip_v7.out; then
  echo "FAIL: verify valid_mem_roundtrip_v7"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_roundtrip_v123.l0" >/tmp/l0_ok_mem_roundtrip_v123.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_roundtrip_v123.out; then
  echo "FAIL: verify valid_mem_roundtrip_v123"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_roundtrip_mismatch_unlowered.l0" >/tmp/l0_ok_mem_roundtrip_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_roundtrip_mismatch_unlowered.out; then
  echo "FAIL: verify valid_mem_roundtrip_mismatch_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_roundtrip_alloca16_lowered.l0" >/tmp/l0_ok_mem_roundtrip_alloca16_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_roundtrip_alloca16_lowered.out; then
  echo "FAIL: verify valid_mem_roundtrip_alloca16_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_roundtrip_alloca0_unlowered.l0" >/tmp/l0_ok_mem_roundtrip_alloca0_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_roundtrip_alloca0_unlowered.out; then
  echo "FAIL: verify valid_mem_roundtrip_alloca0_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_roundtrip_arg_alloca_order_swapped_lowered.l0" >/tmp/l0_ok_mem_roundtrip_arg_alloca_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_roundtrip_arg_alloca_order_swapped_lowered.out; then
  echo "FAIL: verify valid_mem_roundtrip_arg_alloca_order_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_roundtrip_arg_alloca_order_swapped_unlowered.l0" >/tmp/l0_ok_mem_roundtrip_arg_alloca_order_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_roundtrip_arg_alloca_order_swapped_unlowered.out; then
  echo "FAIL: verify valid_mem_roundtrip_arg_alloca_order_swapped_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_gep_roundtrip.l0" >/tmp/l0_ok_mem_gep_roundtrip.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_gep_roundtrip.out; then
  echo "FAIL: verify valid_mem_gep_roundtrip"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_gep_roundtrip_v7.l0" >/tmp/l0_ok_mem_gep_roundtrip_v7.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_gep_roundtrip_v7.out; then
  echo "FAIL: verify valid_mem_gep_roundtrip_v7"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_gep_roundtrip_v123.l0" >/tmp/l0_ok_mem_gep_roundtrip_v123.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_gep_roundtrip_v123.out; then
  echo "FAIL: verify valid_mem_gep_roundtrip_v123"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_gep_roundtrip_mismatch_unlowered.l0" >/tmp/l0_ok_mem_gep_roundtrip_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_gep_roundtrip_mismatch_unlowered.out; then
  echo "FAIL: verify valid_mem_gep_roundtrip_mismatch_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_gep_roundtrip_alloca16_lowered.l0" >/tmp/l0_ok_mem_gep_roundtrip_alloca16_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_gep_roundtrip_alloca16_lowered.out; then
  echo "FAIL: verify valid_mem_gep_roundtrip_alloca16_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_gep_roundtrip_alloca0_unlowered.l0" >/tmp/l0_ok_mem_gep_roundtrip_alloca0_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_gep_roundtrip_alloca0_unlowered.out; then
  echo "FAIL: verify valid_mem_gep_roundtrip_alloca0_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_gep_roundtrip_arg_alloca_order_swapped_lowered.l0" >/tmp/l0_ok_mem_gep_roundtrip_arg_alloca_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_gep_roundtrip_arg_alloca_order_swapped_lowered.out; then
  echo "FAIL: verify valid_mem_gep_roundtrip_arg_alloca_order_swapped_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered.l0" >/tmp/l0_ok_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered.out; then
  echo "FAIL: verify valid_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_malloc.l0" >/tmp/l0_ok_malloc.out
if ! grep -q '^ok$' /tmp/l0_ok_malloc.out; then
  echo "FAIL: verify valid_malloc"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_malloc_v7.l0" >/tmp/l0_ok_malloc_v7.out
if ! grep -q '^ok$' /tmp/l0_ok_malloc_v7.out; then
  echo "FAIL: verify valid_malloc_v7"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_malloc_v123.l0" >/tmp/l0_ok_malloc_v123.out
if ! grep -q '^ok$' /tmp/l0_ok_malloc_v123.out; then
  echo "FAIL: verify valid_malloc_v123"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_malloc_mismatch_unlowered.l0" >/tmp/l0_ok_malloc_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_malloc_mismatch_unlowered.out; then
  echo "FAIL: verify valid_malloc_mismatch_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_free_noop.l0" >/tmp/l0_ok_free_noop.out
if ! grep -q '^ok$' /tmp/l0_ok_free_noop.out; then
  echo "FAIL: verify valid_free_noop"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_free_noop_v7.l0" >/tmp/l0_ok_free_noop_v7.out
if ! grep -q '^ok$' /tmp/l0_ok_free_noop_v7.out; then
  echo "FAIL: verify valid_free_noop_v7"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_free_noop_v123.l0" >/tmp/l0_ok_free_noop_v123.out
if ! grep -q '^ok$' /tmp/l0_ok_free_noop_v123.out; then
  echo "FAIL: verify valid_free_noop_v123"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_free_noop_mismatch_unlowered.l0" >/tmp/l0_ok_free_noop_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_free_noop_mismatch_unlowered.out; then
  echo "FAIL: verify valid_free_noop_mismatch_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_exit.l0" >/tmp/l0_ok_exit.out
if ! grep -q '^ok$' /tmp/l0_ok_exit.out; then
  echo "FAIL: verify valid_exit"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_exit_v7.l0" >/tmp/l0_ok_exit_v7.out
if ! grep -q '^ok$' /tmp/l0_ok_exit_v7.out; then
  echo "FAIL: verify valid_exit_v7"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_exit_v123.l0" >/tmp/l0_ok_exit_v123.out
if ! grep -q '^ok$' /tmp/l0_ok_exit_v123.out; then
  echo "FAIL: verify valid_exit_v123"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_exit_mismatch_unlowered.l0" >/tmp/l0_ok_exit_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_exit_mismatch_unlowered.out; then
  echo "FAIL: verify valid_exit_mismatch_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_write_newline.l0" >/tmp/l0_ok_write_newline.out
if ! grep -q '^ok$' /tmp/l0_ok_write_newline.out; then
  echo "FAIL: verify valid_write_newline"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_write_newline_v7.l0" >/tmp/l0_ok_write_newline_v7.out
if ! grep -q '^ok$' /tmp/l0_ok_write_newline_v7.out; then
  echo "FAIL: verify valid_write_newline_v7"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_write_newline_v123.l0" >/tmp/l0_ok_write_newline_v123.out
if ! grep -q '^ok$' /tmp/l0_ok_write_newline_v123.out; then
  echo "FAIL: verify valid_write_newline_v123"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_write_newline_mismatch_unlowered.l0" >/tmp/l0_ok_write_newline_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_write_newline_mismatch_unlowered.out; then
  echo "FAIL: verify valid_write_newline_mismatch_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_write_newline_alloca16_lowered.l0" >/tmp/l0_ok_write_newline_alloca16_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_write_newline_alloca16_lowered.out; then
  echo "FAIL: verify valid_write_newline_alloca16_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_write_newline_alloca0_unlowered.l0" >/tmp/l0_ok_write_newline_alloca0_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_write_newline_alloca0_unlowered.out; then
  echo "FAIL: verify valid_write_newline_alloca0_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_trace_noop.l0" >/tmp/l0_ok_trace_noop.out
if ! grep -q '^ok$' /tmp/l0_ok_trace_noop.out; then
  echo "FAIL: verify valid_trace_noop"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_trace_noop_v7.l0" >/tmp/l0_ok_trace_noop_v7.out
if ! grep -q '^ok$' /tmp/l0_ok_trace_noop_v7.out; then
  echo "FAIL: verify valid_trace_noop_v7"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_trace_noop_v123.l0" >/tmp/l0_ok_trace_noop_v123.out
if ! grep -q '^ok$' /tmp/l0_ok_trace_noop_v123.out; then
  echo "FAIL: verify valid_trace_noop_v123"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_trace_noop_mismatch_unlowered.l0" >/tmp/l0_ok_trace_noop_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_ok_trace_noop_mismatch_unlowered.out; then
  echo "FAIL: verify valid_trace_noop_mismatch_unlowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_trace_multi.l0" >/tmp/l0_ok_trace_multi.out
if ! grep -q '^ok$' /tmp/l0_ok_trace_multi.out; then
  echo "FAIL: verify valid_trace_multi"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_min.l0" /tmp/l0_test.img >/tmp/l0_build.out
if ! grep -q '^ok$' /tmp/l0_build.out; then
  echo "FAIL: build valid_min"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_min.l0" -o /tmp/l0_test_flag_o.img >/tmp/l0_build_flag_o.out
if ! grep -q '^ok$' /tmp/l0_build_flag_o.out; then
  echo "FAIL: build valid_min with -o"
  exit 1
fi
if [ ! -s /tmp/l0_test_flag_o.img ]; then
  echo "FAIL: build -o output missing"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_min.l0" /tmp/l0_test_schema.img --trace-schema /tmp/l0_trace_schema.bin >/tmp/l0_build_schema.out
if ! grep -q '^ok$' /tmp/l0_build_schema.out; then
  echo "FAIL: build valid_min with --trace-schema"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_min.l0" -o /tmp/l0_test_schema_flag_o.img --trace-schema /tmp/l0_trace_schema_flag_o.bin >/tmp/l0_build_schema_flag_o.out
if ! grep -q '^ok$' /tmp/l0_build_schema_flag_o.out; then
  echo "FAIL: build valid_min with -o --trace-schema"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_min.l0" /tmp/l0_test_debug_map.img --debug-map /tmp/l0_debug_map.bin >/tmp/l0_build_debug_map.out
if ! grep -q '^ok$' /tmp/l0_build_debug_map.out; then
  echo "FAIL: build valid_min with --debug-map"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_min.l0" -o /tmp/l0_test_debug_map_flag_o.img --debug-map /tmp/l0_debug_map_flag_o.bin >/tmp/l0_build_debug_map_flag_o.out
if ! grep -q '^ok$' /tmp/l0_build_debug_map_flag_o.out; then
  echo "FAIL: build valid_min with -o --debug-map"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_min.l0" /tmp/l0_test_both_artifacts.img --trace-schema /tmp/l0_trace_schema_both.bin --debug-map /tmp/l0_debug_map_both.bin >/tmp/l0_build_both_artifacts.out
if ! grep -q '^ok$' /tmp/l0_build_both_artifacts.out; then
  echo "FAIL: build valid_min with --trace-schema --debug-map"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_min.l0" -o /tmp/l0_test_both_artifacts_flag_o.img --debug-map /tmp/l0_debug_map_both_flag_o.bin --trace-schema /tmp/l0_trace_schema_both_flag_o.bin >/tmp/l0_build_both_artifacts_flag_o.out
if ! grep -q '^ok$' /tmp/l0_build_both_artifacts_flag_o.out; then
  echo "FAIL: build valid_min with -o --debug-map --trace-schema"
  exit 1
fi
if "$BIN" build "$ROOT/tests/valid_min.l0" /tmp/l0_test_dup_schema.img --trace-schema /tmp/l0_trace_schema_dup1.bin --trace-schema /tmp/l0_trace_schema_dup2.bin >/tmp/l0_build_dup_schema.out 2>/tmp/l0_build_dup_schema.err; then
  echo "FAIL: build accepted duplicate --trace-schema"
  exit 1
fi
if "$BIN" build "$ROOT/tests/valid_min.l0" -o /tmp/l0_test_dup_map.img --debug-map /tmp/l0_debug_map_dup1.bin --debug-map /tmp/l0_debug_map_dup2.bin >/tmp/l0_build_dup_map.out 2>/tmp/l0_build_dup_map.err; then
  echo "FAIL: build accepted duplicate --debug-map"
  exit 1
fi
if [ "$(wc -c < /tmp/l0_trace_schema.bin)" -ne 32 ]; then
  echo "FAIL: trace schema size"
  exit 1
fi
if [ "$(wc -c < /tmp/l0_trace_schema_flag_o.bin)" -ne 32 ]; then
  echo "FAIL: trace schema size (-o form)"
  exit 1
fi
if [ "$(wc -c < /tmp/l0_debug_map.bin)" -ne 104 ] || [ "$(wc -c < /tmp/l0_debug_map_flag_o.bin)" -ne 104 ]; then
  echo "FAIL: debug map size"
  exit 1
fi
if [ "$(wc -c < /tmp/l0_trace_schema_both.bin)" -ne 32 ] || [ "$(wc -c < /tmp/l0_trace_schema_both_flag_o.bin)" -ne 32 ]; then
  echo "FAIL: trace schema size (both flags)"
  exit 1
fi
if [ "$(wc -c < /tmp/l0_debug_map_both.bin)" -ne 104 ] || [ "$(wc -c < /tmp/l0_debug_map_both_flag_o.bin)" -ne 104 ]; then
  echo "FAIL: debug map size (both flags)"
  exit 1
fi
if [ "$(head -c 4 /tmp/l0_trace_schema.bin)" != "L0TS" ]; then
  echo "FAIL: trace schema magic"
  exit 1
fi
if [ "$(head -c 4 /tmp/l0_debug_map.bin)" != "L0DM" ]; then
  echo "FAIL: debug map magic"
  exit 1
fi
schema_version=$(od -An -t u8 -j 8 -N 8 /tmp/l0_trace_schema.bin | tr -d ' ')
schema_record_size=$(od -An -t u8 -j 16 -N 8 /tmp/l0_trace_schema.bin | tr -d ' ')
schema_field_count=$(od -An -t u8 -j 24 -N 8 /tmp/l0_trace_schema.bin | tr -d ' ')
if [ "$schema_version" != "1" ] || [ "$schema_record_size" != "16" ] || [ "$schema_field_count" != "2" ]; then
  echo "FAIL: trace schema fields"
  exit 1
fi
"$BIN" schemacat /tmp/l0_trace_schema.bin >/tmp/l0_schemacat.out
if [ "$(cat /tmp/l0_schemacat.out)" != $'version 1\nrecord_size 16\nfields 2' ]; then
  echo "FAIL: schemacat decoded output"
  exit 1
fi
cp /tmp/l0_trace_schema.bin /tmp/l0_bad_trace_schema_magic.bin
printf 'BAD!' | dd of=/tmp/l0_bad_trace_schema_magic.bin bs=1 seek=0 conv=notrunc status=none
if "$BIN" schemacat /tmp/l0_bad_trace_schema_magic.bin >/tmp/l0_bad_trace_schema_magic.out 2>/tmp/l0_bad_trace_schema_magic.err; then
  echo "FAIL: schemacat accepted bad schema magic"
  exit 1
fi
cp /tmp/l0_trace_schema.bin /tmp/l0_bad_trace_schema_version.bin
printf '\x00\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_trace_schema_version.bin bs=1 seek=8 conv=notrunc status=none
if "$BIN" schemacat /tmp/l0_bad_trace_schema_version.bin >/tmp/l0_bad_trace_schema_version.out 2>/tmp/l0_bad_trace_schema_version.err; then
  echo "FAIL: schemacat accepted bad schema version"
  exit 1
fi
cp /tmp/l0_trace_schema.bin /tmp/l0_bad_trace_schema_record_size.bin
printf '\x08\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_trace_schema_record_size.bin bs=1 seek=16 conv=notrunc status=none
if "$BIN" schemacat /tmp/l0_bad_trace_schema_record_size.bin >/tmp/l0_bad_trace_schema_record_size.out 2>/tmp/l0_bad_trace_schema_record_size.err; then
  echo "FAIL: schemacat accepted bad schema record_size"
  exit 1
fi
cp /tmp/l0_trace_schema.bin /tmp/l0_bad_trace_schema_fields.bin
printf '\x03\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_trace_schema_fields.bin bs=1 seek=24 conv=notrunc status=none
if "$BIN" schemacat /tmp/l0_bad_trace_schema_fields.bin >/tmp/l0_bad_trace_schema_fields.out 2>/tmp/l0_bad_trace_schema_fields.err; then
  echo "FAIL: schemacat accepted bad schema fields"
  exit 1
fi
cp /tmp/l0_trace_schema.bin /tmp/l0_bad_trace_schema_truncated.bin
truncate -s 31 /tmp/l0_bad_trace_schema_truncated.bin
if "$BIN" schemacat /tmp/l0_bad_trace_schema_truncated.bin >/tmp/l0_bad_trace_schema_truncated.out 2>/tmp/l0_bad_trace_schema_truncated.err; then
  echo "FAIL: schemacat accepted truncated schema payload"
  exit 1
fi
dbg_map_version=$(od -An -t u8 -j 8 -N 8 /tmp/l0_debug_map.bin | tr -d ' ')
dbg_map_inst_count=$(od -An -t u8 -j 16 -N 8 /tmp/l0_debug_map.bin | tr -d ' ')
dbg_map_code_size=$(od -An -t u8 -j 24 -N 8 /tmp/l0_debug_map.bin | tr -d ' ')
dbg_map_inst1_id=$(od -An -t u8 -j 32 -N 8 /tmp/l0_debug_map.bin | tr -d ' ')
dbg_map_inst1_start=$(od -An -t u8 -j 40 -N 8 /tmp/l0_debug_map.bin | tr -d ' ')
dbg_map_inst1_end=$(od -An -t u8 -j 48 -N 8 /tmp/l0_debug_map.bin | tr -d ' ')
dbg_map_inst2_id=$(od -An -t u8 -j 56 -N 8 /tmp/l0_debug_map.bin | tr -d ' ')
dbg_map_inst2_start=$(od -An -t u8 -j 64 -N 8 /tmp/l0_debug_map.bin | tr -d ' ')
dbg_map_inst2_end=$(od -An -t u8 -j 72 -N 8 /tmp/l0_debug_map.bin | tr -d ' ')
dbg_map_inst3_id=$(od -An -t u8 -j 80 -N 8 /tmp/l0_debug_map.bin | tr -d ' ')
dbg_map_inst3_start=$(od -An -t u8 -j 88 -N 8 /tmp/l0_debug_map.bin | tr -d ' ')
dbg_map_inst3_end=$(od -An -t u8 -j 96 -N 8 /tmp/l0_debug_map.bin | tr -d ' ')
if [ "$dbg_map_version" != "2" ] || [ "$dbg_map_inst_count" != "3" ] || [ "$dbg_map_code_size" != "7" ] || [ "$dbg_map_inst1_id" != "1" ] || [ "$dbg_map_inst1_start" != "0" ] || [ "$dbg_map_inst1_end" != "3" ] || [ "$dbg_map_inst2_id" != "2" ] || [ "$dbg_map_inst2_start" != "3" ] || [ "$dbg_map_inst2_end" != "6" ] || [ "$dbg_map_inst3_id" != "3" ] || [ "$dbg_map_inst3_start" != "6" ] || [ "$dbg_map_inst3_end" != "7" ]; then
  echo "FAIL: debug map fields"
  exit 1
fi
"$BIN" mapcat /tmp/l0_debug_map.bin >/tmp/l0_mapcat.out
if [ "$(cat /tmp/l0_mapcat.out)" != $'entries 3\ncode_size 7\ninst_id 1\nstart 0\nend 3\ninst_id 2\nstart 3\nend 6\ninst_id 3\nstart 6\nend 7' ]; then
  echo "FAIL: mapcat decoded output"
  exit 1
fi
cp /tmp/l0_debug_map.bin /tmp/l0_bad_debug_map_version.bin
printf '\x01\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_debug_map_version.bin bs=1 seek=8 conv=notrunc status=none
if "$BIN" mapcat /tmp/l0_bad_debug_map_version.bin >/tmp/l0_bad_debug_map_version.out 2>/tmp/l0_bad_debug_map_version.err; then
  echo "FAIL: mapcat accepted bad map version"
  exit 1
fi
cp /tmp/l0_debug_map.bin /tmp/l0_bad_debug_map_count.bin
printf '\x04\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_debug_map_count.bin bs=1 seek=16 conv=notrunc status=none
if "$BIN" mapcat /tmp/l0_bad_debug_map_count.bin >/tmp/l0_bad_debug_map_count.out 2>/tmp/l0_bad_debug_map_count.err; then
  echo "FAIL: mapcat accepted mismatched debug-map entry count header"
  exit 1
fi
cp /tmp/l0_debug_map.bin /tmp/l0_bad_debug_map_count_65.bin
printf '\x41\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_debug_map_count_65.bin bs=1 seek=16 conv=notrunc status=none
truncate -s $((32 + 65 * 24)) /tmp/l0_bad_debug_map_count_65.bin
if "$BIN" mapcat /tmp/l0_bad_debug_map_count_65.bin >/tmp/l0_bad_debug_map_count_65.out 2>/tmp/l0_bad_debug_map_count_65.err; then
  echo "FAIL: mapcat accepted oversized debug-map entry count header"
  exit 1
fi
cp /tmp/l0_debug_map.bin /tmp/l0_bad_debug_map_range.bin
printf '\xff\xff\xff\xff\xff\xff\xff\xff' | dd of=/tmp/l0_bad_debug_map_range.bin bs=1 seek=40 conv=notrunc status=none
if "$BIN" mapcat /tmp/l0_bad_debug_map_range.bin >/tmp/l0_bad_debug_map_range.out 2>/tmp/l0_bad_debug_map_range.err; then
  echo "FAIL: mapcat accepted out-of-bounds range entry"
  exit 1
fi
cp /tmp/l0_debug_map.bin /tmp/l0_bad_debug_map_overlap.bin
printf '\x01\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_debug_map_overlap.bin bs=1 seek=64 conv=notrunc status=none
if "$BIN" mapcat /tmp/l0_bad_debug_map_overlap.bin >/tmp/l0_bad_debug_map_overlap.out 2>/tmp/l0_bad_debug_map_overlap.err; then
  echo "FAIL: mapcat accepted overlapping map ranges"
  exit 1
fi
cp /tmp/l0_debug_map.bin /tmp/l0_bad_debug_map_inst_order.bin
printf '\x01\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_debug_map_inst_order.bin bs=1 seek=56 conv=notrunc status=none
if "$BIN" mapcat /tmp/l0_bad_debug_map_inst_order.bin >/tmp/l0_bad_debug_map_inst_order.out 2>/tmp/l0_bad_debug_map_inst_order.err; then
  echo "FAIL: mapcat accepted non-increasing inst_id order"
  exit 1
fi
cp /tmp/l0_debug_map.bin /tmp/l0_bad_debug_map_truncated.bin
printf '\x00' >> /tmp/l0_bad_debug_map_truncated.bin
if "$BIN" mapcat /tmp/l0_bad_debug_map_truncated.bin >/tmp/l0_bad_debug_map_truncated.out 2>/tmp/l0_bad_debug_map_truncated.err; then
  echo "FAIL: mapcat accepted misaligned debug-map payload size"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_run_trace_noop.err /tmp/l0_bad_debug_map_version.bin >/tmp/l0_bad_tracejoin.out 2>/tmp/l0_bad_tracejoin.err; then
  echo "FAIL: tracejoin accepted invalid map file"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_run_trace_noop.err /tmp/l0_bad_debug_map_count.bin >/tmp/l0_bad_tracejoin_count.out 2>/tmp/l0_bad_tracejoin_count.err; then
  echo "FAIL: tracejoin accepted mismatched debug-map entry count header"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_run_trace_noop.err /tmp/l0_bad_debug_map_count_65.bin >/tmp/l0_bad_tracejoin_count_65.out 2>/tmp/l0_bad_tracejoin_count_65.err; then
  echo "FAIL: tracejoin accepted oversized debug-map entry count header"
  exit 1
fi
cp /tmp/l0_debug_map.bin /tmp/l0_bad_debug_map_inst_id.bin
printf '\x00\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_debug_map_inst_id.bin bs=1 seek=32 conv=notrunc status=none
if "$BIN" tracejoin /tmp/l0_run_trace_noop.err /tmp/l0_bad_debug_map_inst_id.bin >/tmp/l0_bad_tracejoin_inst_id.out 2>/tmp/l0_bad_tracejoin_inst_id.err; then
  echo "FAIL: tracejoin accepted zero inst_id entry"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_run_trace_noop.err /tmp/l0_bad_debug_map_overlap.bin >/tmp/l0_bad_tracejoin_overlap.out 2>/tmp/l0_bad_tracejoin_overlap.err; then
  echo "FAIL: tracejoin accepted overlapping map ranges"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_run_trace_noop.err /tmp/l0_bad_debug_map_inst_order.bin >/tmp/l0_bad_tracejoin_inst_order.out 2>/tmp/l0_bad_tracejoin_inst_order.err; then
  echo "FAIL: tracejoin accepted non-increasing inst_id order"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_run_trace_noop.err /tmp/l0_bad_debug_map_truncated.bin >/tmp/l0_bad_tracejoin_map_truncated.out 2>/tmp/l0_bad_tracejoin_map_truncated.err; then
  echo "FAIL: tracejoin accepted misaligned debug-map payload size"
  exit 1
fi
cp /tmp/l0_run_trace_noop.err /tmp/l0_bad_trace_unknown_id.err
printf '\x09\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_trace_unknown_id.err bs=1 seek=0 conv=notrunc status=none
if "$BIN" tracejoin /tmp/l0_bad_trace_unknown_id.err /tmp/l0_trace_noop_debug_map.bin >/tmp/l0_bad_trace_unknown_id.out 2>/tmp/l0_bad_trace_unknown_id.errlog; then
  echo "FAIL: tracejoin accepted unknown trace id"
  exit 1
fi
cat /tmp/l0_run_trace_noop.err /tmp/l0_run_trace_noop.err >/tmp/l0_bad_trace_unknown_id_second.err
printf '\x09\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_trace_unknown_id_second.err bs=1 seek=16 conv=notrunc status=none
"$BIN" tracecat /tmp/l0_bad_trace_unknown_id_second.err >/tmp/l0_tracecat_unknown_id_second.out
if [ "$(cat /tmp/l0_tracecat_unknown_id_second.out)" != $'id 1\nval 123\nid 9\nval 123' ]; then
  echo "FAIL: tracecat mixed-record decode output"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_bad_trace_unknown_id_second.err /tmp/l0_trace_noop_debug_map.bin >/tmp/l0_bad_trace_unknown_id_second.out 2>/tmp/l0_bad_trace_unknown_id_second.errlog; then
  echo "FAIL: tracejoin accepted unknown trace id in later record"
  exit 1
fi
cat /tmp/l0_run_trace_noop.err /tmp/l0_run_trace_noop.err /tmp/l0_run_trace_noop.err >/tmp/l0_trace_triple.err
cp /tmp/l0_trace_triple.err /tmp/l0_bad_trace_unknown_id_middle.err
printf '\x09\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_trace_unknown_id_middle.err bs=1 seek=16 conv=notrunc status=none
"$BIN" tracecat /tmp/l0_bad_trace_unknown_id_middle.err >/tmp/l0_tracecat_unknown_id_middle.out
if [ "$(cat /tmp/l0_tracecat_unknown_id_middle.out)" != $'id 1\nval 123\nid 9\nval 123\nid 1\nval 123' ]; then
  echo "FAIL: tracecat triple-record mixed-id decode output"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_bad_trace_unknown_id_middle.err /tmp/l0_trace_noop_debug_map.bin >/tmp/l0_bad_trace_unknown_id_middle.out 2>/tmp/l0_bad_trace_unknown_id_middle.errlog; then
  echo "FAIL: tracejoin accepted unknown trace id in middle record"
  exit 1
fi
cp /tmp/l0_trace_triple.err /tmp/l0_bad_trace_zero_id_third.err
printf '\x00\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_trace_zero_id_third.err bs=1 seek=32 conv=notrunc status=none
"$BIN" tracecat /tmp/l0_bad_trace_zero_id_third.err >/tmp/l0_tracecat_zero_id_third.out
if [ "$(cat /tmp/l0_tracecat_zero_id_third.out)" != $'id 1\nval 123\nid 1\nval 123\nid 0\nval 123' ]; then
  echo "FAIL: tracecat triple-record zero-id decode output"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_bad_trace_zero_id_third.err /tmp/l0_trace_noop_debug_map.bin >/tmp/l0_bad_trace_zero_id_third.out 2>/tmp/l0_bad_trace_zero_id_third.errlog; then
  echo "FAIL: tracejoin accepted zero trace id in later record"
  exit 1
fi
cp /tmp/l0_trace_triple.err /tmp/l0_bad_trace_triple_truncated.err
truncate -s 40 /tmp/l0_bad_trace_triple_truncated.err
if "$BIN" tracecat /tmp/l0_bad_trace_triple_truncated.err >/tmp/l0_bad_trace_triple_truncated.out 2>/tmp/l0_bad_trace_triple_truncated.errlog; then
  echo "FAIL: tracecat accepted truncated multi-record trace payload"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_bad_trace_triple_truncated.err /tmp/l0_trace_noop_debug_map.bin >/tmp/l0_bad_tracejoin_triple_truncated.out 2>/tmp/l0_bad_tracejoin_triple_truncated.errlog; then
  echo "FAIL: tracejoin accepted truncated multi-record trace payload"
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
expected_size=$((80 + in_size + 7 + 64))
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
dbg_kernel_kind=$(od -An -t u8 -j "$((dbg_off + 32))" -N 8 /tmp/l0_test.img | tr -d ' ')
dbg_code_size=$(od -An -t u8 -j "$((dbg_off + 40))" -N 8 /tmp/l0_test.img | tr -d ' ')
dbg_trace_schema_ver=$(od -An -t u8 -j "$((dbg_off + 48))" -N 8 /tmp/l0_test.img | tr -d ' ')
dbg_trace_record_size=$(od -An -t u8 -j "$((dbg_off + 56))" -N 8 /tmp/l0_test.img | tr -d ' ')
if [ "$version" != "1" ] || [ "$hdr_size" != "80" ] || [ "$src_off" != "80" ] || [ "$src_size" != "$in_size" ]; then
  echo "FAIL: build header fields"
  exit 1
fi
if [ "$code_off" != "$((80 + in_size))" ] || [ "$code_size" != "7" ]; then
  echo "FAIL: build code header fields"
  exit 1
fi
if [ "$dbg_off" != "$((80 + in_size + 7))" ] || [ "$dbg_size" != "64" ]; then
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
if [ "$dbg_kernel_kind" != "1" ] || [ "$dbg_code_size" != "7" ]; then
  echo "FAIL: build debug index kernel metadata"
  exit 1
fi
if [ "$dbg_trace_schema_ver" != "1" ] || [ "$dbg_trace_record_size" != "16" ]; then
  echo "FAIL: build debug index trace metadata"
  exit 1
fi
"$BIN" imgcheck /tmp/l0_test.img >/tmp/l0_imgcheck.out
if ! grep -q '^ok$' /tmp/l0_imgcheck.out; then
  echo "FAIL: imgcheck valid image"
  exit 1
fi
"$BIN" imgmeta /tmp/l0_test.img >/tmp/l0_imgmeta.out
if [ "$(cat /tmp/l0_imgmeta.out)" != $'version 1\nsrc_size '"$in_size"$'\ncode_size 7\nfn_count 1\ntype_count 1\nkernel_kind 1\ntrace_schema_ver 1\ntrace_record_size 16' ]; then
  echo "FAIL: imgmeta decoded output"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_imgmeta_kernel_kind.img
printf '\xff\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_imgmeta_kernel_kind.img bs=1 seek="$((dbg_off + 32))" conv=notrunc status=none
if "$BIN" imgmeta /tmp/l0_bad_imgmeta_kernel_kind.img >/tmp/l0_bad_imgmeta_kernel_kind.out 2>/tmp/l0_bad_imgmeta_kernel_kind.err; then
  echo "FAIL: imgmeta accepted out-of-range kernel kind"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_imgmeta_codesz.img
printf '\x08\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_imgmeta_codesz.img bs=1 seek="$((dbg_off + 40))" conv=notrunc status=none
if "$BIN" imgmeta /tmp/l0_bad_imgmeta_codesz.img >/tmp/l0_bad_imgmeta_codesz.out 2>/tmp/l0_bad_imgmeta_codesz.err; then
  echo "FAIL: imgmeta accepted mismatched debug code_size"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_imgmeta_trace_schema_ver.img
printf '\x00\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_imgmeta_trace_schema_ver.img bs=1 seek="$((dbg_off + 48))" conv=notrunc status=none
if "$BIN" imgmeta /tmp/l0_bad_imgmeta_trace_schema_ver.img >/tmp/l0_bad_imgmeta_trace_schema_ver.out 2>/tmp/l0_bad_imgmeta_trace_schema_ver.err; then
  echo "FAIL: imgmeta accepted bad trace schema version"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_imgmeta_trace_record_size.img
printf '\x08\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_imgmeta_trace_record_size.img bs=1 seek="$((dbg_off + 56))" conv=notrunc status=none
if "$BIN" imgmeta /tmp/l0_bad_imgmeta_trace_record_size.img >/tmp/l0_bad_imgmeta_trace_record_size.out 2>/tmp/l0_bad_imgmeta_trace_record_size.err; then
  echo "FAIL: imgmeta accepted bad trace record size"
  exit 1
fi
"$BIN" run /tmp/l0_test.img 7 5 >/tmp/l0_run_add2.out
if [ "$(tr -d '\n' < /tmp/l0_run_add2.out)" != "12" ]; then
  echo "FAIL: run add2 image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_add_lowered.l0" /tmp/l0_test_call_add_lowered.img >/tmp/l0_build_call_add_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_add_lowered.out; then
  echo "FAIL: build valid_call_add_lowered"
  exit 1
fi
call_add_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_add_lowered.img | tr -d ' ')
call_add_kernel_kind=$(od -An -t u8 -j "$((call_add_dbg_off + 32))" -N 8 /tmp/l0_test_call_add_lowered.img | tr -d ' ')
if [ "$call_add_kernel_kind" != "16" ]; then
  echo "FAIL: call->add debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_add_lowered.img 21 21 >/tmp/l0_run_call_add_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_add_lowered.out)" != "42" ]; then
  echo "FAIL: run call->add lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_add_with_dead_const_general_lowered.l0" /tmp/l0_test_call_add_with_dead_const_general_lowered.img >/tmp/l0_build_call_add_with_dead_const_general_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_add_with_dead_const_general_lowered.out; then
  echo "FAIL: build valid_call_add_with_dead_const_general_lowered"
  exit 1
fi
call_add_dead_const_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_add_with_dead_const_general_lowered.img | tr -d ' ')
call_add_dead_const_kernel_kind=$(od -An -t u8 -j "$((call_add_dead_const_dbg_off + 32))" -N 8 /tmp/l0_test_call_add_with_dead_const_general_lowered.img | tr -d ' ')
if [ "$call_add_dead_const_kernel_kind" != "16" ]; then
  echo "FAIL: call->add with dead const debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_add_with_dead_const_general_lowered.img 21 21 >/tmp/l0_run_call_add_with_dead_const_general_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_add_with_dead_const_general_lowered.out)" != "42" ]; then
  echo "FAIL: run call->add with dead const lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_add_swapped_lowered.l0" /tmp/l0_test_call_add_swapped_lowered.img >/tmp/l0_build_call_add_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_add_swapped_lowered.out; then
  echo "FAIL: build valid_call_add_swapped_lowered"
  exit 1
fi
call_add_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_add_swapped_lowered.img | tr -d ' ')
call_add_swapped_kernel_kind=$(od -An -t u8 -j "$((call_add_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_add_swapped_lowered.img | tr -d ' ')
if [ "$call_add_swapped_kernel_kind" != "16" ]; then
  echo "FAIL: call->add swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_add_swapped_lowered.img 21 21 >/tmp/l0_run_call_add_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_add_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run call->add swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_add_v7_lowered.l0" /tmp/l0_test_call_add_v7_lowered.img >/tmp/l0_build_call_add_v7_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_add_v7_lowered.out; then
  echo "FAIL: build valid_call_add_v7_lowered"
  exit 1
fi
call_add_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_add_v7_lowered.img | tr -d ' ')
call_add_v7_kernel_kind=$(od -An -t u8 -j "$((call_add_v7_dbg_off + 32))" -N 8 /tmp/l0_test_call_add_v7_lowered.img | tr -d ' ')
if [ "$call_add_v7_kernel_kind" != "16" ]; then
  echo "FAIL: call->add v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_add_v7_lowered.img 21 21 >/tmp/l0_run_call_add_v7_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_add_v7_lowered.out)" != "42" ]; then
  echo "FAIL: run call->add v7 lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_add_f1v7_lowered.l0" /tmp/l0_test_call_add_f1v7_lowered.img >/tmp/l0_build_call_add_f1v7_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_add_f1v7_lowered.out; then
  echo "FAIL: build valid_call_add_f1v7_lowered"
  exit 1
fi
call_add_f1v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_add_f1v7_lowered.img | tr -d ' ')
call_add_f1v7_kernel_kind=$(od -An -t u8 -j "$((call_add_f1v7_dbg_off + 32))" -N 8 /tmp/l0_test_call_add_f1v7_lowered.img | tr -d ' ')
if [ "$call_add_f1v7_kernel_kind" != "16" ]; then
  echo "FAIL: call->add f1v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_add_f1v7_lowered.img 21 21 >/tmp/l0_run_call_add_f1v7_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_add_f1v7_lowered.out)" != "42" ]; then
  echo "FAIL: run call->add f1v7 lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_add_f1_swapped_lowered.l0" /tmp/l0_test_call_add_f1_swapped_lowered.img >/tmp/l0_build_call_add_f1_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_add_f1_swapped_lowered.out; then
  echo "FAIL: build valid_call_add_f1_swapped_lowered"
  exit 1
fi
call_add_f1_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_add_f1_swapped_lowered.img | tr -d ' ')
call_add_f1_swapped_kernel_kind=$(od -An -t u8 -j "$((call_add_f1_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_add_f1_swapped_lowered.img | tr -d ' ')
if [ "$call_add_f1_swapped_kernel_kind" != "16" ]; then
  echo "FAIL: call->add f1 swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_add_f1_swapped_lowered.img 21 21 >/tmp/l0_run_call_add_f1_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_add_f1_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run call->add f1 swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_sub_lowered.l0" /tmp/l0_test_call_sub_lowered.img >/tmp/l0_build_call_sub_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_sub_lowered.out; then
  echo "FAIL: build valid_call_sub_lowered"
  exit 1
fi
call_sub_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_sub_lowered.img | tr -d ' ')
call_sub_kernel_kind=$(od -An -t u8 -j "$((call_sub_dbg_off + 32))" -N 8 /tmp/l0_test_call_sub_lowered.img | tr -d ' ')
if [ "$call_sub_kernel_kind" != "17" ]; then
  echo "FAIL: call->sub debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_sub_lowered.img 21 9 >/tmp/l0_run_call_sub_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_sub_lowered.out)" != "12" ]; then
  echo "FAIL: run call->sub lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_sub_v7_lowered.l0" /tmp/l0_test_call_sub_v7_lowered.img >/tmp/l0_build_call_sub_v7_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_sub_v7_lowered.out; then
  echo "FAIL: build valid_call_sub_v7_lowered"
  exit 1
fi
call_sub_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_sub_v7_lowered.img | tr -d ' ')
call_sub_v7_kernel_kind=$(od -An -t u8 -j "$((call_sub_v7_dbg_off + 32))" -N 8 /tmp/l0_test_call_sub_v7_lowered.img | tr -d ' ')
if [ "$call_sub_v7_kernel_kind" != "17" ]; then
  echo "FAIL: call->sub v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_sub_v7_lowered.img 21 9 >/tmp/l0_run_call_sub_v7_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_sub_v7_lowered.out)" != "12" ]; then
  echo "FAIL: run call->sub v7 lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_sub_f1v123_lowered.l0" /tmp/l0_test_call_sub_f1v123_lowered.img >/tmp/l0_build_call_sub_f1v123_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_sub_f1v123_lowered.out; then
  echo "FAIL: build valid_call_sub_f1v123_lowered"
  exit 1
fi
call_sub_f1v123_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_sub_f1v123_lowered.img | tr -d ' ')
call_sub_f1v123_kernel_kind=$(od -An -t u8 -j "$((call_sub_f1v123_dbg_off + 32))" -N 8 /tmp/l0_test_call_sub_f1v123_lowered.img | tr -d ' ')
if [ "$call_sub_f1v123_kernel_kind" != "17" ]; then
  echo "FAIL: call->sub f1v123 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_sub_f1v123_lowered.img 21 9 >/tmp/l0_run_call_sub_f1v123_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_sub_f1v123_lowered.out)" != "12" ]; then
  echo "FAIL: run call->sub f1v123 lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_add_f1_argdef_order_swapped_lowered.l0" /tmp/l0_test_call_add_f1_argdef_order_swapped_lowered.img >/tmp/l0_build_call_add_f1_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_add_f1_argdef_order_swapped_lowered.out; then
  echo "FAIL: build valid_call_add_f1_argdef_order_swapped_lowered"
  exit 1
fi
call_add_f1_argdef_order_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_add_f1_argdef_order_swapped_lowered.img | tr -d ' ')
call_add_f1_argdef_order_swapped_kernel_kind=$(od -An -t u8 -j "$((call_add_f1_argdef_order_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_add_f1_argdef_order_swapped_lowered.img | tr -d ' ')
if [ "$call_add_f1_argdef_order_swapped_kernel_kind" != "16" ]; then
  echo "FAIL: call->add f1 argdef-order-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_add_f1_argdef_order_swapped_lowered.img 21 21 >/tmp/l0_run_call_add_f1_argdef_order_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_add_f1_argdef_order_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run call->add f1 argdef-order-swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_mul_f1_argdef_order_swapped_lowered.l0" /tmp/l0_test_call_mul_f1_argdef_order_swapped_lowered.img >/tmp/l0_build_call_mul_f1_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_mul_f1_argdef_order_swapped_lowered.out; then
  echo "FAIL: build valid_call_mul_f1_argdef_order_swapped_lowered"
  exit 1
fi
call_mul_f1_argdef_order_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_mul_f1_argdef_order_swapped_lowered.img | tr -d ' ')
call_mul_f1_argdef_order_swapped_kernel_kind=$(od -An -t u8 -j "$((call_mul_f1_argdef_order_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_mul_f1_argdef_order_swapped_lowered.img | tr -d ' ')
if [ "$call_mul_f1_argdef_order_swapped_kernel_kind" != "18" ]; then
  echo "FAIL: call->mul f1 argdef-order-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_mul_f1_argdef_order_swapped_lowered.img 7 6 >/tmp/l0_run_call_mul_f1_argdef_order_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_mul_f1_argdef_order_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run call->mul f1 argdef-order-swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_sub_f1_argdef_order_swapped_lowered.l0" /tmp/l0_test_call_sub_f1_argdef_order_swapped_lowered.img >/tmp/l0_build_call_sub_f1_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_sub_f1_argdef_order_swapped_lowered.out; then
  echo "FAIL: build valid_call_sub_f1_argdef_order_swapped_lowered"
  exit 1
fi
call_sub_f1_argdef_order_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_sub_f1_argdef_order_swapped_lowered.img | tr -d ' ')
call_sub_f1_argdef_order_swapped_kernel_kind=$(od -An -t u8 -j "$((call_sub_f1_argdef_order_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_sub_f1_argdef_order_swapped_lowered.img | tr -d ' ')
if [ "$call_sub_f1_argdef_order_swapped_kernel_kind" != "17" ]; then
  echo "FAIL: call->sub f1 argdef-order-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_sub_f1_argdef_order_swapped_lowered.img 21 9 >/tmp/l0_run_call_sub_f1_argdef_order_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_sub_f1_argdef_order_swapped_lowered.out)" != "12" ]; then
  echo "FAIL: run call->sub f1 argdef-order-swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_sub_f1_argdef_order_swapped_unlowered.l0" /tmp/l0_test_call_sub_f1_argdef_order_swapped_unlowered.img >/tmp/l0_build_call_sub_f1_argdef_order_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_sub_f1_argdef_order_swapped_unlowered.out; then
  echo "FAIL: build valid_call_sub_f1_argdef_order_swapped_unlowered"
  exit 1
fi
call_sub_f1_argdef_order_swapped_unlowered_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_sub_f1_argdef_order_swapped_unlowered.img | tr -d ' ')
call_sub_f1_argdef_order_swapped_unlowered_kernel_kind=$(od -An -t u8 -j "$((call_sub_f1_argdef_order_swapped_unlowered_dbg_off + 32))" -N 8 /tmp/l0_test_call_sub_f1_argdef_order_swapped_unlowered.img | tr -d ' ')
call_sub_f1_argdef_order_swapped_unlowered_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_call_sub_f1_argdef_order_swapped_unlowered.img | tr -d ' ')
if [ "$call_sub_f1_argdef_order_swapped_unlowered_kernel_kind" != "0" ] || [ "$call_sub_f1_argdef_order_swapped_unlowered_code_size" != "1" ]; then
  echo "FAIL: call->sub f1 argdef-order-swapped unlowered unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_mul_lowered.l0" /tmp/l0_test_call_mul_lowered.img >/tmp/l0_build_call_mul_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_mul_lowered.out; then
  echo "FAIL: build valid_call_mul_lowered"
  exit 1
fi
call_mul_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_mul_lowered.img | tr -d ' ')
call_mul_kernel_kind=$(od -An -t u8 -j "$((call_mul_dbg_off + 32))" -N 8 /tmp/l0_test_call_mul_lowered.img | tr -d ' ')
if [ "$call_mul_kernel_kind" != "18" ]; then
  echo "FAIL: call->mul debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_mul_lowered.img 7 6 >/tmp/l0_run_call_mul_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_mul_lowered.out)" != "42" ]; then
  echo "FAIL: run call->mul lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_mul_swapped_lowered.l0" /tmp/l0_test_call_mul_swapped_lowered.img >/tmp/l0_build_call_mul_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_mul_swapped_lowered.out; then
  echo "FAIL: build valid_call_mul_swapped_lowered"
  exit 1
fi
call_mul_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_mul_swapped_lowered.img | tr -d ' ')
call_mul_swapped_kernel_kind=$(od -An -t u8 -j "$((call_mul_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_mul_swapped_lowered.img | tr -d ' ')
if [ "$call_mul_swapped_kernel_kind" != "18" ]; then
  echo "FAIL: call->mul swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_mul_swapped_lowered.img 7 6 >/tmp/l0_run_call_mul_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_mul_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run call->mul swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_mul_v7_swapped_lowered.l0" /tmp/l0_test_call_mul_v7_swapped_lowered.img >/tmp/l0_build_call_mul_v7_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_mul_v7_swapped_lowered.out; then
  echo "FAIL: build valid_call_mul_v7_swapped_lowered"
  exit 1
fi
call_mul_v7_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_mul_v7_swapped_lowered.img | tr -d ' ')
call_mul_v7_swapped_kernel_kind=$(od -An -t u8 -j "$((call_mul_v7_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_mul_v7_swapped_lowered.img | tr -d ' ')
if [ "$call_mul_v7_swapped_kernel_kind" != "18" ]; then
  echo "FAIL: call->mul v7 swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_mul_v7_swapped_lowered.img 7 6 >/tmp/l0_run_call_mul_v7_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_mul_v7_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run call->mul v7 swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_mul_f1v77_swapped_lowered.l0" /tmp/l0_test_call_mul_f1v77_swapped_lowered.img >/tmp/l0_build_call_mul_f1v77_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_mul_f1v77_swapped_lowered.out; then
  echo "FAIL: build valid_call_mul_f1v77_swapped_lowered"
  exit 1
fi
call_mul_f1v77_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_mul_f1v77_swapped_lowered.img | tr -d ' ')
call_mul_f1v77_swapped_kernel_kind=$(od -An -t u8 -j "$((call_mul_f1v77_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_mul_f1v77_swapped_lowered.img | tr -d ' ')
if [ "$call_mul_f1v77_swapped_kernel_kind" != "18" ]; then
  echo "FAIL: call->mul f1v77 swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_mul_f1v77_swapped_lowered.img 7 6 >/tmp/l0_run_call_mul_f1v77_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_mul_f1v77_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run call->mul f1v77 swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_mul_f1_swapped_lowered.l0" /tmp/l0_test_call_mul_f1_swapped_lowered.img >/tmp/l0_build_call_mul_f1_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_mul_f1_swapped_lowered.out; then
  echo "FAIL: build valid_call_mul_f1_swapped_lowered"
  exit 1
fi
call_mul_f1_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_mul_f1_swapped_lowered.img | tr -d ' ')
call_mul_f1_swapped_kernel_kind=$(od -An -t u8 -j "$((call_mul_f1_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_mul_f1_swapped_lowered.img | tr -d ' ')
if [ "$call_mul_f1_swapped_kernel_kind" != "18" ]; then
  echo "FAIL: call->mul f1 swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_mul_f1_swapped_lowered.img 7 6 >/tmp/l0_run_call_mul_f1_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_mul_f1_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run call->mul f1 swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_add_argdef_order_swapped_lowered.l0" /tmp/l0_test_call_add_argdef_order_swapped_lowered.img >/tmp/l0_build_call_add_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_add_argdef_order_swapped_lowered.out; then
  echo "FAIL: build valid_call_add_argdef_order_swapped_lowered"
  exit 1
fi
call_add_argdef_order_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_add_argdef_order_swapped_lowered.img | tr -d ' ')
call_add_argdef_order_swapped_kernel_kind=$(od -An -t u8 -j "$((call_add_argdef_order_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_add_argdef_order_swapped_lowered.img | tr -d ' ')
if [ "$call_add_argdef_order_swapped_kernel_kind" != "16" ]; then
  echo "FAIL: call->add argdef-order-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_add_argdef_order_swapped_lowered.img 21 21 >/tmp/l0_run_call_add_argdef_order_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_add_argdef_order_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run call->add argdef-order-swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_add_argdef_order_swapped_comm_swapped_lowered.l0" /tmp/l0_test_call_add_argdef_order_swapped_comm_swapped_lowered.img >/tmp/l0_build_call_add_argdef_order_swapped_comm_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_add_argdef_order_swapped_comm_swapped_lowered.out; then
  echo "FAIL: build valid_call_add_argdef_order_swapped_comm_swapped_lowered"
  exit 1
fi
call_add_argdef_order_swapped_comm_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_add_argdef_order_swapped_comm_swapped_lowered.img | tr -d ' ')
call_add_argdef_order_swapped_comm_swapped_kernel_kind=$(od -An -t u8 -j "$((call_add_argdef_order_swapped_comm_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_add_argdef_order_swapped_comm_swapped_lowered.img | tr -d ' ')
if [ "$call_add_argdef_order_swapped_comm_swapped_kernel_kind" != "16" ]; then
  echo "FAIL: call->add argdef-order-swapped comm-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_add_argdef_order_swapped_comm_swapped_lowered.img 21 21 >/tmp/l0_run_call_add_argdef_order_swapped_comm_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_add_argdef_order_swapped_comm_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run call->add argdef-order-swapped comm-swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_mul_argdef_order_swapped_lowered.l0" /tmp/l0_test_call_mul_argdef_order_swapped_lowered.img >/tmp/l0_build_call_mul_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_mul_argdef_order_swapped_lowered.out; then
  echo "FAIL: build valid_call_mul_argdef_order_swapped_lowered"
  exit 1
fi
call_mul_argdef_order_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_mul_argdef_order_swapped_lowered.img | tr -d ' ')
call_mul_argdef_order_swapped_kernel_kind=$(od -An -t u8 -j "$((call_mul_argdef_order_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_mul_argdef_order_swapped_lowered.img | tr -d ' ')
if [ "$call_mul_argdef_order_swapped_kernel_kind" != "18" ]; then
  echo "FAIL: call->mul argdef-order-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_mul_argdef_order_swapped_lowered.img 7 6 >/tmp/l0_run_call_mul_argdef_order_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_mul_argdef_order_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run call->mul argdef-order-swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_sub_argdef_order_swapped_lowered.l0" /tmp/l0_test_call_sub_argdef_order_swapped_lowered.img >/tmp/l0_build_call_sub_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_sub_argdef_order_swapped_lowered.out; then
  echo "FAIL: build valid_call_sub_argdef_order_swapped_lowered"
  exit 1
fi
call_sub_argdef_order_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_sub_argdef_order_swapped_lowered.img | tr -d ' ')
call_sub_argdef_order_swapped_kernel_kind=$(od -An -t u8 -j "$((call_sub_argdef_order_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_sub_argdef_order_swapped_lowered.img | tr -d ' ')
if [ "$call_sub_argdef_order_swapped_kernel_kind" != "17" ]; then
  echo "FAIL: call->sub argdef-order-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_call_sub_argdef_order_swapped_lowered.img 21 9 >/tmp/l0_run_call_sub_argdef_order_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_call_sub_argdef_order_swapped_lowered.out)" != "12" ]; then
  echo "FAIL: run call->sub argdef-order-swapped lowered image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_sub_argdef_order_swapped_unlowered.l0" /tmp/l0_test_call_sub_argdef_order_swapped_unlowered.img >/tmp/l0_build_call_sub_argdef_order_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_sub_argdef_order_swapped_unlowered.out; then
  echo "FAIL: build valid_call_sub_argdef_order_swapped_unlowered"
  exit 1
fi
call_sub_argdef_order_swapped_unlowered_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_sub_argdef_order_swapped_unlowered.img | tr -d ' ')
call_sub_argdef_order_swapped_unlowered_kernel_kind=$(od -An -t u8 -j "$((call_sub_argdef_order_swapped_unlowered_dbg_off + 32))" -N 8 /tmp/l0_test_call_sub_argdef_order_swapped_unlowered.img | tr -d ' ')
call_sub_argdef_order_swapped_unlowered_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_call_sub_argdef_order_swapped_unlowered.img | tr -d ' ')
if [ "$call_sub_argdef_order_swapped_unlowered_kernel_kind" != "0" ] || [ "$call_sub_argdef_order_swapped_unlowered_code_size" != "1" ]; then
  echo "FAIL: call->sub argdef-order-swapped unlowered unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_add_mismatch_unlowered.l0" /tmp/l0_test_call_add_mismatch_unlowered.img >/tmp/l0_build_call_add_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_add_mismatch_unlowered.out; then
  echo "FAIL: build valid_call_add_mismatch_unlowered"
  exit 1
fi
call_add_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_add_mismatch_unlowered.img | tr -d ' ')
call_add_mismatch_kernel_kind=$(od -An -t u8 -j "$((call_add_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_call_add_mismatch_unlowered.img | tr -d ' ')
call_add_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_call_add_mismatch_unlowered.img | tr -d ' ')
if [ "$call_add_mismatch_kernel_kind" != "0" ] || [ "$call_add_mismatch_code_size" != "1" ]; then
  echo "FAIL: call add mismatch unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_sub_f1_swapped_unlowered.l0" /tmp/l0_test_call_sub_f1_swapped_unlowered.img >/tmp/l0_build_call_sub_f1_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_sub_f1_swapped_unlowered.out; then
  echo "FAIL: build valid_call_sub_f1_swapped_unlowered"
  exit 1
fi
call_sub_f1_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_sub_f1_swapped_unlowered.img | tr -d ' ')
call_sub_f1_swapped_kernel_kind=$(od -An -t u8 -j "$((call_sub_f1_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_call_sub_f1_swapped_unlowered.img | tr -d ' ')
call_sub_f1_swapped_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_call_sub_f1_swapped_unlowered.img | tr -d ' ')
if [ "$call_sub_f1_swapped_kernel_kind" != "0" ] || [ "$call_sub_f1_swapped_code_size" != "1" ]; then
  echo "FAIL: call sub f1 swapped unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_sub_f1_swapped_with_dead_const_unlowered.l0" /tmp/l0_test_call_sub_f1_swapped_with_dead_const_unlowered.img >/tmp/l0_build_call_sub_f1_swapped_with_dead_const_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_sub_f1_swapped_with_dead_const_unlowered.out; then
  echo "FAIL: build valid_call_sub_f1_swapped_with_dead_const_unlowered"
  exit 1
fi
call_sub_f1_swapped_dead_const_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_sub_f1_swapped_with_dead_const_unlowered.img | tr -d ' ')
call_sub_f1_swapped_dead_const_kernel_kind=$(od -An -t u8 -j "$((call_sub_f1_swapped_dead_const_dbg_off + 32))" -N 8 /tmp/l0_test_call_sub_f1_swapped_with_dead_const_unlowered.img | tr -d ' ')
call_sub_f1_swapped_dead_const_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_call_sub_f1_swapped_with_dead_const_unlowered.img | tr -d ' ')
if [ "$call_sub_f1_swapped_dead_const_kernel_kind" != "0" ] || [ "$call_sub_f1_swapped_dead_const_code_size" != "1" ]; then
  echo "FAIL: call sub f1 swapped with dead const unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_call_add_f1_ret_mismatch_unlowered.l0" /tmp/l0_test_call_add_f1_ret_mismatch_unlowered.img >/tmp/l0_build_call_add_f1_ret_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_call_add_f1_ret_mismatch_unlowered.out; then
  echo "FAIL: build valid_call_add_f1_ret_mismatch_unlowered"
  exit 1
fi
call_add_f1_ret_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_call_add_f1_ret_mismatch_unlowered.img | tr -d ' ')
call_add_f1_ret_mismatch_kernel_kind=$(od -An -t u8 -j "$((call_add_f1_ret_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_call_add_f1_ret_mismatch_unlowered.img | tr -d ' ')
call_add_f1_ret_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_call_add_f1_ret_mismatch_unlowered.img | tr -d ' ')
if [ "$call_add_f1_ret_mismatch_kernel_kind" != "0" ] || [ "$call_add_f1_ret_mismatch_code_size" != "1" ]; then
  echo "FAIL: call add f1 ret mismatch unexpectedly lowered"
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
"$BIN" build "$ROOT/tests/valid_const_v7.l0" /tmp/l0_test_const_v7.img >/tmp/l0_build_const_v7.out
if ! grep -q '^ok$' /tmp/l0_build_const_v7.out; then
  echo "FAIL: build valid_const_v7"
  exit 1
fi
const_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_const_v7.img | tr -d ' ')
const_v7_kernel_kind=$(od -An -t u8 -j "$((const_v7_dbg_off + 32))" -N 8 /tmp/l0_test_const_v7.img | tr -d ' ')
if [ "$const_v7_kernel_kind" != "13" ]; then
  echo "FAIL: const_v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_const_v7.img >/tmp/l0_run_const_v7.out
if [ "$(tr -d '\n' < /tmp/l0_run_const_v7.out)" != "42" ]; then
  echo "FAIL: run const_v7 image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_const_v123.l0" /tmp/l0_test_const_v123.img >/tmp/l0_build_const_v123.out
if ! grep -q '^ok$' /tmp/l0_build_const_v123.out; then
  echo "FAIL: build valid_const_v123"
  exit 1
fi
const_v123_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_const_v123.img | tr -d ' ')
const_v123_kernel_kind=$(od -An -t u8 -j "$((const_v123_dbg_off + 32))" -N 8 /tmp/l0_test_const_v123.img | tr -d ' ')
if [ "$const_v123_kernel_kind" != "13" ]; then
  echo "FAIL: const_v123 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_const_v123.img >/tmp/l0_run_const_v123.out
if [ "$(tr -d '\n' < /tmp/l0_run_const_v123.out)" != "18446744073709551609" ]; then
  echo "FAIL: run const_v123 image result"
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
"$BIN" build "$ROOT/tests/valid_sub_swapped_unlowered.l0" /tmp/l0_test_sub_swapped_unlowered.img >/tmp/l0_build_sub_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_sub_swapped_unlowered.out; then
  echo "FAIL: build valid_sub_swapped_unlowered"
  exit 1
fi
sub_swapped_unlowered_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_sub_swapped_unlowered.img | tr -d ' ')
sub_swapped_unlowered_kernel_kind=$(od -An -t u8 -j "$((sub_swapped_unlowered_dbg_off + 32))" -N 8 /tmp/l0_test_sub_swapped_unlowered.img | tr -d ' ')
sub_swapped_unlowered_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_sub_swapped_unlowered.img | tr -d ' ')
if [ "$sub_swapped_unlowered_kernel_kind" != "0" ] || [ "$sub_swapped_unlowered_code_size" != "1" ]; then
  echo "FAIL: sub_swapped_unlowered unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_sub_argids_v7_v9_swapped_unlowered.l0" /tmp/l0_test_sub_argids_v7_v9_swapped_unlowered.img >/tmp/l0_build_sub_argids_v7_v9_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_sub_argids_v7_v9_swapped_unlowered.out; then
  echo "FAIL: build valid_sub_argids_v7_v9_swapped_unlowered"
  exit 1
fi
sub_argids_v7_v9_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_sub_argids_v7_v9_swapped_unlowered.img | tr -d ' ')
sub_argids_v7_v9_swapped_kernel_kind=$(od -An -t u8 -j "$((sub_argids_v7_v9_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_sub_argids_v7_v9_swapped_unlowered.img | tr -d ' ')
sub_argids_v7_v9_swapped_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_sub_argids_v7_v9_swapped_unlowered.img | tr -d ' ')
if [ "$sub_argids_v7_v9_swapped_kernel_kind" != "0" ] || [ "$sub_argids_v7_v9_swapped_code_size" != "1" ]; then
  echo "FAIL: sub_argids_v7_v9_swapped unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_add_swapped.l0" /tmp/l0_test_add_swapped.img >/tmp/l0_build_add_swapped.out
if ! grep -q '^ok$' /tmp/l0_build_add_swapped.out; then
  echo "FAIL: build valid_add_swapped"
  exit 1
fi
add_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_add_swapped.img | tr -d ' ')
add_swapped_kernel_kind=$(od -An -t u8 -j "$((add_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_add_swapped.img | tr -d ' ')
if [ "$add_swapped_kernel_kind" != "1" ]; then
  echo "FAIL: add_swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_add_swapped.img 7 5 >/tmp/l0_run_add_swapped.out
if [ "$(tr -d '\n' < /tmp/l0_run_add_swapped.out)" != "12" ]; then
  echo "FAIL: run add_swapped image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_add_v7.l0" /tmp/l0_test_add_v7.img >/tmp/l0_build_add_v7.out
if ! grep -q '^ok$' /tmp/l0_build_add_v7.out; then
  echo "FAIL: build valid_add_v7"
  exit 1
fi
add_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_add_v7.img | tr -d ' ')
add_v7_kernel_kind=$(od -An -t u8 -j "$((add_v7_dbg_off + 32))" -N 8 /tmp/l0_test_add_v7.img | tr -d ' ')
if [ "$add_v7_kernel_kind" != "1" ]; then
  echo "FAIL: add_v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_add_v7.img 7 5 >/tmp/l0_run_add_v7.out
if [ "$(tr -d '\n' < /tmp/l0_run_add_v7.out)" != "12" ]; then
  echo "FAIL: run add_v7 image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_add_argids_v7_v9_lowered.l0" /tmp/l0_test_add_argids_v7_v9_lowered.img >/tmp/l0_build_add_argids_v7_v9_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_add_argids_v7_v9_lowered.out; then
  echo "FAIL: build valid_add_argids_v7_v9_lowered"
  exit 1
fi
add_argids_v7_v9_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_add_argids_v7_v9_lowered.img | tr -d ' ')
add_argids_v7_v9_kernel_kind=$(od -An -t u8 -j "$((add_argids_v7_v9_dbg_off + 32))" -N 8 /tmp/l0_test_add_argids_v7_v9_lowered.img | tr -d ' ')
if [ "$add_argids_v7_v9_kernel_kind" != "1" ]; then
  echo "FAIL: add_argids_v7_v9 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_add_argids_v7_v9_lowered.img 7 5 >/tmp/l0_run_add_argids_v7_v9_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_add_argids_v7_v9_lowered.out)" != "12" ]; then
  echo "FAIL: run add_argids_v7_v9 image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_add_argids_v7_v9_swapped_lowered.l0" /tmp/l0_test_add_argids_v7_v9_swapped_lowered.img >/tmp/l0_build_add_argids_v7_v9_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_add_argids_v7_v9_swapped_lowered.out; then
  echo "FAIL: build valid_add_argids_v7_v9_swapped_lowered"
  exit 1
fi
add_argids_v7_v9_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_add_argids_v7_v9_swapped_lowered.img | tr -d ' ')
add_argids_v7_v9_swapped_kernel_kind=$(od -An -t u8 -j "$((add_argids_v7_v9_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_add_argids_v7_v9_swapped_lowered.img | tr -d ' ')
if [ "$add_argids_v7_v9_swapped_kernel_kind" != "1" ]; then
  echo "FAIL: add_argids_v7_v9_swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_add_argids_v7_v9_swapped_lowered.img 7 5 >/tmp/l0_run_add_argids_v7_v9_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_add_argids_v7_v9_swapped_lowered.out)" != "12" ]; then
  echo "FAIL: run add_argids_v7_v9_swapped image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_add_argids_v77_v123_lowered.l0" /tmp/l0_test_add_argids_v77_v123_lowered.img >/tmp/l0_build_add_argids_v77_v123_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_add_argids_v77_v123_lowered.out; then
  echo "FAIL: build valid_add_argids_v77_v123_lowered"
  exit 1
fi
add_argids_v77_v123_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_add_argids_v77_v123_lowered.img | tr -d ' ')
add_argids_v77_v123_kernel_kind=$(od -An -t u8 -j "$((add_argids_v77_v123_dbg_off + 32))" -N 8 /tmp/l0_test_add_argids_v77_v123_lowered.img | tr -d ' ')
if [ "$add_argids_v77_v123_kernel_kind" != "1" ]; then
  echo "FAIL: add_argids_v77_v123 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_add_argids_v77_v123_lowered.img 7 5 >/tmp/l0_run_add_argids_v77_v123_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_add_argids_v77_v123_lowered.out)" != "12" ]; then
  echo "FAIL: run add_argids_v77_v123 image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_add_argdef_order_swapped_lowered.l0" /tmp/l0_test_add_argdef_order_swapped_lowered.img >/tmp/l0_build_add_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_add_argdef_order_swapped_lowered.out; then
  echo "FAIL: build valid_add_argdef_order_swapped_lowered"
  exit 1
fi
add_argdef_order_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_add_argdef_order_swapped_lowered.img | tr -d ' ')
add_argdef_order_swapped_kernel_kind=$(od -An -t u8 -j "$((add_argdef_order_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_add_argdef_order_swapped_lowered.img | tr -d ' ')
if [ "$add_argdef_order_swapped_kernel_kind" != "1" ]; then
  echo "FAIL: add_argdef_order_swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_add_argdef_order_swapped_lowered.img 7 5 >/tmp/l0_run_add_argdef_order_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_add_argdef_order_swapped_lowered.out)" != "12" ]; then
  echo "FAIL: run add_argdef_order_swapped image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_add_argdef_order_swapped_comm_swapped_lowered.l0" /tmp/l0_test_add_argdef_order_swapped_comm_swapped_lowered.img >/tmp/l0_build_add_argdef_order_swapped_comm_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_add_argdef_order_swapped_comm_swapped_lowered.out; then
  echo "FAIL: build valid_add_argdef_order_swapped_comm_swapped_lowered"
  exit 1
fi
add_argdef_order_swapped_comm_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_add_argdef_order_swapped_comm_swapped_lowered.img | tr -d ' ')
add_argdef_order_swapped_comm_swapped_kernel_kind=$(od -An -t u8 -j "$((add_argdef_order_swapped_comm_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_add_argdef_order_swapped_comm_swapped_lowered.img | tr -d ' ')
if [ "$add_argdef_order_swapped_comm_swapped_kernel_kind" != "1" ]; then
  echo "FAIL: add_argdef_order_swapped_comm_swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_add_argdef_order_swapped_comm_swapped_lowered.img 7 5 >/tmp/l0_run_add_argdef_order_swapped_comm_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_add_argdef_order_swapped_comm_swapped_lowered.out)" != "12" ]; then
  echo "FAIL: run add_argdef_order_swapped_comm_swapped image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_sub_argdef_order_swapped_unlowered.l0" /tmp/l0_test_sub_argdef_order_swapped_unlowered.img >/tmp/l0_build_sub_argdef_order_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_sub_argdef_order_swapped_unlowered.out; then
  echo "FAIL: build valid_sub_argdef_order_swapped_unlowered"
  exit 1
fi
sub_argdef_order_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_sub_argdef_order_swapped_unlowered.img | tr -d ' ')
sub_argdef_order_swapped_kernel_kind=$(od -An -t u8 -j "$((sub_argdef_order_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_sub_argdef_order_swapped_unlowered.img | tr -d ' ')
sub_argdef_order_swapped_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_sub_argdef_order_swapped_unlowered.img | tr -d ' ')
if [ "$sub_argdef_order_swapped_kernel_kind" != "0" ] || [ "$sub_argdef_order_swapped_code_size" != "1" ]; then
  echo "FAIL: sub_argdef_order_swapped unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_add_with_dead_const_general_lowered.l0" /tmp/l0_test_add_with_dead_const_general_lowered.img >/tmp/l0_build_add_with_dead_const_general_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_add_with_dead_const_general_lowered.out; then
  echo "FAIL: build valid_add_with_dead_const_general_lowered"
  exit 1
fi
add_dead_const_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_add_with_dead_const_general_lowered.img | tr -d ' ')
add_dead_const_kernel_kind=$(od -An -t u8 -j "$((add_dead_const_dbg_off + 32))" -N 8 /tmp/l0_test_add_with_dead_const_general_lowered.img | tr -d ' ')
if [ "$add_dead_const_kernel_kind" != "1" ]; then
  echo "FAIL: add_with_dead_const_general debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_add_with_dead_const_general_lowered.img 7 5 >/tmp/l0_run_add_with_dead_const_general_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_add_with_dead_const_general_lowered.out)" != "12" ]; then
  echo "FAIL: run add_with_dead_const_general image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_sub_with_dead_const_swapped_unlowered.l0" /tmp/l0_test_sub_with_dead_const_swapped_unlowered.img >/tmp/l0_build_sub_with_dead_const_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_sub_with_dead_const_swapped_unlowered.out; then
  echo "FAIL: build valid_sub_with_dead_const_swapped_unlowered"
  exit 1
fi
sub_dead_const_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_sub_with_dead_const_swapped_unlowered.img | tr -d ' ')
sub_dead_const_swapped_kernel_kind=$(od -An -t u8 -j "$((sub_dead_const_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_sub_with_dead_const_swapped_unlowered.img | tr -d ' ')
sub_dead_const_swapped_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_sub_with_dead_const_swapped_unlowered.img | tr -d ' ')
if [ "$sub_dead_const_swapped_kernel_kind" != "0" ] || [ "$sub_dead_const_swapped_code_size" != "1" ]; then
  echo "FAIL: sub_with_dead_const_swapped unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_add_trap.l0" /tmp/l0_test_add_trap.img >/tmp/l0_build_add_trap.out
if ! grep -q '^ok$' /tmp/l0_build_add_trap.out; then
  echo "FAIL: build valid_add_trap"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_add_trap.l0" /tmp/l0_test_add_trap_map.img --debug-map /tmp/l0_add_trap_debug_map.bin >/tmp/l0_build_add_trap_map.out
if ! grep -q '^ok$' /tmp/l0_build_add_trap_map.out; then
  echo "FAIL: build valid_add_trap with --debug-map"
  exit 1
fi
"$BIN" mapcat /tmp/l0_add_trap_debug_map.bin >/tmp/l0_add_trap_mapcat.out
if [ "$(cat /tmp/l0_add_trap_mapcat.out)" != $'entries 4\ncode_size 11\ninst_id 1\nstart 0\nend 3\ninst_id 2\nstart 3\nend 6\ninst_id 3\nstart 6\nend 9\ninst_id 4\nstart 9\nend 11' ]; then
  echo "FAIL: add.trap debug-map layout"
  exit 1
fi
add_trap_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_add_trap.img | tr -d ' ')
add_trap_kernel_kind=$(od -An -t u8 -j "$((add_trap_dbg_off + 32))" -N 8 /tmp/l0_test_add_trap.img | tr -d ' ')
if [ "$add_trap_kernel_kind" != "2" ]; then
  echo "FAIL: add.trap debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_add_trap.img 7 5 >/tmp/l0_run_add_trap.out
if [ "$(tr -d '\n' < /tmp/l0_run_add_trap.out)" != "12" ]; then
  echo "FAIL: run add.trap image result"
  exit 1
fi
set +e
"$BIN" run /tmp/l0_test_add_trap.img 9223372036854775807 1 >/tmp/l0_run_add_trap_ovf.out 2>/tmp/l0_run_add_trap_ovf.err
add_trap_ovf_rc=$?
set -e
if [ "$add_trap_ovf_rc" -eq 0 ]; then
  echo "FAIL: run add.trap overflow unexpectedly returned"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_sub_trap.l0" /tmp/l0_test_sub_trap.img >/tmp/l0_build_sub_trap.out
if ! grep -q '^ok$' /tmp/l0_build_sub_trap.out; then
  echo "FAIL: build valid_sub_trap"
  exit 1
fi
"$BIN" run /tmp/l0_test_sub_trap.img 9 2 >/tmp/l0_run_sub_trap.out
if [ "$(tr -d '\n' < /tmp/l0_run_sub_trap.out)" != "7" ]; then
  echo "FAIL: run sub.trap image result"
  exit 1
fi
set +e
"$BIN" run /tmp/l0_test_sub_trap.img 9223372036854775808 1 >/tmp/l0_run_sub_trap_ovf.out 2>/tmp/l0_run_sub_trap_ovf.err
sub_trap_ovf_rc=$?
set -e
if [ "$sub_trap_ovf_rc" -eq 0 ]; then
  echo "FAIL: run sub.trap overflow unexpectedly returned"
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
"$BIN" build "$ROOT/tests/valid_mul_trap.l0" /tmp/l0_test_mul_trap.img >/tmp/l0_build_mul_trap.out
if ! grep -q '^ok$' /tmp/l0_build_mul_trap.out; then
  echo "FAIL: build valid_mul_trap"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mul_trap.l0" /tmp/l0_test_mul_trap_map.img --debug-map /tmp/l0_mul_trap_debug_map.bin >/tmp/l0_build_mul_trap_map.out
if ! grep -q '^ok$' /tmp/l0_build_mul_trap_map.out; then
  echo "FAIL: build valid_mul_trap with --debug-map"
  exit 1
fi
"$BIN" mapcat /tmp/l0_mul_trap_debug_map.bin >/tmp/l0_mul_trap_mapcat.out
if [ "$(cat /tmp/l0_mul_trap_mapcat.out)" != $'entries 4\ncode_size 12\ninst_id 1\nstart 0\nend 3\ninst_id 2\nstart 3\nend 7\ninst_id 3\nstart 7\nend 10\ninst_id 4\nstart 10\nend 12' ]; then
  echo "FAIL: mul.trap debug-map layout"
  exit 1
fi
"$BIN" run /tmp/l0_test_mul_trap.img 7 6 >/tmp/l0_run_mul_trap.out
if [ "$(tr -d '\n' < /tmp/l0_run_mul_trap.out)" != "42" ]; then
  echo "FAIL: run mul.trap image result"
  exit 1
fi
set +e
"$BIN" run /tmp/l0_test_mul_trap.img 9223372036854775807 2 >/tmp/l0_run_mul_trap_ovf.out 2>/tmp/l0_run_mul_trap_ovf.err
mul_trap_ovf_rc=$?
set -e
if [ "$mul_trap_ovf_rc" -eq 0 ]; then
  echo "FAIL: run mul.trap overflow unexpectedly returned"
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
"$BIN" build "$ROOT/tests/valid_icmp_eq_swapped.l0" /tmp/l0_test_icmp_eq_swapped.img >/tmp/l0_build_icmp_eq_swapped.out
if ! grep -q '^ok$' /tmp/l0_build_icmp_eq_swapped.out; then
  echo "FAIL: build valid_icmp_eq_swapped"
  exit 1
fi
icmp_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_icmp_eq_swapped.img | tr -d ' ')
icmp_swapped_kernel_kind=$(od -An -t u8 -j "$((icmp_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_icmp_eq_swapped.img | tr -d ' ')
if [ "$icmp_swapped_kernel_kind" != "11" ]; then
  echo "FAIL: icmp.eq swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_swapped.img 9 9 >/tmp/l0_run_icmp_eq_swapped_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_swapped_t.out)" != "1" ]; then
  echo "FAIL: run icmp.eq swapped true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_swapped.img 9 8 >/tmp/l0_run_icmp_eq_swapped_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_swapped_f.out)" != "0" ]; then
  echo "FAIL: run icmp.eq swapped false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_icmp_eq_v7.l0" /tmp/l0_test_icmp_eq_v7.img >/tmp/l0_build_icmp_eq_v7.out
if ! grep -q '^ok$' /tmp/l0_build_icmp_eq_v7.out; then
  echo "FAIL: build valid_icmp_eq_v7"
  exit 1
fi
icmp_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_icmp_eq_v7.img | tr -d ' ')
icmp_v7_kernel_kind=$(od -An -t u8 -j "$((icmp_v7_dbg_off + 32))" -N 8 /tmp/l0_test_icmp_eq_v7.img | tr -d ' ')
if [ "$icmp_v7_kernel_kind" != "11" ]; then
  echo "FAIL: icmp.eq v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_v7.img 9 9 >/tmp/l0_run_icmp_eq_v7_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_v7_t.out)" != "1" ]; then
  echo "FAIL: run icmp.eq v7 true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_v7.img 9 8 >/tmp/l0_run_icmp_eq_v7_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_v7_f.out)" != "0" ]; then
  echo "FAIL: run icmp.eq v7 false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_icmp_eq_argids_v7_v9_lowered.l0" /tmp/l0_test_icmp_eq_argids_v7_v9_lowered.img >/tmp/l0_build_icmp_eq_argids_v7_v9_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_icmp_eq_argids_v7_v9_lowered.out; then
  echo "FAIL: build valid_icmp_eq_argids_v7_v9_lowered"
  exit 1
fi
icmp_argids_v7_v9_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_icmp_eq_argids_v7_v9_lowered.img | tr -d ' ')
icmp_argids_v7_v9_kernel_kind=$(od -An -t u8 -j "$((icmp_argids_v7_v9_dbg_off + 32))" -N 8 /tmp/l0_test_icmp_eq_argids_v7_v9_lowered.img | tr -d ' ')
if [ "$icmp_argids_v7_v9_kernel_kind" != "11" ]; then
  echo "FAIL: icmp.eq argids v7/v9 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_argids_v7_v9_lowered.img 9 9 >/tmp/l0_run_icmp_eq_argids_v7_v9_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_argids_v7_v9_t.out)" != "1" ]; then
  echo "FAIL: run icmp.eq argids v7/v9 true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_argids_v7_v9_lowered.img 9 8 >/tmp/l0_run_icmp_eq_argids_v7_v9_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_argids_v7_v9_f.out)" != "0" ]; then
  echo "FAIL: run icmp.eq argids v7/v9 false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_icmp_eq_argids_v7_v9_swapped_lowered.l0" /tmp/l0_test_icmp_eq_argids_v7_v9_swapped_lowered.img >/tmp/l0_build_icmp_eq_argids_v7_v9_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_icmp_eq_argids_v7_v9_swapped_lowered.out; then
  echo "FAIL: build valid_icmp_eq_argids_v7_v9_swapped_lowered"
  exit 1
fi
icmp_argids_v7_v9_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_icmp_eq_argids_v7_v9_swapped_lowered.img | tr -d ' ')
icmp_argids_v7_v9_swapped_kernel_kind=$(od -An -t u8 -j "$((icmp_argids_v7_v9_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_icmp_eq_argids_v7_v9_swapped_lowered.img | tr -d ' ')
if [ "$icmp_argids_v7_v9_swapped_kernel_kind" != "11" ]; then
  echo "FAIL: icmp.eq argids v7/v9 swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_argids_v7_v9_swapped_lowered.img 9 9 >/tmp/l0_run_icmp_eq_argids_v7_v9_swapped_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_argids_v7_v9_swapped_t.out)" != "1" ]; then
  echo "FAIL: run icmp.eq argids v7/v9 swapped true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_argids_v7_v9_swapped_lowered.img 9 8 >/tmp/l0_run_icmp_eq_argids_v7_v9_swapped_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_argids_v7_v9_swapped_f.out)" != "0" ]; then
  echo "FAIL: run icmp.eq argids v7/v9 swapped false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_icmp_eq_argdef_order_swapped_lowered.l0" /tmp/l0_test_icmp_eq_argdef_order_swapped_lowered.img >/tmp/l0_build_icmp_eq_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_icmp_eq_argdef_order_swapped_lowered.out; then
  echo "FAIL: build valid_icmp_eq_argdef_order_swapped_lowered"
  exit 1
fi
icmp_argdef_order_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_icmp_eq_argdef_order_swapped_lowered.img | tr -d ' ')
icmp_argdef_order_swapped_kernel_kind=$(od -An -t u8 -j "$((icmp_argdef_order_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_icmp_eq_argdef_order_swapped_lowered.img | tr -d ' ')
if [ "$icmp_argdef_order_swapped_kernel_kind" != "11" ]; then
  echo "FAIL: icmp.eq argdef-order-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_argdef_order_swapped_lowered.img 9 9 >/tmp/l0_run_icmp_eq_argdef_order_swapped_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_argdef_order_swapped_t.out)" != "1" ]; then
  echo "FAIL: run icmp.eq argdef-order-swapped true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_argdef_order_swapped_lowered.img 9 8 >/tmp/l0_run_icmp_eq_argdef_order_swapped_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_argdef_order_swapped_f.out)" != "0" ]; then
  echo "FAIL: run icmp.eq argdef-order-swapped false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_icmp_eq_argdef_order_swapped_cmp_swapped_lowered.l0" /tmp/l0_test_icmp_eq_argdef_order_swapped_cmp_swapped_lowered.img >/tmp/l0_build_icmp_eq_argdef_order_swapped_cmp_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_icmp_eq_argdef_order_swapped_cmp_swapped_lowered.out; then
  echo "FAIL: build valid_icmp_eq_argdef_order_swapped_cmp_swapped_lowered"
  exit 1
fi
icmp_argdef_order_swapped_cmp_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_icmp_eq_argdef_order_swapped_cmp_swapped_lowered.img | tr -d ' ')
icmp_argdef_order_swapped_cmp_swapped_kernel_kind=$(od -An -t u8 -j "$((icmp_argdef_order_swapped_cmp_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_icmp_eq_argdef_order_swapped_cmp_swapped_lowered.img | tr -d ' ')
if [ "$icmp_argdef_order_swapped_cmp_swapped_kernel_kind" != "11" ]; then
  echo "FAIL: icmp.eq argdef-order-swapped cmp-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_argdef_order_swapped_cmp_swapped_lowered.img 9 9 >/tmp/l0_run_icmp_eq_argdef_order_swapped_cmp_swapped_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_argdef_order_swapped_cmp_swapped_t.out)" != "1" ]; then
  echo "FAIL: run icmp.eq argdef-order-swapped cmp-swapped true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_argdef_order_swapped_cmp_swapped_lowered.img 9 8 >/tmp/l0_run_icmp_eq_argdef_order_swapped_cmp_swapped_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_argdef_order_swapped_cmp_swapped_f.out)" != "0" ]; then
  echo "FAIL: run icmp.eq argdef-order-swapped cmp-swapped false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_icmp_eq_with_dead_const_general_lowered.l0" /tmp/l0_test_icmp_eq_with_dead_const_general_lowered.img >/tmp/l0_build_icmp_eq_with_dead_const_general_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_icmp_eq_with_dead_const_general_lowered.out; then
  echo "FAIL: build valid_icmp_eq_with_dead_const_general_lowered"
  exit 1
fi
icmp_dead_const_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_icmp_eq_with_dead_const_general_lowered.img | tr -d ' ')
icmp_dead_const_kernel_kind=$(od -An -t u8 -j "$((icmp_dead_const_dbg_off + 32))" -N 8 /tmp/l0_test_icmp_eq_with_dead_const_general_lowered.img | tr -d ' ')
if [ "$icmp_dead_const_kernel_kind" != "11" ]; then
  echo "FAIL: icmp.eq with dead const debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_with_dead_const_general_lowered.img 9 9 >/tmp/l0_run_icmp_eq_with_dead_const_general_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_with_dead_const_general_t.out)" != "1" ]; then
  echo "FAIL: run icmp.eq with dead const true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_icmp_eq_with_dead_const_general_lowered.img 9 8 >/tmp/l0_run_icmp_eq_with_dead_const_general_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_icmp_eq_with_dead_const_general_f.out)" != "0" ]; then
  echo "FAIL: run icmp.eq with dead const false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select.l0" /tmp/l0_test_cbr_eq_select.img >/tmp/l0_build_cbr_eq_select.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select.out; then
  echo "FAIL: build valid_cbr_eq_select"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select.l0" /tmp/l0_test_cbr_eq_select_map.img --debug-map /tmp/l0_cbr_eq_select_debug_map.bin >/tmp/l0_build_cbr_eq_select_map.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_map.out; then
  echo "FAIL: build valid_cbr_eq_select with --debug-map"
  exit 1
fi
"$BIN" mapcat /tmp/l0_cbr_eq_select_debug_map.bin >/tmp/l0_cbr_eq_select_mapcat.out
if [ "$(cat /tmp/l0_cbr_eq_select_mapcat.out)" != $'entries 4\ncode_size 11\ninst_id 1\nstart 0\nend 3\ninst_id 2\nstart 3\nend 6\ninst_id 3\nstart 6\nend 10\ninst_id 4\nstart 10\nend 11' ]; then
  echo "FAIL: cbr eq-select debug-map layout"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select.img 9 9 >/tmp/l0_run_cbr_eq_select_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_t.out)" != "9" ]; then
  echo "FAIL: run cbr eq-select true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select.img 9 8 >/tmp/l0_run_cbr_eq_select_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_f.out)" != "8" ]; then
  echo "FAIL: run cbr eq-select false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select_swapped.l0" /tmp/l0_test_cbr_eq_select_swapped.img >/tmp/l0_build_cbr_eq_select_swapped.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_swapped.out; then
  echo "FAIL: build valid_cbr_eq_select_swapped"
  exit 1
fi
cbr_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_cbr_eq_select_swapped.img | tr -d ' ')
cbr_swapped_kernel_kind=$(od -An -t u8 -j "$((cbr_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_cbr_eq_select_swapped.img | tr -d ' ')
if [ "$cbr_swapped_kernel_kind" != "12" ]; then
  echo "FAIL: cbr eq-select swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_swapped.img 9 9 >/tmp/l0_run_cbr_eq_select_swapped_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_swapped_t.out)" != "9" ]; then
  echo "FAIL: run cbr eq-select swapped true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_swapped.img 9 8 >/tmp/l0_run_cbr_eq_select_swapped_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_swapped_f.out)" != "8" ]; then
  echo "FAIL: run cbr eq-select swapped false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select_v7.l0" /tmp/l0_test_cbr_eq_select_v7.img >/tmp/l0_build_cbr_eq_select_v7.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_v7.out; then
  echo "FAIL: build valid_cbr_eq_select_v7"
  exit 1
fi
cbr_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_cbr_eq_select_v7.img | tr -d ' ')
cbr_v7_kernel_kind=$(od -An -t u8 -j "$((cbr_v7_dbg_off + 32))" -N 8 /tmp/l0_test_cbr_eq_select_v7.img | tr -d ' ')
if [ "$cbr_v7_kernel_kind" != "12" ]; then
  echo "FAIL: cbr eq-select v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_v7.img 9 9 >/tmp/l0_run_cbr_eq_select_v7_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_v7_t.out)" != "9" ]; then
  echo "FAIL: run cbr eq-select v7 true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_v7.img 9 8 >/tmp/l0_run_cbr_eq_select_v7_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_v7_f.out)" != "8" ]; then
  echo "FAIL: run cbr eq-select v7 false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select_v7_swapped.l0" /tmp/l0_test_cbr_eq_select_v7_swapped.img >/tmp/l0_build_cbr_eq_select_v7_swapped.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_v7_swapped.out; then
  echo "FAIL: build valid_cbr_eq_select_v7_swapped"
  exit 1
fi
cbr_v7_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_cbr_eq_select_v7_swapped.img | tr -d ' ')
cbr_v7_swapped_kernel_kind=$(od -An -t u8 -j "$((cbr_v7_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_cbr_eq_select_v7_swapped.img | tr -d ' ')
if [ "$cbr_v7_swapped_kernel_kind" != "12" ]; then
  echo "FAIL: cbr eq-select v7 swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_v7_swapped.img 9 9 >/tmp/l0_run_cbr_eq_select_v7_swapped_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_v7_swapped_t.out)" != "9" ]; then
  echo "FAIL: run cbr eq-select v7 swapped true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_v7_swapped.img 9 8 >/tmp/l0_run_cbr_eq_select_v7_swapped_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_v7_swapped_f.out)" != "8" ]; then
  echo "FAIL: run cbr eq-select v7 swapped false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select_mismatch_unlowered.l0" /tmp/l0_test_cbr_eq_select_mismatch_unlowered.img >/tmp/l0_build_cbr_eq_select_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_mismatch_unlowered.out; then
  echo "FAIL: build valid_cbr_eq_select_mismatch_unlowered"
  exit 1
fi
cbr_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_cbr_eq_select_mismatch_unlowered.img | tr -d ' ')
cbr_mismatch_kernel_kind=$(od -An -t u8 -j "$((cbr_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_cbr_eq_select_mismatch_unlowered.img | tr -d ' ')
cbr_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_cbr_eq_select_mismatch_unlowered.img | tr -d ' ')
if [ "$cbr_mismatch_kernel_kind" != "0" ] || [ "$cbr_mismatch_code_size" != "1" ]; then
  echo "FAIL: cbr eq-select mismatch unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select_with_dead_const_general_lowered.l0" /tmp/l0_test_cbr_eq_select_with_dead_const_general_lowered.img >/tmp/l0_build_cbr_eq_select_with_dead_const_general_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_with_dead_const_general_lowered.out; then
  echo "FAIL: build valid_cbr_eq_select_with_dead_const_general_lowered"
  exit 1
fi
cbr_dead_const_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_cbr_eq_select_with_dead_const_general_lowered.img | tr -d ' ')
cbr_dead_const_kernel_kind=$(od -An -t u8 -j "$((cbr_dead_const_dbg_off + 32))" -N 8 /tmp/l0_test_cbr_eq_select_with_dead_const_general_lowered.img | tr -d ' ')
if [ "$cbr_dead_const_kernel_kind" != "12" ]; then
  echo "FAIL: cbr eq-select with dead const debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_with_dead_const_general_lowered.img 9 9 >/tmp/l0_run_cbr_eq_select_with_dead_const_general_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_with_dead_const_general_t.out)" != "9" ]; then
  echo "FAIL: run cbr eq-select with dead const true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_with_dead_const_general_lowered.img 9 8 >/tmp/l0_run_cbr_eq_select_with_dead_const_general_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_with_dead_const_general_f.out)" != "8" ]; then
  echo "FAIL: run cbr eq-select with dead const false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select_ret_mismatch_with_dead_const_unlowered.l0" /tmp/l0_test_cbr_eq_select_ret_mismatch_with_dead_const_unlowered.img >/tmp/l0_build_cbr_eq_select_ret_mismatch_with_dead_const_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_ret_mismatch_with_dead_const_unlowered.out; then
  echo "FAIL: build valid_cbr_eq_select_ret_mismatch_with_dead_const_unlowered"
  exit 1
fi
cbr_dead_const_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_cbr_eq_select_ret_mismatch_with_dead_const_unlowered.img | tr -d ' ')
cbr_dead_const_mismatch_kernel_kind=$(od -An -t u8 -j "$((cbr_dead_const_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_cbr_eq_select_ret_mismatch_with_dead_const_unlowered.img | tr -d ' ')
cbr_dead_const_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_cbr_eq_select_ret_mismatch_with_dead_const_unlowered.img | tr -d ' ')
if [ "$cbr_dead_const_mismatch_kernel_kind" != "0" ] || [ "$cbr_dead_const_mismatch_code_size" != "1" ]; then
  echo "FAIL: cbr eq-select dead-const mismatch unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select_argids_v7_v9_lowered.l0" /tmp/l0_test_cbr_eq_select_argids_v7_v9_lowered.img >/tmp/l0_build_cbr_eq_select_argids_v7_v9_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_argids_v7_v9_lowered.out; then
  echo "FAIL: build valid_cbr_eq_select_argids_v7_v9_lowered"
  exit 1
fi
cbr_argids_v7_v9_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_cbr_eq_select_argids_v7_v9_lowered.img | tr -d ' ')
cbr_argids_v7_v9_kernel_kind=$(od -An -t u8 -j "$((cbr_argids_v7_v9_dbg_off + 32))" -N 8 /tmp/l0_test_cbr_eq_select_argids_v7_v9_lowered.img | tr -d ' ')
if [ "$cbr_argids_v7_v9_kernel_kind" != "12" ]; then
  echo "FAIL: cbr eq-select argids v7/v9 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_argids_v7_v9_lowered.img 9 9 >/tmp/l0_run_cbr_eq_select_argids_v7_v9_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_argids_v7_v9_t.out)" != "9" ]; then
  echo "FAIL: run cbr eq-select argids v7/v9 true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_argids_v7_v9_lowered.img 9 8 >/tmp/l0_run_cbr_eq_select_argids_v7_v9_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_argids_v7_v9_f.out)" != "8" ]; then
  echo "FAIL: run cbr eq-select argids v7/v9 false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select_argids_v7_v9_swapped_lowered.l0" /tmp/l0_test_cbr_eq_select_argids_v7_v9_swapped_lowered.img >/tmp/l0_build_cbr_eq_select_argids_v7_v9_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_argids_v7_v9_swapped_lowered.out; then
  echo "FAIL: build valid_cbr_eq_select_argids_v7_v9_swapped_lowered"
  exit 1
fi
cbr_argids_v7_v9_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_cbr_eq_select_argids_v7_v9_swapped_lowered.img | tr -d ' ')
cbr_argids_v7_v9_swapped_kernel_kind=$(od -An -t u8 -j "$((cbr_argids_v7_v9_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_cbr_eq_select_argids_v7_v9_swapped_lowered.img | tr -d ' ')
if [ "$cbr_argids_v7_v9_swapped_kernel_kind" != "12" ]; then
  echo "FAIL: cbr eq-select argids v7/v9 swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_argids_v7_v9_swapped_lowered.img 9 9 >/tmp/l0_run_cbr_eq_select_argids_v7_v9_swapped_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_argids_v7_v9_swapped_t.out)" != "9" ]; then
  echo "FAIL: run cbr eq-select argids v7/v9 swapped true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_argids_v7_v9_swapped_lowered.img 9 8 >/tmp/l0_run_cbr_eq_select_argids_v7_v9_swapped_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_argids_v7_v9_swapped_f.out)" != "8" ]; then
  echo "FAIL: run cbr eq-select argids v7/v9 swapped false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select_argids_ret_mismatch_unlowered.l0" /tmp/l0_test_cbr_eq_select_argids_ret_mismatch_unlowered.img >/tmp/l0_build_cbr_eq_select_argids_ret_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_argids_ret_mismatch_unlowered.out; then
  echo "FAIL: build valid_cbr_eq_select_argids_ret_mismatch_unlowered"
  exit 1
fi
cbr_argids_ret_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_cbr_eq_select_argids_ret_mismatch_unlowered.img | tr -d ' ')
cbr_argids_ret_mismatch_kernel_kind=$(od -An -t u8 -j "$((cbr_argids_ret_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_cbr_eq_select_argids_ret_mismatch_unlowered.img | tr -d ' ')
cbr_argids_ret_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_cbr_eq_select_argids_ret_mismatch_unlowered.img | tr -d ' ')
if [ "$cbr_argids_ret_mismatch_kernel_kind" != "0" ] || [ "$cbr_argids_ret_mismatch_code_size" != "1" ]; then
  echo "FAIL: cbr eq-select argids ret mismatch unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select_argdef_order_swapped_lowered.l0" /tmp/l0_test_cbr_eq_select_argdef_order_swapped_lowered.img >/tmp/l0_build_cbr_eq_select_argdef_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_argdef_order_swapped_lowered.out; then
  echo "FAIL: build valid_cbr_eq_select_argdef_order_swapped_lowered"
  exit 1
fi
cbr_argdef_order_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_cbr_eq_select_argdef_order_swapped_lowered.img | tr -d ' ')
cbr_argdef_order_swapped_kernel_kind=$(od -An -t u8 -j "$((cbr_argdef_order_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_cbr_eq_select_argdef_order_swapped_lowered.img | tr -d ' ')
if [ "$cbr_argdef_order_swapped_kernel_kind" != "12" ]; then
  echo "FAIL: cbr eq-select argdef-order-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_argdef_order_swapped_lowered.img 9 9 >/tmp/l0_run_cbr_eq_select_argdef_order_swapped_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_argdef_order_swapped_t.out)" != "9" ]; then
  echo "FAIL: run cbr eq-select argdef-order-swapped true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_argdef_order_swapped_lowered.img 9 8 >/tmp/l0_run_cbr_eq_select_argdef_order_swapped_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_argdef_order_swapped_f.out)" != "8" ]; then
  echo "FAIL: run cbr eq-select argdef-order-swapped false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered.l0" /tmp/l0_test_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered.img >/tmp/l0_build_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered.out; then
  echo "FAIL: build valid_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered"
  exit 1
fi
cbr_argdef_order_swapped_cmp_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered.img | tr -d ' ')
cbr_argdef_order_swapped_cmp_swapped_kernel_kind=$(od -An -t u8 -j "$((cbr_argdef_order_swapped_cmp_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered.img | tr -d ' ')
if [ "$cbr_argdef_order_swapped_cmp_swapped_kernel_kind" != "12" ]; then
  echo "FAIL: cbr eq-select argdef-order-swapped cmp-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered.img 9 9 >/tmp/l0_run_cbr_eq_select_argdef_order_swapped_cmp_swapped_t.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_argdef_order_swapped_cmp_swapped_t.out)" != "9" ]; then
  echo "FAIL: run cbr eq-select argdef-order-swapped cmp-swapped true result"
  exit 1
fi
"$BIN" run /tmp/l0_test_cbr_eq_select_argdef_order_swapped_cmp_swapped_lowered.img 9 8 >/tmp/l0_run_cbr_eq_select_argdef_order_swapped_cmp_swapped_f.out
if [ "$(tr -d '\n' < /tmp/l0_run_cbr_eq_select_argdef_order_swapped_cmp_swapped_f.out)" != "8" ]; then
  echo "FAIL: run cbr eq-select argdef-order-swapped cmp-swapped false result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_cbr_eq_select_argdef_order_swapped_ret_mismatch_unlowered.l0" /tmp/l0_test_cbr_eq_select_argdef_order_swapped_ret_mismatch_unlowered.img >/tmp/l0_build_cbr_eq_select_argdef_order_swapped_ret_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select_argdef_order_swapped_ret_mismatch_unlowered.out; then
  echo "FAIL: build valid_cbr_eq_select_argdef_order_swapped_ret_mismatch_unlowered"
  exit 1
fi
cbr_argdef_order_swapped_ret_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_cbr_eq_select_argdef_order_swapped_ret_mismatch_unlowered.img | tr -d ' ')
cbr_argdef_order_swapped_ret_mismatch_kernel_kind=$(od -An -t u8 -j "$((cbr_argdef_order_swapped_ret_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_cbr_eq_select_argdef_order_swapped_ret_mismatch_unlowered.img | tr -d ' ')
cbr_argdef_order_swapped_ret_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_cbr_eq_select_argdef_order_swapped_ret_mismatch_unlowered.img | tr -d ' ')
if [ "$cbr_argdef_order_swapped_ret_mismatch_kernel_kind" != "0" ] || [ "$cbr_argdef_order_swapped_ret_mismatch_code_size" != "1" ]; then
  echo "FAIL: cbr eq-select argdef-order-swapped ret mismatch unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_roundtrip.l0" /tmp/l0_test_mem_roundtrip.img >/tmp/l0_build_mem_roundtrip.out
if ! grep -q '^ok$' /tmp/l0_build_mem_roundtrip.out; then
  echo "FAIL: build valid_mem_roundtrip"
  exit 1
fi
mem_roundtrip_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_roundtrip.img | tr -d ' ')
mem_roundtrip_kernel_kind=$(od -An -t u8 -j "$((mem_roundtrip_dbg_off + 32))" -N 8 /tmp/l0_test_mem_roundtrip.img | tr -d ' ')
if [ "$mem_roundtrip_kernel_kind" != "14" ]; then
  echo "FAIL: mem roundtrip debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_mem_roundtrip.img 123 >/tmp/l0_run_mem_roundtrip.out
if [ "$(tr -d '\n' < /tmp/l0_run_mem_roundtrip.out)" != "123" ]; then
  echo "FAIL: run mem roundtrip result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_roundtrip_v7.l0" /tmp/l0_test_mem_roundtrip_v7.img >/tmp/l0_build_mem_roundtrip_v7.out
if ! grep -q '^ok$' /tmp/l0_build_mem_roundtrip_v7.out; then
  echo "FAIL: build valid_mem_roundtrip_v7"
  exit 1
fi
mem_roundtrip_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_roundtrip_v7.img | tr -d ' ')
mem_roundtrip_v7_kernel_kind=$(od -An -t u8 -j "$((mem_roundtrip_v7_dbg_off + 32))" -N 8 /tmp/l0_test_mem_roundtrip_v7.img | tr -d ' ')
if [ "$mem_roundtrip_v7_kernel_kind" != "14" ]; then
  echo "FAIL: mem roundtrip v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_mem_roundtrip_v7.img 123 >/tmp/l0_run_mem_roundtrip_v7.out
if [ "$(tr -d '\n' < /tmp/l0_run_mem_roundtrip_v7.out)" != "123" ]; then
  echo "FAIL: run mem roundtrip v7 result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_roundtrip_v123.l0" /tmp/l0_test_mem_roundtrip_v123.img >/tmp/l0_build_mem_roundtrip_v123.out
if ! grep -q '^ok$' /tmp/l0_build_mem_roundtrip_v123.out; then
  echo "FAIL: build valid_mem_roundtrip_v123"
  exit 1
fi
mem_roundtrip_v123_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_roundtrip_v123.img | tr -d ' ')
mem_roundtrip_v123_kernel_kind=$(od -An -t u8 -j "$((mem_roundtrip_v123_dbg_off + 32))" -N 8 /tmp/l0_test_mem_roundtrip_v123.img | tr -d ' ')
if [ "$mem_roundtrip_v123_kernel_kind" != "14" ]; then
  echo "FAIL: mem roundtrip v123 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_mem_roundtrip_v123.img 123 >/tmp/l0_run_mem_roundtrip_v123.out
if [ "$(tr -d '\n' < /tmp/l0_run_mem_roundtrip_v123.out)" != "123" ]; then
  echo "FAIL: run mem roundtrip v123 result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_roundtrip_mismatch_unlowered.l0" /tmp/l0_test_mem_roundtrip_mismatch_unlowered.img >/tmp/l0_build_mem_roundtrip_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_roundtrip_mismatch_unlowered.out; then
  echo "FAIL: build valid_mem_roundtrip_mismatch_unlowered"
  exit 1
fi
mem_roundtrip_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_roundtrip_mismatch_unlowered.img | tr -d ' ')
mem_roundtrip_mismatch_kernel_kind=$(od -An -t u8 -j "$((mem_roundtrip_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_mem_roundtrip_mismatch_unlowered.img | tr -d ' ')
mem_roundtrip_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_mem_roundtrip_mismatch_unlowered.img | tr -d ' ')
if [ "$mem_roundtrip_mismatch_kernel_kind" != "0" ] || [ "$mem_roundtrip_mismatch_code_size" != "1" ]; then
  echo "FAIL: mem roundtrip mismatch unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_roundtrip_alloca16_lowered.l0" /tmp/l0_test_mem_roundtrip_alloca16_lowered.img >/tmp/l0_build_mem_roundtrip_alloca16_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_roundtrip_alloca16_lowered.out; then
  echo "FAIL: build valid_mem_roundtrip_alloca16_lowered"
  exit 1
fi
mem_roundtrip_alloca16_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_roundtrip_alloca16_lowered.img | tr -d ' ')
mem_roundtrip_alloca16_kernel_kind=$(od -An -t u8 -j "$((mem_roundtrip_alloca16_dbg_off + 32))" -N 8 /tmp/l0_test_mem_roundtrip_alloca16_lowered.img | tr -d ' ')
if [ "$mem_roundtrip_alloca16_kernel_kind" != "14" ]; then
  echo "FAIL: mem roundtrip alloca16 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_mem_roundtrip_alloca16_lowered.img 42 >/tmp/l0_run_mem_roundtrip_alloca16_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_mem_roundtrip_alloca16_lowered.out)" != "42" ]; then
  echo "FAIL: run mem roundtrip alloca16 result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_roundtrip_alloca0_unlowered.l0" /tmp/l0_test_mem_roundtrip_alloca0_unlowered.img >/tmp/l0_build_mem_roundtrip_alloca0_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_roundtrip_alloca0_unlowered.out; then
  echo "FAIL: build valid_mem_roundtrip_alloca0_unlowered"
  exit 1
fi
mem_roundtrip_alloca0_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_roundtrip_alloca0_unlowered.img | tr -d ' ')
mem_roundtrip_alloca0_kernel_kind=$(od -An -t u8 -j "$((mem_roundtrip_alloca0_dbg_off + 32))" -N 8 /tmp/l0_test_mem_roundtrip_alloca0_unlowered.img | tr -d ' ')
mem_roundtrip_alloca0_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_mem_roundtrip_alloca0_unlowered.img | tr -d ' ')
if [ "$mem_roundtrip_alloca0_kernel_kind" != "0" ] || [ "$mem_roundtrip_alloca0_code_size" != "1" ]; then
  echo "FAIL: mem roundtrip alloca0 unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_roundtrip_arg_alloca_order_swapped_lowered.l0" /tmp/l0_test_mem_roundtrip_arg_alloca_order_swapped_lowered.img >/tmp/l0_build_mem_roundtrip_arg_alloca_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_roundtrip_arg_alloca_order_swapped_lowered.out; then
  echo "FAIL: build valid_mem_roundtrip_arg_alloca_order_swapped_lowered"
  exit 1
fi
mem_roundtrip_arg_alloca_order_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_roundtrip_arg_alloca_order_swapped_lowered.img | tr -d ' ')
mem_roundtrip_arg_alloca_order_swapped_kernel_kind=$(od -An -t u8 -j "$((mem_roundtrip_arg_alloca_order_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_mem_roundtrip_arg_alloca_order_swapped_lowered.img | tr -d ' ')
if [ "$mem_roundtrip_arg_alloca_order_swapped_kernel_kind" != "14" ]; then
  echo "FAIL: mem roundtrip arg-alloca-order-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_mem_roundtrip_arg_alloca_order_swapped_lowered.img 42 >/tmp/l0_run_mem_roundtrip_arg_alloca_order_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_mem_roundtrip_arg_alloca_order_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run mem roundtrip arg-alloca-order-swapped result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_roundtrip_arg_alloca_order_swapped_unlowered.l0" /tmp/l0_test_mem_roundtrip_arg_alloca_order_swapped_unlowered.img >/tmp/l0_build_mem_roundtrip_arg_alloca_order_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_roundtrip_arg_alloca_order_swapped_unlowered.out; then
  echo "FAIL: build valid_mem_roundtrip_arg_alloca_order_swapped_unlowered"
  exit 1
fi
mem_roundtrip_arg_alloca_order_swapped_unlowered_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_roundtrip_arg_alloca_order_swapped_unlowered.img | tr -d ' ')
mem_roundtrip_arg_alloca_order_swapped_unlowered_kernel_kind=$(od -An -t u8 -j "$((mem_roundtrip_arg_alloca_order_swapped_unlowered_dbg_off + 32))" -N 8 /tmp/l0_test_mem_roundtrip_arg_alloca_order_swapped_unlowered.img | tr -d ' ')
mem_roundtrip_arg_alloca_order_swapped_unlowered_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_mem_roundtrip_arg_alloca_order_swapped_unlowered.img | tr -d ' ')
if [ "$mem_roundtrip_arg_alloca_order_swapped_unlowered_kernel_kind" != "0" ] || [ "$mem_roundtrip_arg_alloca_order_swapped_unlowered_code_size" != "1" ]; then
  echo "FAIL: mem roundtrip arg-alloca-order-swapped unlowered unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_gep_roundtrip.l0" /tmp/l0_test_mem_gep_roundtrip.img >/tmp/l0_build_mem_gep_roundtrip.out
if ! grep -q '^ok$' /tmp/l0_build_mem_gep_roundtrip.out; then
  echo "FAIL: build valid_mem_gep_roundtrip"
  exit 1
fi
mem_gep_roundtrip_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_gep_roundtrip.img | tr -d ' ')
mem_gep_roundtrip_kernel_kind=$(od -An -t u8 -j "$((mem_gep_roundtrip_dbg_off + 32))" -N 8 /tmp/l0_test_mem_gep_roundtrip.img | tr -d ' ')
if [ "$mem_gep_roundtrip_kernel_kind" != "19" ]; then
  echo "FAIL: mem gep roundtrip debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_mem_gep_roundtrip.img 456 >/tmp/l0_run_mem_gep_roundtrip.out
if [ "$(tr -d '\n' < /tmp/l0_run_mem_gep_roundtrip.out)" != "456" ]; then
  echo "FAIL: run mem gep roundtrip result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_gep_roundtrip_v7.l0" /tmp/l0_test_mem_gep_roundtrip_v7.img >/tmp/l0_build_mem_gep_roundtrip_v7.out
if ! grep -q '^ok$' /tmp/l0_build_mem_gep_roundtrip_v7.out; then
  echo "FAIL: build valid_mem_gep_roundtrip_v7"
  exit 1
fi
mem_gep_roundtrip_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_gep_roundtrip_v7.img | tr -d ' ')
mem_gep_roundtrip_v7_kernel_kind=$(od -An -t u8 -j "$((mem_gep_roundtrip_v7_dbg_off + 32))" -N 8 /tmp/l0_test_mem_gep_roundtrip_v7.img | tr -d ' ')
if [ "$mem_gep_roundtrip_v7_kernel_kind" != "19" ]; then
  echo "FAIL: mem gep roundtrip v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_mem_gep_roundtrip_v7.img 456 >/tmp/l0_run_mem_gep_roundtrip_v7.out
if [ "$(tr -d '\n' < /tmp/l0_run_mem_gep_roundtrip_v7.out)" != "456" ]; then
  echo "FAIL: run mem gep roundtrip v7 result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_gep_roundtrip_v123.l0" /tmp/l0_test_mem_gep_roundtrip_v123.img >/tmp/l0_build_mem_gep_roundtrip_v123.out
if ! grep -q '^ok$' /tmp/l0_build_mem_gep_roundtrip_v123.out; then
  echo "FAIL: build valid_mem_gep_roundtrip_v123"
  exit 1
fi
mem_gep_roundtrip_v123_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_gep_roundtrip_v123.img | tr -d ' ')
mem_gep_roundtrip_v123_kernel_kind=$(od -An -t u8 -j "$((mem_gep_roundtrip_v123_dbg_off + 32))" -N 8 /tmp/l0_test_mem_gep_roundtrip_v123.img | tr -d ' ')
if [ "$mem_gep_roundtrip_v123_kernel_kind" != "19" ]; then
  echo "FAIL: mem gep roundtrip v123 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_mem_gep_roundtrip_v123.img 456 >/tmp/l0_run_mem_gep_roundtrip_v123.out
if [ "$(tr -d '\n' < /tmp/l0_run_mem_gep_roundtrip_v123.out)" != "456" ]; then
  echo "FAIL: run mem gep roundtrip v123 result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_gep_roundtrip_mismatch_unlowered.l0" /tmp/l0_test_mem_gep_roundtrip_mismatch_unlowered.img >/tmp/l0_build_mem_gep_roundtrip_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_gep_roundtrip_mismatch_unlowered.out; then
  echo "FAIL: build valid_mem_gep_roundtrip_mismatch_unlowered"
  exit 1
fi
mem_gep_roundtrip_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_gep_roundtrip_mismatch_unlowered.img | tr -d ' ')
mem_gep_roundtrip_mismatch_kernel_kind=$(od -An -t u8 -j "$((mem_gep_roundtrip_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_mem_gep_roundtrip_mismatch_unlowered.img | tr -d ' ')
mem_gep_roundtrip_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_mem_gep_roundtrip_mismatch_unlowered.img | tr -d ' ')
if [ "$mem_gep_roundtrip_mismatch_kernel_kind" != "0" ] || [ "$mem_gep_roundtrip_mismatch_code_size" != "1" ]; then
  echo "FAIL: mem gep roundtrip mismatch unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_gep_roundtrip_alloca16_lowered.l0" /tmp/l0_test_mem_gep_roundtrip_alloca16_lowered.img >/tmp/l0_build_mem_gep_roundtrip_alloca16_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_gep_roundtrip_alloca16_lowered.out; then
  echo "FAIL: build valid_mem_gep_roundtrip_alloca16_lowered"
  exit 1
fi
mem_gep_roundtrip_alloca16_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_gep_roundtrip_alloca16_lowered.img | tr -d ' ')
mem_gep_roundtrip_alloca16_kernel_kind=$(od -An -t u8 -j "$((mem_gep_roundtrip_alloca16_dbg_off + 32))" -N 8 /tmp/l0_test_mem_gep_roundtrip_alloca16_lowered.img | tr -d ' ')
if [ "$mem_gep_roundtrip_alloca16_kernel_kind" != "19" ]; then
  echo "FAIL: mem gep roundtrip alloca16 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_mem_gep_roundtrip_alloca16_lowered.img 42 >/tmp/l0_run_mem_gep_roundtrip_alloca16_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_mem_gep_roundtrip_alloca16_lowered.out)" != "42" ]; then
  echo "FAIL: run mem gep roundtrip alloca16 result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_gep_roundtrip_alloca0_unlowered.l0" /tmp/l0_test_mem_gep_roundtrip_alloca0_unlowered.img >/tmp/l0_build_mem_gep_roundtrip_alloca0_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_gep_roundtrip_alloca0_unlowered.out; then
  echo "FAIL: build valid_mem_gep_roundtrip_alloca0_unlowered"
  exit 1
fi
mem_gep_roundtrip_alloca0_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_gep_roundtrip_alloca0_unlowered.img | tr -d ' ')
mem_gep_roundtrip_alloca0_kernel_kind=$(od -An -t u8 -j "$((mem_gep_roundtrip_alloca0_dbg_off + 32))" -N 8 /tmp/l0_test_mem_gep_roundtrip_alloca0_unlowered.img | tr -d ' ')
mem_gep_roundtrip_alloca0_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_mem_gep_roundtrip_alloca0_unlowered.img | tr -d ' ')
if [ "$mem_gep_roundtrip_alloca0_kernel_kind" != "0" ] || [ "$mem_gep_roundtrip_alloca0_code_size" != "1" ]; then
  echo "FAIL: mem gep roundtrip alloca0 unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_gep_roundtrip_arg_alloca_order_swapped_lowered.l0" /tmp/l0_test_mem_gep_roundtrip_arg_alloca_order_swapped_lowered.img >/tmp/l0_build_mem_gep_roundtrip_arg_alloca_order_swapped_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_gep_roundtrip_arg_alloca_order_swapped_lowered.out; then
  echo "FAIL: build valid_mem_gep_roundtrip_arg_alloca_order_swapped_lowered"
  exit 1
fi
mem_gep_roundtrip_arg_alloca_order_swapped_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_gep_roundtrip_arg_alloca_order_swapped_lowered.img | tr -d ' ')
mem_gep_roundtrip_arg_alloca_order_swapped_kernel_kind=$(od -An -t u8 -j "$((mem_gep_roundtrip_arg_alloca_order_swapped_dbg_off + 32))" -N 8 /tmp/l0_test_mem_gep_roundtrip_arg_alloca_order_swapped_lowered.img | tr -d ' ')
if [ "$mem_gep_roundtrip_arg_alloca_order_swapped_kernel_kind" != "19" ]; then
  echo "FAIL: mem gep roundtrip arg-alloca-order-swapped debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_mem_gep_roundtrip_arg_alloca_order_swapped_lowered.img 42 >/tmp/l0_run_mem_gep_roundtrip_arg_alloca_order_swapped_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_mem_gep_roundtrip_arg_alloca_order_swapped_lowered.out)" != "42" ]; then
  echo "FAIL: run mem gep roundtrip arg-alloca-order-swapped result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered.l0" /tmp/l0_test_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered.img >/tmp/l0_build_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered.out; then
  echo "FAIL: build valid_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered"
  exit 1
fi
mem_gep_roundtrip_arg_alloca_order_swapped_unlowered_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered.img | tr -d ' ')
mem_gep_roundtrip_arg_alloca_order_swapped_unlowered_kernel_kind=$(od -An -t u8 -j "$((mem_gep_roundtrip_arg_alloca_order_swapped_unlowered_dbg_off + 32))" -N 8 /tmp/l0_test_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered.img | tr -d ' ')
mem_gep_roundtrip_arg_alloca_order_swapped_unlowered_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered.img | tr -d ' ')
if [ "$mem_gep_roundtrip_arg_alloca_order_swapped_unlowered_kernel_kind" != "0" ] || [ "$mem_gep_roundtrip_arg_alloca_order_swapped_unlowered_code_size" != "1" ]; then
  echo "FAIL: mem gep roundtrip arg-alloca-order-swapped unlowered unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_malloc.l0" /tmp/l0_test_malloc.img >/tmp/l0_build_malloc.out
if ! grep -q '^ok$' /tmp/l0_build_malloc.out; then
  echo "FAIL: build valid_malloc"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_malloc.l0" /tmp/l0_test_malloc_map.img --debug-map /tmp/l0_malloc_debug_map.bin >/tmp/l0_build_malloc_map.out
if ! grep -q '^ok$' /tmp/l0_build_malloc_map.out; then
  echo "FAIL: build valid_malloc with --debug-map"
  exit 1
fi
"$BIN" mapcat /tmp/l0_malloc_debug_map.bin >/tmp/l0_malloc_mapcat.out
if [ "$(cat /tmp/l0_malloc_mapcat.out)" != $'entries 4\ncode_size 40\ninst_id 1\nstart 0\nend 6\ninst_id 2\nstart 6\nend 20\ninst_id 3\nstart 20\nend 34\ninst_id 4\nstart 34\nend 40' ]; then
  echo "FAIL: malloc debug-map layout"
  exit 1
fi
malloc_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_malloc.img | tr -d ' ')
malloc_kernel_kind=$(od -An -t u8 -j "$((malloc_dbg_off + 32))" -N 8 /tmp/l0_test_malloc.img | tr -d ' ')
if [ "$malloc_kernel_kind" != "20" ]; then
  echo "FAIL: malloc debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_malloc.img 4096 >/tmp/l0_run_malloc.out
malloc_out="$(tr -d '\n' < /tmp/l0_run_malloc.out)"
if [ "$malloc_out" = "0" ]; then
  echo "FAIL: run malloc returned null"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_malloc_v7.l0" /tmp/l0_test_malloc_v7.img >/tmp/l0_build_malloc_v7.out
if ! grep -q '^ok$' /tmp/l0_build_malloc_v7.out; then
  echo "FAIL: build valid_malloc_v7"
  exit 1
fi
malloc_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_malloc_v7.img | tr -d ' ')
malloc_v7_kernel_kind=$(od -An -t u8 -j "$((malloc_v7_dbg_off + 32))" -N 8 /tmp/l0_test_malloc_v7.img | tr -d ' ')
if [ "$malloc_v7_kernel_kind" != "20" ]; then
  echo "FAIL: malloc v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_malloc_v7.img 4096 >/tmp/l0_run_malloc_v7.out
malloc_v7_out="$(tr -d '\n' < /tmp/l0_run_malloc_v7.out)"
if [ "$malloc_v7_out" = "0" ]; then
  echo "FAIL: run malloc_v7 returned null"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_malloc_v123.l0" /tmp/l0_test_malloc_v123.img >/tmp/l0_build_malloc_v123.out
if ! grep -q '^ok$' /tmp/l0_build_malloc_v123.out; then
  echo "FAIL: build valid_malloc_v123"
  exit 1
fi
malloc_v123_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_malloc_v123.img | tr -d ' ')
malloc_v123_kernel_kind=$(od -An -t u8 -j "$((malloc_v123_dbg_off + 32))" -N 8 /tmp/l0_test_malloc_v123.img | tr -d ' ')
if [ "$malloc_v123_kernel_kind" != "20" ]; then
  echo "FAIL: malloc v123 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_malloc_v123.img 4096 >/tmp/l0_run_malloc_v123.out
malloc_v123_out="$(tr -d '\n' < /tmp/l0_run_malloc_v123.out)"
if [ "$malloc_v123_out" = "0" ]; then
  echo "FAIL: run malloc_v123 returned null"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_malloc_mismatch_unlowered.l0" /tmp/l0_test_malloc_mismatch_unlowered.img >/tmp/l0_build_malloc_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_malloc_mismatch_unlowered.out; then
  echo "FAIL: build valid_malloc_mismatch_unlowered"
  exit 1
fi
malloc_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_malloc_mismatch_unlowered.img | tr -d ' ')
malloc_mismatch_kernel_kind=$(od -An -t u8 -j "$((malloc_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_malloc_mismatch_unlowered.img | tr -d ' ')
malloc_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_malloc_mismatch_unlowered.img | tr -d ' ')
if [ "$malloc_mismatch_kernel_kind" != "0" ] || [ "$malloc_mismatch_code_size" != "1" ]; then
  echo "FAIL: malloc mismatch unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_free_noop.l0" /tmp/l0_test_free_noop.img >/tmp/l0_build_free_noop.out
if ! grep -q '^ok$' /tmp/l0_build_free_noop.out; then
  echo "FAIL: build valid_free_noop"
  exit 1
fi
free_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_free_noop.img | tr -d ' ')
free_kernel_kind=$(od -An -t u8 -j "$((free_dbg_off + 32))" -N 8 /tmp/l0_test_free_noop.img | tr -d ' ')
if [ "$free_kernel_kind" != "21" ]; then
  echo "FAIL: free noop debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_free_noop.img 123 >/tmp/l0_run_free_noop.out
if [ "$(tr -d '\n' < /tmp/l0_run_free_noop.out)" != "0" ]; then
  echo "FAIL: run free noop image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_free_noop_v7.l0" /tmp/l0_test_free_noop_v7.img >/tmp/l0_build_free_noop_v7.out
if ! grep -q '^ok$' /tmp/l0_build_free_noop_v7.out; then
  echo "FAIL: build valid_free_noop_v7"
  exit 1
fi
free_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_free_noop_v7.img | tr -d ' ')
free_v7_kernel_kind=$(od -An -t u8 -j "$((free_v7_dbg_off + 32))" -N 8 /tmp/l0_test_free_noop_v7.img | tr -d ' ')
if [ "$free_v7_kernel_kind" != "21" ]; then
  echo "FAIL: free noop v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_free_noop_v7.img 123 >/tmp/l0_run_free_noop_v7.out
if [ "$(tr -d '\n' < /tmp/l0_run_free_noop_v7.out)" != "0" ]; then
  echo "FAIL: run free noop v7 image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_free_noop_v123.l0" /tmp/l0_test_free_noop_v123.img >/tmp/l0_build_free_noop_v123.out
if ! grep -q '^ok$' /tmp/l0_build_free_noop_v123.out; then
  echo "FAIL: build valid_free_noop_v123"
  exit 1
fi
free_v123_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_free_noop_v123.img | tr -d ' ')
free_v123_kernel_kind=$(od -An -t u8 -j "$((free_v123_dbg_off + 32))" -N 8 /tmp/l0_test_free_noop_v123.img | tr -d ' ')
if [ "$free_v123_kernel_kind" != "21" ]; then
  echo "FAIL: free noop v123 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_free_noop_v123.img 123 >/tmp/l0_run_free_noop_v123.out
if [ "$(tr -d '\n' < /tmp/l0_run_free_noop_v123.out)" != "0" ]; then
  echo "FAIL: run free noop v123 image result"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_free_noop_mismatch_unlowered.l0" /tmp/l0_test_free_noop_mismatch_unlowered.img >/tmp/l0_build_free_noop_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_free_noop_mismatch_unlowered.out; then
  echo "FAIL: build valid_free_noop_mismatch_unlowered"
  exit 1
fi
free_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_free_noop_mismatch_unlowered.img | tr -d ' ')
free_mismatch_kernel_kind=$(od -An -t u8 -j "$((free_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_free_noop_mismatch_unlowered.img | tr -d ' ')
free_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_free_noop_mismatch_unlowered.img | tr -d ' ')
if [ "$free_mismatch_kernel_kind" != "0" ] || [ "$free_mismatch_code_size" != "1" ]; then
  echo "FAIL: free noop mismatch unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_exit.l0" /tmp/l0_test_exit.img >/tmp/l0_build_exit.out
if ! grep -q '^ok$' /tmp/l0_build_exit.out; then
  echo "FAIL: build valid_exit"
  exit 1
fi
exit_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_exit.img | tr -d ' ')
exit_kernel_kind=$(od -An -t u8 -j "$((exit_dbg_off + 32))" -N 8 /tmp/l0_test_exit.img | tr -d ' ')
if [ "$exit_kernel_kind" != "23" ]; then
  echo "FAIL: exit debug kernel kind id"
  exit 1
fi
set +e
"$BIN" run /tmp/l0_test_exit.img 7 >/tmp/l0_run_exit.out 2>/tmp/l0_run_exit.err
exit_rc=$?
set -e
if [ "$exit_rc" -ne 7 ]; then
  echo "FAIL: run exit image status"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_exit_v7.l0" /tmp/l0_test_exit_v7.img >/tmp/l0_build_exit_v7.out
if ! grep -q '^ok$' /tmp/l0_build_exit_v7.out; then
  echo "FAIL: build valid_exit_v7"
  exit 1
fi
exit_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_exit_v7.img | tr -d ' ')
exit_v7_kernel_kind=$(od -An -t u8 -j "$((exit_v7_dbg_off + 32))" -N 8 /tmp/l0_test_exit_v7.img | tr -d ' ')
if [ "$exit_v7_kernel_kind" != "23" ]; then
  echo "FAIL: exit v7 debug kernel kind id"
  exit 1
fi
set +e
"$BIN" run /tmp/l0_test_exit_v7.img 9 >/tmp/l0_run_exit_v7.out 2>/tmp/l0_run_exit_v7.err
exit_v7_rc=$?
set -e
if [ "$exit_v7_rc" -ne 9 ]; then
  echo "FAIL: run exit v7 image status"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_exit_v123.l0" /tmp/l0_test_exit_v123.img >/tmp/l0_build_exit_v123.out
if ! grep -q '^ok$' /tmp/l0_build_exit_v123.out; then
  echo "FAIL: build valid_exit_v123"
  exit 1
fi
exit_v123_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_exit_v123.img | tr -d ' ')
exit_v123_kernel_kind=$(od -An -t u8 -j "$((exit_v123_dbg_off + 32))" -N 8 /tmp/l0_test_exit_v123.img | tr -d ' ')
if [ "$exit_v123_kernel_kind" != "23" ]; then
  echo "FAIL: exit v123 debug kernel kind id"
  exit 1
fi
set +e
"$BIN" run /tmp/l0_test_exit_v123.img 11 >/tmp/l0_run_exit_v123.out 2>/tmp/l0_run_exit_v123.err
exit_v123_rc=$?
set -e
if [ "$exit_v123_rc" -ne 11 ]; then
  echo "FAIL: run exit v123 image status"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_exit_mismatch_unlowered.l0" /tmp/l0_test_exit_mismatch_unlowered.img >/tmp/l0_build_exit_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_exit_mismatch_unlowered.out; then
  echo "FAIL: build valid_exit_mismatch_unlowered"
  exit 1
fi
exit_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_exit_mismatch_unlowered.img | tr -d ' ')
exit_mismatch_kernel_kind=$(od -An -t u8 -j "$((exit_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_exit_mismatch_unlowered.img | tr -d ' ')
exit_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_exit_mismatch_unlowered.img | tr -d ' ')
if [ "$exit_mismatch_kernel_kind" != "0" ] || [ "$exit_mismatch_code_size" != "1" ]; then
  echo "FAIL: exit mismatch unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_write_newline.l0" /tmp/l0_test_write_newline.img >/tmp/l0_build_write_newline.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline.out; then
  echo "FAIL: build valid_write_newline"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_write_newline.l0" /tmp/l0_test_write_newline_map.img --debug-map /tmp/l0_write_newline_debug_map.bin >/tmp/l0_build_write_newline_map.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_map.out; then
  echo "FAIL: build valid_write_newline with --debug-map"
  exit 1
fi
"$BIN" mapcat /tmp/l0_write_newline_debug_map.bin >/tmp/l0_write_newline_mapcat.out
if [ "$(cat /tmp/l0_write_newline_mapcat.out)" != $'entries 4\ncode_size 46\ninst_id 1\nstart 0\nend 12\ninst_id 2\nstart 12\nend 38\ninst_id 3\nstart 38\nend 45\ninst_id 4\nstart 45\nend 46' ]; then
  echo "FAIL: write newline debug-map layout"
  exit 1
fi
write_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_write_newline.img | tr -d ' ')
write_kernel_kind=$(od -An -t u8 -j "$((write_dbg_off + 32))" -N 8 /tmp/l0_test_write_newline.img | tr -d ' ')
if [ "$write_kernel_kind" != "22" ]; then
  echo "FAIL: write debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_write_newline.img >/tmp/l0_run_write_newline.out
if [ "$(tr -d '\n' < /tmp/l0_run_write_newline.out)" != "0" ]; then
  echo "FAIL: run write newline image result"
  exit 1
fi
if [ "$(od -An -t x1 /tmp/l0_run_write_newline.out | tr -d ' \n')" != "0a300a" ]; then
  echo "FAIL: run write newline output bytes"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_write_newline_v7.l0" /tmp/l0_test_write_newline_v7.img >/tmp/l0_build_write_newline_v7.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_v7.out; then
  echo "FAIL: build valid_write_newline_v7"
  exit 1
fi
write_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_write_newline_v7.img | tr -d ' ')
write_v7_kernel_kind=$(od -An -t u8 -j "$((write_v7_dbg_off + 32))" -N 8 /tmp/l0_test_write_newline_v7.img | tr -d ' ')
if [ "$write_v7_kernel_kind" != "22" ]; then
  echo "FAIL: write newline v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_write_newline_v7.img >/tmp/l0_run_write_newline_v7.out
if [ "$(tr -d '\n' < /tmp/l0_run_write_newline_v7.out)" != "0" ]; then
  echo "FAIL: run write newline v7 image result"
  exit 1
fi
if [ "$(od -An -t x1 /tmp/l0_run_write_newline_v7.out | tr -d ' \n')" != "0a300a" ]; then
  echo "FAIL: run write newline v7 output bytes"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_write_newline_v123.l0" /tmp/l0_test_write_newline_v123.img >/tmp/l0_build_write_newline_v123.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_v123.out; then
  echo "FAIL: build valid_write_newline_v123"
  exit 1
fi
write_v123_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_write_newline_v123.img | tr -d ' ')
write_v123_kernel_kind=$(od -An -t u8 -j "$((write_v123_dbg_off + 32))" -N 8 /tmp/l0_test_write_newline_v123.img | tr -d ' ')
if [ "$write_v123_kernel_kind" != "22" ]; then
  echo "FAIL: write newline v123 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_write_newline_v123.img >/tmp/l0_run_write_newline_v123.out
if [ "$(tr -d '\n' < /tmp/l0_run_write_newline_v123.out)" != "0" ]; then
  echo "FAIL: run write newline v123 image result"
  exit 1
fi
if [ "$(od -An -t x1 /tmp/l0_run_write_newline_v123.out | tr -d ' \n')" != "0a300a" ]; then
  echo "FAIL: run write newline v123 output bytes"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_write_newline_mismatch_unlowered.l0" /tmp/l0_test_write_newline_mismatch_unlowered.img >/tmp/l0_build_write_newline_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_mismatch_unlowered.out; then
  echo "FAIL: build valid_write_newline_mismatch_unlowered"
  exit 1
fi
write_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_write_newline_mismatch_unlowered.img | tr -d ' ')
write_mismatch_kernel_kind=$(od -An -t u8 -j "$((write_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_write_newline_mismatch_unlowered.img | tr -d ' ')
write_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_write_newline_mismatch_unlowered.img | tr -d ' ')
if [ "$write_mismatch_kernel_kind" != "0" ] || [ "$write_mismatch_code_size" != "1" ]; then
  echo "FAIL: write newline mismatch unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_write_newline_alloca16_lowered.l0" /tmp/l0_test_write_newline_alloca16_lowered.img >/tmp/l0_build_write_newline_alloca16_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_alloca16_lowered.out; then
  echo "FAIL: build valid_write_newline_alloca16_lowered"
  exit 1
fi
write_alloca16_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_write_newline_alloca16_lowered.img | tr -d ' ')
write_alloca16_kernel_kind=$(od -An -t u8 -j "$((write_alloca16_dbg_off + 32))" -N 8 /tmp/l0_test_write_newline_alloca16_lowered.img | tr -d ' ')
if [ "$write_alloca16_kernel_kind" != "22" ]; then
  echo "FAIL: write newline alloca16 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_write_newline_alloca16_lowered.img >/tmp/l0_run_write_newline_alloca16_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_write_newline_alloca16_lowered.out)" != "0" ]; then
  echo "FAIL: run write newline alloca16 image result"
  exit 1
fi
if [ "$(od -An -t x1 /tmp/l0_run_write_newline_alloca16_lowered.out | tr -d ' \n')" != "0a300a" ]; then
  echo "FAIL: run write newline alloca16 output bytes"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_write_newline_alloca0_unlowered.l0" /tmp/l0_test_write_newline_alloca0_unlowered.img >/tmp/l0_build_write_newline_alloca0_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_alloca0_unlowered.out; then
  echo "FAIL: build valid_write_newline_alloca0_unlowered"
  exit 1
fi
write_alloca0_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_write_newline_alloca0_unlowered.img | tr -d ' ')
write_alloca0_kernel_kind=$(od -An -t u8 -j "$((write_alloca0_dbg_off + 32))" -N 8 /tmp/l0_test_write_newline_alloca0_unlowered.img | tr -d ' ')
write_alloca0_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_write_newline_alloca0_unlowered.img | tr -d ' ')
if [ "$write_alloca0_kernel_kind" != "0" ] || [ "$write_alloca0_code_size" != "1" ]; then
  echo "FAIL: write newline alloca0 unexpectedly lowered"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_trace_noop.l0" /tmp/l0_test_trace_noop.img >/tmp/l0_build_trace_noop.out
if ! grep -q '^ok$' /tmp/l0_build_trace_noop.out; then
  echo "FAIL: build valid_trace_noop"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_trace_noop.l0" /tmp/l0_test_trace_noop_map.img --debug-map /tmp/l0_trace_noop_debug_map.bin >/tmp/l0_build_trace_noop_map.out
if ! grep -q '^ok$' /tmp/l0_build_trace_noop_map.out; then
  echo "FAIL: build valid_trace_noop with --debug-map"
  exit 1
fi
"$BIN" mapcat /tmp/l0_trace_noop_debug_map.bin >/tmp/l0_trace_noop_mapcat.out
if [ "$(cat /tmp/l0_trace_noop_mapcat.out)" != $'entries 2\ncode_size 51\ninst_id 1\nstart 0\nend 17\ninst_id 2\nstart 17\nend 51' ]; then
  echo "FAIL: trace noop debug-map layout"
  exit 1
fi
trace_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_trace_noop.img | tr -d ' ')
trace_kernel_kind=$(od -An -t u8 -j "$((trace_dbg_off + 32))" -N 8 /tmp/l0_test_trace_noop.img | tr -d ' ')
if [ "$trace_kernel_kind" != "24" ]; then
  echo "FAIL: trace debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_trace_noop.img 123 >/tmp/l0_run_trace_noop.out 2>/tmp/l0_run_trace_noop.err
if [ "$(tr -d '\n' < /tmp/l0_run_trace_noop.out)" != "0" ]; then
  echo "FAIL: run trace emit image result"
  exit 1
fi
if [ "$(od -An -t x1 /tmp/l0_run_trace_noop.err | tr -d ' \n')" != "01000000000000007b00000000000000" ]; then
  echo "FAIL: run trace emit bytes"
  exit 1
fi
"$BIN" tracecat /tmp/l0_run_trace_noop.err >/tmp/l0_tracecat.out
if [ "$(cat /tmp/l0_tracecat.out)" != $'id 1\nval 123' ]; then
  echo "FAIL: tracecat decoded output"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_trace_noop_v7.l0" /tmp/l0_test_trace_noop_v7.img >/tmp/l0_build_trace_noop_v7.out
if ! grep -q '^ok$' /tmp/l0_build_trace_noop_v7.out; then
  echo "FAIL: build valid_trace_noop_v7"
  exit 1
fi
trace_v7_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_trace_noop_v7.img | tr -d ' ')
trace_v7_kernel_kind=$(od -An -t u8 -j "$((trace_v7_dbg_off + 32))" -N 8 /tmp/l0_test_trace_noop_v7.img | tr -d ' ')
if [ "$trace_v7_kernel_kind" != "24" ]; then
  echo "FAIL: trace v7 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_trace_noop_v7.img 123 >/tmp/l0_run_trace_noop_v7.out 2>/tmp/l0_run_trace_noop_v7.err
if [ "$(tr -d '\n' < /tmp/l0_run_trace_noop_v7.out)" != "0" ]; then
  echo "FAIL: run trace v7 image result"
  exit 1
fi
if [ "$(od -An -t x1 /tmp/l0_run_trace_noop_v7.err | tr -d ' \n')" != "01000000000000007b00000000000000" ]; then
  echo "FAIL: run trace v7 emit bytes"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_trace_noop_v123.l0" /tmp/l0_test_trace_noop_v123.img >/tmp/l0_build_trace_noop_v123.out
if ! grep -q '^ok$' /tmp/l0_build_trace_noop_v123.out; then
  echo "FAIL: build valid_trace_noop_v123"
  exit 1
fi
trace_v123_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_trace_noop_v123.img | tr -d ' ')
trace_v123_kernel_kind=$(od -An -t u8 -j "$((trace_v123_dbg_off + 32))" -N 8 /tmp/l0_test_trace_noop_v123.img | tr -d ' ')
if [ "$trace_v123_kernel_kind" != "24" ]; then
  echo "FAIL: trace v123 debug kernel kind id"
  exit 1
fi
"$BIN" run /tmp/l0_test_trace_noop_v123.img 123 >/tmp/l0_run_trace_noop_v123.out 2>/tmp/l0_run_trace_noop_v123.err
if [ "$(tr -d '\n' < /tmp/l0_run_trace_noop_v123.out)" != "0" ]; then
  echo "FAIL: run trace v123 image result"
  exit 1
fi
if [ "$(od -An -t x1 /tmp/l0_run_trace_noop_v123.err | tr -d ' \n')" != "01000000000000007b00000000000000" ]; then
  echo "FAIL: run trace v123 emit bytes"
  exit 1
fi
"$BIN" build "$ROOT/tests/valid_trace_noop_mismatch_unlowered.l0" /tmp/l0_test_trace_noop_mismatch_unlowered.img >/tmp/l0_build_trace_noop_mismatch_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_trace_noop_mismatch_unlowered.out; then
  echo "FAIL: build valid_trace_noop_mismatch_unlowered"
  exit 1
fi
trace_mismatch_dbg_off=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test_trace_noop_mismatch_unlowered.img | tr -d ' ')
trace_mismatch_kernel_kind=$(od -An -t u8 -j "$((trace_mismatch_dbg_off + 32))" -N 8 /tmp/l0_test_trace_noop_mismatch_unlowered.img | tr -d ' ')
trace_mismatch_code_size=$(od -An -t u8 -j 56 -N 8 /tmp/l0_test_trace_noop_mismatch_unlowered.img | tr -d ' ')
if [ "$trace_mismatch_kernel_kind" != "0" ] || [ "$trace_mismatch_code_size" != "1" ]; then
  echo "FAIL: trace mismatch unexpectedly lowered"
  exit 1
fi
cp /tmp/l0_run_trace_noop.err /tmp/l0_bad_trace_truncated.err
printf '\x00' >> /tmp/l0_bad_trace_truncated.err
if "$BIN" tracecat /tmp/l0_bad_trace_truncated.err >/tmp/l0_bad_trace_truncated.out 2>/tmp/l0_bad_trace_truncated.errlog; then
  echo "FAIL: tracecat accepted non-16-byte-aligned trace payload"
  exit 1
fi
"$BIN" tracejoin /tmp/l0_run_trace_noop.err /tmp/l0_trace_noop_debug_map.bin >/tmp/l0_tracejoin.out
if [ "$(cat /tmp/l0_tracejoin.out)" != $'id 1\nval 123\nstart 0\nend 17' ]; then
  echo "FAIL: tracejoin decoded output"
  exit 1
fi
cp /tmp/l0_run_trace_noop.err /tmp/l0_bad_tracejoin_truncated.err
printf '\x00' >> /tmp/l0_bad_tracejoin_truncated.err
if "$BIN" tracejoin /tmp/l0_bad_tracejoin_truncated.err /tmp/l0_trace_noop_debug_map.bin >/tmp/l0_bad_tracejoin_truncated.out 2>/tmp/l0_bad_tracejoin_truncated.errlog; then
  echo "FAIL: tracejoin accepted truncated trace payload"
  exit 1
fi
cat /tmp/l0_run_trace_noop.err /tmp/l0_run_trace_noop.err >/tmp/l0_trace_double.err
"$BIN" tracejoin /tmp/l0_trace_double.err /tmp/l0_trace_noop_debug_map.bin >/tmp/l0_tracejoin_double.out
if [ "$(cat /tmp/l0_tracejoin_double.out)" != $'id 1\nval 123\nstart 0\nend 17\nid 1\nval 123\nstart 0\nend 17' ]; then
  echo "FAIL: tracejoin double-record output"
  exit 1
fi
: >/tmp/l0_trace_empty.err
"$BIN" tracecat /tmp/l0_trace_empty.err >/tmp/l0_tracecat_empty.out
if [ -s /tmp/l0_tracecat_empty.out ]; then
  echo "FAIL: tracecat empty-file output"
  exit 1
fi
"$BIN" tracejoin /tmp/l0_trace_empty.err /tmp/l0_trace_noop_debug_map.bin >/tmp/l0_tracejoin_empty.out
if [ -s /tmp/l0_tracejoin_empty.out ]; then
  echo "FAIL: tracejoin empty-file output"
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
cp /tmp/l0_test.img /tmp/l0_bad_header_size.img
printf '\x4f\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_header_size.img bs=1 seek=16 conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_header_size.img >/tmp/l0_bad_header_size.out 2>/tmp/l0_bad_header_size.err; then
  echo "FAIL: imgcheck accepted bad header size"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_src_off.img
printf '\x4f\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_src_off.img bs=1 seek=32 conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_src_off.img >/tmp/l0_bad_src_off.out 2>/tmp/l0_bad_src_off.err; then
  echo "FAIL: imgcheck accepted bad src_off"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_src_size_overflow.img
printf '\xff\xff\xff\xff\xff\xff\xff\xff' | dd of=/tmp/l0_bad_src_size_overflow.img bs=1 seek=40 conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_src_size_overflow.img >/tmp/l0_bad_src_size_overflow.out 2>/tmp/l0_bad_src_size_overflow.err; then
  echo "FAIL: imgcheck accepted overflowing src_size"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_code_pair.img
printf '\x00\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_code_pair.img bs=1 seek=48 conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_code_pair.img >/tmp/l0_bad_code_pair.out 2>/tmp/l0_bad_code_pair.err; then
  echo "FAIL: imgcheck accepted inconsistent code pair"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_code_size_overflow.img
printf '\xff\xff\xff\xff\xff\xff\xff\xff' | dd of=/tmp/l0_bad_code_size_overflow.img bs=1 seek=56 conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_code_size_overflow.img >/tmp/l0_bad_code_size_overflow.out 2>/tmp/l0_bad_code_size_overflow.err; then
  echo "FAIL: imgcheck accepted overflowing code_size"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_debug_pair.img
printf '\x00\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_debug_pair.img bs=1 seek=72 conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_debug_pair.img >/tmp/l0_bad_debug_pair.out 2>/tmp/l0_bad_debug_pair.err; then
  echo "FAIL: imgcheck accepted inconsistent debug pair"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_debug_size_non64.img
printf '\x3f\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_debug_size_non64.img bs=1 seek=72 conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_debug_size_non64.img >/tmp/l0_bad_debug_size_non64.out 2>/tmp/l0_bad_debug_size_non64.err; then
  echo "FAIL: imgcheck accepted non-64 debug_size"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_code_off_overflow.img
printf '\xff\xff\xff\xff\xff\xff\xff\xff' | dd of=/tmp/l0_bad_code_off_overflow.img bs=1 seek=48 conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_code_off_overflow.img >/tmp/l0_bad_code_off_overflow.out 2>/tmp/l0_bad_code_off_overflow.err; then
  echo "FAIL: imgcheck accepted overflowing code_off"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_debug_off_overflow.img
printf '\xff\xff\xff\xff\xff\xff\xff\xff' | dd of=/tmp/l0_bad_debug_off_overflow.img bs=1 seek=64 conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_debug_off_overflow.img >/tmp/l0_bad_debug_off_overflow.out 2>/tmp/l0_bad_debug_off_overflow.err; then
  echo "FAIL: imgcheck accepted overflowing debug_off"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_dbg_magic.img
dbg_off_main=$(od -An -t u8 -j 64 -N 8 /tmp/l0_test.img | tr -d ' ')
printf 'BAD!' | dd of=/tmp/l0_bad_dbg_magic.img bs=1 seek="$dbg_off_main" conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_dbg_magic.img >/tmp/l0_bad_dbg_magic.out 2>/tmp/l0_bad_dbg_magic.err; then
  echo "FAIL: imgcheck accepted bad debug magic"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_dbg_codesz.img
printf '\x08\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_dbg_codesz.img bs=1 seek="$((dbg_off_main + 40))" conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_dbg_codesz.img >/tmp/l0_bad_dbg_codesz.out 2>/tmp/l0_bad_dbg_codesz.err; then
  echo "FAIL: imgcheck accepted mismatched debug code size"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_dbg_kernel_kind.img
printf '\xff\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_dbg_kernel_kind.img bs=1 seek="$((dbg_off_main + 32))" conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_dbg_kernel_kind.img >/tmp/l0_bad_dbg_kernel_kind.out 2>/tmp/l0_bad_dbg_kernel_kind.err; then
  echo "FAIL: imgcheck accepted out-of-range debug kernel kind"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_dbg_trace_schema_ver.img
printf '\x00\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_dbg_trace_schema_ver.img bs=1 seek="$((dbg_off_main + 48))" conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_dbg_trace_schema_ver.img >/tmp/l0_bad_dbg_trace_schema_ver.out 2>/tmp/l0_bad_dbg_trace_schema_ver.err; then
  echo "FAIL: imgcheck accepted bad debug trace schema version"
  exit 1
fi
cp /tmp/l0_test.img /tmp/l0_bad_dbg_trace_record_size.img
printf '\x08\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_bad_dbg_trace_record_size.img bs=1 seek="$((dbg_off_main + 56))" conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_bad_dbg_trace_record_size.img >/tmp/l0_bad_dbg_trace_record_size.out 2>/tmp/l0_bad_dbg_trace_record_size.err; then
  echo "FAIL: imgcheck accepted bad debug trace record size"
  exit 1
fi
for off in 8 16 32 40 48 56 64 72; do
  cp /tmp/l0_test.img "/tmp/l0_fuzz_header_ff_${off}.img"
  printf '\xff\xff\xff\xff\xff\xff\xff\xff' | dd of="/tmp/l0_fuzz_header_ff_${off}.img" bs=1 seek="$off" conv=notrunc status=none
  if "$BIN" imgcheck "/tmp/l0_fuzz_header_ff_${off}.img" >"/tmp/l0_fuzz_header_ff_${off}.out" 2>"/tmp/l0_fuzz_header_ff_${off}.err"; then
    echo "FAIL: imgcheck accepted fuzzed header field offset $off"
    exit 1
  fi
done
for rel in 32 40 48 56; do
  cp /tmp/l0_test.img "/tmp/l0_fuzz_debug_ff_${rel}.img"
  printf '\xff\xff\xff\xff\xff\xff\xff\xff' | dd of="/tmp/l0_fuzz_debug_ff_${rel}.img" bs=1 seek="$((dbg_off_main + rel))" conv=notrunc status=none
  if "$BIN" imgcheck "/tmp/l0_fuzz_debug_ff_${rel}.img" >"/tmp/l0_fuzz_debug_ff_${rel}.out" 2>"/tmp/l0_fuzz_debug_ff_${rel}.err"; then
    echo "FAIL: imgcheck accepted fuzzed debug-index field offset +$rel"
    exit 1
  fi
done
cp /tmp/l0_test.img /tmp/l0_fuzz_header_flags_nonzero.img
printf '\x01\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_fuzz_header_flags_nonzero.img bs=1 seek=24 conv=notrunc status=none
if "$BIN" imgcheck /tmp/l0_fuzz_header_flags_nonzero.img >/tmp/l0_fuzz_header_flags_nonzero.out 2>/tmp/l0_fuzz_header_flags_nonzero.err; then
  echo "FAIL: imgcheck accepted fuzzed nonzero flags field"
  exit 1
fi
printf 'BADIMG' >/tmp/l0_bad.img
if "$BIN" imgcheck /tmp/l0_bad.img >/tmp/l0_badimg.out 2>/tmp/l0_badimg.err; then
  echo "FAIL: imgcheck accepted invalid image"
  exit 1
fi

for f in \
  valid_mem_roundtrip_with_dead_const_general_lowered.l0 \
  valid_mem_roundtrip_mismatch_with_dead_const_unlowered.l0 \
  valid_mem_gep_roundtrip_with_dead_const_general_lowered.l0 \
  valid_mem_gep_roundtrip_mismatch_with_dead_const_unlowered.l0 \
  valid_malloc_with_dead_const_general_lowered.l0 \
  valid_malloc_mismatch_with_dead_const_unlowered.l0 \
  valid_exit_with_dead_const_general_lowered.l0 \
  valid_exit_mismatch_with_dead_const_unlowered.l0 \
  valid_write_newline_with_dead_const_general_unlowered.l0 \
  valid_free_noop_with_dead_const_general_unlowered.l0 \
  valid_trace_noop_with_dead_const_general_unlowered.l0 \
  valid_write_newline_with_two_dead_consts_general_unlowered.l0 \
  valid_free_noop_with_two_dead_consts_general_unlowered.l0 \
  valid_trace_noop_with_two_dead_consts_general_unlowered.l0 \
  valid_write_newline_v123_with_dead_const_general_unlowered.l0 \
  valid_free_noop_v123_with_dead_const_general_unlowered.l0 \
  valid_trace_noop_v123_with_dead_const_general_unlowered.l0 \
  valid_write_newline_alloca16_with_dead_const_general_unlowered.l0 \
  valid_write_newline_alloca0_with_dead_const_general_unlowered.l0 \
  valid_free_noop_v123_with_two_dead_consts_general_unlowered.l0 \
  valid_trace_noop_v123_with_two_dead_consts_general_unlowered.l0 \
  valid_write_newline_alloca0_v123_with_two_dead_consts_general_unlowered.l0 \
  valid_free_noop_v123_with_three_dead_consts_general_unlowered.l0 \
  valid_trace_noop_v123_with_three_dead_consts_general_unlowered.l0 \
  valid_write_newline_alloca0_v123_with_two_dead_consts_crossfn_general_unlowered.l0 \
  valid_free_noop_v123_with_three_dead_consts_crossfn_general_unlowered.l0 \
  valid_trace_noop_v123_with_three_dead_consts_crossfn_general_unlowered.l0
do
  "$BIN" verify "$ROOT/tests/$f" >/tmp/l0_ok_m16_"$f".out
  if ! grep -q '^ok$' /tmp/l0_ok_m16_"$f".out; then
    echo "FAIL: verify $f"
    exit 1
  fi
done

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

"$BIN" build "$ROOT/tests/valid_mem_roundtrip_with_dead_const_general_lowered.l0" /tmp/l0_test_mem_roundtrip_with_dead_const_general_lowered.img >/tmp/l0_build_mem_roundtrip_with_dead_const_general_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_roundtrip_with_dead_const_general_lowered.out; then
  echo "FAIL: build valid_mem_roundtrip_with_dead_const_general_lowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_mem_roundtrip_with_dead_const_general_lowered.img)" != "14" ]; then
  echo "FAIL: mem roundtrip dead-const generalized kernel kind"
  exit 1
fi
"$BIN" run /tmp/l0_test_mem_roundtrip_with_dead_const_general_lowered.img 42 >/tmp/l0_run_mem_roundtrip_with_dead_const_general_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_mem_roundtrip_with_dead_const_general_lowered.out)" != "42" ]; then
  echo "FAIL: run mem roundtrip dead-const generalized result"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_mem_roundtrip_mismatch_with_dead_const_unlowered.l0" /tmp/l0_test_mem_roundtrip_mismatch_with_dead_const_unlowered.img >/tmp/l0_build_mem_roundtrip_mismatch_with_dead_const_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_roundtrip_mismatch_with_dead_const_unlowered.out; then
  echo "FAIL: build valid_mem_roundtrip_mismatch_with_dead_const_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_mem_roundtrip_mismatch_with_dead_const_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_mem_roundtrip_mismatch_with_dead_const_unlowered.img)" != "1" ]; then
  echo "FAIL: mem roundtrip mismatch dead-const unexpectedly lowered"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_mem_gep_roundtrip_with_dead_const_general_lowered.l0" /tmp/l0_test_mem_gep_roundtrip_with_dead_const_general_lowered.img >/tmp/l0_build_mem_gep_roundtrip_with_dead_const_general_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_gep_roundtrip_with_dead_const_general_lowered.out; then
  echo "FAIL: build valid_mem_gep_roundtrip_with_dead_const_general_lowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_mem_gep_roundtrip_with_dead_const_general_lowered.img)" != "19" ]; then
  echo "FAIL: mem gep roundtrip dead-const generalized kernel kind"
  exit 1
fi
"$BIN" run /tmp/l0_test_mem_gep_roundtrip_with_dead_const_general_lowered.img 42 >/tmp/l0_run_mem_gep_roundtrip_with_dead_const_general_lowered.out
if [ "$(tr -d '\n' < /tmp/l0_run_mem_gep_roundtrip_with_dead_const_general_lowered.out)" != "42" ]; then
  echo "FAIL: run mem gep roundtrip dead-const generalized result"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_mem_gep_roundtrip_mismatch_with_dead_const_unlowered.l0" /tmp/l0_test_mem_gep_roundtrip_mismatch_with_dead_const_unlowered.img >/tmp/l0_build_mem_gep_roundtrip_mismatch_with_dead_const_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_mem_gep_roundtrip_mismatch_with_dead_const_unlowered.out; then
  echo "FAIL: build valid_mem_gep_roundtrip_mismatch_with_dead_const_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_mem_gep_roundtrip_mismatch_with_dead_const_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_mem_gep_roundtrip_mismatch_with_dead_const_unlowered.img)" != "1" ]; then
  echo "FAIL: mem gep roundtrip mismatch dead-const unexpectedly lowered"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_malloc_with_dead_const_general_lowered.l0" /tmp/l0_test_malloc_with_dead_const_general_lowered.img >/tmp/l0_build_malloc_with_dead_const_general_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_malloc_with_dead_const_general_lowered.out; then
  echo "FAIL: build valid_malloc_with_dead_const_general_lowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_malloc_with_dead_const_general_lowered.img)" != "20" ]; then
  echo "FAIL: malloc dead-const generalized kernel kind"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_malloc_mismatch_with_dead_const_unlowered.l0" /tmp/l0_test_malloc_mismatch_with_dead_const_unlowered.img >/tmp/l0_build_malloc_mismatch_with_dead_const_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_malloc_mismatch_with_dead_const_unlowered.out; then
  echo "FAIL: build valid_malloc_mismatch_with_dead_const_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_malloc_mismatch_with_dead_const_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_malloc_mismatch_with_dead_const_unlowered.img)" != "1" ]; then
  echo "FAIL: malloc mismatch dead-const unexpectedly lowered"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_exit_with_dead_const_general_lowered.l0" /tmp/l0_test_exit_with_dead_const_general_lowered.img >/tmp/l0_build_exit_with_dead_const_general_lowered.out
if ! grep -q '^ok$' /tmp/l0_build_exit_with_dead_const_general_lowered.out; then
  echo "FAIL: build valid_exit_with_dead_const_general_lowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_exit_with_dead_const_general_lowered.img)" != "23" ]; then
  echo "FAIL: exit dead-const generalized kernel kind"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_exit_mismatch_with_dead_const_unlowered.l0" /tmp/l0_test_exit_mismatch_with_dead_const_unlowered.img >/tmp/l0_build_exit_mismatch_with_dead_const_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_exit_mismatch_with_dead_const_unlowered.out; then
  echo "FAIL: build valid_exit_mismatch_with_dead_const_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_exit_mismatch_with_dead_const_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_exit_mismatch_with_dead_const_unlowered.img)" != "1" ]; then
  echo "FAIL: exit mismatch dead-const unexpectedly lowered"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_write_newline_with_dead_const_general_unlowered.l0" /tmp/l0_test_write_newline_with_dead_const_general_unlowered.img >/tmp/l0_build_write_newline_with_dead_const_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_with_dead_const_general_unlowered.out; then
  echo "FAIL: build valid_write_newline_with_dead_const_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_write_newline_with_dead_const_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_write_newline_with_dead_const_general_unlowered.img)" != "1" ]; then
  echo "FAIL: write newline dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_free_noop_with_dead_const_general_unlowered.l0" /tmp/l0_test_free_noop_with_dead_const_general_unlowered.img >/tmp/l0_build_free_noop_with_dead_const_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_free_noop_with_dead_const_general_unlowered.out; then
  echo "FAIL: build valid_free_noop_with_dead_const_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_free_noop_with_dead_const_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_free_noop_with_dead_const_general_unlowered.img)" != "1" ]; then
  echo "FAIL: free noop dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_trace_noop_with_dead_const_general_unlowered.l0" /tmp/l0_test_trace_noop_with_dead_const_general_unlowered.img >/tmp/l0_build_trace_noop_with_dead_const_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_trace_noop_with_dead_const_general_unlowered.out; then
  echo "FAIL: build valid_trace_noop_with_dead_const_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_trace_noop_with_dead_const_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_trace_noop_with_dead_const_general_unlowered.img)" != "1" ]; then
  echo "FAIL: trace noop dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_write_newline_with_two_dead_consts_general_unlowered.l0" /tmp/l0_test_write_newline_with_two_dead_consts_general_unlowered.img >/tmp/l0_build_write_newline_with_two_dead_consts_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_with_two_dead_consts_general_unlowered.out; then
  echo "FAIL: build valid_write_newline_with_two_dead_consts_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_write_newline_with_two_dead_consts_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_write_newline_with_two_dead_consts_general_unlowered.img)" != "1" ]; then
  echo "FAIL: write newline two-dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_free_noop_with_two_dead_consts_general_unlowered.l0" /tmp/l0_test_free_noop_with_two_dead_consts_general_unlowered.img >/tmp/l0_build_free_noop_with_two_dead_consts_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_free_noop_with_two_dead_consts_general_unlowered.out; then
  echo "FAIL: build valid_free_noop_with_two_dead_consts_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_free_noop_with_two_dead_consts_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_free_noop_with_two_dead_consts_general_unlowered.img)" != "1" ]; then
  echo "FAIL: free noop two-dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_trace_noop_with_two_dead_consts_general_unlowered.l0" /tmp/l0_test_trace_noop_with_two_dead_consts_general_unlowered.img >/tmp/l0_build_trace_noop_with_two_dead_consts_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_trace_noop_with_two_dead_consts_general_unlowered.out; then
  echo "FAIL: build valid_trace_noop_with_two_dead_consts_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_trace_noop_with_two_dead_consts_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_trace_noop_with_two_dead_consts_general_unlowered.img)" != "1" ]; then
  echo "FAIL: trace noop two-dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_write_newline_v123_with_dead_const_general_unlowered.l0" /tmp/l0_test_write_newline_v123_with_dead_const_general_unlowered.img >/tmp/l0_build_write_newline_v123_with_dead_const_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_v123_with_dead_const_general_unlowered.out; then
  echo "FAIL: build valid_write_newline_v123_with_dead_const_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_write_newline_v123_with_dead_const_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_write_newline_v123_with_dead_const_general_unlowered.img)" != "1" ]; then
  echo "FAIL: write newline v123 dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_free_noop_v123_with_dead_const_general_unlowered.l0" /tmp/l0_test_free_noop_v123_with_dead_const_general_unlowered.img >/tmp/l0_build_free_noop_v123_with_dead_const_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_free_noop_v123_with_dead_const_general_unlowered.out; then
  echo "FAIL: build valid_free_noop_v123_with_dead_const_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_free_noop_v123_with_dead_const_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_free_noop_v123_with_dead_const_general_unlowered.img)" != "1" ]; then
  echo "FAIL: free noop v123 dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_trace_noop_v123_with_dead_const_general_unlowered.l0" /tmp/l0_test_trace_noop_v123_with_dead_const_general_unlowered.img >/tmp/l0_build_trace_noop_v123_with_dead_const_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_trace_noop_v123_with_dead_const_general_unlowered.out; then
  echo "FAIL: build valid_trace_noop_v123_with_dead_const_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_trace_noop_v123_with_dead_const_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_trace_noop_v123_with_dead_const_general_unlowered.img)" != "1" ]; then
  echo "FAIL: trace noop v123 dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_write_newline_alloca16_with_dead_const_general_unlowered.l0" /tmp/l0_test_write_newline_alloca16_with_dead_const_general_unlowered.img >/tmp/l0_build_write_newline_alloca16_with_dead_const_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_alloca16_with_dead_const_general_unlowered.out; then
  echo "FAIL: build valid_write_newline_alloca16_with_dead_const_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_write_newline_alloca16_with_dead_const_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_write_newline_alloca16_with_dead_const_general_unlowered.img)" != "1" ]; then
  echo "FAIL: write newline alloca16 dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_write_newline_alloca0_with_dead_const_general_unlowered.l0" /tmp/l0_test_write_newline_alloca0_with_dead_const_general_unlowered.img >/tmp/l0_build_write_newline_alloca0_with_dead_const_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_alloca0_with_dead_const_general_unlowered.out; then
  echo "FAIL: build valid_write_newline_alloca0_with_dead_const_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_write_newline_alloca0_with_dead_const_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_write_newline_alloca0_with_dead_const_general_unlowered.img)" != "1" ]; then
  echo "FAIL: write newline alloca0 dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_free_noop_v123_with_two_dead_consts_general_unlowered.l0" /tmp/l0_test_free_noop_v123_with_two_dead_consts_general_unlowered.img >/tmp/l0_build_free_noop_v123_with_two_dead_consts_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_free_noop_v123_with_two_dead_consts_general_unlowered.out; then
  echo "FAIL: build valid_free_noop_v123_with_two_dead_consts_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_free_noop_v123_with_two_dead_consts_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_free_noop_v123_with_two_dead_consts_general_unlowered.img)" != "1" ]; then
  echo "FAIL: free noop v123 two-dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_trace_noop_v123_with_two_dead_consts_general_unlowered.l0" /tmp/l0_test_trace_noop_v123_with_two_dead_consts_general_unlowered.img >/tmp/l0_build_trace_noop_v123_with_two_dead_consts_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_trace_noop_v123_with_two_dead_consts_general_unlowered.out; then
  echo "FAIL: build valid_trace_noop_v123_with_two_dead_consts_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_trace_noop_v123_with_two_dead_consts_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_trace_noop_v123_with_two_dead_consts_general_unlowered.img)" != "1" ]; then
  echo "FAIL: trace noop v123 two-dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_write_newline_alloca0_v123_with_two_dead_consts_general_unlowered.l0" /tmp/l0_test_write_newline_alloca0_v123_with_two_dead_consts_general_unlowered.img >/tmp/l0_build_write_newline_alloca0_v123_with_two_dead_consts_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_alloca0_v123_with_two_dead_consts_general_unlowered.out; then
  echo "FAIL: build valid_write_newline_alloca0_v123_with_two_dead_consts_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_write_newline_alloca0_v123_with_two_dead_consts_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_write_newline_alloca0_v123_with_two_dead_consts_general_unlowered.img)" != "1" ]; then
  echo "FAIL: write newline alloca0 v123 two-dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_free_noop_v123_with_three_dead_consts_general_unlowered.l0" /tmp/l0_test_free_noop_v123_with_three_dead_consts_general_unlowered.img >/tmp/l0_build_free_noop_v123_with_three_dead_consts_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_free_noop_v123_with_three_dead_consts_general_unlowered.out; then
  echo "FAIL: build valid_free_noop_v123_with_three_dead_consts_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_free_noop_v123_with_three_dead_consts_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_free_noop_v123_with_three_dead_consts_general_unlowered.img)" != "1" ]; then
  echo "FAIL: free noop v123 three-dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_trace_noop_v123_with_three_dead_consts_general_unlowered.l0" /tmp/l0_test_trace_noop_v123_with_three_dead_consts_general_unlowered.img >/tmp/l0_build_trace_noop_v123_with_three_dead_consts_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_trace_noop_v123_with_three_dead_consts_general_unlowered.out; then
  echo "FAIL: build valid_trace_noop_v123_with_three_dead_consts_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_trace_noop_v123_with_three_dead_consts_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_trace_noop_v123_with_three_dead_consts_general_unlowered.img)" != "1" ]; then
  echo "FAIL: trace noop v123 three-dead-const generalized hook fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_write_newline_alloca0_v123_with_two_dead_consts_crossfn_general_unlowered.l0" /tmp/l0_test_write_newline_alloca0_v123_with_two_dead_consts_crossfn_general_unlowered.img >/tmp/l0_build_write_newline_alloca0_v123_with_two_dead_consts_crossfn_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline_alloca0_v123_with_two_dead_consts_crossfn_general_unlowered.out; then
  echo "FAIL: build valid_write_newline_alloca0_v123_with_two_dead_consts_crossfn_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_write_newline_alloca0_v123_with_two_dead_consts_crossfn_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_write_newline_alloca0_v123_with_two_dead_consts_crossfn_general_unlowered.img)" != "1" ]; then
  echo "FAIL: write newline crossfn alloca0 v123 two-dead-const fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_free_noop_v123_with_three_dead_consts_crossfn_general_unlowered.l0" /tmp/l0_test_free_noop_v123_with_three_dead_consts_crossfn_general_unlowered.img >/tmp/l0_build_free_noop_v123_with_three_dead_consts_crossfn_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_free_noop_v123_with_three_dead_consts_crossfn_general_unlowered.out; then
  echo "FAIL: build valid_free_noop_v123_with_three_dead_consts_crossfn_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_free_noop_v123_with_three_dead_consts_crossfn_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_free_noop_v123_with_three_dead_consts_crossfn_general_unlowered.img)" != "1" ]; then
  echo "FAIL: free noop crossfn v123 three-dead-const fallback violated"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_trace_noop_v123_with_three_dead_consts_crossfn_general_unlowered.l0" /tmp/l0_test_trace_noop_v123_with_three_dead_consts_crossfn_general_unlowered.img >/tmp/l0_build_trace_noop_v123_with_three_dead_consts_crossfn_general_unlowered.out
if ! grep -q '^ok$' /tmp/l0_build_trace_noop_v123_with_three_dead_consts_crossfn_general_unlowered.out; then
  echo "FAIL: build valid_trace_noop_v123_with_three_dead_consts_crossfn_general_unlowered"
  exit 1
fi
if [ "$(get_kernel_kind /tmp/l0_test_trace_noop_v123_with_three_dead_consts_crossfn_general_unlowered.img)" != "0" ] || [ "$(get_code_size /tmp/l0_test_trace_noop_v123_with_three_dead_consts_crossfn_general_unlowered.img)" != "1" ]; then
  echo "FAIL: trace noop crossfn v123 three-dead-const fallback violated"
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
if "$BIN" verify "$ROOT/tests/invalid_unknown_opcode.l0" >/tmp/l0_bad38.out 2>/tmp/l0_bad38.err; then
  echo "FAIL: invalid_unknown_opcode unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_malloc_result_not_pointer.l0" >/tmp/l0_bad38a.out 2>/tmp/l0_bad38a.err; then
  echo "FAIL: invalid_malloc_result_not_pointer unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_malloc_size_undefined.l0" >/tmp/l0_bad38aa.out 2>/tmp/l0_bad38aa.err; then
  echo "FAIL: invalid_malloc_size_undefined unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_malloc_size_pointer.l0" >/tmp/l0_bad38ab.out 2>/tmp/l0_bad38ab.err; then
  echo "FAIL: invalid_malloc_size_pointer unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_free_ptr_not_pointer.l0" >/tmp/l0_bad38b.out 2>/tmp/l0_bad38b.err; then
  echo "FAIL: invalid_free_ptr_not_pointer unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_exit_undefined.l0" >/tmp/l0_bad38d.out 2>/tmp/l0_bad38d.err; then
  echo "FAIL: invalid_exit_undefined unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_exit_code_pointer.l0" >/tmp/l0_bad38dd.out 2>/tmp/l0_bad38dd.err; then
  echo "FAIL: invalid_exit_code_pointer unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_write_ptr_not_pointer.l0" >/tmp/l0_bad38e.out 2>/tmp/l0_bad38e.err; then
  echo "FAIL: invalid_write_ptr_not_pointer unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_write_len_undefined.l0" >/tmp/l0_bad38f.out 2>/tmp/l0_bad38f.err; then
  echo "FAIL: invalid_write_len_undefined unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_write_len_pointer.l0" >/tmp/l0_bad38g.out 2>/tmp/l0_bad38g.err; then
  echo "FAIL: invalid_write_len_pointer unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_trace_undefined.l0" >/tmp/l0_bad38h.out 2>/tmp/l0_bad38h.err; then
  echo "FAIL: invalid_trace_undefined unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_trace_second_undefined.l0" >/tmp/l0_bad38i.out 2>/tmp/l0_bad38i.err; then
  echo "FAIL: invalid_trace_second_undefined unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_ld_ptr_not_pointer.l0" >/tmp/l0_bad39.out 2>/tmp/l0_bad39.err; then
  echo "FAIL: invalid_ld_ptr_not_pointer unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_gep_result_not_pointer.l0" >/tmp/l0_bad40.out 2>/tmp/l0_bad40.err; then
  echo "FAIL: invalid_gep_result_not_pointer unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_gep_ptr_not_pointer.l0" >/tmp/l0_bad41.out 2>/tmp/l0_bad41.err; then
  echo "FAIL: invalid_gep_ptr_not_pointer unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_alloca_result_not_pointer.l0" >/tmp/l0_bad42.out 2>/tmp/l0_bad42.err; then
  echo "FAIL: invalid_alloca_result_not_pointer unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_alloca_bad_shape.l0" >/tmp/l0_bad43.out 2>/tmp/l0_bad43.err; then
  echo "FAIL: invalid_alloca_bad_shape unexpectedly passed"
  exit 1
fi
if "$BIN" verify "$ROOT/tests/invalid_st_ptr_not_pointer.l0" >/tmp/l0_bad44.out 2>/tmp/l0_bad44.err; then
  echo "FAIL: invalid_st_ptr_not_pointer unexpectedly passed"
  exit 1
fi

echo "PASS"
