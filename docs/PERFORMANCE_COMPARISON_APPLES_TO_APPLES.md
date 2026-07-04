# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-04T06:27:09Z`
- host: `runnervmkkn4f`
- kernel: `Linux 6.17.0-1018-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 987.0000 | 75.0000 | 13.1600 | 373.7395 ± 8.0211 | 378.6961 ± 6.2301 | 0.9869 | 2.15% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 952.0000 | 76.0000 | 12.5263 | 370.9498 ± 0.3823 | 473.3586 ± 11.8778 | 0.7837 | 0.10% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 930.0000 | 75.0000 | 12.4000 | 453.0456 ± 3.0225 | 461.4699 ± 5.3747 | 0.9817 | 0.67% | ok |
| and (2-arg) | `tests/valid_and.l0` | 963.0000 | 78.0000 | 12.3462 | 397.1542 ± 12.1730 | 414.3859 ± 42.8615 | 0.9584 | 3.07% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 952.0000 | 77.0000 | 12.3636 | 379.3139 ± 16.2953 | 460.9906 ± 26.9473 | 0.8228 | 4.30% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 952.0000 | 79.0000 | 12.0506 | 402.6564 ± 8.3517 | 377.7001 ± 7.6782 | 1.0661 | 2.07% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 952.0000 | 78.0000 | 12.2051 | 370.6964 ± 2.0620 | 401.7288 ± 14.9410 | 0.9228 | 0.56% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 941.0000 | 77.0000 | 12.2208 | 395.8181 ± 3.2461 | 401.9189 ± 18.8896 | 0.9848 | 0.82% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 930.0000 | 74.0000 | 12.5676 | 509.2629 ± 22.0580 | 514.6303 ± 15.8982 | 0.9896 | 4.33% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 12.4231 |
| Geometric mean runtime ratio (L0/GCC) | 0.9402 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
