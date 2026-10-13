# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-13T10:30:21Z`
- host: `runnervmmprz5`
- kernel: `Linux 6.17.0-1022-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 707.0000 | 70.0000 | 10.1000 | 427.3609 ± 0.4042 | 426.9406 ± 0.6008 | 1.0010 | 0.09% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 707.0000 | 71.0000 | 9.9577 | 425.4804 ± 0.5766 | 425.7215 ± 0.9816 | 0.9994 | 0.14% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 695.0000 | 70.0000 | 9.9286 | 424.1406 ± 0.9579 | 425.8793 ± 1.7274 | 0.9959 | 0.23% | ok |
| and (2-arg) | `tests/valid_and.l0` | 695.0000 | 71.0000 | 9.7887 | 426.0372 ± 0.2352 | 425.4155 ± 1.2325 | 1.0015 | 0.06% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 695.0000 | 70.0000 | 9.9286 | 425.9443 ± 0.7904 | 426.3720 ± 0.2891 | 0.9990 | 0.19% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 683.0000 | 71.0000 | 9.6197 | 423.1115 ± 1.8317 | 426.1860 ± 0.9591 | 0.9928 | 0.43% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 677.0000 | 71.0000 | 9.5352 | 426.0651 ± 0.5183 | 424.5186 ± 1.1999 | 1.0036 | 0.12% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 695.0000 | 71.0000 | 9.7887 | 425.3969 ± 0.2694 | 425.6936 ± 0.2071 | 0.9993 | 0.06% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 689.0000 | 68.0000 | 10.1324 | 425.6751 ± 1.1321 | 424.4448 ± 1.4946 | 1.0029 | 0.27% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 9.8626 |
| Geometric mean runtime ratio (L0/GCC) | 0.9995 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
