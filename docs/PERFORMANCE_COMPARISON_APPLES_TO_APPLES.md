# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-11T04:51:13Z`
- host: `runnervm3jyl0`
- kernel: `Linux 6.17.0-1015-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 689.0000 | 61.0000 | 11.2951 | 304.3673 ± 1.6457 | 305.5290 ± 0.7075 | 0.9962 | 0.54% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 683.0000 | 62.0000 | 11.0161 | 304.3531 ± 1.7143 | 307.9667 ± 2.8219 | 0.9883 | 0.56% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 672.0000 | 59.0000 | 11.3898 | 301.1108 ± 0.5281 | 310.7350 ± 1.1259 | 0.9690 | 0.18% | ok |
| and (2-arg) | `tests/valid_and.l0` | 677.0000 | 61.0000 | 11.0984 | 303.6528 ± 1.4887 | 305.7538 ± 1.2951 | 0.9931 | 0.49% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 689.0000 | 61.0000 | 11.2951 | 302.3554 ± 0.5730 | 304.3104 ± 3.2881 | 0.9936 | 0.19% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 683.0000 | 64.0000 | 10.6719 | 313.0761 ± 0.1200 | 305.1138 ± 0.8141 | 1.0261 | 0.04% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 695.0000 | 67.0000 | 10.3731 | 306.5408 ± 0.9152 | 305.5243 ± 0.1526 | 1.0033 | 0.30% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 695.0000 | 65.0000 | 10.6923 | 306.6612 ± 0.9082 | 305.7921 ± 0.6407 | 1.0028 | 0.30% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 677.0000 | 62.0000 | 10.9194 | 311.8364 ± 0.4466 | 312.2702 ± 0.3301 | 0.9986 | 0.14% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.9676 |
| Geometric mean runtime ratio (L0/GCC) | 0.9967 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
