# L0 Native-Only Bootstrap Plan (Pure x86-64 Assembly, No High-Level Dependencies)

## Summary
You want maximum control, determinism, and machine-level purity.
A simpler path would be C17 + asm stubs, but you explicitly rejected simplification, so this plan uses pure x86-64 assembly for compiler, runtime, and tools, with only host binutils (`as`, `ld`, `objcopy`) as build tools.

This plan is decision-complete and targets Linux x86-64 first.

## Locked Decisions
1. Implementation language: pure x86-64 assembly.
2. Toolchain dependency: GNU binutils only (`as`, `ld`, `objcopy`, `objdump`, `readelf`, `make`).
3. Runtime dependency: none (direct Linux syscalls; no libc).
4. Primary output: flat binary image (`.l0img`) plus minimal native loader.
5. IR model: L0 source is the IR (typed SSA, canonical-only accepted).
6. UB policy: defined semantics only in MVP; unsafe deferred.

## Public Interfaces / Types (to be stable in M1)
1. CLI:
- `l0c canon <in.l0> -o <out.l0>`
- `l0c verify <in.l0>`
- `l0c build <in.l0> -o <out.l0img> [--debug-map <out.map>] [--trace-schema <out.bin>]`
- `l0run <out.l0img> [args...]`

2. File formats:
- L0 source canonical text format (fixed section order).
- L0IMG flat binary container:
  - header (`magic`, version, entry fn id, section offsets/sizes)
  - code section
  - rodata section
  - debug map section (optional)
  - semantic index section (optional)
- trace binary records (fixed-width header + payload tuples).

3. Core schemas:
- Instruction ID: `(f_id, b_id, i_idx)` packed to 64-bit.
- Debug map entry: `inst_id -> [code_start, code_end)`.
- Semantic index entry sets: function signatures, CFG counts, call edges, op histogram.

## Implementation Plan

### Phase 0: Spec Freeze (authoritative docs first)
1. Write `SPEC.md` containing:
- token-level grammar
- full type rules
- instruction semantics including overflow (`*.wrap`, `*.trap` in MVP)
- verifier rules
- x86-64 lowering rules
- `L0IMG` binary format
- debug/trace schemas
2. Add `CANON.md` with exact canonicalization rules and rejection behavior.
3. Add `ABI_SYSV_AMD64.md` for concrete call lowering.

Acceptance:
- Example programs in spec parse unambiguously.
- Canon examples have one valid output only.

### Phase 1: Native Compiler Skeleton (asm)
1. Build executable `l0c` in asm:
- command dispatcher
- file I/O via syscalls
- memory arena allocator (bump)
- error reporter with stable codes
2. Internal in-memory model:
- symbol tables keyed by numeric IDs (`tN/kN/gN/fN/bN/vN`)
- section descriptors
- per-function block and instruction arrays

Acceptance:
- `l0c` loads file, prints structured diagnostics, exits with deterministic codes.

### Phase 2: Lexer + Parser + Canonical Printer
1. Deterministic lexer:
- fixed token classes, numeric parsers, punctuation, keywords/opcodes
2. Recursive-descent parser for fixed section order.
3. Canonical printer:
- exact whitespace, ordering, and normalized empty sections.
4. Policy:
- non-canonical input fails by default with expected canonical diff code.
- optional future `--fix` can be added later.

Acceptance:
- golden tests: input -> canonical output exact byte match.
- malformed token/grammar tests produce stable error IDs.

### Phase 3: Verifier
1. Type checker:
- arg types, op signatures, pointer op constraints.
2. SSA checker:
- single def per `vN`, dominance of defs over uses, block terminator completeness.
3. CFG checker:
- target block existence, entry block constraints, unreachable policy (warn in M1).
4. Call checker:
- external/internal signature compatibility.

Acceptance:
- reject corpus for each rule class.
- verifier returns zero on valid corpus and non-zero with rule-specific codes on invalid corpus.

### Phase 4: Codegen + Reg Allocation + Flat Image
1. Lowering:
- arithmetic/logical ops, compare/branch, calls, returns, stack allocas, ld/st/gep.
2. Linear scan allocator:
- GPR set: `rax, rbx, rcx, rdx, rsi, rdi, r8-r15` with spill slots.
3. Prologue/epilogue and stack alignment (SysV).
4. Runtime intrinsics:
- `write`, `exit` via syscalls.
- `malloc/free`: internal bump allocator region in runtime (free is no-op in M1; documented).
5. Emit `L0IMG` and entry metadata.

Acceptance:
- compiles arithmetic + branch + call + memory samples.
- generated programs execute through `l0run` and produce expected output.

### Phase 5: Native Loader (`l0run`)
1. Load `L0IMG`, map sections, relocate internal references.
2. Set up stack/entry and transfer control.
3. Return process exit status from program `exit`.

Acceptance:
- roundtrip `l0c build` + `l0run` works for all M1 sample programs.

### Phase 6: Debug / Trace / Semantic Index
1. Stable instruction IDs assigned during canonical parse.
2. Emit debug map section.
3. Implement `trace` intrinsic lowering:
- debug build keeps events
- release build strips events
4. Emit semantic index section.

Acceptance:
- trace decoder tool reads records and maps to inst IDs.
- failing sample can be narrowed to function/block/instruction using index+trace.

## Test Cases and Scenarios

1. Parser/canonical:
- valid canonical module
- same module non-canonical spacing/order -> reject
- missing section/invalid ID/duplicate ID

2. Verifier:
- bad SSA (use before def, duplicate def)
- wrong types on arithmetic/call/load/store
- missing terminator and invalid branch targets

3. Codegen correctness:
- integer ops (`add/sub/mul/and/or/xor/shl/shr`)
- `icmp + cbr` control flow
- nested calls with 0..6 args
- stack locals via `alloca`
- pointer math with `gep`

4. Runtime/intrinsics:
- `write` output exact bytes
- `exit` status propagation
- `malloc` monotonic allocation and bounds trap test

5. Debugging artifacts:
- instruction ID stability across equivalent canonical source
- debug map ranges non-overlap and complete mapping for emitted instructions
- trace record parse and correlation to semantic index

## Assumptions and Defaults
1. Target platform for M1: Linux x86-64, SysV AMD64 ABI.
2. Endianness: little-endian only in M1.
3. Types in M1 implementation subset:
- `i32`, `i64`, `p0<i8>` fully enabled.
- broader type grammar accepted only if semantics implemented; otherwise verifier rejects with `NOT_IN_MVP`.
4. Overflow semantics in M1:
- `*.wrap` required.
- `*.trap` supported for checked mode where implemented.
- `*.sat` deferred to M2.
5. `free` in M1 is allocator no-op (documented behavior, defined semantics).
6. No external linker/loader dependency at runtime beyond Linux kernel syscalls.
