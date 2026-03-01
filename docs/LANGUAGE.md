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
- bootstrap type RHS token set is currently restricted to:
  - `i1`, `i8`, `i16`, `i32`, `i64`
  - `u8`, `u16`, `u32`, `u64`
  - `p0<i8>`

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
- `kernel_kind`
- `trace_schema_ver`
- `trace_record_size`

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
- current bootstrap emits `N=1` for fallback/const kernels and `N=3` for other kernels.

`mapcat` decodes this bootstrap debug map format and prints:
- `entries <count>`
- `code_size <bytes>`
- then one `inst_id/start/end` triplet per entry

`schemacat` decodes the bootstrap trace-schema format and prints:
- `version <n>`
- `record_size <bytes>`
- `fields <count>`

I print decoded output in deterministic text lines:
- `id <trace_id>`
- `val <traced_value>`

Bootstrap build output currently also includes a compact 64-byte debug semantic index section:
- I currently emit one of two bootstrap code payloads:
  - canonical lowered kernel payloads for:
    - `add.wrap`, `add.trap`, `sub.wrap`, `sub.trap`, `mul.wrap`, `mul.trap`, `and`, `or`, `xor`, `shl`, `shr`
    - `icmp.eq` compare kernel (`i64` args, `i1` result)
    - canonical `icmp.eq + cbr` select kernel (`i64` args, `i64` result)
    - canonical memory roundtrip kernel (`alloca` + `st` + `ld`)
    - canonical `gep` memory roundtrip kernel (`alloca` + `st` + `gep` + `ld`)
    - canonical intrinsic kernels (`malloc` syscall-backed allocator, `free` no-op, `exit` syscall, `write` syscall; canonical newline test returns `0`, `trace` currently lowers to fixed 16-byte binary stderr emission)
    - canonical two-function call->arith kernels (`f0` calling `f1` with `add.wrap`/`sub.wrap`/`mul.wrap`)
    - const-return kernel (`const N` or `const -N` -> `ret v0`)
- fallback payload for other verified modules: single-byte `ret` (`0xC3`)
- magic `L0IX`
- version `1`
- function count
- type count
- kernel kind id
- code size
- trace schema version
- trace record size

## Planned language expansion (next milestones)

1. Opcode-specific verification rules:
- `arg` operand shape
- binary op operand shapes
- call operand/type arity checks

2. SSA/dataflow checks:
- def-before-use
- single-definition checks

3. Type system expansion in verifier:
- operation signatures
- pointer/memory op rules

4. Full token-level parser replacing line-shape validation.
