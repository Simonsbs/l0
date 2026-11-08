# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-08T10:14:22Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 677.0000 | 63.0000 | 10.7460 | 419.2695 ± 0.7721 | 419.0446 ± 0.2315 | 1.0005 | 0.18% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 677.0000 | 63.0000 | 10.7460 | 416.3025 ± 1.7337 | 417.8433 ± 0.9083 | 0.9963 | 0.42% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 672.0000 | 63.0000 | 10.6667 | 415.8593 ± 2.0782 | 419.5667 ± 0.8004 | 0.9912 | 0.50% | ok |
| and (2-arg) | `tests/valid_and.l0` | 655.0000 | 63.0000 | 10.3968 | 420.7145 ± 1.2617 | 421.4044 ± 1.7147 | 0.9984 | 0.30% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 666.0000 | 63.0000 | 10.5714 | 420.5333 ± 0.6843 | 420.2890 ± 0.0329 | 1.0006 | 0.16% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 661.0000 | 64.0000 | 10.3281 | 416.8890 ± 0.3724 | 418.0043 ± 2.0982 | 0.9973 | 0.09% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 666.0000 | 64.0000 | 10.4062 | 420.9593 ± 2.3260 | 421.0047 ± 0.2534 | 0.9999 | 0.55% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 645.0000 | 63.0000 | 10.2381 | 417.6467 ± 0.8901 | 417.9417 ± 2.3983 | 0.9993 | 0.21% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 655.0000 | 61.0000 | 10.7377 | 417.4950 ± 0.4711 | 418.6673 ± 0.5441 | 0.9972 | 0.11% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5358 |
| Geometric mean runtime ratio (L0/GCC) | 0.9979 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
