# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-15T04:52:17Z`
- host: `runnervm1li68`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 1025.0000 | 80.0000 | 12.8125 | 374.5924 ± 3.9657 | 374.5781 ± 9.5437 | 1.0000 | 1.06% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 1012.0000 | 81.0000 | 12.4938 | 376.2377 ± 1.0820 | 408.1851 ± 8.2138 | 0.9217 | 0.29% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 1012.0000 | 79.0000 | 12.8101 | 451.1619 ± 3.6886 | 453.4348 ± 14.7181 | 0.9950 | 0.82% | ok |
| and (2-arg) | `tests/valid_and.l0` | 1000.0000 | 77.0000 | 12.9870 | 369.3714 ± 13.0119 | 454.0356 ± 46.4646 | 0.8135 | 3.52% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 987.0000 | 79.0000 | 12.4937 | 371.1684 ± 3.8720 | 489.4559 ± 18.8863 | 0.7583 | 1.04% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 987.0000 | 80.0000 | 12.3375 | 401.4976 ± 19.7093 | 367.5917 ± 3.9256 | 1.0922 | 4.91% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 1012.0000 | 81.0000 | 12.4938 | 371.0203 ± 1.6979 | 389.5576 ± 3.9055 | 0.9524 | 0.46% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 1012.0000 | 81.0000 | 12.4938 | 370.4222 ± 0.7914 | 374.0974 ± 6.6610 | 0.9902 | 0.21% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 987.0000 | 78.0000 | 12.6538 | 489.4437 ± 2.2299 | 507.8724 ± 17.8788 | 0.9637 | 0.46% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 12.6180 |
| Geometric mean runtime ratio (L0/GCC) | 0.9379 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
