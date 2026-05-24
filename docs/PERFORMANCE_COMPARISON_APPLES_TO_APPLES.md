# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-24T04:42:17Z`
- host: `runnervmg397c`
- kernel: `Linux 6.17.0-1013-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 754.0000 | 70.0000 | 10.7714 | 425.9443 ± 1.0557 | 425.0729 ± 1.0730 | 1.0021 | 0.25% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 754.0000 | 71.0000 | 10.6197 | 425.3692 ± 0.2814 | 425.9350 ± 2.8011 | 0.9987 | 0.07% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 754.0000 | 71.0000 | 10.6197 | 425.8050 ± 0.6961 | 425.2395 ± 0.3457 | 1.0013 | 0.16% | ok |
| and (2-arg) | `tests/valid_and.l0` | 747.0000 | 70.0000 | 10.6714 | 425.1192 ± 0.9003 | 425.0914 ± 0.7180 | 1.0001 | 0.21% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 747.0000 | 70.0000 | 10.6714 | 423.4876 ± 0.9683 | 424.6847 ± 0.8942 | 0.9972 | 0.23% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 747.0000 | 72.0000 | 10.3750 | 425.1562 ± 0.5030 | 425.2580 ± 0.1512 | 0.9998 | 0.12% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 72.0000 | 10.3750 | 424.7956 ± 0.6406 | 424.7494 ± 0.4984 | 1.0001 | 0.15% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 747.0000 | 71.0000 | 10.5211 | 425.0267 ± 1.0493 | 424.2235 ± 0.5973 | 1.0019 | 0.25% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 740.0000 | 70.0000 | 10.5714 | 422.9374 ± 1.5224 | 424.7956 ± 0.5069 | 0.9956 | 0.36% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5766 |
| Geometric mean runtime ratio (L0/GCC) | 0.9996 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
