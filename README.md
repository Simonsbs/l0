# L0

L0 is a low-level, typed SSA source language designed for deterministic compilation and LLM-friendly workflows.

This repository is intentionally native-only for bootstrap:
- implementation language: x86-64 assembly
- runtime dependency: none (Linux syscalls only)
- build tools: GNU binutils + make

## Current status

Initial bootstrap is in place:
- `l0c` CLI skeleton (`canon`, `verify`)
- `l0c build` producing deterministic `.l0img` container header + payload
- `verify` now enforces function/block structural rules in `fns`
- verifier enforces canonical entry block (`b0`) per function
- verifier rejects duplicate `b0` labels in a function
- verifier rejects duplicate block labels in a function
- verifier includes bootstrap opcode-operand checks for `arg` and common binary ops
- file loader (syscalls only)
- strict module-shape validator for fixed section order
- canonical mode echoes validated canonical source

## Documentation

- Language reference: `docs/LANGUAGE.md`
- MVP/compiler spec: `docs/SPEC.md`
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
./bin/l0c verify <module.l0>
./bin/l0c build <module.l0> <out.l0img>
./bin/l0c imgcheck <out.l0img>
```

## Notes

This is the first implementation slice. Full parser, verifier, codegen, image format, loader, and trace pipeline are being implemented incrementally from the frozen spec.
