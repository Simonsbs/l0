# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-28T04:43:51Z`
- host: `runnervmg397c`
- kernel: `Linux 6.17.0-1013-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 714.0000 | 67.0000 | 10.6567 | 306.7575 ± 1.2533 | 306.8780 ± 1.7012 | 0.9996 | 0.41% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 689.0000 | 66.0000 | 10.4394 | 305.6773 ± 0.6660 | 308.7115 ± 1.3417 | 0.9902 | 0.22% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 689.0000 | 66.0000 | 10.4394 | 305.6677 ± 0.4209 | 315.1879 ± 1.3528 | 0.9698 | 0.14% | ok |
| and (2-arg) | `tests/valid_and.l0` | 683.0000 | 66.0000 | 10.3485 | 306.1804 ± 0.4456 | 307.7144 ± 1.7832 | 0.9950 | 0.15% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 707.0000 | 66.0000 | 10.7121 | 305.9838 ± 1.9308 | 307.5448 ± 1.9558 | 0.9949 | 0.63% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 695.0000 | 67.0000 | 10.3731 | 311.9161 ± 1.7655 | 306.5649 ± 1.5369 | 1.0175 | 0.57% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 701.0000 | 66.0000 | 10.6212 | 305.4001 ± 0.3316 | 305.8975 ± 1.1969 | 0.9984 | 0.11% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 707.0000 | 66.0000 | 10.7121 | 307.3319 ± 1.0146 | 306.3197 ± 0.5835 | 1.0033 | 0.33% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 677.0000 | 63.0000 | 10.7460 | 316.1675 ± 0.7114 | 316.5211 ± 2.3596 | 0.9989 | 0.23% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5599 |
| Geometric mean runtime ratio (L0/GCC) | 0.9963 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
