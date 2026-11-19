# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-19T11:32:26Z`
- host: `runnervmccnms`
- kernel: `Linux 7.0.0-1019-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0`
- cpu_model: `AMD EPYC 9V45 96-Core Processor`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 851.0000 | 84.0000 | 10.1310 | 398.0040 ± 5.7024 | 402.0679 ± 2.8025 | 0.9899 | 1.43% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 888.0000 | 85.0000 | 10.4471 | 402.8225 ± 0.7178 | 402.9804 ± 1.2018 | 0.9996 | 0.18% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 869.0000 | 85.0000 | 10.2235 | 402.7892 ± 0.3351 | 402.1010 ± 1.4413 | 1.0017 | 0.08% | ok |
| and (2-arg) | `tests/valid_and.l0` | 898.0000 | 85.0000 | 10.5647 | 402.9139 ± 0.2600 | 402.6481 ± 0.5425 | 1.0007 | 0.06% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 888.0000 | 85.0000 | 10.4471 | 403.1883 ± 4.2560 | 402.0679 ± 3.4342 | 1.0028 | 1.06% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 879.0000 | 86.0000 | 10.2209 | 400.5506 ± 1.3164 | 401.5388 ± 1.0651 | 0.9975 | 0.33% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 888.0000 | 87.0000 | 10.2069 | 398.6051 ± 2.9314 | 401.7866 ± 0.2565 | 0.9921 | 0.74% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 860.0000 | 85.0000 | 10.1176 | 397.9797 ± 3.3190 | 399.6491 ± 2.7093 | 0.9958 | 0.83% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 898.0000 | 85.0000 | 10.5647 | 401.5223 ± 1.4106 | 401.1924 ± 2.4328 | 1.0008 | 0.35% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.3234 |
| Geometric mean runtime ratio (L0/GCC) | 0.9979 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
