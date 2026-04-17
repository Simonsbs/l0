# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-17T04:18:46Z`
- host: `runnervmeorf1`
- kernel: `Linux 6.17.0-1010-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 707.0000 | 62.0000 | 11.4032 | 302.3741 ± 1.7597 | 303.3604 ± 0.2387 | 0.9967 | 0.58% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 689.0000 | 61.0000 | 11.2951 | 304.1398 ± 1.1308 | 310.4683 ± 3.1009 | 0.9796 | 0.37% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 701.0000 | 62.0000 | 11.3065 | 304.6854 ± 0.7020 | 313.6442 ± 2.1784 | 0.9714 | 0.23% | ok |
| and (2-arg) | `tests/valid_and.l0` | 689.0000 | 62.0000 | 11.1129 | 305.6103 ± 1.2010 | 306.4783 ± 0.2878 | 0.9972 | 0.39% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 695.0000 | 64.0000 | 10.8594 | 304.9947 ± 0.7603 | 307.8114 ± 0.3766 | 0.9908 | 0.25% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 689.0000 | 64.0000 | 10.7656 | 312.0806 ± 0.7884 | 306.5793 ± 0.3907 | 1.0179 | 0.25% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 701.0000 | 63.0000 | 11.1270 | 305.7347 ± 1.6224 | 304.7282 ± 0.9338 | 1.0033 | 0.53% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 689.0000 | 63.0000 | 10.9365 | 305.0090 ± 1.3690 | 307.1724 ± 1.9846 | 0.9930 | 0.45% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 683.0000 | 61.0000 | 11.1967 | 315.8965 ± 1.5658 | 316.5467 ± 1.9191 | 0.9979 | 0.50% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.1095 |
| Geometric mean runtime ratio (L0/GCC) | 0.9941 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
