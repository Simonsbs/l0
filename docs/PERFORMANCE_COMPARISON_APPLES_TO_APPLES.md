# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-20T03:56:33Z`
- host: `runnervm76f27`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 720.0000 | 67.0000 | 10.7463 | 419.1345 ± 0.5941 | 420.5062 ± 0.6012 | 0.9967 | 0.14% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 714.0000 | 68.0000 | 10.5000 | 420.9684 ± 0.8855 | 420.1263 ± 0.8767 | 1.0020 | 0.21% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 707.0000 | 68.0000 | 10.3971 | 421.7593 ± 1.2189 | 417.9685 ± 4.8140 | 1.0091 | 0.29% | ok |
| and (2-arg) | `tests/valid_and.l0` | 701.0000 | 66.0000 | 10.6212 | 420.2890 ± 1.8321 | 421.1954 ± 0.7444 | 0.9978 | 0.44% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 714.0000 | 67.0000 | 10.6567 | 421.5226 ± 1.4468 | 423.1023 ± 1.0621 | 0.9963 | 0.34% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 707.0000 | 68.0000 | 10.3971 | 415.6558 ± 1.5761 | 419.0446 ± 0.6699 | 0.9919 | 0.38% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 701.0000 | 68.0000 | 10.3088 | 418.9997 ± 0.4769 | 419.5397 ± 0.6817 | 0.9987 | 0.11% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 720.0000 | 67.0000 | 10.7463 | 418.9907 ± 1.4029 | 419.6118 ± 3.7753 | 0.9985 | 0.33% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 701.0000 | 65.0000 | 10.7846 | 418.0759 ± 0.4435 | 418.1296 ± 1.7387 | 0.9999 | 0.11% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5718 |
| Geometric mean runtime ratio (L0/GCC) | 0.9990 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
