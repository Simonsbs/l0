# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-05T07:37:40Z`
- host: `runnervmejwal`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 754.0000 | 72.0000 | 10.4722 | 425.2488 ± 0.2325 | 425.6751 ± 0.2287 | 0.9990 | 0.05% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 761.0000 | 72.0000 | 10.5694 | 424.5832 ± 0.9361 | 424.4079 ± 0.2081 | 1.0004 | 0.22% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 71.0000 | 10.5211 | 425.1654 ± 0.8037 | 424.2788 ± 1.3796 | 1.0021 | 0.19% | ok |
| and (2-arg) | `tests/valid_and.l0` | 747.0000 | 72.0000 | 10.3750 | 425.1099 ± 0.2722 | 423.3683 ± 0.3012 | 1.0041 | 0.06% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 740.0000 | 70.0000 | 10.5714 | 422.9924 ± 2.2041 | 426.3627 ± 0.4838 | 0.9921 | 0.52% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 747.0000 | 73.0000 | 10.2329 | 425.8329 ± 1.0760 | 425.2673 ± 2.2379 | 1.0013 | 0.25% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 754.0000 | 73.0000 | 10.3288 | 425.7029 ± 0.3483 | 426.1767 ± 0.6730 | 0.9989 | 0.08% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 740.0000 | 71.0000 | 10.4225 | 425.0359 ± 2.0025 | 423.7541 ± 0.2420 | 1.0030 | 0.47% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 740.0000 | 69.0000 | 10.7246 | 422.7726 ± 0.5372 | 424.3064 ± 1.0741 | 0.9964 | 0.13% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4677 |
| Geometric mean runtime ratio (L0/GCC) | 0.9997 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
