# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-06T10:47:28Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 677.0000 | 59.0000 | 11.4746 | 410.9939 ± 1.5374 | 409.1257 ± 3.6224 | 1.0046 | 0.37% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 666.0000 | 61.0000 | 10.9180 | 417.6021 ± 0.9695 | 417.2185 ± 0.9839 | 1.0009 | 0.23% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 629.0000 | 63.0000 | 9.9841 | 421.1136 ± 1.3168 | 421.4135 ± 0.2085 | 0.9993 | 0.31% | ok |
| and (2-arg) | `tests/valid_and.l0` | 655.0000 | 63.0000 | 10.3968 | 419.1435 ± 0.4503 | 418.9817 ± 0.4853 | 1.0004 | 0.11% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 666.0000 | 63.0000 | 10.5714 | 419.8102 ± 1.5320 | 418.6853 ± 0.4554 | 1.0027 | 0.36% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 672.0000 | 64.0000 | 10.5000 | 419.4135 ± 1.1803 | 419.8553 ± 1.7114 | 0.9989 | 0.28% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 672.0000 | 64.0000 | 10.5000 | 417.0225 ± 0.2633 | 417.5307 ± 0.2312 | 0.9988 | 0.06% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 645.0000 | 63.0000 | 10.2381 | 417.9238 ± 0.6621 | 417.1027 ± 0.3779 | 1.0020 | 0.16% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 615.0000 | 60.0000 | 10.2500 | 418.3176 ± 1.4945 | 418.4341 ± 0.8640 | 0.9997 | 0.36% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5292 |
| Geometric mean runtime ratio (L0/GCC) | 1.0008 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
