# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-04T04:01:52Z`
- host: `runnervm727z3`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 761.0000 | 69.0000 | 11.0290 | 425.3321 ± 1.2649 | 424.6939 ± 0.2512 | 1.0015 | 0.30% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 761.0000 | 68.0000 | 11.1912 | 421.3044 ± 2.1592 | 423.8001 ± 1.2465 | 0.9941 | 0.51% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 754.0000 | 68.0000 | 11.0882 | 424.6016 ± 1.3857 | 426.2976 ± 0.6541 | 0.9960 | 0.33% | ok |
| and (2-arg) | `tests/valid_and.l0` | 747.0000 | 68.0000 | 10.9853 | 425.7215 ± 1.0150 | 426.5117 ± 0.8224 | 0.9981 | 0.24% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 754.0000 | 68.0000 | 11.0882 | 424.1959 ± 0.3095 | 424.4817 ± 1.4138 | 0.9993 | 0.07% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 747.0000 | 69.0000 | 10.8261 | 424.8972 ± 0.4627 | 425.4711 ± 0.9458 | 0.9987 | 0.11% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 754.0000 | 72.0000 | 10.4722 | 424.0301 ± 3.0610 | 427.9696 ± 2.1240 | 0.9908 | 0.72% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 754.0000 | 70.0000 | 10.7714 | 427.4638 ± 0.5475 | 427.6885 ± 2.2686 | 0.9995 | 0.13% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 747.0000 | 69.0000 | 10.8261 | 426.2790 ± 2.0220 | 426.6328 ± 0.6300 | 0.9992 | 0.47% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.9178 |
| Geometric mean runtime ratio (L0/GCC) | 0.9975 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
