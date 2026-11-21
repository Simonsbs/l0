# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-21T10:56:01Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 666.0000 | 60.0000 | 11.1000 | 350.7327 ± 0.9362 | 350.6508 ± 1.2959 | 1.0002 | 0.27% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 655.0000 | 58.0000 | 11.2931 | 351.9334 ± 1.7141 | 350.9091 ± 1.4815 | 1.0029 | 0.49% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 661.0000 | 59.0000 | 11.2034 | 351.5027 ± 2.2946 | 354.0001 ± 3.2503 | 0.9929 | 0.65% | ok |
| and (2-arg) | `tests/valid_and.l0` | 655.0000 | 59.0000 | 11.1017 | 355.1330 ± 2.0406 | 355.8642 ± 0.6751 | 0.9979 | 0.57% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 655.0000 | 58.0000 | 11.2931 | 351.6166 ± 0.3877 | 354.0130 ± 1.8235 | 0.9932 | 0.11% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 661.0000 | 60.0000 | 11.0167 | 352.9574 ± 2.4043 | 351.9144 ± 1.8766 | 1.0030 | 0.68% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 661.0000 | 60.0000 | 11.0167 | 352.7661 ± 1.7644 | 351.8257 ± 0.1497 | 1.0027 | 0.50% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 666.0000 | 59.0000 | 11.2881 | 353.9681 ± 0.4956 | 352.0032 ± 0.7443 | 1.0056 | 0.14% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 661.0000 | 58.0000 | 11.3966 | 353.6540 ± 0.9033 | 351.8067 ± 1.3150 | 1.0053 | 0.26% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.1892 |
| Geometric mean runtime ratio (L0/GCC) | 1.0004 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
