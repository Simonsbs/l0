# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-17T04:51:59Z`
- host: `runnervm1li68`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 761.0000 | 71.0000 | 10.7183 | 424.7956 ± 0.2886 | 423.3132 ± 1.0350 | 1.0035 | 0.07% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 761.0000 | 71.0000 | 10.7183 | 421.6955 ± 0.6605 | 419.1255 ± 1.7511 | 1.0061 | 0.16% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 747.0000 | 71.0000 | 10.5211 | 424.5555 ± 0.2470 | 423.8093 ± 0.1000 | 1.0018 | 0.06% | ok |
| and (2-arg) | `tests/valid_and.l0` | 747.0000 | 70.0000 | 10.6714 | 423.0565 ± 1.6171 | 424.4263 ± 0.8591 | 0.9968 | 0.38% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 747.0000 | 71.0000 | 10.5211 | 423.9104 ± 0.4605 | 423.5336 ± 0.3693 | 1.0009 | 0.11% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 740.0000 | 70.0000 | 10.5714 | 421.8230 ± 0.8552 | 423.1848 ± 0.4937 | 0.9968 | 0.20% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 740.0000 | 69.0000 | 10.7246 | 423.6346 ± 0.9006 | 423.5519 ± 4.8633 | 1.0002 | 0.21% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 747.0000 | 72.0000 | 10.3750 | 424.6016 ± 0.7816 | 425.5082 ± 1.2871 | 0.9979 | 0.18% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 747.0000 | 70.0000 | 10.6714 | 424.8418 ± 0.6979 | 426.2325 ± 1.2873 | 0.9967 | 0.16% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.6097 |
| Geometric mean runtime ratio (L0/GCC) | 1.0001 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
