# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-29T09:53:06Z`
- host: `runnervm48cm3`
- kernel: `Linux 7.0.0-1017-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 733.0000 | 78.0000 | 9.3974 | 607.2961 ± 13.4230 | 591.2827 ± 7.4922 | 1.0271 | 2.21% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 784.0000 | 77.0000 | 10.1818 | 631.0582 ± 15.9164 | 643.9369 ± 49.1083 | 0.9800 | 2.52% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 784.0000 | 75.0000 | 10.4533 | 586.2951 ± 7.1431 | 592.8621 ± 7.0983 | 0.9889 | 1.22% | ok |
| and (2-arg) | `tests/valid_and.l0` | 842.0000 | 76.0000 | 11.0789 | 646.0242 ± 15.7614 | 666.4591 ± 17.1166 | 0.9693 | 2.44% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 860.0000 | 76.0000 | 11.3158 | 618.4886 ± 16.5823 | 627.2279 ± 34.7981 | 0.9861 | 2.68% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 792.0000 | 76.0000 | 10.4211 | 605.1135 ± 17.0870 | 577.9502 ± 20.0332 | 1.0470 | 2.82% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 80.0000 | 9.3375 | 587.6181 ± 17.4957 | 630.4267 ± 20.0881 | 0.9321 | 2.98% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 816.0000 | 76.0000 | 10.7368 | 608.7346 ± 9.0131 | 597.4138 ± 8.8278 | 1.0189 | 1.48% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 816.0000 | 76.0000 | 10.7368 | 606.0524 ± 6.4979 | 599.4123 ± 24.8227 | 1.0111 | 1.07% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.3863 |
| Geometric mean runtime ratio (L0/GCC) | 0.9951 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
