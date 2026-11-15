# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-15T10:46:33Z`
- host: `runnervmccnms`
- kernel: `Linux 7.0.0-1019-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 672.0000 | 59.0000 | 11.3898 | 356.4422 ± 0.9046 | 356.3316 ± 0.2703 | 1.0003 | 0.25% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 655.0000 | 59.0000 | 11.1017 | 354.1863 ± 0.2655 | 355.7151 ± 0.7566 | 0.9957 | 0.07% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 655.0000 | 59.0000 | 11.1017 | 354.0515 ± 1.8682 | 354.1028 ± 1.0839 | 0.9999 | 0.53% | ok |
| and (2-arg) | `tests/valid_and.l0` | 655.0000 | 59.0000 | 11.1017 | 356.2407 ± 1.5407 | 357.1200 ± 0.8688 | 0.9975 | 0.43% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 645.0000 | 59.0000 | 10.9322 | 349.8719 ± 1.3868 | 349.5964 ± 1.5069 | 1.0008 | 0.40% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 650.0000 | 59.0000 | 11.0169 | 349.7090 ± 4.3202 | 352.1047 ± 1.8292 | 0.9932 | 1.24% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 645.0000 | 59.0000 | 10.9322 | 354.5078 ± 0.4967 | 354.9200 ± 0.3145 | 0.9988 | 0.14% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 645.0000 | 58.0000 | 11.1207 | 354.7847 ± 0.4753 | 355.5856 ± 1.9754 | 0.9977 | 0.13% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 645.0000 | 58.0000 | 11.1207 | 280.5287 ± 2.4220 | 342.8400 ± 30.8926 | 0.8182 | 0.86% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.0901 |
| Geometric mean runtime ratio (L0/GCC) | 0.9762 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
