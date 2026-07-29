# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-29T06:05:40Z`
- host: `runnervmvrwv9`
- kernel: `Linux 6.17.0-1020-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 740.0000 | 69.0000 | 10.7246 | 410.5446 ± 19.3663 | 408.8088 ± 11.6763 | 1.0042 | 4.72% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 71.0000 | 10.5211 | 424.0669 ± 1.2211 | 424.4540 ± 0.1106 | 0.9991 | 0.29% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 70.0000 | 10.6714 | 421.4317 ± 1.1855 | 422.0327 ± 0.5184 | 0.9986 | 0.28% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 69.0000 | 10.7246 | 426.3906 ± 1.9579 | 427.2394 ± 1.2145 | 0.9980 | 0.46% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 740.0000 | 70.0000 | 10.5714 | 422.9099 ± 1.6649 | 420.9684 ± 2.6228 | 1.0046 | 0.39% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 733.0000 | 71.0000 | 10.3239 | 421.7319 ± 1.3905 | 422.1330 ± 1.6200 | 0.9990 | 0.33% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 740.0000 | 71.0000 | 10.4225 | 422.2425 ± 1.9025 | 423.8277 ± 1.1071 | 0.9963 | 0.45% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 740.0000 | 69.0000 | 10.7246 | 421.0228 ± 0.9425 | 421.1772 ± 0.8972 | 0.9996 | 0.22% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 720.0000 | 67.0000 | 10.7463 | 420.7961 ± 1.9002 | 421.4498 ± 2.2725 | 0.9984 | 0.45% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.6024 |
| Geometric mean runtime ratio (L0/GCC) | 0.9998 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
