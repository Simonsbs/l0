# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-06-02T04:51:31Z`
- host: `runnervm3jyl0`
- kernel: `Linux 6.17.0-1015-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- cpu_model: `Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 1000.0000 | 77.0000 | 12.9870 | 371.7760 ± 2.7882 | 373.5822 ± 3.4797 | 0.9952 | 0.75% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 975.0000 | 76.0000 | 12.8289 | 369.5111 ± 3.5012 | 460.9036 ± 30.3856 | 0.8017 | 0.95% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 941.0000 | 78.0000 | 12.0641 | 458.6631 ± 1.3438 | 483.6144 ± 15.3448 | 0.9484 | 0.29% | ok |
| and (2-arg) | `tests/valid_and.l0` | 941.0000 | 77.0000 | 12.2208 | 374.7937 ± 1.3900 | 498.8188 ± 16.2071 | 0.7514 | 0.37% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 975.0000 | 78.0000 | 12.5000 | 366.2750 ± 5.1003 | 427.3422 ± 3.7250 | 0.8571 | 1.39% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 975.0000 | 79.0000 | 12.3418 | 426.5955 ± 13.7375 | 366.5156 ± 15.3685 | 1.1639 | 3.22% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 963.0000 | 78.0000 | 12.3462 | 366.0348 ± 2.4314 | 372.3643 ± 6.3993 | 0.9830 | 0.66% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 963.0000 | 77.0000 | 12.5065 | 374.7074 ± 4.1243 | 374.2407 ± 5.9403 | 1.0012 | 1.10% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 963.0000 | 76.0000 | 12.6711 | 494.3494 ± 7.4994 | 489.4437 ± 11.4094 | 1.0100 | 1.52% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 12.4932 |
| Geometric mean runtime ratio (L0/GCC) | 0.9383 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
