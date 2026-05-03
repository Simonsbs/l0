# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-03T04:31:54Z`
- host: `runnervmeorf1`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 769.0000 | 67.0000 | 11.4776 | 424.1038 ± 0.7555 | 426.8846 ± 1.0357 | 0.9935 | 0.18% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 761.0000 | 67.0000 | 11.3582 | 423.1482 ± 5.1691 | 422.1330 ± 1.5432 | 1.0024 | 1.22% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 769.0000 | 68.0000 | 11.3088 | 421.2226 ± 1.0785 | 422.2790 ± 0.3485 | 0.9975 | 0.26% | ok |
| and (2-arg) | `tests/valid_and.l0` | 784.0000 | 69.0000 | 11.3623 | 418.7212 ± 5.9967 | 421.1772 ± 4.2637 | 0.9942 | 1.43% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 747.0000 | 67.0000 | 11.1493 | 421.7684 ± 1.9716 | 421.4680 ± 1.4546 | 1.0007 | 0.47% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 727.0000 | 68.0000 | 10.6912 | 424.2696 ± 0.5343 | 424.0117 ± 1.4128 | 1.0006 | 0.13% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 761.0000 | 70.0000 | 10.8714 | 422.1056 ± 0.0664 | 424.0577 ± 0.1198 | 0.9954 | 0.02% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 727.0000 | 66.0000 | 11.0152 | 420.6420 ± 6.5121 | 411.5915 ± 6.5189 | 1.0220 | 1.55% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 733.0000 | 65.0000 | 11.2769 | 417.0671 ± 3.0931 | 416.8089 ± 1.9896 | 1.0006 | 0.74% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.1652 |
| Geometric mean runtime ratio (L0/GCC) | 1.0007 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
