# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-14T05:38:43Z`
- host: `runnervm5mmn9`
- kernel: `Linux 6.17.0-1018-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 769.0000 | 64.0000 | 12.0156 | 422.2608 ± 0.4258 | 419.5126 ± 3.1052 | 1.0066 | 0.10% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 65.0000 | 11.4923 | 414.5090 ± 3.6772 | 415.6027 ± 1.3110 | 0.9974 | 0.89% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 65.0000 | 11.4923 | 420.8686 ± 0.6469 | 420.3976 ± 1.9911 | 1.0011 | 0.15% | ok |
| and (2-arg) | `tests/valid_and.l0` | 761.0000 | 65.0000 | 11.7077 | 420.0901 ± 2.2186 | 422.5165 ± 1.3519 | 0.9943 | 0.53% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 727.0000 | 67.0000 | 10.8507 | 425.5731 ± 1.2546 | 425.0452 ± 0.9691 | 1.0012 | 0.29% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 740.0000 | 66.0000 | 11.2121 | 425.0452 ± 0.7816 | 425.8607 ± 1.2139 | 0.9981 | 0.18% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 754.0000 | 66.0000 | 11.4242 | 421.1499 ± 2.7319 | 424.4171 ± 0.3530 | 0.9923 | 0.65% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 754.0000 | 68.0000 | 11.0882 | 424.8602 ± 1.9772 | 425.9071 ± 0.3948 | 0.9975 | 0.47% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 714.0000 | 65.0000 | 10.9846 | 421.6500 ± 2.0322 | 424.1498 ± 0.3435 | 0.9941 | 0.48% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.3578 |
| Geometric mean runtime ratio (L0/GCC) | 0.9981 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
