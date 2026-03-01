# L0

I am building L0 as a low-level, typed SSA source language focused on deterministic compilation and LLM-friendly workflows.

I am keeping this repository native-only during bootstrap:
- I implement the compiler in x86-64 assembly.
- I use no runtime dependency beyond Linux syscalls.
- I build with GNU binutils + make.

## Current status

Current bootstrap status:
- I have a working `l0c` CLI skeleton (`canon`, `verify`).
- I can run `l0c build` to produce deterministic `.l0img` output with header, source payload, a bootstrap x86-64 code stub section, and a debug index section.
- I currently lower canonical single-block kernel shapes to concrete x86-64 payloads:
  - two-arg arithmetic/bitwise kernels (`add.wrap`, `sub.wrap`, `mul.wrap`, `and`, `or`, `xor`, `shl`, `shr`)
  - two-arg compare kernel (`icmp.eq`) returning `i1`
  - canonical `icmp.eq + cbr` select kernel returning either arg0 or arg1
  - canonical memory roundtrip kernel (`alloca` + `st` + `ld` + `ret`)
  - zero-arg constant-return kernel (`const N` or `const -N` then `ret v0`)
- I keep a deterministic `ret` fallback stub for other verified inputs.
- I can run `l0c run <file.l0img> [u64_a] [u64_b]` to execute emitted code in an executable mmap region and print the returned `u64` value.
- I enforce function/block structural rules in `fns`.
- I enforce contiguous canonical function ordering (`f0`, `f1`, `f2`, ...).
- I enforce canonical entry block (`b0`) per function.
- I reject duplicate `b0` and duplicate block labels in a function.
- I enforce contiguous canonical block ordering (`b0`, `b1`, `b2`, ...).
- I enforce bootstrap opcode-operand checks for `arg` and common binary ops.
- I enforce bootstrap opcode-operand checks for `arg`, `const`, and common binary ops.
- I enforce bootstrap memory-op checks for `ld`, `gep`, and `alloca`, plus non-value `st`.
- I reject unknown opcode tokens in the bootstrap subset.
- I reject duplicate SSA value definitions (`vN`) within a function.
- I enforce `arg` index bounds against the function argument count.
- I enforce that `br`/`cbr` targets reference blocks declared in the same function.
- I enforce def-before-use for bootstrap value uses in `ret vN`, `cbr vN`, and binary `vN vN` ops.
- I enforce bootstrap `call` argument shape (`fN` then optional `vN...`) and def-before-use for call operands.
- I enforce that every `call fN` target references a declared function in the module.
- I enforce bootstrap `call` arity matching against the declared callee signature.
- I enforce that `call` result type suffix matches the declared callee return type.
- I enforce type compatibility for bootstrap `arg`, `ret vN`, and binary `vN vN` operations.
- I enforce pointer-type compatibility (`p0<i8>`) for bootstrap `ld`, `st`, `gep`, and `alloca` checks.
- I enforce that `cbr` condition values are typed as `i1`.
- I parse `types` in bootstrap form and enforce contiguous canonical type IDs (`t0`, `t1`, `t2`, ...).
- I restrict bootstrap `types` RHS tokens to the current primitive set (`i1`, `i8`, `i16`, `i32`, `i64`, `u8`, `u16`, `u32`, `u64`, `p0<i8>`).
- I enforce that every referenced `tN` in function signatures and value result suffixes exists.
- I use syscall-only file loading.
- I validate strict module section order.
- `canon` currently validates and echoes canonical source.

## Documentation

- Language reference: `docs/LANGUAGE.md`
- MVP/compiler spec: `docs/SPEC.md`
- Implementable spec contract: `docs/IMPLEMENTABLE_SPEC.md`
- Canonicalization notes: `docs/CANON.md`
- ABI notes: `docs/ABI_SYSV_AMD64.md`
- Execution plan: `docs/PLAN.md`

## Build

```sh
make
```

## Usage

```sh
./bin/l0c canon <module.l0>
./bin/l0c verify <module.l0>
./bin/l0c build <module.l0> <out.l0img>
./bin/l0c imgcheck <out.l0img>
./bin/l0c run <out.l0img> [u64_a] [u64_b]
```

## Notes

This is still an early implementation slice. I am implementing parser, verifier, codegen, image format, loader, and trace pipeline incrementally from the frozen spec.
