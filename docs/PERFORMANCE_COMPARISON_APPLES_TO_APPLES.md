# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-14T04:51:52Z`
- host: `runnervm1li68`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 740.0000 | 65.0000 | 11.3846 | 422.4617 ± 0.5244 | 423.4509 ± 1.0086 | 0.9977 | 0.12% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 727.0000 | 68.0000 | 10.6912 | 419.7471 ± 3.3527 | 422.0965 ± 1.6999 | 0.9944 | 0.80% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 727.0000 | 68.0000 | 10.6912 | 422.9741 ± 1.5816 | 421.1863 ± 3.0973 | 1.0042 | 0.37% | ok |
| and (2-arg) | `tests/valid_and.l0` | 733.0000 | 68.0000 | 10.7794 | 421.9233 ± 0.6959 | 421.0410 ± 1.9558 | 1.0021 | 0.16% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 733.0000 | 67.0000 | 10.9403 | 421.1136 ± 2.3637 | 420.4157 ± 0.9882 | 1.0017 | 0.56% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 733.0000 | 69.0000 | 10.6232 | 418.9457 ± 2.6411 | 417.1829 ± 2.2735 | 1.0042 | 0.63% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 727.0000 | 64.0000 | 11.3594 | 420.0811 ± 0.3403 | 417.3077 ± 2.7617 | 1.0066 | 0.08% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 733.0000 | 68.0000 | 10.7794 | 413.0102 ± 0.7712 | 415.9036 ± 0.1072 | 0.9930 | 0.19% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 720.0000 | 67.0000 | 10.7463 | 420.8958 ± 1.8951 | 421.4135 ± 0.8010 | 0.9988 | 0.45% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.8850 |
| Geometric mean runtime ratio (L0/GCC) | 1.0003 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
