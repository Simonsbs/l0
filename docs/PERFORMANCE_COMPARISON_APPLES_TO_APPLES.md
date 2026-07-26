# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-26T06:13:16Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 754.0000 | 70.0000 | 10.7714 | 423.0199 ± 0.8930 | 421.4226 ± 2.3957 | 1.0038 | 0.21% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 740.0000 | 71.0000 | 10.4225 | 422.7177 ± 0.2917 | 422.7452 ± 0.6710 | 0.9999 | 0.07% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 70.0000 | 10.6714 | 423.2307 ± 2.4593 | 423.8461 ± 1.3874 | 0.9985 | 0.58% | ok |
| and (2-arg) | `tests/valid_and.l0` | 747.0000 | 70.0000 | 10.6714 | 422.8825 ± 0.5010 | 423.2307 ± 1.1081 | 0.9992 | 0.12% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 740.0000 | 71.0000 | 10.4225 | 423.5703 ± 0.3655 | 423.9012 ± 0.5145 | 0.9992 | 0.09% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 747.0000 | 72.0000 | 10.3750 | 423.5336 ± 0.7587 | 423.1665 ± 0.9543 | 1.0009 | 0.18% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 71.0000 | 10.5211 | 421.8048 ± 0.8366 | 422.2973 ± 0.4760 | 0.9988 | 0.20% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 733.0000 | 70.0000 | 10.4714 | 422.3978 ± 0.9169 | 422.0418 ± 0.9250 | 1.0008 | 0.22% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 733.0000 | 69.0000 | 10.6232 | 423.0199 ± 1.3298 | 424.5462 ± 0.1618 | 0.9964 | 0.31% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5492 |
| Geometric mean runtime ratio (L0/GCC) | 0.9997 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
