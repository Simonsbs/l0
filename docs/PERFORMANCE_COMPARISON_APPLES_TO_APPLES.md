# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-18T04:43:43Z`
- host: `runnervmrw5os`
- kernel: `Linux 6.17.0-1013-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 695.0000 | 61.0000 | 11.3934 | 304.2346 ± 0.9764 | 305.2139 ± 0.7104 | 0.9968 | 0.32% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 689.0000 | 60.0000 | 11.4833 | 302.3460 ± 1.1917 | 304.9709 ± 0.9389 | 0.9914 | 0.39% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 707.0000 | 60.0000 | 11.7833 | 300.8232 ± 2.2735 | 312.6451 ± 2.4949 | 0.9622 | 0.76% | ok |
| and (2-arg) | `tests/valid_and.l0` | 701.0000 | 63.0000 | 11.1270 | 306.6756 ± 1.7274 | 308.3508 ± 1.3242 | 0.9946 | 0.56% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 689.0000 | 65.0000 | 10.6000 | 304.5904 ± 0.3744 | 306.7720 ± 0.4989 | 0.9929 | 0.12% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 714.0000 | 63.0000 | 11.3333 | 305.1662 ± 1.6743 | 297.8641 ± 0.9655 | 1.0245 | 0.55% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 701.0000 | 61.0000 | 11.4918 | 301.8414 ± 2.2112 | 299.6096 ± 0.6271 | 1.0074 | 0.73% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 695.0000 | 61.0000 | 11.3934 | 304.4907 ± 1.4563 | 307.2642 ± 1.9244 | 0.9910 | 0.48% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 689.0000 | 60.0000 | 11.4833 | 312.9156 ± 0.9511 | 313.9315 ± 2.0444 | 0.9968 | 0.30% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.3389 |
| Geometric mean runtime ratio (L0/GCC) | 0.9952 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
