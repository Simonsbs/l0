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
- I emit debug index metadata with function/type counts, kernel kind id, emitted code size, and trace schema metadata.
- I emit deterministic kernel-kind-specific debug-map instruction ranges when I build with `--debug-map`.
- I keep the bootstrap trace-kernel debug-map split stable (`inst_id 1` trace bytes, `inst_id 2` return-path bytes) for deterministic `tracejoin`.
- I lock debug-map layouts for multiple kernel families in regression tests (`add.trap`, `mul.trap`, `cbr`, `malloc`, `write`, `trace`) to catch map drift early.
- I validate debug-map entry integrity (`inst_id != 0`, `start <= end <= code_size`) in `mapcat` and `tracejoin`.
- I enforce strict debug-map ordering in `mapcat` and `tracejoin` (`inst_id` strictly increasing and monotonic non-overlapping ranges).
- I require `tracejoin` to resolve every trace record `id` against the debug map; unknown ids are rejected.
- I reject truncated/non-16-byte-aligned trace payloads in both `tracecat` and `tracejoin`.
- I treat empty trace payloads as valid in `tracecat`/`tracejoin` and emit no output for them.
- I keep `imgcheck` tamper coverage broad in tests (header-size/offset corruption and code/debug section-pair consistency failures).
- I include overflow-style `imgcheck` tamper tests where `code_off`/`debug_off` are forced to max `u64`.
- I also tamper-test `src_size`/`code_size` overflow and `debug_size != 64` rejection in `imgcheck`.
- I enforce `imgmeta` schema checks (kernel-kind range, debug code-size match, trace schema constants) and test tampered-image rejection for them.
- I currently lower canonical single-block kernel shapes to concrete x86-64 payloads:
  - two-arg arithmetic/bitwise kernels (`add.wrap`, `add.trap`, `sub.wrap`, `sub.trap`, `mul.wrap`, `mul.trap`, `and`, `or`, `xor`, `shl`, `shr`)
  - for commutative binary kernels (`add*`, `mul*`, `and`, `or`, `xor`), I also lower canonical swapped operand order (`v1 v0`) in the bootstrap selector
  - binary kernel lowering now accepts canonical nonzero result ids when `ret` references the same result value id (`vN = <op> ...`, `ret vN`)
  - I keep swapped non-commutative forms (for example `sub.wrap v1 v0`) outside current lowering and covered by regression tests as intentionally unlowered
  - two-arg compare kernel (`icmp.eq`) returning `i1`
  - canonical `icmp.eq + cbr` select kernel returning either arg0 or arg1
  - for `icmp.eq` and `icmp.eq + cbr`, I also lower canonical swapped compare order (`icmp.eq v1 v0`)
  - `icmp.eq` lowering now accepts canonical nonzero compare-result ids when `ret` uses the same value id (`vN = icmp.eq ...`, `ret vN`)
  - `icmp.eq + cbr` lowering now accepts canonical nonzero compare-result ids when `cbr` uses the same value id (`vN = icmp.eq ...`, `cbr vN ...`)
  - I keep mismatched `icmp.eq + cbr` id/dataflow shapes outside current lowering and regression-test them as intentionally unlowered
  - canonical memory roundtrip kernel (`alloca` + `st` + `ld` + `ret`)
  - canonical `gep` memory roundtrip kernel (`alloca` + `st` + `gep` + `ld` + `ret`)
  - canonical two-function call kernels (`f0` calls `f1` where `f1` is `add.wrap`, `sub.wrap`, or `mul.wrap`)
  - for call->`add.wrap` and call->`mul.wrap`, I also lower swapped call-arg form in `f0` (`call f1 v1 v0`)
  - call-kernel lowering now accepts canonical nonzero call-result ids in `f0` when `ret` references the same value id (`vN = call ...`, `ret vN`)
  - I keep mismatch call-result/dataflow shapes outside current lowering and regression-test them as intentionally unlowered
  - canonical intrinsic kernels (`malloc` allocator syscall path, `free` no-op path, `exit` syscall path, `write` syscall path, `trace` stderr-binary emit path)
  - malloc-kernel lowering now accepts canonical nonzero arg/result ids when `malloc` and `ret` reference the corresponding defined ids (`vN = arg ...`, `vM = malloc vN`, `ret vM`)
  - I keep mismatched malloc result/return-id shapes outside current lowering and regression-test them as intentionally unlowered
  - free-noop kernel lowering now accepts canonical nonzero arg/const-ret ids when `free` and `ret` reference the corresponding defined ids (`vN = arg ...`, `free vN`, `vM = const 0`, `ret vM`)
  - I keep mismatched free-noop const/return-id shapes outside current lowering and regression-test them as intentionally unlowered
  - trace-kernel lowering now accepts canonical nonzero trace/dataflow value ids when `trace` and `ret` both reference the corresponding defined ids (`vN = arg ...`, `trace 1 vN`, `vM = const 0`, `ret vM`)
  - I keep mismatched trace id/dataflow shapes outside current lowering and regression-test them as intentionally unlowered
  - zero-arg constant-return kernel (`const N` or `const -N` then `ret v0`)
  - const-return lowering accepts canonical nonzero SSA ids when `ret` uses the same const-def value (`vN = const ...`, `ret vN`)
- I keep a deterministic `ret` fallback stub for other verified inputs.
- I can run `l0c run <file.l0img> [u64_a] [u64_b]` to execute emitted code in an executable mmap region and print the returned `u64` value.
- I enforce function/block structural rules in `fns`.
- I enforce contiguous canonical function ordering (`f0`, `f1`, `f2`, ...).
- I enforce canonical entry block (`b0`) per function.
- I reject duplicate `b0` and duplicate block labels in a function.
- I enforce contiguous canonical block ordering (`b0`, `b1`, `b2`, ...).
- I enforce bootstrap opcode-operand checks for `arg`, `const`, and common binary ops.
- I enforce bootstrap memory-op checks for `ld`, `gep`, and `alloca`, plus non-value `st`.
- I enforce bootstrap intrinsic checks for `malloc` (value op), `free`/`exit`/`write`/`trace` (non-value ops), including non-pointer operand constraints for intrinsic size/code/length values and def-before-use checks for traced values.
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
- Project status dashboard: `docs/STATUS.md`
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
./bin/l0c canon <module.l0> -o <out.l0>
./bin/l0c verify <module.l0>
./bin/l0c build <module.l0> <out.l0img>
./bin/l0c build <module.l0> -o <out.l0img>
./bin/l0c build <module.l0> <out.l0img> --trace-schema <trace_schema.bin>
./bin/l0c build <module.l0> <out.l0img> --debug-map <debug_map.bin>
./bin/l0c build <module.l0> <out.l0img> --trace-schema <trace_schema.bin> --debug-map <debug_map.bin>
./bin/l0c imgcheck <out.l0img>
./bin/l0c imgmeta <out.l0img>
./bin/l0c run <out.l0img> [u64_a] [u64_b]
./bin/l0c tracecat <trace.bin>
./bin/l0c mapcat <debug_map.bin>
./bin/l0c schemacat <trace_schema.bin>
./bin/l0c tracejoin <trace.bin> <debug_map.bin>
```

## Notes

This is still an early implementation slice. I am implementing parser, verifier, codegen, image format, loader, and trace pipeline incrementally from the frozen spec.
