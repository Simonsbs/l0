# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-17T11:45:41Z`
- host: `ip-10-0-135-2`
- kernel: `Linux 7.0.0-1016-aws x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0`
- cpu_model: `Intel(R) Xeon(R) 6975P-C`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 1111.0000 | 92.0000 | 12.0761 | 456.4229 ± 3.5001 | 444.9032 ± 6.1640 | 1.0259 | 0.77% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 1081.0000 | 92.0000 | 11.7500 | 457.9962 ± 3.8904 | 387.6248 ± 3.4989 | 1.1815 | 0.85% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 1052.0000 | 91.0000 | 11.5604 | 369.6650 ± 1.8059 | 369.7070 ± 0.5245 | 0.9999 | 0.49% | ok |
| and (2-arg) | `tests/valid_and.l0` | 1111.0000 | 91.0000 | 12.2088 | 450.9119 ± 1.4272 | 399.9437 ± 4.1547 | 1.1274 | 0.32% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 1176.0000 | 91.0000 | 12.9231 | 451.1411 ± 2.6583 | 405.1034 ± 3.0485 | 1.1136 | 0.59% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 1159.0000 | 94.0000 | 12.3298 | 459.9918 ± 1.5629 | 452.4474 ± 8.4636 | 1.0167 | 0.34% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 1142.0000 | 94.0000 | 12.1489 | 386.5278 ± 7.0585 | 458.6954 ± 0.8895 | 0.8427 | 1.83% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 1159.0000 | 93.0000 | 12.4624 | 450.7662 ± 4.2521 | 453.4137 ± 5.1952 | 0.9942 | 0.94% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 1126.0000 | 90.0000 | 12.5111 | 446.2042 ± 5.3557 | 416.8089 ± 3.1241 | 1.0705 | 1.20% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 12.2129 |
| Geometric mean runtime ratio (L0/GCC) | 1.0371 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
