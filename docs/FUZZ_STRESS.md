# Fuzz and Malformed-Input Stress (v1)

I use this document as the frozen fuzz-stress contract for the current bootstrap toolchain.

Contract version: `fuzzstress.v1`

## What I Freeze in v1

I freeze deterministic, fixed-budget malformed-input stress checks across four surfaces:
- parser (`verify`, `canon` on mutated `.l0` inputs)
- verifier (`verify` on mutated `.l0` inputs)
- image tooling (`imgcheck`, `imgmeta` on mutated `.img` inputs)
- trace/debug tooling (`tracecat`, `tracejoin`, `mapcat`, `schemacat` on mutated binary payloads)

For this contract, the invariant is crash-freedom under the fixed corpus and mutation budget.

## Enforcement

I enforce this contract in:
- `tests/m65_fuzz_stress.sh`

That harness is integrated into `tests/run.sh` and therefore enforced by `make test`.

## Corpus and Regression Fixtures in v1

I seed the stress harness with:
- parser seeds in `tests/fuzz/parser_seeds/`
- verifier seeds in `tests/fuzz/verifier_seeds/`
- generated baseline image/trace artifacts from canonical fixtures

I also lock malformed regression fixtures in:
- `tests/fuzz/m65_regressions/`

Those regression fixtures are required to fail deterministically without crashing.

## Fixed Budget Minimums in v1

I require at least these executed command counts per run:
- parser surface: `>=120`
- verifier surface: `>=30`
- image surface: `>=20`
- trace surface: `>=35`

## Out of Scope in v1

- Coverage-guided fuzzing engines and corpus minimization.
- Cross-machine fuzz reproducibility guarantees outside the pinned Linux x86-64 bootstrap environment.
- Exhaustive semantic rejection requirements for every malformed mutation; v1 gates crash-freedom and deterministic execution stability.
