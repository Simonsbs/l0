# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-03-15T04:09:55Z`
- host: `runnervm46oaq`
- kernel: `Linux 6.14.0-1017-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 695.0000 | 65.0000 | 10.6923 | 414.9670 ± 3.4220 | 416.7823 ± 1.7272 | 0.9956 | 0.82% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 689.0000 | 64.0000 | 10.7656 | 414.7291 ± 2.4502 | 417.8344 ± 0.0607 | 0.9926 | 0.59% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 695.0000 | 64.0000 | 10.8594 | 416.8979 ± 0.3372 | 417.7093 ± 0.8123 | 0.9981 | 0.08% | ok |
| and (2-arg) | `tests/valid_and.l0` | 666.0000 | 63.0000 | 10.5714 | 413.0888 ± 0.5664 | 416.6400 ± 1.0473 | 0.9915 | 0.14% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 683.0000 | 64.0000 | 10.6719 | 417.3879 ± 2.7562 | 417.4593 ± 1.7099 | 0.9998 | 0.66% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 689.0000 | 65.0000 | 10.6000 | 415.6469 ± 0.5682 | 418.7571 ± 1.2200 | 0.9926 | 0.14% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 683.0000 | 66.0000 | 10.3485 | 415.8328 ± 0.6811 | 417.9774 ± 0.2926 | 0.9949 | 0.16% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 677.0000 | 64.0000 | 10.5781 | 416.5511 ± 0.8568 | 416.8890 ± 0.7765 | 0.9992 | 0.21% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 683.0000 | 63.0000 | 10.8413 | 413.8415 ± 0.2258 | 413.7013 ± 1.8842 | 1.0003 | 0.05% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.6577 |
| Geometric mean runtime ratio (L0/GCC) | 0.9961 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
