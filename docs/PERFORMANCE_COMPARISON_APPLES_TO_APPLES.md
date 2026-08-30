# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-30T09:10:59Z`
- host: `runnervmgx7h7`
- kernel: `Linux 6.17.0-1022-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 695.0000 | 59.0000 | 11.7797 | 302.7491 ± 0.3778 | 303.0403 ± 0.7299 | 0.9990 | 0.12% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 677.0000 | 59.0000 | 11.4746 | 300.9298 ± 0.2744 | 302.6224 ± 1.1089 | 0.9944 | 0.09% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 683.0000 | 59.0000 | 11.5763 | 301.6316 ± 1.7224 | 310.0592 ± 0.8334 | 0.9728 | 0.57% | ok |
| and (2-arg) | `tests/valid_and.l0` | 672.0000 | 60.0000 | 11.2000 | 302.5708 ± 1.6538 | 304.2677 ± 0.6038 | 0.9944 | 0.55% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 666.0000 | 60.0000 | 11.1000 | 302.3367 ± 0.7334 | 304.1161 ± 0.3713 | 0.9941 | 0.24% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 683.0000 | 61.0000 | 11.1967 | 308.5993 ± 1.0677 | 303.2662 ± 0.6137 | 1.0176 | 0.35% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 677.0000 | 61.0000 | 11.0984 | 304.9042 ± 0.1132 | 303.9221 ± 0.7225 | 1.0032 | 0.04% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 672.0000 | 60.0000 | 11.2000 | 301.5199 ± 1.0357 | 303.4688 ± 2.0930 | 0.9936 | 0.34% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 661.0000 | 59.0000 | 11.2034 | 311.7817 ± 0.9307 | 311.1558 ± 2.3674 | 1.0020 | 0.30% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.3121 |
| Geometric mean runtime ratio (L0/GCC) | 0.9967 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
