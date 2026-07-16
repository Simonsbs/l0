# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-16T05:47:51Z`
- host: `runnervm5mmn9`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 740.0000 | 68.0000 | 10.8824 | 422.4343 ± 1.7471 | 423.2124 ± 1.1673 | 0.9982 | 0.41% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 733.0000 | 68.0000 | 10.7794 | 419.5847 ± 2.8451 | 421.2226 ± 0.6313 | 0.9961 | 0.68% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 727.0000 | 66.0000 | 11.0152 | 426.0837 ± 1.5467 | 424.7863 ± 1.4267 | 1.0031 | 0.36% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 69.0000 | 10.7246 | 426.4186 ± 1.4602 | 426.4838 ± 1.2350 | 0.9998 | 0.34% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 727.0000 | 68.0000 | 10.6912 | 426.2325 ± 2.8410 | 426.2139 ± 0.7904 | 1.0000 | 0.67% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 727.0000 | 69.0000 | 10.5362 | 424.1314 ± 0.7428 | 425.7679 ± 2.9067 | 0.9962 | 0.18% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 727.0000 | 69.0000 | 10.5362 | 421.2953 ± 0.8267 | 422.2334 ± 0.4807 | 0.9978 | 0.20% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 727.0000 | 68.0000 | 10.6912 | 421.6682 ± 0.5452 | 421.9597 ± 0.3202 | 0.9993 | 0.13% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 727.0000 | 67.0000 | 10.8507 | 418.3714 ± 2.1345 | 420.1263 ± 2.5575 | 0.9958 | 0.51% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.7442 |
| Geometric mean runtime ratio (L0/GCC) | 0.9985 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
