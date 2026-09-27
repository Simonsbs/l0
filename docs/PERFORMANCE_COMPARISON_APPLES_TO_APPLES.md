# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-27T09:11:56Z`
- host: `runnervmtr4k5`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 689.0000 | 60.0000 | 11.4833 | 407.7420 ± 4.6068 | 417.9238 ± 3.0790 | 0.9756 | 1.13% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 661.0000 | 58.0000 | 11.3966 | 413.0102 ± 2.7346 | 411.3747 ± 1.5811 | 1.0040 | 0.66% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 661.0000 | 60.0000 | 11.0167 | 409.3743 ± 3.8861 | 409.8296 ± 3.8019 | 0.9989 | 0.95% | ok |
| and (2-arg) | `tests/valid_and.l0` | 677.0000 | 61.0000 | 11.0984 | 413.9029 ± 2.9989 | 418.5148 ± 2.7114 | 0.9890 | 0.72% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 672.0000 | 62.0000 | 10.8387 | 413.2723 ± 1.9797 | 414.1574 ± 1.0846 | 0.9979 | 0.48% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 666.0000 | 63.0000 | 10.5714 | 403.9555 ± 0.7586 | 403.8720 ± 1.5109 | 1.0002 | 0.19% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 677.0000 | 63.0000 | 10.7460 | 401.7288 ± 6.4789 | 403.0053 ± 0.3086 | 0.9968 | 1.61% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 655.0000 | 61.0000 | 10.7377 | 403.3882 ± 9.2474 | 404.6753 ± 41.8161 | 0.9968 | 2.29% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 666.0000 | 60.0000 | 11.1000 | 402.0679 ± 0.9191 | 401.7370 ± 0.3845 | 1.0008 | 0.23% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.9950 |
| Geometric mean runtime ratio (L0/GCC) | 0.9955 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
