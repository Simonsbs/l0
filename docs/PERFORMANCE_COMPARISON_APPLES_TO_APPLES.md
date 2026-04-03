# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-03T04:08:39Z`
- host: `runnervmrg6be`
- kernel: `Linux 6.17.0-1008-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 769.0000 | 71.0000 | 10.8310 | 423.9749 ± 0.7187 | 424.7863 ± 0.4548 | 0.9981 | 0.17% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 733.0000 | 68.0000 | 10.7794 | 424.2972 ± 0.8679 | 425.1377 ± 1.5480 | 0.9980 | 0.20% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 70.0000 | 10.6714 | 423.6254 ± 0.8002 | 425.2025 ± 0.6545 | 0.9963 | 0.19% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 71.0000 | 10.4225 | 423.5887 ± 1.0016 | 424.3157 ± 0.4978 | 0.9983 | 0.24% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 733.0000 | 70.0000 | 10.4714 | 423.9473 ± 1.7268 | 422.6811 ± 0.5695 | 1.0030 | 0.41% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 740.0000 | 70.0000 | 10.5714 | 422.8916 ± 1.1323 | 422.3247 ± 0.5613 | 1.0013 | 0.27% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 740.0000 | 69.0000 | 10.7246 | 422.0418 ± 1.1868 | 421.4862 ± 0.6450 | 1.0013 | 0.28% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 733.0000 | 66.0000 | 11.1061 | 415.4613 ± 2.1907 | 416.0099 ± 1.0685 | 0.9987 | 0.53% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 720.0000 | 63.0000 | 11.4286 | 426.5024 ± 0.8082 | 424.5555 ± 1.6705 | 1.0046 | 0.19% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.7744 |
| Geometric mean runtime ratio (L0/GCC) | 1.0000 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
