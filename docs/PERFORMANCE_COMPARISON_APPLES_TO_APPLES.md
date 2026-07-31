# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-31T06:21:43Z`
- host: `runnervmvrwv9`
- kernel: `Linux 6.17.0-1020-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 740.0000 | 68.0000 | 10.8824 | 421.7957 ± 4.0673 | 424.7494 ± 0.9886 | 0.9930 | 0.96% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 727.0000 | 69.0000 | 10.5362 | 421.0319 ± 1.5248 | 421.0501 ± 2.2108 | 1.0000 | 0.36% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 727.0000 | 69.0000 | 10.5362 | 420.6601 ± 0.4765 | 420.7326 ± 1.2319 | 0.9998 | 0.11% | ok |
| and (2-arg) | `tests/valid_and.l0` | 720.0000 | 68.0000 | 10.5882 | 418.8020 ± 1.6797 | 420.4700 ± 0.9335 | 0.9960 | 0.40% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 720.0000 | 67.0000 | 10.7463 | 421.8868 ± 2.0396 | 422.0053 ± 0.2297 | 0.9997 | 0.48% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 720.0000 | 70.0000 | 10.2857 | 421.4044 ± 0.2473 | 420.8596 ± 0.2990 | 1.0013 | 0.06% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 720.0000 | 68.0000 | 10.5882 | 421.0955 ± 2.9509 | 420.7689 ± 0.4213 | 1.0008 | 0.70% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 714.0000 | 68.0000 | 10.5000 | 421.9506 ± 1.5138 | 422.4800 ± 0.6146 | 0.9987 | 0.36% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 720.0000 | 68.0000 | 10.5882 | 421.5499 ± 0.4995 | 422.1604 ± 1.0796 | 0.9986 | 0.12% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5824 |
| Geometric mean runtime ratio (L0/GCC) | 0.9987 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
