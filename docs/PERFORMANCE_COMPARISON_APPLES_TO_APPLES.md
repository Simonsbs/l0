# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-24T04:21:22Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 761.0000 | 70.0000 | 10.8714 | 425.0729 ± 0.6846 | 425.4711 ± 0.4818 | 0.9991 | 0.16% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 761.0000 | 71.0000 | 10.7183 | 424.7032 ± 3.8702 | 430.3839 ± 1.0395 | 0.9868 | 0.91% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 71.0000 | 10.5211 | 424.3986 ± 0.6621 | 424.3618 ± 0.2843 | 1.0001 | 0.16% | ok |
| and (2-arg) | `tests/valid_and.l0` | 761.0000 | 71.0000 | 10.7183 | 424.4355 ± 1.1957 | 424.5186 ± 3.0165 | 0.9998 | 0.28% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 740.0000 | 70.0000 | 10.5714 | 424.2880 ± 1.0346 | 424.4263 ± 1.0329 | 0.9997 | 0.24% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 754.0000 | 72.0000 | 10.4722 | 425.2951 ± 0.0794 | 425.7215 ± 0.7401 | 0.9990 | 0.02% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 754.0000 | 72.0000 | 10.4722 | 424.6385 ± 1.9714 | 425.0267 ± 1.6909 | 0.9991 | 0.46% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 747.0000 | 71.0000 | 10.5211 | 423.8369 ± 0.7109 | 424.4355 ± 1.4257 | 0.9986 | 0.17% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 740.0000 | 69.0000 | 10.7246 | 423.7449 ± 0.6191 | 425.1932 ± 1.0481 | 0.9966 | 0.15% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.6203 |
| Geometric mean runtime ratio (L0/GCC) | 0.9976 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
