# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-11T09:56:35Z`
- host: `runnervmmprz5`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 683.0000 | 63.0000 | 10.8413 | 418.0222 ± 2.8894 | 417.7539 ± 0.2207 | 1.0006 | 0.69% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 677.0000 | 63.0000 | 10.7460 | 422.0783 ± 0.6670 | 420.3614 ± 1.4052 | 1.0041 | 0.16% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 655.0000 | 62.0000 | 10.5645 | 416.6756 ± 1.4424 | 418.8559 ± 2.4127 | 0.9948 | 0.35% | ok |
| and (2-arg) | `tests/valid_and.l0` | 661.0000 | 62.0000 | 10.6613 | 417.1561 ± 0.8624 | 418.9098 ± 0.0887 | 0.9958 | 0.21% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 672.0000 | 63.0000 | 10.6667 | 417.9059 ± 0.5616 | 418.8110 ± 1.3806 | 0.9978 | 0.13% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 661.0000 | 64.0000 | 10.3281 | 421.5135 ± 3.6468 | 420.9049 ± 0.1358 | 1.0014 | 0.87% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 661.0000 | 64.0000 | 10.3281 | 416.2759 ± 4.6357 | 418.3535 ± 0.4529 | 0.9950 | 1.11% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 672.0000 | 62.0000 | 10.8387 | 417.3790 ± 1.7587 | 415.9479 ± 3.6155 | 1.0034 | 0.42% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 661.0000 | 62.0000 | 10.6613 | 417.4682 ± 2.6474 | 423.4234 ± 2.3449 | 0.9859 | 0.63% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.6247 |
| Geometric mean runtime ratio (L0/GCC) | 0.9976 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
