# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-26T08:32:37Z`
- host: `runnervmtr4k5`
- kernel: `Linux 6.17.0-1022-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `AMD EPYC 7763 64-Core Processor`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 689.0000 | 69.0000 | 9.9855 | 422.7543 ± 0.9195 | 423.0199 ± 1.6538 | 0.9994 | 0.22% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 689.0000 | 70.0000 | 9.8429 | 423.7725 ± 0.7081 | 425.6751 ± 0.6835 | 0.9955 | 0.17% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 701.0000 | 70.0000 | 10.0143 | 423.2674 ± 0.7036 | 423.5427 ± 0.2734 | 0.9994 | 0.17% | ok |
| and (2-arg) | `tests/valid_and.l0` | 695.0000 | 69.0000 | 10.0725 | 422.9008 ± 2.5539 | 422.2699 ± 1.5018 | 1.0015 | 0.60% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 683.0000 | 69.0000 | 9.8986 | 423.8920 ± 0.6292 | 422.8092 ± 1.7143 | 1.0026 | 0.15% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 683.0000 | 70.0000 | 9.7571 | 423.7265 ± 0.4901 | 423.2032 ± 1.5213 | 1.0012 | 0.12% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 689.0000 | 71.0000 | 9.7042 | 423.2124 ± 0.9105 | 423.2766 ± 1.4698 | 0.9998 | 0.22% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 689.0000 | 70.0000 | 9.8429 | 425.2025 ± 1.4190 | 424.5647 ± 0.8283 | 1.0015 | 0.33% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 695.0000 | 68.0000 | 10.2206 | 423.5336 ± 1.6614 | 424.0853 ± 1.0840 | 0.9987 | 0.39% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 9.9253 |
| Geometric mean runtime ratio (L0/GCC) | 1.0000 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
