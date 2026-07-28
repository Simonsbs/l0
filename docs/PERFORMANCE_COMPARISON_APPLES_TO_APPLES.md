# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-28T06:01:28Z`
- host: `runnervmvrwv9`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 689.0000 | 65.0000 | 10.6000 | 304.5619 ± 0.5472 | 305.0233 ± 0.6570 | 0.9985 | 0.18% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 695.0000 | 66.0000 | 10.5303 | 304.6664 ± 0.4195 | 307.9667 ± 1.9315 | 0.9893 | 0.14% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 677.0000 | 65.0000 | 10.4154 | 303.8795 ± 0.7745 | 315.0659 ± 1.3770 | 0.9645 | 0.25% | ok |
| and (2-arg) | `tests/valid_and.l0` | 683.0000 | 65.0000 | 10.5077 | 305.1376 ± 0.4975 | 306.5842 ± 1.1112 | 0.9953 | 0.16% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 672.0000 | 65.0000 | 10.3385 | 304.6379 ± 0.4485 | 306.5986 ± 1.8608 | 0.9936 | 0.15% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 672.0000 | 66.0000 | 10.1818 | 311.5032 ± 1.6744 | 305.7778 ± 0.9209 | 1.0187 | 0.54% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 689.0000 | 67.0000 | 10.2836 | 304.4812 ± 1.2138 | 305.1424 ± 0.5785 | 0.9978 | 0.40% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 677.0000 | 65.0000 | 10.4154 | 313.4277 ± 6.6872 | 304.1209 ± 0.8188 | 1.0306 | 2.13% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 683.0000 | 64.0000 | 10.6719 | 316.8189 ± 2.2564 | 316.7521 ± 1.8697 | 1.0002 | 0.71% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4373 |
| Geometric mean runtime ratio (L0/GCC) | 0.9986 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
