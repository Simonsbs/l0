# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-05-25T04:47:39Z`
- host: `runnervmg397c`
- kernel: `Linux 6.17.0-1013-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 784.0000 | 72.0000 | 10.8889 | 426.4186 ± 1.3523 | 424.4724 ± 1.4709 | 1.0046 | 0.32% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 784.0000 | 73.0000 | 10.7397 | 427.0993 ± 1.1725 | 428.7400 ± 1.4562 | 0.9962 | 0.27% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 769.0000 | 72.0000 | 10.6806 | 426.5955 ± 0.6812 | 426.3906 ± 0.4393 | 1.0005 | 0.16% | ok |
| and (2-arg) | `tests/valid_and.l0` | 761.0000 | 72.0000 | 10.5694 | 428.7400 ± 2.7456 | 430.5167 ± 2.5678 | 0.9959 | 0.64% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 769.0000 | 72.0000 | 10.6806 | 427.3984 ± 1.4499 | 428.8812 ± 0.4504 | 0.9965 | 0.34% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 761.0000 | 72.0000 | 10.5694 | 426.7353 ± 0.2540 | 425.5916 ± 2.2560 | 1.0027 | 0.06% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 754.0000 | 73.0000 | 10.3288 | 429.2488 ± 2.8938 | 426.2976 ± 1.6925 | 1.0069 | 0.67% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 754.0000 | 72.0000 | 10.4722 | 425.0637 ± 0.4156 | 427.6604 ± 0.2067 | 0.9939 | 0.10% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 747.0000 | 71.0000 | 10.5211 | 426.1953 ± 1.1504 | 425.4804 ± 0.3162 | 1.0017 | 0.27% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.6045 |
| Geometric mean runtime ratio (L0/GCC) | 0.9999 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
