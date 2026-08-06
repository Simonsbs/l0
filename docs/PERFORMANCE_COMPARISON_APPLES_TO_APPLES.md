# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-06T06:03:07Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 727.0000 | 63.0000 | 11.5397 | 414.5970 ± 1.3610 | 416.3558 ± 2.1708 | 0.9958 | 0.33% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 733.0000 | 63.0000 | 11.6349 | 418.1296 ± 1.1652 | 416.7022 ± 5.4065 | 1.0034 | 0.28% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 714.0000 | 62.0000 | 11.5161 | 411.6175 ± 1.9102 | 417.6200 ± 0.7350 | 0.9856 | 0.46% | ok |
| and (2-arg) | `tests/valid_and.l0` | 714.0000 | 64.0000 | 11.1562 | 419.6208 ± 0.9959 | 419.4586 ± 1.8908 | 1.0004 | 0.24% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 714.0000 | 63.0000 | 11.3333 | 414.1486 ± 1.5607 | 410.2600 ± 3.0523 | 1.0095 | 0.38% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 714.0000 | 64.0000 | 11.1562 | 418.3087 ± 1.9159 | 417.2363 ± 1.0908 | 1.0026 | 0.46% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 720.0000 | 65.0000 | 11.0769 | 416.1872 ± 5.7243 | 419.0896 ± 1.2499 | 0.9931 | 1.38% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 714.0000 | 64.0000 | 11.1562 | 421.3953 ± 4.1404 | 422.6628 ± 3.7116 | 0.9970 | 0.98% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 720.0000 | 64.0000 | 11.2500 | 420.3614 ± 1.4292 | 421.2317 ± 1.0434 | 0.9979 | 0.34% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.3117 |
| Geometric mean runtime ratio (L0/GCC) | 0.9983 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
