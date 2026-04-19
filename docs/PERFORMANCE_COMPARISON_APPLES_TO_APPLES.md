# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-19T04:19:57Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 769.0000 | 72.0000 | 10.6806 | 426.5583 ± 0.7150 | 425.0452 ± 0.3924 | 1.0036 | 0.17% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 769.0000 | 72.0000 | 10.6806 | 424.5186 ± 0.4286 | 425.9815 ± 1.3233 | 0.9966 | 0.10% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 761.0000 | 72.0000 | 10.5694 | 426.7260 ± 1.9275 | 426.6981 ± 1.5066 | 1.0001 | 0.45% | ok |
| and (2-arg) | `tests/valid_and.l0` | 754.0000 | 71.0000 | 10.6197 | 423.8093 ± 0.9223 | 424.5093 ± 1.1255 | 0.9984 | 0.22% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 754.0000 | 72.0000 | 10.4722 | 425.2117 ± 0.7125 | 425.7215 ± 1.1211 | 0.9988 | 0.17% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 747.0000 | 72.0000 | 10.3750 | 425.3043 ± 0.9648 | 425.4525 ± 0.7618 | 0.9997 | 0.23% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 733.0000 | 72.0000 | 10.1806 | 422.7452 ± 2.0060 | 422.3886 ± 1.3178 | 1.0008 | 0.47% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 747.0000 | 71.0000 | 10.5211 | 425.9071 ± 1.8549 | 424.6478 ± 1.2798 | 1.0030 | 0.44% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 747.0000 | 68.0000 | 10.9853 | 424.8140 ± 0.8941 | 424.9065 ± 0.6511 | 0.9998 | 0.21% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5628 |
| Geometric mean runtime ratio (L0/GCC) | 1.0001 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
