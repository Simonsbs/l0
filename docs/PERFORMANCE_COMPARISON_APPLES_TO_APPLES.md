# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-09-18T08:12:01Z`
- host: `runnervmlun5p`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 707.0000 | 60.0000 | 11.7833 | 400.6492 ± 1.6437 | 398.9063 ± 3.1884 | 1.0044 | 0.41% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 701.0000 | 60.0000 | 11.6833 | 414.1926 ± 0.8201 | 413.2286 ± 2.8086 | 1.0023 | 0.20% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 707.0000 | 59.0000 | 11.9831 | 405.4903 ± 3.6975 | 407.1216 ± 3.7704 | 0.9960 | 0.91% | ok |
| and (2-arg) | `tests/valid_and.l0` | 707.0000 | 62.0000 | 11.4032 | 415.0287 ± 0.6193 | 412.2778 ± 3.3105 | 1.0067 | 0.15% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 720.0000 | 60.0000 | 12.0000 | 412.8792 ± 2.9431 | 413.9468 ± 0.8771 | 0.9974 | 0.71% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 707.0000 | 62.0000 | 11.4032 | 413.0538 ± 2.3061 | 414.2892 ± 1.1177 | 0.9970 | 0.56% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 707.0000 | 62.0000 | 11.4032 | 406.4776 ± 3.8230 | 405.2547 ± 2.2293 | 1.0030 | 0.94% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 695.0000 | 59.0000 | 11.7797 | 412.3910 ± 1.7740 | 410.3376 ± 2.1891 | 1.0050 | 0.43% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 707.0000 | 59.0000 | 11.9831 | 403.8637 ± 0.4103 | 402.9139 ± 0.7790 | 1.0024 | 0.10% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.7111 |
| Geometric mean runtime ratio (L0/GCC) | 1.0016 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
