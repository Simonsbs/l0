# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-27T04:36:18Z`
- host: `runnervmmklqx`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 1025.0000 | 84.0000 | 12.2024 | 380.2369 ± 8.2477 | 380.0446 ± 3.0369 | 1.0005 | 2.17% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 975.0000 | 82.0000 | 11.8902 | 378.3293 ± 2.1432 | 462.1031 ± 21.7172 | 0.8187 | 0.57% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 1000.0000 | 83.0000 | 12.0482 | 471.3253 ± 4.8532 | 467.3666 ± 1.5051 | 1.0085 | 1.03% | ok |
| and (2-arg) | `tests/valid_and.l0` | 963.0000 | 83.0000 | 11.6024 | 374.1260 ± 1.7592 | 482.9208 ± 40.4579 | 0.7747 | 0.47% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 987.0000 | 83.0000 | 11.8916 | 376.6803 ± 12.5597 | 491.2657 ± 7.6439 | 0.7668 | 3.33% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 898.0000 | 83.0000 | 10.8193 | 441.9635 ± 29.1295 | 377.4811 ± 6.3287 | 1.1708 | 6.59% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 1012.0000 | 85.0000 | 11.9059 | 377.0876 ± 1.9607 | 398.0283 ± 0.2802 | 0.9474 | 0.52% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 941.0000 | 82.0000 | 11.4756 | 376.2377 ± 1.8779 | 376.4843 ± 1.6558 | 0.9993 | 0.50% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 941.0000 | 81.0000 | 11.6173 | 509.1699 ± 14.6439 | 495.8680 ± 1.8943 | 1.0268 | 2.88% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.7105 |
| Geometric mean runtime ratio (L0/GCC) | 0.9373 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
