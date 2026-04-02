# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-02T04:08:24Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 769.0000 | 69.0000 | 11.1449 | 424.2880 ± 0.5983 | 424.0025 ± 2.6729 | 1.0007 | 0.14% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 761.0000 | 70.0000 | 10.8714 | 423.9289 ± 1.1023 | 424.2511 ± 1.1132 | 0.9992 | 0.26% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 761.0000 | 69.0000 | 11.0290 | 427.0993 ± 0.2751 | 426.5862 ± 0.8772 | 1.0012 | 0.06% | ok |
| and (2-arg) | `tests/valid_and.l0` | 754.0000 | 70.0000 | 10.7714 | 425.1377 ± 0.3407 | 425.5452 ± 0.4991 | 0.9990 | 0.08% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 747.0000 | 69.0000 | 10.8261 | 423.6346 ± 3.9568 | 425.3506 ± 4.5402 | 0.9960 | 0.93% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 747.0000 | 72.0000 | 10.3750 | 425.3414 ± 0.2279 | 426.2232 ± 1.0134 | 0.9979 | 0.05% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 754.0000 | 71.0000 | 10.6197 | 425.9071 ± 1.6421 | 426.7167 ± 0.3890 | 0.9981 | 0.39% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 747.0000 | 70.0000 | 10.6714 | 424.8048 ± 1.1451 | 424.3710 ± 1.7721 | 1.0010 | 0.27% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 740.0000 | 67.0000 | 11.0448 | 424.2788 ± 1.1743 | 424.6293 ± 0.1905 | 0.9992 | 0.28% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.8147 |
| Geometric mean runtime ratio (L0/GCC) | 0.9991 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
