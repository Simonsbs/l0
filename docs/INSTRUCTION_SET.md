# L0 Instruction Set (Bootstrap)

I use this document as my operator-level reference for the current L0 bootstrap language slice.

This is intentionally strict and canonical. I only describe forms that are valid in my current verifier/build pipeline.

## Instruction line forms

I only use three line shapes inside a block:

1. Value-producing:
`vN = OP ... : tM`

2. Non-value:
`OP ...`

3. Terminator:
`br bK` or `cbr vN bT bF` or `ret` or `ret vN`

I keep one instruction per line.

## Value-producing ops

### `arg`

Form:
`vN = arg I : tM`

Rules:
- `I` is a zero-based function argument index.
- `arg` result type must match the declared function signature at index `I`.
- index must be in range.

### `const`

Form:
`vN = const K : tM`

Rules:
- I currently use integer literals for bootstrap lowering.
- sign is explicit in the literal (`-42` supported).
- result type must be a known declared type (`tM`).

### Binary integer/bitwise

Forms:
- `vN = add.wrap vA vB : tM`
- `vN = add.trap vA vB : tM`
- `vN = sub.wrap vA vB : tM`
- `vN = sub.trap vA vB : tM`
- `vN = mul.wrap vA vB : tM`
- `vN = mul.trap vA vB : tM`
- `vN = and vA vB : tM`
- `vN = or vA vB : tM`
- `vN = xor vA vB : tM`
- `vN = shl vA vB : tM`
- `vN = shr vA vB : tM`

Rules:
- both operands must be defined before use.
- operand types must match result type.
- bootstrap lowering targets integer kernels over `i64` (`t0`) in canonical tests.

### `icmp.eq`

Form:
`vN = icmp.eq vA vB : tM`

Rules:
- operand types must match.
- result must be `i1`.

### `call`

Form:
`vN = call fK vA vB ... : tM`

Rules:
- target function id must exist.
- argument arity must match callee signature.
- operand types must match callee argument types.
- result type suffix must match callee return type.

### Memory value ops

`alloca`:
`vN = alloca tElem, COUNT : tPtr`

`ld`:
`vN = ld vPtr : tVal`

`gep`:
`vN = gep vPtr OFFSET : tPtr`

`malloc`:
`vN = malloc vSize : tPtr`

Rules:
- pointer-related ops require pointer-compatible types in bootstrap (`p0<i8>` path).
- `malloc` size must be an integer-like value, not pointer-typed.

## Non-value ops

### `st`

Form:
`st vPtr vVal`

Rules:
- `vPtr` must be pointer-compatible.
- `vVal` must be defined before use.

### `free`

Form:
`free vPtr`

Rules:
- pointer-compatible operand required.
- currently lowered as defined no-op free stub in bootstrap.

### `write`

Form:
`write vPtr vLen`

Rules:
- pointer + integer length shape.
- currently lowered for canonical newline kernel template.

### `exit`

Form:
`exit vCode`

Rules:
- integer-like exit code operand.
- currently lowered for canonical single-block exit template.

### `trace`

Form:
`trace ID vA vB ...`

Rules:
- `ID` is decimal.
- all traced values must be defined before use.
- current bootstrap lowering path targets canonical trace-noop template.

## Terminators

### `br`
`br bK`

### `cbr`
`cbr vCond bT bF`

Rules:
- `vCond` must be typed `i1`.
- branch targets must exist in the same function.

### `ret`
`ret` or `ret vN`

Rules:
- if value form is used, value type must match function return type.

## Bootstrap lowering note

My current compiler has two layers:

1. Verifier acceptance (broader bootstrap subset)
2. Selector-based lowering to native payloads (currently canonical template-driven)

If a verified module does not match a current lowering template, build falls back to a deterministic `ret` stub (`kernel_kind=0`, `code_size=1`).

