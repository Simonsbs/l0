# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-04T10:49:58Z`
- host: `runnervm7aw5e`
- kernel: `Linux 7.0.0-1017-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 677.0000 | 63.0000 | 10.7460 | 418.9008 ± 0.7652 | 418.9367 ± 1.1052 | 0.9999 | 0.18% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 666.0000 | 63.0000 | 10.5714 | 418.7751 ± 0.4307 | 417.6467 ± 0.6941 | 1.0027 | 0.10% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 655.0000 | 63.0000 | 10.3968 | 417.5753 ± 0.5574 | 416.9869 ± 1.0100 | 1.0014 | 0.13% | ok |
| and (2-arg) | `tests/valid_and.l0` | 666.0000 | 63.0000 | 10.5714 | 418.2101 ± 0.6941 | 418.1922 ± 0.3827 | 1.0000 | 0.17% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 661.0000 | 62.0000 | 10.6613 | 418.9188 ± 1.0768 | 419.6208 ± 1.0109 | 0.9983 | 0.26% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 650.0000 | 64.0000 | 10.1562 | 416.4002 ± 1.7142 | 418.9278 ± 0.6347 | 0.9940 | 0.41% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 666.0000 | 64.0000 | 10.4062 | 414.4474 ± 3.3003 | 417.4593 ± 0.9234 | 0.9928 | 0.80% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 655.0000 | 63.0000 | 10.3968 | 418.6404 ± 1.0192 | 416.9424 ± 0.2783 | 1.0041 | 0.24% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 661.0000 | 60.0000 | 11.0167 | 419.3055 ± 1.6301 | 418.3983 ± 1.6234 | 1.0022 | 0.39% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5444 |
| Geometric mean runtime ratio (L0/GCC) | 0.9995 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
