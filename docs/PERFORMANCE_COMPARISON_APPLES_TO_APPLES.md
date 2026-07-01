# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-01T04:49:05Z`
- host: `runnervmmklqx`
- kernel: `Linux 6.17.0-1018-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `AMD EPYC 7763 64-Core Processor`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 754.0000 | 72.0000 | 10.4722 | 425.0637 ± 1.2717 | 426.6049 ± 1.1409 | 0.9964 | 0.30% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 761.0000 | 72.0000 | 10.5694 | 425.0174 ± 0.7435 | 425.3877 ± 0.6757 | 0.9991 | 0.17% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 71.0000 | 10.5211 | 424.0853 ± 0.4135 | 423.9841 ± 1.4873 | 1.0002 | 0.10% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 71.0000 | 10.4225 | 424.3341 ± 0.7414 | 423.1207 ± 0.6540 | 1.0029 | 0.17% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 747.0000 | 70.0000 | 10.6714 | 425.7400 ± 1.8065 | 426.4000 ± 0.1960 | 0.9985 | 0.42% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 761.0000 | 73.0000 | 10.4247 | 425.8700 ± 0.6707 | 426.2790 ± 0.9276 | 0.9990 | 0.16% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 754.0000 | 73.0000 | 10.3288 | 423.6070 ± 0.0888 | 424.4724 ± 0.2504 | 0.9980 | 0.02% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 733.0000 | 71.0000 | 10.3239 | 425.2117 ± 0.8416 | 425.1654 ± 0.6249 | 1.0001 | 0.20% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 740.0000 | 69.0000 | 10.7246 | 425.1562 ± 1.2672 | 425.1562 ± 0.5952 | 1.0000 | 0.30% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4946 |
| Geometric mean runtime ratio (L0/GCC) | 0.9994 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
