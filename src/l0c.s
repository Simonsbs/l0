.intel_syntax noprefix

.section .bss
.lcomm file_buf, 1048576
.lcomm out_path_ptr, 8
.lcomm img_header_buf, 80
.lcomm vfp_state_in_fn, 8
.lcomm vfp_fn_seen, 8
.lcomm vfp_block_seen, 8
.lcomm vfp_term_seen, 8
.lcomm vfp_fn_arg_count, 8
.lcomm vfp_block_seen_map, 2048
.lcomm vfp_value_seen_map, 8192

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
    call skip_until_close_brace_newline
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

    mov qword ptr [rip+vfp_state_in_fn], 0
    mov qword ptr [rip+vfp_fn_seen], 0
    mov qword ptr [rip+vfp_block_seen], 0
    mov qword ptr [rip+vfp_term_seen], 0

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
    mov rax, 1
    jmp .vfp_done

.vfp_try_fn_header:
    mov rdi, r12
    mov rsi, r13
    call line_is_fn_header
    cmp rax, 1
    jne .vfp_bad
    mov qword ptr [rip+vfp_state_in_fn], 1
    mov qword ptr [rip+vfp_fn_seen], 1
    mov qword ptr [rip+vfp_block_seen], 0
    mov qword ptr [rip+vfp_term_seen], 0
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
    mov qword ptr [rip+vfp_term_seen], 1
    jmp .vfp_next_line

.vfp_try_value_instr:
    mov rdi, r12
    mov rsi, r13
    call line_is_value_instruction
    cmp rax, 1
    jne .vfp_bad
    # SSA uniqueness: vN may be defined only once per function
    mov rdi, r12
    mov rsi, r13
    call parse_value_lhs_id
    cmp rax, 0
    jl .vfp_bad
    mov rdi, rax
    call test_and_set_value_seen
    cmp rax, 1
    je .vfp_bad
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
    call parse_digits
    cmp rax, 1
    jne .lfh_no
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
.pbi_conv:
    cmp r8, rsi
    jae .pbi_ok
    cmp r8, rcx
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
    mov r15, r9
    sub r15, 3                   # args_end (exclusive), suffix start
    cmp r15, r14                 # args must be non-empty
    jbe .lvi_no

    # opcode-aware checks
    # "arg" => args must be digits only
    mov r10, r13
    sub r10, r12
    cmp r10, 3
    jne .lvi_check_binary
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
