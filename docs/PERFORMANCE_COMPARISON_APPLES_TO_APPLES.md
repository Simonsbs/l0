# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-17T07:44:05Z`
- host: `runnervm8k3b6`
- kernel: `Linux 6.17.0-1022-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `INTEL(R) XEON(R) PLATINUM 8573C`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 761.0000 | 75.0000 | 10.1467 | 582.3444 ± 11.6877 | 577.9673 ± 14.6625 | 1.0076 | 2.01% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 761.0000 | 78.0000 | 9.7564 | 586.6650 ± 21.6413 | 622.0936 ± 3.4694 | 0.9430 | 3.69% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 792.0000 | 78.0000 | 10.1538 | 565.8116 ± 9.2507 | 611.2685 ± 11.4631 | 0.9256 | 1.63% | ok |
| and (2-arg) | `tests/valid_and.l0` | 727.0000 | 77.0000 | 9.4416 | 579.7688 ± 5.8768 | 614.5768 ± 14.0447 | 0.9434 | 1.01% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 769.0000 | 76.0000 | 10.1184 | 589.6938 ± 8.1772 | 596.3012 ± 11.7912 | 0.9889 | 1.39% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 754.0000 | 79.0000 | 9.5443 | 565.8936 ± 14.4413 | 577.4547 ± 7.2300 | 0.9800 | 2.55% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 78.0000 | 9.5769 | 565.8608 ± 4.7676 | 568.4960 ± 4.3551 | 0.9954 | 0.84% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 776.0000 | 78.0000 | 9.9487 | 573.1001 ± 2.6727 | 586.6473 ± 11.9763 | 0.9769 | 0.47% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 727.0000 | 74.0000 | 9.8243 | 588.8760 ± 4.2958 | 592.8441 ± 1.1162 | 0.9933 | 0.73% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 9.8311 |
| Geometric mean runtime ratio (L0/GCC) | 0.9723 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
