# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-30T09:56:32Z`
- host: `runnervm48cm3`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 689.0000 | 64.0000 | 10.7656 | 419.2695 ± 2.1117 | 420.7961 ± 1.3488 | 0.9964 | 0.50% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 672.0000 | 64.0000 | 10.5000 | 420.2980 ± 1.6321 | 419.5487 ± 0.6665 | 1.0018 | 0.39% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 666.0000 | 64.0000 | 10.4062 | 418.4341 ± 0.3842 | 419.2695 ± 0.4300 | 0.9980 | 0.09% | ok |
| and (2-arg) | `tests/valid_and.l0` | 666.0000 | 64.0000 | 10.4062 | 423.4234 ± 0.3225 | 423.1298 ± 1.1183 | 1.0007 | 0.08% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 677.0000 | 64.0000 | 10.5781 | 419.1975 ± 0.2389 | 418.3714 ± 1.1534 | 1.0020 | 0.06% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 666.0000 | 65.0000 | 10.2462 | 421.4226 ± 0.4070 | 420.4428 ± 0.5789 | 1.0023 | 0.10% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 672.0000 | 65.0000 | 10.3385 | 420.1172 ± 1.1266 | 420.9865 ± 0.7614 | 0.9979 | 0.27% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 677.0000 | 64.0000 | 10.5781 | 420.4700 ± 1.4761 | 421.1772 ± 1.0604 | 0.9983 | 0.35% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 672.0000 | 63.0000 | 10.6667 | 419.3235 ± 0.6637 | 420.4700 ± 1.4418 | 0.9973 | 0.16% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4972 |
| Geometric mean runtime ratio (L0/GCC) | 0.9994 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
