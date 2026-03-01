.intel_syntax noprefix

.section .bss
.lcomm file_buf, 1048576
.lcomm out_path_ptr, 8
.lcomm trace_schema_out_path_ptr, 8
.lcomm debug_map_out_path_ptr, 8
.lcomm run_arg1_ptr, 8
.lcomm run_arg2_ptr, 8
.lcomm tracejoin_map_path_ptr, 8
.lcomm num_buf, 32
.lcomm codegen_buf, 65536
.lcomm codegen_len, 8
.lcomm img_header_buf, 80
.lcomm img_debug_idx_buf, 64
.lcomm trace_schema_buf, 32
.lcomm debug_map_buf, 256
.lcomm debug_map_size, 8
.lcomm debug_map_fd, 8
.lcomm tracejoin_map_count, 8
.lcomm tracejoin_map_inst_id, 512
.lcomm tracejoin_map_start, 512
.lcomm tracejoin_map_end, 512
.lcomm tracejoin_join_start, 8
.lcomm tracejoin_join_end, 8
.lcomm build_kernel_kind, 8
.lcomm vfp_state_in_fn, 8
.lcomm vfp_fn_seen, 8
.lcomm vfp_type_count, 8
.lcomm vfp_type_is_i1_map, 32768
.lcomm vfp_type_is_p0_i8_map, 32768
.lcomm vfp_i1_type_id, 8
.lcomm vfp_block_seen, 8
.lcomm vfp_term_seen, 8
.lcomm vfp_fn_arg_count, 8
.lcomm vfp_fn_ret_type, 8
.lcomm vfp_fn_body_ptr, 8
.lcomm vfp_fns_body_ptr, 8
.lcomm vfp_last_fn_id, 8
.lcomm vfp_last_block_id, 8
.lcomm vfp_fn_arg_type_map, 8192
.lcomm vfp_fn_arg_count_map, 32768
.lcomm vfp_fn_ret_type_map, 32768
.lcomm vfp_block_seen_map, 2048
.lcomm vfp_value_seen_map, 8192
.lcomm vfp_value_type_map, 524288

.section .rodata
usage_msg: .ascii "usage: l0c <canon|verify> <input.l0> | l0c canon <input.l0> -o <out.l0> | l0c build <input.l0> <out.l0img> [--trace-schema <out.bin>] [--debug-map <out.bin>] | l0c build <input.l0> -o <out.l0img> [--trace-schema <out.bin>] [--debug-map <out.bin>] | l0c imgcheck <file.l0img> | l0c imgmeta <file.l0img> | l0c run <file.l0img> [u64_a] [u64_b] | l0c tracecat <trace.bin> | l0c mapcat <debug_map.bin> | l0c schemacat <trace_schema.bin> | l0c tracejoin <trace.bin> <debug_map.bin>\n"
usage_len = . - usage_msg

ok_msg: .ascii "ok\n"
ok_len = . - ok_msg

err_open_msg: .ascii "error: cannot open input\n"
err_open_len = . - err_open_msg

err_read_msg: .ascii "error: cannot read input\n"
err_read_len = . - err_read_msg

err_parse_msg: .ascii "error: invalid module shape or non-canonical input\n"
err_parse_len = . - err_parse_msg
err_build_msg: .ascii "error: cannot write output image\n"
err_build_len = . - err_build_msg
err_img_msg: .ascii "error: invalid or corrupt L0IMG\n"
err_img_len = . - err_img_msg
err_run_msg: .ascii "error: cannot execute image\n"
err_run_len = . - err_run_msg
err_run_arg_msg: .ascii "error: invalid run argument (expected unsigned decimal)\n"
err_run_arg_len = . - err_run_arg_msg

cmd_canon: .ascii "canon\0"
cmd_verify: .ascii "verify\0"
cmd_build: .ascii "build\0"
flag_o: .ascii "-o\0"
flag_trace_schema: .ascii "--trace-schema\0"
flag_debug_map: .ascii "--debug-map\0"
cmd_imgcheck: .ascii "imgcheck\0"
cmd_imgmeta: .ascii "imgmeta\0"
cmd_run: .ascii "run\0"
cmd_tracecat: .ascii "tracecat\0"
cmd_mapcat: .ascii "mapcat\0"
cmd_schemacat: .ascii "schemacat\0"
cmd_tracejoin: .ascii "tracejoin\0"
trace_id_prefix: .ascii "id "
trace_id_prefix_len = . - trace_id_prefix
trace_val_prefix: .ascii "val "
trace_val_prefix_len = . - trace_val_prefix
map_entries_prefix: .ascii "entries "
map_entries_prefix_len = . - map_entries_prefix
map_code_size_prefix: .ascii "code_size "
map_code_size_prefix_len = . - map_code_size_prefix
map_inst_id_prefix: .ascii "inst_id "
map_inst_id_prefix_len = . - map_inst_id_prefix
map_start_prefix: .ascii "start "
map_start_prefix_len = . - map_start_prefix
map_end_prefix: .ascii "end "
map_end_prefix_len = . - map_end_prefix
schema_version_prefix: .ascii "version "
schema_version_prefix_len = . - schema_version_prefix
schema_record_size_prefix: .ascii "record_size "
schema_record_size_prefix_len = . - schema_record_size_prefix
schema_fields_prefix: .ascii "fields "
schema_fields_prefix_len = . - schema_fields_prefix
join_start_prefix: .ascii "start "
join_start_prefix_len = . - join_start_prefix
join_end_prefix: .ascii "end "
join_end_prefix_len = . - join_end_prefix
img_version_prefix: .ascii "version "
img_version_prefix_len = . - img_version_prefix
img_src_size_prefix: .ascii "src_size "
img_src_size_prefix_len = . - img_src_size_prefix
img_code_size_prefix: .ascii "code_size "
img_code_size_prefix_len = . - img_code_size_prefix
img_fn_count_prefix: .ascii "fn_count "
img_fn_count_prefix_len = . - img_fn_count_prefix
img_type_count_prefix: .ascii "type_count "
img_type_count_prefix_len = . - img_type_count_prefix
img_kernel_kind_prefix: .ascii "kernel_kind "
img_kernel_kind_prefix_len = . - img_kernel_kind_prefix
img_trace_schema_ver_prefix: .ascii "trace_schema_ver "
img_trace_schema_ver_prefix_len = . - img_trace_schema_ver_prefix
img_trace_record_size_prefix: .ascii "trace_record_size "
img_trace_record_size_prefix_len = . - img_trace_record_size_prefix
img_header_len = 80

kw_ver: .ascii "ver "
kw_ver_len = . - kw_ver
kw_types: .ascii "types {"
kw_types_len = . - kw_types
kw_consts: .ascii "consts {"
kw_consts_len = . - kw_consts
kw_extern: .ascii "extern {"
kw_extern_len = . - kw_extern
kw_globals: .ascii "globals {"
kw_globals_len = . - kw_globals
kw_fns: .ascii "fns {"
kw_fns_len = . - kw_fns

tok_i1: .ascii "i1"
tok_i1_len = . - tok_i1
tok_i8: .ascii "i8"
tok_i8_len = . - tok_i8
tok_i16: .ascii "i16"
tok_i16_len = . - tok_i16
tok_i32: .ascii "i32"
tok_i32_len = . - tok_i32
tok_i64: .ascii "i64"
tok_i64_len = . - tok_i64
tok_u8: .ascii "u8"
tok_u8_len = . - tok_u8
tok_u16: .ascii "u16"
tok_u16_len = . - tok_u16
tok_u32: .ascii "u32"
tok_u32_len = . - tok_u32
tok_u64: .ascii "u64"
tok_u64_len = . - tok_u64
tok_p0_i8: .ascii "p0<i8>"
tok_p0_i8_len = . - tok_p0_i8

code_stub_ret: .byte 0xc3
code_stub_ret_len = . - code_stub_ret
code_stub_add: .byte 0x48,0x89,0xf8,0x48,0x01,0xf0,0xc3
code_stub_add_len = . - code_stub_add
code_stub_add_trap: .byte 0x48,0x89,0xf8,0x48,0x01,0xf0,0x70,0x01,0xc3,0x0f,0x0b
code_stub_add_trap_len = . - code_stub_add_trap
code_stub_sub: .byte 0x48,0x89,0xf8,0x48,0x29,0xf0,0xc3
code_stub_sub_len = . - code_stub_sub
code_stub_sub_trap: .byte 0x48,0x89,0xf8,0x48,0x29,0xf0,0x70,0x01,0xc3,0x0f,0x0b
code_stub_sub_trap_len = . - code_stub_sub_trap
code_stub_and: .byte 0x48,0x89,0xf8,0x48,0x21,0xf0,0xc3
code_stub_and_len = . - code_stub_and
code_stub_or: .byte 0x48,0x89,0xf8,0x48,0x09,0xf0,0xc3
code_stub_or_len = . - code_stub_or
code_stub_xor: .byte 0x48,0x89,0xf8,0x48,0x31,0xf0,0xc3
code_stub_xor_len = . - code_stub_xor
code_stub_mul: .byte 0x48,0x89,0xf8,0x48,0x0f,0xaf,0xc6,0xc3
code_stub_mul_len = . - code_stub_mul
code_stub_mul_trap: .byte 0x48,0x89,0xf8,0x48,0x0f,0xaf,0xc6,0x70,0x01,0xc3,0x0f,0x0b
code_stub_mul_trap_len = . - code_stub_mul_trap
code_stub_shl: .byte 0x48,0x89,0xf8,0x48,0x89,0xf1,0x48,0xd3,0xe0,0xc3
code_stub_shl_len = . - code_stub_shl
code_stub_shr: .byte 0x48,0x89,0xf8,0x48,0x89,0xf1,0x48,0xd3,0xe8,0xc3
code_stub_shr_len = . - code_stub_shr
code_stub_icmp_eq: .byte 0x31,0xc0,0x48,0x39,0xf7,0x0f,0x94,0xc0,0xc3
code_stub_icmp_eq_len = . - code_stub_icmp_eq
code_stub_cbr_eq_select: .byte 0x48,0x89,0xf0,0x48,0x39,0xf7,0x48,0x0f,0x44,0xc7,0xc3
code_stub_cbr_eq_select_len = . - code_stub_cbr_eq_select
code_stub_mem_roundtrip: .byte 0x48,0x83,0xec,0x08,0x48,0x89,0x3c,0x24,0x48,0x8b,0x04,0x24,0x48,0x83,0xc4,0x08,0xc3
code_stub_mem_roundtrip_len = . - code_stub_mem_roundtrip
code_stub_malloc: .byte 0x48,0x89,0xfe,0x48,0x31,0xff,0x48,0xc7,0xc0,0x09,0x00,0x00,0x00,0x48,0xc7,0xc2,0x03,0x00,0x00,0x00,0x49,0xc7,0xc2,0x22,0x00,0x00,0x00,0x49,0xc7,0xc0,0xff,0xff,0xff,0xff,0x4d,0x31,0xc9,0x0f,0x05,0xc3
code_stub_malloc_len = . - code_stub_malloc
code_stub_free_noop: .byte 0x48,0x31,0xc0,0xc3
code_stub_free_noop_len = . - code_stub_free_noop
code_stub_exit: .byte 0x48,0xc7,0xc0,0x3c,0x00,0x00,0x00,0x0f,0x05
code_stub_exit_len = . - code_stub_exit
code_stub_write_newline: .byte 0x48,0x83,0xec,0x08,0x48,0xc7,0x04,0x24,0x0a,0x00,0x00,0x00,0x48,0xc7,0xc0,0x01,0x00,0x00,0x00,0x48,0xc7,0xc7,0x01,0x00,0x00,0x00,0x48,0x89,0xe6,0x48,0xc7,0xc2,0x01,0x00,0x00,0x00,0x0f,0x05,0x48,0x31,0xc0,0x48,0x83,0xc4,0x08,0xc3
code_stub_write_newline_len = . - code_stub_write_newline
code_stub_trace_emit: .byte 0x48,0x83,0xec,0x10,0x48,0xc7,0x04,0x24,0x01,0x00,0x00,0x00,0x48,0x89,0x7c,0x24,0x08,0x48,0xc7,0xc0,0x01,0x00,0x00,0x00,0x48,0xc7,0xc7,0x02,0x00,0x00,0x00,0x48,0x89,0xe6,0x48,0xc7,0xc2,0x10,0x00,0x00,0x00,0x0f,0x05,0x48,0x31,0xc0,0x48,0x83,0xc4,0x10,0xc3
code_stub_trace_emit_len = . - code_stub_trace_emit
pat_bin_head: .ascii "fn f0 (t0,t0)->t0 {\nb0:\n  v0 = arg 0 : t0\n  v1 = arg 1 : t0\n  v"
pat_bin_head_len = . - pat_bin_head
pat_bin_mid: .ascii " = "
pat_bin_mid_len = . - pat_bin_mid
pat_bin_tail_a: .ascii "v0 v1 : t0\n  ret v"
pat_bin_tail_a_len = . - pat_bin_tail_a
pat_bin_tail_a_swapped: .ascii "v1 v0 : t0\n  ret v"
pat_bin_tail_a_swapped_len = . - pat_bin_tail_a_swapped
pat_bin_tail_b: .ascii "\n}\n"
pat_bin_tail_b_len = . - pat_bin_tail_b
pat_icmp_head: .ascii "fn f0 (t0,t0)->t1 {\nb0:\n  v0 = arg 0 : t0\n  v1 = arg 1 : t0\n  v"
pat_icmp_head_len = . - pat_icmp_head
pat_icmp_mid: .ascii " = icmp.eq "
pat_icmp_mid_len = . - pat_icmp_mid
pat_icmp_tail_a: .ascii "v0 v1 : t1\n  ret v"
pat_icmp_tail_a_len = . - pat_icmp_tail_a
pat_icmp_tail_a_swapped: .ascii "v1 v0 : t1\n  ret v"
pat_icmp_tail_a_swapped_len = . - pat_icmp_tail_a_swapped
pat_icmp_tail_b: .ascii "\n}\n"
pat_icmp_tail_b_len = . - pat_icmp_tail_b
pat_cbr_head: .ascii "fn f0 (t0,t0)->t0 {\nb0:\n  v0 = arg 0 : t0\n  v1 = arg 1 : t0\n  v"
pat_cbr_head_len = . - pat_cbr_head
pat_cbr_mid: .ascii " = icmp.eq "
pat_cbr_mid_len = . - pat_cbr_mid
pat_cbr_tail_a: .ascii "v0 v1 : t1\n  cbr v"
pat_cbr_tail_a_len = . - pat_cbr_tail_a
pat_cbr_tail_a_swapped: .ascii "v1 v0 : t1\n  cbr v"
pat_cbr_tail_a_swapped_len = . - pat_cbr_tail_a_swapped
pat_cbr_tail_b: .ascii " b1 b2\nb1:\n  ret v0\nb2:\n  ret v1\n}\n"
pat_cbr_tail_b_len = . - pat_cbr_tail_b
pat_mem_head: .ascii "fn f0 (t0)->t0 {\nb0:\n  v"
pat_mem_head_len = . - pat_mem_head
pat_mem_mid_a: .ascii " = arg 0 : t0\n  v"
pat_mem_mid_a_len = . - pat_mem_mid_a
pat_mem_mid_b: .ascii " = alloca t0, 1 : t1\n  st v"
pat_mem_mid_b_len = . - pat_mem_mid_b
pat_mem_mid_c: .ascii " v"
pat_mem_mid_c_len = . - pat_mem_mid_c
pat_mem_mid_d: .ascii "\n  v"
pat_mem_mid_d_len = . - pat_mem_mid_d
pat_mem_mid_e: .ascii " = ld v"
pat_mem_mid_e_len = . - pat_mem_mid_e
pat_mem_mid_f: .ascii " : t0\n  ret v"
pat_mem_mid_f_len = . - pat_mem_mid_f
pat_mem_tail: .ascii "\n}\n"
pat_mem_tail_len = . - pat_mem_tail
pat_mem_gep_roundtrip: .ascii "fn f0 (t0)->t0 {\nb0:\n  v0 = arg 0 : t0\n  v1 = alloca t0, 1 : t1\n  st v1 v0\n  v2 = gep v1 0 : t1\n  v3 = ld v2 : t0\n  ret v3\n}\n"
pat_mem_gep_roundtrip_len = . - pat_mem_gep_roundtrip
pat_malloc_head: .ascii "fn f0 (t0)->t1 {\nb0:\n  v"
pat_malloc_head_len = . - pat_malloc_head
pat_malloc_mid_a: .ascii " = arg 0 : t0\n  v"
pat_malloc_mid_a_len = . - pat_malloc_mid_a
pat_malloc_mid_b: .ascii " = malloc v"
pat_malloc_mid_b_len = . - pat_malloc_mid_b
pat_malloc_mid_c: .ascii " : t1\n  ret v"
pat_malloc_mid_c_len = . - pat_malloc_mid_c
pat_malloc_tail: .ascii "\n}\n"
pat_malloc_tail_len = . - pat_malloc_tail
pat_free_head: .ascii "fn f0 (t1)->t0 {\nb0:\n  v"
pat_free_head_len = . - pat_free_head
pat_free_mid_a: .ascii " = arg 0 : t1\n  free v"
pat_free_mid_a_len = . - pat_free_mid_a
pat_free_mid_b: .ascii "\n  v"
pat_free_mid_b_len = . - pat_free_mid_b
pat_free_mid_c: .ascii " = const 0 : t0\n  ret v"
pat_free_mid_c_len = . - pat_free_mid_c
pat_free_tail: .ascii "\n}\n"
pat_free_tail_len = . - pat_free_tail
pat_exit_head: .ascii "fn f0 (t0)->t0 {\nb0:\n  v"
pat_exit_head_len = . - pat_exit_head
pat_exit_mid_a: .ascii " = arg 0 : t0\n  exit v"
pat_exit_mid_a_len = . - pat_exit_mid_a
pat_exit_mid_b: .ascii "\n  ret v"
pat_exit_mid_b_len = . - pat_exit_mid_b
pat_exit_tail: .ascii "\n}\n"
pat_exit_tail_len = . - pat_exit_tail
pat_write_head: .ascii "fn f0 ()->t0 {\nb0:\n  v"
pat_write_head_len = . - pat_write_head
pat_write_mid_a: .ascii " = alloca t0, 1 : t1\n  v"
pat_write_mid_a_len = . - pat_write_mid_a
pat_write_mid_b: .ascii " = const 10 : t0\n  st v"
pat_write_mid_b_len = . - pat_write_mid_b
pat_write_mid_c: .ascii " v"
pat_write_mid_c_len = . - pat_write_mid_c
pat_write_mid_d: .ascii "\n  v"
pat_write_mid_d_len = . - pat_write_mid_d
pat_write_mid_e: .ascii " = const 1 : t0\n  write v"
pat_write_mid_e_len = . - pat_write_mid_e
pat_write_mid_f: .ascii " v"
pat_write_mid_f_len = . - pat_write_mid_f
pat_write_mid_g: .ascii "\n  v"
pat_write_mid_g_len = . - pat_write_mid_g
pat_write_mid_h: .ascii " = const 0 : t0\n  ret v"
pat_write_mid_h_len = . - pat_write_mid_h
pat_write_tail: .ascii "\n}\n"
pat_write_tail_len = . - pat_write_tail
pat_trace_head: .ascii "fn f0 (t0)->t0 {\nb0:\n  v"
pat_trace_head_len = . - pat_trace_head
pat_trace_mid_a: .ascii " = arg 0 : t0\n  trace 1 v"
pat_trace_mid_a_len = . - pat_trace_mid_a
pat_trace_mid_b: .ascii "\n  v"
pat_trace_mid_b_len = . - pat_trace_mid_b
pat_trace_mid_c: .ascii " = const 0 : t0\n  ret v"
pat_trace_mid_c_len = . - pat_trace_mid_c
pat_trace_tail: .ascii "\n}\n"
pat_trace_tail_len = . - pat_trace_tail
pat_call_head: .ascii "fn f0 (t0,t0)->t0 {\nb0:\n  v0 = arg 0 : t0\n  v1 = arg 1 : t0\n  v"
pat_call_head_len = . - pat_call_head
pat_call_mid: .ascii " = call f1 "
pat_call_mid_len = . - pat_call_mid
pat_call_tail_a: .ascii "v0 v1 : t0\n  ret v"
pat_call_tail_a_len = . - pat_call_tail_a
pat_call_tail_a_swapped: .ascii "v1 v0 : t0\n  ret v"
pat_call_tail_a_swapped_len = . - pat_call_tail_a_swapped
pat_call_tail_b_add: .ascii "\n}\nfn f1 (t0,t0)->t0 {\nb0:\n  v0 = arg 0 : t0\n  v1 = arg 1 : t0\n  v2 = add.wrap v0 v1 : t0\n  ret v2\n}\n"
pat_call_tail_b_add_len = . - pat_call_tail_b_add
pat_call_tail_b_sub: .ascii "\n}\nfn f1 (t0,t0)->t0 {\nb0:\n  v0 = arg 0 : t0\n  v1 = arg 1 : t0\n  v2 = sub.wrap v0 v1 : t0\n  ret v2\n}\n"
pat_call_tail_b_sub_len = . - pat_call_tail_b_sub
pat_call_tail_b_mul: .ascii "\n}\nfn f1 (t0,t0)->t0 {\nb0:\n  v0 = arg 0 : t0\n  v1 = arg 1 : t0\n  v2 = mul.wrap v0 v1 : t0\n  ret v2\n}\n"
pat_call_tail_b_mul_len = . - pat_call_tail_b_mul
pat_const_head: .ascii "fn f0 ()->t0 {\nb0:\n  v"
pat_const_head_len = . - pat_const_head
pat_const_mid: .ascii " = const "
pat_const_mid_len = . - pat_const_mid
pat_const_tail_a: .ascii " : t0\n  ret v"
pat_const_tail_a_len = . - pat_const_tail_a
pat_const_tail_b: .ascii "\n}\n"
pat_const_tail_b_len = . - pat_const_tail_b
tok_add_wrap: .ascii "add.wrap"
tok_add_wrap_len = . - tok_add_wrap
tok_add_trap: .ascii "add.trap"
tok_add_trap_len = . - tok_add_trap
tok_sub_wrap: .ascii "sub.wrap"
tok_sub_wrap_len = . - tok_sub_wrap
tok_sub_trap: .ascii "sub.trap"
tok_sub_trap_len = . - tok_sub_trap
tok_mul_wrap: .ascii "mul.wrap"
tok_mul_wrap_len = . - tok_mul_wrap
tok_mul_trap: .ascii "mul.trap"
tok_mul_trap_len = . - tok_mul_trap
tok_and: .ascii "and"
tok_and_len = . - tok_and
tok_or: .ascii "or"
tok_or_len = . - tok_or
tok_xor: .ascii "xor"
tok_xor_len = . - tok_xor
tok_shl: .ascii "shl"
tok_shl_len = . - tok_shl
tok_shr: .ascii "shr"
tok_shr_len = . - tok_shr

.section .text
.global _start

_start:
    mov r12, rsp
    mov r13, [r12]            # argc
    cmp r13, 3
    jb usage

    mov r14, [r12+16]         # argv[1] command
    mov r15, [r12+24]         # argv[2] input path

    lea rsi, [rip+cmd_canon]
    mov rdi, r14
    call str_eq
    cmp rax, 1
    jne .check_verify
    cmp r13, 3
    je do_canon
    cmp r13, 5
    jne usage
    mov rdi, [r12+32]         # argv[3] should be "-o"
    lea rsi, [rip+flag_o]
    call str_eq
    cmp rax, 1
    jne usage
    mov r11, [r12+40]         # argv[4] output path
    mov qword ptr [rip+out_path_ptr], r11
    jmp do_canon_out

.check_verify:
    lea rsi, [rip+cmd_verify]
    mov rdi, r14
    call str_eq
    cmp rax, 1
    jne .check_build
    cmp r13, 3
    jne usage
    jmp do_verify

.check_build:
    lea rsi, [rip+cmd_build]
    mov rdi, r14
    call str_eq
    cmp rax, 1
    jne .check_imgcheck
    mov qword ptr [rip+trace_schema_out_path_ptr], 0
    mov qword ptr [rip+debug_map_out_path_ptr], 0
    cmp r13, 4
    je .build_positional
    cmp r13, 5
    je .build_flag_o_no_opt
    cmp r13, 6
    je .build_positional_with_opt
    cmp r13, 7
    je .build_flag_o_with_opt
    cmp r13, 8
    je .build_positional_two_opts
    cmp r13, 9
    je .build_flag_o_two_opts
    jne usage
.build_flag_o_no_opt:
    mov rdi, [r12+32]         # argv[3] should be "-o"
    lea rsi, [rip+flag_o]
    call str_eq
    cmp rax, 1
    jne usage
    mov r11, [r12+40]         # argv[4] output path
    mov qword ptr [rip+out_path_ptr], r11
    jmp do_build
.build_positional:
    mov r11, [r12+32]         # argv[3] output path
    mov qword ptr [rip+out_path_ptr], r11
    jmp do_build

.build_positional_with_opt:
    mov r11, [r12+32]         # argv[3] output path
    mov qword ptr [rip+out_path_ptr], r11
    mov rdi, [r12+40]         # argv[4] optional flag
    lea rsi, [rip+flag_trace_schema]
    call str_eq
    cmp rax, 1
    je .build_positional_set_schema
    mov rdi, [r12+40]
    lea rsi, [rip+flag_debug_map]
    call str_eq
    cmp rax, 1
    jne usage
    mov r11, [r12+48]         # argv[5] debug-map path
    mov qword ptr [rip+debug_map_out_path_ptr], r11
    jmp do_build
.build_positional_set_schema:
    mov r11, [r12+48]         # argv[5] schema path
    mov qword ptr [rip+trace_schema_out_path_ptr], r11
    jmp do_build

.build_flag_o_with_opt:
    mov rdi, [r12+32]         # argv[3] should be "-o"
    lea rsi, [rip+flag_o]
    call str_eq
    cmp rax, 1
    jne usage
    mov r11, [r12+40]         # argv[4] output path
    mov qword ptr [rip+out_path_ptr], r11
    mov rdi, [r12+48]         # argv[5] optional flag
    lea rsi, [rip+flag_trace_schema]
    call str_eq
    cmp rax, 1
    je .build_flag_o_set_schema
    mov rdi, [r12+48]
    lea rsi, [rip+flag_debug_map]
    call str_eq
    cmp rax, 1
    jne usage
    mov r11, [r12+56]         # argv[6] debug-map path
    mov qword ptr [rip+debug_map_out_path_ptr], r11
    jmp do_build
.build_flag_o_set_schema:
    mov r11, [r12+56]         # argv[6] schema path
    mov qword ptr [rip+trace_schema_out_path_ptr], r11
    jmp do_build

.build_positional_two_opts:
    mov r11, [r12+32]         # argv[3] output path
    mov qword ptr [rip+out_path_ptr], r11
    # option pair 1: argv[4] flag, argv[5] path
    mov rdi, [r12+40]
    lea rsi, [rip+flag_trace_schema]
    call str_eq
    cmp rax, 1
    je .build_pos_two_set_schema_1
    mov rdi, [r12+40]
    lea rsi, [rip+flag_debug_map]
    call str_eq
    cmp rax, 1
    jne usage
    mov r11, [r12+48]
    mov qword ptr [rip+debug_map_out_path_ptr], r11
    jmp .build_pos_two_pair2
.build_pos_two_set_schema_1:
    cmp qword ptr [rip+trace_schema_out_path_ptr], 0
    jne usage
    mov r11, [r12+48]
    mov qword ptr [rip+trace_schema_out_path_ptr], r11
.build_pos_two_pair2:
    # option pair 2: argv[6] flag, argv[7] path
    mov rdi, [r12+56]
    lea rsi, [rip+flag_trace_schema]
    call str_eq
    cmp rax, 1
    je .build_pos_two_set_schema_2
    mov rdi, [r12+56]
    lea rsi, [rip+flag_debug_map]
    call str_eq
    cmp rax, 1
    jne usage
    cmp qword ptr [rip+debug_map_out_path_ptr], 0
    jne usage
    mov r11, [r12+64]
    mov qword ptr [rip+debug_map_out_path_ptr], r11
    jmp do_build
.build_pos_two_set_schema_2:
    cmp qword ptr [rip+trace_schema_out_path_ptr], 0
    jne usage
    mov r11, [r12+64]
    mov qword ptr [rip+trace_schema_out_path_ptr], r11
    jmp do_build

.build_flag_o_two_opts:
    mov rdi, [r12+32]         # argv[3] should be "-o"
    lea rsi, [rip+flag_o]
    call str_eq
    cmp rax, 1
    jne usage
    mov r11, [r12+40]         # argv[4] output path
    mov qword ptr [rip+out_path_ptr], r11
    # option pair 1: argv[5] flag, argv[6] path
    mov rdi, [r12+48]
    lea rsi, [rip+flag_trace_schema]
    call str_eq
    cmp rax, 1
    je .build_flag_two_set_schema_1
    mov rdi, [r12+48]
    lea rsi, [rip+flag_debug_map]
    call str_eq
    cmp rax, 1
    jne usage
    mov r11, [r12+56]
    mov qword ptr [rip+debug_map_out_path_ptr], r11
    jmp .build_flag_two_pair2
.build_flag_two_set_schema_1:
    cmp qword ptr [rip+trace_schema_out_path_ptr], 0
    jne usage
    mov r11, [r12+56]
    mov qword ptr [rip+trace_schema_out_path_ptr], r11
.build_flag_two_pair2:
    # option pair 2: argv[7] flag, argv[8] path
    mov rdi, [r12+64]
    lea rsi, [rip+flag_trace_schema]
    call str_eq
    cmp rax, 1
    je .build_flag_two_set_schema_2
    mov rdi, [r12+64]
    lea rsi, [rip+flag_debug_map]
    call str_eq
    cmp rax, 1
    jne usage
    cmp qword ptr [rip+debug_map_out_path_ptr], 0
    jne usage
    mov r11, [r12+72]
    mov qword ptr [rip+debug_map_out_path_ptr], r11
    jmp do_build
.build_flag_two_set_schema_2:
    cmp qword ptr [rip+trace_schema_out_path_ptr], 0
    jne usage
    mov r11, [r12+72]
    mov qword ptr [rip+trace_schema_out_path_ptr], r11
    jmp do_build

.check_imgcheck:
    lea rsi, [rip+cmd_imgcheck]
    mov rdi, r14
    call str_eq
    cmp rax, 1
    jne .check_imgmeta
    cmp r13, 3
    jne usage
    jmp do_imgcheck

.check_imgmeta:
    lea rsi, [rip+cmd_imgmeta]
    mov rdi, r14
    call str_eq
    cmp rax, 1
    jne .check_run
    cmp r13, 3
    jne usage
    jmp do_imgmeta

.check_run:
    lea rsi, [rip+cmd_run]
    mov rdi, r14
    call str_eq
    cmp rax, 1
    jne .check_tracecat
    cmp r13, 3
    jb usage
    cmp r13, 5
    ja usage
    mov qword ptr [rip+run_arg1_ptr], 0
    mov qword ptr [rip+run_arg2_ptr], 0
    cmp r13, 4
    jb .run_dispatch_done
    mov r11, [r12+32]
    mov qword ptr [rip+run_arg1_ptr], r11
    cmp r13, 5
    jb .run_dispatch_done
    mov r11, [r12+40]
    mov qword ptr [rip+run_arg2_ptr], r11
.run_dispatch_done:
    jmp do_run

.check_tracecat:
    lea rsi, [rip+cmd_tracecat]
    mov rdi, r14
    call str_eq
    cmp rax, 1
    jne .check_mapcat
    cmp r13, 3
    jne usage
    jmp do_tracecat

.check_mapcat:
    lea rsi, [rip+cmd_mapcat]
    mov rdi, r14
    call str_eq
    cmp rax, 1
    jne .check_schemacat
    cmp r13, 3
    jne usage
    jmp do_mapcat

.check_schemacat:
    lea rsi, [rip+cmd_schemacat]
    mov rdi, r14
    call str_eq
    cmp rax, 1
    jne .check_tracejoin
    cmp r13, 3
    jne usage
    jmp do_schemacat

.check_tracejoin:
    lea rsi, [rip+cmd_tracejoin]
    mov rdi, r14
    call str_eq
    cmp rax, 1
    jne usage
    cmp r13, 4
    jne usage
    mov r11, [r12+32]         # argv[3] debug_map path
    mov qword ptr [rip+tracejoin_map_path_ptr], r11
    jmp do_tracejoin

usage:
    lea rsi, [rip+usage_msg]
    mov rdx, usage_len
    mov rdi, 2
    call write_fd
    mov rdi, 2
    call exit

do_canon:
    mov rdi, r15
    call load_file
    cmp rax, 0
    jl fail_io
    mov rbx, rax               # size
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call validate_module
    cmp rax, 1
    jne fail_parse

    lea rsi, [rip+file_buf]
    mov rdx, rbx
    mov rdi, 1
    call write_fd
    mov rdi, 0
    call exit

do_canon_out:
    mov rdi, r15
    call load_file
    cmp rax, 0
    jl fail_io
    mov rbx, rax               # size
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call validate_module
    cmp rax, 1
    jne fail_parse

    mov rdi, qword ptr [rip+out_path_ptr]
    mov rax, 2                 # sys_open
    mov rsi, 577               # O_WRONLY|O_CREAT|O_TRUNC
    mov rdx, 420               # 0644
    syscall
    test rax, rax
    js fail_build
    mov r10, rax               # out fd

    mov rdi, r10
    lea rsi, [rip+file_buf]
    mov rdx, rbx
    call write_all
    cmp rax, 0
    jne .canon_out_fail

    mov rdi, r10
    mov rax, 3                 # sys_close
    syscall
    lea rsi, [rip+ok_msg]
    mov rdx, ok_len
    mov rdi, 1
    call write_fd
    mov rdi, 0
    call exit
.canon_out_fail:
    mov rdi, r10
    mov rax, 3
    syscall
    jmp fail_build

do_verify:
    mov rdi, r15
    call load_file
    cmp rax, 0
    jl fail_io
    mov rbx, rax
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call validate_module
    cmp rax, 1
    jne fail_parse

    lea rsi, [rip+ok_msg]
    mov rdx, ok_len
    mov rdi, 1
    call write_fd
    mov rdi, 0
    call exit

do_build:
    mov rdi, r15
    call load_file
    cmp rax, 0
    jl fail_io
    mov rbx, rax
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call validate_module
    cmp rax, 1
    jne fail_parse

    # select bootstrap code payload:
    # - canonical arg2 binary kernel lowering for supported ops
    # - canonical call->{add,sub,mul}.wrap two-function kernel lowering
    # - canonical malloc/free/exit/write/trace intrinsic kernel lowering
    # - canonical alloca+st+ld memory roundtrip kernel lowering
    # - canonical icmp.eq + cbr select kernel lowering
    # - canonical icmp.eq kernel lowering
    # - canonical const-return kernel lowering
    # - otherwise 1-byte ret stub fallback
    lea r14, [rip+code_stub_ret]
    mov r15, code_stub_ret_len
    mov qword ptr [rip+build_kernel_kind], 0
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call try_select_trace_noop_kernel_code
    cmp rax, 1
    jne .build_try_write_newline
    jmp .build_code_selected

.build_try_write_newline:
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call try_select_write_newline_kernel_code
    cmp rax, 1
    jne .build_try_exit
    jmp .build_code_selected

.build_try_exit:
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call try_select_exit_kernel_code
    cmp rax, 1
    jne .build_try_malloc
    jmp .build_code_selected

.build_try_malloc:
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call try_select_malloc_kernel_code
    cmp rax, 1
    jne .build_try_free_noop
    jmp .build_code_selected

.build_try_free_noop:
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call try_select_free_noop_kernel_code
    cmp rax, 1
    jne .build_try_call_sub
    jmp .build_code_selected

.build_try_call_sub:
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call try_select_call_kernel_code
    cmp rax, 1
    jne .build_try_mem_gep_roundtrip
    jmp .build_code_selected

.build_try_mem_gep_roundtrip:
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    lea rdx, [rip+pat_mem_gep_roundtrip]
    mov rcx, pat_mem_gep_roundtrip_len
    call find_substr
    cmp rax, 1
    jne .build_try_mem_roundtrip
    lea r14, [rip+code_stub_mem_roundtrip]
    mov r15, code_stub_mem_roundtrip_len
    mov qword ptr [rip+build_kernel_kind], 19
    jmp .build_code_selected

.build_try_mem_roundtrip:
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call try_select_mem_roundtrip_kernel_code
    cmp rax, 1
    jne .build_try_cbr_eq_select
    jmp .build_code_selected

.build_try_cbr_eq_select:
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call try_select_cbr_eq_select_kernel_code
    cmp rax, 1
    jne .build_try_icmp_eq
    jmp .build_code_selected

.build_try_icmp_eq:
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call try_select_icmp_eq_kernel_code
    cmp rax, 1
    jne .build_try_bin_kernel
    jmp .build_code_selected

.build_try_bin_kernel:
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call try_select_bin_kernel_code
    cmp rax, 1
    jne .build_try_const_kernel
    jmp .build_code_selected

.build_try_const_kernel:
    lea rdi, [rip+file_buf]
    mov rsi, rbx
    call try_select_const_kernel_code
    cmp rax, 1
    jne .build_code_selected
    lea r14, [rip+codegen_buf]
    mov r15, qword ptr [rip+codegen_len]
    mov qword ptr [rip+build_kernel_kind], 13
.build_code_selected:

    # open output path argv[3]
    mov rdi, qword ptr [rip+out_path_ptr]
    mov rax, 2                 # sys_open
    mov rsi, 577               # O_WRONLY|O_CREAT|O_TRUNC
    mov rdx, 420               # 0644
    syscall
    test rax, rax
    js fail_build
    mov r10, rax               # out fd

    # Build structured 80-byte L0IMG header in-memory.
    # Also emit a bootstrap code stub and 64-byte debug semantic index (L0IX).
    # qword[0]  = magic "L0IM"
    # qword[1]  = version
    # qword[2]  = header size
    # qword[3]  = flags
    # qword[4]  = src offset
    # qword[5]  = src size
    # qword[6]  = code offset (after source payload)
    # qword[7]  = code size   (bootstrap-selected payload size)
    # qword[8]  = debug offset (after code payload)
    # qword[9]  = debug size   (64 in bootstrap)
    mov r8, img_header_len
    add r8, rbx                 # code_off
    mov r9, r8
    add r9, r15                 # debug_off
    lea r11, [rip+img_header_buf]
    mov rax, 0x000000004d49304c
    mov qword ptr [r11+0], rax
    mov qword ptr [r11+8], 1
    mov qword ptr [r11+16], img_header_len
    mov qword ptr [r11+24], 0
    mov qword ptr [r11+32], img_header_len
    mov qword ptr [r11+40], rbx
    mov qword ptr [r11+48], r8
    mov qword ptr [r11+56], r15
    mov qword ptr [r11+64], r9
    mov qword ptr [r11+72], 64

    # Build debug semantic index qwords:
    # [0]=magic "L0IX" [1]=version [2]=fn_count [3]=type_count
    # [4]=kernel_kind [5]=code_size [6]=trace_schema_ver [7]=trace_record_size
    lea r11, [rip+img_debug_idx_buf]
    mov rax, 0x000000005849304c
    mov qword ptr [r11+0], rax
    mov qword ptr [r11+8], 1
    mov rax, qword ptr [rip+vfp_last_fn_id]
    inc rax
    mov qword ptr [r11+16], rax
    mov rax, qword ptr [rip+vfp_type_count]
    mov qword ptr [r11+24], rax
    mov rax, qword ptr [rip+build_kernel_kind]
    mov qword ptr [r11+32], rax
    mov qword ptr [r11+40], r15
    mov qword ptr [r11+48], 1
    mov qword ptr [r11+56], 16

    mov rdi, r10
    lea rsi, [rip+img_header_buf]
    mov rdx, img_header_len
    call write_all
    cmp rax, 0
    jne .build_write_fail

    mov rdi, r10
    lea rsi, [rip+file_buf]
    mov rdx, rbx
    call write_all
    cmp rax, 0
    jne .build_write_fail

    mov rdi, r10
    mov rsi, r14
    mov rdx, r15
    call write_all
    cmp rax, 0
    jne .build_write_fail

    mov rdi, r10
    lea rsi, [rip+img_debug_idx_buf]
    mov rdx, 64
    call write_all
    cmp rax, 0
    jne .build_write_fail

    mov rdi, r10
    mov rax, 3                 # sys_close
    syscall

    mov r11, qword ptr [rip+trace_schema_out_path_ptr]
    cmp r11, 0
    je .build_try_debug_map
    mov rdi, r11
    mov rax, 2                 # sys_open
    mov rsi, 577               # O_WRONLY|O_CREAT|O_TRUNC
    mov rdx, 420               # 0644
    syscall
    test rax, rax
    js fail_build
    mov r10, rax
    mov qword ptr [rip+debug_map_fd], r10
    lea r11, [rip+trace_schema_buf]
    mov rax, 0x000000005354304c
    mov qword ptr [r11+0], rax
    mov qword ptr [r11+8], 1
    mov qword ptr [r11+16], 16
    mov qword ptr [r11+24], 2
    mov rdi, r10
    lea rsi, [rip+trace_schema_buf]
    mov rdx, 32
    call write_all
    cmp rax, 0
    jne .build_write_schema_fail
    mov rdi, r10
    mov rax, 3
    syscall

.build_try_debug_map:
    mov r11, qword ptr [rip+debug_map_out_path_ptr]
    cmp r11, 0
    je .build_emit_ok
    mov rdi, r11
    mov rax, 2                 # sys_open
    mov rsi, 577               # O_WRONLY|O_CREAT|O_TRUNC
    mov rdx, 420               # 0644
    syscall
    test rax, rax
    js fail_build
    mov r10, rax
    mov qword ptr [rip+debug_map_fd], r10
    lea r11, [rip+debug_map_buf]
    mov rax, 0x000000004d44304c
    mov qword ptr [r11+0], rax
    mov qword ptr [r11+8], 2
    mov rax, qword ptr [rip+build_kernel_kind]
    cmp rax, 0
    je .build_dbg_map_case_single_full
    cmp rax, 13
    je .build_dbg_map_case_single_full
    cmp rax, 1
    je .build_dbg_map_case_three_3_6
    cmp rax, 3
    je .build_dbg_map_case_three_3_6
    cmp rax, 6
    je .build_dbg_map_case_three_3_6
    cmp rax, 7
    je .build_dbg_map_case_three_3_6
    cmp rax, 8
    je .build_dbg_map_case_three_3_6
    cmp rax, 16
    je .build_dbg_map_case_three_3_6
    cmp rax, 17
    je .build_dbg_map_case_three_3_6
    cmp rax, 5
    je .build_dbg_map_case_three_3_7
    cmp rax, 18
    je .build_dbg_map_case_three_3_7
    cmp rax, 2
    je .build_dbg_map_case_four_3_6_9
    cmp rax, 4
    je .build_dbg_map_case_four_3_6_9
    cmp rax, 15
    je .build_dbg_map_case_four_3_7_10
    cmp rax, 9
    je .build_dbg_map_case_four_3_6_9
    cmp rax, 10
    je .build_dbg_map_case_four_3_6_9
    cmp rax, 11
    je .build_dbg_map_case_four_2_5_8
    cmp rax, 12
    je .build_dbg_map_case_four_3_6_10
    cmp rax, 14
    je .build_dbg_map_case_five_4_8_12_16
    cmp rax, 19
    je .build_dbg_map_case_five_4_8_12_16
    cmp rax, 20
    je .build_dbg_map_case_four_6_20_34
    cmp rax, 21
    je .build_dbg_map_case_two_3
    cmp rax, 22
    je .build_dbg_map_case_four_12_38_45
    cmp rax, 23
    je .build_dbg_map_case_two_7
    cmp rax, 24
    je .build_dbg_map_case_two_17
    jmp .build_dbg_map_case_synth

.build_dbg_map_case_single_full:
    mov r12, 1
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_two_3:
    mov r12, 2
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], 3
    mov qword ptr [r11+56], 2
    mov qword ptr [r11+64], 3
    mov qword ptr [r11+72], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_two_7:
    mov r12, 2
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], 7
    mov qword ptr [r11+56], 2
    mov qword ptr [r11+64], 7
    mov qword ptr [r11+72], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_two_17:
    mov r12, 2
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], 17
    mov qword ptr [r11+56], 2
    mov qword ptr [r11+64], 17
    mov qword ptr [r11+72], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_three_3_6:
    mov r12, 3
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], 3
    mov qword ptr [r11+56], 2
    mov qword ptr [r11+64], 3
    mov qword ptr [r11+72], 6
    mov qword ptr [r11+80], 3
    mov qword ptr [r11+88], 6
    mov qword ptr [r11+96], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_three_3_7:
    mov r12, 3
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], 3
    mov qword ptr [r11+56], 2
    mov qword ptr [r11+64], 3
    mov qword ptr [r11+72], 7
    mov qword ptr [r11+80], 3
    mov qword ptr [r11+88], 7
    mov qword ptr [r11+96], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_four_3_6_9:
    mov r12, 4
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], 3
    mov qword ptr [r11+56], 2
    mov qword ptr [r11+64], 3
    mov qword ptr [r11+72], 6
    mov qword ptr [r11+80], 3
    mov qword ptr [r11+88], 6
    mov qword ptr [r11+96], 9
    mov qword ptr [r11+104], 4
    mov qword ptr [r11+112], 9
    mov qword ptr [r11+120], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_four_3_7_10:
    mov r12, 4
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], 3
    mov qword ptr [r11+56], 2
    mov qword ptr [r11+64], 3
    mov qword ptr [r11+72], 7
    mov qword ptr [r11+80], 3
    mov qword ptr [r11+88], 7
    mov qword ptr [r11+96], 10
    mov qword ptr [r11+104], 4
    mov qword ptr [r11+112], 10
    mov qword ptr [r11+120], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_four_2_5_8:
    mov r12, 4
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], 2
    mov qword ptr [r11+56], 2
    mov qword ptr [r11+64], 2
    mov qword ptr [r11+72], 5
    mov qword ptr [r11+80], 3
    mov qword ptr [r11+88], 5
    mov qword ptr [r11+96], 8
    mov qword ptr [r11+104], 4
    mov qword ptr [r11+112], 8
    mov qword ptr [r11+120], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_four_3_6_10:
    mov r12, 4
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], 3
    mov qword ptr [r11+56], 2
    mov qword ptr [r11+64], 3
    mov qword ptr [r11+72], 6
    mov qword ptr [r11+80], 3
    mov qword ptr [r11+88], 6
    mov qword ptr [r11+96], 10
    mov qword ptr [r11+104], 4
    mov qword ptr [r11+112], 10
    mov qword ptr [r11+120], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_four_6_20_34:
    mov r12, 4
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], 6
    mov qword ptr [r11+56], 2
    mov qword ptr [r11+64], 6
    mov qword ptr [r11+72], 20
    mov qword ptr [r11+80], 3
    mov qword ptr [r11+88], 20
    mov qword ptr [r11+96], 34
    mov qword ptr [r11+104], 4
    mov qword ptr [r11+112], 34
    mov qword ptr [r11+120], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_four_12_38_45:
    mov r12, 4
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], 12
    mov qword ptr [r11+56], 2
    mov qword ptr [r11+64], 12
    mov qword ptr [r11+72], 38
    mov qword ptr [r11+80], 3
    mov qword ptr [r11+88], 38
    mov qword ptr [r11+96], 45
    mov qword ptr [r11+104], 4
    mov qword ptr [r11+112], 45
    mov qword ptr [r11+120], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_five_4_8_12_16:
    mov r12, 5
    mov qword ptr [r11+32], 1
    mov qword ptr [r11+40], 0
    mov qword ptr [r11+48], 4
    mov qword ptr [r11+56], 2
    mov qword ptr [r11+64], 4
    mov qword ptr [r11+72], 8
    mov qword ptr [r11+80], 3
    mov qword ptr [r11+88], 8
    mov qword ptr [r11+96], 12
    mov qword ptr [r11+104], 4
    mov qword ptr [r11+112], 12
    mov qword ptr [r11+120], 16
    mov qword ptr [r11+128], 5
    mov qword ptr [r11+136], 16
    mov qword ptr [r11+144], r15
    jmp .build_dbg_map_finish

.build_dbg_map_case_synth:
    mov r12, 3
    mov rax, r15
    xor rdx, rdx
    div r12
    mov r13, rax                # per-entry base segment size
    mov r14, rdx                # remainder for last segment
    xor r8, r8                  # start offset
    mov r9, 1                   # synthetic inst_id starts at 1
    xor rcx, rcx                # entry index
.build_dbg_map_loop:
    cmp rcx, r12
    jae .build_dbg_map_finish
    mov rax, r13
    mov rbx, r12
    dec rbx
    cmp rcx, rbx
    jne .build_dbg_map_no_rem
    add rax, r14
.build_dbg_map_no_rem:
    mov r10, r8
    add r10, rax                # end offset
    mov rdx, rcx
    imul rdx, 24
    add rdx, 32
    mov qword ptr [r11+rdx+0], r9
    mov qword ptr [r11+rdx+8], r8
    mov qword ptr [r11+rdx+16], r10
    mov r8, r10
    inc r9
    inc rcx
    jmp .build_dbg_map_loop

.build_dbg_map_finish:
    # Clamp all emitted ranges to [0, code_size] and enforce start <= end.
    xor rcx, rcx
.build_dbg_map_clamp_loop:
    cmp rcx, r12
    jae .build_dbg_map_header
    mov rdx, rcx
    imul rdx, 24
    add rdx, 32
    mov rax, qword ptr [r11+rdx+8]   # start
    cmp rax, r15
    jbe .build_dbg_map_start_ok
    mov rax, r15
.build_dbg_map_start_ok:
    mov qword ptr [r11+rdx+8], rax
    mov r8, qword ptr [r11+rdx+16]   # end
    cmp r8, r15
    jbe .build_dbg_map_end_bound_ok
    mov r8, r15
.build_dbg_map_end_bound_ok:
    cmp r8, rax
    jae .build_dbg_map_end_ok
    mov r8, rax
.build_dbg_map_end_ok:
    mov qword ptr [r11+rdx+16], r8
    inc rcx
    jmp .build_dbg_map_clamp_loop

.build_dbg_map_header:
    mov qword ptr [r11+16], r12
    mov qword ptr [r11+24], r15
    mov rax, r12
    imul rax, 24
    add rax, 32
    mov qword ptr [rip+debug_map_size], rax
    mov rdi, qword ptr [rip+debug_map_fd]
    lea rsi, [rip+debug_map_buf]
    mov rdx, qword ptr [rip+debug_map_size]
    call write_all
    cmp rax, 0
    jne .build_write_debug_map_fail
    mov rdi, qword ptr [rip+debug_map_fd]
    mov rax, 3
    syscall

.build_emit_ok:
    lea rsi, [rip+ok_msg]
    mov rdx, ok_len
    mov rdi, 1
    call write_fd
    mov rdi, 0
    call exit

.build_write_schema_fail:
    mov rdi, r10
    mov rax, 3
    syscall
    jmp fail_build

.build_write_debug_map_fail:
    mov rdi, qword ptr [rip+debug_map_fd]
    mov rax, 3
    syscall
    jmp fail_build

.build_write_fail:
    mov rdi, r10
    mov rax, 3
    syscall
    jmp fail_build

do_imgcheck:
    mov rdi, r15
    call load_file
    cmp rax, 0
    jl fail_io
    mov rbx, rax
    cmp rbx, img_header_len
    jb fail_img

    lea r8, [rip+file_buf]
    mov rax, qword ptr [r8+0]
    mov r9, 0x000000004d49304c
    cmp rax, r9
    jne fail_img
    mov rax, qword ptr [r8+8]     # version
    cmp rax, 1
    jne fail_img
    mov rax, qword ptr [r8+16]    # header_size
    cmp rax, img_header_len
    jne fail_img
    mov rax, qword ptr [r8+24]    # flags (bootstrap: must be zero)
    cmp rax, 0
    jne fail_img
    mov r10, qword ptr [r8+16]    # header_size
    mov r11, qword ptr [r8+32]    # src_off
    cmp r11, r10
    jb fail_img
    cmp r11, rbx
    ja fail_img
    mov rax, qword ptr [r8+40]    # src_size
    add rax, r11
    jc fail_img
    cmp rax, rbx
    ja fail_img

    # code section (allow zero/zero in bootstrap)
    mov r12, qword ptr [r8+48]    # code_off
    mov r13, qword ptr [r8+56]    # code_size
    cmp r12, 0
    jne .img_chk_code_nonzero
    cmp r13, 0
    jne fail_img
    jmp .img_chk_debug
.img_chk_code_nonzero:
    cmp r13, 0
    je fail_img
    cmp r12, r10
    jb fail_img
    cmp r12, rbx
    ja fail_img
    mov rax, r12
    add rax, r13
    jc fail_img
    cmp rax, rbx
    ja fail_img

.img_chk_debug:
    mov r12, qword ptr [r8+64]    # debug_off
    mov r13, qword ptr [r8+72]    # debug_size
    cmp r12, 0
    jne .img_chk_debug_nonzero
    cmp r13, 0
    jne fail_img
    jmp .img_ok
.img_chk_debug_nonzero:
    cmp r13, 0
    je fail_img
    cmp r13, 64
    jne fail_img
    cmp r12, r10
    jb fail_img
    cmp r12, rbx
    ja fail_img
    mov rax, r12
    add rax, r13
    jc fail_img
    cmp rax, rbx
    ja fail_img
    # validate debug payload qwords for bootstrap schema
    mov rax, qword ptr [r8+72]    # debug_size
    cmp rax, 64
    jne fail_img
    mov r9, qword ptr [r8+64]     # debug_off
    mov rax, qword ptr [r8+r9+0]  # L0IX magic
    mov r11, 0x000000005849304c
    cmp rax, r11
    jne fail_img
    mov rax, qword ptr [r8+r9+8]  # L0IX version
    cmp rax, 1
    jne fail_img
    # L0IX kernel kind id must be within known bootstrap range [0,24]
    mov rax, qword ptr [r8+r9+32]
    cmp rax, 24
    ja fail_img
    # L0IX code_size must match header code_size
    mov rax, qword ptr [r8+r9+40]
    cmp rax, qword ptr [r8+56]
    jne fail_img
    mov rax, qword ptr [r8+r9+48]
    cmp rax, 1
    jne fail_img
    mov rax, qword ptr [r8+r9+56]
    cmp rax, 16
    jne fail_img

.img_ok:

    lea rsi, [rip+ok_msg]
    mov rdx, ok_len
    mov rdi, 1
    call write_fd
    mov rdi, 0
    call exit

do_imgmeta:
    mov rdi, r15
    call load_file
    cmp rax, 0
    jl fail_io
    mov rbx, rax
    cmp rbx, img_header_len
    jb fail_img

    lea r8, [rip+file_buf]
    mov rax, qword ptr [r8+0]
    mov r9, 0x000000004d49304c
    cmp rax, r9
    jne fail_img
    mov rax, qword ptr [r8+8]     # version
    cmp rax, 1
    jne fail_img
    mov rax, qword ptr [r8+16]    # header_size
    cmp rax, img_header_len
    jne fail_img
    mov rax, qword ptr [r8+24]    # flags
    cmp rax, 0
    jne fail_img

    mov r10, qword ptr [r8+16]    # header_size
    mov r11, qword ptr [r8+32]    # src_off
    cmp r11, r10
    jb fail_img
    cmp r11, rbx
    ja fail_img
    mov rax, qword ptr [r8+40]    # src_size
    add rax, r11
    jc fail_img
    cmp rax, rbx
    ja fail_img

    mov r12, qword ptr [r8+48]    # code_off
    mov r13, qword ptr [r8+56]    # code_size
    cmp r12, 0
    je fail_img
    cmp r13, 0
    je fail_img
    cmp r12, r10
    jb fail_img
    cmp r12, rbx
    ja fail_img
    mov rax, r12
    add rax, r13
    jc fail_img
    cmp rax, rbx
    ja fail_img

    mov r12, qword ptr [r8+64]    # debug_off
    mov r13, qword ptr [r8+72]    # debug_size
    cmp r12, 0
    je fail_img
    cmp r13, 64
    jne fail_img
    cmp r12, r10
    jb fail_img
    cmp r12, rbx
    ja fail_img
    mov rax, r12
    add rax, r13
    jc fail_img
    cmp rax, rbx
    ja fail_img

    mov r9, qword ptr [r8+64]     # debug_off
    mov rax, qword ptr [r8+r9+0]
    mov r11, 0x000000005849304c
    cmp rax, r11
    jne fail_img
    mov rax, qword ptr [r8+r9+8]
    cmp rax, 1
    jne fail_img
    mov rax, qword ptr [r8+r9+32]  # kernel kind
    cmp rax, 24
    ja fail_img
    mov rax, qword ptr [r8+r9+40]  # debug code_size
    cmp rax, qword ptr [r8+56]
    jne fail_img
    mov rax, qword ptr [r8+r9+48]  # trace schema ver
    cmp rax, 1
    jne fail_img
    mov rax, qword ptr [r8+r9+56]  # trace record size
    cmp rax, 16
    jne fail_img

    mov rdi, 1
    lea rsi, [rip+img_version_prefix]
    mov rdx, img_version_prefix_len
    call write_fd
    mov rdi, qword ptr [r8+8]
    call print_u64_nl

    mov rdi, 1
    lea rsi, [rip+img_src_size_prefix]
    mov rdx, img_src_size_prefix_len
    call write_fd
    mov rdi, qword ptr [r8+40]
    call print_u64_nl

    mov rdi, 1
    lea rsi, [rip+img_code_size_prefix]
    mov rdx, img_code_size_prefix_len
    call write_fd
    mov rdi, qword ptr [r8+56]
    call print_u64_nl

    mov rdi, 1
    lea rsi, [rip+img_fn_count_prefix]
    mov rdx, img_fn_count_prefix_len
    call write_fd
    mov rdi, qword ptr [r8+r9+16]
    call print_u64_nl

    mov rdi, 1
    lea rsi, [rip+img_type_count_prefix]
    mov rdx, img_type_count_prefix_len
    call write_fd
    mov rdi, qword ptr [r8+r9+24]
    call print_u64_nl

    mov rdi, 1
    lea rsi, [rip+img_kernel_kind_prefix]
    mov rdx, img_kernel_kind_prefix_len
    call write_fd
    mov rdi, qword ptr [r8+r9+32]
    call print_u64_nl

    mov rdi, 1
    lea rsi, [rip+img_trace_schema_ver_prefix]
    mov rdx, img_trace_schema_ver_prefix_len
    call write_fd
    mov rdi, qword ptr [r8+r9+48]
    call print_u64_nl

    mov rdi, 1
    lea rsi, [rip+img_trace_record_size_prefix]
    mov rdx, img_trace_record_size_prefix_len
    call write_fd
    mov rdi, qword ptr [r8+r9+56]
    call print_u64_nl

    mov rdi, 0
    call exit

do_run:
    mov rdi, r15
    call load_file
    cmp rax, 0
    jl fail_io
    mov rbx, rax
    cmp rbx, img_header_len
    jb fail_img

    lea r8, [rip+file_buf]
    mov rax, qword ptr [r8+0]
    mov r9, 0x000000004d49304c
    cmp rax, r9
    jne fail_img
    mov rax, qword ptr [r8+8]     # version
    cmp rax, 1
    jne fail_img
    mov rax, qword ptr [r8+16]    # header_size
    cmp rax, img_header_len
    jne fail_img

    mov r10, qword ptr [r8+16]    # header_size
    mov r12, qword ptr [r8+48]    # code_off
    mov r13, qword ptr [r8+56]    # code_size
    cmp r12, 0
    je fail_img
    cmp r13, 0
    je fail_img
    cmp r12, r10
    jb fail_img
    cmp r12, rbx
    ja fail_img
    mov rax, r12
    add rax, r13
    jc fail_img
    cmp rax, rbx
    ja fail_img

    # mmap executable code buffer
    mov rax, 9                    # sys_mmap
    xor rdi, rdi                  # addr = NULL
    mov rsi, r13                  # len = code_size
    mov rdx, 7                    # PROT_READ|PROT_WRITE|PROT_EXEC
    mov r10, 34                   # MAP_PRIVATE|MAP_ANONYMOUS
    mov r8, -1                    # fd
    xor r9, r9                    # offset
    syscall
    test rax, rax
    js fail_run
    mov r11, rax                  # exec buffer
    mov rbx, r11

    # copy image code section into executable buffer
    lea rsi, [rip+file_buf]
    add rsi, r12
    mov rdi, r11
    mov rcx, r13
    rep movsb

    xor r14, r14                  # run arg a default
    xor r15, r15                  # run arg b default

    mov rdi, qword ptr [rip+run_arg1_ptr]
    cmp rdi, 0
    je .run_arg2
    call parse_u64_cstr
    cmp rdx, 1
    jne fail_run_arg
    mov r14, rax

.run_arg2:
    mov rdi, qword ptr [rip+run_arg2_ptr]
    cmp rdi, 0
    je .run_call
    call parse_u64_cstr
    cmp rdx, 1
    jne fail_run_arg
    mov r15, rax

.run_call:
    mov rdi, r14
    mov rsi, r15
    call rbx

    mov rdi, rax
    call print_u64_nl
    mov rdi, 0
    call exit

do_tracecat:
    mov rdi, r15
    call load_file
    cmp rax, 0
    jl fail_io
    mov rbx, rax
    mov rax, rbx
    and rax, 15
    cmp rax, 0
    jne fail_parse
    xor r12, r12
.tracecat_loop:
    cmp r12, rbx
    jae .tracecat_done
    mov rdi, 1
    lea rsi, [rip+trace_id_prefix]
    mov rdx, trace_id_prefix_len
    call write_fd
    lea r8, [rip+file_buf]
    add r8, r12
    mov rdi, qword ptr [r8+0]
    call print_u64_nl
    mov rdi, 1
    lea rsi, [rip+trace_val_prefix]
    mov rdx, trace_val_prefix_len
    call write_fd
    mov rdi, qword ptr [r8+8]
    call print_u64_nl
    add r12, 16
    jmp .tracecat_loop
.tracecat_done:
    mov rdi, 0
    call exit

do_mapcat:
    mov rdi, r15
    call load_file
    cmp rax, 0
    jl fail_io
    mov rbx, rax
    cmp rbx, 32
    jb fail_parse
    mov rax, rbx
    sub rax, 32
    xor rdx, rdx
    mov rcx, 24
    div rcx
    cmp rdx, 0
    jne fail_parse
    lea r8, [rip+file_buf]
    mov r12, r8
    mov rax, qword ptr [r12+0]
    mov r9, 0x000000004d44304c
    cmp rax, r9
    jne fail_parse
    mov rax, qword ptr [r12+8]
    cmp rax, 2
    jne fail_parse
    mov r15, qword ptr [r12+16]    # entry count
    mov rax, r15
    imul rax, 24
    add rax, 32
    cmp rax, rbx
    jne fail_parse
    mov r13, qword ptr [r12+24]    # code_size
    xor r9, r9                     # prev inst_id
    xor r10, r10                   # prev end
    xor r14, r14
.mapcat_validate_loop:
    cmp r14, r15
    jae .mapcat_validate_done
    mov r11, r14
    imul r11, 24
    add r11, 32
    mov rax, qword ptr [r12+r11+0] # inst_id
    cmp rax, 0
    je fail_parse
    cmp rax, r9
    jbe fail_parse
    mov r9, rax
    mov rax, qword ptr [r12+r11+8] # start
    cmp rax, r13
    ja fail_parse
    mov rcx, qword ptr [r12+r11+16] # end
    cmp rcx, r13
    ja fail_parse
    cmp rax, rcx
    ja fail_parse
    cmp rax, r10
    jb fail_parse
    mov r10, rcx
    inc r14
    jmp .mapcat_validate_loop
.mapcat_validate_done:
    mov rdi, 1
    lea rsi, [rip+map_entries_prefix]
    mov rdx, map_entries_prefix_len
    call write_fd
    mov rdi, r15
    call print_u64_nl
    mov rdi, 1
    lea rsi, [rip+map_code_size_prefix]
    mov rdx, map_code_size_prefix_len
    call write_fd
    mov rdi, r13
    call print_u64_nl
    xor r14, r14
.mapcat_entry_loop:
    cmp r14, r15
    jae .mapcat_done
    mov rdi, 1
    lea rsi, [rip+map_inst_id_prefix]
    mov rdx, map_inst_id_prefix_len
    call write_fd
    mov r11, r14
    imul r11, 24
    add r11, 32
    mov rdi, qword ptr [r12+r11+0]
    call print_u64_nl
    mov rdi, 1
    lea rsi, [rip+map_start_prefix]
    mov rdx, map_start_prefix_len
    call write_fd
    mov r11, r14
    imul r11, 24
    add r11, 32
    mov rdi, qword ptr [r12+r11+8]
    call print_u64_nl
    mov rdi, 1
    lea rsi, [rip+map_end_prefix]
    mov rdx, map_end_prefix_len
    call write_fd
    mov r11, r14
    imul r11, 24
    add r11, 32
    mov rdi, qword ptr [r12+r11+16]
    call print_u64_nl
    inc r14
    jmp .mapcat_entry_loop
.mapcat_done:
    mov rdi, 0
    call exit

do_schemacat:
    mov rdi, r15
    call load_file
    cmp rax, 0
    jl fail_io
    mov rbx, rax
    cmp rbx, 32
    jne fail_parse
    lea r8, [rip+file_buf]
    mov rax, qword ptr [r8+0]
    mov r9, 0x000000005354304c
    cmp rax, r9
    jne fail_parse
    mov rax, qword ptr [r8+8]
    cmp rax, 1
    jne fail_parse
    mov rdi, 1
    lea rsi, [rip+schema_version_prefix]
    mov rdx, schema_version_prefix_len
    call write_fd
    mov rdi, qword ptr [r8+8]
    call print_u64_nl
    mov rdi, 1
    lea rsi, [rip+schema_record_size_prefix]
    mov rdx, schema_record_size_prefix_len
    call write_fd
    mov rdi, qword ptr [r8+16]
    call print_u64_nl
    mov rdi, 1
    lea rsi, [rip+schema_fields_prefix]
    mov rdx, schema_fields_prefix_len
    call write_fd
    mov rdi, qword ptr [r8+24]
    call print_u64_nl
    mov rdi, 0
    call exit

do_tracejoin:
    # load and parse debug map first
    mov rdi, qword ptr [rip+tracejoin_map_path_ptr]
    call load_file
    cmp rax, 0
    jl fail_io
    mov rbx, rax
    cmp rbx, 32
    jb fail_parse
    mov rax, rbx
    sub rax, 32
    xor rdx, rdx
    mov rcx, 24
    div rcx
    cmp rdx, 0
    jne fail_parse
    lea r8, [rip+file_buf]
    mov rax, qword ptr [r8+0]
    mov r9, 0x000000004d44304c
    cmp rax, r9
    jne fail_parse
    mov rax, qword ptr [r8+8]
    cmp rax, 2
    jne fail_parse
    mov r10, qword ptr [r8+16]    # entry_count
    cmp r10, 64
    ja fail_parse
    mov rax, r10
    imul rax, 24
    add rax, 32
    cmp rax, rbx
    jne fail_parse
    mov r13, qword ptr [r8+24]    # code_size
    xor r12, r12                  # prev inst_id
    xor rbx, rbx                  # prev end
    mov qword ptr [rip+tracejoin_map_count], r10
    xor r14, r14
.tj_copy_map_loop:
    cmp r14, r10
    jae .tj_map_copied
    mov r11, r14
    imul r11, 24
    add r11, 32
    mov rax, qword ptr [r8+r11+0]
    cmp rax, 0
    je fail_parse
    cmp rax, r12
    jbe fail_parse
    mov r12, rax
    mov rcx, r14
    shl rcx, 3
    lea rdx, [rip+tracejoin_map_inst_id]
    add rdx, rcx
    mov qword ptr [rdx], rax
    mov rax, qword ptr [r8+r11+8]
    cmp rax, r13
    ja fail_parse
    lea rdx, [rip+tracejoin_map_start]
    add rdx, rcx
    mov qword ptr [rdx], rax
    mov r9, qword ptr [r8+r11+16]
    cmp r9, r13
    ja fail_parse
    cmp rax, r9
    ja fail_parse
    cmp rax, rbx
    jb fail_parse
    mov rbx, r9
    lea rdx, [rip+tracejoin_map_end]
    add rdx, rcx
    mov qword ptr [rdx], r9
    inc r14
    jmp .tj_copy_map_loop

.tj_map_copied:
    # load trace records and join on inst_id
    mov rdi, r15
    call load_file
    cmp rax, 0
    jl fail_io
    mov rbx, rax
    mov rax, rbx
    and rax, 15
    cmp rax, 0
    jne fail_parse
    xor r12, r12
.tj_trace_loop:
    cmp r12, rbx
    jae .tj_done
    lea r8, [rip+file_buf]
    add r8, r12
    mov r13, qword ptr [r8+0]     # trace id
    mov r14, qword ptr [r8+8]     # traced value
    xor r9, r9                    # joined start
    xor r10, r10                  # joined end
    xor rcx, rcx
    mov r11, qword ptr [rip+tracejoin_map_count]
.tj_find_loop:
    cmp rcx, r11
    jae fail_parse
    mov rax, rcx
    shl rax, 3
    lea rdx, [rip+tracejoin_map_inst_id]
    add rdx, rax
    mov rdx, qword ptr [rdx]
    cmp rdx, r13
    jne .tj_find_next
    lea rdx, [rip+tracejoin_map_start]
    add rdx, rax
    mov r9, qword ptr [rdx]
    lea rdx, [rip+tracejoin_map_end]
    add rdx, rax
    mov r10, qword ptr [rdx]
    jmp .tj_emit
.tj_find_next:
    inc rcx
    jmp .tj_find_loop

.tj_emit:
    mov qword ptr [rip+tracejoin_join_start], r9
    mov qword ptr [rip+tracejoin_join_end], r10
    mov rdi, 1
    lea rsi, [rip+trace_id_prefix]
    mov rdx, trace_id_prefix_len
    call write_fd
    mov rdi, r13
    call print_u64_nl
    mov rdi, 1
    lea rsi, [rip+trace_val_prefix]
    mov rdx, trace_val_prefix_len
    call write_fd
    mov rdi, r14
    call print_u64_nl
    mov rdi, 1
    lea rsi, [rip+join_start_prefix]
    mov rdx, join_start_prefix_len
    call write_fd
    mov rdi, qword ptr [rip+tracejoin_join_start]
    call print_u64_nl
    mov rdi, 1
    lea rsi, [rip+join_end_prefix]
    mov rdx, join_end_prefix_len
    call write_fd
    mov rdi, qword ptr [rip+tracejoin_join_end]
    call print_u64_nl
    add r12, 16
    jmp .tj_trace_loop

.tj_done:
    mov rdi, 0
    call exit

fail_io:
    cmp rax, -2
    je fail_read
    lea rsi, [rip+err_open_msg]
    mov rdx, err_open_len
    mov rdi, 2
    call write_fd
    mov rdi, 3
    call exit

fail_read:
    lea rsi, [rip+err_read_msg]
    mov rdx, err_read_len
    mov rdi, 2
    call write_fd
    mov rdi, 4
    call exit

fail_parse:
    lea rsi, [rip+err_parse_msg]
    mov rdx, err_parse_len
    mov rdi, 2
    call write_fd
    mov rdi, 5
    call exit

fail_build:
    lea rsi, [rip+err_build_msg]
    mov rdx, err_build_len
    mov rdi, 2
    call write_fd
    mov rdi, 6
    call exit

fail_img:
    lea rsi, [rip+err_img_msg]
    mov rdx, err_img_len
    mov rdi, 2
    call write_fd
    mov rdi, 7
    call exit

fail_run:
    lea rsi, [rip+err_run_msg]
    mov rdx, err_run_len
    mov rdi, 2
    call write_fd
    mov rdi, 8
    call exit

fail_run_arg:
    lea rsi, [rip+err_run_arg_msg]
    mov rdx, err_run_arg_len
    mov rdi, 2
    call write_fd
    mov rdi, 9
    call exit

# rdi=path ; returns rax=size or negative code
# -1 open fail, -2 read fail
load_file:
    mov rax, 2                 # sys_open
    mov rsi, 0                 # O_RDONLY
    mov rdx, 0
    syscall
    test rax, rax
    js .open_fail

    mov r8, rax                # fd
    mov rdi, r8
    lea rsi, [rip+file_buf]
    mov rdx, 1048576
    mov rax, 0                 # sys_read
    syscall
    test rax, rax
    js .read_fail

    mov r9, rax                # bytes read
    mov rdi, r8
    mov rax, 3                 # sys_close
    syscall

    mov rax, r9
    ret

.read_fail:
    mov rdi, r8
    mov rax, 3
    syscall
    mov rax, -2
    ret

.open_fail:
    mov rax, -1
    ret

# strict bootstrap validator
# rdi=buf, rsi=len ; rax=1 valid else 0
validate_module:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    mov r12, rdi               # ptr
    mov r13, rsi               # remaining len

    # ver
    lea rbx, [rip+kw_ver]
    mov rdi, r12
    mov rsi, rbx
    mov rdx, kw_ver_len
    call mem_eq
    cmp rax, 1
    jne .bad
    add r12, kw_ver_len
    sub r13, kw_ver_len

    # must be '1' then '\n'
    cmp r13, 2
    jb .bad
    mov al, byte ptr [r12]
    cmp al, '1'
    jne .bad
    mov al, byte ptr [r12+1]
    cmp al, 10
    jne .bad
    add r12, 2
    sub r13, 2

    # types {
    lea rbx, [rip+kw_types]
    mov rdi, r12
    mov rsi, rbx
    mov rdx, kw_types_len
    call mem_eq
    cmp rax, 1
    jne .bad
    add r12, kw_types_len
    sub r13, kw_types_len
    call validate_types_section
    cmp rax, 1
    jne .bad

    # consts {
    lea rbx, [rip+kw_consts]
    mov rdi, r12
    mov rsi, rbx
    mov rdx, kw_consts_len
    call mem_eq
    cmp rax, 1
    jne .bad
    add r12, kw_consts_len
    sub r13, kw_consts_len
    call skip_until_close_brace_newline
    cmp rax, 1
    jne .bad

    # extern {
    lea rbx, [rip+kw_extern]
    mov rdi, r12
    mov rsi, rbx
    mov rdx, kw_extern_len
    call mem_eq
    cmp rax, 1
    jne .bad
    add r12, kw_extern_len
    sub r13, kw_extern_len
    call skip_until_close_brace_newline
    cmp rax, 1
    jne .bad

    # globals {
    lea rbx, [rip+kw_globals]
    mov rdi, r12
    mov rsi, rbx
    mov rdx, kw_globals_len
    call mem_eq
    cmp rax, 1
    jne .bad
    add r12, kw_globals_len
    sub r13, kw_globals_len
    call skip_until_close_brace_newline
    cmp rax, 1
    jne .bad

    # fns {
    lea rbx, [rip+kw_fns]
    mov rdi, r12
    mov rsi, rbx
    mov rdx, kw_fns_len
    call mem_eq
    cmp rax, 1
    jne .bad
    add r12, kw_fns_len
    sub r13, kw_fns_len

    # verify function/body structure in fns payload
    mov rdi, r12
    mov rsi, r13
    call verify_fns_payload
    cmp rax, 1
    jne .bad

.good:
    mov rax, 1
    jmp .done

.bad:
    xor rax, rax

.done:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

# uses global parser cursor r12/r13
# expects parser currently after section prefix e.g. "types {"
# scans until "}\n"
skip_until_close_brace_newline:
.loop:
    cmp r13, 0
    je .fail
    mov al, byte ptr [r12]
    cmp al, '}'
    jne .next
    cmp r13, 1
    je .fail
    mov al, byte ptr [r12+1]
    cmp al, 10
    jne .next
    add r12, 2
    sub r13, 2
    mov rax, 1
    ret
.next:
    inc r12
    dec r13
    jmp .loop
.fail:
    xor rax, rax
    ret

# validate_types_section
# uses parser cursor r12/r13 currently right after "types {"
# validates canonical bootstrap type table and stores vfp_type_count
# accepted canonical forms:
# - empty: " }\n"
# - non-empty: " t0=<tok>, t1=<tok>, ... }\n" (contiguous ids from 0)
validate_types_section:
    push rbx
    push r14
    push r15
    call clear_type_is_i1_map
    call clear_type_is_p0_i8_map
    mov qword ptr [rip+vfp_i1_type_id], -1

    # find closing "}\n"
    xor r14, r14
.vts_find_close:
    cmp r14, r13
    jae .vts_bad
    mov al, byte ptr [r12+r14]
    cmp al, '}'
    jne .vts_next
    mov r15, r14
    inc r15
    cmp r15, r13
    jae .vts_bad
    mov al, byte ptr [r12+r15]
    cmp al, 10
    je .vts_have_close
.vts_next:
    inc r14
    jmp .vts_find_close

.vts_have_close:
    # content is [0, r14), must start with single leading space
    cmp r14, 1
    jb .vts_bad
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vts_bad
    mov qword ptr [rip+vfp_type_count], 0

    # empty case: exactly " "
    cmp r14, 1
    je .vts_consume

    # parse entries: " tN=tok" with ", " separators, trailing space before "}"
    mov rcx, 1                    # scan index into content
    xor rbx, rbx                  # expected type id

.vts_entry:
    cmp rcx, r14
    jae .vts_bad
    mov al, byte ptr [r12+rcx]
    cmp al, 't'
    jne .vts_bad
    inc rcx
    mov rdi, r12
    mov rsi, r14
    call parse_digits
    cmp rax, 1
    jne .vts_bad

    # convert parsed id from digits [start, rcx)
    xor r9, r9
    mov r8, 0                     # start unknown yet
    mov r8, rcx
.vts_find_digit_start:
    cmp r8, 0
    je .vts_bad
    dec r8
    mov al, byte ptr [r12+r8]
    cmp al, '0'
    jb .vts_digit_start_found
    cmp al, '9'
    jbe .vts_find_digit_start
.vts_digit_start_found:
    inc r8
.vts_id_conv:
    cmp r8, rcx
    jae .vts_id_done
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul r9, r9, 10
    movzx r10, al
    add r9, r10
    inc r8
    jmp .vts_id_conv
.vts_id_done:
    cmp r9, rbx
    jne .vts_bad
    inc rbx

    cmp rcx, r14
    jae .vts_bad
    mov al, byte ptr [r12+rcx]
    cmp al, '='
    jne .vts_bad
    inc rcx
    cmp rcx, r14
    jae .vts_bad

    # parse minimal type token payload until delimiter ',' or ' '
    mov r8, rcx
.vts_tok_loop:
    cmp rcx, r14
    jae .vts_bad
    mov al, byte ptr [r12+rcx]
    cmp al, ','
    je .vts_tok_done
    cmp al, ' '
    je .vts_tok_done
    inc rcx
    jmp .vts_tok_loop
.vts_tok_done:
    cmp rcx, r8
    je .vts_bad
    # validate token against bootstrap allowed type set
    push r8
    push rcx
    push r9
    mov r10, qword ptr [rsp+16]   # token_start
    mov r11, qword ptr [rsp+8]    # token_end
    mov rdi, r12
    add rdi, r10
    mov rsi, r11
    sub rsi, r10
    call type_token_is_allowed
    cmp rax, 1
    jne .vts_tok_badpop
    # mark i1 types for cbr condition typing checks
    mov r10, qword ptr [rsp+16]
    mov r11, qword ptr [rsp+8]
    mov rdi, r12
    add rdi, r10
    mov rsi, r11
    sub rsi, r10
    call type_token_is_i1
    cmp rax, 1
    jne .vts_tok_kind_not_i1
    pop r9
    mov r11, r9
    cmp r11, 4096
    jae .vts_tok_i1_badpop
    shl r11, 3
    lea r10, [rip+vfp_type_is_i1_map]
    add r10, r11
    mov qword ptr [r10], 1
    cmp qword ptr [rip+vfp_i1_type_id], -1
    jne .vts_tok_i1_id_done
    mov qword ptr [rip+vfp_i1_type_id], r9
.vts_tok_i1_id_done:
    pop rcx
    pop r8
    jmp .vts_tok_kind_done
.vts_tok_i1_badpop:
    pop rcx
    pop r8
    jmp .vts_bad
.vts_tok_kind_not_i1:
    mov r10, qword ptr [rsp+16]
    mov r11, qword ptr [rsp+8]
    mov rdi, r12
    add rdi, r10
    mov rsi, r11
    sub rsi, r10
    call type_token_is_p0_i8
    cmp rax, 1
    jne .vts_tok_kind_not_ptr
    pop r9
    mov r11, r9
    cmp r11, 4096
    jae .vts_tok_ptr_badpop
    shl r11, 3
    lea r10, [rip+vfp_type_is_p0_i8_map]
    add r10, r11
    mov qword ptr [r10], 1
    pop rcx
    pop r8
    jmp .vts_tok_kind_done
.vts_tok_ptr_badpop:
    pop rcx
    pop r8
    jmp .vts_bad
.vts_tok_kind_not_ptr:
    pop r9
    pop rcx
    pop r8
.vts_tok_kind_done:

    mov al, byte ptr [r12+rcx]
    cmp al, ','
    je .vts_after_comma
    cmp al, ' '
    jne .vts_bad
    inc rcx
    cmp rcx, r14
    jne .vts_bad                 # require single trailing space then close
    jmp .vts_set_count

.vts_tok_badpop:
    pop r9
    pop rcx
    pop r8
    jmp .vts_bad

.vts_after_comma:
    inc rcx
    cmp rcx, r14
    jae .vts_bad
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vts_bad
    inc rcx
    cmp rcx, r14
    jae .vts_bad
    jmp .vts_entry

.vts_set_count:
    mov qword ptr [rip+vfp_type_count], rbx

.vts_consume:
    # advance parser cursor past "}\n"
    add r14, 2
    add r12, r14
    sub r13, r14
    mov rax, 1
    jmp .vts_done

.vts_bad:
    xor rax, rax
.vts_done:
    pop r15
    pop r14
    pop rbx
    ret

# verify_fns_payload
# rdi=ptr (immediately after "fns {"), rsi=len
# returns rax=1 valid, 0 invalid
verify_fns_payload:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r14, rdi                # cursor
    mov r15, rsi                # remaining

    # require newline after "fns {"
    cmp r15, 1
    jb .vfp_bad
    mov al, byte ptr [r14]
    cmp al, 10
    jne .vfp_bad
    inc r14
    dec r15
    mov qword ptr [rip+vfp_fns_body_ptr], r14

    mov qword ptr [rip+vfp_state_in_fn], 0
    mov qword ptr [rip+vfp_fn_seen], 0
    mov qword ptr [rip+vfp_block_seen], 0
    mov qword ptr [rip+vfp_term_seen], 0
    mov qword ptr [rip+vfp_last_fn_id], -1
    mov qword ptr [rip+vfp_last_block_id], -1
    call clear_fn_arg_count_map
    call clear_fn_ret_type_map

.vfp_next_line:
    cmp r15, 0
    je .vfp_bad

    # find newline in remaining bytes
    xor rcx, rcx
.vfp_find_nl:
    cmp rcx, r15
    jae .vfp_bad
    mov al, byte ptr [r14+rcx]
    cmp al, 10
    je .vfp_line_ready
    inc rcx
    jmp .vfp_find_nl

.vfp_line_ready:
    # line: [r14, rcx)
    cmp rcx, 0
    je .vfp_bad                 # no blank lines in canonical form
    mov r12, r14                # line_ptr
    mov r13, rcx                # line_len

    # advance cursor past line + newline
    lea r14, [r14+rcx+1]
    sub r15, rcx
    dec r15

    cmp qword ptr [rip+vfp_state_in_fn], 0
    je .vfp_top_level
    jmp .vfp_in_fn

.vfp_top_level:
    # top-level expects either:
    # - closing "}" of fns section (must be final line)
    # - function header
    cmp r13, 1
    jne .vfp_try_fn_header
    mov al, byte ptr [r12]
    cmp al, '}'
    jne .vfp_try_fn_header
    cmp qword ptr [rip+vfp_fn_seen], 1
    jne .vfp_bad
    cmp r15, 0
    jne .vfp_bad
    mov rdi, qword ptr [rip+vfp_fns_body_ptr]
    mov rsi, r12
    sub rsi, rdi
    call verify_call_targets_in_module
    cmp rax, 1
    jne .vfp_bad
    mov rax, 1
    jmp .vfp_done

.vfp_try_fn_header:
    mov rdi, r12
    mov rsi, r13
    call line_is_fn_header
    cmp rax, 1
    jne .vfp_bad
    # canonical function order: require contiguous ascending ids f0, f1, ...
    mov rdi, r12
    mov rsi, r13
    call parse_fn_header_id
    cmp rax, 0
    jl .vfp_bad
    mov rbx, rax
    mov rax, qword ptr [rip+vfp_last_fn_id]
    add rax, 1
    cmp rbx, rax
    jne .vfp_bad
    mov qword ptr [rip+vfp_last_fn_id], rbx
    cmp rbx, 4096
    jae .vfp_bad
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_fn_arg_count_map]
    add r9, r8
    mov rax, qword ptr [rip+vfp_fn_arg_count]
    mov qword ptr [r9], rax
    lea r9, [rip+vfp_fn_ret_type_map]
    add r9, r8
    mov rax, qword ptr [rip+vfp_fn_ret_type]
    mov qword ptr [r9], rax
    mov qword ptr [rip+vfp_state_in_fn], 1
    mov qword ptr [rip+vfp_fn_seen], 1
    mov qword ptr [rip+vfp_block_seen], 0
    mov qword ptr [rip+vfp_term_seen], 0
    mov qword ptr [rip+vfp_last_block_id], -1
    mov qword ptr [rip+vfp_fn_body_ptr], r14
    call clear_block_seen_map
    call clear_value_seen_map
    jmp .vfp_next_line

.vfp_in_fn:
    # function close line
    cmp r13, 1
    jne .vfp_try_block
    mov al, byte ptr [r12]
    cmp al, '}'
    jne .vfp_try_block
    cmp qword ptr [rip+vfp_block_seen], 1
    jne .vfp_bad
    cmp qword ptr [rip+vfp_term_seen], 1
    jne .vfp_bad
    mov rdi, qword ptr [rip+vfp_fn_body_ptr]
    mov rsi, r12
    sub rsi, rdi
    call verify_branch_targets_in_function
    cmp rax, 1
    jne .vfp_bad
    mov qword ptr [rip+vfp_state_in_fn], 0
    jmp .vfp_next_line

.vfp_try_block:
    mov rdi, r12
    mov rsi, r13
    call line_is_block_label
    cmp rax, 1
    jne .vfp_try_instr
    cmp qword ptr [rip+vfp_block_seen], 0
    je .vfp_first_block_check
    cmp qword ptr [rip+vfp_term_seen], 1
    jne .vfp_bad
    # after first block, b0 must not appear again
    mov rdi, r12
    mov rsi, r13
    call line_is_entry_block
    cmp rax, 1
    je .vfp_bad
    jmp .vfp_set_block

.vfp_first_block_check:
    # canonical entry block must be b0
    mov rdi, r12
    mov rsi, r13
    call line_is_entry_block
    cmp rax, 1
    jne .vfp_bad

.vfp_set_block:
    # block label must be unique within function
    mov rdi, r12
    mov rsi, r13
    call parse_block_id
    cmp rax, 0
    jl .vfp_bad
    mov rbx, rax
    mov rdi, rbx
    call test_and_set_block_seen
    cmp rax, 1
    je .vfp_bad

    # canonical block order: require contiguous ascending ids
    mov rax, qword ptr [rip+vfp_last_block_id]
    add rax, 1
    cmp rbx, rax
    jne .vfp_bad
    mov qword ptr [rip+vfp_last_block_id], rbx

    mov qword ptr [rip+vfp_block_seen], 1
    mov qword ptr [rip+vfp_term_seen], 0
    jmp .vfp_next_line

.vfp_try_instr:
    mov rdi, r12
    mov rsi, r13
    call line_is_instruction
    cmp rax, 1
    jne .vfp_bad
    cmp qword ptr [rip+vfp_block_seen], 1
    jne .vfp_bad
    cmp qword ptr [rip+vfp_term_seen], 1
    je .vfp_bad
    mov rdi, r12
    mov rsi, r13
    call line_is_terminator
    cmp rax, 1
    jne .vfp_try_value_instr
    mov rdi, r12
    mov rsi, r13
    call validate_terminator_uses_defined
    cmp rax, 1
    jne .vfp_bad
    mov qword ptr [rip+vfp_term_seen], 1
    jmp .vfp_next_line

.vfp_try_value_instr:
    mov rdi, r12
    mov rsi, r13
    call line_is_value_instruction
    cmp rax, 1
    jne .vfp_try_nonvalue_instr
    mov rdi, r12
    mov rsi, r13
    call validate_value_uses_defined
    cmp rax, 1
    jne .vfp_bad
    # SSA uniqueness: vN may be defined only once per function
    mov rdi, r12
    mov rsi, r13
    call parse_value_lhs_id
    cmp rax, 0
    jl .vfp_bad
    mov rbx, rax
    mov rdi, rbx
    call test_and_set_value_seen
    cmp rax, 1
    je .vfp_bad
    # record value result type id for downstream type checks
    mov rdi, r12
    mov rsi, r13
    call parse_value_result_type_id
    cmp rax, 0
    jl .vfp_bad
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov qword ptr [r9], rax
    jmp .vfp_next_line

.vfp_try_nonvalue_instr:
    mov rdi, r12
    mov rsi, r13
    call line_is_nonvalue_instruction
    cmp rax, 1
    jne .vfp_bad
    mov rdi, r12
    mov rsi, r13
    call validate_nonvalue_uses_defined
    cmp rax, 1
    jne .vfp_bad
    jmp .vfp_next_line

.vfp_bad:
    xor rax, rax

.vfp_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

# rdi=line_ptr, rsi=line_len -> rax=1 if line starts with "fn f" and ends with " {"
line_is_fn_header:
    cmp rsi, 14
    jb .lfh_no
    mov al, byte ptr [rdi]
    cmp al, 'f'
    jne .lfh_no
    mov al, byte ptr [rdi+1]
    cmp al, 'n'
    jne .lfh_no
    mov al, byte ptr [rdi+2]
    cmp al, ' '
    jne .lfh_no
    mov al, byte ptr [rdi+3]
    cmp al, 'f'
    jne .lfh_no
    mov rcx, 4
    call parse_digits
    cmp rax, 1
    jne .lfh_no
    cmp rcx, rsi
    jae .lfh_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lfh_no
    inc rcx
    cmp rcx, rsi
    jae .lfh_no
    mov al, byte ptr [rdi+rcx]
    cmp al, '('
    jne .lfh_no
    inc rcx
    cmp rcx, rsi
    jae .lfh_no

    # args: empty or comma-separated tN list
    mov qword ptr [rip+vfp_fn_arg_count], 0
    mov al, byte ptr [rdi+rcx]
    cmp al, ')'
    je .lfh_after_args

.lfh_arg_loop:
    mov al, byte ptr [rdi+rcx]
    cmp al, 't'
    jne .lfh_no
    inc rcx
    mov r8, rcx
    call parse_digits
    cmp rax, 1
    jne .lfh_no
    xor r9, r9
.lfh_arg_id_conv:
    cmp r8, rcx
    jae .lfh_arg_id_done
    mov al, byte ptr [rdi+r8]
    sub al, '0'
    imul r9, r9, 10
    movzx r10, al
    add r9, r10
    inc r8
    jmp .lfh_arg_id_conv
.lfh_arg_id_done:
    cmp r9, qword ptr [rip+vfp_type_count]
    jae .lfh_no
    # record expected function argument type id
    mov r11, qword ptr [rip+vfp_fn_arg_count]
    cmp r11, 1024
    jae .lfh_no
    mov r8, r11
    shl r8, 3
    lea r10, [rip+vfp_fn_arg_type_map]
    add r10, r8
    mov qword ptr [r10], r9
    inc qword ptr [rip+vfp_fn_arg_count]
    cmp rcx, rsi
    jae .lfh_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ','
    je .lfh_arg_next
    cmp al, ')'
    je .lfh_after_args
    jmp .lfh_no

.lfh_arg_next:
    inc rcx
    cmp rcx, rsi
    jae .lfh_no
    jmp .lfh_arg_loop

.lfh_after_args:
    mov al, byte ptr [rdi+rcx]
    cmp al, ')'
    jne .lfh_no
    inc rcx
    cmp rcx, rsi
    jae .lfh_no
    mov al, byte ptr [rdi+rcx]
    cmp al, '-'
    jne .lfh_no
    inc rcx
    cmp rcx, rsi
    jae .lfh_no
    mov al, byte ptr [rdi+rcx]
    cmp al, '>'
    jne .lfh_no
    inc rcx
    cmp rcx, rsi
    jae .lfh_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 't'
    jne .lfh_no
    inc rcx
    mov r8, rcx
    call parse_digits
    cmp rax, 1
    jne .lfh_no
    xor r9, r9
.lfh_ret_id_conv:
    cmp r8, rcx
    jae .lfh_ret_id_done
    mov al, byte ptr [rdi+r8]
    sub al, '0'
    imul r9, r9, 10
    movzx r10, al
    add r9, r10
    inc r8
    jmp .lfh_ret_id_conv
.lfh_ret_id_done:
    cmp r9, qword ptr [rip+vfp_type_count]
    jae .lfh_no
    mov qword ptr [rip+vfp_fn_ret_type], r9
    cmp rcx, rsi
    jae .lfh_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lfh_no
    inc rcx
    cmp rcx, rsi
    jae .lfh_no
    mov al, byte ptr [rdi+rcx]
    cmp al, '{'
    jne .lfh_no
    inc rcx
    cmp rcx, rsi
    jne .lfh_no
    mov rax, 1
    ret
.lfh_no:
    xor rax, rax
    ret

# rdi=line_ptr, rsi=line_len -> rax=1 if "b<digits>:"
line_is_block_label:
    cmp rsi, 3
    jb .lbl_no
    mov al, byte ptr [rdi]
    cmp al, 'b'
    jne .lbl_no
    mov rcx, 1
    call parse_digits
    cmp rax, 1
    jne .lbl_no
    cmp rcx, rsi
    jae .lbl_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ':'
    jne .lbl_no
    inc rcx
    cmp rcx, rsi
    jne .lbl_no
    mov rax, 1
    ret
.lbl_no:
    xor rax, rax
    ret

# rdi=line_ptr, rsi=line_len -> rax=1 if exactly "b0:"
line_is_entry_block:
    cmp rsi, 3
    jne .leb_no
    mov al, byte ptr [rdi]
    cmp al, 'b'
    jne .leb_no
    mov al, byte ptr [rdi+1]
    cmp al, '0'
    jne .leb_no
    mov al, byte ptr [rdi+2]
    cmp al, ':'
    jne .leb_no
    mov rax, 1
    ret
.leb_no:
    xor rax, rax
    ret

# parse_fn_header_id
# rdi=line_ptr, rsi=line_len
# out: rax=function id (>=0) or -1 if invalid header prefix
parse_fn_header_id:
    cmp rsi, 6
    jb .pfhi_bad
    mov al, byte ptr [rdi]
    cmp al, 'f'
    jne .pfhi_bad
    mov al, byte ptr [rdi+1]
    cmp al, 'n'
    jne .pfhi_bad
    mov al, byte ptr [rdi+2]
    cmp al, ' '
    jne .pfhi_bad
    mov al, byte ptr [rdi+3]
    cmp al, 'f'
    jne .pfhi_bad
    mov rcx, 4
    call parse_digits
    cmp rax, 1
    jne .pfhi_bad
    cmp rcx, rsi
    jae .pfhi_bad
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .pfhi_bad

    xor rax, rax
    mov r8, 4
.pfhi_conv:
    cmp r8, rcx
    jae .pfhi_ok
    mov bl, byte ptr [rdi+r8]
    sub bl, '0'
    imul rax, rax, 10
    movzx r9, bl
    add rax, r9
    inc r8
    jmp .pfhi_conv
.pfhi_ok:
    ret
.pfhi_bad:
    mov rax, -1
    ret

# parse_block_id
# rdi=line_ptr, rsi=line_len
# out: rax = block id (>=0) or -1 if invalid label shape
parse_block_id:
    cmp rsi, 3
    jb .pbi_bad
    mov al, byte ptr [rdi]
    cmp al, 'b'
    jne .pbi_bad
    mov rcx, 1
    call parse_digits
    cmp rax, 1
    jne .pbi_bad
    cmp rcx, rsi
    jae .pbi_bad
    mov al, byte ptr [rdi+rcx]
    cmp al, ':'
    jne .pbi_bad
    inc rcx
    cmp rcx, rsi
    jne .pbi_bad

    # convert decimal digits in [1, rsi-1) to integer
    xor rax, rax
    mov r8, 1
    mov r10, rsi
    dec r10
.pbi_conv:
    cmp r8, r10
    je .pbi_ok
    mov bl, byte ptr [rdi+r8]
    sub bl, '0'
    imul rax, rax, 10
    movzx r9, bl
    add rax, r9
    inc r8
    jmp .pbi_conv

.pbi_ok:
    ret
.pbi_bad:
    mov rax, -1
    ret

# clear_block_seen_map
clear_block_seen_map:
    lea rdi, [rip+vfp_block_seen_map]
    xor rax, rax
    mov rcx, 256
    rep stosq
    ret

# clear_value_seen_map
clear_value_seen_map:
    lea rdi, [rip+vfp_value_seen_map]
    xor rax, rax
    mov rcx, 1024
    rep stosq
    ret

# clear_fn_arg_count_map
clear_fn_arg_count_map:
    lea rdi, [rip+vfp_fn_arg_count_map]
    xor rax, rax
    mov rcx, 4096
    rep stosq
    ret

# clear_fn_ret_type_map
clear_fn_ret_type_map:
    lea rdi, [rip+vfp_fn_ret_type_map]
    xor rax, rax
    mov rcx, 4096
    rep stosq
    ret

# clear_type_is_i1_map
clear_type_is_i1_map:
    lea rdi, [rip+vfp_type_is_i1_map]
    xor rax, rax
    mov rcx, 4096
    rep stosq
    ret

# clear_type_is_p0_i8_map
clear_type_is_p0_i8_map:
    lea rdi, [rip+vfp_type_is_p0_i8_map]
    xor rax, rax
    mov rcx, 4096
    rep stosq
    ret

# test_and_set_block_seen
# rdi=block_id
# out: rax=1 if already seen, 0 if newly set
test_and_set_block_seen:
    cmp rdi, 16384
    jae .tbss_seen
    mov r8, rdi
    shr r8, 3                      # byte index
    mov r9, rdi
    and r9, 7                      # bit index
    lea r10, [rip+vfp_block_seen_map]
    add r10, r8
    mov al, byte ptr [r10]
    mov dl, 1
    mov cl, r9b
    shl dl, cl
    test al, dl
    jne .tbss_seen
    or al, dl
    mov byte ptr [r10], al
    xor rax, rax
    ret
.tbss_seen:
    mov rax, 1
    ret

# test_and_set_value_seen
# rdi=value_id
# out: rax=1 if already seen, 0 if newly set
test_and_set_value_seen:
    cmp rdi, 65536
    jae .tvss_seen
    mov r8, rdi
    shr r8, 3
    mov r9, rdi
    and r9, 7
    lea r10, [rip+vfp_value_seen_map]
    add r10, r8
    mov al, byte ptr [r10]
    mov dl, 1
    mov cl, r9b
    shl dl, cl
    test al, dl
    jne .tvss_seen
    or al, dl
    mov byte ptr [r10], al
    xor rax, rax
    ret
.tvss_seen:
    mov rax, 1
    ret

# value_seen_exists
# rdi=value_id
# out: rax=1 if seen, 0 if not seen
value_seen_exists:
    cmp rdi, 65536
    jae .vse_no
    mov r8, rdi
    shr r8, 3
    mov r9, rdi
    and r9, 7
    lea r10, [rip+vfp_value_seen_map]
    add r10, r8
    mov al, byte ptr [r10]
    mov dl, 1
    mov cl, r9b
    shl dl, cl
    test al, dl
    jne .vse_yes
.vse_no:
    xor rax, rax
    ret
.vse_yes:
    mov rax, 1
    ret

# validate_terminator_uses_defined
# rdi=line_ptr, rsi=line_len
# out: rax=1 valid, 0 invalid
validate_terminator_uses_defined:
    push rbx
    push r12
    push r13

    mov r12, rdi
    mov r13, rsi

    # "  ret" has no value use
    cmp r13, 5
    jne .vtud_try_retv
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vtud_bad
    mov al, byte ptr [r12+1]
    cmp al, ' '
    jne .vtud_bad
    mov al, byte ptr [r12+2]
    cmp al, 'r'
    jne .vtud_bad
    mov al, byte ptr [r12+3]
    cmp al, 'e'
    jne .vtud_bad
    mov al, byte ptr [r12+4]
    cmp al, 't'
    jne .vtud_bad
    jmp .vtud_ok

.vtud_try_retv:
    # "  ret vN" => vN must already be defined
    cmp r13, 8
    jb .vtud_try_cbr
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vtud_try_cbr
    mov al, byte ptr [r12+1]
    cmp al, ' '
    jne .vtud_try_cbr
    mov al, byte ptr [r12+2]
    cmp al, 'r'
    jne .vtud_try_cbr
    mov al, byte ptr [r12+3]
    cmp al, 'e'
    jne .vtud_try_cbr
    mov al, byte ptr [r12+4]
    cmp al, 't'
    jne .vtud_try_cbr
    mov al, byte ptr [r12+5]
    cmp al, ' '
    jne .vtud_try_cbr
    mov al, byte ptr [r12+6]
    cmp al, 'v'
    jne .vtud_try_cbr
    mov rdi, r12
    mov rsi, r13
    mov rcx, 7
    call parse_digits
    cmp rax, 1
    jne .vtud_bad
    cmp rcx, r13
    jne .vtud_bad
    xor rbx, rbx
    mov r8, 7
.vtud_retv_conv:
    cmp r8, rcx
    jae .vtud_retv_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vtud_retv_conv
.vtud_retv_check:
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    jne .vtud_bad
    # ret value type must match current function return type
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r10, qword ptr [r9]
    cmp r10, qword ptr [rip+vfp_fn_ret_type]
    jne .vtud_bad
    jmp .vtud_ok

.vtud_try_cbr:
    # "  cbr vN bT bF" => condition vN must already be defined
    cmp r13, 12
    jb .vtud_ok
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vtud_ok
    mov al, byte ptr [r12+1]
    cmp al, ' '
    jne .vtud_ok
    mov al, byte ptr [r12+2]
    cmp al, 'c'
    jne .vtud_ok
    mov al, byte ptr [r12+3]
    cmp al, 'b'
    jne .vtud_ok
    mov al, byte ptr [r12+4]
    cmp al, 'r'
    jne .vtud_ok
    mov al, byte ptr [r12+5]
    cmp al, ' '
    jne .vtud_ok
    mov al, byte ptr [r12+6]
    cmp al, 'v'
    jne .vtud_ok
    mov rdi, r12
    mov rsi, r13
    mov rcx, 7
    call parse_digits
    cmp rax, 1
    jne .vtud_bad
    cmp rcx, r13
    jae .vtud_bad
    xor rbx, rbx
    mov r8, 7
.vtud_cbr_conv:
    cmp r8, rcx
    jae .vtud_cbr_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vtud_cbr_conv
.vtud_cbr_check:
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    jne .vtud_bad
    # cbr condition must be i1-typed
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r10, qword ptr [r9]
    cmp r10, 4096
    jae .vtud_bad
    mov r11, r10
    shl r11, 3
    lea r9, [rip+vfp_type_is_i1_map]
    add r9, r11
    cmp qword ptr [r9], 1
    jne .vtud_bad
    jmp .vtud_ok

.vtud_bad:
    xor rax, rax
    jmp .vtud_done
.vtud_ok:
    mov rax, 1
.vtud_done:
    pop r13
    pop r12
    pop rbx
    ret

# validate_nonvalue_uses_defined
# rdi=line_ptr, rsi=line_len
# out: rax=1 valid, 0 invalid
validate_nonvalue_uses_defined:
    push rbx
    push r12
    push r13

    mov r12, rdi
    mov r13, rsi

    # bootstrap non-value set:
    # trace N vVal | write vPtr vLen | exit vCode | free vPtr | st vPtr vVal
    cmp r13, 9
    jb .vnud_bad
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vnud_try_write
    mov al, byte ptr [r12+1]
    cmp al, ' '
    jne .vnud_try_write
    mov al, byte ptr [r12+2]
    cmp al, 't'
    jne .vnud_try_write
    mov al, byte ptr [r12+3]
    cmp al, 'r'
    jne .vnud_try_write
    mov al, byte ptr [r12+4]
    cmp al, 'a'
    jne .vnud_try_write
    mov al, byte ptr [r12+5]
    cmp al, 'c'
    jne .vnud_try_write
    mov al, byte ptr [r12+6]
    cmp al, 'e'
    jne .vnud_try_write
    mov al, byte ptr [r12+7]
    cmp al, ' '
    jne .vnud_try_write
    mov rcx, 8
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vnud_try_write
    cmp rcx, r13
    jae .vnud_try_write
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vnud_try_write
    inc rcx
    cmp rcx, r13
    jae .vnud_try_write
.vnud_trace_v_loop:
    mov al, byte ptr [r12+rcx]
    cmp al, 'v'
    jne .vnud_try_write
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vnud_try_write
    xor rbx, rbx
.vnud_trace_v_conv:
    cmp r8, rcx
    jae .vnud_trace_v_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vnud_trace_v_conv
.vnud_trace_v_check:
    push rcx
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    je .vnud_trace_v_seen
    pop rcx
    jmp .vnud_bad
.vnud_trace_v_seen:
    pop rcx
    cmp rcx, r13
    jne .vnud_trace_more
    mov rax, 1
    jmp .vnud_done
.vnud_trace_more:
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vnud_try_write
    inc rcx
    cmp rcx, r13
    jae .vnud_try_write
    jmp .vnud_trace_v_loop
    mov rax, 1
    jmp .vnud_done

.vnud_try_write:
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vnud_try_exit
    mov al, byte ptr [r12+1]
    cmp al, ' '
    jne .vnud_try_exit
    mov al, byte ptr [r12+2]
    cmp al, 'w'
    jne .vnud_try_exit
    mov al, byte ptr [r12+3]
    cmp al, 'r'
    jne .vnud_try_exit
    mov al, byte ptr [r12+4]
    cmp al, 'i'
    jne .vnud_try_exit
    mov al, byte ptr [r12+5]
    cmp al, 't'
    jne .vnud_try_exit
    mov al, byte ptr [r12+6]
    cmp al, 'e'
    jne .vnud_try_exit
    mov al, byte ptr [r12+7]
    cmp al, ' '
    jne .vnud_try_exit
    mov al, byte ptr [r12+8]
    cmp al, 'v'
    jne .vnud_try_exit
    mov rcx, 9
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vnud_try_exit
    cmp rcx, r13
    jae .vnud_try_exit
    xor rbx, rbx
    mov r8, 9
.vnud_write_ptr_conv:
    cmp r8, rcx
    jae .vnud_write_ptr_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vnud_write_ptr_conv
.vnud_write_ptr_check:
    push rcx
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    je .vnud_write_ptr_seen
    pop rcx
    jmp .vnud_bad
.vnud_write_ptr_seen:
    pop rcx
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r10, qword ptr [r9]
    cmp r10, 4096
    jae .vnud_bad
    mov r11, r10
    shl r11, 3
    lea r9, [rip+vfp_type_is_p0_i8_map]
    add r9, r11
    cmp qword ptr [r9], 1
    jne .vnud_bad
    mov r8, rcx
    mov al, byte ptr [r12+r8]
    cmp al, ' '
    jne .vnud_bad
    inc r8
    cmp r8, r13
    jae .vnud_bad
    mov al, byte ptr [r12+r8]
    cmp al, 'v'
    jne .vnud_bad
    inc r8
    mov rcx, r8
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vnud_bad
    cmp rcx, r13
    jne .vnud_bad
    xor rbx, rbx
.vnud_write_len_conv:
    cmp r8, rcx
    jae .vnud_write_len_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vnud_write_len_conv
.vnud_write_len_check:
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    jne .vnud_bad
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r10, qword ptr [r9]
    cmp r10, 4096
    jae .vnud_bad
    mov r11, r10
    shl r11, 3
    lea r9, [rip+vfp_type_is_p0_i8_map]
    add r9, r11
    cmp qword ptr [r9], 1
    je .vnud_bad
    mov rax, 1
    jmp .vnud_done

.vnud_try_exit:
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vnud_try_free
    mov al, byte ptr [r12+1]
    cmp al, ' '
    jne .vnud_try_free
    mov al, byte ptr [r12+2]
    cmp al, 'e'
    jne .vnud_try_free
    mov al, byte ptr [r12+3]
    cmp al, 'x'
    jne .vnud_try_free
    mov al, byte ptr [r12+4]
    cmp al, 'i'
    jne .vnud_try_free
    mov al, byte ptr [r12+5]
    cmp al, 't'
    jne .vnud_try_free
    mov al, byte ptr [r12+6]
    cmp al, ' '
    jne .vnud_try_free
    mov al, byte ptr [r12+7]
    cmp al, 'v'
    jne .vnud_try_free
    mov rcx, 8
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vnud_try_free
    cmp rcx, r13
    jne .vnud_try_free
    xor rbx, rbx
    mov r8, 8
.vnud_exit_conv:
    cmp r8, rcx
    jae .vnud_exit_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vnud_exit_conv
.vnud_exit_check:
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    jne .vnud_bad
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r10, qword ptr [r9]
    cmp r10, 4096
    jae .vnud_bad
    mov r11, r10
    shl r11, 3
    lea r9, [rip+vfp_type_is_p0_i8_map]
    add r9, r11
    cmp qword ptr [r9], 1
    je .vnud_bad
    mov rax, 1
    jmp .vnud_done

.vnud_try_free:
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vnud_try_st
    mov al, byte ptr [r12+1]
    cmp al, ' '
    jne .vnud_try_st
    mov al, byte ptr [r12+2]
    cmp al, 'f'
    jne .vnud_try_st
    mov al, byte ptr [r12+3]
    cmp al, 'r'
    jne .vnud_try_st
    mov al, byte ptr [r12+4]
    cmp al, 'e'
    jne .vnud_try_st
    mov al, byte ptr [r12+5]
    cmp al, 'e'
    jne .vnud_try_st
    mov al, byte ptr [r12+6]
    cmp al, ' '
    jne .vnud_try_st
    mov al, byte ptr [r12+7]
    cmp al, 'v'
    jne .vnud_try_st
    mov rcx, 8
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vnud_try_st
    cmp rcx, r13
    jne .vnud_try_st
    xor rbx, rbx
    mov r8, 8
.vnud_free_ptr_conv:
    cmp r8, rcx
    jae .vnud_free_ptr_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vnud_free_ptr_conv
.vnud_free_ptr_check:
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    jne .vnud_bad
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r10, qword ptr [r9]
    cmp r10, 4096
    jae .vnud_bad
    mov r11, r10
    shl r11, 3
    lea r9, [rip+vfp_type_is_p0_i8_map]
    add r9, r11
    cmp qword ptr [r9], 1
    jne .vnud_bad
    mov rax, 1
    jmp .vnud_done

.vnud_try_st:
    cmp r13, 10
    jb .vnud_bad
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vnud_bad
    mov al, byte ptr [r12+1]
    cmp al, ' '
    jne .vnud_bad
    mov al, byte ptr [r12+2]
    cmp al, 's'
    jne .vnud_bad
    mov al, byte ptr [r12+3]
    cmp al, 't'
    jne .vnud_bad
    mov al, byte ptr [r12+4]
    cmp al, ' '
    jne .vnud_bad
    mov al, byte ptr [r12+5]
    cmp al, 'v'
    jne .vnud_bad
    mov rcx, 6
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vnud_bad

    xor rbx, rbx
    mov r8, 6
.vnud_ptr_conv:
    cmp r8, rcx
    jae .vnud_ptr_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vnud_ptr_conv
.vnud_ptr_check:
    push rcx
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    je .vnud_ptr_seen
    pop rcx
    jmp .vnud_bad
.vnud_ptr_seen:
    pop rcx
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r10, qword ptr [r9]
    cmp r10, 4096
    jae .vnud_bad
    mov r11, r10
    shl r11, 3
    lea r9, [rip+vfp_type_is_p0_i8_map]
    add r9, r11
    cmp qword ptr [r9], 1
    jne .vnud_bad

    cmp rcx, r13
    jae .vnud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vnud_bad
    inc rcx
    cmp rcx, r13
    jae .vnud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, 'v'
    jne .vnud_bad
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vnud_bad
    cmp rcx, r13
    jne .vnud_bad

    xor rbx, rbx
.vnud_val_conv:
    cmp r8, rcx
    jae .vnud_val_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vnud_val_conv
.vnud_val_check:
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    jne .vnud_bad
    mov rax, 1
    jmp .vnud_done

.vnud_bad:
    xor rax, rax
.vnud_done:
    pop r13
    pop r12
    pop rbx
    ret

# validate_value_uses_defined
# rdi=line_ptr, rsi=line_len
# out: rax=1 valid, 0 invalid
validate_value_uses_defined:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi

    # parse canonical prefix to locate opcode + args span
    cmp r13, 14
    jb .vvud_bad
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vvud_bad
    mov al, byte ptr [r12+1]
    cmp al, ' '
    jne .vvud_bad
    mov al, byte ptr [r12+2]
    cmp al, 'v'
    jne .vvud_bad
    mov rdi, r12
    mov rsi, r13
    mov rcx, 3
    call parse_digits
    cmp rax, 1
    jne .vvud_bad
    cmp rcx, r13
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vvud_bad
    inc rcx
    cmp rcx, r13
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, '='
    jne .vvud_bad
    inc rcx
    cmp rcx, r13
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vvud_bad
    inc rcx
    cmp rcx, r13
    jae .vvud_bad

    mov r14, rcx                 # op_start
.vvud_op_loop:
    cmp rcx, r13
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, 'a'
    jb .vvud_op_dot
    cmp al, 'z'
    jbe .vvud_op_next
.vvud_op_dot:
    cmp al, '.'
    jne .vvud_op_done
.vvud_op_next:
    inc rcx
    jmp .vvud_op_loop
.vvud_op_done:
    cmp rcx, r14
    je .vvud_bad
    mov r15, rcx                 # op_end
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vvud_bad
    inc rcx
    mov r8, rcx                  # args_start
    cmp r8, r13
    jae .vvud_bad

    # find args_end via trailing " : tN" suffix
    mov r9, r13
    dec r9
    mov r10, r9
.vvud_back_digits:
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .vvud_digits_done
    cmp al, '9'
    ja .vvud_digits_done
    cmp r9, 0
    je .vvud_bad
    dec r9
    jmp .vvud_back_digits
.vvud_digits_done:
    cmp r9, r10
    je .vvud_bad
    cmp r9, 3
    jb .vvud_bad
    mov al, byte ptr [r12+r9]
    cmp al, 't'
    jne .vvud_bad
    mov al, byte ptr [r12+r9-1]
    cmp al, ' '
    jne .vvud_bad
    mov al, byte ptr [r12+r9-2]
    cmp al, ':'
    jne .vvud_bad
    mov al, byte ptr [r12+r9-3]
    cmp al, ' '
    jne .vvud_bad
    mov r11, r9
    sub r11, 3                   # args_end exclusive
    cmp r11, r8
    jbe .vvud_bad

    # bootstrap call def-use check:
    # args must be "fN" or "fN vA vB ...", and each call operand vN must be defined
    mov r10, r15
    sub r10, r14                 # opcode length
    cmp r10, 4
    jne .vvud_detect_const
    mov al, byte ptr [r12+r14]
    cmp al, 'c'
    jne .vvud_detect_const
    mov al, byte ptr [r12+r14+1]
    cmp al, 'a'
    jne .vvud_detect_const
    mov al, byte ptr [r12+r14+2]
    cmp al, 'l'
    jne .vvud_detect_const
    mov al, byte ptr [r12+r14+3]
    cmp al, 'l'
    jne .vvud_detect_const

    mov rcx, r8
    cmp rcx, r11
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, 'f'
    jne .vvud_bad
    inc rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vvud_bad
    cmp rcx, r11
    je .vvud_ok

.vvud_call_arg_loop:
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vvud_bad
    inc rcx
    cmp rcx, r11
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, 'v'
    jne .vvud_bad
    inc rcx
    mov r9, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vvud_bad
    xor rbx, rbx
.vvud_call_v_conv:
    cmp r9, rcx
    jae .vvud_call_v_check
    mov al, byte ptr [r12+r9]
    sub al, '0'
    imul rbx, rbx, 10
    movzx rdx, al
    add rbx, rdx
    inc r9
    jmp .vvud_call_v_conv
.vvud_call_v_check:
    push rcx
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    je .vvud_call_v_seen
    pop rcx
    jmp .vvud_bad
.vvud_call_v_seen:
    pop rcx
    cmp rcx, r11
    je .vvud_ok
    jmp .vvud_call_arg_loop

.vvud_detect_const:
    # bootstrap const shape check:
    # args must be a signed or unsigned decimal literal (no spaces)
    mov r10, r15
    sub r10, r14                 # opcode length
    cmp r10, 5
    jne .vvud_detect_gep
    mov al, byte ptr [r12+r14]
    cmp al, 'c'
    jne .vvud_detect_gep
    mov al, byte ptr [r12+r14+1]
    cmp al, 'o'
    jne .vvud_detect_gep
    mov al, byte ptr [r12+r14+2]
    cmp al, 'n'
    jne .vvud_detect_gep
    mov al, byte ptr [r12+r14+3]
    cmp al, 's'
    jne .vvud_detect_gep
    mov al, byte ptr [r12+r14+4]
    cmp al, 't'
    jne .vvud_detect_gep

    mov rcx, r8
    cmp rcx, r11
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, '-'
    jne .vvud_const_digits
    inc rcx
    cmp rcx, r11
    jae .vvud_bad
.vvud_const_digits:
    mov r9, rcx
.vvud_const_loop:
    cmp rcx, r11
    je .vvud_const_done
    mov al, byte ptr [r12+rcx]
    cmp al, '0'
    jb .vvud_bad
    cmp al, '9'
    ja .vvud_bad
    inc rcx
    jmp .vvud_const_loop
.vvud_const_done:
    cmp r9, rcx
    je .vvud_bad
    jmp .vvud_ok

.vvud_detect_gep:
    # gep def-use/type checks:
    # - result type suffix must be p0<i8>
    # - args must be "vN <signed_decimal>"
    # - pointer operand must be defined and p0<i8>-typed
    mov r10, r15
    sub r10, r14                 # opcode length
    cmp r10, 3
    jne .vvud_detect_ld
    mov al, byte ptr [r12+r14]
    cmp al, 'g'
    jne .vvud_detect_ld
    mov al, byte ptr [r12+r14+1]
    cmp al, 'e'
    jne .vvud_detect_ld
    mov al, byte ptr [r12+r14+2]
    cmp al, 'p'
    jne .vvud_detect_ld

    push r8
    push r11
    mov rdi, r12
    mov rsi, r13
    call parse_value_result_type_id
    cmp rax, 0
    jl .vvud_gep_type_bad
    mov r15, rax
    cmp r15, 4096
    jae .vvud_gep_type_bad
    mov r9, r15
    shl r9, 3
    lea r10, [rip+vfp_type_is_p0_i8_map]
    add r10, r9
    cmp qword ptr [r10], 1
    jne .vvud_gep_type_bad
    pop r11
    pop r8

    mov rcx, r8
    mov al, byte ptr [r12+rcx]
    cmp al, 'v'
    jne .vvud_bad
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vvud_bad
    xor rbx, rbx
.vvud_gep_v_conv:
    cmp r8, rcx
    jae .vvud_gep_v_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vvud_gep_v_conv
.vvud_gep_v_check:
    push rcx
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    je .vvud_gep_v_seen
    pop rcx
    jmp .vvud_bad
.vvud_gep_v_seen:
    pop rcx
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r10, qword ptr [r9]
    cmp r10, 4096
    jae .vvud_bad
    mov r15, r10
    shl r15, 3
    lea r9, [rip+vfp_type_is_p0_i8_map]
    add r9, r15
    cmp qword ptr [r9], 1
    jne .vvud_bad

    cmp rcx, r11
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vvud_bad
    inc rcx
    cmp rcx, r11
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, '-'
    jne .vvud_gep_off_digits
    inc rcx
    cmp rcx, r11
    jae .vvud_bad
.vvud_gep_off_digits:
    mov r9, rcx
.vvud_gep_off_loop:
    cmp rcx, r11
    je .vvud_gep_off_done
    mov al, byte ptr [r12+rcx]
    cmp al, '0'
    jb .vvud_bad
    cmp al, '9'
    ja .vvud_bad
    inc rcx
    jmp .vvud_gep_off_loop
.vvud_gep_off_done:
    cmp r9, rcx
    je .vvud_bad
    jmp .vvud_ok

.vvud_gep_type_bad:
    pop r11
    pop r8
    jmp .vvud_bad

.vvud_detect_ld:
    # ld def-use/type checks:
    # - args must be "vN"
    # - operand must be defined and p0<i8>-typed
    mov r10, r15
    sub r10, r14                 # opcode length
    cmp r10, 2
    jne .vvud_detect_alloca
    mov al, byte ptr [r12+r14]
    cmp al, 'l'
    jne .vvud_detect_alloca
    mov al, byte ptr [r12+r14+1]
    cmp al, 'd'
    jne .vvud_detect_alloca

    mov rcx, r8
    mov al, byte ptr [r12+rcx]
    cmp al, 'v'
    jne .vvud_bad
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vvud_bad
    cmp rcx, r11
    jne .vvud_bad
    xor rbx, rbx
.vvud_ld_v_conv:
    cmp r8, rcx
    jae .vvud_ld_v_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vvud_ld_v_conv
.vvud_ld_v_check:
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    jne .vvud_bad
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r10, qword ptr [r9]
    cmp r10, 4096
    jae .vvud_bad
    mov r11, r10
    shl r11, 3
    lea r9, [rip+vfp_type_is_p0_i8_map]
    add r9, r11
    cmp qword ptr [r9], 1
    jne .vvud_bad
    jmp .vvud_ok

.vvud_detect_alloca:
    # alloca shape/type checks:
    # - result type suffix must be p0<i8>
    # - args must be "tN, N" with known tN and decimal N
    mov r10, r15
    sub r10, r14                 # opcode length
    cmp r10, 6
    jne .vvud_detect_malloc
    mov al, byte ptr [r12+r14]
    cmp al, 'a'
    jne .vvud_detect_malloc
    mov al, byte ptr [r12+r14+1]
    cmp al, 'l'
    jne .vvud_detect_malloc
    mov al, byte ptr [r12+r14+2]
    cmp al, 'l'
    jne .vvud_detect_malloc
    mov al, byte ptr [r12+r14+3]
    cmp al, 'o'
    jne .vvud_detect_malloc
    mov al, byte ptr [r12+r14+4]
    cmp al, 'c'
    jne .vvud_detect_malloc
    mov al, byte ptr [r12+r14+5]
    cmp al, 'a'
    jne .vvud_detect_malloc

    push r8
    push r11
    mov rdi, r12
    mov rsi, r13
    call parse_value_result_type_id
    cmp rax, 0
    jl .vvud_alloca_type_bad
    mov r15, rax
    cmp r15, 4096
    jae .vvud_alloca_type_bad
    mov r9, r15
    shl r9, 3
    lea r10, [rip+vfp_type_is_p0_i8_map]
    add r10, r9
    cmp qword ptr [r10], 1
    jne .vvud_alloca_type_bad
    pop r11
    pop r8

    mov rcx, r8
    mov al, byte ptr [r12+rcx]
    cmp al, 't'
    jne .vvud_bad
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vvud_bad
    xor rbx, rbx
.vvud_alloca_ty_conv:
    cmp r8, rcx
    jae .vvud_alloca_ty_done
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vvud_alloca_ty_conv
.vvud_alloca_ty_done:
    cmp rbx, qword ptr [rip+vfp_type_count]
    jae .vvud_bad
    cmp rcx, r11
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, ','
    jne .vvud_bad
    inc rcx
    cmp rcx, r11
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vvud_bad
    inc rcx
    cmp rcx, r11
    jae .vvud_bad
    mov r9, rcx
.vvud_alloca_n_loop:
    cmp rcx, r11
    je .vvud_alloca_n_done
    mov al, byte ptr [r12+rcx]
    cmp al, '0'
    jb .vvud_bad
    cmp al, '9'
    ja .vvud_bad
    inc rcx
    jmp .vvud_alloca_n_loop
.vvud_alloca_n_done:
    cmp r9, rcx
    je .vvud_bad
    jmp .vvud_ok

.vvud_alloca_type_bad:
    pop r11
    pop r8
    jmp .vvud_bad

.vvud_detect_malloc:
    # malloc def-use/type checks:
    # - result type suffix must be p0<i8>
    # - args must be "vN"
    # - size operand must be defined
    mov r10, r15
    sub r10, r14                 # opcode length
    cmp r10, 6
    jne .vvud_detect_icmp
    mov al, byte ptr [r12+r14]
    cmp al, 'm'
    jne .vvud_detect_icmp
    mov al, byte ptr [r12+r14+1]
    cmp al, 'a'
    jne .vvud_detect_icmp
    mov al, byte ptr [r12+r14+2]
    cmp al, 'l'
    jne .vvud_detect_icmp
    mov al, byte ptr [r12+r14+3]
    cmp al, 'l'
    jne .vvud_detect_icmp
    mov al, byte ptr [r12+r14+4]
    cmp al, 'o'
    jne .vvud_detect_icmp
    mov al, byte ptr [r12+r14+5]
    cmp al, 'c'
    jne .vvud_detect_icmp

    push r8
    push r11
    mov rdi, r12
    mov rsi, r13
    call parse_value_result_type_id
    cmp rax, 0
    jl .vvud_malloc_type_bad
    mov r15, rax
    cmp r15, 4096
    jae .vvud_malloc_type_bad
    mov r9, r15
    shl r9, 3
    lea r10, [rip+vfp_type_is_p0_i8_map]
    add r10, r9
    cmp qword ptr [r10], 1
    jne .vvud_malloc_type_bad
    pop r11
    pop r8

    mov rcx, r8
    mov al, byte ptr [r12+rcx]
    cmp al, 'v'
    jne .vvud_bad
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vvud_bad
    cmp rcx, r11
    jne .vvud_bad
    xor rbx, rbx
.vvud_malloc_v_conv:
    cmp r8, rcx
    jae .vvud_malloc_v_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vvud_malloc_v_conv
.vvud_malloc_v_check:
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    jne .vvud_bad
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r10, qword ptr [r9]
    cmp r10, 4096
    jae .vvud_bad
    mov r11, r10
    shl r11, 3
    lea r9, [rip+vfp_type_is_p0_i8_map]
    add r9, r11
    cmp qword ptr [r9], 1
    je .vvud_bad
    jmp .vvud_ok

.vvud_malloc_type_bad:
    pop r11
    pop r8
    jmp .vvud_bad

.vvud_detect_icmp:
    # icmp.eq def-use/type checks:
    # - result type suffix is i1
    # - args are exactly "vN vN"
    # - both operands are defined
    # - operand types match each other
    mov r10, r15
    sub r10, r14                 # opcode length
    cmp r10, 7
    jne .vvud_detect_binary
    mov al, byte ptr [r12+r14]
    cmp al, 'i'
    jne .vvud_detect_binary
    mov al, byte ptr [r12+r14+1]
    cmp al, 'c'
    jne .vvud_detect_binary
    mov al, byte ptr [r12+r14+2]
    cmp al, 'm'
    jne .vvud_detect_binary
    mov al, byte ptr [r12+r14+3]
    cmp al, 'p'
    jne .vvud_detect_binary
    mov al, byte ptr [r12+r14+4]
    cmp al, '.'
    jne .vvud_detect_binary
    mov al, byte ptr [r12+r14+5]
    cmp al, 'e'
    jne .vvud_detect_binary
    mov al, byte ptr [r12+r14+6]
    cmp al, 'q'
    jne .vvud_detect_binary

    push r8
    push r11
    mov rdi, r12
    mov rsi, r13
    call parse_value_result_type_id
    cmp rax, 0
    jl .vvud_icmp_type_bad
    mov r15, rax
    cmp r15, 4096
    jae .vvud_icmp_type_bad
    mov r9, r15
    shl r9, 3
    lea r10, [rip+vfp_type_is_i1_map]
    add r10, r9
    cmp qword ptr [r10], 1
    jne .vvud_icmp_type_bad
    pop r11
    pop r8

    mov rcx, r8
    mov al, byte ptr [r12+rcx]
    cmp al, 'v'
    jne .vvud_bad
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vvud_bad
    xor rbx, rbx
    mov r9, r8
.vvud_icmp_v1_conv:
    cmp r9, rcx
    jae .vvud_icmp_v1_check
    mov al, byte ptr [r12+r9]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r10, al
    add rbx, r10
    inc r9
    jmp .vvud_icmp_v1_conv
.vvud_icmp_v1_check:
    push rcx
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    je .vvud_icmp_v1_seen
    pop rcx
    jmp .vvud_bad
.vvud_icmp_v1_seen:
    pop rcx
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r15, qword ptr [r9]      # operand 1 type

    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vvud_bad
    inc rcx
    cmp rcx, r11
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, 'v'
    jne .vvud_bad
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vvud_bad
    cmp rcx, r11
    jne .vvud_bad
    xor rbx, rbx
.vvud_icmp_v2_conv:
    cmp r8, rcx
    jae .vvud_icmp_v2_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vvud_icmp_v2_conv
.vvud_icmp_v2_check:
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    jne .vvud_bad
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r11, qword ptr [r9]
    cmp r11, r15
    jne .vvud_bad
    jmp .vvud_ok

.vvud_icmp_type_bad:
    pop r11
    pop r8
    jmp .vvud_bad

.vvud_detect_binary:

    # detect bootstrap binary op set
    mov rdx, 0
    cmp r10, 8
    jne .vvud_bin_short
    mov al, byte ptr [r12+r14]
    cmp al, 'a'
    jne .vvud_chk_sub_wrap
    mov al, byte ptr [r12+r14+1]
    cmp al, 'd'
    jne .vvud_chk_sub_wrap
    mov al, byte ptr [r12+r14+2]
    cmp al, 'd'
    jne .vvud_chk_sub_wrap
    mov al, byte ptr [r12+r14+3]
    cmp al, '.'
    jne .vvud_chk_sub_wrap
    mov al, byte ptr [r12+r14+4]
    cmp al, 'w'
    jne .vvud_chk_sub_wrap
    mov al, byte ptr [r12+r14+5]
    cmp al, 'r'
    jne .vvud_chk_sub_wrap
    mov al, byte ptr [r12+r14+6]
    cmp al, 'a'
    jne .vvud_chk_sub_wrap
    mov al, byte ptr [r12+r14+7]
    cmp al, 'p'
    jne .vvud_chk_sub_wrap
    mov rdx, 1
    jmp .vvud_bin_done
.vvud_chk_sub_wrap:
    mov al, byte ptr [r12+r14]
    cmp al, 'a'
    jne .vvud_chk_sub_wrap_real
    mov al, byte ptr [r12+r14+1]
    cmp al, 'd'
    jne .vvud_chk_sub_wrap_real
    mov al, byte ptr [r12+r14+2]
    cmp al, 'd'
    jne .vvud_chk_sub_wrap_real
    mov al, byte ptr [r12+r14+3]
    cmp al, '.'
    jne .vvud_chk_sub_wrap_real
    mov al, byte ptr [r12+r14+4]
    cmp al, 't'
    jne .vvud_chk_sub_wrap_real
    mov al, byte ptr [r12+r14+5]
    cmp al, 'r'
    jne .vvud_chk_sub_wrap_real
    mov al, byte ptr [r12+r14+6]
    cmp al, 'a'
    jne .vvud_chk_sub_wrap_real
    mov al, byte ptr [r12+r14+7]
    cmp al, 'p'
    jne .vvud_chk_sub_wrap_real
    mov rdx, 1
    jmp .vvud_bin_done
.vvud_chk_sub_wrap_real:
    mov al, byte ptr [r12+r14]
    cmp al, 's'
    jne .vvud_chk_mul_wrap
    mov al, byte ptr [r12+r14+1]
    cmp al, 'u'
    jne .vvud_chk_mul_wrap
    mov al, byte ptr [r12+r14+2]
    cmp al, 'b'
    jne .vvud_chk_mul_wrap
    mov al, byte ptr [r12+r14+3]
    cmp al, '.'
    jne .vvud_chk_mul_wrap
    mov al, byte ptr [r12+r14+4]
    cmp al, 't'
    jne .vvud_chk_sub_wrap_variant_wrap
    mov al, byte ptr [r12+r14+5]
    cmp al, 'r'
    jne .vvud_chk_mul_wrap
    mov al, byte ptr [r12+r14+6]
    cmp al, 'a'
    jne .vvud_chk_mul_wrap
    mov al, byte ptr [r12+r14+7]
    cmp al, 'p'
    jne .vvud_chk_mul_wrap
    mov rdx, 1
    jmp .vvud_bin_done

.vvud_chk_sub_wrap_variant_wrap:
    mov al, byte ptr [r12+r14+4]
    cmp al, 'w'
    jne .vvud_chk_mul_wrap
    mov al, byte ptr [r12+r14+5]
    cmp al, 'r'
    jne .vvud_chk_mul_wrap
    mov al, byte ptr [r12+r14+6]
    cmp al, 'a'
    jne .vvud_chk_mul_wrap
    mov al, byte ptr [r12+r14+7]
    cmp al, 'p'
    jne .vvud_chk_mul_wrap
    mov rdx, 1
    jmp .vvud_bin_done
.vvud_chk_mul_wrap:
    mov al, byte ptr [r12+r14]
    cmp al, 'm'
    jne .vvud_bin_short
    mov al, byte ptr [r12+r14+1]
    cmp al, 'u'
    jne .vvud_bin_short
    mov al, byte ptr [r12+r14+2]
    cmp al, 'l'
    jne .vvud_bin_short
    mov al, byte ptr [r12+r14+3]
    cmp al, '.'
    jne .vvud_bin_short
    mov al, byte ptr [r12+r14+4]
    cmp al, 't'
    jne .vvud_chk_mul_wrap_variant_wrap
    mov al, byte ptr [r12+r14+5]
    cmp al, 'r'
    jne .vvud_bin_short
    mov al, byte ptr [r12+r14+6]
    cmp al, 'a'
    jne .vvud_bin_short
    mov al, byte ptr [r12+r14+7]
    cmp al, 'p'
    jne .vvud_bin_short
    mov rdx, 1
    jmp .vvud_bin_done

.vvud_chk_mul_wrap_variant_wrap:
    mov al, byte ptr [r12+r14+4]
    cmp al, 'w'
    jne .vvud_bin_short
    mov al, byte ptr [r12+r14+5]
    cmp al, 'r'
    jne .vvud_bin_short
    mov al, byte ptr [r12+r14+6]
    cmp al, 'a'
    jne .vvud_bin_short
    mov al, byte ptr [r12+r14+7]
    cmp al, 'p'
    jne .vvud_bin_short
    mov rdx, 1
    jmp .vvud_bin_done

.vvud_bin_short:
    cmp r10, 2
    jne .vvud_bin_len3
    mov al, byte ptr [r12+r14]
    cmp al, 'o'
    jne .vvud_bin_len3
    mov al, byte ptr [r12+r14+1]
    cmp al, 'r'
    jne .vvud_bin_len3
    mov rdx, 1
    jmp .vvud_bin_done
.vvud_bin_len3:
    cmp r10, 3
    jne .vvud_ok
    mov al, byte ptr [r12+r14]
    cmp al, 'a'
    jne .vvud_chk_xor
    mov al, byte ptr [r12+r14+1]
    cmp al, 'n'
    jne .vvud_chk_xor
    mov al, byte ptr [r12+r14+2]
    cmp al, 'd'
    jne .vvud_chk_xor
    mov rdx, 1
    jmp .vvud_bin_done
.vvud_chk_xor:
    mov al, byte ptr [r12+r14]
    cmp al, 'x'
    jne .vvud_chk_shl
    mov al, byte ptr [r12+r14+1]
    cmp al, 'o'
    jne .vvud_chk_shl
    mov al, byte ptr [r12+r14+2]
    cmp al, 'r'
    jne .vvud_chk_shl
    mov rdx, 1
    jmp .vvud_bin_done
.vvud_chk_shl:
    mov al, byte ptr [r12+r14]
    cmp al, 's'
    jne .vvud_chk_shr
    mov al, byte ptr [r12+r14+1]
    cmp al, 'h'
    jne .vvud_chk_shr
    mov al, byte ptr [r12+r14+2]
    cmp al, 'l'
    jne .vvud_chk_shr
    mov rdx, 1
    jmp .vvud_bin_done
.vvud_chk_shr:
    mov al, byte ptr [r12+r14]
    cmp al, 's'
    jne .vvud_ok
    mov al, byte ptr [r12+r14+1]
    cmp al, 'h'
    jne .vvud_ok
    mov al, byte ptr [r12+r14+2]
    cmp al, 'r'
    jne .vvud_ok
    mov rdx, 1

.vvud_bin_done:
    cmp rdx, 1
    jne .vvud_ok
    # for binary ops, operand value types must match explicit result type suffix
    push r8
    push r11
    mov rdi, r12
    mov rsi, r13
    call parse_value_result_type_id
    cmp rax, 0
    jl .vvud_bin_type_bad
    mov r15, rax
    pop r11
    pop r8

    # binary args must be "vN vN" and both vN must already be defined
    mov rcx, r8
    mov al, byte ptr [r12+rcx]
    cmp al, 'v'
    jne .vvud_bad
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vvud_bad
    xor rbx, rbx
    mov r9, r8
.vvud_v1_conv:
    cmp r9, rcx
    jae .vvud_v1_check
    mov al, byte ptr [r12+r9]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r10, al
    add rbx, r10
    inc r9
    jmp .vvud_v1_conv
.vvud_v1_check:
    push rcx
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    je .vvud_v1_seen
    pop rcx
    jmp .vvud_bad
.vvud_v1_seen:
    pop rcx
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r10, qword ptr [r9]
    cmp r10, r15
    jne .vvud_bad

    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vvud_bad
    inc rcx
    cmp rcx, r11
    jae .vvud_bad
    mov al, byte ptr [r12+rcx]
    cmp al, 'v'
    jne .vvud_bad
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vvud_bad
    cmp rcx, r11
    jne .vvud_bad
    xor rbx, rbx
.vvud_v2_conv:
    cmp r8, rcx
    jae .vvud_v2_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vvud_v2_conv
.vvud_v2_check:
    mov rdi, rbx
    call value_seen_exists
    cmp rax, 1
    jne .vvud_bad
    mov r8, rbx
    shl r8, 3
    lea r9, [rip+vfp_value_type_map]
    add r9, r8
    mov r10, qword ptr [r9]
    cmp r10, r15
    jne .vvud_bad

.vvud_ok:
    mov rax, 1
    jmp .vvud_done
.vvud_bad:
    xor rax, rax
.vvud_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

.vvud_bin_type_bad:
    pop r11
    pop r8
    jmp .vvud_bad

# block_seen_exists
# rdi=block_id
# out: rax=1 if seen, 0 if not seen
block_seen_exists:
    cmp rdi, 16384
    jae .bse_no
    mov r8, rdi
    shr r8, 3
    mov r9, rdi
    and r9, 7
    lea r10, [rip+vfp_block_seen_map]
    add r10, r8
    mov al, byte ptr [r10]
    mov dl, 1
    mov cl, r9b
    shl dl, cl
    test al, dl
    jne .bse_yes
.bse_no:
    xor rax, rax
    ret
.bse_yes:
    mov rax, 1
    ret

# verify_branch_targets_in_function
# rdi=fn_body_ptr, rsi=fn_body_len (bytes up to function-close line)
# out: rax=1 valid, 0 invalid
verify_branch_targets_in_function:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r14, rdi
    mov r15, rsi

.vbt_next_line:
    cmp r15, 0
    je .vbt_ok

    xor rcx, rcx
.vbt_find_nl:
    cmp rcx, r15
    jae .vbt_bad
    mov al, byte ptr [r14+rcx]
    cmp al, 10
    je .vbt_line_ready
    inc rcx
    jmp .vbt_find_nl

.vbt_line_ready:
    cmp rcx, 0
    je .vbt_bad
    mov r12, r14
    mov r13, rcx

    lea r14, [r14+rcx+1]
    sub r15, rcx
    dec r15

    # Check "  br bN"
    cmp r13, 7
    jb .vbt_try_cbr
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vbt_try_cbr
    mov al, byte ptr [r12+1]
    cmp al, ' '
    jne .vbt_try_cbr
    mov al, byte ptr [r12+2]
    cmp al, 'b'
    jne .vbt_try_cbr
    mov al, byte ptr [r12+3]
    cmp al, 'r'
    jne .vbt_try_cbr
    mov al, byte ptr [r12+4]
    cmp al, ' '
    jne .vbt_try_cbr
    mov al, byte ptr [r12+5]
    cmp al, 'b'
    jne .vbt_try_cbr
    mov rdi, r12
    mov rsi, r13
    mov rcx, 6
    call parse_digits
    cmp rax, 1
    jne .vbt_try_cbr
    cmp rcx, r13
    jne .vbt_try_cbr
    xor rbx, rbx
    mov r8, 6
.vbt_br_conv:
    cmp r8, rcx
    jae .vbt_br_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vbt_br_conv
.vbt_br_check:
    mov rdi, rbx
    call block_seen_exists
    cmp rax, 1
    jne .vbt_bad
    jmp .vbt_next_line

.vbt_try_cbr:
    cmp r13, 12
    jb .vbt_next_line
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vbt_next_line
    mov al, byte ptr [r12+1]
    cmp al, ' '
    jne .vbt_next_line
    mov al, byte ptr [r12+2]
    cmp al, 'c'
    jne .vbt_next_line
    mov al, byte ptr [r12+3]
    cmp al, 'b'
    jne .vbt_next_line
    mov al, byte ptr [r12+4]
    cmp al, 'r'
    jne .vbt_next_line
    mov al, byte ptr [r12+5]
    cmp al, ' '
    jne .vbt_next_line
    mov al, byte ptr [r12+6]
    cmp al, 'v'
    jne .vbt_next_line

    mov rdi, r12
    mov rsi, r13
    mov rcx, 7
    call parse_digits
    cmp rax, 1
    jne .vbt_bad
    cmp rcx, r13
    jae .vbt_bad
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vbt_bad
    inc rcx
    cmp rcx, r13
    jae .vbt_bad
    mov al, byte ptr [r12+rcx]
    cmp al, 'b'
    jne .vbt_bad
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vbt_bad
    cmp rcx, r13
    jae .vbt_bad
    xor rbx, rbx
.vbt_cbr_t1_conv:
    cmp r8, rcx
    jae .vbt_cbr_t1_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vbt_cbr_t1_conv
.vbt_cbr_t1_check:
    mov r11, rcx
    mov rdi, rbx
    call block_seen_exists
    cmp rax, 1
    jne .vbt_bad
    mov rcx, r11

    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vbt_bad
    inc rcx
    cmp rcx, r13
    jae .vbt_bad
    mov al, byte ptr [r12+rcx]
    cmp al, 'b'
    jne .vbt_bad
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vbt_bad
    cmp rcx, r13
    jne .vbt_bad
    xor rbx, rbx
.vbt_cbr_t2_conv:
    cmp r8, rcx
    jae .vbt_cbr_t2_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul rbx, rbx, 10
    movzx r9, al
    add rbx, r9
    inc r8
    jmp .vbt_cbr_t2_conv
.vbt_cbr_t2_check:
    mov rdi, rbx
    call block_seen_exists
    cmp rax, 1
    jne .vbt_bad
    jmp .vbt_next_line

.vbt_bad:
    xor rax, rax
    jmp .vbt_done
.vbt_ok:
    mov rax, 1
.vbt_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

# verify_call_targets_in_module
# rdi=fns_body_ptr, rsi=fns_body_len (bytes up to closing fns line)
# uses vfp_last_fn_id to derive function count
# out: rax=1 valid, 0 invalid
verify_call_targets_in_module:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r14, rdi
    mov r15, rsi
    mov rbx, qword ptr [rip+vfp_last_fn_id]
    inc rbx                      # fn_count

.vctm_next_line:
    cmp r15, 0
    je .vctm_ok

    xor rcx, rcx
.vctm_find_nl:
    cmp rcx, r15
    jae .vctm_bad
    mov al, byte ptr [r14+rcx]
    cmp al, 10
    je .vctm_line_ready
    inc rcx
    jmp .vctm_find_nl

.vctm_line_ready:
    cmp rcx, 0
    je .vctm_bad
    mov r12, r14
    mov r13, rcx

    lea r14, [r14+rcx+1]
    sub r15, rcx
    dec r15

    # detect value call prefix: "  vN = call fN"
    cmp r13, 14
    jb .vctm_next_line
    mov al, byte ptr [r12]
    cmp al, ' '
    jne .vctm_next_line
    mov al, byte ptr [r12+1]
    cmp al, ' '
    jne .vctm_next_line
    mov al, byte ptr [r12+2]
    cmp al, 'v'
    jne .vctm_next_line
    mov rdi, r12
    mov rsi, r13
    mov rcx, 3
    call parse_digits
    cmp rax, 1
    jne .vctm_next_line
    cmp rcx, r13
    jae .vctm_next_line
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vctm_next_line
    inc rcx
    cmp rcx, r13
    jae .vctm_next_line
    mov al, byte ptr [r12+rcx]
    cmp al, '='
    jne .vctm_next_line
    inc rcx
    cmp rcx, r13
    jae .vctm_next_line
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vctm_next_line
    inc rcx
    cmp rcx, r13
    jae .vctm_next_line
    mov al, byte ptr [r12+rcx]
    cmp al, 'c'
    jne .vctm_next_line
    inc rcx
    cmp rcx, r13
    jae .vctm_next_line
    mov al, byte ptr [r12+rcx]
    cmp al, 'a'
    jne .vctm_next_line
    inc rcx
    cmp rcx, r13
    jae .vctm_next_line
    mov al, byte ptr [r12+rcx]
    cmp al, 'l'
    jne .vctm_next_line
    inc rcx
    cmp rcx, r13
    jae .vctm_next_line
    mov al, byte ptr [r12+rcx]
    cmp al, 'l'
    jne .vctm_next_line
    inc rcx
    cmp rcx, r13
    jae .vctm_next_line
    mov al, byte ptr [r12+rcx]
    cmp al, ' '
    jne .vctm_next_line
    inc rcx
    cmp rcx, r13
    jae .vctm_next_line
    mov al, byte ptr [r12+rcx]
    cmp al, 'f'
    jne .vctm_next_line
    inc rcx
    mov r8, rcx
    mov rdi, r12
    mov rsi, r13
    call parse_digits
    cmp rax, 1
    jne .vctm_bad
    xor r9, r9
.vctm_fid_conv:
    cmp r8, rcx
    jae .vctm_fid_check
    mov al, byte ptr [r12+r8]
    sub al, '0'
    imul r9, r9, 10
    movzx r10, al
    add r9, r10
    inc r8
    jmp .vctm_fid_conv
.vctm_fid_check:
    cmp r9, rbx
    jae .vctm_bad
    push rcx
    push r9
    # call result type must match callee return type
    mov rdi, r12
    mov rsi, r13
    call parse_value_result_type_id
    cmp rax, 0
    jl .vctm_fid_check_badpop
    mov r8, qword ptr [rsp]       # saved target function id
    cmp r8, 4096
    jae .vctm_fid_check_badpop
    shl r8, 3
    lea rcx, [rip+vfp_fn_ret_type_map]
    add rcx, r8
    cmp rax, qword ptr [rcx]
    jne .vctm_fid_check_badpop
    pop r9
    pop rcx

    # count call operands in args tail and enforce exact callee arity
    mov r8, rcx                   # cursor after callee fN
    xor r10, r10                  # call_arg_count

    # locate suffix start by scanning backward for " : tN"
    mov rcx, r13
    dec rcx
    mov r11, rcx
.vctm_back_digits:
    mov al, byte ptr [r12+rcx]
    cmp al, '0'
    jb .vctm_digits_done
    cmp al, '9'
    ja .vctm_digits_done
    cmp rcx, 0
    je .vctm_bad
    dec rcx
    jmp .vctm_back_digits
.vctm_digits_done:
    cmp rcx, r11
    je .vctm_bad
    cmp rcx, 3
    jb .vctm_bad
    mov al, byte ptr [r12+rcx]
    cmp al, 't'
    jne .vctm_bad
    mov al, byte ptr [r12+rcx-1]
    cmp al, ' '
    jne .vctm_bad
    mov al, byte ptr [r12+rcx-2]
    cmp al, ':'
    jne .vctm_bad
    mov al, byte ptr [r12+rcx-3]
    cmp al, ' '
    jne .vctm_bad
    mov r11, rcx
    sub r11, 3                    # args_end exclusive

    cmp r8, r11
    je .vctm_check_arity
.vctm_call_arg_loop:
    cmp r8, r11
    jae .vctm_bad
    mov al, byte ptr [r12+r8]
    cmp al, ' '
    jne .vctm_bad
    inc r8
    cmp r8, r11
    jae .vctm_bad
    mov al, byte ptr [r12+r8]
    cmp al, 'v'
    jne .vctm_bad
    inc r8
    mov rdi, r12
    mov rsi, r11
    mov rcx, r8
    call parse_digits
    cmp rax, 1
    jne .vctm_bad
    mov r8, rcx
    inc r10
    cmp r8, r11
    je .vctm_check_arity
    jmp .vctm_call_arg_loop

.vctm_check_arity:
    cmp r9, 4096
    jae .vctm_bad
    mov r8, r9
    shl r8, 3
    lea rcx, [rip+vfp_fn_arg_count_map]
    add rcx, r8
    mov rax, qword ptr [rcx]
    cmp r10, rax
    jne .vctm_bad
    jmp .vctm_next_line

.vctm_fid_check_badpop:
    pop r9
    pop rcx
    jmp .vctm_bad

.vctm_bad:
    xor rax, rax
    jmp .vctm_done
.vctm_ok:
    mov rax, 1
.vctm_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

# rdi=line_ptr, rsi=line_len -> rax=1 if starts with "  "
line_is_instruction:
    cmp rsi, 3
    jb .lin_no
    mov al, byte ptr [rdi]
    cmp al, ' '
    jne .lin_no
    mov al, byte ptr [rdi+1]
    cmp al, ' '
    jne .lin_no
    mov rax, 1
    ret
.lin_no:
    xor rax, rax
    ret

# rdi=line_ptr, rsi=line_len -> rax=1 if terminator
# accepted:
# "  ret"
# "  ret vN"
# "  br bN"
# "  cbr vN bN bN"
line_is_terminator:
    cmp rsi, 5
    jb .lterm_try_retv
    mov al, byte ptr [rdi]
    cmp al, ' '
    jne .lterm_try_retv
    mov al, byte ptr [rdi+1]
    cmp al, ' '
    jne .lterm_try_retv
    mov al, byte ptr [rdi+2]
    cmp al, 'r'
    jne .lterm_try_retv
    mov al, byte ptr [rdi+3]
    cmp al, 'e'
    jne .lterm_try_retv
    mov al, byte ptr [rdi+4]
    cmp al, 't'
    jne .lterm_try_retv
    cmp rsi, 5
    je .lterm_yes

.lterm_try_retv:
    cmp rsi, 8
    jb .lterm_try_br
    mov al, byte ptr [rdi]
    cmp al, ' '
    jne .lterm_try_br
    mov al, byte ptr [rdi+1]
    cmp al, ' '
    jne .lterm_try_br
    mov al, byte ptr [rdi+2]
    cmp al, 'r'
    jne .lterm_try_br
    mov al, byte ptr [rdi+3]
    cmp al, 'e'
    jne .lterm_try_br
    mov al, byte ptr [rdi+4]
    cmp al, 't'
    jne .lterm_try_br
    mov al, byte ptr [rdi+5]
    cmp al, ' '
    jne .lterm_try_br
    mov al, byte ptr [rdi+6]
    cmp al, 'v'
    jne .lterm_try_br
    mov rcx, 7
    call parse_digits
    cmp rax, 1
    jne .lterm_try_br
    cmp rcx, rsi
    je .lterm_yes

.lterm_try_br:
    cmp rsi, 7
    jb .lterm_try_cbr
    mov al, byte ptr [rdi]
    cmp al, ' '
    jne .lterm_try_cbr
    mov al, byte ptr [rdi+1]
    cmp al, ' '
    jne .lterm_try_cbr
    mov al, byte ptr [rdi+2]
    cmp al, 'b'
    jne .lterm_try_cbr
    mov al, byte ptr [rdi+3]
    cmp al, 'r'
    jne .lterm_try_cbr
    mov al, byte ptr [rdi+4]
    cmp al, ' '
    jne .lterm_try_cbr
    mov al, byte ptr [rdi+5]
    cmp al, 'b'
    jne .lterm_try_cbr
    mov rcx, 6
    call parse_digits
    cmp rax, 1
    jne .lterm_try_cbr
    cmp rcx, rsi
    je .lterm_yes

.lterm_try_cbr:
    cmp rsi, 12
    jb .lterm_no
    mov al, byte ptr [rdi]
    cmp al, ' '
    jne .lterm_no
    mov al, byte ptr [rdi+1]
    cmp al, ' '
    jne .lterm_no
    mov al, byte ptr [rdi+2]
    cmp al, 'c'
    jne .lterm_no
    mov al, byte ptr [rdi+3]
    cmp al, 'b'
    jne .lterm_no
    mov al, byte ptr [rdi+4]
    cmp al, 'r'
    jne .lterm_no
    mov al, byte ptr [rdi+5]
    cmp al, ' '
    jne .lterm_no
    mov al, byte ptr [rdi+6]
    cmp al, 'v'
    jne .lterm_no
    mov rcx, 7
    call parse_digits
    cmp rax, 1
    jne .lterm_no
    cmp rcx, rsi
    jae .lterm_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lterm_no
    inc rcx
    cmp rcx, rsi
    jae .lterm_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'b'
    jne .lterm_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lterm_no
    cmp rcx, rsi
    jae .lterm_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lterm_no
    inc rcx
    cmp rcx, rsi
    jae .lterm_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'b'
    jne .lterm_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lterm_no
    cmp rcx, rsi
    je .lterm_yes

.lterm_no:
    xor rax, rax
    ret
.lterm_yes:
    mov rax, 1
    ret

# rdi=line_ptr, rsi=line_len -> rax=1 if canonical non-value instruction
# currently accepted:
# "  st vN vN"
# "  free vN"
# "  exit vN"
# "  write vN vN"
# "  trace N vN"
line_is_nonvalue_instruction:
    # trace N vN
    cmp rsi, 12
    jb .lnvi_try_write
    mov al, byte ptr [rdi]
    cmp al, ' '
    jne .lnvi_try_write
    mov al, byte ptr [rdi+1]
    cmp al, ' '
    jne .lnvi_try_write
    mov al, byte ptr [rdi+2]
    cmp al, 't'
    jne .lnvi_try_write
    mov al, byte ptr [rdi+3]
    cmp al, 'r'
    jne .lnvi_try_write
    mov al, byte ptr [rdi+4]
    cmp al, 'a'
    jne .lnvi_try_write
    mov al, byte ptr [rdi+5]
    cmp al, 'c'
    jne .lnvi_try_write
    mov al, byte ptr [rdi+6]
    cmp al, 'e'
    jne .lnvi_try_write
    mov al, byte ptr [rdi+7]
    cmp al, ' '
    jne .lnvi_try_write
    mov rcx, 8
    call parse_digits
    cmp rax, 1
    jne .lnvi_try_write
    cmp rcx, rsi
    jae .lnvi_try_write
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lnvi_try_write
    inc rcx
.lnvi_trace_v_loop:
    cmp rcx, rsi
    jae .lnvi_try_write
    mov al, byte ptr [rdi+rcx]
    cmp al, 'v'
    jne .lnvi_try_write
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lnvi_try_write
    cmp rcx, rsi
    je .lnvi_yes
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lnvi_try_write
    inc rcx
    jmp .lnvi_trace_v_loop

.lnvi_try_write:
    # write vN vN
    cmp rsi, 11
    jb .lnvi_try_exit
    mov al, byte ptr [rdi]
    cmp al, ' '
    jne .lnvi_try_exit
    mov al, byte ptr [rdi+1]
    cmp al, ' '
    jne .lnvi_try_exit
    mov al, byte ptr [rdi+2]
    cmp al, 'w'
    jne .lnvi_try_exit
    mov al, byte ptr [rdi+3]
    cmp al, 'r'
    jne .lnvi_try_exit
    mov al, byte ptr [rdi+4]
    cmp al, 'i'
    jne .lnvi_try_exit
    mov al, byte ptr [rdi+5]
    cmp al, 't'
    jne .lnvi_try_exit
    mov al, byte ptr [rdi+6]
    cmp al, 'e'
    jne .lnvi_try_exit
    mov al, byte ptr [rdi+7]
    cmp al, ' '
    jne .lnvi_try_exit
    mov al, byte ptr [rdi+8]
    cmp al, 'v'
    jne .lnvi_try_exit
    mov rcx, 9
    call parse_digits
    cmp rax, 1
    jne .lnvi_try_exit
    cmp rcx, rsi
    jae .lnvi_try_exit
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lnvi_try_exit
    inc rcx
    cmp rcx, rsi
    jae .lnvi_try_exit
    mov al, byte ptr [rdi+rcx]
    cmp al, 'v'
    jne .lnvi_try_exit
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lnvi_try_exit
    cmp rcx, rsi
    je .lnvi_yes

.lnvi_try_exit:
    # exit vN
    cmp rsi, 9
    jb .lnvi_try_free
    mov al, byte ptr [rdi]
    cmp al, ' '
    jne .lnvi_try_free
    mov al, byte ptr [rdi+1]
    cmp al, ' '
    jne .lnvi_try_free
    mov al, byte ptr [rdi+2]
    cmp al, 'e'
    jne .lnvi_try_free
    mov al, byte ptr [rdi+3]
    cmp al, 'x'
    jne .lnvi_try_free
    mov al, byte ptr [rdi+4]
    cmp al, 'i'
    jne .lnvi_try_free
    mov al, byte ptr [rdi+5]
    cmp al, 't'
    jne .lnvi_try_free
    mov al, byte ptr [rdi+6]
    cmp al, ' '
    jne .lnvi_try_free
    mov al, byte ptr [rdi+7]
    cmp al, 'v'
    jne .lnvi_try_free
    mov rcx, 8
    call parse_digits
    cmp rax, 1
    jne .lnvi_try_free
    cmp rcx, rsi
    je .lnvi_yes

.lnvi_try_free:
    # free vN
    cmp rsi, 9
    jb .lnvi_try_st
    mov al, byte ptr [rdi]
    cmp al, ' '
    jne .lnvi_try_st
    mov al, byte ptr [rdi+1]
    cmp al, ' '
    jne .lnvi_try_st
    mov al, byte ptr [rdi+2]
    cmp al, 'f'
    jne .lnvi_try_st
    mov al, byte ptr [rdi+3]
    cmp al, 'r'
    jne .lnvi_try_st
    mov al, byte ptr [rdi+4]
    cmp al, 'e'
    jne .lnvi_try_st
    mov al, byte ptr [rdi+5]
    cmp al, 'e'
    jne .lnvi_try_st
    mov al, byte ptr [rdi+6]
    cmp al, ' '
    jne .lnvi_try_st
    mov al, byte ptr [rdi+7]
    cmp al, 'v'
    jne .lnvi_try_st
    mov rcx, 8
    call parse_digits
    cmp rax, 1
    jne .lnvi_try_st
    cmp rcx, rsi
    je .lnvi_yes

.lnvi_try_st:
    cmp rsi, 10
    jb .lnvi_no
    mov al, byte ptr [rdi]
    cmp al, ' '
    jne .lnvi_no
    mov al, byte ptr [rdi+1]
    cmp al, ' '
    jne .lnvi_no
    mov al, byte ptr [rdi+2]
    cmp al, 's'
    jne .lnvi_no
    mov al, byte ptr [rdi+3]
    cmp al, 't'
    jne .lnvi_no
    mov al, byte ptr [rdi+4]
    cmp al, ' '
    jne .lnvi_no
    mov al, byte ptr [rdi+5]
    cmp al, 'v'
    jne .lnvi_no
    mov rcx, 6
    call parse_digits
    cmp rax, 1
    jne .lnvi_no
    cmp rcx, rsi
    jae .lnvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lnvi_no
    inc rcx
    cmp rcx, rsi
    jae .lnvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'v'
    jne .lnvi_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lnvi_no
    cmp rcx, rsi
    jne .lnvi_no
    mov rax, 1
    ret
.lnvi_no:
    xor rax, rax
    ret
.lnvi_yes:
    mov rax, 1
    ret

# rdi=line_ptr, rsi=line_len -> rax=1 if canonical value instruction:
# "  vN = <opcode> <args> : tN"
line_is_value_instruction:
    push r12
    push r13
    push r14
    push r15

    cmp rsi, 14
    jb .lvi_no

    # prefix "  v"
    mov al, byte ptr [rdi]
    cmp al, ' '
    jne .lvi_no
    mov al, byte ptr [rdi+1]
    cmp al, ' '
    jne .lvi_no
    mov al, byte ptr [rdi+2]
    cmp al, 'v'
    jne .lvi_no

    # lhs id
    mov rcx, 3
    call parse_digits
    cmp rax, 1
    jne .lvi_no
    cmp rcx, rsi
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lvi_no
    inc rcx
    cmp rcx, rsi
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, '='
    jne .lvi_no
    inc rcx
    cmp rcx, rsi
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lvi_no
    inc rcx
    cmp rcx, rsi
    jae .lvi_no

    # opcode token: [a-z.]+ then single space
    mov r12, rcx                 # op_start
.lvi_op_loop:
    cmp rcx, rsi
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'a'
    jb .lvi_op_dot
    cmp al, 'z'
    jbe .lvi_op_next
.lvi_op_dot:
    cmp al, '.'
    jne .lvi_op_done
.lvi_op_next:
    inc rcx
    jmp .lvi_op_loop
.lvi_op_done:
    cmp rcx, r12
    je .lvi_no
    mov r13, rcx                 # op_end
    cmp rcx, rsi
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lvi_no
    inc rcx
    mov r14, rcx                 # args_start
    cmp r14, rsi
    jae .lvi_no

    # suffix from end: "... : tN"
    mov r9, rsi
    dec r9                       # last index
    mov r10, r9
.lvi_back_digits:
    mov al, byte ptr [rdi+r9]
    cmp al, '0'
    jb .lvi_digits_done
    cmp al, '9'
    ja .lvi_digits_done
    cmp r9, 0
    je .lvi_digits_done_after_dec
    dec r9
    jmp .lvi_back_digits
.lvi_digits_done_after_dec:
    # consumed down to index 0 digit
    jmp .lvi_no
.lvi_digits_done:
    cmp r9, r10                  # no trailing digits
    je .lvi_no
    cmp r9, 3
    jb .lvi_no
    mov al, byte ptr [rdi+r9]
    cmp al, 't'
    jne .lvi_no
    mov al, byte ptr [rdi+r9-1]
    cmp al, ' '
    jne .lvi_no
    mov al, byte ptr [rdi+r9-2]
    cmp al, ':'
    jne .lvi_no
    mov al, byte ptr [rdi+r9-3]
    cmp al, ' '
    jne .lvi_no
    # enforce value result type id exists in module type table
    xor r8, r8
    mov r11, r10
    inc r11
    mov rdx, r9
    inc rdx
.lvi_type_id_conv:
    cmp rdx, r11
    jae .lvi_type_id_done
    mov al, byte ptr [rdi+rdx]
    sub al, '0'
    imul r8, r8, 10
    movzx r10, al
    add r8, r10
    inc rdx
    jmp .lvi_type_id_conv
.lvi_type_id_done:
    cmp r8, qword ptr [rip+vfp_type_count]
    jae .lvi_no

    mov r15, r9
    sub r15, 3                   # args_end (exclusive), suffix start
    cmp r15, r14                 # args must be non-empty
    jbe .lvi_no

    # opcode-aware checks
    # "arg" => args must be digits only
    mov r10, r13
    sub r10, r12
    cmp r10, 3
    jne .lvi_check_call
    mov al, byte ptr [rdi+r12]
    cmp al, 'a'
    jne .lvi_check_call
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'r'
    jne .lvi_check_call
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'g'
    jne .lvi_check_call
    # digits-only span [r14, r15)
    mov rcx, r14
    cmp rcx, r15
    jae .lvi_no
    xor r10, r10
.lvi_arg_digits:
    cmp rcx, r15
    je .lvi_arg_done
    mov al, byte ptr [rdi+rcx]
    cmp al, '0'
    jb .lvi_no
    cmp al, '9'
    ja .lvi_no
    imul r10, r10, 10
    movzx r11, al
    sub r11, '0'
    add r10, r11
    inc rcx
    jmp .lvi_arg_digits

.lvi_arg_done:
    cmp r10, qword ptr [rip+vfp_fn_arg_count]
    jae .lvi_no
    # arg result type must match declared function arg type
    mov r11, r10
    shl r11, 3
    lea r9, [rip+vfp_fn_arg_type_map]
    add r9, r11
    mov r11, qword ptr [r9]
    cmp r8, r11
    jne .lvi_no
    jmp .lvi_yes

.lvi_check_call:
    # "call" => args must be "fN" or "fN vA vB ..."
    cmp r10, 4
    jne .lvi_check_const
    mov al, byte ptr [rdi+r12]
    cmp al, 'c'
    jne .lvi_check_const
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'a'
    jne .lvi_check_const
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'l'
    jne .lvi_check_const
    mov al, byte ptr [rdi+r12+3]
    cmp al, 'l'
    jne .lvi_check_const

    mov rcx, r14
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'f'
    jne .lvi_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lvi_no
    cmp rcx, r15
    je .lvi_yes

.lvi_call_arg_loop:
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lvi_no
    inc rcx
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'v'
    jne .lvi_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lvi_no
    cmp rcx, r15
    je .lvi_yes
    jmp .lvi_call_arg_loop

.lvi_check_const:
    # const args must be signed/unsigned decimal literal (no spaces)
    cmp r10, 5
    jne .lvi_check_gep
    mov al, byte ptr [rdi+r12]
    cmp al, 'c'
    jne .lvi_check_icmp
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'o'
    jne .lvi_check_icmp
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'n'
    jne .lvi_check_icmp
    mov al, byte ptr [rdi+r12+3]
    cmp al, 's'
    jne .lvi_check_icmp
    mov al, byte ptr [rdi+r12+4]
    cmp al, 't'
    jne .lvi_check_gep

    mov rcx, r14
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, '-'
    jne .lvi_const_digits
    inc rcx
    cmp rcx, r15
    jae .lvi_no
.lvi_const_digits:
    mov r11, rcx
.lvi_const_loop:
    cmp rcx, r15
    je .lvi_const_done
    mov al, byte ptr [rdi+rcx]
    cmp al, '0'
    jb .lvi_no
    cmp al, '9'
    ja .lvi_no
    inc rcx
    jmp .lvi_const_loop
.lvi_const_done:
    cmp r11, rcx
    je .lvi_no
    jmp .lvi_yes

.lvi_check_gep:
    # gep args must be "vN <signed_decimal>", result type must be p0<i8>
    cmp r10, 3
    jne .lvi_check_ld
    mov al, byte ptr [rdi+r12]
    cmp al, 'g'
    jne .lvi_check_ld
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'e'
    jne .lvi_check_ld
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'p'
    jne .lvi_check_ld
    cmp r8, 4096
    jae .lvi_no
    mov r11, r8
    shl r11, 3
    lea r9, [rip+vfp_type_is_p0_i8_map]
    add r9, r11
    cmp qword ptr [r9], 1
    jne .lvi_no

    mov rcx, r14
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'v'
    jne .lvi_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lvi_no
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lvi_no
    inc rcx
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, '-'
    jne .lvi_gep_off_digits
    inc rcx
    cmp rcx, r15
    jae .lvi_no
.lvi_gep_off_digits:
    mov r11, rcx
.lvi_gep_off_loop:
    cmp rcx, r15
    je .lvi_gep_off_done
    mov al, byte ptr [rdi+rcx]
    cmp al, '0'
    jb .lvi_no
    cmp al, '9'
    ja .lvi_no
    inc rcx
    jmp .lvi_gep_off_loop
.lvi_gep_off_done:
    cmp r11, rcx
    je .lvi_no
    jmp .lvi_yes

.lvi_check_ld:
    # ld args must be "vN"
    cmp r10, 2
    jne .lvi_check_alloca
    mov al, byte ptr [rdi+r12]
    cmp al, 'l'
    jne .lvi_check_alloca
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'd'
    jne .lvi_check_alloca
    mov rcx, r14
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'v'
    jne .lvi_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lvi_no
    cmp rcx, r15
    jne .lvi_no
    jmp .lvi_yes

.lvi_check_alloca:
    # alloca args must be "tN, N", result type must be p0<i8>
    cmp r10, 6
    jne .lvi_check_malloc
    mov al, byte ptr [rdi+r12]
    cmp al, 'a'
    jne .lvi_check_malloc
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'l'
    jne .lvi_check_malloc
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'l'
    jne .lvi_check_malloc
    mov al, byte ptr [rdi+r12+3]
    cmp al, 'o'
    jne .lvi_check_malloc
    mov al, byte ptr [rdi+r12+4]
    cmp al, 'c'
    jne .lvi_check_malloc
    mov al, byte ptr [rdi+r12+5]
    cmp al, 'a'
    jne .lvi_check_malloc

    cmp r8, 4096
    jae .lvi_no
    mov r11, r8
    shl r11, 3
    lea r9, [rip+vfp_type_is_p0_i8_map]
    add r9, r11
    cmp qword ptr [r9], 1
    jne .lvi_no

    mov rcx, r14
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 't'
    jne .lvi_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lvi_no
    # parsed alloca element type id must exist
    xor r11, r11
    mov r9, r14
    inc r9
.lvi_alloca_ty_conv:
    cmp r9, rcx
    jae .lvi_alloca_ty_done
    mov al, byte ptr [rdi+r9]
    sub al, '0'
    imul r11, r11, 10
    movzx r10, al
    add r11, r10
    inc r9
    jmp .lvi_alloca_ty_conv
.lvi_alloca_ty_done:
    cmp r11, qword ptr [rip+vfp_type_count]
    jae .lvi_no
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ','
    jne .lvi_no
    inc rcx
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lvi_no
    inc rcx
    cmp rcx, r15
    jae .lvi_no
.lvi_alloca_n_loop:
    cmp rcx, r15
    je .lvi_yes
    mov al, byte ptr [rdi+rcx]
    cmp al, '0'
    jb .lvi_no
    cmp al, '9'
    ja .lvi_no
    inc rcx
    jmp .lvi_alloca_n_loop

.lvi_check_malloc:
    # malloc args must be "vN", result type must be p0<i8>
    cmp r10, 6
    jne .lvi_check_icmp
    mov al, byte ptr [rdi+r12]
    cmp al, 'm'
    jne .lvi_check_icmp
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'a'
    jne .lvi_check_icmp
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'l'
    jne .lvi_check_icmp
    mov al, byte ptr [rdi+r12+3]
    cmp al, 'l'
    jne .lvi_check_icmp
    mov al, byte ptr [rdi+r12+4]
    cmp al, 'o'
    jne .lvi_check_icmp
    mov al, byte ptr [rdi+r12+5]
    cmp al, 'c'
    jne .lvi_check_icmp
    cmp r8, 4096
    jae .lvi_no
    mov r11, r8
    shl r11, 3
    lea r9, [rip+vfp_type_is_p0_i8_map]
    add r9, r11
    cmp qword ptr [r9], 1
    jne .lvi_no
    mov rcx, r14
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'v'
    jne .lvi_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lvi_no
    cmp rcx, r15
    jne .lvi_no
    jmp .lvi_yes

.lvi_check_icmp:
    # icmp.eq args must be "vN vN" and result type suffix must be i1
    cmp r10, 7
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12]
    cmp al, 'i'
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'c'
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'm'
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12+3]
    cmp al, 'p'
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12+4]
    cmp al, '.'
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12+5]
    cmp al, 'e'
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12+6]
    cmp al, 'q'
    jne .lvi_check_binary

    cmp r8, 4096
    jae .lvi_no
    mov r11, r8
    shl r11, 3
    lea r9, [rip+vfp_type_is_i1_map]
    add r9, r11
    cmp qword ptr [r9], 1
    jne .lvi_no

    mov rcx, r14
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'v'
    jne .lvi_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lvi_no
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lvi_no
    inc rcx
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'v'
    jne .lvi_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lvi_no
    cmp rcx, r15
    jne .lvi_no
    jmp .lvi_yes

.lvi_check_binary:
    # binary op set:
    # add.wrap sub.wrap mul.wrap and or xor shl shr
    mov r10, r13
    sub r10, r12
    mov r11, 0

    cmp r10, 8
    jne .lvi_bin_short_ops
    mov al, byte ptr [rdi+r12]
    cmp al, 'a'
    jne .lvi_chk_sub_wrap
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'd'
    jne .lvi_chk_sub_wrap
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'd'
    jne .lvi_chk_sub_wrap
    mov al, byte ptr [rdi+r12+3]
    cmp al, '.'
    jne .lvi_chk_sub_wrap
    mov al, byte ptr [rdi+r12+4]
    cmp al, 'w'
    jne .lvi_chk_sub_wrap
    mov al, byte ptr [rdi+r12+5]
    cmp al, 'r'
    jne .lvi_chk_sub_wrap
    mov al, byte ptr [rdi+r12+6]
    cmp al, 'a'
    jne .lvi_chk_sub_wrap
    mov al, byte ptr [rdi+r12+7]
    cmp al, 'p'
    jne .lvi_chk_sub_wrap
    mov r11, 1
    jmp .lvi_bin_checked

.lvi_chk_sub_wrap:
    mov al, byte ptr [rdi+r12]
    cmp al, 'a'
    jne .lvi_chk_sub_wrap_real
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'd'
    jne .lvi_chk_sub_wrap_real
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'd'
    jne .lvi_chk_sub_wrap_real
    mov al, byte ptr [rdi+r12+3]
    cmp al, '.'
    jne .lvi_chk_sub_wrap_real
    mov al, byte ptr [rdi+r12+4]
    cmp al, 't'
    jne .lvi_chk_sub_wrap_real
    mov al, byte ptr [rdi+r12+5]
    cmp al, 'r'
    jne .lvi_chk_sub_wrap_real
    mov al, byte ptr [rdi+r12+6]
    cmp al, 'a'
    jne .lvi_chk_sub_wrap_real
    mov al, byte ptr [rdi+r12+7]
    cmp al, 'p'
    jne .lvi_chk_sub_wrap_real
    mov r11, 1
    jmp .lvi_bin_checked

.lvi_chk_sub_wrap_real:
    mov al, byte ptr [rdi+r12]
    cmp al, 's'
    jne .lvi_chk_mul_wrap
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'u'
    jne .lvi_chk_mul_wrap
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'b'
    jne .lvi_chk_mul_wrap
    mov al, byte ptr [rdi+r12+3]
    cmp al, '.'
    jne .lvi_chk_mul_wrap
    mov al, byte ptr [rdi+r12+4]
    cmp al, 't'
    jne .lvi_chk_sub_wrap_variant_wrap
    mov al, byte ptr [rdi+r12+5]
    cmp al, 'r'
    jne .lvi_chk_mul_wrap
    mov al, byte ptr [rdi+r12+6]
    cmp al, 'a'
    jne .lvi_chk_mul_wrap
    mov al, byte ptr [rdi+r12+7]
    cmp al, 'p'
    jne .lvi_chk_mul_wrap
    mov r11, 1
    jmp .lvi_bin_checked

.lvi_chk_sub_wrap_variant_wrap:
    mov al, byte ptr [rdi+r12+4]
    cmp al, 'w'
    jne .lvi_chk_mul_wrap
    mov al, byte ptr [rdi+r12+5]
    cmp al, 'r'
    jne .lvi_chk_mul_wrap
    mov al, byte ptr [rdi+r12+6]
    cmp al, 'a'
    jne .lvi_chk_mul_wrap
    mov al, byte ptr [rdi+r12+7]
    cmp al, 'p'
    jne .lvi_chk_mul_wrap
    mov r11, 1
    jmp .lvi_bin_checked

.lvi_chk_mul_wrap:
    mov al, byte ptr [rdi+r12]
    cmp al, 'm'
    jne .lvi_bin_short_ops
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'u'
    jne .lvi_bin_short_ops
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'l'
    jne .lvi_bin_short_ops
    mov al, byte ptr [rdi+r12+3]
    cmp al, '.'
    jne .lvi_bin_short_ops
    mov al, byte ptr [rdi+r12+4]
    cmp al, 't'
    jne .lvi_chk_mul_wrap_variant_wrap
    mov al, byte ptr [rdi+r12+5]
    cmp al, 'r'
    jne .lvi_bin_short_ops
    mov al, byte ptr [rdi+r12+6]
    cmp al, 'a'
    jne .lvi_bin_short_ops
    mov al, byte ptr [rdi+r12+7]
    cmp al, 'p'
    jne .lvi_bin_short_ops
    mov r11, 1
    jmp .lvi_bin_checked

.lvi_chk_mul_wrap_variant_wrap:
    mov al, byte ptr [rdi+r12+4]
    cmp al, 'w'
    jne .lvi_bin_short_ops
    mov al, byte ptr [rdi+r12+5]
    cmp al, 'r'
    jne .lvi_bin_short_ops
    mov al, byte ptr [rdi+r12+6]
    cmp al, 'a'
    jne .lvi_bin_short_ops
    mov al, byte ptr [rdi+r12+7]
    cmp al, 'p'
    jne .lvi_bin_short_ops
    mov r11, 1
    jmp .lvi_bin_checked

.lvi_bin_short_ops:
    cmp r10, 2
    jne .lvi_bin_len3
    mov al, byte ptr [rdi+r12]
    cmp al, 'o'
    jne .lvi_bin_len3
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'r'
    jne .lvi_bin_len3
    mov r11, 1
    jmp .lvi_bin_checked

.lvi_bin_len3:
    cmp r10, 3
    jne .lvi_bin_no
    mov al, byte ptr [rdi+r12]
    cmp al, 'a'
    jne .lvi_chk_xor
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'n'
    jne .lvi_chk_xor
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'd'
    jne .lvi_chk_xor
    mov r11, 1
    jmp .lvi_bin_checked
.lvi_chk_xor:
    mov al, byte ptr [rdi+r12]
    cmp al, 'x'
    jne .lvi_chk_shl
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'o'
    jne .lvi_chk_shl
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'r'
    jne .lvi_chk_shl
    mov r11, 1
    jmp .lvi_bin_checked
.lvi_chk_shl:
    mov al, byte ptr [rdi+r12]
    cmp al, 's'
    jne .lvi_chk_shr
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'h'
    jne .lvi_chk_shr
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'l'
    jne .lvi_chk_shr
    mov r11, 1
    jmp .lvi_bin_checked
.lvi_chk_shr:
    mov al, byte ptr [rdi+r12]
    cmp al, 's'
    jne .lvi_bin_no
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'h'
    jne .lvi_bin_no
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'r'
    jne .lvi_bin_no
    mov r11, 1
    jmp .lvi_bin_checked

.lvi_bin_no:
    # unknown opcode in bootstrap subset
    jmp .lvi_no

.lvi_bin_checked:
    cmp r11, 1
    jne .lvi_yes
    # enforce args "vN vN"
    mov rcx, r14
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'v'
    jne .lvi_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lvi_no
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .lvi_no
    inc rcx
    cmp rcx, r15
    jae .lvi_no
    mov al, byte ptr [rdi+rcx]
    cmp al, 'v'
    jne .lvi_no
    inc rcx
    call parse_digits
    cmp rax, 1
    jne .lvi_no
    cmp rcx, r15
    jne .lvi_no
    jmp .lvi_yes

.lvi_yes:
    mov rax, 1
    jmp .lvi_done
.lvi_no:
    xor rax, rax
.lvi_done:
    pop r15
    pop r14
    pop r13
    pop r12
    ret

# parse_value_lhs_id
# rdi=line_ptr, rsi=line_len
# out: rax=value id or -1 on parse error
parse_value_lhs_id:
    cmp rsi, 8
    jb .pvli_bad
    mov al, byte ptr [rdi]
    cmp al, ' '
    jne .pvli_bad
    mov al, byte ptr [rdi+1]
    cmp al, ' '
    jne .pvli_bad
    mov al, byte ptr [rdi+2]
    cmp al, 'v'
    jne .pvli_bad
    mov rcx, 3
    call parse_digits
    cmp rax, 1
    jne .pvli_bad
    cmp rcx, rsi
    jae .pvli_bad
    mov al, byte ptr [rdi+rcx]
    cmp al, ' '
    jne .pvli_bad

    xor rax, rax
    mov r8, 3
.pvli_conv:
    cmp r8, rcx
    jae .pvli_ok
    mov bl, byte ptr [rdi+r8]
    sub bl, '0'
    imul rax, rax, 10
    movzx r9, bl
    add rax, r9
    inc r8
    jmp .pvli_conv
.pvli_ok:
    ret
.pvli_bad:
    mov rax, -1
    ret

# parse_value_result_type_id
# rdi=line_ptr, rsi=line_len
# out: rax=type id or -1 on parse error
parse_value_result_type_id:
    cmp rsi, 6
    jb .pvti_bad
    mov r9, rsi
    dec r9                       # last index
    mov r10, r9
.pvti_back_digits:
    mov al, byte ptr [rdi+r9]
    cmp al, '0'
    jb .pvti_digits_done
    cmp al, '9'
    ja .pvti_digits_done
    cmp r9, 0
    je .pvti_bad
    dec r9
    jmp .pvti_back_digits
.pvti_digits_done:
    cmp r9, r10
    je .pvti_bad
    cmp r9, 3
    jb .pvti_bad
    mov al, byte ptr [rdi+r9]
    cmp al, 't'
    jne .pvti_bad
    mov al, byte ptr [rdi+r9-1]
    cmp al, ' '
    jne .pvti_bad
    mov al, byte ptr [rdi+r9-2]
    cmp al, ':'
    jne .pvti_bad
    mov al, byte ptr [rdi+r9-3]
    cmp al, ' '
    jne .pvti_bad

    xor rax, rax
    mov r8, r9
    inc r8                       # first type digit
    mov r11, r10
    inc r11                      # one-past last type digit
.pvti_conv:
    cmp r8, r11
    jae .pvti_ok
    movzx rdx, byte ptr [rdi+r8]
    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc r8
    jmp .pvti_conv
.pvti_ok:
    ret
.pvti_bad:
    mov rax, -1
    ret

# type_token_is_i1
# rdi=token_ptr, rsi=token_len
# out: rax=1 if token is exactly i1 else 0
type_token_is_i1:
    cmp rsi, tok_i1_len
    jne .ttii1_no
    lea rdx, [rip+tok_i1]
    mov r8, 0
.ttii1_loop:
    cmp r8, tok_i1_len
    jae .ttii1_yes
    mov al, byte ptr [rdi+r8]
    mov r9b, byte ptr [rdx+r8]
    cmp al, r9b
    jne .ttii1_no
    inc r8
    jmp .ttii1_loop
.ttii1_yes:
    mov rax, 1
    ret
.ttii1_no:
    xor rax, rax
    ret

# type_token_is_p0_i8
# rdi=token_ptr, rsi=token_len
# out: rax=1 if token is exactly p0<i8> else 0
type_token_is_p0_i8:
    cmp rsi, tok_p0_i8_len
    jne .ttip_no
    lea rdx, [rip+tok_p0_i8]
    mov r8, 0
.ttip_loop:
    cmp r8, tok_p0_i8_len
    jae .ttip_yes
    mov al, byte ptr [rdi+r8]
    mov r9b, byte ptr [rdx+r8]
    cmp al, r9b
    jne .ttip_no
    inc r8
    jmp .ttip_loop
.ttip_yes:
    mov rax, 1
    ret
.ttip_no:
    xor rax, rax
    ret

# type_token_is_allowed
# rdi=token_ptr, rsi=token_len
# out: rax=1 if token is in bootstrap allowed set, else 0
type_token_is_allowed:
    push r12
    mov r12, rdi

    # i1
    mov rdi, r12
    call type_token_is_i1
    cmp rax, 1
    je .ttia_yes

    # i8
    mov rdi, r12
    lea rdx, [rip+tok_i8]
    mov rcx, tok_i8_len
    call token_eq
    cmp rax, 1
    je .ttia_yes
    # i16
    mov rdi, r12
    lea rdx, [rip+tok_i16]
    mov rcx, tok_i16_len
    call token_eq
    cmp rax, 1
    je .ttia_yes
    # i32
    mov rdi, r12
    lea rdx, [rip+tok_i32]
    mov rcx, tok_i32_len
    call token_eq
    cmp rax, 1
    je .ttia_yes
    # i64
    mov rdi, r12
    lea rdx, [rip+tok_i64]
    mov rcx, tok_i64_len
    call token_eq
    cmp rax, 1
    je .ttia_yes

    # u8
    mov rdi, r12
    lea rdx, [rip+tok_u8]
    mov rcx, tok_u8_len
    call token_eq
    cmp rax, 1
    je .ttia_yes
    # u16
    mov rdi, r12
    lea rdx, [rip+tok_u16]
    mov rcx, tok_u16_len
    call token_eq
    cmp rax, 1
    je .ttia_yes
    # u32
    mov rdi, r12
    lea rdx, [rip+tok_u32]
    mov rcx, tok_u32_len
    call token_eq
    cmp rax, 1
    je .ttia_yes
    # u64
    mov rdi, r12
    lea rdx, [rip+tok_u64]
    mov rcx, tok_u64_len
    call token_eq
    cmp rax, 1
    je .ttia_yes
    # p0<i8>
    mov rdi, r12
    lea rdx, [rip+tok_p0_i8]
    mov rcx, tok_p0_i8_len
    call token_eq
    cmp rax, 1
    je .ttia_yes

    xor rax, rax
    jmp .ttia_done
.ttia_yes:
    mov rax, 1
.ttia_done:
    pop r12
    ret

# token_eq
# rdi=token_ptr, rsi=token_len, rdx=lit_ptr, rcx=lit_len
# out: rax=1 if equal else 0
token_eq:
    cmp rsi, rcx
    jne .teq_no
    mov r8, 0
.teq_loop:
    cmp r8, rcx
    jae .teq_yes
    mov al, byte ptr [rdi+r8]
    mov r9b, byte ptr [rdx+r8]
    cmp al, r9b
    jne .teq_no
    inc r8
    jmp .teq_loop
.teq_yes:
    mov rax, 1
    ret
.teq_no:
    xor rax, rax
    ret

# parse one-or-more digits at line index rcx
# in: rdi=line_ptr, rsi=line_len, rcx=index
# out: rax=1 if any digits parsed, rcx advanced
parse_digits:
    cmp rcx, rsi
    jae .pd_no
    mov rdx, rcx
.pd_loop:
    cmp rcx, rsi
    jae .pd_done
    mov al, byte ptr [rdi+rcx]
    cmp al, '0'
    jb .pd_done
    cmp al, '9'
    ja .pd_done
    inc rcx
    jmp .pd_loop
.pd_done:
    cmp rcx, rdx
    je .pd_no
    mov rax, 1
    ret
.pd_no:
    xor rax, rax
    ret

# rdi=a, rsi=b, rdx=len => rax=1 eq else 0
mem_eq:
    push rbx
    cmp rdx, 0
    je .mem_eq_eq
.mem_eq_loop:
    mov al, byte ptr [rdi]
    mov bl, byte ptr [rsi]
    cmp al, bl
    jne .mem_eq_ne
    inc rdi
    inc rsi
    dec rdx
    jne .mem_eq_loop
.mem_eq_eq:
    mov rax, 1
    pop rbx
    ret
.mem_eq_ne:
    xor rax, rax
    pop rbx
    ret

# rdi=str1 rsi=str2 => rax=1 eq else 0
str_eq:
.str_eq_loop:
    mov al, byte ptr [rdi]
    mov bl, byte ptr [rsi]
    cmp al, bl
    jne .str_eq_ne
    cmp al, 0
    je .str_eq_eq
    inc rdi
    inc rsi
    jmp .str_eq_loop
.str_eq_eq:
    mov rax, 1
    ret
.str_eq_ne:
    xor rax, rax
    ret

# find_substr_pos
# rdi=hay_ptr, rsi=hay_len, rdx=needle_ptr, rcx=needle_len
# out: rax=index if found, -1 otherwise
find_substr_pos:
    cmp rcx, 0
    je .fsp_zero
    cmp rsi, rcx
    jb .fsp_no
    xor r8, r8
.fsp_outer:
    mov r9, rsi
    sub r9, rcx
    cmp r8, r9
    ja .fsp_no
    xor r10, r10
.fsp_inner:
    cmp r10, rcx
    je .fsp_yes
    mov r11, r8
    add r11, r10
    mov al, byte ptr [rdi+r11]
    mov r11, rdx
    add r11, r10
    mov r11b, byte ptr [r11]
    cmp al, r11b
    jne .fsp_next
    inc r10
    jmp .fsp_inner
.fsp_next:
    inc r8
    jmp .fsp_outer
.fsp_zero:
    xor rax, rax
    ret
.fsp_yes:
    mov rax, r8
    ret
.fsp_no:
    mov rax, -1
    ret

# try_select_write_newline_kernel_code
# rdi=src_ptr, rsi=src_len
# out: rax=1 if selected and sets r14/r15 ; 0 otherwise
try_select_write_newline_kernel_code:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    lea rdx, [rip+pat_write_head]
    mov rcx, pat_write_head_len
    mov rdi, r12
    mov rsi, r13
    call find_substr_pos
    cmp rax, -1
    je .tswk_no

    mov r8, rax
    add r8, pat_write_head_len       # alloca-id start
    cmp r8, r13
    jae .tswk_no
    mov r9, r8
.tswk_alloca_vid_loop:
    cmp r9, r13
    jae .tswk_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tswk_alloca_vid_done
    cmp al, '9'
    ja .tswk_alloca_vid_done
    inc r9
    jmp .tswk_alloca_vid_loop
.tswk_alloca_vid_done:
    cmp r9, r8
    je .tswk_no
    mov r14, r8
    mov r15, r9
    sub r15, r8                      # alloca-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_write_mid_a_len
    jb .tswk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_write_mid_a]
    mov rdx, pat_write_mid_a_len
    call mem_eq
    cmp rax, 1
    jne .tswk_no
    add r10, pat_write_mid_a_len     # const10-id start
    cmp r10, r13
    jae .tswk_no

    mov r8, r10
    mov r9, r8
.tswk_c10_vid_loop:
    cmp r9, r13
    jae .tswk_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tswk_c10_vid_done
    cmp al, '9'
    ja .tswk_c10_vid_done
    inc r9
    jmp .tswk_c10_vid_loop
.tswk_c10_vid_done:
    cmp r9, r8
    je .tswk_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                      # const10-id len
    push rbx
    push r11

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_write_mid_b_len
    jb .tswk_no_pop_c10
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_write_mid_b]
    mov rdx, pat_write_mid_b_len
    call mem_eq
    cmp rax, 1
    jne .tswk_no_pop_c10
    add r10, pat_write_mid_b_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, r14
    mov rdx, r15
    call mem_eq
    cmp rax, 1
    jne .tswk_no_pop_c10
    add r10, r15

    mov rax, r13
    sub rax, r10
    cmp rax, pat_write_mid_c_len
    jb .tswk_no_pop_c10
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_write_mid_c]
    mov rdx, pat_write_mid_c_len
    call mem_eq
    cmp rax, 1
    jne .tswk_no_pop_c10
    add r10, pat_write_mid_c_len

    pop r11
    pop rbx
    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tswk_no
    add r10, r11

    mov rax, r13
    sub rax, r10
    cmp rax, pat_write_mid_d_len
    jb .tswk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_write_mid_d]
    mov rdx, pat_write_mid_d_len
    call mem_eq
    cmp rax, 1
    jne .tswk_no
    add r10, pat_write_mid_d_len     # const1-id start
    cmp r10, r13
    jae .tswk_no

    mov r8, r10
    mov r9, r8
.tswk_c1_vid_loop:
    cmp r9, r13
    jae .tswk_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tswk_c1_vid_done
    cmp al, '9'
    ja .tswk_c1_vid_done
    inc r9
    jmp .tswk_c1_vid_loop
.tswk_c1_vid_done:
    cmp r9, r8
    je .tswk_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                      # const1-id len
    push rbx
    push r11

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_write_mid_e_len
    jb .tswk_no_pop_c1
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_write_mid_e]
    mov rdx, pat_write_mid_e_len
    call mem_eq
    cmp rax, 1
    jne .tswk_no_pop_c1
    add r10, pat_write_mid_e_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, r14
    mov rdx, r15
    call mem_eq
    cmp rax, 1
    jne .tswk_no_pop_c1
    add r10, r15

    mov rax, r13
    sub rax, r10
    cmp rax, pat_write_mid_f_len
    jb .tswk_no_pop_c1
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_write_mid_f]
    mov rdx, pat_write_mid_f_len
    call mem_eq
    cmp rax, 1
    jne .tswk_no_pop_c1
    add r10, pat_write_mid_f_len

    pop r11
    pop rbx
    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tswk_no
    add r10, r11

    mov rax, r13
    sub rax, r10
    cmp rax, pat_write_mid_g_len
    jb .tswk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_write_mid_g]
    mov rdx, pat_write_mid_g_len
    call mem_eq
    cmp rax, 1
    jne .tswk_no
    add r10, pat_write_mid_g_len     # const0/ret-id start
    cmp r10, r13
    jae .tswk_no

    mov r8, r10
    mov r9, r8
.tswk_c0_vid_loop:
    cmp r9, r13
    jae .tswk_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tswk_c0_vid_done
    cmp al, '9'
    ja .tswk_c0_vid_done
    inc r9
    jmp .tswk_c0_vid_loop
.tswk_c0_vid_done:
    cmp r9, r8
    je .tswk_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                      # const0/ret-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_write_mid_h_len
    jb .tswk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_write_mid_h]
    mov rdx, pat_write_mid_h_len
    call mem_eq
    cmp rax, 1
    jne .tswk_no
    add r10, pat_write_mid_h_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tswk_no
    add r10, r11

    mov rax, r13
    sub rax, r10
    cmp rax, pat_write_tail_len
    jb .tswk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_write_tail]
    mov rdx, pat_write_tail_len
    call mem_eq
    cmp rax, 1
    jne .tswk_no

    lea r14, [rip+code_stub_write_newline]
    mov r15, code_stub_write_newline_len
    mov qword ptr [rip+build_kernel_kind], 22
    mov rax, 1
    jmp .tswk_done

.tswk_no_pop_c1:
    add rsp, 16
    jmp .tswk_no
.tswk_no_pop_c10:
    add rsp, 16
.tswk_no:
    xor rax, rax
.tswk_done:
    pop rcx
    pop rdx
    cmp rax, 1
    je .tswk_keep_out
    mov r14, rdx
    mov r15, rcx
.tswk_keep_out:
    pop r13
    pop r12
    pop rbx
    ret

# try_select_mem_roundtrip_kernel_code
# rdi=src_ptr, rsi=src_len
# out: rax=1 if selected and sets r14/r15 ; 0 otherwise
try_select_mem_roundtrip_kernel_code:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    lea rdx, [rip+pat_mem_head]
    mov rcx, pat_mem_head_len
    mov rdi, r12
    mov rsi, r13
    call find_substr_pos
    cmp rax, -1
    je .tsmr_no

    mov r8, rax
    add r8, pat_mem_head_len         # arg-id start
    cmp r8, r13
    jae .tsmr_no
    mov r9, r8
.tsmr_arg_vid_loop:
    cmp r9, r13
    jae .tsmr_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tsmr_arg_vid_done
    cmp al, '9'
    ja .tsmr_arg_vid_done
    inc r9
    jmp .tsmr_arg_vid_loop
.tsmr_arg_vid_done:
    cmp r9, r8
    je .tsmr_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                      # arg-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_mem_mid_a_len
    jb .tsmr_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_mem_mid_a]
    mov rdx, pat_mem_mid_a_len
    call mem_eq
    cmp rax, 1
    jne .tsmr_no
    add r10, pat_mem_mid_a_len       # alloca-id start
    cmp r10, r13
    jae .tsmr_no

    mov r8, r10
    mov r9, r8
.tsmr_alloca_vid_loop:
    cmp r9, r13
    jae .tsmr_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tsmr_alloca_vid_done
    cmp al, '9'
    ja .tsmr_alloca_vid_done
    inc r9
    jmp .tsmr_alloca_vid_loop
.tsmr_alloca_vid_done:
    cmp r9, r8
    je .tsmr_no
    mov r14, r8
    mov r15, r9
    sub r15, r8                      # alloca-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_mem_mid_b_len
    jb .tsmr_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_mem_mid_b]
    mov rdx, pat_mem_mid_b_len
    call mem_eq
    cmp rax, 1
    jne .tsmr_no
    add r10, pat_mem_mid_b_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, r14
    mov rdx, r15
    call mem_eq
    cmp rax, 1
    jne .tsmr_no
    add r10, r15

    mov rax, r13
    sub rax, r10
    cmp rax, pat_mem_mid_c_len
    jb .tsmr_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_mem_mid_c]
    mov rdx, pat_mem_mid_c_len
    call mem_eq
    cmp rax, 1
    jne .tsmr_no
    add r10, pat_mem_mid_c_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsmr_no
    add r10, r11

    mov rax, r13
    sub rax, r10
    cmp rax, pat_mem_mid_d_len
    jb .tsmr_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_mem_mid_d]
    mov rdx, pat_mem_mid_d_len
    call mem_eq
    cmp rax, 1
    jne .tsmr_no
    add r10, pat_mem_mid_d_len       # ld-result-id start
    cmp r10, r13
    jae .tsmr_no

    mov r8, r10
    mov r9, r8
.tsmr_ld_vid_loop:
    cmp r9, r13
    jae .tsmr_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tsmr_ld_vid_done
    cmp al, '9'
    ja .tsmr_ld_vid_done
    inc r9
    jmp .tsmr_ld_vid_loop
.tsmr_ld_vid_done:
    cmp r9, r8
    je .tsmr_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                      # ld-result-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_mem_mid_e_len
    jb .tsmr_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_mem_mid_e]
    mov rdx, pat_mem_mid_e_len
    call mem_eq
    cmp rax, 1
    jne .tsmr_no
    add r10, pat_mem_mid_e_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, r14
    mov rdx, r15
    call mem_eq
    cmp rax, 1
    jne .tsmr_no
    add r10, r15

    mov rax, r13
    sub rax, r10
    cmp rax, pat_mem_mid_f_len
    jb .tsmr_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_mem_mid_f]
    mov rdx, pat_mem_mid_f_len
    call mem_eq
    cmp rax, 1
    jne .tsmr_no
    add r10, pat_mem_mid_f_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsmr_no
    add r10, r11

    mov rax, r13
    sub rax, r10
    cmp rax, pat_mem_tail_len
    jb .tsmr_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_mem_tail]
    mov rdx, pat_mem_tail_len
    call mem_eq
    cmp rax, 1
    jne .tsmr_no

    lea r14, [rip+code_stub_mem_roundtrip]
    mov r15, code_stub_mem_roundtrip_len
    mov qword ptr [rip+build_kernel_kind], 14
    mov rax, 1
    jmp .tsmr_done

.tsmr_no:
    xor rax, rax
.tsmr_done:
    pop rcx
    pop rdx
    cmp rax, 1
    je .tsmr_keep_out
    mov r14, rdx
    mov r15, rcx
.tsmr_keep_out:
    pop r13
    pop r12
    pop rbx
    ret

# try_select_exit_kernel_code
# rdi=src_ptr, rsi=src_len
# out: rax=1 if selected and sets r14/r15 ; 0 otherwise
try_select_exit_kernel_code:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    lea rdx, [rip+pat_exit_head]
    mov rcx, pat_exit_head_len
    mov rdi, r12
    mov rsi, r13
    call find_substr_pos
    cmp rax, -1
    je .tsek_no

    mov r8, rax
    add r8, pat_exit_head_len        # arg/exit/ret id start
    cmp r8, r13
    jae .tsek_no
    mov r9, r8
.tsek_vid_loop:
    cmp r9, r13
    jae .tsek_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tsek_vid_done
    cmp al, '9'
    ja .tsek_vid_done
    inc r9
    jmp .tsek_vid_loop
.tsek_vid_done:
    cmp r9, r8
    je .tsek_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                      # id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_exit_mid_a_len
    jb .tsek_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_exit_mid_a]
    mov rdx, pat_exit_mid_a_len
    call mem_eq
    cmp rax, 1
    jne .tsek_no
    add r10, pat_exit_mid_a_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsek_no
    add r10, r11

    mov rax, r13
    sub rax, r10
    cmp rax, pat_exit_mid_b_len
    jb .tsek_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_exit_mid_b]
    mov rdx, pat_exit_mid_b_len
    call mem_eq
    cmp rax, 1
    jne .tsek_no
    add r10, pat_exit_mid_b_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsek_no
    add r10, r11

    mov rax, r13
    sub rax, r10
    cmp rax, pat_exit_tail_len
    jb .tsek_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_exit_tail]
    mov rdx, pat_exit_tail_len
    call mem_eq
    cmp rax, 1
    jne .tsek_no

    lea r14, [rip+code_stub_exit]
    mov r15, code_stub_exit_len
    mov qword ptr [rip+build_kernel_kind], 23
    mov rax, 1
    jmp .tsek_done

.tsek_no:
    xor rax, rax
.tsek_done:
    pop rcx
    pop rdx
    cmp rax, 1
    je .tsek_keep_out
    mov r14, rdx
    mov r15, rcx
.tsek_keep_out:
    pop r13
    pop r12
    pop rbx
    ret

# try_select_free_noop_kernel_code
# rdi=src_ptr, rsi=src_len
# out: rax=1 if selected and sets r14/r15 ; 0 otherwise
try_select_free_noop_kernel_code:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    lea rdx, [rip+pat_free_head]
    mov rcx, pat_free_head_len
    mov rdi, r12
    mov rsi, r13
    call find_substr_pos
    cmp rax, -1
    je .tsfk_no

    mov r8, rax
    add r8, pat_free_head_len        # arg-id start
    cmp r8, r13
    jae .tsfk_no
    mov r9, r8
.tsfk_arg_vid_loop:
    cmp r9, r13
    jae .tsfk_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tsfk_arg_vid_done
    cmp al, '9'
    ja .tsfk_arg_vid_done
    inc r9
    jmp .tsfk_arg_vid_loop
.tsfk_arg_vid_done:
    cmp r9, r8
    je .tsfk_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                      # arg-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_free_mid_a_len
    jb .tsfk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_free_mid_a]
    mov rdx, pat_free_mid_a_len
    call mem_eq
    cmp rax, 1
    jne .tsfk_no
    add r10, pat_free_mid_a_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsfk_no
    add r10, r11

    mov rax, r13
    sub rax, r10
    cmp rax, pat_free_mid_b_len
    jb .tsfk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_free_mid_b]
    mov rdx, pat_free_mid_b_len
    call mem_eq
    cmp rax, 1
    jne .tsfk_no
    add r10, pat_free_mid_b_len      # const/ret id start
    cmp r10, r13
    jae .tsfk_no

    mov r8, r10
    mov r9, r8
.tsfk_const_vid_loop:
    cmp r9, r13
    jae .tsfk_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tsfk_const_vid_done
    cmp al, '9'
    ja .tsfk_const_vid_done
    inc r9
    jmp .tsfk_const_vid_loop
.tsfk_const_vid_done:
    cmp r9, r8
    je .tsfk_no
    mov r14, r8
    mov r15, r9
    sub r15, r8                      # const/ret id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_free_mid_c_len
    jb .tsfk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_free_mid_c]
    mov rdx, pat_free_mid_c_len
    call mem_eq
    cmp rax, 1
    jne .tsfk_no
    add r10, pat_free_mid_c_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, r14
    mov rdx, r15
    call mem_eq
    cmp rax, 1
    jne .tsfk_no
    add r10, r15

    mov rax, r13
    sub rax, r10
    cmp rax, pat_free_tail_len
    jb .tsfk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_free_tail]
    mov rdx, pat_free_tail_len
    call mem_eq
    cmp rax, 1
    jne .tsfk_no

    lea r14, [rip+code_stub_free_noop]
    mov r15, code_stub_free_noop_len
    mov qword ptr [rip+build_kernel_kind], 21
    mov rax, 1
    jmp .tsfk_done

.tsfk_no:
    xor rax, rax
.tsfk_done:
    pop rcx
    pop rdx
    cmp rax, 1
    je .tsfk_keep_out
    mov r14, rdx
    mov r15, rcx
.tsfk_keep_out:
    pop r13
    pop r12
    pop rbx
    ret

# try_select_malloc_kernel_code
# rdi=src_ptr, rsi=src_len
# out: rax=1 if selected and sets r14/r15 ; 0 otherwise
try_select_malloc_kernel_code:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    lea rdx, [rip+pat_malloc_head]
    mov rcx, pat_malloc_head_len
    mov rdi, r12
    mov rsi, r13
    call find_substr_pos
    cmp rax, -1
    je .tsmk_no

    mov r8, rax
    add r8, pat_malloc_head_len      # arg-id start
    cmp r8, r13
    jae .tsmk_no
    mov r9, r8
.tsmk_arg_vid_loop:
    cmp r9, r13
    jae .tsmk_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tsmk_arg_vid_done
    cmp al, '9'
    ja .tsmk_arg_vid_done
    inc r9
    jmp .tsmk_arg_vid_loop
.tsmk_arg_vid_done:
    cmp r9, r8
    je .tsmk_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                      # arg-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_malloc_mid_a_len
    jb .tsmk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_malloc_mid_a]
    mov rdx, pat_malloc_mid_a_len
    call mem_eq
    cmp rax, 1
    jne .tsmk_no
    add r10, pat_malloc_mid_a_len    # malloc result-id start
    cmp r10, r13
    jae .tsmk_no

    mov r8, r10
    mov r9, r8
.tsmk_res_vid_loop:
    cmp r9, r13
    jae .tsmk_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tsmk_res_vid_done
    cmp al, '9'
    ja .tsmk_res_vid_done
    inc r9
    jmp .tsmk_res_vid_loop
.tsmk_res_vid_done:
    cmp r9, r8
    je .tsmk_no
    mov r14, r8
    mov r15, r9
    sub r15, r8                      # malloc result-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_malloc_mid_b_len
    jb .tsmk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_malloc_mid_b]
    mov rdx, pat_malloc_mid_b_len
    call mem_eq
    cmp rax, 1
    jne .tsmk_no
    add r10, pat_malloc_mid_b_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsmk_no
    add r10, r11

    mov rax, r13
    sub rax, r10
    cmp rax, pat_malloc_mid_c_len
    jb .tsmk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_malloc_mid_c]
    mov rdx, pat_malloc_mid_c_len
    call mem_eq
    cmp rax, 1
    jne .tsmk_no
    add r10, pat_malloc_mid_c_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, r14
    mov rdx, r15
    call mem_eq
    cmp rax, 1
    jne .tsmk_no
    add r10, r15

    mov rax, r13
    sub rax, r10
    cmp rax, pat_malloc_tail_len
    jb .tsmk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_malloc_tail]
    mov rdx, pat_malloc_tail_len
    call mem_eq
    cmp rax, 1
    jne .tsmk_no

    lea r14, [rip+code_stub_malloc]
    mov r15, code_stub_malloc_len
    mov qword ptr [rip+build_kernel_kind], 20
    mov rax, 1
    jmp .tsmk_done

.tsmk_no:
    xor rax, rax
.tsmk_done:
    pop rcx
    pop rdx
    cmp rax, 1
    je .tsmk_keep_out
    mov r14, rdx
    mov r15, rcx
.tsmk_keep_out:
    pop r13
    pop r12
    pop rbx
    ret

# try_select_trace_noop_kernel_code
# rdi=src_ptr, rsi=src_len
# out: rax=1 if selected and sets r14/r15 ; 0 otherwise
try_select_trace_noop_kernel_code:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    lea rdx, [rip+pat_trace_head]
    mov rcx, pat_trace_head_len
    mov rdi, r12
    mov rsi, r13
    call find_substr_pos
    cmp rax, -1
    je .tstn_no

    mov r8, rax
    add r8, pat_trace_head_len       # arg value-id start
    cmp r8, r13
    jae .tstn_no
    mov r9, r8
.tstn_arg_vid_loop:
    cmp r9, r13
    jae .tstn_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tstn_arg_vid_done
    cmp al, '9'
    ja .tstn_arg_vid_done
    inc r9
    jmp .tstn_arg_vid_loop
.tstn_arg_vid_done:
    cmp r9, r8
    je .tstn_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                      # arg value-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_trace_mid_a_len
    jb .tstn_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_trace_mid_a]
    mov rdx, pat_trace_mid_a_len
    call mem_eq
    cmp rax, 1
    jne .tstn_no
    add r10, pat_trace_mid_a_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tstn_no
    add r10, r11

    mov rax, r13
    sub rax, r10
    cmp rax, pat_trace_mid_b_len
    jb .tstn_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_trace_mid_b]
    mov rdx, pat_trace_mid_b_len
    call mem_eq
    cmp rax, 1
    jne .tstn_no
    add r10, pat_trace_mid_b_len     # const result-id start
    cmp r10, r13
    jae .tstn_no

    mov r8, r10
    mov r9, r8
.tstn_const_vid_loop:
    cmp r9, r13
    jae .tstn_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tstn_const_vid_done
    cmp al, '9'
    ja .tstn_const_vid_done
    inc r9
    jmp .tstn_const_vid_loop
.tstn_const_vid_done:
    cmp r9, r8
    je .tstn_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                      # const result-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_trace_mid_c_len
    jb .tstn_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_trace_mid_c]
    mov rdx, pat_trace_mid_c_len
    call mem_eq
    cmp rax, 1
    jne .tstn_no
    add r10, pat_trace_mid_c_len

    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tstn_no
    add r10, r11

    mov rax, r13
    sub rax, r10
    cmp rax, pat_trace_tail_len
    jb .tstn_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_trace_tail]
    mov rdx, pat_trace_tail_len
    call mem_eq
    cmp rax, 1
    jne .tstn_no

    lea r14, [rip+code_stub_trace_emit]
    mov r15, code_stub_trace_emit_len
    mov qword ptr [rip+build_kernel_kind], 24
    mov rax, 1
    jmp .tstn_done

.tstn_no:
    xor rax, rax
.tstn_done:
    pop rcx
    pop rdx
    cmp rax, 1
    je .tstn_keep_out
    mov r14, rdx
    mov r15, rcx
.tstn_keep_out:
    pop r13
    pop r12
    pop rbx
    ret

# try_select_call_kernel_code
# rdi=src_ptr, rsi=src_len
# out: rax=1 if selected and sets r14/r15 ; 0 otherwise
try_select_call_kernel_code:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    lea rdx, [rip+pat_call_head]
    mov rcx, pat_call_head_len
    mov rdi, r12
    mov rsi, r13
    call find_substr_pos
    cmp rax, -1
    je .tsck_call_no

    mov r8, rax
    add r8, pat_call_head_len       # result-id start
    cmp r8, r13
    jae .tsck_call_no
    mov r9, r8
.tsck_call_find_vid_end:
    cmp r9, r13
    jae .tsck_call_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tsck_call_vid_done
    cmp al, '9'
    ja .tsck_call_vid_done
    inc r9
    jmp .tsck_call_find_vid_end
.tsck_call_vid_done:
    cmp r9, r8
    je .tsck_call_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                     # result-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_call_mid_len
    jb .tsck_call_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_call_mid]
    mov rdx, pat_call_mid_len
    call mem_eq
    cmp rax, 1
    jne .tsck_call_no
    add r10, pat_call_mid_len       # suffix start

    # add normal
    mov rax, r13
    sub rax, r10
    mov rcx, pat_call_tail_a_len
    add rcx, r11
    add rcx, pat_call_tail_b_add_len
    cmp rax, rcx
    jb .tsck_call_try_add_swapped
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_call_tail_a]
    mov rdx, pat_call_tail_a_len
    call mem_eq
    cmp rax, 1
    jne .tsck_call_try_add_swapped
    mov rdi, r12
    add rdi, r10
    add rdi, pat_call_tail_a_len
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsck_call_try_add_swapped
    mov rdi, r12
    add rdi, r10
    add rdi, pat_call_tail_a_len
    add rdi, r11
    lea rsi, [rip+pat_call_tail_b_add]
    mov rdx, pat_call_tail_b_add_len
    call mem_eq
    cmp rax, 1
    jne .tsck_call_try_add_swapped
    lea r14, [rip+code_stub_add]
    mov r15, code_stub_add_len
    mov qword ptr [rip+build_kernel_kind], 16
    mov rax, 1
    jmp .tsck_call_done

.tsck_call_try_add_swapped:
    mov rax, r13
    sub rax, r10
    mov rcx, pat_call_tail_a_swapped_len
    add rcx, r11
    add rcx, pat_call_tail_b_add_len
    cmp rax, rcx
    jb .tsck_call_try_sub
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_call_tail_a_swapped]
    mov rdx, pat_call_tail_a_swapped_len
    call mem_eq
    cmp rax, 1
    jne .tsck_call_try_sub
    mov rdi, r12
    add rdi, r10
    add rdi, pat_call_tail_a_swapped_len
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsck_call_try_sub
    mov rdi, r12
    add rdi, r10
    add rdi, pat_call_tail_a_swapped_len
    add rdi, r11
    lea rsi, [rip+pat_call_tail_b_add]
    mov rdx, pat_call_tail_b_add_len
    call mem_eq
    cmp rax, 1
    jne .tsck_call_try_sub
    lea r14, [rip+code_stub_add]
    mov r15, code_stub_add_len
    mov qword ptr [rip+build_kernel_kind], 16
    mov rax, 1
    jmp .tsck_call_done

.tsck_call_try_sub:
    mov rax, r13
    sub rax, r10
    mov rcx, pat_call_tail_a_len
    add rcx, r11
    add rcx, pat_call_tail_b_sub_len
    cmp rax, rcx
    jb .tsck_call_try_mul
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_call_tail_a]
    mov rdx, pat_call_tail_a_len
    call mem_eq
    cmp rax, 1
    jne .tsck_call_try_mul
    mov rdi, r12
    add rdi, r10
    add rdi, pat_call_tail_a_len
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsck_call_try_mul
    mov rdi, r12
    add rdi, r10
    add rdi, pat_call_tail_a_len
    add rdi, r11
    lea rsi, [rip+pat_call_tail_b_sub]
    mov rdx, pat_call_tail_b_sub_len
    call mem_eq
    cmp rax, 1
    jne .tsck_call_try_mul
    lea r14, [rip+code_stub_sub]
    mov r15, code_stub_sub_len
    mov qword ptr [rip+build_kernel_kind], 17
    mov rax, 1
    jmp .tsck_call_done

.tsck_call_try_mul:
    mov rax, r13
    sub rax, r10
    mov rcx, pat_call_tail_a_len
    add rcx, r11
    add rcx, pat_call_tail_b_mul_len
    cmp rax, rcx
    jb .tsck_call_try_mul_swapped
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_call_tail_a]
    mov rdx, pat_call_tail_a_len
    call mem_eq
    cmp rax, 1
    jne .tsck_call_try_mul_swapped
    mov rdi, r12
    add rdi, r10
    add rdi, pat_call_tail_a_len
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsck_call_try_mul_swapped
    mov rdi, r12
    add rdi, r10
    add rdi, pat_call_tail_a_len
    add rdi, r11
    lea rsi, [rip+pat_call_tail_b_mul]
    mov rdx, pat_call_tail_b_mul_len
    call mem_eq
    cmp rax, 1
    jne .tsck_call_try_mul_swapped
    lea r14, [rip+code_stub_mul]
    mov r15, code_stub_mul_len
    mov qword ptr [rip+build_kernel_kind], 18
    mov rax, 1
    jmp .tsck_call_done

.tsck_call_try_mul_swapped:
    mov rax, r13
    sub rax, r10
    mov rcx, pat_call_tail_a_swapped_len
    add rcx, r11
    add rcx, pat_call_tail_b_mul_len
    cmp rax, rcx
    jb .tsck_call_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_call_tail_a_swapped]
    mov rdx, pat_call_tail_a_swapped_len
    call mem_eq
    cmp rax, 1
    jne .tsck_call_no
    mov rdi, r12
    add rdi, r10
    add rdi, pat_call_tail_a_swapped_len
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsck_call_no
    mov rdi, r12
    add rdi, r10
    add rdi, pat_call_tail_a_swapped_len
    add rdi, r11
    lea rsi, [rip+pat_call_tail_b_mul]
    mov rdx, pat_call_tail_b_mul_len
    call mem_eq
    cmp rax, 1
    jne .tsck_call_no
    lea r14, [rip+code_stub_mul]
    mov r15, code_stub_mul_len
    mov qword ptr [rip+build_kernel_kind], 18
    mov rax, 1
    jmp .tsck_call_done

.tsck_call_no:
    xor rax, rax
.tsck_call_done:
    pop rcx
    pop rdx
    cmp rax, 1
    je .tsck_call_keep_out
    mov r14, rdx
    mov r15, rcx
.tsck_call_keep_out:
    pop r13
    pop r12
    pop rbx
    ret

# try_select_cbr_eq_select_kernel_code
# rdi=src_ptr, rsi=src_len
# out: rax=1 if selected and sets r14/r15 ; 0 otherwise
try_select_cbr_eq_select_kernel_code:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    lea rdx, [rip+pat_cbr_head]
    mov rcx, pat_cbr_head_len
    mov rdi, r12
    mov rsi, r13
    call find_substr_pos
    cmp rax, -1
    je .tscs_no

    mov r8, rax
    add r8, pat_cbr_head_len        # result-id start
    cmp r8, r13
    jae .tscs_no
    mov r9, r8
.tscs_find_vid_end:
    cmp r9, r13
    jae .tscs_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tscs_vid_done
    cmp al, '9'
    ja .tscs_vid_done
    inc r9
    jmp .tscs_find_vid_end
.tscs_vid_done:
    cmp r9, r8
    je .tscs_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                     # result-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_cbr_mid_len
    jb .tscs_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_cbr_mid]
    mov rdx, pat_cbr_mid_len
    call mem_eq
    cmp rax, 1
    jne .tscs_no
    add r10, pat_cbr_mid_len
    mov rax, r13
    sub rax, r10
    mov rcx, pat_cbr_tail_a_len
    add rcx, r11
    add rcx, pat_cbr_tail_b_len
    cmp rax, rcx
    jb .tscs_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_cbr_tail_a]
    mov rdx, pat_cbr_tail_a_len
    call mem_eq
    cmp rax, 1
    je .tscs_tail_a_ok
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_cbr_tail_a_swapped]
    mov rdx, pat_cbr_tail_a_swapped_len
    call mem_eq
    cmp rax, 1
    jne .tscs_no
.tscs_tail_a_ok:
    add r10, pat_cbr_tail_a_len
    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tscs_no
    add r10, r11
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_cbr_tail_b]
    mov rdx, pat_cbr_tail_b_len
    call mem_eq
    cmp rax, 1
    jne .tscs_no

    lea r14, [rip+code_stub_cbr_eq_select]
    mov r15, code_stub_cbr_eq_select_len
    mov qword ptr [rip+build_kernel_kind], 12
    mov rax, 1
    jmp .tscs_done

.tscs_no:
    xor rax, rax
.tscs_done:
    pop rcx
    pop rdx
    cmp rax, 1
    je .tscs_keep_out
    mov r14, rdx
    mov r15, rcx
.tscs_keep_out:
    pop r13
    pop r12
    pop rbx
    ret

# try_select_icmp_eq_kernel_code
# rdi=src_ptr, rsi=src_len
# out: rax=1 if selected and sets r14/r15 ; 0 otherwise
try_select_icmp_eq_kernel_code:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    lea rdx, [rip+pat_icmp_head]
    mov rcx, pat_icmp_head_len
    mov rdi, r12
    mov rsi, r13
    call find_substr_pos
    cmp rax, -1
    je .tsik_no

    mov r8, rax
    add r8, pat_icmp_head_len       # result-id start
    cmp r8, r13
    jae .tsik_no
    mov r9, r8
.tsik_find_vid_end:
    cmp r9, r13
    jae .tsik_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tsik_vid_done
    cmp al, '9'
    ja .tsik_vid_done
    inc r9
    jmp .tsik_find_vid_end
.tsik_vid_done:
    cmp r9, r8
    je .tsik_no
    mov rbx, r8
    mov r11, r9
    sub r11, r8                     # result-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_icmp_mid_len
    jb .tsik_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_icmp_mid]
    mov rdx, pat_icmp_mid_len
    call mem_eq
    cmp rax, 1
    jne .tsik_no
    add r10, pat_icmp_mid_len       # suffix start
    mov rax, r13
    sub rax, r10
    mov rcx, pat_icmp_tail_a_len
    add rcx, r11
    add rcx, pat_icmp_tail_b_len
    cmp rax, rcx
    jb .tsik_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_icmp_tail_a]
    mov rdx, pat_icmp_tail_a_len
    call mem_eq
    cmp rax, 1
    je .tsik_tail_a_ok
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_icmp_tail_a_swapped]
    mov rdx, pat_icmp_tail_a_swapped_len
    call mem_eq
    cmp rax, 1
    jne .tsik_no
.tsik_tail_a_ok:
    add r10, pat_icmp_tail_a_len
    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsik_no
    add r10, r11
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_icmp_tail_b]
    mov rdx, pat_icmp_tail_b_len
    call mem_eq
    cmp rax, 1
    jne .tsik_no

    lea r14, [rip+code_stub_icmp_eq]
    mov r15, code_stub_icmp_eq_len
    mov qword ptr [rip+build_kernel_kind], 11
    mov rax, 1
    jmp .tsik_done

.tsik_no:
    xor rax, rax
.tsik_done:
    pop rcx
    pop rdx
    cmp rax, 1
    je .tsik_keep_out
    mov r14, rdx
    mov r15, rcx
.tsik_keep_out:
    pop r13
    pop r12
    pop rbx
    ret

# try_select_bin_kernel_code
# rdi=src_ptr, rsi=src_len
# out: rax=1 if selected and sets r14/r15 ; 0 otherwise
try_select_bin_kernel_code:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    lea rdx, [rip+pat_bin_head]
    mov rcx, pat_bin_head_len
    mov rdi, r12
    mov rsi, r13
    call find_substr_pos
    cmp rax, -1
    je .tsbk_no

    mov r8, rax
    add r8, pat_bin_head_len        # result-id start
    cmp r8, r13
    jae .tsbk_no

    mov r9, r8
.tsbk_find_vid_end:
    cmp r9, r13
    jae .tsbk_no
    mov al, byte ptr [r12+r9]
    cmp al, '0'
    jb .tsbk_vid_done
    cmp al, '9'
    ja .tsbk_vid_done
    inc r9
    jmp .tsbk_find_vid_end
.tsbk_vid_done:
    cmp r9, r8
    je .tsbk_no

    mov rbx, r8                       # preserve result-id start
    mov r11, r9
    sub r11, r8                       # preserve result-id len

    mov r10, r9
    mov rax, r13
    sub rax, r10
    cmp rax, pat_bin_mid_len
    jb .tsbk_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_bin_mid]
    mov rdx, pat_bin_mid_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_no
    add r10, pat_bin_mid_len          # opcode start
    cmp r10, r13
    jae .tsbk_no
    mov r14, r10                      # preserve opcode start across calls

    mov r9, r10
.tsbk_find_space:
    cmp r9, r13
    jae .tsbk_no
    mov al, byte ptr [r12+r9]
    cmp al, ' '
    je .tsbk_space
    inc r9
    jmp .tsbk_find_space
.tsbk_space:
    cmp r9, r10
    je .tsbk_no

    mov r10, r9
    inc r10                           # suffix start
    mov rax, r13
    sub rax, r10
    mov rcx, pat_bin_tail_a_len
    add rcx, r11
    add rcx, pat_bin_tail_b_len
    cmp rax, rcx
    jb .tsbk_no
    xor r13d, r13d                    # operand order flag: 0=v0 v1, 1=v1 v0
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_bin_tail_a]
    mov rdx, pat_bin_tail_a_len
    call mem_eq
    cmp rax, 1
    je .tsbk_tail_a_ok
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_bin_tail_a_swapped]
    mov rdx, pat_bin_tail_a_swapped_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_no
    mov r13d, 1
.tsbk_tail_a_ok:
    add r10, pat_bin_tail_a_len
    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsbk_no
    add r10, r11
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_bin_tail_b]
    mov rdx, pat_bin_tail_b_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_no

    mov r15, r9
    sub r15, r14                     # opcode len

    # match opcode token and set r14/r15
    cmp r15, tok_add_wrap_len
    jne .tsbk_chk_sub
    mov rdi, r12
    add rdi, r14
    lea rsi, [rip+tok_add_wrap]
    mov rdx, tok_add_wrap_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_chk_sub
    lea r14, [rip+code_stub_add]
    mov r15, code_stub_add_len
    mov qword ptr [rip+build_kernel_kind], 1
    jmp .tsbk_yes

.tsbk_chk_sub:
    cmp r15, tok_add_trap_len
    jne .tsbk_chk_sub_real
    mov rdi, r12
    add rdi, r14
    lea rsi, [rip+tok_add_trap]
    mov rdx, tok_add_trap_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_chk_sub_real
    lea r14, [rip+code_stub_add_trap]
    mov r15, code_stub_add_trap_len
    mov qword ptr [rip+build_kernel_kind], 2
    jmp .tsbk_yes

.tsbk_chk_sub_real:
    cmp r15, tok_sub_trap_len
    jne .tsbk_chk_sub_wrap_real
    mov rdi, r12
    add rdi, r14
    lea rsi, [rip+tok_sub_trap]
    mov rdx, tok_sub_trap_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_chk_sub_wrap_real
    cmp r13d, 0
    jne .tsbk_no
    lea r14, [rip+code_stub_sub_trap]
    mov r15, code_stub_sub_trap_len
    mov qword ptr [rip+build_kernel_kind], 4
    jmp .tsbk_yes

.tsbk_chk_sub_wrap_real:
    cmp r15, tok_sub_wrap_len
    jne .tsbk_chk_mul
    mov rdi, r12
    add rdi, r14
    lea rsi, [rip+tok_sub_wrap]
    mov rdx, tok_sub_wrap_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_chk_mul
    cmp r13d, 0
    jne .tsbk_no
    lea r14, [rip+code_stub_sub]
    mov r15, code_stub_sub_len
    mov qword ptr [rip+build_kernel_kind], 3
    jmp .tsbk_yes

.tsbk_chk_mul:
    cmp r15, tok_mul_trap_len
    jne .tsbk_chk_mul_wrap_real
    mov rdi, r12
    add rdi, r14
    lea rsi, [rip+tok_mul_trap]
    mov rdx, tok_mul_trap_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_chk_mul_wrap_real
    lea r14, [rip+code_stub_mul_trap]
    mov r15, code_stub_mul_trap_len
    mov qword ptr [rip+build_kernel_kind], 15
    jmp .tsbk_yes

.tsbk_chk_mul_wrap_real:
    cmp r15, tok_mul_wrap_len
    jne .tsbk_chk_and
    mov rdi, r12
    add rdi, r14
    lea rsi, [rip+tok_mul_wrap]
    mov rdx, tok_mul_wrap_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_chk_and
    lea r14, [rip+code_stub_mul]
    mov r15, code_stub_mul_len
    mov qword ptr [rip+build_kernel_kind], 5
    jmp .tsbk_yes

.tsbk_chk_and:
    cmp r15, tok_and_len
    jne .tsbk_chk_or
    mov rdi, r12
    add rdi, r14
    lea rsi, [rip+tok_and]
    mov rdx, tok_and_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_chk_or
    lea r14, [rip+code_stub_and]
    mov r15, code_stub_and_len
    mov qword ptr [rip+build_kernel_kind], 6
    jmp .tsbk_yes

.tsbk_chk_or:
    cmp r15, tok_or_len
    jne .tsbk_chk_xor
    mov rdi, r12
    add rdi, r14
    lea rsi, [rip+tok_or]
    mov rdx, tok_or_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_chk_xor
    lea r14, [rip+code_stub_or]
    mov r15, code_stub_or_len
    mov qword ptr [rip+build_kernel_kind], 7
    jmp .tsbk_yes

.tsbk_chk_xor:
    cmp r15, tok_xor_len
    jne .tsbk_chk_shl
    mov rdi, r12
    add rdi, r14
    lea rsi, [rip+tok_xor]
    mov rdx, tok_xor_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_chk_shl
    lea r14, [rip+code_stub_xor]
    mov r15, code_stub_xor_len
    mov qword ptr [rip+build_kernel_kind], 8
    jmp .tsbk_yes

.tsbk_chk_shl:
    cmp r15, tok_shl_len
    jne .tsbk_chk_shr
    mov rdi, r12
    add rdi, r14
    lea rsi, [rip+tok_shl]
    mov rdx, tok_shl_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_chk_shr
    cmp r13d, 0
    jne .tsbk_no
    lea r14, [rip+code_stub_shl]
    mov r15, code_stub_shl_len
    mov qword ptr [rip+build_kernel_kind], 9
    jmp .tsbk_yes

.tsbk_chk_shr:
    cmp r15, tok_shr_len
    jne .tsbk_no
    mov rdi, r12
    add rdi, r14
    lea rsi, [rip+tok_shr]
    mov rdx, tok_shr_len
    call mem_eq
    cmp rax, 1
    jne .tsbk_no
    cmp r13d, 0
    jne .tsbk_no
    lea r14, [rip+code_stub_shr]
    mov r15, code_stub_shr_len
    mov qword ptr [rip+build_kernel_kind], 10
    jmp .tsbk_yes

.tsbk_yes:
    mov rax, 1
    jmp .tsbk_done
.tsbk_no:
    xor rax, rax
.tsbk_done:
    pop rcx
    pop rdx
    cmp rax, 1
    je .tsbk_keep_out
    mov r14, rdx
    mov r15, rcx
.tsbk_keep_out:
    pop r13
    pop r12
    pop rbx
    ret

# try_select_const_kernel_code
# rdi=src_ptr, rsi=src_len
# out: rax=1 if generated code in codegen_buf/codegen_len; 0 otherwise
try_select_const_kernel_code:
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    lea rdx, [rip+pat_const_head]
    mov rcx, pat_const_head_len
    mov rdi, r12
    mov rsi, r13
    call find_substr_pos
    cmp rax, -1
    je .tsck_no

    mov r8, rax
    add r8, pat_const_head_len       # value-id start
    cmp r8, r13
    jae .tsck_no

    mov rbx, r8                      # preserve value-id start
    mov r10, r8
.tsck_vid_loop:
    cmp r10, r13
    jae .tsck_no
    mov al, byte ptr [r12+r10]
    cmp al, '0'
    jb .tsck_done_vid
    cmp al, '9'
    ja .tsck_done_vid
    inc r10
    jmp .tsck_vid_loop
.tsck_done_vid:
    cmp r10, r8
    je .tsck_no
    mov r15, r10
    sub r15, rbx                      # preserve value-id digit len

    mov r11, r13
    sub r11, r10
    cmp r11, pat_const_mid_len
    jb .tsck_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_const_mid]
    mov rdx, pat_const_mid_len
    call mem_eq
    cmp rax, 1
    jne .tsck_no
    add r10, pat_const_mid_len        # literal start
    cmp r10, r13
    jae .tsck_no

    xor r9, r9                        # sign flag
    mov al, byte ptr [r12+r10]
    cmp al, '-'
    jne .tsck_digits
    mov r9, 1
    inc r10
    cmp r10, r13
    jae .tsck_no
.tsck_digits:
    mov r8, r10                       # literal digit start
    xor r14, r14                      # magnitude
.tsck_loop:
    cmp r10, r13
    jae .tsck_no
    mov al, byte ptr [r12+r10]
    cmp al, '0'
    jb .tsck_done_digits
    cmp al, '9'
    ja .tsck_done_digits
    imul r14, r14, 10
    movzx rax, al
    sub rax, '0'
    add r14, rax
    inc r10
    jmp .tsck_loop
.tsck_done_digits:
    cmp r10, r8
    je .tsck_no

    mov r11, r13
    sub r11, r10
    cmp r11, pat_const_tail_a_len
    jb .tsck_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_const_tail_a]
    mov rdx, pat_const_tail_a_len
    call mem_eq
    cmp rax, 1
    jne .tsck_no
    add r10, pat_const_tail_a_len

    mov r11, r15                      # value-id digit len
    cmp r11, 0
    je .tsck_no
    mov rax, r13
    sub rax, r10
    cmp rax, r11
    jb .tsck_no
    mov rdi, r12
    add rdi, r10
    mov rsi, r12
    add rsi, rbx
    mov rdx, r11
    call mem_eq
    cmp rax, 1
    jne .tsck_no
    add r10, r11

    mov rax, r13
    sub rax, r10
    cmp rax, pat_const_tail_b_len
    jb .tsck_no
    mov rdi, r12
    add rdi, r10
    lea rsi, [rip+pat_const_tail_b]
    mov rdx, pat_const_tail_b_len
    call mem_eq
    cmp rax, 1
    jne .tsck_no

    mov rax, r14
    cmp r9, 1
    jne .tsck_emit
    neg rax

.tsck_emit:
    lea rdi, [rip+codegen_buf]
    mov byte ptr [rdi+0], 0x48
    mov byte ptr [rdi+1], 0xb8
    mov qword ptr [rdi+2], rax
    mov byte ptr [rdi+10], 0xc3
    mov qword ptr [rip+codegen_len], 11
    mov rax, 1
    jmp .tsck_done

.tsck_no:
    xor rax, rax
.tsck_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

# find_substr
# rdi=hay_ptr, rsi=hay_len, rdx=needle_ptr, rcx=needle_len
# out: rax=1 if found else 0
find_substr:
    cmp rcx, 0
    je .fs_yes
    cmp rsi, rcx
    jb .fs_no
    mov r8, 0
.fs_outer:
    mov r9, rsi
    sub r9, rcx
    cmp r8, r9
    ja .fs_no
    mov r10, 0
.fs_inner:
    cmp r10, rcx
    je .fs_yes
    mov r11, r8
    add r11, r10
    mov al, byte ptr [rdi+r11]
    mov r11, rdx
    add r11, r10
    mov r11b, byte ptr [r11]
    cmp al, r11b
    jne .fs_next
    inc r10
    jmp .fs_inner
.fs_next:
    inc r8
    jmp .fs_outer
.fs_yes:
    mov rax, 1
    ret
.fs_no:
    xor rax, rax
    ret

# parse_u64_cstr
# rdi = NUL-terminated string
# out: rax=value, rdx=1 valid; rdx=0 invalid
parse_u64_cstr:
    xor rax, rax
    xor rcx, rcx
.puc_loop:
    mov r8b, byte ptr [rdi+rcx]
    cmp r8b, 0
    je .puc_done
    cmp r8b, '0'
    jb .puc_bad
    cmp r8b, '9'
    ja .puc_bad
    imul rax, rax, 10
    movzx r9, r8b
    sub r9, '0'
    add rax, r9
    inc rcx
    jmp .puc_loop
.puc_done:
    cmp rcx, 0
    je .puc_bad
    mov rdx, 1
    ret
.puc_bad:
    xor rax, rax
    xor rdx, rdx
    ret

# print_u64_nl
# rdi = value
print_u64_nl:
    lea rsi, [rip+num_buf+31]
    mov byte ptr [rsi], 10
    mov rcx, 1
    cmp rdi, 0
    jne .pun_loop
    dec rsi
    mov byte ptr [rsi], '0'
    inc rcx
    jmp .pun_write
.pun_loop:
    mov rax, rdi
    xor rdx, rdx
    mov r10, 10
    div r10
    dec rsi
    add dl, '0'
    mov byte ptr [rsi], dl
    inc rcx
    mov rdi, rax
    test rdi, rdi
    jne .pun_loop
.pun_write:
    mov rdi, 1
    mov rdx, rcx
    call write_fd
    ret

# rdi=fd rsi=buf rdx=len
write_fd:
    mov rax, 1
    syscall
    ret

# rdi=fd rsi=buf rdx=len ; rax=0 success, -1 error
write_all:
    mov r8, rsi
    mov r9, rdx
.wa_loop:
    cmp r9, 0
    je .wa_ok
    mov rax, 1
    mov rsi, r8
    mov rdx, r9
    syscall
    test rax, rax
    jle .wa_err
    add r8, rax
    sub r9, rax
    jmp .wa_loop
.wa_ok:
    xor rax, rax
    ret
.wa_err:
    mov rax, -1
    ret

# rdi=status
exit:
    mov rax, 60
    syscall
    hlt
