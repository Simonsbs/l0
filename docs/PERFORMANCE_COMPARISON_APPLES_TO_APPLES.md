# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-09T04:34:29Z`
- host: `runnervmvrwv9`
- kernel: `Linux 6.17.0-1020-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 754.0000 | 70.0000 | 10.7714 | 427.5387 ± 0.9239 | 425.9536 ± 2.2757 | 1.0037 | 0.22% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 733.0000 | 70.0000 | 10.4714 | 423.2949 ± 1.7022 | 421.6682 ± 2.3092 | 1.0039 | 0.40% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 740.0000 | 70.0000 | 10.5714 | 424.1222 ± 0.7438 | 424.6939 ± 1.7737 | 0.9987 | 0.18% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 69.0000 | 10.7246 | 425.1562 ± 1.2921 | 425.9629 ± 1.8738 | 0.9981 | 0.30% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 740.0000 | 68.0000 | 10.8824 | 419.5757 ± 3.5684 | 421.9415 ± 1.6870 | 0.9944 | 0.85% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 740.0000 | 69.0000 | 10.7246 | 423.8736 ± 0.6034 | 424.2696 ± 3.9620 | 0.9991 | 0.14% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 740.0000 | 66.0000 | 11.2121 | 418.5417 ± 1.2595 | 417.4682 ± 0.8754 | 1.0026 | 0.30% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 733.0000 | 66.0000 | 11.1061 | 421.7957 ± 1.6736 | 422.5805 ± 0.8541 | 0.9981 | 0.40% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 720.0000 | 63.0000 | 11.4286 | 422.7635 ± 2.8573 | 425.5545 ± 4.2856 | 0.9934 | 0.68% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.8730 |
| Geometric mean runtime ratio (L0/GCC) | 0.9991 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
