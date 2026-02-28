# SysV AMD64 ABI Notes for L0

Target: Linux x86-64 SysV ABI

MVP lowering rules to implement:
- integer args in: rdi, rsi, rdx, rcx, r8, r9
- integer return in: rax
- caller-saved: rax, rcx, rdx, rsi, rdi, r8-r11
- callee-saved: rbx, rbp, r12-r15
- stack alignment 16-byte before call
