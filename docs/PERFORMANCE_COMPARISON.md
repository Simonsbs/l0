# Performance Comparison Snapshot

I generated this snapshot automatically with `tests/benchmark_compare.sh`.

- generated_utc: `2026-03-17T04:02:17Z`
- host: `runnervm46oaq`
- kernel: `Linux 6.14.0-1017-azure x86_64`
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
| Build minimal add artifact | 1449 | 24 |
| Run minimal add artifact/program | 1883 | 1195 |

## Notes

- I run this on the local host, so values are machine-dependent.
- CI smoke/full perf gates remain the enforcement source for regressions.
