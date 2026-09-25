# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-25T08:46:09Z`
- host: `runnervmtr4k5`
- kernel: `Linux 6.17.0-1022-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `AMD EPYC 9V45 96-Core Processor`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 869.0000 | 96.0000 | 9.0521 | 439.2105 ± 1.1863 | 437.7143 ± 0.9111 | 1.0034 | 0.27% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 95.0000 | 7.8632 | 440.7865 ± 1.3233 | 440.6771 ± 3.2525 | 1.0002 | 0.30% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 851.0000 | 93.0000 | 9.1505 | 440.3492 ± 2.6134 | 439.8732 ± 3.2329 | 1.0011 | 0.59% | ok |
| and (2-arg) | `tests/valid_and.l0` | 842.0000 | 93.0000 | 9.0538 | 461.9719 ± 9.4361 | 463.6388 ± 1.9937 | 0.9964 | 2.04% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 879.0000 | 93.0000 | 9.4516 | 436.2868 ± 1.7023 | 436.2575 ± 0.4107 | 1.0001 | 0.39% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 733.0000 | 81.0000 | 9.0494 | 450.8183 ± 8.3871 | 443.1568 ± 3.1292 | 1.0173 | 1.86% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 909.0000 | 96.0000 | 9.4688 | 457.9855 ± 8.7038 | 454.8392 ± 7.9870 | 1.0069 | 1.90% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 879.0000 | 96.0000 | 9.1562 | 462.0812 ± 1.9153 | 463.6609 ± 4.9442 | 0.9966 | 0.41% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 919.0000 | 97.0000 | 9.4742 | 459.3751 ± 6.9803 | 467.2213 ± 3.5466 | 0.9832 | 1.52% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 9.0673 |
| Geometric mean runtime ratio (L0/GCC) | 1.0005 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
