# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-20T04:41:20Z`
- host: `runnervmrw5os`
- kernel: `Linux 6.17.0-1013-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 754.0000 | 67.0000 | 11.2537 | 423.5244 ± 1.3797 | 423.9104 ± 0.9929 | 0.9991 | 0.33% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 67.0000 | 11.1493 | 423.8093 ± 0.9263 | 424.4355 ± 0.5249 | 0.9985 | 0.22% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 733.0000 | 68.0000 | 10.7794 | 418.1833 ± 12.9823 | 423.5703 ± 1.2768 | 0.9873 | 3.10% | ok |
| and (2-arg) | `tests/valid_and.l0` | 727.0000 | 68.0000 | 10.6912 | 420.7326 ± 4.4019 | 419.9005 ± 8.0389 | 1.0020 | 1.05% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 740.0000 | 69.0000 | 10.7246 | 425.0637 ± 1.0487 | 419.4316 ± 3.5378 | 1.0134 | 0.25% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 733.0000 | 71.0000 | 10.3239 | 422.7360 ± 2.1065 | 423.1482 ± 1.0703 | 0.9990 | 0.50% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 733.0000 | 70.0000 | 10.4714 | 422.8367 ± 0.5574 | 423.4968 ± 1.0502 | 0.9984 | 0.13% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 740.0000 | 70.0000 | 10.5714 | 427.1180 ± 2.6159 | 426.0930 ± 2.0742 | 1.0024 | 0.61% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 740.0000 | 68.0000 | 10.8824 | 424.8880 ± 2.0671 | 424.8325 ± 0.1602 | 1.0001 | 0.49% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.7571 |
| Geometric mean runtime ratio (L0/GCC) | 1.0000 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
