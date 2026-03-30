# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-03-30T04:16:56Z`
- host: `runnervmrg6be`
- kernel: `Linux 6.17.0-1008-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 761.0000 | 72.0000 | 10.5694 | 423.3958 ± 1.2370 | 424.7309 ± 1.9854 | 0.9969 | 0.29% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 761.0000 | 71.0000 | 10.7183 | 425.7679 ± 0.2637 | 425.8329 ± 0.1761 | 0.9998 | 0.06% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 733.0000 | 71.0000 | 10.3239 | 424.6570 ± 0.1487 | 425.1840 ± 0.4452 | 0.9988 | 0.04% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 71.0000 | 10.4225 | 424.3894 ± 1.0620 | 426.4186 ± 0.6109 | 0.9952 | 0.25% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 747.0000 | 71.0000 | 10.5211 | 426.1209 ± 0.4187 | 426.0837 ± 0.2118 | 1.0001 | 0.10% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 747.0000 | 73.0000 | 10.2329 | 425.8607 ± 0.9364 | 426.0837 ± 0.3440 | 0.9995 | 0.22% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 72.0000 | 10.3750 | 425.0544 ± 2.6431 | 425.4525 ± 1.0437 | 0.9991 | 0.62% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 754.0000 | 71.0000 | 10.6197 | 425.0267 ± 2.5481 | 426.6887 ± 0.4980 | 0.9961 | 0.60% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 747.0000 | 69.0000 | 10.8261 | 426.1767 ± 1.7293 | 425.3228 ± 1.4680 | 1.0020 | 0.41% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5105 |
| Geometric mean runtime ratio (L0/GCC) | 0.9986 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
