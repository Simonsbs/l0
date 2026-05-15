# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-15T04:36:31Z`
- host: `runnervmeorf1`
- kernel: `Linux 6.17.0-1010-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 689.0000 | 66.0000 | 10.4394 | 305.2998 ± 0.7568 | 305.2426 ± 0.4405 | 1.0002 | 0.25% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 701.0000 | 67.0000 | 10.4627 | 305.2187 ± 0.2092 | 309.5972 ± 0.6397 | 0.9859 | 0.07% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 695.0000 | 66.0000 | 10.5303 | 306.1996 ± 0.1684 | 312.9256 ± 2.5585 | 0.9785 | 0.05% | ok |
| and (2-arg) | `tests/valid_and.l0` | 689.0000 | 66.0000 | 10.4394 | 305.3094 ± 0.5149 | 307.8454 ± 1.3373 | 0.9918 | 0.17% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 695.0000 | 66.0000 | 10.5303 | 305.7491 ± 0.0963 | 308.2924 ± 0.8852 | 0.9918 | 0.03% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 677.0000 | 67.0000 | 10.1045 | 313.7651 ± 0.8598 | 305.4335 ± 0.2812 | 1.0273 | 0.27% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 683.0000 | 67.0000 | 10.1940 | 303.9126 ± 0.5158 | 305.1329 ± 0.2434 | 0.9960 | 0.17% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 701.0000 | 66.0000 | 10.6212 | 305.5147 ± 0.3641 | 306.1037 ± 0.3446 | 0.9981 | 0.12% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 689.0000 | 65.0000 | 10.6000 | 314.9846 ± 1.6933 | 315.1015 ± 1.6905 | 0.9996 | 0.54% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4344 |
| Geometric mean runtime ratio (L0/GCC) | 0.9965 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
