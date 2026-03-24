# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-03-24T04:02:37Z`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 655.0000 | 61.0000 | 10.7377 | 411.4267 ± 1.2744 | 411.3488 ± 0.8558 | 1.0002 | 0.31% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 666.0000 | 62.0000 | 10.7419 | 416.3025 ± 1.1612 | 416.0986 ± 2.5905 | 1.0005 | 0.28% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 677.0000 | 62.0000 | 10.9194 | 411.9822 ± 1.0064 | 413.3248 ± 1.3947 | 0.9968 | 0.24% | ok |
| and (2-arg) | `tests/valid_and.l0` | 672.0000 | 61.0000 | 11.0164 | 413.2723 ± 0.7468 | 412.8705 ± 1.0633 | 1.0010 | 0.18% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 640.0000 | 59.0000 | 10.8475 | 409.3572 ± 2.8268 | 411.2448 ± 2.7304 | 0.9954 | 0.69% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 655.0000 | 62.0000 | 10.5645 | 414.8259 ± 0.5048 | 414.2541 ± 1.5712 | 1.0014 | 0.12% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 683.0000 | 61.0000 | 11.1967 | 404.7760 ± 4.7196 | 404.4491 ± 6.5699 | 1.0008 | 1.17% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 666.0000 | 60.0000 | 11.1000 | 408.4839 ± 1.6960 | 412.3126 ± 0.8124 | 0.9907 | 0.42% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 661.0000 | 59.0000 | 11.2034 | 412.0082 ± 3.0682 | 409.5546 ± 0.2925 | 1.0060 | 0.74% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.9233 |
| Geometric mean runtime ratio (L0/GCC) | 0.9992 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
