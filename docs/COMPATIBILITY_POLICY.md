# Compatibility and Upgrade Policy (v1)

I use this document as the frozen compatibility and upgrade policy contract for the current bootstrap toolchain.

Contract version: `compat.v1`

## What I Freeze in v1

I freeze compatibility expectations across these surfaces:
- source compatibility (canonical L0 accepted/verified/built behavior)
- image compatibility (`L0IMG` v1 decode/execute behavior)
- trace/debug compatibility (`debugmap.v1`, `traceschema.v1` decode behavior)
- object-output compatibility (`build-elf` + minimal native link/run slice)
- previously frozen contract-doc surfaces (intrinsics, determinism, differential, fuzz, perf, error, release)

## Upgrade Policy in v1

I use semantic versioning-style release tags:
- release candidate: `vMAJOR.MINOR.PATCH-rcN`
- production release: `vMAJOR.MINOR.PATCH`

I apply this bump policy:
- `PATCH`: bug fixes and hardening with no contract-surface breakage
- `MINOR`: additive, backward-compatible capabilities
- `MAJOR`: any change that breaks a frozen compatibility contract

When a frozen contract surface changes, I bump that contract version and document migration impact.

## Backward-Compatibility Expectations in v1

For the current v1 line, I keep:
- canonical v1 source fixtures accepted and behaviorally stable
- v1 image format accepted by `imgcheck`/`imgmeta`/`run`
- v1 trace/debug schemas accepted by `schemacat`/`mapcat`/`tracecat`/`tracejoin`
- prior v1 fixture behavior slices stable under the compatibility matrix gate

## Enforcement

I enforce this policy with:
- `tests/compatibility_matrix.sh`
- `tests/compat/m69_matrix.tsv`

That gate is integrated into `tests/run.sh` and therefore enforced by `make test`.

## Matrix Coverage in v1

I run compatibility slices spanning prior milestone fixtures:
- arithmetic and const-return runtime outputs
- control-flow and multi-block merge runtime outputs
- spill/regalloc runtime output slice
- SysV 6-arg runtime output slice
- trace/debug decode output slices
- ELF build/link/run exit-code slice

## Out of Scope in v1

- Multi-version binary migration tooling.
- Automatic source upgrader between future major contract versions.
- Cross-platform object compatibility beyond current Linux x86-64 bootstrap scope.
