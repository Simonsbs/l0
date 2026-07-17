# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-17T05:48:54Z`
- host: `runnervm3jd5f`
- kernel: `Linux 6.17.0-1020-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 952.0000 | 73.0000 | 13.0411 | 373.7895 ± 3.4183 | 372.6484 ± 1.4172 | 1.0031 | 0.91% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 963.0000 | 76.0000 | 12.6711 | 366.2682 ± 2.1459 | 468.5101 ± 9.7761 | 0.7818 | 0.59% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 941.0000 | 76.0000 | 12.3816 | 452.8986 ± 2.4491 | 441.5339 ± 5.0309 | 1.0257 | 0.54% | ok |
| and (2-arg) | `tests/valid_and.l0` | 987.0000 | 77.0000 | 12.8182 | 370.7597 ± 3.1233 | 497.3707 ± 13.3529 | 0.7454 | 0.84% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 952.0000 | 76.0000 | 12.5263 | 368.2848 ± 6.2146 | 414.9670 ± 8.2556 | 0.8875 | 1.69% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 941.0000 | 78.0000 | 12.0641 | 438.6285 ± 5.6530 | 369.8120 ± 1.6559 | 1.1861 | 1.29% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 941.0000 | 76.0000 | 12.3816 | 368.2501 ± 2.0415 | 376.3174 ± 1.9197 | 0.9786 | 0.55% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 952.0000 | 75.0000 | 12.6933 | 373.8539 ± 6.2766 | 393.4975 ± 13.1862 | 0.9501 | 1.68% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 898.0000 | 72.0000 | 12.4722 | 463.4408 ± 20.3488 | 514.7660 ± 2.0523 | 0.9003 | 4.39% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 12.5582 |
| Geometric mean runtime ratio (L0/GCC) | 0.9316 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
