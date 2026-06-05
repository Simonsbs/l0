# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-05T04:45:46Z`
- host: `runnervm3jyl0`
- kernel: `Linux 6.17.0-1015-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 747.0000 | 64.0000 | 11.6719 | 422.9649 ± 0.2430 | 424.2419 ± 1.6892 | 0.9970 | 0.06% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 68.0000 | 10.9853 | 424.1774 ± 1.6001 | 424.7956 ± 0.8539 | 0.9985 | 0.38% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 68.0000 | 10.9853 | 421.8595 ± 0.8221 | 422.2243 ± 1.3275 | 0.9991 | 0.19% | ok |
| and (2-arg) | `tests/valid_and.l0` | 740.0000 | 66.0000 | 11.2121 | 423.3224 ± 0.9710 | 422.6811 ± 0.3715 | 1.0015 | 0.23% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 740.0000 | 68.0000 | 10.8824 | 420.6692 ± 4.0946 | 423.1390 ± 1.1423 | 0.9942 | 0.97% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 733.0000 | 68.0000 | 10.7794 | 423.1482 ± 1.9253 | 422.2425 ± 0.3403 | 1.0021 | 0.45% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 68.0000 | 10.9853 | 420.9956 ± 0.8402 | 421.2862 ± 1.1793 | 0.9993 | 0.20% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 740.0000 | 65.0000 | 11.3846 | 422.6171 ± 1.2834 | 421.6773 ± 0.3460 | 1.0022 | 0.30% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 740.0000 | 67.0000 | 11.0448 | 424.9157 ± 0.6545 | 422.1239 ± 1.1173 | 1.0066 | 0.15% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.1004 |
| Geometric mean runtime ratio (L0/GCC) | 1.0000 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
