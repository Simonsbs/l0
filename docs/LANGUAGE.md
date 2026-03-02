# L0 Language Reference (Bootstrap)

I maintain this document as the evolving language reference for **L0**.

Status: bootstrap phase. I describe the currently implemented and enforced subset in `l0c verify`, plus the intended direction.

## Design goals

- Low-level, typed SSA source representation
- Deterministic canonical text format
- Numeric identity (`tN`, `fN`, `bN`, `vN`, etc.)
- Defined semantics by default (no implicit UB contracts)

## Module layout

Section order is fixed and required:

1. `ver`
2. `types`
3. `consts`
4. `extern`
5. `globals`
6. `fns`

Bootstrap type-table requirement currently enforced:
- `types { }` is valid (empty table).
- non-empty `types` entries must use contiguous canonical ids: `t0`, `t1`, `t2`, ...
- bootstrap type RHS token set currently supports:
  - `i1`, `i8`, `i16`, `i32`, `i64`
  - `u8`, `u16`, `u32`, `u64`
  - `p0<i8>`
  - `s{tA,tB,...}` (struct with one-or-more `tN` fields)
  - `aN<tA>` (fixed array with `N > 0`)
  - `fn(tA,...)->tR` (function type with zero-or-more args and a `tN` return)
- for `s{}`, `aN<>`, and `fn()->`, referenced `tN` ids are validated and forward/self references are rejected in the bootstrap type-table parser.

Example skeleton:

```text
ver 1
types { }
consts { }
extern { }
globals { }
fns {
}
```

## Identifier classes

- Types: `t0`, `t1`, ...
- Constants: `k0`, `k1`, ...
- Globals: `g0`, `g1`, ...
- Functions: `f0`, `f1`, ...
- Blocks: `b0`, `b1`, ...
- SSA values: `v0`, `v1`, ...

## Function form

Canonical function header shape currently enforced:

```text
fn fN (arg_types)->tM {
```

Where:
- `arg_types` is either empty `()` or comma-separated `tN` values, e.g. `(t0,t1)`.
- return type is `tM`.
- each referenced `tN` must exist in the parsed module `types` table.

Function body requirements currently enforced:
- at least one block
- first block must be `b0:`
- `b0:` must be unique inside a function
- block labels use `bN:`
- every block label must be unique inside a function
- block labels must be contiguous in canonical order (`b0`, `b1`, `b2`, ...)
- instruction lines are indented with two spaces
- each block must terminate before next block or function close
- no instruction is allowed after a terminator within the same block

Function ordering requirement currently enforced:
- function ids must be contiguous in canonical order (`f0`, `f1`, `f2`, ...)
- `br` and `cbr` targets must reference blocks declared in the same function
- `cbr` condition value must be typed as `i1`

## Instructions

### Terminators (currently recognized)

- `ret`
- `ret vN`
- `br bN`
- `cbr vN bT bF`

### Value-producing form (currently enforced)

Non-terminators must follow canonical assignment form:

```text
vN = OP args... : tM
```

Current bootstrap checks enforce structural shape:
- `vN =`
- non-empty opcode token (restricted tokenizer subset)
- non-empty args payload
- explicit type suffix `: tM`
- value result type suffix `tM` must exist in the parsed module `types` table.

Current bootstrap opcode-aware checks:
- unknown opcodes are rejected in the current bootstrap subset
- `arg` requires a numeric index operand
- `arg` index must be within the function argument count
- `arg` result type must match the declared type of function argument index `N`
- `const` requires a decimal literal operand (`N` or `-N`)
- `call` requires args in canonical shape: `fN` followed by zero-or-more `vN` operands
- `call` target `fN` must reference a declared function in the module
- `call` result type suffix must match the declared return type of target `fN`
- `call` argument count must match the declared arity of target `fN`
- `icmp.eq` requires `vN vN` operands, an `i1` result type suffix, and matching operand value types
- `ld` requires `vN` operand shape and enforces `p0<i8>` pointer typing on the operand
- `gep` requires `vN <signed_decimal>` operand shape and enforces `p0<i8>` pointer typing on operand and result
- `alloca` requires `tN, N` operand shape and enforces `p0<i8>` result typing
- `malloc` requires `vN` operand shape, enforces non-pointer typing on `vN`, and enforces `p0<i8>` result typing
- `st` is accepted as a canonical non-value instruction (`st vPtr vVal`) with def-before-use and `p0<i8>` pointer typing checks on `vPtr`
- `free` is accepted as a canonical non-value instruction (`free vPtr`) with def-before-use and `p0<i8>` pointer typing checks on `vPtr`
- `exit` is accepted as a canonical non-value instruction (`exit vCode`) with def-before-use checks and non-pointer typing checks on `vCode`
- `write` is accepted as a canonical non-value instruction (`write vPtr vLen`) with def-before-use checks, `p0<i8>` pointer typing on `vPtr`, and non-pointer typing checks on `vLen`
- `trace` is accepted as a canonical non-value instruction (`trace N vA vB ...`) with decimal trace-id `N` and def-before-use checks on each traced value
- binary ops (`add.wrap`, `add.trap`, `sub.wrap`, `sub.trap`, `mul.wrap`, `mul.trap`, `and`, `or`, `xor`, `shl`, `shr`) require `vN vN` operands
- binary ops require both operand value types to match the explicit result type suffix

Current bootstrap SSA check:
- each SSA value id (`vN`) may be assigned once per function
- def-before-use is enforced for:
  - `ret vN` (with return-type compatibility check)
  - `cbr vN bT bF` condition value
  - `call fN vA vB ...` value operands (`vA`, `vB`, ...)
  - `ld`, `gep`, and `st` value operands
  - `malloc` and `free` value operands
  - `exit` value operands
  - `write` value operands
  - `trace` value operands
  - bootstrap binary operands (`vN vN`)

Note: full opcode semantics/type-checking are still being added incrementally.

## Canonicalization policy (current)

- `verify` rejects non-canonical structure for the implemented subset.
- `canon` currently validates and echoes canonical input.
- full canonical rewrite mode is planned as a later pass.

## Implemented CLI behavior

- `l0c canon <input.l0>`
- `l0c canon <input.l0> -o <out.l0>`
- `l0c verify <input.l0>`
- `l0c build <input.l0> <out.l0img>`
- `l0c build <input.l0> -o <out.l0img>`
- `l0c build <input.l0> <out.l0img> --trace-schema <out.bin>`
- `l0c build <input.l0> <out.l0img> --debug-map <out.bin>`
- `l0c build <input.l0> <out.l0img> --trace-schema <out.bin> --debug-map <out.bin>`
- `l0c imgcheck <out.l0img>`
- `l0c imgmeta <out.l0img>`
- `l0c run <out.l0img> [u64_a] [u64_b]`
- `l0c tracecat <trace.bin>`
- `l0c mapcat <debug_map.bin>`
- `l0c schemacat <trace_schema.bin>`
- `l0c tracejoin <trace.bin> <debug_map.bin>`

### `imgcheck` bootstrap integrity rules

`imgcheck` currently validates:
- header magic `L0IM`
- version `1`
- header size `80`
- flags `0` (reserved for future use)
- source section bounds/size consistency
- code/debug section pair consistency (both zero or both valid in-bounds ranges)
- debug schema consistency for non-zero debug section (`L0IX` magic/version, kernel kind range, code-size match, trace schema/version constants)

### `imgmeta` bootstrap output rules

`imgmeta` currently prints selected validated image metadata fields:
- `version`
- `src_size`
- `code_size`
- `fn_count`
- `type_count`
- `kernel_kind`
- `trace_schema_ver`
- `trace_record_size`

Before printing, `imgmeta` now also rejects bootstrap debug-index schema mismatches:
- out-of-range kernel kind ids
- debug `code_size` mismatch vs image header
- unexpected trace schema/version constants

### `run` bootstrap execution rules

`run` currently executes the image code section with a minimal syscall-only loader path:
- I validate core image header fields and code section bounds.
- I allocate executable memory with `mmap` and copy code bytes into it.
- I invoke code as `fn(u64,u64)->u64` using optional decimal CLI args (`u64_a`, `u64_b`) as inputs.
- I print the returned value as unsigned decimal with a newline.
- I reject invalid numeric arguments.

### `tracecat` bootstrap decode rules

`tracecat` currently decodes binary trace records as fixed 16-byte tuples:
- `u64 trace_id`
- `u64 traced_value`

I can emit a matching schema file during build with `--trace-schema <out.bin>`.
Current bootstrap schema payload is 32 bytes:
- magic `L0TS`
- version `1`
- record size `16`
- field count `2`

I can emit a minimal debug map file during build with `--debug-map <out.bin>`.
Current bootstrap debug map payload is variable-size:
- magic `L0DM`
- version `2`
- instruction entry count `N`
- code size (`code_size` from the built image)
- entry array with triplets:
  - `inst_id`
  - `start`
  - `end`
- current bootstrap emits kernel-kind-specific deterministic ranges:
  - fallback/const kernels use one full-range entry
  - canonical lowered kernels use fixed opcode-boundary splits per kernel family
  - current `trace` kernel emits two entries: `inst_id 1` for trace record emission bytes and `inst_id 2` for trailing return path bytes
  - unknown future kernel kinds fall back to deterministic synthetic partitions

`mapcat` decodes this bootstrap debug map format and prints:
- `entries <count>`
- `code_size <bytes>`
- then one `inst_id/start/end` triplet per entry
- it rejects entries with `inst_id = 0`
- it rejects non-increasing `inst_id` order
- it rejects invalid ranges (`start > end` or `end > code_size`)
- it rejects overlapping/non-monotonic ranges (`start < previous_end`)

`schemacat` decodes the bootstrap trace-schema format and prints:
- `version <n>`
- `record_size <bytes>`
- `fields <count>`
and it now rejects schema payloads where bootstrap constants do not match (`version != 1`, `record_size != 16`, or `fields != 2`).

`tracejoin` decodes trace records and debug-map entries, joins by `inst_id`, and prints:
- `id <trace_id>`
- `val <value>`
- `start <offset>`
- `end <offset>`
- it rejects invalid debug-map entries (`inst_id = 0`, non-increasing `inst_id`, or ranges outside/overlapping `code_size`)
- it rejects trace records whose `trace_id` has no matching debug-map entry
- it rejects truncated/non-16-byte-aligned trace payloads
- it treats empty trace payloads as valid and emits no output

I print decoded output in deterministic text lines:
- `id <trace_id>`
- `val <traced_value>`

Bootstrap build output currently also includes a compact 64-byte debug semantic index section:
- I currently emit one of two bootstrap code payloads:
  - canonical lowered kernel payloads for:
    - `add.wrap`, `add.trap`, `sub.wrap`, `sub.trap`, `mul.wrap`, `mul.trap`, `and`, `or`, `xor`, `shl`, `shr`
    - commutative binary kernels in that set also accept canonical swapped operand order (`v1 v0`) during bootstrap lowering
    - non-commutative `sub.wrap` also accepts canonical swapped operand order (`v1 v0`) during bootstrap lowering by selecting a reverse-sub payload
    - binary kernel templates also accept nonzero result value ids when `ret` references the same value (`vN = <op> ...`, `ret vN`)
    - before binary kernel selection, I run a normalization pass that strips canonical dead `const` value lines; this lets me lower binary kernels even when dead const defs are interleaved in the block
    - in that normalization pass, I now strip only dead const defs (not live const defs), and I scope dead-const detection to the current function so same numeric value ids in other functions do not interfere
    - `icmp.eq` compare kernel (`i64` args, `i1` result)
    - canonical `icmp.eq + cbr` select kernel (`i64` args, `i64` result)
    - before compare/select kernel selection, I run normalization that strips dead `const` and dead `icmp.eq` value lines, so canonical interleaved dead defs do not block `icmp.eq` or `icmp.eq + cbr` lowering
    - both kernels also accept swapped compare operand order (`icmp.eq v1 v0`) in bootstrap lowering
    - `icmp.eq` compare kernels also accept nonzero result ids when `ret` references the same compare result value id
    - `icmp.eq + cbr` kernels also accept nonzero compare-result ids when `cbr` references the same compare result value id
    - `icmp.eq + cbr` kernels now also lower deterministic reverse return mappings where `b1` returns arg1 and `b2` returns arg0 (including normalized dead-const variants)
    - `icmp.eq + cbr` kernels now also tolerate extra dead pure value lines (`const` or `icmp.eq`) in `b0`, `b1`, and `b2` when compare id/dataflow and branch-return mapping still match supported selector shapes
    - canonical memory roundtrip kernel (`alloca` + `st` + `ld`)
    - before memory-roundtrip kernel selection, I run the same dead-const normalization pass, so canonical interleaved dead `const` defs do not block lowering
    - memory-roundtrip kernel also accepts canonical nonzero ids across arg/alloca/st/ld/ret when ids/dataflow match
    - memory-roundtrip kernel also accepts canonical arg-return form (`ret vArg`) when the stored value is that same arg
    - memory-roundtrip kernel also accepts canonical nonzero `alloca` element counts (`alloca t0, N`, `N > 0`)
    - memory-roundtrip kernel also accepts either canonical arg/alloca definition order (`arg` then `alloca`, or `alloca` then `arg`)
    - canonical `gep` memory roundtrip kernel (`alloca` + `st` + `gep` + `ld`)
    - before memory-gep-roundtrip kernel selection, I run the same dead-const normalization pass, so canonical interleaved dead `const` defs do not block lowering
    - memory-gep-roundtrip kernel also accepts canonical nonzero ids across arg/alloca/st/gep/ld/ret when ids/dataflow match
    - memory-gep-roundtrip kernel also accepts canonical arg-return form (`ret vArg`) when the stored value is that same arg
    - memory-gep-roundtrip kernel also accepts canonical nonzero `alloca` element counts (`alloca t0, N`, `N > 0`)
    - memory-gep-roundtrip kernel also accepts either canonical arg/alloca definition order (`arg` then `alloca`, or `alloca` then `arg`)
    - canonical intrinsic kernels (`malloc` syscall-backed allocator, `free` no-op, `exit` syscall, `write` syscall; canonical newline test returns `0`, `trace` currently lowers to fixed 16-byte binary stderr emission)
    - before `malloc` and `exit` kernel selection, I run generalized dead pure-line normalization, so canonical interleaved dead `const` and dead `icmp.eq` defs do not block lowering for those const-independent intrinsic shapes
    - `malloc` intrinsic kernel also accepts canonical nonzero arg/result ids when ids/dataflow match (`vN = arg ...`, `vM = malloc vN`, `ret vM`)
    - `free` intrinsic kernel also accepts canonical nonzero arg/const-ret ids when ids/dataflow match (`vN = arg ...`, `free vN`, `vM = const 0`, `ret vM`)
    - `exit` intrinsic kernel also accepts canonical nonzero arg/return ids when ids/dataflow match (`vN = arg ...`, `exit vN`, `ret vN`)
    - bootstrap newline `write` intrinsic kernel also accepts canonical nonzero ids across alloca/const/store/write/ret when ids/dataflow match
    - bootstrap newline `write` intrinsic kernel also accepts canonical nonzero `alloca` element counts (`alloca t0, N`, `N > 0`)
    - `trace` intrinsic kernel also accepts canonical nonzero traced-arg id and const/return id when ids/dataflow match (`trace 1 vN` and `ret vM` where `vM` is the const-def id)
    - for const-dependent kernels (`free`, `write`, `trace`), I now run generalized dead pure-line normalization before selector matching and lower valid dead-const/dead-icmp-injected canonical variants (including nonzero-id, multi-dead-const, and cross-function value-id-reuse cases), while preserving intentional write guardrail fallback for `alloca ... , 0` shapes
    - intrinsic generalized coverage now also includes multi-dead-pure (`const` + `icmp.eq`) variants for `malloc`/`free`/`write`/`trace`/`exit`, plus cross-function dead-icmp id-reuse variants for `free` and `trace`, with write `alloca 0` cross-function guardrails preserved
    - in the current build selector chain, these const-dependent intrinsic families are routed through generalized normalized selector paths only (legacy direct fallback stages are removed)
    - I now apply the same generalized-only routing to all current generalized families, including const-return (`exit`, `malloc`, `call`, memory roundtrip families, compare/select, binary, and const-return)
    - canonical two-function call kernels (`f0` calling `f1` with `add.wrap`/`sub.wrap`/`mul.wrap`/`and`/`or`)
    - before call-kernel selection, I run generalized dead pure-line normalization, so canonical interleaved dead `const` and dead `icmp.eq` defs in `f0`/`f1` do not block call lowering
    - call->commutative targets (`add.wrap`, `mul.wrap`, `and`, `or`, `xor`) also accept swapped call-arg order in `f0` (`call f1 v1 v0`) in bootstrap lowering
    - call->non-commutative targets (`shl`, `shr`) now lower both semantic call-arg mappings:
      - canonical arg0->arg1 mapping
      - reverse arg1->arg0 mapping via dedicated reverse-shift payloads
    - for call->`sub.wrap`, I now lower canonical semantic arg0->arg1 shapes and one deterministic reverse-mapping shape where `f0` provides arg1->arg0 mapping while `f1` remains canonical
    - non-matching non-commutative call shapes remain intentionally unlowered guardrails in current bootstrap lowering
    - call-kernel templates also accept either canonical arg-definition order in `f0` (`arg 0` then `arg 1`, or `arg 1` then `arg 0`)
    - for call->`sub.wrap`, I keep non-commutative guardrails by lowering canonical and explicit reverse-mapping forms under supported `f0`/`f1` mapping combinations
    - call-kernel templates also accept either canonical arg-definition order in `f1` (`arg 0` then `arg 1`, or `arg 1` then `arg 0`)
    - for call->`sub.wrap`, I now also lower reverse `f1` mapping variants (including argdef-order-swapped and dead-const-normalized forms); non-matching structural mismatch shapes remain guardrailed
    - call-kernel templates also accept nonzero call-result ids in `f0` when `ret` references the same value id
    - mismatch trace-id/dataflow shapes remain intentionally unlowered in current bootstrap selector and are regression-tested
    - mismatch malloc result-id/dataflow shapes remain intentionally unlowered in current bootstrap selector and are regression-tested
    - mismatch free-noop const/return-id dataflow shapes remain intentionally unlowered in current bootstrap selector and are regression-tested
    - non-returning `exit` shapes now lower when `exit` operand matches the canonical arg id, even when trailing return-path lines are unreachable
    - mismatch write-newline const/return-id dataflow shapes remain intentionally unlowered in current bootstrap selector and are regression-tested
    - mismatch memory-roundtrip load/return-id dataflow shapes remain intentionally unlowered in current bootstrap selector and are regression-tested
    - mismatch memory-gep-roundtrip load/return-id dataflow shapes remain intentionally unlowered in current bootstrap selector and are regression-tested
    - canonical branch-identity multi-block modules (`cbr vN b1 b2` with both branches returning `vN`) are now directly lowered in bootstrap instead of falling back to the single-byte `ret` stub
    - canonical branch-const-select multi-block modules (`cbr vN b1 b2` with branch-local `const` returns) are now directly lowered in bootstrap, including dead-const-normalized variants, while unsupported branch-return mappings remain strict fallback guardrails
    - const-return kernel (`const N` or `const -N` -> `ret v0`)
    - const-return kernels also accept nonzero const-def value ids when the same id is returned (`vN = const ...`, `ret vN`)
- fallback payload for other verified modules: single-byte `ret` (`0xC3`)
- magic `L0IX`
- version `1`
- function count
- type count
- kernel kind id
- code size
- trace schema version
- trace record size

## Next focus areas

1. General CFG lowering beyond current template/kernel selectors.
2. SSA merge/join lowering for broader branch convergence shapes.
3. Register allocation generalization and spill stress coverage.
4. ABI/output-path expansion (including object emission milestones).
