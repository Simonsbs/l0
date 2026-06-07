# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-07T04:50:36Z`
- host: `runnervm3jyl0`
- kernel: `Linux 6.17.0-1015-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 714.0000 | 66.0000 | 10.8182 | 306.1756 ± 0.7359 | 307.2449 ± 0.2848 | 0.9965 | 0.24% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 707.0000 | 64.0000 | 11.0469 | 306.8635 ± 1.1561 | 310.1232 ± 3.2507 | 0.9895 | 0.38% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 707.0000 | 65.0000 | 10.8769 | 306.0317 ± 0.6795 | 312.9607 ± 0.8759 | 0.9779 | 0.22% | ok |
| and (2-arg) | `tests/valid_and.l0` | 689.0000 | 65.0000 | 10.6000 | 306.2525 ± 0.4821 | 307.7581 ± 0.4119 | 0.9951 | 0.16% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 683.0000 | 64.0000 | 10.6719 | 306.1420 ± 0.3997 | 306.9986 ± 2.3078 | 0.9972 | 0.13% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 683.0000 | 64.0000 | 10.6719 | 310.7944 ± 0.7315 | 305.0471 ± 0.4144 | 1.0188 | 0.24% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 695.0000 | 62.0000 | 11.2097 | 302.7068 ± 0.1940 | 303.2944 ± 3.3804 | 0.9981 | 0.06% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 683.0000 | 62.0000 | 11.0161 | 304.4812 ± 0.5082 | 304.7567 ± 0.4621 | 0.9991 | 0.17% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 683.0000 | 61.0000 | 11.1967 | 313.9063 ± 1.0219 | 313.7701 ± 0.7668 | 1.0004 | 0.33% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.8988 |
| Geometric mean runtime ratio (L0/GCC) | 0.9969 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
