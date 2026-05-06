# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-06T04:26:31Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 784.0000 | 72.0000 | 10.8889 | 428.7118 ± 1.8147 | 428.8530 ± 0.1828 | 0.9997 | 0.42% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 792.0000 | 72.0000 | 11.0000 | 427.1180 ± 3.9039 | 426.3255 ± 2.3884 | 1.0019 | 0.91% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 769.0000 | 71.0000 | 10.8310 | 418.8739 ± 3.9276 | 416.6933 ± 1.0732 | 1.0052 | 0.94% | ok |
| and (2-arg) | `tests/valid_and.l0` | 769.0000 | 72.0000 | 10.6806 | 427.3890 ± 1.1028 | 428.0728 ± 0.2215 | 0.9984 | 0.26% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 769.0000 | 71.0000 | 10.8310 | 426.3348 ± 1.9414 | 425.0082 ± 1.0781 | 1.0031 | 0.46% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 761.0000 | 72.0000 | 10.5694 | 420.8596 ± 0.9191 | 419.3865 ± 1.3134 | 1.0035 | 0.22% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 761.0000 | 72.0000 | 10.5694 | 426.1581 ± 1.2272 | 426.6981 ± 1.4438 | 0.9987 | 0.29% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 761.0000 | 71.0000 | 10.7183 | 426.7633 ± 1.8254 | 425.2858 ± 2.4540 | 1.0035 | 0.43% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 747.0000 | 68.0000 | 10.9853 | 425.7679 ± 1.1805 | 425.0082 ± 2.0231 | 1.0018 | 0.28% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.7849 |
| Geometric mean runtime ratio (L0/GCC) | 1.0018 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
