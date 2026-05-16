# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-16T04:24:36Z`
- host: `runnervmrw5os`
- kernel: `Linux 6.17.0-1013-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 761.0000 | 70.0000 | 10.8714 | 426.6514 ± 1.6070 | 427.1180 ± 0.8631 | 0.9989 | 0.38% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 70.0000 | 10.6714 | 427.3890 ± 0.2561 | 427.4264 ± 2.3487 | 0.9999 | 0.06% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 740.0000 | 71.0000 | 10.4225 | 427.2768 ± 2.5534 | 426.9032 ± 2.4281 | 1.0009 | 0.60% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 70.0000 | 10.5714 | 424.7494 ± 1.2387 | 424.9434 ± 0.6206 | 0.9995 | 0.29% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 747.0000 | 69.0000 | 10.8261 | 425.0637 ± 2.0582 | 426.5396 ± 0.5869 | 0.9965 | 0.48% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 733.0000 | 72.0000 | 10.1806 | 428.9189 ± 2.4678 | 428.7682 ± 0.5358 | 1.0004 | 0.58% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 72.0000 | 10.3750 | 427.2581 ± 1.6477 | 427.0432 ± 1.3211 | 1.0005 | 0.39% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 740.0000 | 71.0000 | 10.4225 | 425.0267 ± 1.0614 | 426.3441 ± 0.3035 | 0.9969 | 0.25% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 727.0000 | 69.0000 | 10.5362 | 425.6287 ± 0.1831 | 425.8793 ± 0.8861 | 0.9994 | 0.04% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5398 |
| Geometric mean runtime ratio (L0/GCC) | 0.9992 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
