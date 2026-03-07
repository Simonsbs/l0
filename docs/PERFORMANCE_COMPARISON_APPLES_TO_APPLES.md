# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-03-07T03:54:28Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 701.0000 | 68.0000 | 10.3088 | 417.9596 ± 0.8712 | 419.0086 ± 4.8918 | 0.9975 | 0.21% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 695.0000 | 68.0000 | 10.2206 | 418.2639 ± 1.0311 | 419.2335 ± 0.3112 | 0.9977 | 0.25% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 683.0000 | 66.0000 | 10.3485 | 417.9864 ± 0.8453 | 417.5485 ± 0.1990 | 1.0010 | 0.20% | ok |
| and (2-arg) | `tests/valid_and.l0` | 689.0000 | 67.0000 | 10.2836 | 417.8791 ± 1.0199 | 420.7417 ± 0.5577 | 0.9932 | 0.24% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 677.0000 | 67.0000 | 10.1045 | 416.3735 ± 0.3379 | 417.9238 ± 0.1435 | 0.9963 | 0.08% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 683.0000 | 68.0000 | 10.0441 | 416.7378 ± 0.5671 | 417.1294 ± 1.1199 | 0.9991 | 0.14% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 683.0000 | 68.0000 | 10.0441 | 416.3735 ± 1.8389 | 417.9148 ± 1.8154 | 0.9963 | 0.44% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 695.0000 | 67.0000 | 10.3731 | 417.5753 ± 0.7824 | 417.2185 ± 0.7727 | 1.0009 | 0.19% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 689.0000 | 66.0000 | 10.4394 | 420.9230 ± 1.6626 | 419.7290 ± 2.2038 | 1.0028 | 0.39% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.2398 |
| Geometric mean runtime ratio (L0/GCC) | 0.9983 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
