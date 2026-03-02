# SysV AMD64 ABI Notes for L0

Target: Linux x86-64 SysV ABI

I currently implement and test these bootstrap rules:
- integer args in: rdi, rsi, rdx, rcx, r8, r9
- integer return in: rax
- caller-saved: rax, rcx, rdx, rsi, rdi, r8-r11
- callee-saved: rbx, rbp, r12-r15
- stack alignment 16-byte before call

Current M58 coverage I lock in tests:
- `l0c run` accepts up to six optional u64 arguments and maps them to SysV integer-arg registers.
- deterministic 3/4/5/6-arg entry lowering fixtures verify end-to-end argument register behavior:
  - `tests/valid_sysv_abi_sum3_lowered.l0` (kernel kind 29)
  - `tests/valid_sysv_abi_sum4_lowered.l0` (kernel kind 30)
  - `tests/valid_sysv_abi_sum5_lowered.l0` (kernel kind 31)
  - `tests/valid_sysv_abi_sum6_lowered.l0` (kernel kind 32)
- generalized dead-const normalization path is covered for the 6-arg SysV shape.
- non-matching 6-arg shape fallback is covered and remains intentionally unlowered (`kernel_kind 0`).
