# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-04-11T04:05:46Z`
- host: `runnervm35a4x`
- kernel: `Linux 6.17.0-1010-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 1000.0000 | 81.0000 | 12.3457 | 373.8897 ± 3.8996 | 375.6515 ± 4.2947 | 0.9953 | 1.04% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 1000.0000 | 80.0000 | 12.5000 | 372.1018 ± 1.9397 | 467.2324 ± 47.7990 | 0.7964 | 0.52% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 1012.0000 | 81.0000 | 12.4938 | 458.0392 ± 1.6109 | 452.7936 ± 2.9401 | 1.0116 | 0.35% | ok |
| and (2-arg) | `tests/valid_and.l0` | 1000.0000 | 79.0000 | 12.6582 | 376.3319 ± 8.0473 | 414.8171 ± 9.4537 | 0.9072 | 2.14% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 1012.0000 | 78.0000 | 12.9744 | 373.5536 ± 0.4166 | 439.8237 ± 12.0682 | 0.8493 | 0.11% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 1012.0000 | 82.0000 | 12.3415 | 405.6419 ± 27.4857 | 371.5708 ± 23.0180 | 1.0917 | 6.78% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 1025.0000 | 83.0000 | 12.3494 | 369.4692 ± 1.3698 | 379.4465 ± 7.8351 | 0.9737 | 0.37% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 1012.0000 | 81.0000 | 12.4938 | 375.1104 ± 0.1110 | 371.7547 ± 2.1367 | 1.0090 | 0.03% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 975.0000 | 75.0000 | 13.0000 | 475.3633 ± 19.8230 | 505.3233 ± 24.1587 | 0.9407 | 4.17% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 12.5707 |
| Geometric mean runtime ratio (L0/GCC) | 0.9488 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
