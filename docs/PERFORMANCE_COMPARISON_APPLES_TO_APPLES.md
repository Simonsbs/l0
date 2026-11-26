# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-26T12:22:42Z`
- host: `ip-10-0-136-138`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 1095.0000 | 83.0000 | 13.1928 | 418.7840 ± 1.6181 | 417.9953 ± 1.7630 | 1.0019 | 0.39% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 1081.0000 | 84.0000 | 12.8690 | 418.4700 ± 10.7155 | 401.7040 ± 21.5152 | 1.0417 | 2.56% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 1081.0000 | 84.0000 | 12.8690 | 348.6042 ± 0.7717 | 349.6777 ± 1.0242 | 0.9969 | 0.22% | ok |
| and (2-arg) | `tests/valid_and.l0` | 1081.0000 | 82.0000 | 13.1829 | 422.4526 ± 1.9357 | 386.8647 ± 3.8013 | 1.0920 | 0.46% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 1081.0000 | 82.0000 | 13.1829 | 422.5257 ± 5.2569 | 395.3934 ± 9.0233 | 1.0686 | 1.24% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 1095.0000 | 82.0000 | 13.3537 | 421.2226 ± 7.7662 | 423.0748 ± 0.5223 | 0.9956 | 1.84% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 1066.0000 | 83.0000 | 12.8434 | 370.3519 ± 4.0741 | 420.7779 ± 2.4841 | 0.8802 | 1.10% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 1095.0000 | 84.0000 | 13.0357 | 429.0131 ± 10.0075 | 420.6511 ± 5.2974 | 1.0199 | 2.33% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 1066.0000 | 81.0000 | 13.1605 | 425.2951 ± 1.5971 | 411.0631 ± 6.2259 | 1.0346 | 0.38% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 13.0755 |
| Geometric mean runtime ratio (L0/GCC) | 1.0129 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
