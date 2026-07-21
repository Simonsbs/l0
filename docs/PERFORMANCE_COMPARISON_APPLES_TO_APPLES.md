# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-21T06:04:19Z`
- host: `runnervm3jd5f`
- kernel: `Linux 6.17.0-1020-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 683.0000 | 64.0000 | 10.6719 | 303.4829 ± 0.2607 | 304.7377 ± 1.0485 | 0.9959 | 0.09% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 701.0000 | 65.0000 | 10.7846 | 303.4122 ± 0.0629 | 306.2861 ± 0.2396 | 0.9906 | 0.02% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 689.0000 | 65.0000 | 10.6000 | 304.0404 ± 0.7136 | 311.9559 ± 0.0673 | 0.9746 | 0.23% | ok |
| and (2-arg) | `tests/valid_and.l0` | 683.0000 | 64.0000 | 10.6719 | 305.2903 ± 0.3659 | 307.6272 ± 0.3697 | 0.9924 | 0.12% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 689.0000 | 64.0000 | 10.7656 | 305.6725 ± 0.2851 | 309.4304 ± 1.3213 | 0.9879 | 0.09% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 677.0000 | 64.0000 | 10.5781 | 311.0666 ± 0.4298 | 304.6237 ± 0.1486 | 1.0212 | 0.14% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 677.0000 | 63.0000 | 10.7460 | 304.7139 ± 0.3894 | 304.8471 ± 0.5520 | 0.9996 | 0.13% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 683.0000 | 60.0000 | 11.3833 | 302.6646 ± 0.8286 | 303.4876 ± 1.8047 | 0.9973 | 0.27% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 677.0000 | 61.0000 | 11.0984 | 312.2552 ± 0.7923 | 315.1676 ± 1.2787 | 0.9908 | 0.25% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.8083 |
| Geometric mean runtime ratio (L0/GCC) | 0.9944 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
