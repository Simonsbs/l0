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
  - cross-kernel debug-map layout assertions in regression tests (`add.trap`, `mul.trap`, `cbr`, `malloc`, `write`, `trace`)
  - expanded malformed-image tamper coverage for `imgcheck` (header size, source offset, code/debug pair consistency)
  - overflow-style image tamper checks for `imgcheck` (`code_off`/`debug_off` set to max u64 values)
  - negative-path tests for malformed artifacts
- Remaining:
  - broader malformed-image fuzz-style tests (randomized/automated generation)
  - broader multi-record trace corruption patterns beyond truncation/alignment checks

### M5: Full language/general codegen

- Status: not started (beyond bootstrap kernels)
- Planned:
  - lower general multi-block SSA modules (not only canonical kernel templates)
  - integrate a generalized instruction-selection and register allocation path
  - widen type/memory ABI coverage toward full MVP spec

## Documentation status

- I keep these docs current in first-person voice:
  - `docs/LANGUAGE.md`
  - `docs/SPEC.md`
  - `docs/IMPLEMENTABLE_SPEC.md`
  - `docs/PLAN.md`
- I use this file (`docs/STATUS.md`) as the quick project-progress dashboard.
