# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-14T04:58:50Z`
- host: `runnervmvrwv9`
- kernel: `Linux 6.17.0-1020-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 769.0000 | 77.0000 | 9.9870 | 571.4735 ± 24.0373 | 591.1037 ± 5.2683 | 0.9668 | 4.21% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 851.0000 | 74.0000 | 11.5000 | 583.4752 ± 11.9881 | 603.4123 ± 14.4741 | 0.9670 | 2.05% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 879.0000 | 74.0000 | 11.8784 | 574.1277 ± 6.8538 | 616.6530 ± 10.3868 | 0.9310 | 1.19% | ok |
| and (2-arg) | `tests/valid_and.l0` | 714.0000 | 77.0000 | 9.2727 | 569.0592 ± 8.3663 | 595.0658 ± 13.7424 | 0.9563 | 1.47% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 747.0000 | 74.0000 | 10.0946 | 564.8952 ± 12.4424 | 606.6924 ± 6.7691 | 0.9311 | 2.20% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 761.0000 | 77.0000 | 9.8831 | 607.0885 ± 15.8770 | 555.0385 ± 22.3204 | 1.0938 | 2.62% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 842.0000 | 77.0000 | 10.9351 | 561.6786 ± 5.5044 | 540.4629 ± 11.4928 | 1.0393 | 0.98% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 860.0000 | 76.0000 | 11.3158 | 562.8116 ± 10.3234 | 577.5742 ± 3.1912 | 0.9744 | 1.83% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 701.0000 | 73.0000 | 9.6027 | 568.9763 ± 5.7165 | 594.9752 ± 7.1928 | 0.9563 | 1.00% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4605 |
| Geometric mean runtime ratio (L0/GCC) | 0.9783 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
