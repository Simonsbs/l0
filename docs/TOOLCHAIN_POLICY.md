# Toolchain Pinning and Policy

I use this document to define the pinned native toolchain baseline for deterministic builds and tests.

## Policy Version

- `toolchain.v1`

## Supported Toolchain Baseline

I require GNU toolchain components with these minimum versions:

- GNU assembler (`as`) >= `2.40`
- GNU linker (`ld`) >= `2.40`
- GNU Make (`make`) >= `4.3`

I validate this baseline with:
- `tests/toolchain_policy.sh`

That gate is enforced by:
- `tests/run.sh`
- `make test`

## Why I Pin This

I pin these versions to reduce drift in:
- assembly parsing behavior
- linker behavior
- deterministic output expectations in release and compatibility gates

## Upgrade Procedure

When I upgrade this baseline, I do all of the following:
1. run `make test` on the target toolchain
2. evaluate deterministic artifact and compatibility gates
3. update this policy doc and `tests/toolchain_policy.sh`
4. record impact in release notes and `docs/COMPATIBILITY_POLICY.md` when needed
