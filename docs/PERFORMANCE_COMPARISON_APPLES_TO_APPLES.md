# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-03-31T04:10:29Z`
- host: `runnervmrg6be`
- kernel: `Linux 6.17.0-1008-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 784.0000 | 72.0000 | 10.8889 | 426.3813 ± 0.4602 | 426.8659 ± 1.1191 | 0.9989 | 0.11% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 792.0000 | 72.0000 | 11.0000 | 426.4651 ± 1.3255 | 425.5545 ± 2.2475 | 1.0021 | 0.31% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 769.0000 | 72.0000 | 10.6806 | 420.5605 ± 6.7339 | 416.1606 ± 4.9630 | 1.0106 | 1.60% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 65.0000 | 11.3846 | 424.9342 ± 0.6331 | 425.6380 ± 1.8785 | 0.9983 | 0.15% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 761.0000 | 72.0000 | 10.5694 | 425.7586 ± 0.5378 | 425.4155 ± 0.5892 | 1.0008 | 0.13% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 754.0000 | 73.0000 | 10.3288 | 424.6478 ± 0.5097 | 426.0558 ± 0.2646 | 0.9967 | 0.12% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 754.0000 | 73.0000 | 10.3288 | 442.2337 ± 8.1347 | 426.4558 ± 6.2656 | 1.0370 | 1.84% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 761.0000 | 72.0000 | 10.5694 | 425.5638 ± 0.5068 | 425.2302 ± 1.4406 | 1.0008 | 0.12% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 761.0000 | 71.0000 | 10.7183 | 426.1953 ± 1.0685 | 427.0993 ± 3.2843 | 0.9979 | 0.25% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.7141 |
| Geometric mean runtime ratio (L0/GCC) | 1.0047 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
