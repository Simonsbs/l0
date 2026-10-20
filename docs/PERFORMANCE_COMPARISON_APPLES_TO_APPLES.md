# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-20T08:27:42Z`
- host: `runnervm8k3b6`
- kernel: `Linux 6.17.0-1022-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 941.0000 | 83.0000 | 11.3373 | 381.0604 ± 2.6265 | 379.5571 ± 1.8842 | 1.0040 | 0.69% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 919.0000 | 82.0000 | 11.2073 | 381.0529 ± 4.3344 | 429.3526 ± 21.2302 | 0.8875 | 1.14% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 930.0000 | 82.0000 | 11.3415 | 465.6506 ± 2.9813 | 464.8637 ± 13.9510 | 1.0017 | 0.64% | ok |
| and (2-arg) | `tests/valid_and.l0` | 919.0000 | 80.0000 | 11.4875 | 376.9857 ± 1.6138 | 401.3243 ± 9.1142 | 0.9394 | 0.43% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 941.0000 | 81.0000 | 11.6173 | 376.6004 ± 4.0862 | 433.4883 ± 8.3117 | 0.8688 | 1.09% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 930.0000 | 82.0000 | 11.3415 | 412.8617 ± 23.5646 | 374.5206 ± 7.2755 | 1.1024 | 5.71% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 941.0000 | 82.0000 | 11.4756 | 373.4965 ± 2.0602 | 375.9914 ± 8.3757 | 0.9934 | 0.55% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 909.0000 | 80.0000 | 11.3625 | 379.0856 ± 2.6921 | 375.6877 ± 5.8891 | 1.0090 | 0.71% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 919.0000 | 79.0000 | 11.6329 | 499.2906 ± 9.1957 | 507.5293 ± 8.7628 | 0.9838 | 1.84% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.4218 |
| Geometric mean runtime ratio (L0/GCC) | 0.9744 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
