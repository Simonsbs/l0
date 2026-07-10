# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-10T06:53:08Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 695.0000 | 65.0000 | 10.6923 | 304.2725 ± 0.4753 | 304.7282 ± 0.4947 | 0.9985 | 0.16% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 695.0000 | 66.0000 | 10.5303 | 307.2642 ± 1.6084 | 309.8723 ± 0.5789 | 0.9916 | 0.52% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 701.0000 | 65.0000 | 10.7846 | 305.2330 ± 0.3678 | 312.6451 ± 2.0978 | 0.9763 | 0.12% | ok |
| and (2-arg) | `tests/valid_and.l0` | 689.0000 | 65.0000 | 10.6000 | 303.9552 ± 0.6890 | 307.9570 ± 1.7145 | 0.9870 | 0.23% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 677.0000 | 65.0000 | 10.4154 | 304.4669 ± 1.1634 | 307.9133 ± 0.3909 | 0.9888 | 0.38% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 683.0000 | 66.0000 | 10.3485 | 313.3222 ± 0.9089 | 304.6949 ± 0.1489 | 1.0283 | 0.29% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 677.0000 | 65.0000 | 10.4154 | 306.0029 ± 0.4128 | 305.3380 ± 0.2286 | 1.0022 | 0.13% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 689.0000 | 65.0000 | 10.6000 | 305.1996 ± 0.5258 | 304.4432 ± 0.3698 | 1.0025 | 0.17% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 677.0000 | 63.0000 | 10.7460 | 313.9164 ± 0.5993 | 315.0964 ± 0.7665 | 0.9963 | 0.19% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5693 |
| Geometric mean runtime ratio (L0/GCC) | 0.9967 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
