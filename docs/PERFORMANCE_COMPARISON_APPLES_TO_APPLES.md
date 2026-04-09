# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-09T04:09:27Z`
- host: `runnervm35a4x`
- kernel: `Linux 6.17.0-1010-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 769.0000 | 69.0000 | 11.1449 | 423.8001 ± 2.0877 | 425.5360 ± 0.9409 | 0.9959 | 0.49% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 761.0000 | 69.0000 | 11.0290 | 427.0339 ± 1.6595 | 427.3048 ± 0.9016 | 0.9994 | 0.39% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 769.0000 | 69.0000 | 11.1449 | 427.0246 ± 2.0045 | 428.2511 ± 3.2318 | 0.9971 | 0.47% | ok |
| and (2-arg) | `tests/valid_and.l0` | 747.0000 | 70.0000 | 10.6714 | 414.9141 ± 3.5925 | 415.8593 ± 2.8992 | 0.9977 | 0.87% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 747.0000 | 69.0000 | 10.8261 | 423.9933 ± 0.5312 | 423.1115 ± 1.0162 | 1.0021 | 0.13% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 747.0000 | 70.0000 | 10.6714 | 422.7269 ± 0.5235 | 424.1038 ± 1.1688 | 0.9968 | 0.12% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 70.0000 | 10.6714 | 424.3618 ± 0.2504 | 423.4968 ± 1.1008 | 1.0020 | 0.06% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 727.0000 | 69.0000 | 10.5362 | 426.5490 ± 2.2776 | 426.7913 ± 1.5412 | 0.9994 | 0.53% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 740.0000 | 67.0000 | 11.0448 | 426.1116 ± 0.5904 | 424.0485 ± 0.7585 | 1.0049 | 0.14% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.8578 |
| Geometric mean runtime ratio (L0/GCC) | 0.9995 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
