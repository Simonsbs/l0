# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-19T06:06:13Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 952.0000 | 75.0000 | 12.6933 | 368.9597 ± 2.1389 | 369.6160 ± 0.8693 | 0.9982 | 0.58% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 987.0000 | 75.0000 | 13.1600 | 391.2275 ± 3.8764 | 418.7391 ± 31.7881 | 0.9343 | 0.99% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 952.0000 | 75.0000 | 12.6933 | 472.9460 ± 5.9501 | 459.1699 ± 1.5203 | 1.0300 | 1.26% | ok |
| and (2-arg) | `tests/valid_and.l0` | 963.0000 | 74.0000 | 13.0135 | 372.1656 ± 1.9414 | 452.8565 ± 36.6951 | 0.8218 | 0.52% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 952.0000 | 74.0000 | 12.8649 | 368.0628 ± 1.3534 | 402.8308 ± 36.4169 | 0.9137 | 0.37% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 952.0000 | 74.0000 | 12.8649 | 420.0540 ± 34.4233 | 371.2671 ± 2.0365 | 1.1314 | 8.19% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 941.0000 | 77.0000 | 12.2208 | 362.5155 ± 0.9349 | 366.8391 ± 1.6048 | 0.9882 | 0.26% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 941.0000 | 75.0000 | 12.5467 | 368.5142 ± 1.2869 | 369.4902 ± 7.4057 | 0.9974 | 0.35% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 909.0000 | 73.0000 | 12.4521 | 504.3967 ± 11.9847 | 506.4764 ± 12.7673 | 0.9959 | 2.38% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 12.7203 |
| Geometric mean runtime ratio (L0/GCC) | 0.9757 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
