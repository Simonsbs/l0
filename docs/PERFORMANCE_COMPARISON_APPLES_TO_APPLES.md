# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-16T04:20:14Z`
- host: `runnervm35a4x`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 695.0000 | 60.0000 | 11.5833 | 303.0215 ± 1.0480 | 304.4337 ± 0.2579 | 0.9954 | 0.35% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 683.0000 | 60.0000 | 11.3833 | 304.7615 ± 5.6643 | 304.8424 ± 1.5775 | 0.9997 | 1.86% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 695.0000 | 62.0000 | 11.2097 | 303.2238 ± 0.2577 | 312.4450 ± 6.1561 | 0.9705 | 0.08% | ok |
| and (2-arg) | `tests/valid_and.l0` | 677.0000 | 59.0000 | 11.4746 | 303.5159 ± 0.1704 | 307.3029 ± 3.0415 | 0.9877 | 0.06% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 695.0000 | 62.0000 | 11.2097 | 304.9423 ± 1.4111 | 310.8191 ± 2.6548 | 0.9811 | 0.46% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 677.0000 | 61.0000 | 11.0984 | 311.3046 ± 0.2852 | 306.3485 ± 1.6345 | 1.0162 | 0.09% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 677.0000 | 62.0000 | 10.9194 | 304.7092 ± 0.1678 | 303.7094 ± 0.2479 | 1.0033 | 0.06% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 689.0000 | 61.0000 | 11.2951 | 302.7444 ± 1.1535 | 304.7567 ± 4.8282 | 0.9934 | 0.38% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 672.0000 | 60.0000 | 11.2000 | 312.1354 ± 0.7386 | 313.0610 ± 1.3002 | 0.9970 | 0.24% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.2622 |
| Geometric mean runtime ratio (L0/GCC) | 0.9937 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
