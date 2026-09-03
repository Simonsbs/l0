# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-03T07:59:55Z`
- host: `runnervmgx7h7`
- kernel: `Linux 6.17.0-1022-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `AMD EPYC 7763 64-Core Processor`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 720.0000 | 67.0000 | 10.7463 | 422.9099 ± 0.9432 | 422.8550 ± 1.3209 | 1.0001 | 0.22% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 720.0000 | 66.0000 | 10.9091 | 423.5060 ± 0.8708 | 422.9466 ± 0.8500 | 1.0013 | 0.21% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 720.0000 | 67.0000 | 10.7463 | 418.7930 ± 1.3826 | 421.1045 ± 0.8836 | 0.9945 | 0.33% | ok |
| and (2-arg) | `tests/valid_and.l0` | 720.0000 | 67.0000 | 10.7463 | 418.9817 ± 1.4536 | 420.6964 ± 1.0076 | 0.9959 | 0.35% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 720.0000 | 67.0000 | 10.7463 | 420.6601 ± 2.1634 | 419.4045 ± 0.6499 | 1.0030 | 0.51% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 727.0000 | 68.0000 | 10.6912 | 421.6682 ± 1.2171 | 421.3862 ± 0.6865 | 1.0007 | 0.29% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 727.0000 | 68.0000 | 10.6912 | 421.3498 ± 0.6679 | 421.2862 ± 0.9658 | 1.0002 | 0.16% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 701.0000 | 67.0000 | 10.4627 | 414.8436 ± 3.4233 | 417.9953 ± 2.2952 | 0.9925 | 0.83% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 707.0000 | 63.0000 | 11.2222 | 420.9140 ± 3.6409 | 422.1604 ± 6.1229 | 0.9970 | 0.86% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.7718 |
| Geometric mean runtime ratio (L0/GCC) | 0.9984 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
