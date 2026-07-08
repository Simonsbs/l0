# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-08T06:05:29Z`
- host: `runnervm5mmn9`
- kernel: `Linux 6.17.0-1018-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 683.0000 | 65.0000 | 10.5077 | 305.2616 ± 2.8831 | 305.3237 ± 0.7508 | 0.9998 | 0.94% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 683.0000 | 65.0000 | 10.5077 | 305.7778 ± 0.1608 | 307.8114 ± 1.4437 | 0.9934 | 0.05% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 672.0000 | 65.0000 | 10.3385 | 302.7491 ± 0.8594 | 310.7054 ± 0.2857 | 0.9744 | 0.28% | ok |
| and (2-arg) | `tests/valid_and.l0` | 666.0000 | 65.0000 | 10.2462 | 303.6103 ± 0.5048 | 305.7682 ± 0.5936 | 0.9929 | 0.17% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 672.0000 | 64.0000 | 10.5000 | 303.6339 ± 0.6239 | 306.1660 ± 0.5204 | 0.9917 | 0.21% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 683.0000 | 65.0000 | 10.5077 | 311.7020 ± 2.1852 | 303.5112 ± 0.2917 | 1.0270 | 0.70% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 683.0000 | 64.0000 | 10.6719 | 303.8512 ± 1.2770 | 304.2109 ± 0.2500 | 0.9988 | 0.42% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 683.0000 | 65.0000 | 10.5077 | 304.6379 ± 0.9654 | 304.6712 ± 0.0947 | 0.9999 | 0.32% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 661.0000 | 60.0000 | 11.0167 | 312.2901 ± 0.7731 | 312.5100 ± 1.0229 | 0.9993 | 0.25% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5318 |
| Geometric mean runtime ratio (L0/GCC) | 0.9974 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
