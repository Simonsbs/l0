# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-03T09:05:36Z`
- host: `runnervm8df0l`
- kernel: `Linux 6.17.0-1022-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 930.0000 | 76.0000 | 12.2368 | 372.2933 ± 1.1910 | 374.1834 ± 1.7793 | 0.9949 | 0.32% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 919.0000 | 77.0000 | 11.9351 | 369.4622 ± 3.5817 | 453.9090 ± 25.3947 | 0.8140 | 0.97% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 919.0000 | 75.0000 | 12.2533 | 454.7757 ± 2.0525 | 457.5028 ± 17.9639 | 0.9940 | 0.45% | ok |
| and (2-arg) | `tests/valid_and.l0` | 909.0000 | 76.0000 | 11.9605 | 371.8467 ± 2.7173 | 400.9618 ± 26.0816 | 0.9274 | 0.73% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 919.0000 | 78.0000 | 11.7821 | 376.7239 ± 7.6223 | 409.5289 ± 10.9899 | 0.9199 | 2.02% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 930.0000 | 79.0000 | 11.7722 | 465.6728 ± 2.3074 | 378.2267 ± 3.3240 | 1.2312 | 0.50% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 930.0000 | 77.0000 | 12.0779 | 366.9839 ± 3.6469 | 377.0657 ± 5.0634 | 0.9733 | 0.99% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 909.0000 | 74.0000 | 12.2838 | 366.0554 ± 1.6667 | 371.5779 ± 2.4558 | 0.9851 | 0.46% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 909.0000 | 73.0000 | 12.4521 | 492.5666 ± 1.7606 | 497.0669 ± 8.9642 | 0.9909 | 0.36% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 12.0817 |
| Geometric mean runtime ratio (L0/GCC) | 0.9760 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
