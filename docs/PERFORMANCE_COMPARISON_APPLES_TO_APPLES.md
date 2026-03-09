# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-03-09T04:01:39Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 701.0000 | 61.0000 | 11.4918 | 415.9391 ± 0.9361 | 414.4562 ± 1.8975 | 1.0036 | 0.23% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 689.0000 | 60.0000 | 11.4833 | 411.9474 ± 3.9817 | 410.8642 ± 1.6212 | 1.0026 | 0.97% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 677.0000 | 60.0000 | 11.2833 | 408.1681 ± 0.8525 | 410.7691 ± 1.1447 | 0.9937 | 0.21% | ok |
| and (2-arg) | `tests/valid_and.l0` | 672.0000 | 61.0000 | 11.0164 | 409.4602 ± 1.9262 | 411.7911 ± 0.3726 | 0.9943 | 0.47% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 666.0000 | 60.0000 | 11.1000 | 412.0343 ± 0.7533 | 410.0619 ± 3.4022 | 1.0048 | 0.18% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 683.0000 | 62.0000 | 11.0161 | 411.6088 ± 0.4824 | 412.7570 ± 0.4162 | 0.9972 | 0.12% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 683.0000 | 62.0000 | 11.0161 | 411.0890 ± 0.9732 | 410.8555 ± 0.6389 | 1.0006 | 0.24% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 677.0000 | 61.0000 | 11.0984 | 409.9070 ± 1.3482 | 409.1942 ± 0.7858 | 1.0017 | 0.33% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 666.0000 | 59.0000 | 11.2881 | 411.4094 ± 2.8893 | 414.0872 ± 0.5859 | 0.9935 | 0.70% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.1978 |
| Geometric mean runtime ratio (L0/GCC) | 0.9991 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
