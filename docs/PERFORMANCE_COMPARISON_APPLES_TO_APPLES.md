# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-23T04:29:03Z`
- host: `runnervmg397c`
- kernel: `Linux 6.17.0-1013-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 1000.0000 | 75.0000 | 13.3333 | 369.8540 ± 1.8899 | 373.2609 ± 2.4374 | 0.9909 | 0.51% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 975.0000 | 75.0000 | 13.0000 | 373.8038 ± 3.4789 | 470.2133 ± 16.5861 | 0.7950 | 0.93% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 975.0000 | 74.0000 | 13.1757 | 453.9512 ± 5.6651 | 450.8599 ± 7.7403 | 1.0069 | 1.25% | ok |
| and (2-arg) | `tests/valid_and.l0` | 975.0000 | 76.0000 | 12.8289 | 387.6863 ± 3.0009 | 463.8701 ± 29.1983 | 0.8358 | 0.77% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 1000.0000 | 77.0000 | 12.9870 | 374.1834 ± 2.5540 | 474.5778 ± 29.1041 | 0.7885 | 0.68% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 975.0000 | 82.0000 | 11.8902 | 439.2895 ± 21.3516 | 379.1739 ± 6.1011 | 1.1585 | 4.86% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 987.0000 | 82.0000 | 12.0366 | 372.0380 ± 1.1304 | 378.3220 ± 2.8159 | 0.9834 | 0.30% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 987.0000 | 80.0000 | 12.3375 | 390.8126 ± 12.1884 | 392.9197 ± 13.7123 | 0.9946 | 3.12% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 963.0000 | 73.0000 | 13.1918 | 482.3007 ± 10.9768 | 504.3837 ± 6.8092 | 0.9562 | 2.28% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 12.7434 |
| Geometric mean runtime ratio (L0/GCC) | 0.9388 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
