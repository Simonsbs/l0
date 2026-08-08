# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-08T04:19:28Z`
- host: `runnervmvrwv9`
- kernel: `Linux 6.17.0-1020-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `AMD EPYC 9V74 80-Core Processor`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 677.0000 | 64.0000 | 10.5781 | 304.3483 ± 0.5818 | 304.0451 ± 3.4442 | 1.0010 | 0.19% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 677.0000 | 64.0000 | 10.5781 | 303.5159 ± 0.3150 | 306.5986 ± 0.4753 | 0.9899 | 0.10% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 672.0000 | 64.0000 | 10.5000 | 303.8654 ± 1.5016 | 312.6901 ± 0.3997 | 0.9718 | 0.49% | ok |
| and (2-arg) | `tests/valid_and.l0` | 683.0000 | 63.0000 | 10.8413 | 303.9505 ± 0.8837 | 304.7663 ± 0.5721 | 0.9973 | 0.29% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 672.0000 | 62.0000 | 10.8387 | 302.9980 ± 0.2332 | 307.4480 ± 0.0753 | 0.9855 | 0.08% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 677.0000 | 65.0000 | 10.4154 | 309.6610 ± 1.4883 | 303.6905 ± 0.3797 | 1.0197 | 0.48% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 672.0000 | 63.0000 | 10.6667 | 305.8879 ± 0.4448 | 302.6928 ± 1.2176 | 1.0106 | 0.15% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 677.0000 | 63.0000 | 10.7460 | 303.3981 ± 0.4404 | 303.1391 ± 0.8454 | 1.0009 | 0.15% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 666.0000 | 61.0000 | 10.9180 | 313.0108 ± 0.4763 | 311.7070 ± 0.6735 | 1.0042 | 0.15% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.6746 |
| Geometric mean runtime ratio (L0/GCC) | 0.9978 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
