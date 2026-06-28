# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-28T04:47:02Z`
- host: `runnervmmklqx`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 769.0000 | 70.0000 | 10.9857 | 423.0290 ± 0.6991 | 422.8275 ± 0.6745 | 1.0005 | 0.17% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 761.0000 | 68.0000 | 11.1912 | 421.0773 ± 1.6665 | 417.3701 ± 4.1352 | 1.0089 | 0.40% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 754.0000 | 69.0000 | 10.9275 | 425.1562 ± 1.5475 | 424.1130 ± 0.4348 | 1.0025 | 0.36% | ok |
| and (2-arg) | `tests/valid_and.l0` | 747.0000 | 68.0000 | 10.9853 | 423.3958 ± 1.8465 | 423.4326 ± 1.1491 | 0.9999 | 0.44% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 754.0000 | 65.0000 | 11.6000 | 421.4135 ± 2.9242 | 423.5336 ± 2.8389 | 0.9950 | 0.69% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 747.0000 | 67.0000 | 11.1493 | 421.8321 ± 2.3443 | 422.2516 ± 1.4236 | 0.9990 | 0.56% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 740.0000 | 67.0000 | 11.0448 | 416.2050 ± 2.4531 | 416.6756 ± 4.5338 | 0.9989 | 0.59% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 747.0000 | 67.0000 | 11.1493 | 417.0938 ± 1.9510 | 420.0811 ± 2.8237 | 0.9929 | 0.47% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 727.0000 | 64.0000 | 11.3594 | 421.8048 ± 2.5341 | 421.4226 ± 0.2989 | 1.0009 | 0.60% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.1529 |
| Geometric mean runtime ratio (L0/GCC) | 0.9998 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
