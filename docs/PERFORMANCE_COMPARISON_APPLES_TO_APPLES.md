# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-03T06:32:27Z`
- host: `runnervmvrwv9`
- kernel: `Linux 6.17.0-1020-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 754.0000 | 70.0000 | 10.7714 | 420.4881 ± 1.5411 | 422.6080 ± 0.8487 | 0.9950 | 0.37% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 69.0000 | 10.8261 | 422.4252 ± 2.5287 | 422.3978 ± 1.4631 | 1.0001 | 0.60% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 733.0000 | 68.0000 | 10.7794 | 422.3430 ± 1.3897 | 420.6783 ± 2.0915 | 1.0040 | 0.33% | ok |
| and (2-arg) | `tests/valid_and.l0` | 727.0000 | 66.0000 | 11.0152 | 420.5243 ± 5.9902 | 418.8200 ± 3.4747 | 1.0041 | 1.42% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 720.0000 | 68.0000 | 10.5882 | 422.2699 ± 0.3050 | 422.4800 ± 0.3913 | 0.9995 | 0.07% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 701.0000 | 69.0000 | 10.1594 | 416.2227 ± 2.2988 | 419.5307 ± 1.0747 | 0.9921 | 0.55% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 720.0000 | 68.0000 | 10.5882 | 421.8595 ± 0.4644 | 423.0565 ± 0.6933 | 0.9972 | 0.11% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 727.0000 | 69.0000 | 10.5362 | 421.7775 ± 0.4338 | 423.3132 ± 0.5191 | 0.9964 | 0.10% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 714.0000 | 66.0000 | 10.8182 | 422.0144 ± 1.4763 | 422.9191 ± 1.2086 | 0.9979 | 0.35% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.6733 |
| Geometric mean runtime ratio (L0/GCC) | 0.9985 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
