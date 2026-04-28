# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-28T04:27:03Z`
- host: `runnervmhkfpo`
- kernel: `Linux 6.17.0-1011-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 754.0000 | 72.0000 | 10.4722 | 422.5074 ± 0.4094 | 423.2124 ± 1.5803 | 0.9983 | 0.10% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 740.0000 | 72.0000 | 10.2778 | 422.1056 ± 0.5111 | 424.0945 ± 0.1716 | 0.9953 | 0.12% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 733.0000 | 71.0000 | 10.3239 | 422.5348 ± 0.7551 | 421.7775 ± 2.7425 | 1.0018 | 0.18% | ok |
| and (2-arg) | `tests/valid_and.l0` | 733.0000 | 71.0000 | 10.3239 | 423.7817 ± 1.3062 | 424.8695 ± 1.0801 | 0.9974 | 0.31% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 740.0000 | 71.0000 | 10.4225 | 423.8645 ± 1.0171 | 422.8367 ± 0.5299 | 1.0024 | 0.24% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 733.0000 | 72.0000 | 10.1806 | 420.7326 ± 0.4943 | 423.7817 ± 0.3765 | 0.9928 | 0.12% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 740.0000 | 73.0000 | 10.1370 | 423.6530 ± 0.8258 | 424.3525 ± 0.5041 | 0.9984 | 0.19% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 740.0000 | 71.0000 | 10.4225 | 423.9381 ± 0.8400 | 425.6287 ± 1.3441 | 0.9960 | 0.20% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 740.0000 | 70.0000 | 10.5714 | 424.9157 ± 1.2064 | 425.7308 ± 0.6491 | 0.9981 | 0.28% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.3471 |
| Geometric mean runtime ratio (L0/GCC) | 0.9978 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
