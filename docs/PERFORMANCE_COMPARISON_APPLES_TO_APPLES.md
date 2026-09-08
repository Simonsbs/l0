# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-08T08:01:54Z`
- host: `runnervmejwal`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 689.0000 | 63.0000 | 10.9365 | 304.4005 ± 0.5373 | 305.2807 ± 0.6116 | 0.9971 | 0.18% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 677.0000 | 64.0000 | 10.5781 | 305.7874 ± 0.3497 | 307.7726 ± 0.3808 | 0.9935 | 0.11% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 677.0000 | 64.0000 | 10.5781 | 305.6438 ± 0.1418 | 313.6945 ± 1.2956 | 0.9743 | 0.05% | ok |
| and (2-arg) | `tests/valid_and.l0` | 695.0000 | 64.0000 | 10.8594 | 305.8017 ± 0.7159 | 307.2304 ± 2.7267 | 0.9953 | 0.23% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 677.0000 | 63.0000 | 10.7460 | 304.2061 ± 1.4786 | 306.0077 ± 0.9630 | 0.9941 | 0.49% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 677.0000 | 63.0000 | 10.7460 | 311.6274 ± 1.0506 | 304.5951 ± 0.5161 | 1.0231 | 0.34% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 677.0000 | 63.0000 | 10.7460 | 302.2852 ± 1.6523 | 302.5427 ± 0.0883 | 0.9991 | 0.55% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 677.0000 | 62.0000 | 10.9194 | 303.9410 ± 0.1341 | 303.4075 ± 0.5245 | 1.0018 | 0.04% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 672.0000 | 60.0000 | 11.2000 | 313.1915 ± 0.9161 | 311.3592 ± 0.6840 | 1.0059 | 0.29% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.8106 |
| Geometric mean runtime ratio (L0/GCC) | 0.9982 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
