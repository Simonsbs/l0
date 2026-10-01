# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-01T10:03:58Z`
- host: `runnervm8df0l`
- kernel: `Linux 6.17.0-1022-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 116.0000 | 49.0000 | 2.3673 | 441.7436 ± 0.7351 | 438.0972 ± 5.3044 | 1.0083 | 0.17% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 454.0000 | 62.0000 | 7.3226 | 461.7644 ± 6.9842 | 462.0922 ± 1.3544 | 0.9993 | 1.51% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 322.0000 | 68.0000 | 4.7353 | 432.7008 ± 2.3294 | 435.0913 ± 3.3731 | 0.9945 | 0.54% | ok |
| and (2-arg) | `tests/valid_and.l0` | 197.0000 | 62.0000 | 3.1774 | 421.2226 ± 1.3126 | 420.9412 ± 4.9820 | 1.0007 | 0.31% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 476.0000 | 59.0000 | 8.0678 | 434.2111 ± 2.8248 | 430.7825 ± 2.1060 | 1.0080 | 0.65% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 316.0000 | 37.0000 | 8.5405 | 453.9828 ± 3.4333 | 449.7904 ± 4.7733 | 1.0093 | 0.76% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 220.0000 | 36.0000 | 6.1111 | 423.9933 ± 3.5505 | 429.6643 ± 1.1182 | 0.9868 | 0.84% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 164.0000 | 51.0000 | 3.2157 | 428.9377 ± 7.6301 | 429.4565 ± 2.0474 | 0.9988 | 1.78% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 610.0000 | 62.0000 | 9.8387 | 434.2690 ± 4.7556 | 430.5546 ± 4.6274 | 1.0086 | 1.10% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 5.3305 |
| Geometric mean runtime ratio (L0/GCC) | 1.0016 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
