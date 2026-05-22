# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-22T04:40:15Z`
- host: `runnervmrw5os`
- kernel: `Linux 6.17.0-1013-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 769.0000 | 71.0000 | 10.8310 | 424.0761 ± 1.6202 | 424.5370 ± 1.4723 | 0.9989 | 0.38% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 754.0000 | 70.0000 | 10.7714 | 423.1482 ± 0.4564 | 423.0015 ± 0.9279 | 1.0003 | 0.11% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 70.0000 | 10.6714 | 423.8736 ± 0.4233 | 423.3958 ± 0.3600 | 1.0011 | 0.10% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 70.0000 | 10.5714 | 423.7173 ± 0.5165 | 424.0025 ± 2.9300 | 0.9993 | 0.12% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 733.0000 | 71.0000 | 10.3239 | 423.6714 ± 0.3607 | 421.9780 ± 1.9447 | 1.0040 | 0.09% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 733.0000 | 72.0000 | 10.1806 | 424.6201 ± 0.5267 | 423.3224 ± 1.2038 | 1.0031 | 0.12% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 72.0000 | 10.3750 | 423.6162 ± 1.1945 | 423.5611 ± 0.4322 | 1.0001 | 0.28% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 740.0000 | 71.0000 | 10.4225 | 424.5462 ± 1.8594 | 425.2858 ± 0.3729 | 0.9983 | 0.44% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 733.0000 | 70.0000 | 10.4714 | 424.5186 ± 0.3076 | 423.5060 ± 0.9147 | 1.0024 | 0.07% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5112 |
| Geometric mean runtime ratio (L0/GCC) | 1.0008 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
