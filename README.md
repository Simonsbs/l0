# L0

L0 is a low-level, typed SSA source language designed for deterministic compilation and LLM-friendly workflows.

This repository is intentionally native-only for bootstrap:
- implementation language: x86-64 assembly
- runtime dependency: none (Linux syscalls only)
- build tools: GNU binutils + make

## Current status

Initial bootstrap is in place:
- `l0c` CLI skeleton (`canon`, `verify`)
- file loader (syscalls only)
- strict module-shape validator for fixed section order
- canonical mode echoes validated canonical source

## Build

```sh
make
```

## Usage

```sh
./bin/l0c canon <module.l0>
./bin/l0c verify <module.l0>
```

## Notes

This is the first implementation slice. Full parser, verifier, codegen, image format, loader, and trace pipeline are being implemented incrementally from the frozen spec.
