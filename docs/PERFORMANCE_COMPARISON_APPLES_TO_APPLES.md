# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-02T07:52:16Z`
- host: `runnervmgx7h7`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 754.0000 | 71.0000 | 10.6197 | 424.7217 ± 0.2851 | 424.4724 ± 0.7945 | 1.0006 | 0.07% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 70.0000 | 10.6714 | 423.3958 ± 0.2129 | 423.9381 ± 0.7544 | 0.9987 | 0.05% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 70.0000 | 10.6714 | 424.7309 ± 1.4542 | 423.2857 ± 1.4720 | 1.0034 | 0.34% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 71.0000 | 10.4225 | 421.5772 ± 1.3283 | 423.7173 ± 2.8610 | 0.9949 | 0.32% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 740.0000 | 71.0000 | 10.4225 | 422.7086 ± 1.2270 | 423.6530 ± 0.4734 | 0.9978 | 0.29% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 740.0000 | 72.0000 | 10.2778 | 423.2032 ± 1.9879 | 423.9841 ± 1.3785 | 0.9982 | 0.47% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 72.0000 | 10.3750 | 426.3627 ± 2.3106 | 425.8886 ± 2.4173 | 1.0011 | 0.54% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 747.0000 | 71.0000 | 10.5211 | 424.8510 ± 0.6793 | 424.2880 ± 1.4560 | 1.0013 | 0.16% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 733.0000 | 69.0000 | 10.6232 | 424.4355 ± 0.8611 | 423.9196 ± 0.2345 | 1.0012 | 0.20% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5108 |
| Geometric mean runtime ratio (L0/GCC) | 0.9997 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
