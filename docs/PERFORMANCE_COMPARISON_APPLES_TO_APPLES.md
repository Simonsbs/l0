# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-24T06:02:30Z`
- host: `runnervm3jd5f`
- kernel: `Linux 6.17.0-1020-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `AMD EPYC 9V74 80-Core Processor`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 689.0000 | 63.0000 | 10.9365 | 303.8370 ± 0.4602 | 303.8417 ± 1.1221 | 1.0000 | 0.15% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 672.0000 | 61.0000 | 11.0164 | 303.8748 ± 1.2331 | 306.3341 ± 0.8699 | 0.9920 | 0.41% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 683.0000 | 64.0000 | 10.6719 | 303.5725 ± 0.5780 | 312.9456 ± 1.1017 | 0.9700 | 0.19% | ok |
| and (2-arg) | `tests/valid_and.l0` | 677.0000 | 63.0000 | 10.7460 | 305.2855 ± 0.5716 | 307.1627 ± 0.6350 | 0.9939 | 0.19% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 672.0000 | 63.0000 | 10.6667 | 305.0233 ± 0.4604 | 307.5400 ± 0.4725 | 0.9918 | 0.15% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 672.0000 | 64.0000 | 10.5000 | 312.4000 ± 0.4819 | 303.3085 ± 0.5125 | 1.0300 | 0.15% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 666.0000 | 65.0000 | 10.2462 | 302.5943 ± 1.0032 | 302.4022 ± 0.2440 | 1.0006 | 0.33% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 661.0000 | 59.0000 | 11.2034 | 302.0047 ± 0.3073 | 302.2758 ± 0.4350 | 0.9991 | 0.10% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 655.0000 | 59.0000 | 11.1017 | 311.1013 ± 2.1240 | 311.4833 ± 0.7429 | 0.9988 | 0.68% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.7837 |
| Geometric mean runtime ratio (L0/GCC) | 0.9972 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
