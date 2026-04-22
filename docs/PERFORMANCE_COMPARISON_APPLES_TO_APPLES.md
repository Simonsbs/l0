# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-22T04:16:37Z`
- host: `runnervmeorf1`
- kernel: `Linux 6.17.0-1010-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 689.0000 | 68.0000 | 10.1324 | 426.3441 ± 0.3060 | 424.6662 ± 0.1957 | 1.0040 | 0.07% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 70.0000 | 10.6714 | 423.0657 ± 0.5556 | 422.5257 ± 0.6105 | 1.0013 | 0.13% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 733.0000 | 71.0000 | 10.3239 | 423.3224 ± 0.6692 | 422.8825 ± 0.8162 | 1.0010 | 0.16% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 72.0000 | 10.2778 | 422.5348 ± 0.8837 | 423.7909 ± 0.1683 | 0.9970 | 0.21% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 733.0000 | 71.0000 | 10.3239 | 424.7956 ± 1.0511 | 423.8828 ± 0.3433 | 1.0022 | 0.25% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 740.0000 | 72.0000 | 10.2778 | 422.8642 ± 1.4303 | 424.4817 ± 0.6588 | 0.9962 | 0.34% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 72.0000 | 10.3750 | 423.2490 ± 0.6758 | 424.3064 ± 2.3510 | 0.9975 | 0.16% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 733.0000 | 70.0000 | 10.4714 | 425.4525 ± 1.4415 | 428.2418 ± 3.0416 | 0.9935 | 0.34% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 727.0000 | 69.0000 | 10.5362 | 425.6287 ± 0.4959 | 424.5093 ± 0.2645 | 1.0026 | 0.12% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.3755 |
| Geometric mean runtime ratio (L0/GCC) | 0.9995 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
