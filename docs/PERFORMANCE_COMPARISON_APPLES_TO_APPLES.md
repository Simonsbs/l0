# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-06T07:52:13Z`
- host: `runnervmejwal`
- kernel: `Linux 6.17.0-1022-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `AMD EPYC 9V45 96-Core Processor`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 192.0000 | 70.0000 | 2.7429 | 446.6532 ± 4.7454 | 451.5478 ± 9.2164 | 0.9892 | 1.06% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 400.0000 | 48.0000 | 8.3333 | 451.7776 ± 1.2370 | 446.8167 ± 10.1998 | 1.0111 | 0.27% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 375.0000 | 72.0000 | 5.2083 | 440.1904 ± 11.1290 | 446.1940 ± 11.8528 | 0.9865 | 2.53% | ok |
| and (2-arg) | `tests/valid_and.l0` | 375.0000 | 62.0000 | 6.0484 | 437.6555 ± 2.7167 | 444.9032 ± 2.6783 | 0.9837 | 0.62% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 232.0000 | 67.0000 | 3.4627 | 451.9867 ± 14.1709 | 460.3712 ± 12.1392 | 0.9818 | 3.14% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 193.0000 | 66.0000 | 2.9242 | 459.3967 ± 7.0350 | 462.9465 ± 3.2213 | 0.9923 | 1.53% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 165.0000 | 57.0000 | 2.8947 | 449.2524 ± 107.9103 | 429.8440 ± 50.4599 | 1.0452 | 24.02% | warn |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 189.0000 | 69.0000 | 2.7391 | 465.2846 ± 2.3739 | 466.5628 ± 0.6178 | 0.9973 | 0.51% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 610.0000 | 63.0000 | 9.6825 | 459.3751 ± 7.6263 | 457.8674 ± 10.2051 | 1.0033 | 1.66% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 4.3518 |
| Geometric mean runtime ratio (L0/GCC) | 0.9988 |
| Kernels above runtime CI95 warning threshold | 1 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
