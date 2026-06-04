# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-04T04:51:43Z`
- host: `runnervm3jyl0`
- kernel: `Linux 6.17.0-1015-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 707.0000 | 66.0000 | 10.7121 | 306.0557 ± 0.5876 | 305.9023 ± 0.3326 | 1.0005 | 0.19% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 720.0000 | 66.0000 | 10.9091 | 305.7203 ± 0.4258 | 307.8793 ± 0.4492 | 0.9930 | 0.14% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 720.0000 | 66.0000 | 10.9091 | 306.1133 ± 0.8346 | 313.0911 ± 2.9216 | 0.9777 | 0.27% | ok |
| and (2-arg) | `tests/valid_and.l0` | 689.0000 | 65.0000 | 10.6000 | 305.6486 ± 1.6767 | 306.3870 ± 1.8491 | 0.9976 | 0.55% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 683.0000 | 63.0000 | 10.8413 | 305.3237 ± 0.0383 | 307.1724 ± 1.5649 | 0.9940 | 0.01% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 689.0000 | 66.0000 | 10.4394 | 313.4227 ± 0.7782 | 305.7969 ± 0.6007 | 1.0249 | 0.25% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 707.0000 | 67.0000 | 10.5522 | 306.8346 ± 0.7883 | 306.6901 ± 0.0489 | 1.0005 | 0.26% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 701.0000 | 65.0000 | 10.7846 | 306.4302 ± 0.0503 | 306.3581 ± 0.3562 | 1.0002 | 0.02% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 683.0000 | 63.0000 | 10.8413 | 312.7001 ± 0.3140 | 315.3100 ± 2.1358 | 0.9917 | 0.10% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.7310 |
| Geometric mean runtime ratio (L0/GCC) | 0.9977 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
