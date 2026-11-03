# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-03T10:46:28Z`
- host: `runnervm48cm3`
- kernel: `Linux 7.0.0-1017-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 975.0000 | 82.0000 | 11.8902 | 648.5125 ± 24.4717 | 607.9388 ± 8.3750 | 1.0667 | 3.77% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 83.0000 | 9.0000 | 636.7363 ± 11.9145 | 700.9493 ± 33.7320 | 0.9084 | 1.87% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 733.0000 | 82.0000 | 8.9390 | 649.7206 ± 2.5349 | 651.3891 ± 13.6046 | 0.9974 | 0.39% | ok |
| and (2-arg) | `tests/valid_and.l0` | 930.0000 | 81.0000 | 11.4815 | 634.2962 ± 28.6286 | 693.2367 ± 13.0801 | 0.9150 | 4.51% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 842.0000 | 80.0000 | 10.5250 | 657.6178 ± 3.5078 | 690.1014 ± 9.4650 | 0.9529 | 0.53% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 851.0000 | 81.0000 | 10.5062 | 694.8150 ± 20.6852 | 636.5496 ± 16.9811 | 1.0915 | 2.98% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 919.0000 | 84.0000 | 10.9405 | 661.1798 ± 4.9489 | 644.8724 ± 12.2471 | 1.0253 | 0.75% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 769.0000 | 82.0000 | 9.3780 | 665.1427 ± 12.5175 | 654.5106 ± 13.8619 | 1.0162 | 1.88% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 733.0000 | 81.0000 | 9.0494 | 654.9495 ± 12.6074 | 661.6950 ± 5.3012 | 0.9898 | 1.92% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.1343 |
| Geometric mean runtime ratio (L0/GCC) | 0.9941 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
