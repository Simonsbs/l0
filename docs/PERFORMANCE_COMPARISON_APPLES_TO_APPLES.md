# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-13T08:15:40Z`
- host: `runnervmlun5p`
- kernel: `Linux 6.17.0-1022-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 727.0000 | 63.0000 | 11.5397 | 411.3314 ± 2.6805 | 407.3338 ± 1.6539 | 1.0098 | 0.65% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 727.0000 | 64.0000 | 11.3594 | 412.8443 ± 5.5965 | 348.8035 ± 40.9559 | 1.1836 | 1.36% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 720.0000 | 65.0000 | 11.0769 | 419.5126 ± 0.7164 | 418.3893 ± 4.6577 | 1.0027 | 0.17% | ok |
| and (2-arg) | `tests/valid_and.l0` | 707.0000 | 61.0000 | 11.5902 | 413.0451 ± 0.7072 | 414.8524 ± 2.0751 | 0.9956 | 0.17% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 707.0000 | 62.0000 | 11.4032 | 406.7400 ± 0.8258 | 408.1766 ± 3.5893 | 0.9965 | 0.20% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 695.0000 | 62.0000 | 11.2097 | 416.1695 ± 1.3120 | 417.2631 ± 4.0161 | 0.9974 | 0.32% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 714.0000 | 62.0000 | 11.5161 | 416.2848 ± 1.3599 | 416.5334 ± 2.7076 | 0.9994 | 0.33% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 714.0000 | 63.0000 | 11.3333 | 417.2363 ± 3.7080 | 419.6118 ± 1.4482 | 0.9943 | 0.89% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 714.0000 | 61.0000 | 11.7049 | 417.8076 ± 1.9302 | 418.6225 ± 1.8933 | 0.9981 | 0.46% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.4133 |
| Geometric mean runtime ratio (L0/GCC) | 1.0182 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
