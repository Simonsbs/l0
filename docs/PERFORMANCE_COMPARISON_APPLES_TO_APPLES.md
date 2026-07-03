# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-07-03T06:40:28Z`
- host: `runnervmkkn4f`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 727.0000 | 68.0000 | 10.6912 | 420.5152 ± 1.4548 | 421.0682 ± 1.5437 | 0.9987 | 0.35% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 727.0000 | 65.0000 | 11.1846 | 421.4680 ± 0.8673 | 420.1353 ± 0.9893 | 1.0032 | 0.21% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 720.0000 | 68.0000 | 10.5882 | 420.9684 ± 0.4624 | 421.0592 ± 0.6715 | 0.9998 | 0.11% | ok |
| and (2-arg) | `tests/valid_and.l0` | 707.0000 | 67.0000 | 10.5522 | 420.7508 ± 0.7971 | 421.7593 ± 1.2631 | 0.9976 | 0.19% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 720.0000 | 68.0000 | 10.5882 | 420.9775 ± 0.7682 | 420.7054 ± 0.8342 | 1.0006 | 0.18% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 701.0000 | 69.0000 | 10.1594 | 421.0773 ± 0.9247 | 421.8413 ± 1.1436 | 0.9982 | 0.22% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 714.0000 | 68.0000 | 10.5000 | 419.3325 ± 3.2889 | 419.6478 ± 1.5499 | 0.9992 | 0.78% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 672.0000 | 68.0000 | 9.8824 | 420.1263 ± 0.1141 | 420.4519 ± 1.4061 | 0.9992 | 0.03% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 707.0000 | 66.0000 | 10.7121 | 420.9684 ± 1.6442 | 421.5226 ± 0.8775 | 0.9987 | 0.39% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5342 |
| Geometric mean runtime ratio (L0/GCC) | 0.9995 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
