# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-07T10:11:44Z`
- host: `runnervm8df0l`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 689.0000 | 62.0000 | 11.1129 | 412.6785 ± 3.4315 | 417.0581 ± 3.0063 | 0.9895 | 0.83% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 666.0000 | 61.0000 | 10.9180 | 411.9908 ± 3.6698 | 418.4431 ± 4.4424 | 0.9846 | 0.89% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 683.0000 | 62.0000 | 11.0161 | 415.5674 ± 1.2222 | 410.6741 ± 0.8594 | 1.0119 | 0.29% | ok |
| and (2-arg) | `tests/valid_and.l0` | 683.0000 | 62.0000 | 11.0161 | 416.2848 ± 2.4304 | 417.8880 ± 0.3122 | 0.9962 | 0.58% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 677.0000 | 62.0000 | 10.9194 | 417.8701 ± 2.8096 | 412.6349 ± 0.7621 | 1.0127 | 0.67% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 677.0000 | 66.0000 | 10.2576 | 411.1842 ± 2.3862 | 412.6088 ± 4.8794 | 0.9965 | 0.58% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 677.0000 | 64.0000 | 10.5781 | 422.6628 ± 0.7405 | 421.9597 ± 1.5311 | 1.0017 | 0.18% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 666.0000 | 62.0000 | 10.7419 | 409.2714 ± 1.9304 | 411.2448 ± 1.3023 | 0.9952 | 0.47% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 655.0000 | 61.0000 | 10.7377 | 404.3318 ± 0.7881 | 412.9665 ± 0.7708 | 0.9791 | 0.19% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.8079 |
| Geometric mean runtime ratio (L0/GCC) | 0.9963 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
