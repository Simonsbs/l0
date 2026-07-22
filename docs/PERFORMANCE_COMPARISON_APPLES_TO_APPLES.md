# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-22T06:03:06Z`
- host: `runnervm3jd5f`
- kernel: `Linux 6.17.0-1020-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `Intel(R) Xeon(R) 6973P-C`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 588.0000 | 57.0000 | 10.3158 | 462.9136 ± 9.6465 | 490.7842 ± 12.7287 | 0.9432 | 2.08% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 285.0000 | 70.0000 | 4.0714 | 550.4241 ± 10.9004 | 514.0614 ± 29.3915 | 1.0707 | 1.98% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 266.0000 | 72.0000 | 3.6944 | 446.1430 ± 1.8458 | 450.2570 ± 1.0455 | 0.9909 | 0.41% | ok |
| and (2-arg) | `tests/valid_and.l0` | 640.0000 | 61.0000 | 10.4918 | 527.2731 ± 5.5026 | 527.4725 ± 10.7972 | 0.9996 | 1.04% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 784.0000 | 71.0000 | 11.0423 | 551.6835 ± 24.8343 | 534.3707 ± 2.9440 | 1.0324 | 4.50% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 824.0000 | 66.0000 | 12.4848 | 543.8036 ± 9.4321 | 496.6877 ± 12.6482 | 1.0949 | 1.73% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 879.0000 | 76.0000 | 11.5658 | 471.2343 ± 7.3625 | 539.7759 ± 17.9297 | 0.8730 | 1.56% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 941.0000 | 86.0000 | 10.9419 | 548.7385 ± 9.5787 | 548.3226 ± 6.1102 | 1.0008 | 1.75% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 465.0000 | 76.0000 | 6.1184 | 547.6614 ± 22.9605 | 530.9136 ± 4.8776 | 1.0315 | 4.19% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 8.2329 |
| Geometric mean runtime ratio (L0/GCC) | 1.0021 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
