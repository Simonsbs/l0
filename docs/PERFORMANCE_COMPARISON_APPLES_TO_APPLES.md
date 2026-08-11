# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-11T04:37:48Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 695.0000 | 66.0000 | 10.5303 | 304.4764 ± 1.0247 | 304.7472 ± 1.0732 | 0.9991 | 0.34% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 689.0000 | 66.0000 | 10.4394 | 305.4526 ± 1.8921 | 307.7047 ± 1.2673 | 0.9927 | 0.62% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 683.0000 | 65.0000 | 10.5077 | 302.5146 ± 1.7128 | 312.0806 ± 1.9712 | 0.9693 | 0.57% | ok |
| and (2-arg) | `tests/valid_and.l0` | 683.0000 | 65.0000 | 10.5077 | 305.1996 ± 1.3818 | 305.9119 ± 2.1656 | 0.9977 | 0.45% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 683.0000 | 65.0000 | 10.5077 | 304.1966 ± 0.4677 | 305.9982 ± 2.8245 | 0.9941 | 0.15% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 677.0000 | 66.0000 | 10.2576 | 312.7001 ± 1.1896 | 304.7044 ± 0.8659 | 1.0262 | 0.38% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 683.0000 | 66.0000 | 10.3485 | 305.0280 ± 1.6541 | 304.8995 ± 1.0488 | 1.0004 | 0.54% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 677.0000 | 65.0000 | 10.4154 | 303.1391 ± 1.4811 | 305.4144 ± 1.4004 | 0.9926 | 0.49% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 666.0000 | 64.0000 | 10.4062 | 312.9105 ± 1.3146 | 313.1413 ± 2.1887 | 0.9993 | 0.42% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4353 |
| Geometric mean runtime ratio (L0/GCC) | 0.9967 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
