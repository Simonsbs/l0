# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-03-02T15:40:42Z`
- host: `SimonsLaptop`
- kernel: `Linux 6.17.0-14-generic x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `11th Gen Intel(R) Core(TM) i7-11800H @ 2.30GHz`
- cpu_topology: `CPU(s)=16 Thread(s) per core=2 Core(s) per socket=8 Socket(s)=1`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 1355.0000 | 97.0000 | 13.9691 | 717.4540 ± 7.8454 | 732.4951 ± 12.8856 | 0.9795 | 1.09% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 1355.0000 | 97.0000 | 13.9691 | 699.6937 ± 7.9636 | 729.5129 ± 32.6060 | 0.9591 | 1.14% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 1333.0000 | 97.0000 | 13.7423 | 714.6974 ± 4.7287 | 736.3059 ± 22.3921 | 0.9707 | 0.66% | ok |
| and (2-arg) | `tests/valid_and.l0` | 1333.0000 | 96.0000 | 13.8854 | 702.6641 ± 9.3154 | 720.7635 ± 2.1222 | 0.9749 | 1.33% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 1355.0000 | 97.0000 | 13.9691 | 706.9624 ± 1.4264 | 751.4620 ± 18.3150 | 0.9408 | 0.20% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 1355.0000 | 97.0000 | 13.9691 | 738.7567 ± 6.9411 | 748.0372 ± 16.2484 | 0.9876 | 0.94% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 1333.0000 | 97.0000 | 13.7423 | 749.8176 ± 14.4530 | 750.9420 ± 29.6980 | 0.9985 | 1.93% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 1379.0000 | 97.0000 | 14.2165 | 710.4081 ± 33.9106 | 728.5605 ± 10.8587 | 0.9751 | 4.77% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 1311.0000 | 93.0000 | 14.0968 | 649.7206 ± 20.1684 | 649.1807 ± 24.3999 | 1.0008 | 3.10% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 13.9503 |
| Geometric mean runtime ratio (L0/GCC) | 0.9762 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
