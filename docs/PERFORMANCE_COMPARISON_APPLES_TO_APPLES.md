# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-28T15:18:26Z`
- host: `runnervmgx7h7`
- kernel: `Linux 6.17.0-1022-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `AMD EPYC 9V74 80-Core Processor`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 677.0000 | 65.0000 | 10.4154 | 304.3057 ± 0.5705 | 304.5287 ± 0.2597 | 0.9993 | 0.19% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 689.0000 | 66.0000 | 10.4394 | 304.6759 ± 0.4153 | 307.2594 ± 1.4446 | 0.9916 | 0.14% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 672.0000 | 65.0000 | 10.3385 | 304.1777 ± 0.5281 | 315.2388 ± 1.0076 | 0.9649 | 0.17% | ok |
| and (2-arg) | `tests/valid_and.l0` | 672.0000 | 65.0000 | 10.3385 | 305.5195 ± 0.3084 | 308.1173 ± 1.1729 | 0.9916 | 0.10% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 672.0000 | 65.0000 | 10.3385 | 304.7900 ± 0.6869 | 305.7969 ± 0.4952 | 0.9967 | 0.23% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 672.0000 | 66.0000 | 10.1818 | 310.4831 ± 1.6934 | 304.1540 ± 0.5880 | 1.0208 | 0.55% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 677.0000 | 66.0000 | 10.2576 | 308.1708 ± 0.3991 | 304.1824 ± 0.2964 | 1.0131 | 0.13% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 677.0000 | 65.0000 | 10.4154 | 304.3863 ± 0.4809 | 305.5721 ± 0.1635 | 0.9961 | 0.16% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 677.0000 | 63.0000 | 10.7460 | 313.4328 ± 0.9549 | 314.9237 ± 0.1938 | 0.9953 | 0.30% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.3846 |
| Geometric mean runtime ratio (L0/GCC) | 0.9965 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
