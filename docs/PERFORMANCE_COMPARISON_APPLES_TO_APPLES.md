# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-12T04:59:11Z`
- host: `runnervmvrwv9`
- kernel: `Linux 6.17.0-1020-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 672.0000 | 57.0000 | 11.7895 | 302.1776 ± 1.1257 | 301.7341 ± 0.9988 | 1.0015 | 0.37% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 677.0000 | 58.0000 | 11.6724 | 299.3892 ± 1.3998 | 301.3245 ± 1.4152 | 0.9936 | 0.47% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 655.0000 | 57.0000 | 11.4912 | 298.3054 ± 0.7358 | 307.4190 ± 1.3753 | 0.9704 | 0.25% | ok |
| and (2-arg) | `tests/valid_and.l0` | 661.0000 | 57.0000 | 11.5965 | 298.7298 ± 0.1030 | 302.3179 ± 2.1170 | 0.9881 | 0.03% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 661.0000 | 58.0000 | 11.3966 | 299.5407 ± 0.7416 | 301.7807 ± 0.7209 | 0.9926 | 0.25% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 661.0000 | 58.0000 | 11.3966 | 309.3618 ± 0.3951 | 301.5664 ± 0.9274 | 1.0258 | 0.13% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 655.0000 | 57.0000 | 11.4912 | 299.4075 ± 0.9669 | 297.5646 ± 0.8262 | 1.0062 | 0.32% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 666.0000 | 57.0000 | 11.6842 | 299.5269 ± 1.8443 | 298.6064 ± 0.5146 | 1.0031 | 0.62% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 661.0000 | 56.0000 | 11.8036 | 307.3899 ± 3.5804 | 308.8970 ± 1.1834 | 0.9951 | 1.16% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.5904 |
| Geometric mean runtime ratio (L0/GCC) | 0.9973 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
