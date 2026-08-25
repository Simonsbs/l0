# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-25T03:57:11Z`
- host: `runnervm76f27`
- kernel: `Linux 6.17.0-1022-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `INTEL(R) XEON(R) PLATINUM 8573C`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 701.0000 | 60.0000 | 11.6833 | 616.6140 ± 31.9458 | 597.5235 ± 7.3564 | 1.0319 | 5.18% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 714.0000 | 47.0000 | 15.1915 | 619.0178 ± 13.0515 | 666.9370 ± 29.3255 | 0.9282 | 2.11% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 260.0000 | 45.0000 | 5.7778 | 626.1220 ± 30.2392 | 624.1811 ± 12.4151 | 1.0031 | 4.83% | ok |
| and (2-arg) | `tests/valid_and.l0` | 341.0000 | 63.0000 | 5.4127 | 587.5474 ± 25.7980 | 659.0825 ± 24.1765 | 0.8915 | 4.39% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 205.0000 | 43.0000 | 4.7674 | 599.3571 ± 4.2251 | 646.1311 ± 7.4008 | 0.9276 | 0.70% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 121.0000 | 51.0000 | 2.3725 | 656.5567 ± 21.4853 | 597.0851 ± 10.9454 | 1.0996 | 3.27% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 297.0000 | 70.0000 | 4.2429 | 594.8483 ± 23.1056 | 616.9062 ± 13.0495 | 0.9642 | 3.88% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 784.0000 | 72.0000 | 10.8889 | 611.2876 ± 15.6556 | 606.2405 ± 1.3424 | 1.0083 | 2.56% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 337.0000 | 45.0000 | 7.4889 | 658.8601 ± 26.2179 | 621.6778 ± 10.0997 | 1.0598 | 3.98% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 6.5345 |
| Geometric mean runtime ratio (L0/GCC) | 0.9884 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
