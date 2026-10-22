# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-22T08:32:44Z`
- host: `runnervmxehtw`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 625.0000 | 57.0000 | 10.9649 | 409.5289 ± 1.9928 | 412.9054 ± 5.6541 | 0.9918 | 0.49% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 629.0000 | 57.0000 | 11.0351 | 409.0914 ± 0.7672 | 408.1084 ± 1.8009 | 1.0024 | 0.19% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 629.0000 | 57.0000 | 11.0351 | 411.2881 ± 1.1054 | 408.3985 ± 0.3140 | 1.0071 | 0.27% | ok |
| and (2-arg) | `tests/valid_and.l0` | 629.0000 | 57.0000 | 11.0351 | 413.9292 ± 4.1461 | 412.6611 ± 2.8097 | 1.0031 | 1.00% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 625.0000 | 56.0000 | 11.1607 | 410.3721 ± 3.4767 | 408.2961 ± 1.5391 | 1.0051 | 0.85% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 634.0000 | 56.0000 | 11.3214 | 407.9208 ± 2.9488 | 409.7350 ± 1.8392 | 0.9956 | 0.72% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 634.0000 | 57.0000 | 11.1228 | 408.5523 ± 1.8491 | 406.2578 ± 2.5580 | 1.0056 | 0.45% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 625.0000 | 56.0000 | 11.1607 | 409.3143 ± 1.8612 | 409.5890 ± 1.2733 | 0.9993 | 0.45% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 588.0000 | 55.0000 | 10.6909 | 402.1258 ± 2.1119 | 402.5900 ± 1.6292 | 0.9988 | 0.53% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.0573 |
| Geometric mean runtime ratio (L0/GCC) | 1.0010 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
