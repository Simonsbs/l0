# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-10-16T08:06:34Z`
- host: `runnervm8k3b6`
- kernel: `Linux 6.17.0-1022-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 650.0000 | 55.0000 | 11.8182 | 298.3237 ± 1.0597 | 299.1782 ± 0.7750 | 0.9971 | 0.36% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 650.0000 | 56.0000 | 11.6071 | 300.4623 ± 1.1193 | 302.5193 ± 1.7572 | 0.9932 | 0.37% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 645.0000 | 55.0000 | 11.7273 | 300.0376 ± 1.4724 | 308.7213 ± 1.0568 | 0.9719 | 0.49% | ok |
| and (2-arg) | `tests/valid_and.l0` | 640.0000 | 61.0000 | 10.4918 | 300.5316 ± 1.0607 | 304.0356 ± 1.8691 | 0.9885 | 0.35% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 650.0000 | 61.0000 | 10.6557 | 301.9954 ± 0.4298 | 303.6717 ± 2.8470 | 0.9945 | 0.14% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 629.0000 | 58.0000 | 10.8448 | 311.2947 ± 2.0495 | 302.7491 ± 0.4858 | 1.0282 | 0.66% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 640.0000 | 60.0000 | 10.6667 | 301.2269 ± 0.2729 | 301.4826 ± 0.2501 | 0.9992 | 0.09% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 634.0000 | 55.0000 | 11.5273 | 297.7779 ± 0.7483 | 298.9081 ± 1.0871 | 0.9962 | 0.25% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 640.0000 | 58.0000 | 11.0345 | 312.2053 ± 0.6896 | 312.1853 ± 2.4581 | 1.0001 | 0.22% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 11.1419 |
| Geometric mean runtime ratio (L0/GCC) | 0.9964 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
