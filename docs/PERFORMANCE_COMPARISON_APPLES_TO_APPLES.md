# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-22T11:14:51Z`
- host: `runnervm0hi8g`
- kernel: `Linux 7.0.0-1020-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 661.0000 | 60.0000 | 11.0167 | 353.7309 ± 0.2780 | 354.0772 ± 0.3006 | 0.9990 | 0.08% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 672.0000 | 59.0000 | 11.3898 | 352.8362 ± 1.6901 | 353.3469 ± 0.9068 | 0.9986 | 0.48% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 677.0000 | 60.0000 | 11.2833 | 351.9905 ± 1.5820 | 354.1285 ± 0.6080 | 0.9940 | 0.45% | ok |
| and (2-arg) | `tests/valid_and.l0` | 661.0000 | 59.0000 | 11.2034 | 353.4236 ± 2.0239 | 353.4044 ± 1.3227 | 1.0001 | 0.57% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 661.0000 | 59.0000 | 11.2034 | 352.4288 ± 0.3462 | 351.8891 ± 1.1846 | 1.0015 | 0.10% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 650.0000 | 60.0000 | 10.8333 | 351.2183 ± 1.0154 | 350.3615 ± 2.1008 | 1.0024 | 0.29% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 650.0000 | 60.0000 | 10.8333 | 353.1616 ± 0.7890 | 355.0491 ± 1.1206 | 0.9947 | 0.22% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 666.0000 | 60.0000 | 11.1000 | 354.4434 ± 1.1349 | 355.2299 ± 0.1754 | 0.9978 | 0.32% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 661.0000 | 58.0000 | 11.3966 | 352.3525 ± 0.7454 | 352.7916 ± 1.0373 | 0.9988 | 0.21% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.1382 |
| Geometric mean runtime ratio (L0/GCC) | 0.9985 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
