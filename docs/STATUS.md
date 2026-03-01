# L0 Project Status

I maintain this file as my current implementation status for the L0 bootstrap.

Last updated: 2026-03-01

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

- Status: in progress
- Scope completed:
  - duplicate optional flag rejection in `build`
  - debug-map entry bounds validation and clamping
  - ordered/non-overlapping map validation
  - strict `tracejoin` id resolution (unknown ids rejected)
  - explicit `tracejoin` rejection test for non-increasing debug-map `inst_id` ordering
  - explicit malformed debug-map payload-size tests: `mapcat` and `tracejoin` both reject misaligned/truncated map payloads
  - explicit debug-map header consistency tests: `mapcat` and `tracejoin` reject mismatched `entry_count` header vs payload size
  - explicit oversized debug-map entry-count tests: `mapcat` rejects oversized count payload artifacts and `tracejoin` rejects `entry_count > 64`
  - explicit malformed trace-schema tests: `schemacat` rejects bad schema version and truncated payload size
  - cross-kernel debug-map layout assertions in regression tests (`add.trap`, `mul.trap`, `cbr`, `malloc`, `write`, `trace`)
  - expanded malformed-image tamper coverage for `imgcheck` (header size, source offset, code/debug pair consistency)
  - overflow-style image tamper checks for `imgcheck` (`src_size`/`code_size`/`code_off`/`debug_off` set to max u64 values)
  - explicit `debug_size != 64` tamper rejection checks
  - `imgmeta` schema-hardening parity with `imgcheck` plus negative tamper tests
  - negative-path tests for malformed artifacts
- Remaining:
  - broader malformed-image fuzz-style tests (randomized/automated generation)
  - broader multi-record trace corruption patterns beyond truncation/alignment checks

### M5: Full language/general codegen

- Status: started (initial bootstrap selector broadening)
- Planned:
  - lower general multi-block SSA modules (not only canonical kernel templates)
  - integrate a generalized instruction-selection and register allocation path
  - widen type/memory ABI coverage toward full MVP spec
- Current incremental step completed:
  - commutative binary bootstrap selector now accepts canonical swapped operand order (`v1 v0`) for `add*`, `mul*`, `and`, `or`, `xor`
  - commutative call-lowering selector now accepts swapped call-arg order in `f0` for call->`add.wrap` and call->`mul.wrap`
  - compare/select bootstrap selector now accepts swapped `icmp.eq` operand order for both `icmp.eq` and `icmp.eq + cbr` kernel templates
  - const-return selector now accepts canonical nonzero value ids when `ret` references the same const-def id
  - const-return selector path is regression-covered for both single-digit and multi-digit value ids
  - non-commutative guardrail test added: swapped `sub.wrap` remains intentionally unlowered in current bootstrap selector
  - binary kernel selector now accepts canonical nonzero result value ids (`vN = <op> ...`, `ret vN`)
  - `icmp.eq` selector now accepts canonical nonzero compare-result ids (`vN = icmp.eq ...`, `ret vN`)
  - `icmp.eq + cbr` selector now accepts canonical nonzero compare-result ids (`vN = icmp.eq ...`, `cbr vN ...`)
  - guardrail added: `icmp.eq + cbr` path with mismatched compare-id/dataflow shape remains intentionally unlowered in bootstrap selector
  - call-kernel selector now accepts canonical nonzero call-result ids in `f0` (`vN = call ...`, `ret vN`)
  - call-kernel guardrail added: mismatch between call result id and returned id in `f0` remains intentionally unlowered
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

## Documentation status

- I keep these docs current in first-person voice:
  - `docs/LANGUAGE.md`
  - `docs/SPEC.md`
  - `docs/IMPLEMENTABLE_SPEC.md`
  - `docs/PLAN.md`
- I use this file (`docs/STATUS.md`) as the quick project-progress dashboard.
