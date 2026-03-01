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
- I now cover broader multi-record trace corruption patterns: I test unknown/zero ids in middle/later records and explicit multi-record truncation paths.
- I keep `imgcheck` tamper coverage broad in tests (header-size/offset corruption and code/debug section-pair consistency failures).
- I include overflow-style `imgcheck` tamper tests where `code_off`/`debug_off` are forced to max `u64`.
- I also tamper-test `src_size`/`code_size` overflow and `debug_size != 64` rejection in `imgcheck`.
- I now run deterministic fuzz-style tamper loops over image header/debug u64 fields and require `imgcheck` to reject every mutated artifact.
- I enforce `imgmeta` schema checks (kernel-kind range, debug code-size match, trace schema constants) and test tampered-image rejection for them.
- I currently lower canonical single-block kernel shapes to concrete x86-64 payloads:
  - two-arg arithmetic/bitwise kernels (`add.wrap`, `add.trap`, `sub.wrap`, `sub.trap`, `mul.wrap`, `mul.trap`, `and`, `or`, `xor`, `shl`, `shr`)
  - for commutative binary kernels (`add*`, `mul*`, `and`, `or`, `xor`), I also lower canonical swapped operand order (`v1 v0`) in the bootstrap selector
  - binary kernel lowering now accepts canonical nonzero result ids when `ret` references the same result value id (`vN = <op> ...`, `ret vN`)
  - binary kernel lowering now accepts canonical nonzero `arg` value ids in `f0` (`vA = arg 0`, `vB = arg 1`) when binary operands reference those exact defined ids
  - I regression-test the dynamic-arg binary selector with multi-digit ids (for example `v77`, `v123`) to keep digit parsing stable
  - I keep swapped non-commutative forms (for example `sub.wrap v1 v0`) outside current lowering and covered by regression tests as intentionally unlowered
  - I keep swapped non-commutative binary forms with nonzero arg ids outside current lowering and covered by regression tests as intentionally unlowered
  - two-arg compare kernel (`icmp.eq`) returning `i1`
  - canonical `icmp.eq + cbr` select kernel returning either arg0 or arg1
  - for `icmp.eq` and `icmp.eq + cbr`, I also lower canonical swapped compare order (`icmp.eq v1 v0`)
  - `icmp.eq` lowering now accepts canonical nonzero compare-result ids when `ret` uses the same value id (`vN = icmp.eq ...`, `ret vN`)
  - `icmp.eq` lowering now accepts canonical nonzero `arg` value ids in `f0` (`vA = arg 0`, `vB = arg 1`) when compare operands reference those exact defined ids
  - `icmp.eq + cbr` lowering now accepts canonical nonzero compare-result ids when `cbr` uses the same value id (`vN = icmp.eq ...`, `cbr vN ...`)
  - `icmp.eq + cbr` lowering now accepts canonical nonzero `arg` value ids in `f0` and enforces `b1`/`b2` return mapping to those arg defs
  - I keep mismatched `icmp.eq + cbr` id/dataflow shapes outside current lowering and regression-test them as intentionally unlowered
  - I keep mismatched `icmp.eq + cbr` branch-return mappings outside current lowering and regression-test them as intentionally unlowered
  - canonical memory roundtrip kernel (`alloca` + `st` + `ld` + `ret`)
  - memory-roundtrip lowering now accepts canonical nonzero ids across arg/alloca/store/load/return dataflow when each use references matching defs
  - memory-roundtrip lowering now accepts canonical nonzero `alloca` element counts (not only `1`) and keeps `alloca ... , 0` intentionally unlowered
  - memory-roundtrip lowering now accepts either canonical arg/alloca definition order in `f0` (`arg` then `alloca`, or `alloca` then `arg`)
  - I keep mismatched memory-roundtrip load/return-id shapes outside current lowering and regression-test them as intentionally unlowered
  - canonical `gep` memory roundtrip kernel (`alloca` + `st` + `gep` + `ld` + `ret`)
  - memory-gep-roundtrip lowering now accepts canonical nonzero ids across arg/alloca/store/gep/load/return dataflow when each use references matching defs
  - memory-gep-roundtrip lowering now accepts canonical nonzero `alloca` element counts (not only `1`) and keeps `alloca ... , 0` intentionally unlowered
  - memory-gep-roundtrip lowering now accepts either canonical arg/alloca definition order in `f0` (`arg` then `alloca`, or `alloca` then `arg`)
  - I keep mismatched memory-gep-roundtrip load/return-id shapes outside current lowering and regression-test them as intentionally unlowered
  - canonical two-function call kernels (`f0` calls `f1` where `f1` is `add.wrap`, `sub.wrap`, `mul.wrap`, `and`, or `or`)
  - for call->commutative targets (`add.wrap`, `mul.wrap`, `and`, `or`), I also lower swapped call-arg form in `f0` (`call f1 v1 v0`)
  - call-kernel lowering now accepts either canonical arg-definition order in `f0` (`arg 0` then `arg 1`, or `arg 1` then `arg 0`)
  - for call->`sub.wrap`, I preserve non-commutative guardrails by lowering only semantic arg0->arg1 mapping under either arg-definition order
  - call-kernel lowering now also accepts either canonical arg-definition order inside `f1` (`arg 0` then `arg 1`, or `arg 1` then `arg 0`)
  - for call->`sub.wrap`, I preserve non-commutative semantics under `f1` arg-definition-order variants by requiring semantic arg0->arg1 mapping in `f1`
  - call-kernel lowering now accepts canonical nonzero call-result ids in `f0` when `ret` references the same value id (`vN = call ...`, `ret vN`)
  - call-kernel lowering now accepts canonical nonzero internal result ids in `f1` when `ret` references the same value id (`vN = add.wrap|sub.wrap|mul.wrap ...`, `ret vN`)
  - call-kernel lowering now accepts canonical swapped operand order inside `f1` for commutative ops (`add.wrap`, `mul.wrap`)
  - I regression-test multi-digit SSA id lowering paths (for example `v77`, `v123`) across const, intrinsic, and memory-selector families to catch digit-scan regressions
  - I keep mismatch call-result/dataflow shapes outside current lowering and regression-test them as intentionally unlowered
  - I keep mismatch `f1` op-result/return-id call-kernel shapes outside current lowering and regression-test them as intentionally unlowered
  - I keep swapped non-commutative `f1` call-kernel shapes (`sub.wrap v1 v0`) outside current lowering and regression-test them as intentionally unlowered
  - canonical intrinsic kernels (`malloc` allocator syscall path, `free` no-op path, `exit` syscall path, `write` syscall path, `trace` stderr-binary emit path)
  - malloc-kernel lowering now accepts canonical nonzero arg/result ids when `malloc` and `ret` reference the corresponding defined ids (`vN = arg ...`, `vM = malloc vN`, `ret vM`)
  - I keep mismatched malloc result/return-id shapes outside current lowering and regression-test them as intentionally unlowered
  - free-noop kernel lowering now accepts canonical nonzero arg/const-ret ids when `free` and `ret` reference the corresponding defined ids (`vN = arg ...`, `free vN`, `vM = const 0`, `ret vM`)
  - I keep mismatched free-noop const/return-id shapes outside current lowering and regression-test them as intentionally unlowered
  - exit-kernel lowering now accepts canonical nonzero arg/ret ids when `exit` and `ret` reference the same defined value id (`vN = arg ...`, `exit vN`, `ret vN`)
  - I keep mismatched exit arg/return-id shapes outside current lowering and regression-test them as intentionally unlowered
  - write-newline kernel lowering now accepts canonical nonzero ids across alloca/const/store/write/return dataflow when each use references its matching defined value id
  - write-newline kernel lowering now accepts canonical nonzero `alloca` element counts (not only `1`) and keeps `alloca ... , 0` intentionally unlowered
  - I keep mismatched write-newline const/return-id shapes outside current lowering and regression-test them as intentionally unlowered
  - trace-kernel lowering now accepts canonical nonzero trace/dataflow value ids when `trace` and `ret` both reference the corresponding defined ids (`vN = arg ...`, `trace 1 vN`, `vM = const 0`, `ret vM`)
  - I keep mismatched trace id/dataflow shapes outside current lowering and regression-test them as intentionally unlowered
  - zero-arg constant-return kernel (`const N` or `const -N` then `ret v0`)
  - const-return lowering accepts canonical nonzero SSA ids when `ret` uses the same const-def value (`vN = const ...`, `ret vN`)
- I keep a deterministic `ret` fallback stub for other verified inputs.
- I now consider my M5 bootstrap selector-broadening milestone complete.
- I now consider my M6 selector-decoupling milestone complete: I lower binary, `icmp.eq`, and `icmp.eq + cbr` kernels independent of arg-definition line order in `f0`, with guardrails preserved.
- I now consider my M7 selector-decoupling completion milestone complete: I lower call kernels independent of arg-definition line order in `f0` while preserving non-commutative `sub.wrap` guardrails.
- I now consider my M8 selector-decoupling completion milestone complete: I lower call kernels correctly across canonical arg-definition-order variants in both `f0` and `f1`, with non-commutative `sub.wrap` semantics preserved.
- I now consider my M10 selector-decoupling completion milestone complete: I lower memory roundtrip and memory-gep roundtrip kernels across canonical nonzero `alloca` element counts while preserving strict `alloca ... , 0` guardrails.
- I now consider my M11 selector-decoupling completion milestone complete: I lower the write-newline kernel across canonical nonzero `alloca` element counts while preserving strict `alloca ... , 0` guardrails.
- I now consider my M12 selector-decoupling completion milestone complete: I lower memory roundtrip and memory-gep roundtrip kernels independent of arg/alloca definition order in `f0`, while preserving intentional unlowered guardrails for mismatched dataflow.
- I now consider my M13 generalized binary-lowering milestone complete: before binary selection, I run a normalization pass that strips canonical dead `const` value lines and then lower from the normalized function shape, while preserving existing non-commutative guardrails.
- I now consider my M14 generalized compare/select normalization milestone complete: I reuse the same dead-const normalization path for `icmp.eq` and `icmp.eq + cbr` lowering, and I regression-test both lowered and intentional unlowered guardrail outcomes.
- I now consider my M15 generalized call normalization milestone complete: I reuse the same dead-const normalization path for call-kernel lowering across `f0` and `f1`, and I regression-test both lowered and intentional unlowered non-commutative guardrail outcomes.
- I now consider my M16 generalized memory/malloc/exit normalization milestone complete: I run the same dead-const normalization path before memory roundtrip, memory-gep roundtrip, `malloc`, and `exit` kernel selection, and I regression-test both lowered and intentionally unlowered mismatch outcomes.
- I now consider my M17 dead-const normalization correctness-hardening milestone complete: I now strip only dead canonical `const` value lines (instead of stripping all const lines), scope dead-const detection to the current function so same numeric value IDs in later functions do not block stripping, and keep generalized lowering behavior stable for my completed kernel families.
- I now consider my M18 backend-readiness integration milestone complete: I wired generalized normalization hooks for the remaining const-dependent intrinsic selector families (`write`/`free`/`trace`) and kept full-suite behavior stable while preserving canonical fallback behavior.
- I now consider my M19 generalized intrinsic hook activation milestone complete: generalized normalization hook stages are active in the build chain for all current intrinsic families with deterministic legacy fallback behavior preserved under full-suite coverage.
- I now consider my M20 const-dependent intrinsic fallback-closure milestone complete: I added explicit regression coverage proving dead-const-injected `write`/`free`/`trace` shapes deterministically remain unlowered (`kernel_kind 0`, `code_size 1`) while generalized hook stages are active.
- I now consider my M21 staged intrinsic fallback-matrix milestone complete: I expanded deterministic fallback coverage to multi-dead-const injected `write`/`free`/`trace` shapes and locked those invariants in the automated suite.
- I now consider my M22 staged intrinsic nonzero-id fallback-matrix milestone complete: I expanded deterministic fallback coverage for dead-const injected `write`/`free`/`trace` shapes that use nonzero/multi-digit SSA ids and locked those invariants in the automated suite.
- I now consider my M23 staged intrinsic mixed-variant fallback-matrix milestone complete: I expanded deterministic fallback coverage across mixed canonical variants (`alloca` count variants plus nonzero-id and multi-dead-const combinations) for `write`/`free`/`trace` and locked those invariants in the automated suite.
- I now consider my M24 staged intrinsic write-guardrail fallback-closure milestone complete: I expanded deterministic fallback coverage for dead-const-injected write guardrail shapes with `alloca 0` and locked those invariants in the automated suite.
- I now consider my M25 staged intrinsic stress fallback-matrix milestone complete: I expanded deterministic fallback coverage to higher-stress combinations (write guardrail + nonzero ids + multi-dead-const injections, plus deeper free/trace dead-const stacks) and locked those invariants in the automated suite.
- I now consider my M26 staged intrinsic cross-function fallback-matrix milestone complete: I expanded deterministic fallback coverage for dead-const-injected `write`/`free`/`trace` shapes into cross-function mixed variants and locked those invariants in the automated suite.
- I now consider my M27 const-dependent intrinsic dead-const lowering-closure milestone complete: I fixed dead-const normalization id-length matching and now lower valid dead-const-injected `write`/`free`/`trace` shapes (including nonzero-id, multi-dead-const, and cross-function variants) while preserving intentional write `alloca 0` guardrail fallback.
- I now consider my M28 generalized intrinsic-selector pipeline cutoff milestone complete: in `build` I removed legacy direct fallback stages for `trace`/`write`/`free` and route those families through generalized normalized selector paths only, with full regression stability preserved.
- I now consider my M29 generalized selector-chain unification milestone complete: in `build` I removed the remaining legacy direct fallback stages for generalized families (`exit`, `malloc`, `call`, memory roundtrip families, compare/select, and binary), so all generalized families now route through normalization+selector stages only.
- I now consider my M30 generalized selector-chain completion milestone complete: I routed const-return through the same generalized normalization path and added dead-const/cross-function const regression coverage, so all current kernel families now flow through generalized normalization+selector stages.
- I now consider my M31 call-family backend expansion milestone complete: I extended two-function call lowering to include canonical `and` kernels (including swapped call-arg order and dead-const generalized variants) with full regression coverage.
- I now consider my M32 call-family backend expansion milestone complete: I extended two-function call lowering to include canonical `or` kernels (including swapped call-arg order and dead-const generalized variants) with full regression coverage.
- I track full non-template multi-block backend/codegen completion as my next milestone (M33).
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
- Instruction-set quick reference: `docs/INSTRUCTION_SET.md`
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
