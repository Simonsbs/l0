# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-26T04:42:51Z`
- host: `runnervmmklqx`
- kernel: `Linux 6.17.0-1018-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 1038.0000 | 86.0000 | 12.0698 | 391.5098 ± 9.9376 | 391.7454 ± 17.5460 | 0.9994 | 2.54% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 1000.0000 | 84.0000 | 11.9048 | 381.1943 ± 0.5812 | 482.1102 ± 7.1794 | 0.7907 | 0.15% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 1025.0000 | 84.0000 | 12.2024 | 463.2869 ± 1.3096 | 464.6536 ± 9.0503 | 0.9971 | 0.28% | ok |
| and (2-arg) | `tests/valid_and.l0` | 1000.0000 | 82.0000 | 12.1951 | 364.4094 ± 1.6261 | 477.6418 ± 38.8797 | 0.7629 | 0.45% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 975.0000 | 76.0000 | 12.8289 | 377.5979 ± 3.3109 | 452.3322 ± 15.5105 | 0.8348 | 0.88% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 987.0000 | 80.0000 | 12.3375 | 401.3326 ± 10.0740 | 385.5207 ± 14.8235 | 1.0410 | 2.51% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 930.0000 | 75.0000 | 12.4000 | 357.4206 ± 1.8127 | 364.1716 ± 1.1434 | 0.9815 | 0.51% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 941.0000 | 74.0000 | 12.7162 | 371.3871 ± 21.3904 | 370.2536 ± 2.6959 | 1.0031 | 5.76% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 888.0000 | 69.0000 | 12.8696 | 491.2657 ± 15.2622 | 499.6355 ± 19.0424 | 0.9832 | 3.11% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 12.3874 |
| Geometric mean runtime ratio (L0/GCC) | 0.9270 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
