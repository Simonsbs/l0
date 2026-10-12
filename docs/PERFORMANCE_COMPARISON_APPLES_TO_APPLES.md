# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-12T10:42:50Z`
- host: `runnervmmprz5`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 683.0000 | 60.0000 | 11.3833 | 406.5538 ± 1.9734 | 408.0913 ± 0.7089 | 0.9962 | 0.49% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 683.0000 | 60.0000 | 11.3833 | 407.6739 ± 0.0434 | 409.5031 ± 1.6781 | 0.9955 | 0.01% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 689.0000 | 60.0000 | 11.4833 | 406.9434 ± 0.7765 | 404.7005 ± 0.6657 | 1.0055 | 0.19% | ok |
| and (2-arg) | `tests/valid_and.l0` | 672.0000 | 60.0000 | 11.2000 | 410.2342 ± 3.1329 | 406.4184 ± 1.7480 | 1.0094 | 0.76% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 677.0000 | 60.0000 | 11.2833 | 407.0876 ± 0.1908 | 407.4358 ± 0.5410 | 0.9991 | 0.05% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 677.0000 | 61.0000 | 11.0984 | 407.9634 ± 1.7968 | 407.1895 ± 1.4399 | 1.0019 | 0.44% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 689.0000 | 61.0000 | 11.2951 | 410.8296 ± 3.7308 | 407.2149 ± 4.3831 | 1.0089 | 0.91% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 695.0000 | 61.0000 | 11.3934 | 409.7436 ± 2.0525 | 408.4412 ± 0.5597 | 1.0032 | 0.50% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 672.0000 | 58.0000 | 11.5862 | 407.6824 ± 1.4437 | 406.4100 ± 1.1452 | 1.0031 | 0.35% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.3443 |
| Geometric mean runtime ratio (L0/GCC) | 1.0025 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
