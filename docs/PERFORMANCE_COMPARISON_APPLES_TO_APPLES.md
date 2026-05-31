# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-31T04:48:02Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 701.0000 | 59.0000 | 11.8814 | 301.1247 ± 1.8476 | 301.1944 ± 1.3338 | 0.9998 | 0.61% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 701.0000 | 60.0000 | 11.6833 | 305.2187 ± 1.7845 | 307.0710 ± 3.2282 | 0.9940 | 0.58% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 689.0000 | 59.0000 | 11.6780 | 305.3953 ± 0.1050 | 312.5500 ± 4.2879 | 0.9771 | 0.03% | ok |
| and (2-arg) | `tests/valid_and.l0` | 689.0000 | 64.0000 | 10.7656 | 305.4526 ± 0.0655 | 307.3174 ± 1.4354 | 0.9939 | 0.02% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 701.0000 | 65.0000 | 10.7846 | 304.4859 ± 1.3834 | 308.7554 ± 1.1555 | 0.9862 | 0.45% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 695.0000 | 63.0000 | 11.0317 | 313.4781 ± 0.1400 | 306.2476 ± 0.5649 | 1.0236 | 0.04% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 689.0000 | 63.0000 | 10.9365 | 306.1181 ± 0.3735 | 304.6949 ± 0.8675 | 1.0047 | 0.12% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 683.0000 | 60.0000 | 11.3833 | 303.3085 ± 1.8284 | 302.1402 ± 2.2328 | 1.0039 | 0.60% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 672.0000 | 58.0000 | 11.5862 | 314.3307 ± 1.1986 | 312.0158 ± 1.1970 | 1.0074 | 0.38% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.2961 |
| Geometric mean runtime ratio (L0/GCC) | 0.9989 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
