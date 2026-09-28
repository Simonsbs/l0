# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-28T09:41:37Z`
- host: `runnervmtr4k5`
- kernel: `Linux 6.17.0-1022-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `AMD EPYC 7763 64-Core Processor`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 677.0000 | 64.0000 | 10.5781 | 408.3729 ± 11.8489 | 398.9796 ± 9.4430 | 1.0235 | 2.90% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 689.0000 | 69.0000 | 9.9855 | 423.2032 ± 0.4029 | 423.4326 ± 1.4195 | 0.9995 | 0.10% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 683.0000 | 68.0000 | 10.0441 | 424.2051 ± 0.7749 | 423.5887 ± 0.4367 | 1.0015 | 0.18% | ok |
| and (2-arg) | `tests/valid_and.l0` | 672.0000 | 64.0000 | 10.5000 | 423.8461 ± 0.1806 | 424.2235 ± 0.5093 | 0.9991 | 0.04% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 689.0000 | 69.0000 | 9.9855 | 424.7124 ± 2.0215 | 425.5452 ± 1.4601 | 0.9980 | 0.48% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 689.0000 | 70.0000 | 9.8429 | 422.9741 ± 0.4074 | 423.4509 ± 0.6963 | 0.9989 | 0.10% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 689.0000 | 70.0000 | 9.8429 | 424.2880 ± 2.2159 | 424.9712 ± 0.7058 | 0.9984 | 0.52% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 683.0000 | 66.0000 | 10.3485 | 425.6473 ± 1.0311 | 423.6622 ± 0.0649 | 1.0047 | 0.24% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 666.0000 | 68.0000 | 9.7941 | 424.1038 ± 0.7371 | 425.2951 ± 0.5368 | 0.9972 | 0.17% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.0986 |
| Geometric mean runtime ratio (L0/GCC) | 1.0023 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
