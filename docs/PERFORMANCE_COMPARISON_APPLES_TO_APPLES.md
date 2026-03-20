# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-03-20T03:59:39Z`
- host: `runnervm46oaq`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 677.0000 | 56.0000 | 12.0893 | 412.7221 ± 0.4786 | 411.6175 ± 0.6922 | 1.0027 | 0.12% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 666.0000 | 61.0000 | 10.9180 | 414.1135 ± 1.9581 | 411.9822 ± 0.5358 | 1.0052 | 0.47% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 650.0000 | 61.0000 | 10.6557 | 412.4607 ± 1.1262 | 412.2604 ± 0.7908 | 1.0005 | 0.27% | ok |
| and (2-arg) | `tests/valid_and.l0` | 666.0000 | 60.0000 | 11.1000 | 408.8944 ± 1.9790 | 411.1236 ± 0.7853 | 0.9946 | 0.48% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 661.0000 | 62.0000 | 10.6613 | 413.1587 ± 0.5912 | 416.4002 ± 0.5788 | 0.9922 | 0.14% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 661.0000 | 61.0000 | 10.8361 | 411.5568 ± 4.6170 | 410.3118 ± 1.7211 | 1.0030 | 1.12% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 661.0000 | 61.0000 | 10.8361 | 412.4955 ± 1.6368 | 411.1582 ± 0.5694 | 1.0033 | 0.40% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 655.0000 | 60.0000 | 10.9167 | 412.2343 ± 2.1272 | 412.6088 ± 0.6214 | 0.9991 | 0.52% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 666.0000 | 60.0000 | 11.1000 | 412.5129 ± 0.6548 | 412.0517 ± 0.9114 | 1.0011 | 0.16% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.0053 |
| Geometric mean runtime ratio (L0/GCC) | 1.0002 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
