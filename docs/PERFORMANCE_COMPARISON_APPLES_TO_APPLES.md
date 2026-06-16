# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-16T04:52:51Z`
- host: `runnervm1li68`
- kernel: `Linux 6.17.0-1018-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `AMD EPYC 9V74 80-Core Processor`
- cpu_topology: `CPU(s)=4 Thread(s) per core=2 Core(s) per socket=2 Socket(s)=1`
- cpu_affinity: `0`
- build iterations per sample: `80`
- build samples per kernel: `3`
- runtime iterations per sample: `5000000`
- runtime samples per kernel: `5`
- warmup runs per kernel: `1`
- outlier_trim_count_per_side: `1`
- runtime_ci95_warn_threshold_pct: `20`

## Method

I compare multiple equivalent `f0(uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t)->uint64_t` implementations:
- L0: each listed fixture built via `l0c build-elf`
- GCC: generated equivalent C function built with `gcc -O2 -c`
- Runtime harness: same assembly `_start` loop calling `f0` with fixed args for both variants
- Runtime metric: median Mops/s across samples + CI95 on sample mean
- Build metric: median build throughput (ops/s) across samples
- Machine-readable artifact: `docs/PERFORMANCE_COMPARISON_APPLES_TO_APPLES.json`

## Per-Kernel Results

| Kernel | L0 fixture | Build ops/s L0 (median) | Build ops/s GCC (median) | Build ratio L0/GCC | Runtime Mops/s L0 (median ± CI95) | Runtime Mops/s GCC (median ± CI95) | Runtime ratio L0/GCC | CI95% L0 | Stability |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 695.0000 | 66.0000 | 10.5303 | 306.5697 ± 0.5374 | 306.1085 ± 0.5631 | 1.0015 | 0.18% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 714.0000 | 65.0000 | 10.9846 | 306.8105 ± 0.3574 | 306.6852 ± 0.4953 | 1.0004 | 0.12% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 689.0000 | 65.0000 | 10.6000 | 305.4526 ± 1.7607 | 314.7815 ± 1.3672 | 0.9704 | 0.58% | ok |
| and (2-arg) | `tests/valid_and.l0` | 683.0000 | 65.0000 | 10.5077 | 305.6725 ± 0.1616 | 307.6030 ± 0.3560 | 0.9937 | 0.05% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 695.0000 | 65.0000 | 10.6923 | 305.3332 ± 1.6801 | 306.1660 ± 2.4642 | 0.9973 | 0.55% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 683.0000 | 63.0000 | 10.8413 | 312.5400 ± 6.2178 | 300.6195 ± 21.6864 | 1.0397 | 1.99% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 701.0000 | 63.0000 | 11.1270 | 304.0498 ± 1.3807 | 301.9767 ± 1.6836 | 1.0069 | 0.45% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 695.0000 | 61.0000 | 11.3934 | 307.2739 ± 0.1822 | 305.9167 ± 1.5218 | 1.0044 | 0.06% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 689.0000 | 61.0000 | 11.2951 | 314.3408 ± 1.0024 | 314.7004 ± 2.0441 | 0.9989 | 0.32% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.8813 |
| Geometric mean runtime ratio (L0/GCC) | 1.0013 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
