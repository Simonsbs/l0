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
"$BIN" verify "$ROOT/tests/valid_call_sub_lowered.l0" >/tmp/l0_ok_call_sub_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_sub_lowered.out; then
  echo "FAIL: verify valid_call_sub_lowered"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_call_mul_lowered.l0" >/tmp/l0_ok_call_mul_lowered.out
if ! grep -q '^ok$' /tmp/l0_ok_call_mul_lowered.out; then
  echo "FAIL: verify valid_call_mul_lowered"
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
"$BIN" verify "$ROOT/tests/valid_cbr_eq_select.l0" >/tmp/l0_ok_cbr_eq_select.out
if ! grep -q '^ok$' /tmp/l0_ok_cbr_eq_select.out; then
  echo "FAIL: verify valid_cbr_eq_select"
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
"$BIN" verify "$ROOT/tests/valid_mem_gep_roundtrip.l0" >/tmp/l0_ok_mem_gep_roundtrip.out
if ! grep -q '^ok$' /tmp/l0_ok_mem_gep_roundtrip.out; then
  echo "FAIL: verify valid_mem_gep_roundtrip"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_malloc.l0" >/tmp/l0_ok_malloc.out
if ! grep -q '^ok$' /tmp/l0_ok_malloc.out; then
  echo "FAIL: verify valid_malloc"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_free_noop.l0" >/tmp/l0_ok_free_noop.out
if ! grep -q '^ok$' /tmp/l0_ok_free_noop.out; then
  echo "FAIL: verify valid_free_noop"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_exit.l0" >/tmp/l0_ok_exit.out
if ! grep -q '^ok$' /tmp/l0_ok_exit.out; then
  echo "FAIL: verify valid_exit"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_write_newline.l0" >/tmp/l0_ok_write_newline.out
if ! grep -q '^ok$' /tmp/l0_ok_write_newline.out; then
  echo "FAIL: verify valid_write_newline"
  exit 1
fi
"$BIN" verify "$ROOT/tests/valid_trace_noop.l0" >/tmp/l0_ok_trace_noop.out
if ! grep -q '^ok$' /tmp/l0_ok_trace_noop.out; then
  echo "FAIL: verify valid_trace_noop"
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
if [ "$dbg_map_version" != "2" ] || [ "$dbg_map_inst_count" != "3" ] || [ "$dbg_map_code_size" != "7" ] || [ "$dbg_map_inst1_id" != "1" ] || [ "$dbg_map_inst1_start" != "0" ] || [ "$dbg_map_inst1_end" != "2" ] || [ "$dbg_map_inst2_id" != "2" ] || [ "$dbg_map_inst2_start" != "2" ] || [ "$dbg_map_inst2_end" != "4" ] || [ "$dbg_map_inst3_id" != "3" ] || [ "$dbg_map_inst3_start" != "4" ] || [ "$dbg_map_inst3_end" != "7" ]; then
  echo "FAIL: debug map fields"
  exit 1
fi
"$BIN" mapcat /tmp/l0_debug_map.bin >/tmp/l0_mapcat.out
if [ "$(cat /tmp/l0_mapcat.out)" != $'entries 3\ncode_size 7\ninst_id 1\nstart 0\nend 2\ninst_id 2\nstart 2\nend 4\ninst_id 3\nstart 4\nend 7' ]; then
  echo "FAIL: mapcat decoded output"
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
if [ "$(cat /tmp/l0_imgmeta.out)" != $'version 1\nsrc_size '"$in_size"$'\ncode_size 7\nkernel_kind 1\ntrace_schema_ver 1\ntrace_record_size 16' ]; then
  echo "FAIL: imgmeta decoded output"
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
"$BIN" build "$ROOT/tests/valid_add_trap.l0" /tmp/l0_test_add_trap.img >/tmp/l0_build_add_trap.out
if ! grep -q '^ok$' /tmp/l0_build_add_trap.out; then
  echo "FAIL: build valid_add_trap"
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
"$BIN" build "$ROOT/tests/valid_cbr_eq_select.l0" /tmp/l0_test_cbr_eq_select.img >/tmp/l0_build_cbr_eq_select.out
if ! grep -q '^ok$' /tmp/l0_build_cbr_eq_select.out; then
  echo "FAIL: build valid_cbr_eq_select"
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
"$BIN" build "$ROOT/tests/valid_malloc.l0" /tmp/l0_test_malloc.img >/tmp/l0_build_malloc.out
if ! grep -q '^ok$' /tmp/l0_build_malloc.out; then
  echo "FAIL: build valid_malloc"
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
"$BIN" build "$ROOT/tests/valid_write_newline.l0" /tmp/l0_test_write_newline.img >/tmp/l0_build_write_newline.out
if ! grep -q '^ok$' /tmp/l0_build_write_newline.out; then
  echo "FAIL: build valid_write_newline"
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
"$BIN" build "$ROOT/tests/valid_trace_noop.l0" /tmp/l0_test_trace_noop.img >/tmp/l0_build_trace_noop.out
if ! grep -q '^ok$' /tmp/l0_build_trace_noop.out; then
  echo "FAIL: build valid_trace_noop"
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
