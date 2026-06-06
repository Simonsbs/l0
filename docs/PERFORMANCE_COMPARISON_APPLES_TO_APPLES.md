# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-06T04:37:30Z`
- host: `runnervm3jyl0`
- kernel: `Linux 6.17.0-1015-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `AMD EPYC 9V74 80-Core Processor`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 701.0000 | 66.0000 | 10.6212 | 305.4717 ± 1.4981 | 305.5052 ± 0.6220 | 0.9999 | 0.49% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 695.0000 | 65.0000 | 10.6923 | 306.1324 ± 0.5022 | 305.4717 ± 0.4462 | 1.0022 | 0.16% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 695.0000 | 65.0000 | 10.6923 | 305.2044 ± 0.5632 | 314.5179 ± 1.0784 | 0.9704 | 0.18% | ok |
| and (2-arg) | `tests/valid_and.l0` | 707.0000 | 66.0000 | 10.7121 | 305.7874 ± 1.2555 | 307.4480 ± 0.2414 | 0.9946 | 0.41% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 695.0000 | 66.0000 | 10.5303 | 307.4577 ± 1.3344 | 308.4531 ± 1.4171 | 0.9968 | 0.43% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 701.0000 | 67.0000 | 10.4627 | 312.9657 ± 0.6101 | 305.3428 ± 0.6372 | 1.0250 | 0.19% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 695.0000 | 67.0000 | 10.3731 | 305.9023 ± 0.3931 | 306.2621 ± 0.0961 | 0.9988 | 0.13% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 695.0000 | 66.0000 | 10.5303 | 305.5052 ± 0.1298 | 304.6664 ± 0.5679 | 1.0028 | 0.04% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 683.0000 | 64.0000 | 10.6719 | 312.5800 ± 0.5840 | 314.6801 ± 2.2410 | 0.9933 | 0.19% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.5868 |
| Geometric mean runtime ratio (L0/GCC) | 0.9981 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
