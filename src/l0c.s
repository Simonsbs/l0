.intel_syntax noprefix

.section .bss
.lcomm file_buf, 1048576
.lcomm out_path_ptr, 8
.lcomm img_header_buf, 80

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
    mov rax, qword ptr [r8+16]    # header_size
    cmp rax, img_header_len
    jne fail_img
    mov rax, qword ptr [r8+32]    # src_off
    cmp rax, img_header_len
    jne fail_img
    mov rax, qword ptr [r8+40]    # src_size
    add rax, img_header_len
    cmp rax, rbx
    jne fail_img

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

    # fns payload may contain inner braces; only enforce module tail:
    # final non-newline byte must be '}'
    cmp r13, 1
    jb .bad
    mov rcx, r13
    dec rcx
.trim_tail_nl:
    mov al, byte ptr [r12+rcx]
    cmp al, 10
    jne .tail_found
    cmp rcx, 0
    je .bad
    dec rcx
    jmp .trim_tail_nl
.tail_found:
    cmp al, '}'
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
