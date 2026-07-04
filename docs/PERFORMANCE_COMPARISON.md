# Performance Comparison Snapshot

I generated this snapshot automatically with `tests/benchmark_compare.sh`.

- generated_utc: `2026-07-04T06:27:01Z`
- host: `runnervmkkn4f`
- kernel: `Linux 6.17.0-1018-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 13.3.0-6ubuntu2~24.04.1) 13.3.0`

## Method

I compare process-level throughput (ops/s) for equivalent minimal tasks:
- build throughput: compile/build a minimal add kernel/program repeatedly
- run throughput: execute add with two decimal args repeatedly

This is an operational comparison, not a language-runtime microbenchmark.

## Results

| Workload | L0 (`l0c`) ops/s | GCC C ops/s |
|---|---:|---:|
| Build minimal add artifact | 2325 | 29 |
| Run minimal add artifact/program | 2784 | 1702 |

## Notes

- I run this on the local host, so values are machine-dependent.
- CI smoke/full perf gates remain the enforcement source for regressions.
