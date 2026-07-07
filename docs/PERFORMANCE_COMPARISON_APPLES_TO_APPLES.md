# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-07T06:53:59Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 754.0000 | 70.0000 | 10.7714 | 425.5174 ± 2.8859 | 425.8607 ± 0.9813 | 0.9992 | 0.68% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 727.0000 | 70.0000 | 10.3857 | 423.6530 ± 0.8112 | 423.7541 ± 0.4960 | 0.9998 | 0.19% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 733.0000 | 71.0000 | 10.3239 | 423.9657 ± 0.0939 | 423.8828 ± 0.6222 | 1.0002 | 0.02% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 70.0000 | 10.5714 | 421.2862 ± 2.9599 | 423.1298 ± 2.6088 | 0.9956 | 0.70% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 733.0000 | 70.0000 | 10.4714 | 424.0485 ± 0.8804 | 423.7265 ± 0.2716 | 1.0008 | 0.21% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 733.0000 | 71.0000 | 10.3239 | 422.5805 ± 1.6210 | 423.4601 ± 0.9791 | 0.9979 | 0.38% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 740.0000 | 71.0000 | 10.4225 | 422.2516 ± 1.4744 | 423.8277 ± 1.3330 | 0.9963 | 0.35% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 727.0000 | 71.0000 | 10.2394 | 423.9841 ± 0.0217 | 424.3710 ± 0.1416 | 0.9991 | 0.01% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 701.0000 | 69.0000 | 10.1594 | 422.8092 ± 2.0712 | 424.2604 ± 0.7220 | 0.9966 | 0.49% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4062 |
| Geometric mean runtime ratio (L0/GCC) | 0.9984 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
