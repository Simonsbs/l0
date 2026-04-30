# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-30T04:25:41Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 695.0000 | 65.0000 | 10.6923 | 306.0653 ± 1.0471 | 304.9804 ± 0.8270 | 1.0036 | 0.34% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 727.0000 | 65.0000 | 11.1846 | 306.2717 ± 0.8916 | 307.8648 ± 1.1162 | 0.9948 | 0.29% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 707.0000 | 64.0000 | 11.0469 | 304.8043 ± 0.4264 | 315.2846 ± 2.7072 | 0.9668 | 0.14% | ok |
| and (2-arg) | `tests/valid_and.l0` | 689.0000 | 63.0000 | 10.9365 | 304.3436 ± 6.5272 | 305.0661 ± 4.5579 | 0.9976 | 2.14% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 695.0000 | 64.0000 | 10.8594 | 305.8304 ± 0.8151 | 307.0517 ± 1.9360 | 0.9960 | 0.27% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 689.0000 | 64.0000 | 10.7656 | 311.7518 ± 0.9970 | 304.1303 ± 1.0078 | 1.0251 | 0.32% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 695.0000 | 64.0000 | 10.8594 | 303.9126 ± 1.2820 | 303.6575 ± 0.4598 | 1.0008 | 0.42% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 714.0000 | 63.0000 | 11.3333 | 304.5619 ± 0.6674 | 305.3284 ± 0.4112 | 0.9975 | 0.22% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 683.0000 | 63.0000 | 10.8413 | 313.8710 ± 0.1902 | 314.7156 ± 1.2414 | 0.9973 | 0.06% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.9449 |
| Geometric mean runtime ratio (L0/GCC) | 0.9976 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
