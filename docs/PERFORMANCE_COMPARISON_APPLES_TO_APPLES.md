# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-20T06:24:28Z`
- host: `runnervm3jd5f`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 695.0000 | 62.0000 | 11.2097 | 299.7153 ± 1.9262 | 302.2150 ± 2.2731 | 0.9917 | 0.64% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 683.0000 | 61.0000 | 11.1967 | 303.7519 ± 0.8806 | 306.2188 ± 0.8817 | 0.9919 | 0.29% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 677.0000 | 61.0000 | 11.0984 | 301.4268 ± 4.8931 | 311.6076 ± 25.3391 | 0.9673 | 1.62% | ok |
| and (2-arg) | `tests/valid_and.l0` | 677.0000 | 62.0000 | 10.9194 | 303.9268 ± 1.3916 | 306.6804 ± 0.7811 | 0.9910 | 0.46% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 677.0000 | 61.0000 | 11.0984 | 303.1532 ± 0.5704 | 308.1757 ± 0.8430 | 0.9837 | 0.19% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 677.0000 | 63.0000 | 10.7460 | 309.7052 ± 0.4349 | 302.4303 ± 0.1741 | 1.0241 | 0.14% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 672.0000 | 60.0000 | 11.2000 | 303.4263 ± 1.3080 | 303.2520 ± 1.6928 | 1.0006 | 0.43% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 672.0000 | 61.0000 | 11.0164 | 302.6271 ± 0.9954 | 303.8370 ± 0.4498 | 0.9960 | 0.33% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 677.0000 | 61.0000 | 11.0984 | 311.6473 ± 0.7270 | 311.8713 ± 0.4522 | 0.9993 | 0.23% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.0639 |
| Geometric mean runtime ratio (L0/GCC) | 0.9939 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
