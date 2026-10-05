# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-05T10:20:54Z`
- host: `runnervm8df0l`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 689.0000 | 62.0000 | 11.1129 | 418.3804 ± 2.3623 | 418.6853 ± 5.3732 | 0.9993 | 0.56% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 672.0000 | 62.0000 | 10.8387 | 407.9208 ± 3.7880 | 404.6586 ± 2.7933 | 1.0081 | 0.93% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 677.0000 | 61.0000 | 11.0984 | 407.2149 ± 4.9576 | 408.1425 ± 2.1715 | 0.9977 | 1.22% | ok |
| and (2-arg) | `tests/valid_and.l0` | 677.0000 | 61.0000 | 11.0984 | 411.2275 ± 2.5401 | 407.2744 ± 1.4753 | 1.0097 | 0.62% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 666.0000 | 60.0000 | 11.1000 | 411.5741 ± 2.7018 | 410.4066 ± 6.6112 | 1.0028 | 0.66% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 677.0000 | 62.0000 | 10.9194 | 416.2493 ± 2.6792 | 414.7555 ± 3.4348 | 1.0036 | 0.64% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 666.0000 | 63.0000 | 10.5714 | 415.2316 ± 1.1390 | 412.2778 ± 4.5607 | 1.0072 | 0.27% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 666.0000 | 61.0000 | 10.9180 | 409.9156 ± 5.7332 | 414.3419 ± 2.7007 | 0.9893 | 1.40% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 666.0000 | 60.0000 | 11.1000 | 412.1821 ± 2.4981 | 411.1582 ± 2.0678 | 1.0025 | 0.61% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.9716 |
| Geometric mean runtime ratio (L0/GCC) | 1.0022 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
