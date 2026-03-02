# Apples-to-Apples Performance Comparison

I generated this snapshot automatically with `tests/benchmark_apples_to_apples.sh`.

- generated_utc: `2026-03-02T14:02:24Z`
- host: `runnervmnay03`
- kernel: `Linux 6.14.0-1017-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`
- runtime iterations per run: `20000000`

## Method

I compare equivalent `f0(uint64_t,uint64_t,uint64_t,uint64_t,uint64_t,uint64_t)->uint64_t` implementations:
- L0: `tests/valid_sysv_abi_sum6_lowered.l0` built via `l0c build-elf`
- GCC: equivalent C function built with `gcc -O2 -c`
- Runtime harness: same assembly `_start` loop calling `f0` with fixed args for both variants
- Runtime metric: median of 3 runs in Mops/s
- Build metric: repeated object build throughput (ops/s)

## Results

| Metric | L0 (`l0c`) | GCC (`-O2`) |
|---|---:|---:|
| Build throughput (sum6 object) ops/s | 1250 | 60 |
| Runtime throughput (sum6 harness) Mops/s | 501.81 | 501.09 |

## Interpretation

- This is tighter than process-I/O comparisons because both variants use the same loop harness.
- It still represents one kernel shape; broader conclusions require additional kernels.
