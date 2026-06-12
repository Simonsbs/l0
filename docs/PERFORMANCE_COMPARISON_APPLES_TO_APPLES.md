# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-12T04:51:42Z`
- host: `runnervm1li68`
- kernel: `Linux 6.17.0-1018-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 987.0000 | 79.0000 | 12.4937 | 377.5906 ± 2.3322 | 379.1592 ± 5.7778 | 0.9959 | 0.62% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 987.0000 | 77.0000 | 12.8182 | 378.3000 ± 7.6918 | 473.4389 ± 22.2264 | 0.7990 | 2.03% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 963.0000 | 77.0000 | 12.5065 | 460.6427 ± 6.7864 | 459.5696 ± 1.4886 | 1.0023 | 1.47% | ok |
| and (2-arg) | `tests/valid_and.l0` | 975.0000 | 78.0000 | 12.5000 | 372.3998 ± 1.5997 | 458.4262 ± 26.5442 | 0.8123 | 0.43% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 975.0000 | 77.0000 | 12.6623 | 366.1034 ± 0.3514 | 455.5075 ± 42.8709 | 0.8037 | 0.10% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 987.0000 | 80.0000 | 12.3375 | 413.3335 ± 26.5313 | 376.2884 ± 4.0417 | 1.0984 | 6.42% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 1000.0000 | 79.0000 | 12.6582 | 372.5560 ± 0.8948 | 381.0827 ± 4.7946 | 0.9776 | 0.24% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 975.0000 | 77.0000 | 12.6623 | 375.8322 ± 2.2707 | 375.3267 ± 1.5937 | 1.0013 | 0.60% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 930.0000 | 75.0000 | 12.4000 | 503.2790 ± 13.4478 | 512.7658 ± 4.7589 | 0.9815 | 2.67% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 12.5590 |
| Geometric mean runtime ratio (L0/GCC) | 0.9356 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
