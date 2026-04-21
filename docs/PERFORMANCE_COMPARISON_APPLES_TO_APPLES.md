# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-21T04:18:33Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 761.0000 | 65.0000 | 11.7077 | 421.3498 ± 1.9176 | 422.0600 ± 1.0249 | 0.9983 | 0.46% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 727.0000 | 68.0000 | 10.6912 | 420.3614 ± 1.0072 | 421.9050 ± 1.3711 | 0.9963 | 0.24% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 68.0000 | 10.9853 | 265.9194 ± 15.7644 | 270.5534 ± 79.6705 | 0.9829 | 5.93% | ok |
| and (2-arg) | `tests/valid_and.l0` | 733.0000 | 65.0000 | 11.2769 | 415.8328 ± 4.6637 | 424.2327 ± 2.0619 | 0.9802 | 1.12% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 761.0000 | 66.0000 | 11.5303 | 419.9185 ± 3.3344 | 420.6601 ± 2.2117 | 0.9982 | 0.79% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 740.0000 | 69.0000 | 10.7246 | 423.4601 ± 0.7929 | 423.6070 ± 0.9251 | 0.9997 | 0.19% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 69.0000 | 10.8261 | 424.1682 ± 1.4941 | 423.9196 ± 3.0463 | 1.0006 | 0.35% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 740.0000 | 67.0000 | 11.0448 | 421.0955 ± 0.3604 | 422.9466 ± 0.2077 | 0.9956 | 0.09% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 740.0000 | 66.0000 | 11.2121 | 422.4434 ± 0.6322 | 421.8321 ± 1.2334 | 1.0014 | 0.15% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.1061 |
| Geometric mean runtime ratio (L0/GCC) | 0.9948 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
