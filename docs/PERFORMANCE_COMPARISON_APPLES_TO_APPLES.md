# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-03-11T03:56:59Z`
- host: `runnervm0kj6c`
- kernel: `Linux 6.14.0-1017-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 695.0000 | 66.0000 | 10.5303 | 418.6584 ± 0.4170 | 417.7629 ± 0.8400 | 1.0021 | 0.10% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 677.0000 | 67.0000 | 10.1045 | 417.5664 ± 1.8202 | 418.5686 ± 1.0942 | 0.9976 | 0.44% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 683.0000 | 66.0000 | 10.3485 | 417.2542 ± 0.5035 | 416.2848 ± 1.0907 | 1.0023 | 0.12% | ok |
| and (2-arg) | `tests/valid_and.l0` | 677.0000 | 66.0000 | 10.2576 | 416.3735 ± 0.9353 | 417.9685 ± 1.5344 | 0.9962 | 0.22% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 677.0000 | 67.0000 | 10.1045 | 417.4861 ± 1.1934 | 418.1475 ± 2.6201 | 0.9984 | 0.29% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 672.0000 | 68.0000 | 9.8824 | 417.3790 ± 1.4914 | 415.1345 ± 1.4848 | 1.0054 | 0.36% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 672.0000 | 68.0000 | 9.8824 | 416.2671 ± 1.5574 | 417.2452 ± 1.0196 | 0.9977 | 0.37% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 677.0000 | 64.0000 | 10.5781 | 412.9316 ± 2.0459 | 413.1587 ± 2.6553 | 0.9995 | 0.50% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 666.0000 | 65.0000 | 10.2462 | 417.2987 ± 1.5986 | 419.4135 ± 1.9780 | 0.9950 | 0.38% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.2122 |
| Geometric mean runtime ratio (L0/GCC) | 0.9994 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
