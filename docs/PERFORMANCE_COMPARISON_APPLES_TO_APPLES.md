# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-27T08:55:16Z`
- host: `runnervmtai0g`
- kernel: `Linux 6.17.0-1022-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 707.0000 | 67.0000 | 10.5522 | 420.1534 ± 4.7301 | 419.6839 ± 0.9950 | 1.0011 | 1.13% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 661.0000 | 64.0000 | 10.3281 | 418.8559 ± 2.2729 | 418.1206 ± 1.9479 | 1.0018 | 0.54% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 683.0000 | 64.0000 | 10.6719 | 413.5699 ± 3.2604 | 417.2452 ± 1.7679 | 0.9912 | 0.79% | ok |
| and (2-arg) | `tests/valid_and.l0` | 672.0000 | 63.0000 | 10.6667 | 415.0287 ± 0.7757 | 417.9774 ± 1.5819 | 0.9929 | 0.19% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 655.0000 | 63.0000 | 10.3968 | 421.3407 ± 0.4274 | 421.2590 ± 2.7012 | 1.0002 | 0.10% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 672.0000 | 64.0000 | 10.5000 | 413.0364 ± 0.7768 | 410.9939 ± 2.0016 | 1.0050 | 0.19% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 661.0000 | 66.0000 | 10.0152 | 416.2050 ± 4.8296 | 417.9148 ± 1.4928 | 0.9959 | 1.16% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 677.0000 | 64.0000 | 10.5781 | 416.8089 ± 1.3157 | 416.2937 ± 5.1368 | 1.0012 | 0.32% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 661.0000 | 62.0000 | 10.6613 | 423.6806 ± 0.2496 | 424.9897 ± 0.5974 | 0.9969 | 0.06% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4836 |
| Geometric mean runtime ratio (L0/GCC) | 0.9985 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
