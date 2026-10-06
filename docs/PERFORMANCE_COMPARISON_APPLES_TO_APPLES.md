# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-06T10:12:46Z`
- host: `runnervm8df0l`
- kernel: `Linux 6.17.0-1022-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `INTEL(R) XEON(R) PLATINUM 8573C`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 792.0000 | 81.0000 | 9.7778 | 646.0242 ± 19.6612 | 599.4123 ± 19.3084 | 1.0778 | 3.04% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 869.0000 | 85.0000 | 10.2235 | 590.2641 ± 8.7827 | 603.3937 ± 7.9236 | 0.9782 | 1.49% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 824.0000 | 82.0000 | 10.0488 | 612.0922 ± 8.9328 | 610.2943 ± 10.5131 | 1.0029 | 1.46% | ok |
| and (2-arg) | `tests/valid_and.l0` | 879.0000 | 85.0000 | 10.3412 | 624.4605 ± 18.7481 | 676.0791 ± 12.6204 | 0.9237 | 3.00% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 851.0000 | 86.0000 | 9.8953 | 636.4873 ± 16.6018 | 684.3465 ± 10.1692 | 0.9301 | 2.61% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 851.0000 | 90.0000 | 9.4556 | 647.2874 ± 38.8443 | 630.7932 ± 8.6903 | 1.0261 | 6.00% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 824.0000 | 84.0000 | 9.8095 | 616.2638 ± 16.8912 | 649.5909 ± 7.2596 | 0.9487 | 2.74% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 860.0000 | 88.0000 | 9.7727 | 614.4801 ± 13.8988 | 607.8631 ± 11.9350 | 1.0109 | 2.26% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 800.0000 | 83.0000 | 9.6386 | 613.7849 ± 44.7585 | 663.3355 ± 9.6515 | 0.9253 | 7.29% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 9.8813 |
| Geometric mean runtime ratio (L0/GCC) | 0.9791 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
