# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-15T08:13:44Z`
- host: `runnervm8k3b6`
- kernel: `Linux 6.17.0-1022-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 418.0000 | 54.0000 | 7.7407 | 392.7616 ± 0.5605 | 392.6827 ± 0.4583 | 1.0002 | 0.14% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 268.0000 | 72.0000 | 3.7222 | 392.7537 ± 1.0944 | 394.1328 ± 3.6833 | 0.9965 | 0.28% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 238.0000 | 63.0000 | 3.7778 | 392.6827 ± 0.0237 | 405.3977 ± 0.6698 | 0.9686 | 0.01% | ok |
| and (2-arg) | `tests/valid_and.l0` | 213.0000 | 47.0000 | 4.5319 | 395.5776 ± 1.2913 | 398.9063 ± 1.1862 | 0.9917 | 0.33% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 449.0000 | 76.0000 | 5.9079 | 394.5388 ± 1.5291 | 399.6164 ± 1.6314 | 0.9873 | 0.39% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 128.0000 | 44.0000 | 2.9091 | 404.7760 ± 0.8437 | 392.9434 ± 0.4076 | 1.0301 | 0.21% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 101.0000 | 36.0000 | 2.8056 | 393.6244 ± 2.1268 | 393.0462 ± 0.9857 | 1.0015 | 0.54% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 125.0000 | 59.0000 | 2.1186 | 392.3041 ± 0.7089 | 392.8643 ± 1.5022 | 0.9986 | 0.18% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 720.0000 | 58.0000 | 12.4138 | 405.0110 ± 1.6634 | 403.8052 ± 1.3431 | 1.0030 | 0.41% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 4.4059 |
| Geometric mean runtime ratio (L0/GCC) | 0.9974 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
