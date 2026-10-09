# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-09T10:28:46Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 707.0000 | 69.0000 | 10.2464 | 423.5703 ± 1.7362 | 424.4540 ± 0.2428 | 0.9979 | 0.41% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 701.0000 | 69.0000 | 10.1594 | 420.8505 ± 2.9145 | 425.2025 ± 3.5430 | 0.9898 | 0.69% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 695.0000 | 66.0000 | 10.5303 | 421.1318 ± 1.7834 | 419.0356 ± 1.2078 | 1.0050 | 0.42% | ok |
| and (2-arg) | `tests/valid_and.l0` | 683.0000 | 64.0000 | 10.6719 | 420.7870 ± 0.3813 | 419.2065 ± 0.9592 | 1.0038 | 0.09% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 677.0000 | 64.0000 | 10.5781 | 418.8200 ± 1.2629 | 419.0176 ± 0.4148 | 0.9995 | 0.30% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 677.0000 | 65.0000 | 10.4154 | 413.6837 ± 0.4745 | 414.7026 ± 5.9581 | 0.9975 | 0.11% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 683.0000 | 66.0000 | 10.3485 | 416.5956 ± 0.5581 | 418.7122 ± 1.1905 | 0.9949 | 0.13% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 677.0000 | 64.0000 | 10.5781 | 415.0728 ± 3.8184 | 417.3433 ± 2.9988 | 0.9946 | 0.92% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 672.0000 | 64.0000 | 10.5000 | 417.2185 ± 1.7704 | 415.1434 ± 0.1373 | 1.0050 | 0.42% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4463 |
| Geometric mean runtime ratio (L0/GCC) | 0.9987 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
