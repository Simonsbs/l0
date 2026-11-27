# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-27T12:08:42Z`
- host: `runnervm0hi8g`
- kernel: `Linux 7.0.0-1020-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 824.0000 | 64.0000 | 12.8750 | 349.3213 ± 2.5170 | 345.9001 ± 3.0964 | 1.0099 | 0.72% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 683.0000 | 61.0000 | 11.1967 | 351.4838 ± 2.0476 | 350.6445 ± 0.9602 | 1.0024 | 0.58% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 707.0000 | 63.0000 | 11.2222 | 343.9024 ± 1.5042 | 345.6308 ± 3.2683 | 0.9950 | 0.44% | ok |
| and (2-arg) | `tests/valid_and.l0` | 769.0000 | 57.0000 | 13.4912 | 349.1277 ± 3.4457 | 346.7660 ± 3.7589 | 1.0068 | 0.99% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 683.0000 | 61.0000 | 11.1967 | 371.9813 ± 6.9369 | 371.5991 ± 3.3407 | 1.0010 | 1.86% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 672.0000 | 64.0000 | 10.5000 | 356.2601 ± 4.2144 | 353.3405 ± 0.3549 | 1.0083 | 1.18% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 695.0000 | 66.0000 | 10.5303 | 362.5559 ± 5.3176 | 366.6257 ± 6.3102 | 0.9889 | 1.47% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 695.0000 | 61.0000 | 11.3934 | 347.5373 ± 3.2825 | 345.8572 ± 2.2015 | 1.0049 | 0.94% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 784.0000 | 63.0000 | 12.4444 | 343.4428 ± 1.1965 | 345.4474 ± 1.6920 | 0.9942 | 0.35% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.6095 |
| Geometric mean runtime ratio (L0/GCC) | 1.0012 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
