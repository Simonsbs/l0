# Production Readiness Gate (v1)

I use this document as the frozen production-readiness gate contract for the current bootstrap toolchain.

Contract version: `prodready.v1`

## What I Freeze in v1

I freeze a final, scripted production-readiness gate that requires:
- milestone gate coverage M52 through M69 in the active test run
- representative checkpoint coverage for M54 through M59 slices
- presence of all frozen v1 contract docs
- release-candidate packaging and checksum verification success

## Enforcement

I enforce this contract in:
- `tests/production_readiness.sh`

That harness is integrated at the end of `tests/run.sh` and therefore enforced by `make test`.

## Gate Inputs in v1

I require successful prerequisite gate outputs from the active run:
- `/tmp/l0_m52_parser_fuzz.out`
- `/tmp/l0_m53_verifier_matrix.out`
- `/tmp/l0_m60_intrinsic_contracts.out`
- `/tmp/l0_m61_debug_map_schema.out`
- `/tmp/l0_m62_trace_schema_contracts.out`
- `/tmp/l0_m63_deterministic_builds.out`
- `/tmp/l0_m64_differential_semantics.out`
- `/tmp/l0_m65_fuzz_stress.out`
- `/tmp/l0_m66_performance_gates.out`
- `/tmp/l0_m67_error_model.out`
- `/tmp/l0_m68_release_pipeline.out`
- `/tmp/l0_m69_compatibility_matrix.out`

I also require representative milestone checkpoints already produced by the suite for M54-M59 slices.

## Release-Candidate Check in v1

I run the release pipeline for:
- version `1.0.0-rc1`

I require all expected artifacts and checksum verification to pass.

## Tag Policy in v1

I cut and publish a production candidate tag in the repository:
- `v1.0.0-rc1`

I treat this as the production candidate anchor for the v1 contract set.

## Out of Scope in v1

- External deployment rollout automation.
- Signed artifact attestation systems.
- Multi-platform production readiness beyond current Linux x86-64 bootstrap scope.
