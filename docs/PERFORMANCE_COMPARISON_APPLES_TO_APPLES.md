# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-11-02T10:56:59Z`
- host: `runnervm48cm3`
- kernel: `Linux 7.0.0-1017-azure x86_64`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 761.0000 | 74.0000 | 10.2838 | 389.5809 ± 0.2991 | 389.7053 ± 0.4250 | 0.9997 | 0.08% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 776.0000 | 73.0000 | 10.6301 | 388.4111 ± 0.1487 | 394.2680 ± 3.5135 | 0.9851 | 0.04% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 761.0000 | 74.0000 | 10.2838 | 389.5421 ± 0.3804 | 406.1902 ± 0.9870 | 0.9590 | 0.10% | ok |
| and (2-arg) | `tests/valid_and.l0` | 754.0000 | 68.0000 | 11.0882 | 389.5265 ± 1.2666 | 393.9102 ± 1.2369 | 0.9889 | 0.33% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 519.0000 | 68.0000 | 7.6324 | 388.7357 ± 0.3417 | 391.3686 ± 1.2549 | 0.9933 | 0.09% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 707.0000 | 75.0000 | 9.4267 | 397.5665 ± 3.1178 | 389.8920 ± 0.6824 | 1.0197 | 0.78% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 761.0000 | 74.0000 | 10.2838 | 388.8054 ± 0.8817 | 388.7512 ± 0.4413 | 1.0001 | 0.23% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 655.0000 | 63.0000 | 10.3968 | 387.6479 ± 1.4610 | 389.6897 ± 0.9670 | 0.9948 | 0.38% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 754.0000 | 66.0000 | 11.4242 | 403.5799 ± 1.9719 | 407.5378 ± 3.4329 | 0.9903 | 0.49% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.1018 |
| Geometric mean runtime ratio (L0/GCC) | 0.9922 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
