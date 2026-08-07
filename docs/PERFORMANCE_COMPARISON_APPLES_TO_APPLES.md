# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-07T05:00:47Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 701.0000 | 65.0000 | 10.7846 | 305.8783 ± 1.1347 | 305.0804 ± 0.5362 | 1.0026 | 0.37% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 677.0000 | 65.0000 | 10.4154 | 304.8043 ± 0.3526 | 307.6950 ± 1.1828 | 0.9906 | 0.12% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 683.0000 | 65.0000 | 10.5077 | 303.5678 ± 0.2458 | 313.4177 ± 2.3632 | 0.9686 | 0.08% | ok |
| and (2-arg) | `tests/valid_and.l0` | 683.0000 | 65.0000 | 10.5077 | 304.7710 ± 0.6617 | 305.4765 ± 0.2594 | 0.9977 | 0.22% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 677.0000 | 65.0000 | 10.4154 | 304.6046 ± 0.9420 | 307.1386 ± 0.4620 | 0.9917 | 0.31% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 677.0000 | 66.0000 | 10.2576 | 311.6125 ± 1.6878 | 304.3057 ± 0.2188 | 1.0240 | 0.54% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 677.0000 | 66.0000 | 10.2576 | 305.0566 ± 0.4567 | 304.5571 ± 0.3193 | 1.0016 | 0.15% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 689.0000 | 65.0000 | 10.6000 | 305.1329 ± 0.3770 | 304.9233 ± 0.0862 | 1.0007 | 0.12% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 677.0000 | 63.0000 | 10.7460 | 312.9506 ± 0.7340 | 314.9237 ± 1.4407 | 0.9937 | 0.23% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4976 |
| Geometric mean runtime ratio (L0/GCC) | 0.9967 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
