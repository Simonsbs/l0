# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-06T07:21:07Z`
- host: `runnervmkkn4f`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 754.0000 | 72.0000 | 10.4722 | 425.6844 ± 1.8293 | 424.5278 ± 0.8884 | 1.0027 | 0.43% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 727.0000 | 70.0000 | 10.3857 | 422.3338 ± 0.4921 | 421.7046 ± 0.3258 | 1.0015 | 0.12% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 727.0000 | 71.0000 | 10.2394 | 424.1498 ± 2.8817 | 423.5244 ± 1.3044 | 1.0015 | 0.68% | ok |
| and (2-arg) | `tests/valid_and.l0` | 733.0000 | 71.0000 | 10.3239 | 422.4617 ± 0.8891 | 422.8367 ± 0.6631 | 0.9991 | 0.21% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 727.0000 | 71.0000 | 10.2394 | 420.0992 ± 29.2264 | 422.9557 ± 1.9579 | 0.9932 | 6.96% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 733.0000 | 72.0000 | 10.1806 | 421.5226 ± 0.5824 | 421.6773 ± 0.3081 | 0.9996 | 0.14% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 727.0000 | 72.0000 | 10.0972 | 423.7541 ± 0.9828 | 423.9841 ± 1.4894 | 0.9995 | 0.23% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 727.0000 | 71.0000 | 10.2394 | 422.8825 ± 1.6171 | 422.6171 ± 0.7184 | 1.0006 | 0.38% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 733.0000 | 70.0000 | 10.4714 | 421.9233 ± 2.2772 | 422.9099 ± 1.0624 | 0.9977 | 0.54% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.2936 |
| Geometric mean runtime ratio (L0/GCC) | 0.9995 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
