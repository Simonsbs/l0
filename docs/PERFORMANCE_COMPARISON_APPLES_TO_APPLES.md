# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-21T04:52:09Z`
- host: `runnervm7b5n9`
- kernel: `Linux 6.17.0-1018-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 695.0000 | 65.0000 | 10.6923 | 306.1564 ± 0.3380 | 306.5938 ± 0.3193 | 0.9986 | 0.11% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 695.0000 | 66.0000 | 10.5303 | 308.6334 ± 1.0041 | 309.8035 ± 1.8099 | 0.9962 | 0.33% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 695.0000 | 66.0000 | 10.5303 | 306.3437 ± 1.7793 | 316.0141 ± 3.2284 | 0.9694 | 0.58% | ok |
| and (2-arg) | `tests/valid_and.l0` | 689.0000 | 66.0000 | 10.4394 | 306.6467 ± 0.4721 | 308.7408 ± 0.5564 | 0.9932 | 0.15% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 683.0000 | 65.0000 | 10.5077 | 305.3571 ± 0.6909 | 307.6805 ± 1.0862 | 0.9924 | 0.23% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 701.0000 | 67.0000 | 10.4627 | 312.4600 ± 0.5508 | 304.2393 ± 0.0813 | 1.0270 | 0.18% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 695.0000 | 67.0000 | 10.3731 | 304.8995 ± 0.1231 | 304.9328 ± 0.6507 | 0.9999 | 0.04% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 689.0000 | 66.0000 | 10.4394 | 305.2998 ± 1.0467 | 305.0519 ± 0.4893 | 1.0008 | 0.34% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 677.0000 | 65.0000 | 10.4154 | 313.0761 ± 0.4899 | 313.2468 ± 0.5885 | 0.9995 | 0.16% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4875 |
| Geometric mean runtime ratio (L0/GCC) | 0.9973 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
