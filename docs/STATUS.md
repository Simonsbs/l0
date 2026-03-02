# L0 Project Status

I maintain this file as my current implementation status for the L0 bootstrap.

Last updated: 2026-03-02

## Overall

- I am in bootstrap/MVP implementation mode with a native-only toolchain (`as`, `ld`, `make`).
- I have a deterministic end-to-end loop: `verify -> build -> imgcheck/imgmeta -> run`.
- I have deterministic debug/trace tooling: `tracecat`, `schemacat`, `mapcat`, `tracejoin`.

## Milestone Matrix

### M0: Native bootstrap compiler shell

- Status: complete
- Scope completed:
  - CLI command dispatcher in assembly
  - syscall-only file I/O path
  - canonical section-order validation skeleton

### M1: Verifier baseline

- Status: complete for bootstrap subset
- Scope completed:
  - canonical function/block layout checks
  - SSA single-def and def-before-use checks for supported op families
  - opcode-aware checks for arithmetic, compare, branch, memory, and current intrinsic subset
  - typed signature checks for args/calls/returns/cbr/memory pointer constraints

### M2: Build image + runtime execution

- Status: complete for bootstrap subset
- Scope completed:
  - deterministic `L0IMG` container emission
  - bootstrap code lowering for supported canonical kernel shapes
  - executable mmap loader and invocation path
  - integrity and metadata inspection commands (`imgcheck`, `imgmeta`)

### M3: Trace/debug artifacts

- Status: complete for bootstrap subset
- Scope completed:
  - trace schema side artifact (`--trace-schema`)
  - debug-map side artifact (`--debug-map`) with versioned multi-entry format
  - native decoders (`schemacat`, `mapcat`, `tracecat`)
  - native joiner (`tracejoin`) with strict validation and strict id resolution

### M4: Reliability hardening

- Status: complete
- Scope completed:
  - duplicate optional flag rejection in `build`
  - debug-map entry bounds validation and clamping
  - ordered/non-overlapping map validation
  - strict `tracejoin` id resolution (unknown ids rejected)
  - explicit `tracejoin` rejection test for non-increasing debug-map `inst_id` ordering
  - explicit malformed debug-map payload-size tests: `mapcat` and `tracejoin` both reject misaligned/truncated map payloads
  - explicit debug-map header consistency tests: `mapcat` and `tracejoin` reject mismatched `entry_count` header vs payload size
  - explicit oversized debug-map entry-count tests: `mapcat` rejects oversized count payload artifacts and `tracejoin` rejects `entry_count > 64`
  - explicit malformed trace-schema tests: `schemacat` rejects bad schema version, bad record size, bad field count, and truncated payload size
  - expanded multi-record trace corruption coverage: `tracejoin` rejects unknown `trace_id` appearing in later records while `tracecat` still decodes the mixed payload deterministically
  - expanded multi-record trace corruption matrix:
    - `tracejoin` rejects unknown `trace_id` in middle records
    - `tracejoin` rejects zero `trace_id` in later records
    - `tracecat` deterministic decode coverage for triple-record mixed-id payloads
    - both `tracecat` and `tracejoin` reject truncated multi-record payloads
  - deterministic automated malformed-image tamper matrix for `imgcheck`:
    - fixed-header u64 field fuzz pass (`version`, `header_size`, `src_off`, `src_size`, `code_off`, `code_size`, `debug_off`, `debug_size`)
    - debug-index u64 field fuzz pass (`kernel_kind`, `code_size`, `trace_schema_ver`, `trace_record_size`)
    - explicit nonzero flags tamper case in the fuzz block
  - cross-kernel debug-map layout assertions in regression tests (`add.trap`, `mul.trap`, `cbr`, `malloc`, `write`, `trace`)
  - expanded malformed-image tamper coverage for `imgcheck` (header size, source offset, code/debug pair consistency)
  - overflow-style image tamper checks for `imgcheck` (`src_size`/`code_size`/`code_off`/`debug_off` set to max u64 values)
  - explicit `debug_size != 64` tamper rejection checks
  - `imgmeta` schema-hardening parity with `imgcheck` plus negative tamper tests
  - negative-path tests for malformed artifacts

### M5: Full language/general codegen

- Status: complete for bootstrap generalized-selector scope
- Scope completed:
  - commutative binary bootstrap selector now accepts canonical swapped operand order (`v1 v0`) for `add*`, `mul*`, `and`, `or`, `xor`
  - commutative call-lowering selector now accepts swapped call-arg order in `f0` for call->`add.wrap` and call->`mul.wrap`
  - compare/select bootstrap selector now accepts swapped `icmp.eq` operand order for both `icmp.eq` and `icmp.eq + cbr` kernel templates
  - const-return selector now accepts canonical nonzero value ids when `ret` references the same const-def id
  - const-return selector path is regression-covered for both single-digit and multi-digit value ids
  - non-commutative guardrail test added: swapped `sub.wrap` remains intentionally unlowered in current bootstrap selector
  - binary kernel selector now accepts canonical nonzero result value ids (`vN = <op> ...`, `ret vN`)
  - binary kernel selector now accepts canonical nonzero argument value ids in `f0` (`vA = arg 0`, `vB = arg 1`) when binary operands reference those exact defs
  - binary selector guardrail added: swapped non-commutative `sub.wrap` with nonzero arg ids remains intentionally unlowered
  - binary dynamic-arg selector path is regression-covered for multi-digit ids (`v77`, `v123`)
  - `icmp.eq` selector now accepts canonical nonzero compare-result ids (`vN = icmp.eq ...`, `ret vN`)
  - `icmp.eq` selector now accepts canonical nonzero argument value ids in `f0` (`vA = arg 0`, `vB = arg 1`) when compare operands reference those exact defs
  - `icmp.eq + cbr` selector now accepts canonical nonzero compare-result ids (`vN = icmp.eq ...`, `cbr vN ...`)
  - `icmp.eq + cbr` selector now accepts canonical nonzero argument value ids in `f0` and checks that `b1`/`b2` return the corresponding arg defs
  - guardrail added: `icmp.eq + cbr` path with mismatched compare-id/dataflow shape remains intentionally unlowered in bootstrap selector
  - `icmp.eq + cbr` guardrail added: mismatched branch-return mapping (`b1`/`b2` not returning arg0/arg1 respectively) remains intentionally unlowered
  - call-kernel selector now accepts canonical nonzero call-result ids in `f0` (`vN = call ...`, `ret vN`)
  - call-kernel guardrail added: mismatch between call result id and returned id in `f0` remains intentionally unlowered
  - call-kernel selector now accepts canonical nonzero internal result ids in `f1` for `add.wrap`/`sub.wrap`/`mul.wrap` (`vN = <op> ...`, `ret vN`)
  - call-kernel guardrail added: mismatch between `f1` op-result id and `f1` returned id remains intentionally unlowered
  - call-kernel selector now accepts canonical swapped operand order inside `f1` for commutative ops (`add.wrap`, `mul.wrap`)
  - call-kernel guardrail added: swapped operand order inside `f1` for non-commutative `sub.wrap` remains intentionally unlowered
  - trace intrinsic selector now accepts canonical nonzero value ids for traced arg and returned const value (`trace 1 vN`, `ret vM` where `vM` matches the const-def id)
  - trace selector guardrail added: mismatch between const result id and returned id remains intentionally unlowered
  - malloc intrinsic selector now accepts canonical nonzero arg/result ids (`vN = arg ...`, `vM = malloc vN`, `ret vM`)
  - malloc selector guardrail added: mismatch between malloc result id and returned id remains intentionally unlowered
  - free-noop intrinsic selector now accepts canonical nonzero arg/const-ret ids (`vN = arg ...`, `free vN`, `vM = const 0`, `ret vM`)
  - free-noop selector guardrail added: mismatch between const result id and returned id remains intentionally unlowered
  - exit intrinsic selector now accepts canonical nonzero arg/return ids (`vN = arg ...`, `exit vN`, `ret vN`)
  - exit selector guardrail added: mismatch between exit operand id and returned id remains intentionally unlowered
  - write intrinsic selector now accepts canonical nonzero ids across alloca/const/store/write/ret dataflow for the bootstrap newline kernel template
  - write selector guardrail added: mismatch between final const id and returned id remains intentionally unlowered
  - memory roundtrip selector now accepts canonical nonzero ids across arg/alloca/st/ld/ret dataflow
  - memory roundtrip selector guardrail added: mismatch between load result id and returned id remains intentionally unlowered
  - memory-gep roundtrip selector now accepts canonical nonzero ids across arg/alloca/st/gep/ld/ret dataflow
  - memory-gep selector guardrail added: mismatch between load result id and returned id remains intentionally unlowered
  - expanded multi-digit SSA id regression coverage (`v77`/`v123`) for intrinsic selectors (`malloc`, `free`, `exit`) plus `write`, `trace`, `mem_roundtrip`, and `mem_gep_roundtrip` selector paths to lock digit-parse stability

### M6: Selector-Decoupling Generalization

- Status: complete
- Scope completed:
  - binary selector accepts either canonical arg-definition order in `f0` (`arg 0` then `arg 1`, or `arg 1` then `arg 0`) and normalizes dataflow by arg index
  - commutative binary lowering remains valid under swapped arg-definition order
  - non-commutative guardrail maintained under swapped arg-definition order (`sub.wrap` swapped operands remains intentionally unlowered)
  - `icmp.eq` selector accepts either canonical arg-definition order in `f0` and normalizes compare operand binding by arg index
  - `icmp.eq + cbr` selector accepts either canonical arg-definition order in `f0`, preserves compare-result consistency checks, and preserves strict branch-return mapping checks
  - regression matrix added for arg-definition-order variants (lowered and intentional unlowered guardrail shapes) across binary/icmp/cbr selector families

### M7: Selector-Decoupling Completion (Call Family)

- Status: complete
- Scope completed:
  - call-kernel selector accepts either canonical arg-definition order in `f0` (`arg 0` then `arg 1`, or `arg 1` then `arg 0`)
  - call-kernel lowering remains valid for commutative call targets (`add.wrap`, `mul.wrap`) under either arg-definition order in `f0`
  - non-commutative guardrail is preserved for call->`sub.wrap` under arg-definition-order variants by requiring semantic arg0->arg1 mapping
  - regression matrix added for call arg-definition-order variants (lowered and intentional unlowered guardrail shapes)

### M8: Selector-Decoupling Completion (Call f1 Family)

- Status: complete
- Scope completed:
  - call-kernel selector accepts either canonical arg-definition order in `f1` (`arg 0` then `arg 1`, or `arg 1` then `arg 0`)
  - call-kernel lowering remains valid for commutative `f1` targets (`add.wrap`, `mul.wrap`) under either arg-definition order in `f1`
  - non-commutative guardrail is preserved for call->`sub.wrap` under `f1` arg-definition-order variants by requiring semantic arg0->arg1 mapping
  - regression matrix added for `f1` arg-definition-order variants (lowered and intentional unlowered guardrail shapes)

### M10: Selector-Decoupling Completion (Memory Alloca-Count Family)

- Status: complete
- Scope completed:
  - memory roundtrip selector accepts canonical nonzero `alloca` element counts (`alloca t0, N`, `N > 0`) instead of only `alloca t0, 1`
  - memory-gep roundtrip selector accepts canonical nonzero `alloca` element counts (`alloca t0, N`, `N > 0`) instead of only `alloca t0, 1`
  - strict guardrails preserved: `alloca t0, 0` shapes remain intentionally unlowered
  - regression matrix added for memory alloca-count variants (lowered and intentional unlowered guardrail shapes)

### M11: Selector-Decoupling Completion (Write Alloca-Count Family)

- Status: complete
- Scope completed:
  - write-newline selector accepts canonical nonzero `alloca` element counts (`alloca t0, N`, `N > 0`) instead of only `alloca t0, 1`
  - strict guardrails preserved: write-newline shapes with `alloca t0, 0` remain intentionally unlowered
  - regression matrix added for write-newline alloca-count variants (lowered and intentional unlowered guardrail shapes)

### M12: Selector-Decoupling Completion (Memory Def-Order Family)

- Status: complete
- Scope completed:
  - memory roundtrip selector accepts either canonical arg/alloca definition order in `f0` (`arg` then `alloca`, or `alloca` then `arg`)
  - memory-gep roundtrip selector accepts either canonical arg/alloca definition order in `f0` (`arg` then `alloca`, or `alloca` then `arg`)
  - regression matrix added for swapped memory def-order variants (lowered and intentional unlowered guardrail shapes)

### M13: Generalized Binary Normalization Path

- Status: complete
- Scope completed:
  - added a generalized pre-lowering normalization path for binary kernels in `build`
  - normalization strips canonical dead `const` value lines before binary lowering
  - normalized source is lowered through the existing binary selector path, so existing opcode mappings and non-commutative guardrails are preserved
  - added regression coverage for:
    - lowered add kernel with an injected dead `const` value line
    - intentionally unlowered swapped non-commutative sub kernel with an injected dead `const` value line

### M14: Generalized Compare/Select Normalization Path

- Status: complete
- Scope completed:
  - added generalized pre-lowering normalization path for `icmp.eq` kernels in `build`
  - added generalized pre-lowering normalization path for `icmp.eq + cbr` select kernels in `build`
  - reused shared dead-const normalization so canonical interleaved `const` value lines do not block compare/select lowering
  - preserved existing compare/select guardrails by delegating final lowering decisions to existing selectors
  - added regression coverage for:
    - lowered `icmp.eq` kernel with injected dead `const` value line
    - lowered `icmp.eq + cbr` kernel with injected dead `const` value line
    - intentionally unlowered `icmp.eq + cbr` return-mismatch shape with injected dead `const` value line

### M15: Generalized Call Normalization Path

- Status: complete
- Scope completed:
  - added generalized pre-lowering normalization path for call kernels in `build`
  - reused shared dead-const normalization so canonical interleaved `const` value lines in `f0`/`f1` do not block call-kernel lowering
  - preserved existing call-family non-commutative guardrails by delegating final lowering decisions to existing call selector logic
  - added regression coverage for:
    - lowered call->add kernel with injected dead `const` value lines
    - intentionally unlowered call->sub (swapped in `f1`) with injected dead `const` value lines

### M16: Generalized Memory/Malloc/Exit Normalization Path

- Status: complete
- Scope completed:
  - added generalized pre-lowering normalization path for memory roundtrip kernels in `build`
  - added generalized pre-lowering normalization path for memory-gep roundtrip kernels in `build`
  - added generalized pre-lowering normalization path for `malloc` and `exit` intrinsic kernels in `build`
  - reused shared dead-const normalization so canonical interleaved dead `const` value lines do not block these const-independent kernel families
  - preserved existing mismatch guardrails by delegating final lowering decisions to existing selectors
  - added regression coverage for lowered and intentionally unlowered dead-const-injected variants of memory roundtrip, memory-gep roundtrip, `malloc`, and `exit`

### M17: Dead-Const Normalization Correctness Hardening

- Status: complete
- Scope completed:
  - changed shared dead-const normalization to strip only dead canonical `const` value lines instead of stripping all `const` value lines
  - scoped dead-const use detection to the current function so same numeric value IDs in later functions do not incorrectly keep dead const defs
  - retained generalized lowering behavior for already-completed normalization families (`bin`, `icmp`, `icmp+cbr`, `call`, `memory`, `memory-gep`, `malloc`, `exit`)
  - validated with full suite regression pass, including existing multi-function call dead-const coverage

### M18: Backend-Readiness Integration

- Status: complete
- Scope completed:
  - wired generalized normalization hook stages into `build` for remaining const-dependent intrinsic selector families (`trace`, `write`, `free`) ahead of legacy selector fallbacks
  - kept existing selector behavior stable and deterministic under full regression-suite execution
  - retained legacy canonical fallback behavior for const-dependent intrinsic dead-const-injected shapes while generalized normalization hook path is staged
  - validated end-to-end with full-suite pass

### M19: Generalized Intrinsic Hook Activation

- Status: complete
- Scope completed:
  - activated generalized normalization hook stages in the live `build` selection chain for all current intrinsic families (`trace`, `write`, `exit`, `malloc`, `free`)
  - preserved deterministic legacy selector fallbacks when generalized hook paths do not select
  - validated end-to-end stability with full regression-suite pass

### M20: Const-Dependent Intrinsic Fallback Closure

- Status: complete
- Scope completed:
  - added explicit regression fixtures for dead-const-injected const-dependent intrinsic shapes:
    - `write`
    - `free`
    - `trace`
  - added deterministic build assertions proving these shapes remain intentionally unlowered under active generalized hook staging (`kernel_kind 0`, `code_size 1`)
  - validated with full-suite pass

### M21: Staged Intrinsic Fallback Matrix Expansion

- Status: complete
- Scope completed:
  - added explicit regression fixtures for multi-dead-const injected const-dependent intrinsic shapes:
    - `write`
    - `free`
    - `trace`
  - added deterministic build assertions proving these heavier staged-hook cases remain intentionally unlowered (`kernel_kind 0`, `code_size 1`)
  - validated with full-suite pass

### M22: Staged Intrinsic Nonzero-ID Fallback Matrix Expansion

- Status: complete
- Scope completed:
  - added explicit regression fixtures for dead-const-injected const-dependent intrinsic shapes using nonzero/multi-digit SSA ids:
    - `write`
    - `free`
    - `trace`
  - added deterministic build assertions proving these staged-hook nonzero-id cases remain intentionally unlowered (`kernel_kind 0`, `code_size 1`)
  - validated with full-suite pass

### M23: Staged Intrinsic Mixed-Variant Fallback Matrix Expansion

- Status: complete
- Scope completed:
  - added explicit regression fixtures for mixed canonical variant staged-hook cases:
    - `write` with non-unit `alloca` count + dead const
    - `free` with nonzero/multi-digit ids + multi-dead-const injection
    - `trace` with nonzero/multi-digit ids + multi-dead-const injection
  - added deterministic build assertions proving these mixed staged-hook cases remain intentionally unlowered (`kernel_kind 0`, `code_size 1`)
  - validated with full-suite pass

### M24: Staged Intrinsic Write-Guardrail Fallback Closure

- Status: complete
- Scope completed:
  - added explicit regression fixture for dead-const-injected write guardrail shape with `alloca 0`
  - added deterministic build assertion proving this staged-hook guardrail case remains intentionally unlowered (`kernel_kind 0`, `code_size 1`)
  - validated with full-suite pass

### M25: Staged Intrinsic Stress Fallback Matrix Expansion

- Status: complete
- Scope completed:
  - added explicit regression fixtures for higher-stress staged-hook combinations:
    - `write` with `alloca 0` + nonzero/multi-digit ids + multi-dead-const injection
    - `free` with nonzero/multi-digit ids + deeper dead-const stack
    - `trace` with nonzero/multi-digit ids + deeper dead-const stack
  - added deterministic build assertions proving these stress staged-hook cases remain intentionally unlowered (`kernel_kind 0`, `code_size 1`)
  - validated with full-suite pass

### M26: Staged Intrinsic Cross-Function Fallback Matrix Expansion

- Status: complete
- Scope completed:
  - added explicit regression fixtures for cross-function mixed staged-hook fallback cases:
    - `write` with `alloca 0` + nonzero/multi-digit ids + multi-dead-const injection in `f0` plus id reuse in `f1`
    - `free` with nonzero/multi-digit ids + deeper dead-const stack in `f0` plus id reuse in `f1`
    - `trace` with nonzero/multi-digit ids + deeper dead-const stack in `f0` plus id reuse in `f1`
  - added deterministic build assertions proving these cross-function staged-hook cases remain intentionally unlowered (`kernel_kind 0`, `code_size 1`)
  - validated with full-suite pass

### M27: Const-Dependent Intrinsic Dead-Const Lowering Closure

- Status: complete
- Scope completed:
  - fixed dead-const normalization value-id matching (`lhs` id-length extraction) so live const lines are preserved and only dead canonical const defs are stripped
  - moved const-dependent intrinsic generalized lowering from deterministic staged fallback to lowered closure for valid canonical dead-const-injected shapes:
    - `write`
    - `free`
    - `trace`
  - validated lowered closure across nonzero-id, multi-dead-const, and cross-function value-id-reuse variants
  - preserved intentional write guardrail fallback behavior for `alloca ... , 0` variants (`kernel_kind 0`, `code_size 1`)
  - validated with full-suite pass

### M28: Generalized Intrinsic-Selector Pipeline Cutoff

- Status: complete
- Scope completed:
  - removed legacy direct selector fallback stages for const-dependent intrinsic families in `build`:
    - `trace`
    - `write`
    - `free`
  - kept these families routed through generalized normalization+selector paths only
  - validated deterministic behavior and full regression-suite stability under the generalized-only routing

### M29: Generalized Selector-Chain Unification

- Status: complete
- Scope completed:
  - removed remaining legacy direct selector fallback stages in `build` for generalized families:
    - `exit`
    - `malloc`
    - `call`
    - memory roundtrip families (`mem_roundtrip`, `mem_gep_roundtrip`)
    - compare/select (`icmp.eq`, `icmp.eq + cbr`)
    - binary ops
  - kept these families routed through generalized normalization+selector paths only
  - preserved fallback behavior for unsupported verified modules through the existing single-byte `ret` stub path
  - validated deterministic behavior and full regression-suite stability under the generalized-only routing

### M30: Generalized Selector-Chain Completion (Const-Return Path)

- Status: complete
- Scope completed:
  - added generalized pre-lowering normalization routing for const-return kernel selection in `build`
  - removed the remaining direct const-return selection stage from the `build` chain
  - added regression coverage for const-return dead-const-injected shapes, including cross-function value-id reuse variants
  - validated deterministic behavior and full regression-suite stability under generalized-only routing for all current kernel families

### M31: Call-Family Backend Expansion (`and`)

- Status: complete
- Scope completed:
  - extended two-function call-kernel lowering to include canonical `and` target in `f1`
  - added commutative swapped call-arg lowering support for call->`and` in `f0`
  - validated generalized dead-const normalization path for call->`and` with dead consts in both `f0` and `f1`
  - added regression fixtures and assertions for:
    - canonical call->`and` lowered shape
    - swapped call-arg call->`and` lowered shape
    - dead-const-injected call->`and` generalized lowered shape
  - validated with full-suite pass

### M32: Call-Family Backend Expansion (`or`)

- Status: complete
- Scope completed:
  - extended two-function call-kernel lowering to include canonical `or` target in `f1`
  - added commutative swapped call-arg lowering support for call->`or` in `f0`
  - validated generalized dead-const normalization path for call->`or` with dead consts in both `f0` and `f1`
  - added regression fixtures and assertions for:
    - canonical call->`or` lowered shape
    - swapped call-arg call->`or` lowered shape
    - dead-const-injected call->`or` generalized lowered shape
  - validated with full-suite pass

### M33: Call-Family Backend Expansion (`xor`)

- Status: complete
- Scope completed:
  - extended two-function call-kernel lowering to include canonical `xor` target in `f1`
  - added commutative swapped call-arg lowering support for call->`xor` in `f0`
  - validated generalized dead-const normalization path for call->`xor` with dead consts in both `f0` and `f1`
  - added regression fixtures and assertions for:
    - canonical call->`xor` lowered shape
    - swapped call-arg call->`xor` lowered shape
    - dead-const-injected call->`xor` generalized lowered shape
  - validated with full-suite pass

### M34: Call-Family Backend Expansion (`shl`/`shr`)

- Status: complete
- Scope completed:
  - extended two-function call-kernel lowering to include canonical `shl` and `shr` targets in `f1`
  - preserved non-commutative call semantics by lowering only semantic arg0->arg1 mappings under parsed `f0`/`f1` arg-definition order
  - validated generalized dead-const normalization path for call->`shl`/`shr` with dead consts in both `f0` and `f1`
  - kept swapped call-arg non-commutative guardrails intentionally unlowered (`kernel_kind 0`, `code_size 1`)
  - added regression fixtures and assertions for:
    - canonical call->`shl` lowered shape
    - canonical call->`shr` lowered shape
    - dead-const-injected call->`shl` generalized lowered shape
    - dead-const-injected call->`shr` generalized lowered shape
    - swapped call-arg call->`shl` intentional unlowered guardrail shape
    - swapped call-arg call->`shr` intentional unlowered guardrail shape
  - validated with full-suite pass

### M35: Multi-Block Backend Kickoff (Branch-Identity Lowering)

- Status: complete
- Scope completed:
  - added a generalized normalized selector path for canonical multi-block branch-identity modules:
    - `fn f0 (t0)->t0` with `cbr vN b1 b2` in `b0`
    - both `b1` and `b2` returning the same `vN`
  - added direct lowering for that shape to a deterministic `arg0 -> ret` machine payload (no fallback stub)
  - integrated the new selector into the generalized build selector chain
  - extended kernel-kind range handling to include the new lowered branch-identity kernel kind (`25`) in image validation and metadata decode paths
  - updated debug-map kernel-kind routing so existing trace kernel map layouts remain stable while the new branch-identity kernel gets deterministic debug-map emission
  - updated regression assertions so `valid_branch.l0` now verifies lowered code bytes and runtime behavior instead of fallback stub behavior
  - validated with full-suite pass

### M36: Non-Commutative Call Generalization (`sub.wrap` reverse mapping)

- Status: complete
- Scope completed:
  - added deterministic reverse-mapping lowering path for `call->sub.wrap` in two-function call selector flow
  - lowerings now include a canonical reverse-mapping shape where:
    - parsed `f0` call-arg mapping is semantic arg1->arg0
    - parsed `f1` `sub.wrap` mapping remains canonical
  - kept kernel kind stable for call->`sub.wrap` (`17`) while emitting a dedicated reverse machine payload
  - preserved existing unlowered guardrails for other non-matching non-commutative call shapes (including swapped-operand `f1` sub variants)
  - updated regression assertions:
    - `valid_call_sub_argdef_order_swapped_unlowered.l0` now lowers and executes with deterministic reverse-sub behavior
    - existing `f1` swapped `sub.wrap` variants remain intentionally unlowered
  - validated with full-suite pass

### M37: Compare/Select Branch-Mapping Generalization

- Status: complete
- Scope completed:
  - extended `icmp.eq + cbr` selector lowering to support deterministic reverse branch-return mapping:
    - `b1` returns arg1
    - `b2` returns arg0
  - added dedicated reversed machine payload for compare/select while keeping kernel kind stable (`12`)
  - wired reverse mapping through generalized normalization flow, so dead-const-injected reverse variants now lower when otherwise canonical
  - updated regression assertions for previously intentional unlowered reverse mapping fixtures:
    - arg-id reverse mapping shape now lowers and executes deterministically
    - argdef-order-swapped reverse mapping shape now lowers and executes deterministically
    - dead-const-injected reverse mapping shape now lowers and executes deterministically
  - preserved existing intentional unlowered behavior for non-canonical mismatch shapes (for example extra compare/dataflow divergence cases)
  - validated with full-suite pass

### M38: Non-Commutative Call Generalization (`sub.wrap` f1 reverse mapping)

- Status: complete
- Scope completed:
  - extended `call->sub.wrap` selector lowering to support deterministic reverse `f1` mapping variants under canonical call structure
  - added lowered coverage for previously intentional unlowered `f1` reverse-mapping fixtures:
    - `valid_call_sub_f1_argdef_order_swapped_unlowered.l0`
    - `valid_call_sub_f1_swapped_unlowered.l0`
    - `valid_call_sub_f1_swapped_with_dead_const_unlowered.l0`
  - updated regression assertions for those fixtures from fallback checks (`kernel_kind 0`, `code_size 1`) to lowered behavior checks (`kernel_kind 17` + deterministic runtime outputs)
  - preserved existing structural mismatch guardrails for unrelated call shapes (for example call-result/id mismatches and non-canonical mismatches)
  - validated with full-suite pass

### M39: Non-Commutative Binary Generalization (`sub.wrap` swapped forms)

- Status: complete
- Scope completed:
  - extended direct binary selector lowering for `sub.wrap` to accept canonical swapped operand order (`v1 v0`)
  - routed swapped `sub.wrap` binary forms to reverse-sub machine payload while keeping kernel kind stable (`3`)
  - preserved existing non-commutative guardrail for `sub.trap` swapped forms (still intentionally unlowered)
  - updated regression assertions for previously intentional unlowered swapped `sub.wrap` fixtures:
    - `valid_sub_swapped_unlowered.l0`
    - `valid_sub_argids_v7_v9_swapped_unlowered.l0`
    - `valid_sub_argdef_order_swapped_unlowered.l0`
    - `valid_sub_with_dead_const_swapped_unlowered.l0`
  - converted those assertions from fallback checks (`kernel_kind 0`, `code_size 1`) to lowered checks (`kernel_kind 3` + deterministic runtime output)
  - validated with full-suite pass

### M40: Non-Commutative Shift-Call Generalization (`shl`/`shr` reverse mapping)

- Status: complete
- Scope completed:
  - extended `call->shl` selector lowering to support canonical swapped call-arg mapping (`call f1 v1 v0`) under canonical call structure
  - extended `call->shr` selector lowering to support canonical swapped call-arg mapping (`call f1 v1 v0`) under canonical call structure
  - added dedicated reverse machine payload routing for non-commutative shift semantics while keeping kernel kinds stable (`8` for `shl`, `9` for `shr`)
  - updated regression assertions for previously intentional unlowered fixtures:
    - `valid_call_shl_swapped_unlowered.l0`
    - `valid_call_shr_swapped_unlowered.l0`
  - converted those assertions from fallback checks (`kernel_kind 0`, `code_size 1`) to lowered checks (`kernel_kind 8/9` + deterministic runtime output)
  - preserved existing structural mismatch guardrails for unrelated call shapes
  - validated with full-suite pass

### M41: Non-Returning Exit Generalization

- Status: complete
- Scope completed:
  - relaxed `exit` selector matching to treat `exit` as non-returning in bootstrap runtime lowering
  - once canonical arg-to-exit value-id mapping is matched, selector now lowers without requiring a matching trailing `ret` value-id path
  - added lowered coverage for previously intentional unlowered fixtures:
    - `valid_exit_mismatch_unlowered.l0`
    - `valid_exit_mismatch_with_dead_const_unlowered.l0`
  - converted those assertions from fallback checks (`kernel_kind 0`, `code_size 1`) to lowered checks (`kernel_kind 23`) plus deterministic exit-status runtime checks
  - preserved existing mismatch guardrails for unrelated intrinsic families
  - validated with full-suite pass

### M42: Dead-Compare Normalization (Compare/Select Generalization)

- Status: complete
- Scope completed:
  - extended shared generalized normalization to strip dead canonical `icmp.eq` value lines (in addition to dead `const` value lines)
  - enabled lowering for compare/select modules that include extra unused compare defs
  - updated regression assertions for previously intentional unlowered fixture:
    - `valid_cbr_eq_select_mismatch_unlowered.l0`
  - converted that assertion from fallback checks (`kernel_kind 0`, `code_size 1`) to lowered checks (`kernel_kind 12`) plus deterministic true/false runtime outputs
  - preserved existing compare/select guardrails for branch-return/dataflow mismatch families
  - validated with full-suite pass

### M43: Memory Arg-Return Generalization

- Status: complete
- Scope completed:
  - extended `mem_roundtrip` selector lowering to accept canonical arg-return form (`ret vArg`) when `st vAlloca vArg` is present
  - extended `mem_gep_roundtrip` selector lowering to accept canonical arg-return form (`ret vArg`) when `st vAlloca vArg` is present
  - preserved existing kernel kinds (`14` for memory roundtrip, `19` for memory-gep roundtrip)
  - updated regression assertions for previously intentional unlowered fixtures:
    - `valid_mem_roundtrip_arg_alloca_order_swapped_unlowered.l0`
    - `valid_mem_gep_roundtrip_arg_alloca_order_swapped_unlowered.l0`
  - converted those assertions from fallback checks (`kernel_kind 0`, `code_size 1`) to lowered checks (`kernel_kind 14/19`) plus deterministic runtime output checks
  - validated with full-suite pass

### M44: Compare/Select Multi-Block Tolerant Normalization

- Status: complete
- Scope completed:
  - expanded compare/select normalization coverage so canonical `icmp.eq + cbr` modules still lower when one extra dead pure value line (`icmp.eq` or `const`) appears in `b0`, `b1`, or `b2`
  - kept lowered compare/select kernel identity stable (`kernel_kind 12`)
  - added regression fixtures and assertions:
    - `valid_cbr_eq_select_dead_line_b0_general_lowered.l0`
    - `valid_cbr_eq_select_dead_lines_b1_b2_general_lowered.l0`
    - `valid_cbr_eq_select_dead_lines_guardrail_fallback.l0`
  - asserted deterministic lowered behavior (kernel kind and true/false runtime outputs) for the two lowered fixtures
  - asserted deterministic fallback behavior (`kernel_kind 0`, `code_size 1`) for the unsupported branch-return guardrail fixture
  - validated with full-suite pass

### M45: Call-Kernel Dead Pure-Line Tolerance

- Status: complete
- Scope completed:
  - confirmed generalized call-path normalization tolerates dead pure `icmp.eq` value lines in both function bodies:
    - `f0` around `call f1 ...`
    - `f1` around the lowered op result line
  - preserved existing call-family lowered kernel kinds (`16` add, `17` sub) and existing non-commutative guardrails
  - added regression fixtures and assertions:
    - `valid_call_add_dead_icmp_f0_lowered.l0`
    - `valid_call_add_dead_icmp_f1_lowered.l0`
    - `valid_call_sub_dead_icmp_supported_lowered.l0`
    - `valid_call_add_dead_icmp_guardrail_fallback.l0`
  - asserted deterministic lowered behavior (kernel kind and runtime outputs) for the three lowered fixtures
  - asserted deterministic fallback behavior (`kernel_kind 0`, `code_size 1`) for the unsupported guardrail fixture
  - validated with full-suite pass

### M46: Intrinsic Path Tolerant Normalization

- Status: complete
- Scope completed:
  - validated intrinsic-path dead pure-line tolerance using dead `icmp.eq` injections across:
    - `malloc`
    - `free`
    - `write`
    - `trace`
    - `exit`
  - preserved intrinsic kernel-kind stability for lowered cases (`20`, `21`, `22`, `23`, `24`)
  - preserved strict write guardrail fallback for `alloca 0` with dead `icmp.eq` injection
  - added regression fixtures and assertions:
    - `valid_malloc_with_dead_icmp_general_lowered.l0`
    - `valid_free_noop_with_dead_icmp_general_lowered.l0`
    - `valid_write_newline_with_dead_icmp_general_lowered.l0`
    - `valid_trace_noop_with_dead_icmp_general_lowered.l0`
    - `valid_exit_with_dead_icmp_general_lowered.l0`
    - `valid_write_newline_alloca0_with_dead_icmp_guardrail_fallback.l0`
  - asserted deterministic lowered behavior (kernel kind plus runtime behavior) for the 5 lowered fixtures
  - asserted deterministic fallback behavior (`kernel_kind 0`, `code_size 1`) for the guardrail fixture
  - validated with full-suite pass

### M47: Intrinsic Dead-Pure Stress Matrix Expansion

- Status: complete
- Scope completed:
  - expanded intrinsic dead-pure coverage to multi-dead-pure (`const` + `icmp.eq`) variants for:
    - `malloc`
    - `free`
    - `write`
    - `trace`
    - `exit`
  - added cross-function dead-icmp id-reuse variants for:
    - `free`
    - `trace`
  - preserved write `alloca 0` fallback guardrails under cross-function multi-dead-pure variant
  - added regression fixtures and assertions:
    - `valid_malloc_with_multi_dead_pure_general_lowered.l0`
    - `valid_free_noop_with_multi_dead_pure_general_lowered.l0`
    - `valid_write_newline_with_multi_dead_pure_general_lowered.l0`
    - `valid_trace_noop_with_multi_dead_pure_general_lowered.l0`
    - `valid_exit_with_multi_dead_pure_general_lowered.l0`
    - `valid_free_noop_with_dead_icmp_crossfn_general_lowered.l0`
    - `valid_trace_noop_with_dead_icmp_crossfn_general_lowered.l0`
    - `valid_write_newline_alloca0_with_multi_dead_pure_crossfn_guardrail_fallback.l0`
  - asserted deterministic lowered behavior (kernel kind plus runtime outputs/status) for lowered fixtures
  - asserted deterministic fallback behavior (`kernel_kind 0`, `code_size 1`) for cross-function write guardrail fixture
  - validated with full-suite pass

### M48: Intrinsic Debug/Trace Stress Coverage

- Status: complete
- Scope completed:
  - added debug-map and tracejoin stress coverage for intrinsic dead-pure/cross-function fixtures
  - asserted stable debug-map entry layouts for 3 intrinsic families under multi-dead-pure variants:
    - `malloc`
    - `write`
    - `trace`
  - added tracejoin decode assertions for cross-function trace fixture outputs (`id 1`, `val 123`, `start 0`, `end 17`)
  - added tamper-rejection tests on emitted cross-function trace artifacts:
    - truncated debug-map payload
    - bad debug-map entry count header
    - unknown trace id in emitted trace payload
    - non-monotonic debug-map range mutation
  - validated with full-suite pass

### M49: Call/Compare Debug-Trace Coverage Expansion

- Status: complete
- Scope completed:
  - extended debug-map layout lock assertions to dead-pure call and compare/select fixture families
  - added map-layout assertions for:
    - call dead-icmp fixture (`valid_call_add_dead_icmp_f0_lowered.l0`)
    - compare dead-const fixture (`valid_icmp_eq_with_dead_const_general_lowered.l0`)
    - compare/select dead-line fixture (`valid_cbr_eq_select_dead_line_b0_general_lowered.l0`)
  - added tracejoin decode assertions using those emitted map artifacts and deterministic synthetic trace records
  - added tamper-rejection checks on those family artifacts:
    - call-map bad entry-count mutation rejected (`mapcat`)
    - compare-map truncated payload rejected (`tracejoin`)
    - compare/select-map non-monotonic range mutation rejected (`tracejoin`)
    - compare/select unknown trace-id payload rejected (`tracejoin`)
  - validated with full-suite pass

### M50: Documentation Consolidation

- Status: complete
- Scope completed:
  - added a canonical writing guide: `docs/HOW_TO_WRITE_L0.md`
  - linked the writing guide to language/spec details:
    - `docs/LANGUAGE.md`
    - `docs/SPEC.md`
    - `docs/IMPLEMENTABLE_SPEC.md`
  - added 11 runnable documentation examples under `docs/examples`:
    - arithmetic: `01_arithmetic_add_wrap.l0`
    - compare: `02_compare_icmp_eq.l0`
    - control flow: `03_control_cbr_select.l0`
    - memory: `04_memory_roundtrip.l0`, `05_memory_gep_roundtrip.l0`
    - call kernel: `06_call_add_two_function.l0`
    - intrinsics: `07_intrinsic_malloc.l0`, `08_intrinsic_free.l0`, `09_intrinsic_write.l0`, `10_intrinsic_trace.l0`, `11_intrinsic_exit.l0`
  - added dedicated debug/tracing workflow commands in the guide:
    - `build --debug-map --trace-schema`
    - `mapcat`, `schemacat`, `tracecat`, `tracejoin`
  - added an explicit LLM output checklist in the guide (canonical order, ids, terminators, use-before-def, verifier pass)
  - wired docs-example verification into `tests/run.sh` so `make test` verifies every `docs/examples/*.l0` file
  - validated with full-suite pass

### M51: Docs-Driven Execution Walkthroughs

- Status: complete
- Scope completed:
  - added a dedicated workflows reference: `docs/WORKFLOWS.md`
  - documented 3 deterministic end-to-end workflows from `docs/examples`:
    - arithmetic: `verify -> build -> imgcheck/imgmeta -> run`
    - control-flow: `verify -> build -> imgcheck/imgmeta -> run` with both branch inputs
    - debug/trace: `build --debug-map --trace-schema -> schemacat/mapcat -> run -> tracecat/tracejoin`
  - added scripted assertions in `tests/run.sh` for those 3 workflows:
    - deterministic `imgmeta` kernel-kind/code-size checks
    - deterministic runtime return value checks
    - deterministic `schemacat`, `mapcat`, `tracecat`, and `tracejoin` output checks
  - validated with full-suite pass

## Production Roadmap (Planned)

### M52: Canonical Parser Hardening

- Status: complete
- Scope completed:
  - expanded malformed-token and malformed-line negative corpus with dedicated parser fixtures:
    - `invalid_parser_bad_ver_token.l0`
    - `invalid_parser_types_missing_close_brace.l0`
    - `invalid_parser_fn_missing_lbrace.l0`
    - `invalid_parser_block_label_space.l0`
    - `invalid_parser_value_missing_equals.l0`
    - `invalid_parser_ret_extra_operand.l0`
    - `invalid_parser_bad_id_prefix.l0`
    - `invalid_parser_cbr_missing_false_target.l0`
    - `invalid_parser_garbage_tail.l0`
    - `invalid_parser_section_keyword_case.l0`
    - `invalid_parser_fn_trailing_comma_arg.l0`
    - `invalid_parser_value_missing_colon_type.l0`
  - added parser-focused fuzz seed corpus in `tests/fuzz/parser_seeds` with both valid and invalid seed shapes
  - added deterministic parser fuzz regression and crash-repro harness:
    - `tests/parser_fuzz_regress.sh`
    - supports corpus run mode and `--repro <input.l0>` single-case repro mode
  - wired parser fuzz regression into `tests/run.sh` so `make test` enforces crash-free parser regression by default
  - added parser-invalid fixture sweep in `tests/run.sh` for all `invalid_parser_*.l0` fixtures
  - validated with full-suite pass

### M53: Verifier Completeness Closure

- Status: complete
- Scope completed:
  - closed verifier coverage gaps by introducing an explicit verifier rule matrix:
    - `tests/verifier_matrix.tsv`
  - added deterministic automated matrix runner:
    - `tests/verifier_matrix.sh`
  - enforced the verifier matrix in `make test` by wiring it into:
    - `tests/run.sh`
  - added first-person verifier rule-to-test mapping documentation:
    - `docs/VERIFIER_RULE_MAP.md`
  - locked one positive and one negative fixture for each mapped verifier rule in the matrix
  - validated with full-suite pass

### M54: Type-System Expansion and Closure

- Status: complete
- Scope completed:
  - extended bootstrap type-token verifier support to include canonical forms:
    - struct: `s{tA,tB,...}`
    - fixed array: `aN<tA>` with `N > 0`
    - function type: `fn(tA,...)->tR`
  - added strict type-token edge validation:
    - canonical delimiter handling for nested type tokens in the `types` section
    - `tN` reference validation in struct/array/function type tokens
    - rejection of malformed/trailing-comma/missing-arrow/unknown-ref type-token shapes
  - added deterministic positive type-form fixtures:
    - `valid_types_struct_sig.l0`
    - `valid_types_array_sig.l0`
    - `valid_types_fn_sig.l0`
  - added deterministic negative edge-case fixtures:
    - `invalid_types_struct_unknown_ref.l0`
    - `invalid_types_struct_trailing_comma.l0`
    - `invalid_types_struct_empty.l0`
    - `invalid_types_array_zero_len.l0`
    - `invalid_types_array_bad_elem_token.l0`
    - `invalid_types_fn_unknown_ref.l0`
    - `invalid_types_fn_bad_return_token.l0`
    - `invalid_types_fn_trailing_comma.l0`
    - `invalid_types_fn_missing_arrow.l0`
  - added deterministic canonical docs examples for each new supported type form:
    - `docs/examples/12_types_struct_sig.l0`
    - `docs/examples/13_types_array_sig.l0`
    - `docs/examples/14_types_fn_sig.l0`
  - integrated all new fixtures into default automation:
    - verify/canon assertions in `tests/run.sh`
    - verifier matrix coverage in `tests/verifier_matrix.tsv`
  - updated type-system documentation in:
    - `docs/LANGUAGE.md`
    - `docs/HOW_TO_WRITE_L0.md`
    - `docs/VERIFIER_RULE_MAP.md`
  - validated with full-suite pass

### M55: General CFG Lowering v1

- Status: planned
- Planned (measurable):
  - implement lowering path for non-template multi-block function shapes
  - preserve deterministic fallback behavior for unsupported patterns
  - acceptance: new non-template CFG fixtures lower and run correctly with deterministic metadata

### M56: SSA Join and Merge Lowering

- Status: planned
- Planned (measurable):
  - add deterministic lowering support for merge-point value selection in multi-branch control-flow
  - add regression fixtures for branch merge/join value correctness
  - acceptance: merge fixtures pass runtime correctness checks and remain deterministic in emitted artifacts

### M57: Register Allocation Generalization

- Status: planned
- Planned (measurable):
  - extend allocator behavior for broader live-range/spill patterns in generalized lowering
  - add spill/reload stress fixtures with deterministic runtime checks
  - acceptance: stress fixtures pass and preserve deterministic image/debug metadata stability

### M58: SysV AMD64 ABI Completeness

- Status: planned
- Planned (measurable):
  - complete SysV ABI lowering/validation coverage for supported L0 call shapes
  - add ABI-focused fixture matrix and runtime checks
  - acceptance: ABI matrix passes under `make test` on Linux x86-64

### M59: Object Output Path (ELF) v1

- Status: planned
- Planned (measurable):
  - add ELF object emission path alongside current image output path
  - add deterministic object metadata checks
  - acceptance: ELF fixtures link and run in scripted checks with deterministic outputs

### M60: Runtime Intrinsic Contract Freeze v1

- Status: planned
- Planned (measurable):
  - freeze semantics and contracts for `malloc`, `free`, `write`, `exit`, `trace`
  - document versioned intrinsic behavior and negative-path guarantees
  - acceptance: intrinsic contract tests pass and docs/spec are aligned

### M61: Debug-Map Schema Freeze v1

- Status: planned
- Planned (measurable):
  - freeze debug-map format and compatibility constraints
  - add compatibility fixtures for schema-stability checks
  - acceptance: schema fixtures decode identically and tamper checks remain strict

### M62: Trace Schema Freeze v1

- Status: planned
- Planned (measurable):
  - freeze trace record schema and decode rules
  - add compatibility fixture corpus for trace tooling
  - acceptance: `schemacat`, `tracecat`, `tracejoin` pass compatibility and tamper suites

### M63: Deterministic Build Guarantees

- Status: planned
- Planned (measurable):
  - add repeat-build determinism checks for emitted images and side artifacts
  - lock byte-for-byte reproducibility for selected fixture corpus
  - acceptance: deterministic build checks pass in default `make test`

### M64: Differential Semantic Testing

- Status: planned
- Planned (measurable):
  - add semantic differential harness for supported op families
  - run generated fixture comparisons for runtime result equivalence
  - acceptance: differential corpus passes with no semantic mismatches

### M65: Fuzzing and Malformed-Input Stress

- Status: planned
- Planned (measurable):
  - expand parser/verifier/image/trace fuzz harness and corpus
  - convert discovered failures into locked regression fixtures
  - acceptance: fuzz regression suite is stable and crash-free across fixed budget runs

### M66: Performance Baseline and Regression Gates

- Status: planned
- Planned (measurable):
  - establish baseline metrics for build throughput and runtime micro-kernels
  - add regression thresholds and checks in automated suite
  - acceptance: performance checks pass within pinned thresholds

### M67: Error Model Stabilization

- Status: planned
- Planned (measurable):
  - normalize deterministic error categories/messages across CLI commands
  - add assertion coverage for representative failure classes
  - acceptance: error-behavior fixtures pass with stable output contracts

### M68: Packaging and Release Pipeline

- Status: planned
- Planned (measurable):
  - add reproducible release build steps and artifact checksums
  - document release procedure and versioning policy
  - acceptance: scripted release candidate build succeeds end-to-end

### M69: Compatibility and Upgrade Policy

- Status: planned
- Planned (measurable):
  - define source/image/tool compatibility guarantees across versions
  - add compatibility test slices spanning prior release fixtures
  - acceptance: compatibility matrix passes and policy docs are published

### M70: Production Readiness Gate

- Status: planned
- Planned (measurable):
  - run final quality gate across correctness, determinism, tooling, docs, and release process
  - freeze v1 schemas/contracts and cut production candidate tag
  - acceptance: all milestone gates M52-M69 are complete and release candidate passes full suite

## Documentation status

- I keep these docs current in first-person voice:
  - `docs/LANGUAGE.md`
  - `docs/SPEC.md`
  - `docs/IMPLEMENTABLE_SPEC.md`
  - `docs/PLAN.md`
- I use this file (`docs/STATUS.md`) as the quick project-progress dashboard.
