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

Function body requirements currently enforced:
- at least one block
- first block must be `b0:`
- `b0:` must be unique inside a function
- block labels use `bN:`
- every block label must be unique inside a function
- instruction lines are indented with two spaces
- each block must terminate before next block or function close
- no instruction is allowed after a terminator within the same block
- `br` and `cbr` targets must reference blocks declared in the same function

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

Current bootstrap opcode-aware checks:
- `arg` requires a numeric index operand
- `arg` index must be within the function argument count
- binary ops (`add.wrap`, `sub.wrap`, `mul.wrap`, `and`, `or`, `xor`, `shl`, `shr`) require `vN vN` operands

Current bootstrap SSA check:
- each SSA value id (`vN`) may be assigned once per function

Note: full opcode semantics/type-checking are still being added incrementally.

## Canonicalization policy (current)

- `verify` rejects non-canonical structure for the implemented subset.
- `canon` currently validates and echoes canonical input.
- full canonical rewrite mode is planned as a later pass.

## Implemented CLI behavior

- `l0c canon <input.l0>`
- `l0c verify <input.l0>`
- `l0c build <input.l0> <out.l0img>`
- `l0c imgcheck <out.l0img>`

### `imgcheck` bootstrap integrity rules

`imgcheck` currently validates:
- header magic `L0IM`
- version `1`
- header size `80`
- flags `0` (reserved for future use)
- source section bounds/size consistency
- code/debug section pair consistency (both zero or both valid in-bounds ranges)

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
