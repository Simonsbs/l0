# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-03-10T03:56:32Z`
- host: `runnervm0kj6c`
- kernel: `Linux 6.14.0-1017-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 689.0000 | 68.0000 | 10.1324 | 419.3775 ± 1.1111 | 419.3145 ± 1.1266 | 1.0002 | 0.26% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 707.0000 | 69.0000 | 10.2464 | 417.6289 ± 1.3795 | 418.9817 ± 0.6493 | 0.9968 | 0.33% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 683.0000 | 69.0000 | 9.8986 | 419.0446 ± 1.8702 | 419.2785 ± 0.1968 | 0.9994 | 0.45% | ok |
| and (2-arg) | `tests/valid_and.l0` | 689.0000 | 68.0000 | 10.1324 | 417.9953 ± 1.8054 | 417.9059 ± 1.1897 | 1.0002 | 0.43% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 689.0000 | 68.0000 | 10.1324 | 416.6578 ± 1.6505 | 418.1296 ± 0.7588 | 0.9965 | 0.40% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 689.0000 | 69.0000 | 9.9855 | 417.9774 ± 1.2142 | 418.7840 ± 0.5749 | 0.9981 | 0.29% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 695.0000 | 69.0000 | 10.0725 | 416.7734 ± 0.3751 | 417.2363 ± 0.2731 | 0.9989 | 0.09% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 689.0000 | 68.0000 | 10.1324 | 417.8880 ± 0.8440 | 418.3535 ± 1.5215 | 0.9989 | 0.20% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 683.0000 | 66.0000 | 10.3485 | 416.7911 ± 0.4831 | 417.5575 ± 0.1958 | 0.9982 | 0.12% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.1194 |
| Geometric mean runtime ratio (L0/GCC) | 0.9986 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
