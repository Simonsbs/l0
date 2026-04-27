# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-27T04:25:05Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 701.0000 | 66.0000 | 10.6212 | 306.1612 ± 0.7712 | 306.0845 ± 0.3489 | 1.0003 | 0.25% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 689.0000 | 66.0000 | 10.4394 | 303.1814 ± 3.1367 | 298.7892 ± 5.7042 | 1.0147 | 1.03% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 683.0000 | 66.0000 | 10.3485 | 305.7012 ± 0.0722 | 315.1472 ± 1.6000 | 0.9700 | 0.02% | ok |
| and (2-arg) | `tests/valid_and.l0` | 689.0000 | 66.0000 | 10.4394 | 305.6773 ± 0.3719 | 307.5836 ± 0.9067 | 0.9938 | 0.12% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 695.0000 | 66.0000 | 10.5303 | 306.9889 ± 0.3395 | 308.6042 ± 0.8621 | 0.9948 | 0.11% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 695.0000 | 67.0000 | 10.3731 | 312.9858 ± 0.6149 | 305.5625 ± 0.1974 | 1.0243 | 0.20% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 701.0000 | 67.0000 | 10.4627 | 306.3918 ± 0.7909 | 304.7425 ± 0.1896 | 1.0054 | 0.26% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 707.0000 | 67.0000 | 10.5522 | 306.9359 ± 0.2485 | 306.8105 ± 0.6014 | 1.0004 | 0.08% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 689.0000 | 65.0000 | 10.6000 | 314.0628 ± 0.2459 | 315.3508 ± 1.8298 | 0.9959 | 0.08% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4848 |
| Geometric mean runtime ratio (L0/GCC) | 0.9999 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
