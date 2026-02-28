.intel_syntax noprefix

.section .bss
.lcomm file_buf, 1048576
.lcomm out_path_ptr, 8
.lcomm img_header_buf, 80
.lcomm vfp_state_in_fn, 8
.lcomm vfp_fn_seen, 8
.lcomm vfp_type_count, 8
.lcomm vfp_type_is_i1_map, 32768
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
usage_msg: .ascii "usage: l0c <canon|verify> <input.l0> | l0c build <input.l0> <out.l0img> | l0c imgcheck <file.l0img>\n"
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

cmd_canon: .ascii "canon\0"
cmd_verify: .ascii "verify\0"
cmd_build: .ascii "build\0"
cmd_imgcheck: .ascii "imgcheck\0"
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
    jne usage
    jmp do_canon

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
    cmp r13, 4
    jne usage
    mov r11, [r12+32]         # argv[3] output path
    mov qword ptr [rip+out_path_ptr], r11
    jmp do_build

.check_imgcheck:
    lea rsi, [rip+cmd_imgcheck]
    mov rdi, r14
    call str_eq
    cmp rax, 1
    jne usage
    cmp r13, 3
    jne usage
    jmp do_imgcheck

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
    # qword[0]  = magic "L0IM"
    # qword[1]  = version
    # qword[2]  = header size
    # qword[3]  = flags
    # qword[4]  = src offset
    # qword[5]  = src size
    # qword[6]  = code offset (0 in bootstrap)
    # qword[7]  = code size   (0 in bootstrap)
    # qword[8]  = debug offset (0 in bootstrap)
    # qword[9]  = debug size   (0 in bootstrap)
    lea r8, [rip+img_header_buf]
    mov rax, 0x000000004d49304c
    mov qword ptr [r8+0], rax
    mov qword ptr [r8+8], 1
    mov qword ptr [r8+16], img_header_len
    mov qword ptr [r8+24], 0
    mov qword ptr [r8+32], img_header_len
    mov qword ptr [r8+40], rbx
    mov qword ptr [r8+48], 0
    mov qword ptr [r8+56], 0
    mov qword ptr [r8+64], 0
    mov qword ptr [r8+72], 0

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
    mov rax, 3                 # sys_close
    syscall

    lea rsi, [rip+ok_msg]
    mov rdx, ok_len
    mov rdi, 1
    call write_fd
    mov rdi, 0
    call exit

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
    jne fail_img

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
    cmp r12, r10
    jb fail_img
    cmp r12, rbx
    ja fail_img
    mov rax, r12
    add rax, r13
    jc fail_img
    cmp rax, rbx
    ja fail_img

.img_ok:

    lea rsi, [rip+ok_msg]
    mov rdx, ok_len
    mov rdi, 1
    call write_fd
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
    # mark type id as i1 when token exactly "i1"
    mov r11, rcx
    sub r11, r8
    cmp r11, 2
    jne .vts_tok_kind_done
    mov al, byte ptr [r12+r8]
    cmp al, 'i'
    jne .vts_tok_kind_done
    mov al, byte ptr [r12+r8+1]
    cmp al, '1'
    jne .vts_tok_kind_done
    mov r11, r9
    cmp r11, 4096
    jae .vts_bad
    shl r11, 3
    lea r10, [rip+vfp_type_is_i1_map]
    add r10, r11
    mov qword ptr [r10], 1
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
    jne .vfp_bad
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
    jne .vvud_detect_binary
    mov al, byte ptr [r12+r14]
    cmp al, 'c'
    jne .vvud_detect_binary
    mov al, byte ptr [r12+r14+1]
    cmp al, 'a'
    jne .vvud_detect_binary
    mov al, byte ptr [r12+r14+2]
    cmp al, 'l'
    jne .vvud_detect_binary
    mov al, byte ptr [r12+r14+3]
    cmp al, 'l'
    jne .vvud_detect_binary

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
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'r'
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'g'
    jne .lvi_check_binary
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
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12]
    cmp al, 'c'
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12+1]
    cmp al, 'a'
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12+2]
    cmp al, 'l'
    jne .lvi_check_binary
    mov al, byte ptr [rdi+r12+3]
    cmp al, 'l'
    jne .lvi_check_binary

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
    jmp .lvi_yes

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
    mov al, byte ptr [rdi+r8]
    sub al, '0'
    imul rax, rax, 10
    movzx rdx, al
    add rax, rdx
    inc r8
    jmp .pvti_conv
.pvti_ok:
    ret
.pvti_bad:
    mov rax, -1
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
    ret
.mem_eq_ne:
    xor rax, rax
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
