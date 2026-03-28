# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-03-28T04:03:56Z`
- host: `runnervmrg6be`
- kernel: `Linux 6.17.0-1008-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 747.0000 | 67.0000 | 11.1493 | 422.5531 ± 0.7387 | 422.3704 ± 1.8607 | 1.0004 | 0.17% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 733.0000 | 67.0000 | 10.9403 | 421.0138 ± 0.9111 | 419.0536 ± 0.9169 | 1.0047 | 0.22% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 740.0000 | 66.0000 | 11.2121 | 425.3321 ± 2.0021 | 424.7124 ± 0.4924 | 1.0015 | 0.47% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 67.0000 | 11.0448 | 419.0176 ± 3.4656 | 420.0811 ± 2.2705 | 0.9975 | 0.83% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 733.0000 | 66.0000 | 11.1061 | 422.1330 ± 0.4694 | 424.6385 ± 0.3032 | 0.9941 | 0.11% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 740.0000 | 68.0000 | 10.8824 | 419.1885 ± 6.0619 | 422.0418 ± 4.1493 | 0.9932 | 1.45% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 740.0000 | 67.0000 | 11.0448 | 419.1255 ± 3.2879 | 420.6148 ± 3.4042 | 0.9965 | 0.78% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 747.0000 | 66.0000 | 11.3182 | 419.8824 ± 0.9156 | 415.9125 ± 1.3100 | 1.0095 | 0.22% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 733.0000 | 66.0000 | 11.1061 | 424.1222 ± 0.6042 | 422.7360 ± 0.8757 | 1.0033 | 0.14% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.0886 |
| Geometric mean runtime ratio (L0/GCC) | 1.0001 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
