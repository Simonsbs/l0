# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-25T12:46:13Z`
- host: `runnervm0hi8g`
- kernel: `Linux 7.0.0-1020-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 597.0000 | 56.0000 | 10.6607 | 327.4473 ± 1.5261 | 324.8549 ± 5.9298 | 1.0080 | 0.47% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 588.0000 | 59.0000 | 9.9661 | 324.5580 ± 1.4039 | 327.6890 ± 2.3038 | 0.9904 | 0.43% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 279.0000 | 60.0000 | 4.6500 | 323.1243 ± 5.6358 | 324.2078 ± 5.3026 | 0.9967 | 1.74% | ok |
| and (2-arg) | `tests/valid_and.l0` | 516.0000 | 49.0000 | 10.5306 | 327.0142 ± 0.7740 | 329.5134 ± 0.6125 | 0.9924 | 0.24% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 629.0000 | 58.0000 | 10.8448 | 327.4857 ± 1.4124 | 330.4389 ± 2.8359 | 0.9911 | 0.43% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 610.0000 | 59.0000 | 10.3390 | 331.0101 ± 2.8742 | 325.3744 ± 1.7663 | 1.0173 | 0.87% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 512.0000 | 57.0000 | 8.9825 | 319.4408 ± 1.2918 | 319.9222 ± 0.9603 | 0.9985 | 0.40% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 695.0000 | 53.0000 | 13.1132 | 319.8908 ± 0.9109 | 320.1005 ± 2.6380 | 0.9993 | 0.28% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 506.0000 | 55.0000 | 9.2000 | 325.5263 ± 1.7177 | 327.6890 ± 5.0484 | 0.9934 | 0.53% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 9.5032 |
| Geometric mean runtime ratio (L0/GCC) | 0.9985 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
