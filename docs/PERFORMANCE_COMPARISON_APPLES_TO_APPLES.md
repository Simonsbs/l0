# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-20T04:42:56Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 720.0000 | 64.0000 | 11.2500 | 303.9931 ± 0.7402 | 305.4430 ± 1.1112 | 0.9953 | 0.24% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 695.0000 | 62.0000 | 11.2097 | 305.7299 ± 0.6117 | 306.4591 ± 0.2074 | 0.9976 | 0.20% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 689.0000 | 65.0000 | 10.6000 | 303.7661 ± 0.0466 | 318.5239 ± 0.5630 | 0.9537 | 0.02% | ok |
| and (2-arg) | `tests/valid_and.l0` | 695.0000 | 64.0000 | 10.8594 | 304.7663 ± 0.7139 | 307.5497 ± 0.7256 | 0.9909 | 0.23% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 689.0000 | 65.0000 | 10.6000 | 306.6708 ± 0.4513 | 307.1144 ± 1.6585 | 0.9986 | 0.15% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 683.0000 | 66.0000 | 10.3485 | 313.3875 ± 0.1871 | 304.9233 ± 0.4417 | 1.0278 | 0.06% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 689.0000 | 66.0000 | 10.4394 | 304.5382 ± 0.5684 | 305.1662 ± 0.0891 | 0.9979 | 0.19% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 683.0000 | 64.0000 | 10.6719 | 304.9852 ± 0.4324 | 305.2950 ± 0.6091 | 0.9990 | 0.14% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 677.0000 | 63.0000 | 10.7460 | 311.7120 ± 0.3221 | 312.7752 ± 1.9648 | 0.9966 | 0.10% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.7432 |
| Geometric mean runtime ratio (L0/GCC) | 0.9951 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
