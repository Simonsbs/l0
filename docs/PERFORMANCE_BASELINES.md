# Performance Baseline and Regression Gates (v1)

I use this document as the frozen performance-baseline contract for the current bootstrap toolchain.

Contract version: `perfbase.v1`

## What I Freeze in v1

I freeze deterministic throughput floors (ops/sec) for representative CLI workloads in the pinned Linux x86-64 bootstrap environment.

The gated workloads are:
- `verify` on `tests/valid_min.l0`
- `build` on `tests/valid_min.l0`
- `run` on `valid_min` image (2-arg arithmetic kernel)
- `run` on `valid_sysv_abi_sum6_lowered` image (6-arg SysV kernel)
- `build-elf` on `tests/valid_sysv_abi_sum6_lowered.l0`
- `mapcat`, `schemacat`, `tracecat`, `tracejoin` on deterministic trace artifacts

## Enforcement

I enforce this contract in:
- `tests/performance_gates.sh`

That harness is integrated into `tests/run.sh` and therefore enforced by `make test`.

## Pinned Throughput Floors in v1

- `verify.valid_min >= 1800 ops/s`
- `build.valid_min >= 1300 ops/s`
- `run.add >= 2400 ops/s`
- `run.sum6 >= 2200 ops/s`
- `build-elf.sum6 >= 1100 ops/s`
- `mapcat.trace_map >= 2500 ops/s`
- `schemacat.trace_schema >= 2500 ops/s`
- `tracecat.trace_bin >= 2500 ops/s`
- `tracejoin.trace_bin+map >= 2300 ops/s`

## Out of Scope in v1

- Cross-machine or cross-CPU performance comparability guarantees.
- Full benchmarking methodology for release marketing claims.
- Auto-tuning of thresholds; v1 thresholds are pinned and explicitly versioned.
