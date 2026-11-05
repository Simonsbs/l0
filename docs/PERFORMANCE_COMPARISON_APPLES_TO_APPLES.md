# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-05T10:47:34Z`
- host: `runnervm7aw5e`
- kernel: `Linux 7.0.0-1017-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 677.0000 | 63.0000 | 10.7460 | 420.2709 ± 1.8790 | 420.3433 ± 0.1609 | 0.9998 | 0.45% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 683.0000 | 62.0000 | 11.0161 | 420.4428 ± 0.0462 | 418.8379 ± 1.6900 | 1.0038 | 0.01% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 683.0000 | 63.0000 | 10.8413 | 419.0986 ± 0.7743 | 417.6825 ± 1.3665 | 1.0034 | 0.18% | ok |
| and (2-arg) | `tests/valid_and.l0` | 672.0000 | 62.0000 | 10.8387 | 420.7054 ± 2.0523 | 420.0449 ± 0.5746 | 1.0016 | 0.49% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 677.0000 | 63.0000 | 10.7460 | 418.6135 ± 0.3189 | 418.4790 ± 0.7483 | 1.0003 | 0.08% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 683.0000 | 64.0000 | 10.6719 | 420.1534 ± 1.5236 | 418.7212 ± 3.1607 | 1.0034 | 0.36% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 677.0000 | 64.0000 | 10.5781 | 419.1435 ± 1.1566 | 418.7661 ± 1.5150 | 1.0009 | 0.28% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 683.0000 | 63.0000 | 10.8413 | 417.5128 ± 1.8721 | 417.4593 ± 1.6431 | 1.0001 | 0.45% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 672.0000 | 61.0000 | 11.0164 | 417.7450 ± 2.0947 | 415.8239 ± 0.4215 | 1.0046 | 0.50% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.8098 |
| Geometric mean runtime ratio (L0/GCC) | 1.0020 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
