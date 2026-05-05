# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-05T04:21:29Z`
- host: `runnervmeorf1`
- kernel: `Linux 6.17.0-1010-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 776.0000 | 70.0000 | 11.0857 | 426.7913 ± 3.8033 | 424.2880 ± 0.4073 | 1.0059 | 0.89% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 754.0000 | 70.0000 | 10.7714 | 423.7541 ± 0.4966 | 424.4540 ± 1.3560 | 0.9984 | 0.12% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 754.0000 | 69.0000 | 10.9275 | 424.6201 ± 0.1626 | 423.3683 ± 2.2997 | 1.0030 | 0.04% | ok |
| and (2-arg) | `tests/valid_and.l0` | 761.0000 | 68.0000 | 11.1912 | 422.6994 ± 1.2912 | 423.6438 ± 0.9126 | 0.9978 | 0.31% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 754.0000 | 70.0000 | 10.7714 | 424.1222 ± 0.3439 | 425.4525 ± 0.2486 | 0.9969 | 0.08% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 747.0000 | 72.0000 | 10.3750 | 422.9374 ± 2.8695 | 424.1314 ± 0.7531 | 0.9972 | 0.68% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 720.0000 | 71.0000 | 10.1408 | 428.8624 ± 1.6597 | 428.1573 ± 0.5321 | 1.0016 | 0.39% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 747.0000 | 69.0000 | 10.8261 | 425.4711 ± 0.9826 | 425.5545 ± 0.9569 | 0.9998 | 0.23% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 747.0000 | 68.0000 | 10.9853 | 425.5545 ± 0.7222 | 425.9722 ± 0.8259 | 0.9990 | 0.17% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.7813 |
| Geometric mean runtime ratio (L0/GCC) | 1.0000 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
