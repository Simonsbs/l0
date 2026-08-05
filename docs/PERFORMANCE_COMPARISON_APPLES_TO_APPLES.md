# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-05T05:59:08Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 747.0000 | 70.0000 | 10.6714 | 420.8414 ± 2.0471 | 422.0783 ± 0.5227 | 0.9971 | 0.49% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 740.0000 | 69.0000 | 10.7246 | 423.4509 ± 1.2761 | 424.1959 ± 0.6848 | 0.9982 | 0.30% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 733.0000 | 70.0000 | 10.4714 | 420.8596 ± 0.6997 | 423.2215 ± 0.6530 | 0.9944 | 0.17% | ok |
| and (2-arg) | `tests/valid_and.l0` | 727.0000 | 69.0000 | 10.5362 | 422.7543 ± 0.2953 | 421.8048 ± 1.2168 | 1.0023 | 0.07% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 740.0000 | 70.0000 | 10.5714 | 423.0199 ± 0.9959 | 423.1757 ± 0.9365 | 0.9996 | 0.24% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 727.0000 | 71.0000 | 10.2394 | 423.6806 ± 0.5490 | 424.5739 ± 0.1306 | 0.9979 | 0.13% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 740.0000 | 71.0000 | 10.4225 | 421.9688 ± 0.6613 | 422.4434 ± 0.4430 | 0.9989 | 0.16% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 733.0000 | 70.0000 | 10.4714 | 422.2060 ± 0.9619 | 422.4983 ± 1.4691 | 0.9993 | 0.23% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 720.0000 | 68.0000 | 10.5882 | 422.7818 ± 1.0284 | 423.3224 ± 0.2480 | 0.9987 | 0.24% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5210 |
| Geometric mean runtime ratio (L0/GCC) | 0.9985 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
