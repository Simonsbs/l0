# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-23T08:28:45Z`
- host: `runnervm8k3b6`
- kernel: `Linux 6.17.0-1022-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 740.0000 | 79.0000 | 9.3671 | 368.2848 ± 1.0970 | 369.9311 ± 1.0611 | 0.9955 | 0.30% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 754.0000 | 79.0000 | 9.5443 | 374.8728 ± 3.4141 | 375.9480 ± 0.8910 | 0.9971 | 0.91% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 754.0000 | 79.0000 | 9.5443 | 381.5815 ± 2.5933 | 386.6655 ± 2.4245 | 0.9869 | 0.68% | ok |
| and (2-arg) | `tests/valid_and.l0` | 754.0000 | 79.0000 | 9.5443 | 371.2107 ± 0.5882 | 379.0856 ± 4.1234 | 0.9792 | 0.16% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 761.0000 | 78.0000 | 9.7564 | 371.8892 ± 2.3376 | 376.7384 ± 2.0590 | 0.9871 | 0.63% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 747.0000 | 80.0000 | 9.3375 | 384.8143 ± 1.7544 | 374.3125 ± 1.9373 | 1.0281 | 0.46% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 761.0000 | 80.0000 | 9.5125 | 376.6077 ± 1.7041 | 375.0384 ± 2.4302 | 1.0042 | 0.45% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 754.0000 | 80.0000 | 9.4250 | 364.6271 ± 4.4779 | 362.1056 ± 1.0453 | 1.0070 | 1.23% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 733.0000 | 77.0000 | 9.5195 | 387.2636 ± 2.1310 | 389.1230 ± 2.6161 | 0.9952 | 0.55% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 9.5049 |
| Geometric mean runtime ratio (L0/GCC) | 0.9977 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
