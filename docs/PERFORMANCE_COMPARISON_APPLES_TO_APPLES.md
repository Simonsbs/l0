# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-12T07:53:00Z`
- host: `runnervmlun5p`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 941.0000 | 71.0000 | 13.2535 | 365.0019 ± 1.2354 | 369.9451 ± 1.6896 | 0.9866 | 0.34% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 930.0000 | 73.0000 | 12.7397 | 364.7020 ± 2.3488 | 420.1715 ± 13.6023 | 0.8680 | 0.64% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 952.0000 | 73.0000 | 13.0411 | 449.8319 ± 2.8363 | 453.0246 ± 8.2547 | 0.9930 | 0.63% | ok |
| and (2-arg) | `tests/valid_and.l0` | 941.0000 | 72.0000 | 13.0694 | 382.5981 ± 4.9172 | 396.7186 ± 6.3857 | 0.9644 | 1.29% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 952.0000 | 73.0000 | 13.0411 | 366.8943 ± 1.8797 | 435.5279 ± 16.9899 | 0.8424 | 0.51% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 952.0000 | 76.0000 | 12.5263 | 417.2809 ± 28.1332 | 367.7509 ± 7.0516 | 1.1347 | 6.74% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 941.0000 | 73.0000 | 12.8904 | 367.9310 ± 5.5189 | 366.6463 ± 1.1155 | 1.0035 | 1.50% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 941.0000 | 73.0000 | 12.8904 | 367.4810 ± 3.4555 | 368.7368 ± 1.1203 | 0.9966 | 0.94% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 919.0000 | 69.0000 | 13.3188 | 476.8022 ± 10.7878 | 489.0882 ± 23.8497 | 0.9749 | 2.26% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 12.9724 |
| Geometric mean runtime ratio (L0/GCC) | 0.9706 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
