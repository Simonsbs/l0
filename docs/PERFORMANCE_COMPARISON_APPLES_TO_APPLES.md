# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-08-16T03:57:10Z`
- host: `runnervmzvulz`
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
| add.wrap (2-arg) | `tests/valid_add_v7.l0` | 747.0000 | 68.0000 | 10.9853 | 418.9817 ± 1.1157 | 421.5226 ± 1.0420 | 0.9940 | 0.27% | ok |
| sub.wrap (2-arg) | `tests/valid_sub.l0` | 747.0000 | 67.0000 | 11.1493 | 420.4971 ± 0.7130 | 420.6692 ± 1.0025 | 0.9996 | 0.17% | ok |
| mul.wrap (2-arg) | `tests/valid_mul.l0` | 727.0000 | 67.0000 | 10.8507 | 420.7054 ± 1.2589 | 422.4160 ± 0.4614 | 0.9960 | 0.30% | ok |
| and (2-arg) | `tests/valid_and.l0` | 727.0000 | 68.0000 | 10.6912 | 422.3521 ± 3.4332 | 421.0682 ± 1.1538 | 1.0030 | 0.81% | ok |
| xor (2-arg) | `tests/valid_xor.l0` | 720.0000 | 68.0000 | 10.5882 | 419.9727 ± 0.6714 | 421.8686 ± 1.0375 | 0.9955 | 0.16% | ok |
| cbr select (eq ? a : b) | `tests/valid_cbr_eq_select_v7.l0` | 727.0000 | 70.0000 | 10.3857 | 422.1786 ± 0.1554 | 422.8001 ± 0.3886 | 0.9985 | 0.04% | ok |
| memory roundtrip | `tests/valid_mem_roundtrip_v7.l0` | 727.0000 | 71.0000 | 10.2394 | 422.0509 ± 0.2307 | 421.6227 ± 0.6691 | 1.0010 | 0.05% | ok |
| call add (f0->f1) | `tests/valid_call_add_v7_lowered.l0` | 740.0000 | 70.0000 | 10.5714 | 424.6016 ± 1.1662 | 422.6537 ± 1.9744 | 1.0046 | 0.27% | ok |
| sum6 sysv | `tests/valid_sysv_abi_sum6_lowered.l0` | 720.0000 | 67.0000 | 10.7463 | 422.7086 ± 1.2083 | 419.6298 ± 2.4490 | 1.0073 | 0.29% | ok |

## Aggregate

| Metric | Value |
|---|---:|
| Geometric mean build ratio (L0/GCC) | 10.6864 |
| Geometric mean runtime ratio (L0/GCC) | 0.9999 |
| Kernels above runtime CI95 warning threshold | 0 |

## Interpretation

- This matrix is tighter than process-I/O comparisons because both variants use the same loop harness per kernel.
- Runtime ratio near 1.0 means parity; >1.0 favors L0; <1.0 favors GCC.
- CI95 is computed from trimmed samples when enough samples are available.
- Stability marks `warn` if L0 runtime CI95% exceeds the configured threshold.
- Build ratio reflects compiler throughput, not generated-code quality.
