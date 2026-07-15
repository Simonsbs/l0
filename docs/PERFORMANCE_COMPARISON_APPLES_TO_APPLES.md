# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-15T05:40:01Z`
- host: `runnervm5mmn9`
- kernel: `Linux 6.17.0-1018-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 733.0000 | 68.0000 | 10.7794 | 416.1695 ± 1.8177 | 417.3077 ± 0.4990 | 0.9973 | 0.44% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 727.0000 | 69.0000 | 10.5362 | 422.2151 ± 1.3246 | 421.4498 ± 1.2930 | 1.0018 | 0.31% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 727.0000 | 68.0000 | 10.6912 | 420.2167 ± 0.3934 | 421.4407 ± 1.1545 | 0.9971 | 0.09% | ok |
| and (2-arg) | `tests/valid_and.l0` | 720.0000 | 69.0000 | 10.4348 | 422.1969 ± 0.5838 | 421.6318 ± 1.0050 | 1.0013 | 0.14% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 720.0000 | 68.0000 | 10.5882 | 420.8505 ± 0.5431 | 420.3523 ± 0.3522 | 1.0012 | 0.13% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 727.0000 | 70.0000 | 10.3857 | 422.1786 ± 0.1992 | 421.7866 ± 0.3414 | 1.0009 | 0.05% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 733.0000 | 70.0000 | 10.4714 | 419.1975 ± 1.5243 | 421.6318 ± 0.4204 | 0.9942 | 0.36% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 727.0000 | 66.0000 | 11.0152 | 420.1805 ± 4.4176 | 419.4045 ± 1.2634 | 1.0019 | 1.05% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 695.0000 | 65.0000 | 10.6923 | 418.0490 ± 2.6582 | 422.3521 ± 0.5152 | 0.9898 | 0.64% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.6200 |
| Geometric mean runtime ratio (L0/GCC) | 0.9984 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
