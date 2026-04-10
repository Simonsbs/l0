# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-10T04:16:56Z`
- host: `runnervm35a4x`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 769.0000 | 70.0000 | 10.9857 | 425.2580 ± 2.9271 | 424.4355 ± 0.4385 | 1.0019 | 0.69% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 70.0000 | 10.6714 | 427.1180 ± 1.3392 | 425.3599 ± 1.6175 | 1.0041 | 0.31% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 754.0000 | 71.0000 | 10.6197 | 424.7771 ± 1.0582 | 424.1314 ± 2.0222 | 1.0015 | 0.25% | ok |
| and (2-arg) | `tests/valid_and.l0` | 761.0000 | 70.0000 | 10.8714 | 427.0713 ± 0.7107 | 424.3525 ± 0.3085 | 1.0064 | 0.17% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 754.0000 | 71.0000 | 10.6197 | 425.2395 ± 0.7388 | 426.0744 ± 0.8461 | 0.9980 | 0.17% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 747.0000 | 72.0000 | 10.3750 | 428.6835 ± 1.4133 | 429.4848 ± 0.3827 | 0.9981 | 0.33% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 740.0000 | 73.0000 | 10.1370 | 425.1284 ± 1.0210 | 424.4448 ± 0.1807 | 1.0016 | 0.24% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 733.0000 | 72.0000 | 10.1806 | 418.2460 ± 9.3006 | 410.8469 ± 11.3754 | 1.0180 | 2.22% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 740.0000 | 69.0000 | 10.7246 | 426.5490 ± 0.8882 | 425.1562 ± 0.6032 | 1.0033 | 0.21% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5725 |
| Geometric mean runtime ratio (L0/GCC) | 1.0036 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
