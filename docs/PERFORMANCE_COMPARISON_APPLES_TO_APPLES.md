# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-24T04:41:58Z`
- host: `runnervm7b5n9`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 761.0000 | 71.0000 | 10.7183 | 424.5370 ± 0.5719 | 424.3525 ± 0.4223 | 1.0004 | 0.13% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 754.0000 | 71.0000 | 10.6197 | 424.4263 ± 0.2853 | 423.7265 ± 0.3126 | 1.0017 | 0.07% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 754.0000 | 72.0000 | 10.4722 | 422.6263 ± 1.2555 | 422.4617 ± 1.6214 | 1.0004 | 0.30% | ok |
| and (2-arg) | `tests/valid_and.l0` | 747.0000 | 71.0000 | 10.5211 | 424.6109 ± 1.2710 | 425.2488 ± 0.2230 | 0.9985 | 0.30% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 740.0000 | 71.0000 | 10.4225 | 423.9196 ± 0.7670 | 424.1866 ± 0.5014 | 0.9994 | 0.18% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 740.0000 | 73.0000 | 10.1370 | 424.2143 ± 0.4636 | 424.8972 ± 1.8316 | 0.9984 | 0.11% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 747.0000 | 73.0000 | 10.2329 | 422.9741 ± 1.1839 | 425.5174 ± 1.1681 | 0.9940 | 0.28% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 740.0000 | 71.0000 | 10.4225 | 423.9196 ± 0.6153 | 425.5267 ± 0.2807 | 0.9962 | 0.15% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 727.0000 | 69.0000 | 10.5362 | 422.9557 ± 0.7888 | 421.9688 ± 0.9263 | 1.0023 | 0.19% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.4522 |
| Geometric mean runtime ratio (L0/GCC) | 0.9990 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
