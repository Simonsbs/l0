# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-22T08:29:13Z`
- host: `runnervmlun5p`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 683.0000 | 64.0000 | 10.6719 | 305.0614 ± 1.4799 | 304.3673 ± 0.8415 | 1.0023 | 0.49% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 689.0000 | 64.0000 | 10.7656 | 304.7805 ± 1.0172 | 305.4574 ± 1.1419 | 0.9978 | 0.33% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 672.0000 | 64.0000 | 10.5000 | 302.3179 ± 0.2649 | 313.3573 ± 2.2260 | 0.9648 | 0.09% | ok |
| and (2-arg) | `tests/valid_and.l0` | 677.0000 | 65.0000 | 10.4154 | 305.5290 ± 0.8155 | 306.0125 ± 1.4391 | 0.9984 | 0.27% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 683.0000 | 65.0000 | 10.5077 | 305.2426 ± 0.1982 | 306.5168 ± 0.5995 | 0.9958 | 0.06% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 695.0000 | 66.0000 | 10.5303 | 312.9757 ± 1.6040 | 305.7778 ± 0.4075 | 1.0235 | 0.51% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 683.0000 | 66.0000 | 10.3485 | 305.5290 ± 0.6874 | 304.2914 ± 0.6555 | 1.0041 | 0.22% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 683.0000 | 65.0000 | 10.5077 | 304.2109 ± 0.2439 | 305.0947 ± 0.1777 | 0.9971 | 0.08% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 672.0000 | 64.0000 | 10.5000 | 313.2568 ± 3.4193 | 313.1162 ± 0.7614 | 1.0004 | 1.09% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5268 |
| Geometric mean runtime ratio (L0/GCC) | 0.9981 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
