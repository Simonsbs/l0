# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-26T04:22:51Z`
- host: `runnervmeorf1`
- kernel: `Linux 6.17.0-1010-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 769.0000 | 69.0000 | 11.1449 | 420.3252 ± 1.0658 | 419.2065 ± 3.1409 | 1.0027 | 0.25% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 70.0000 | 10.6714 | 424.9434 ± 2.7912 | 422.8001 ± 1.8054 | 1.0051 | 0.66% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 68.0000 | 10.9853 | 423.8920 ± 0.5437 | 423.0565 ± 0.6270 | 1.0020 | 0.13% | ok |
| and (2-arg) | `tests/valid_and.l0` | 761.0000 | 67.0000 | 11.3582 | 423.3775 ± 0.4746 | 423.0473 ± 0.3779 | 1.0008 | 0.11% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 761.0000 | 67.0000 | 11.3582 | 416.4890 ± 2.1039 | 419.5487 ± 0.8884 | 0.9927 | 0.51% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 740.0000 | 65.0000 | 11.3846 | 413.5874 ± 0.8245 | 414.0608 ± 2.6737 | 0.9989 | 0.20% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 66.0000 | 11.3182 | 423.4785 ± 2.0105 | 423.1665 ± 0.8603 | 1.0007 | 0.47% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 740.0000 | 67.0000 | 11.0448 | 425.5638 ± 1.9689 | 427.7915 ± 0.5850 | 0.9948 | 0.46% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 733.0000 | 69.0000 | 10.6232 | 424.0393 ± 0.3625 | 424.8325 ± 0.5384 | 0.9981 | 0.09% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.0953 |
| Geometric mean runtime ratio (L0/GCC) | 0.9995 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
