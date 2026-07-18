# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-18T05:34:42Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 683.0000 | 57.0000 | 11.9825 | 300.6704 ± 0.1684 | 300.7816 ± 0.8665 | 0.9996 | 0.06% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 683.0000 | 57.0000 | 11.9825 | 302.4818 ± 0.7289 | 305.4430 ± 0.7078 | 0.9903 | 0.24% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 666.0000 | 57.0000 | 11.6842 | 297.4423 ± 2.0917 | 310.6115 ± 3.0551 | 0.9576 | 0.70% | ok |
| and (2-arg) | `tests/valid_and.l0` | 683.0000 | 58.0000 | 11.7759 | 304.1303 ± 1.0842 | 304.9090 ± 1.0248 | 0.9974 | 0.36% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 666.0000 | 58.0000 | 11.4828 | 302.6787 ± 3.9677 | 305.7969 ± 1.7474 | 0.9898 | 1.31% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 661.0000 | 59.0000 | 11.2034 | 305.9502 ± 1.1486 | 298.5015 ± 1.4634 | 1.0250 | 0.38% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 672.0000 | 60.0000 | 11.2000 | 305.9215 ± 0.6128 | 304.6332 ± 0.2492 | 1.0042 | 0.20% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 672.0000 | 61.0000 | 11.0164 | 303.7567 ± 0.3625 | 302.4116 ± 0.6124 | 1.0044 | 0.12% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 666.0000 | 58.0000 | 11.4828 | 311.3046 ± 2.5540 | 312.6100 ± 1.8049 | 0.9958 | 0.82% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.5298 |
| Geometric mean runtime ratio (L0/GCC) | 0.9959 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
