# Performance Comparison Snapshot

I generated this snapshot automatically with `tests/benchmark_compare.sh`.

- generated_utc: `2026-11-14T10:17:49Z`
- host: `runnervmccnms`
- kernel: `Linux 7.0.0-1019-azure x86_64`
- l0c: `./bin/l0c`
- gcc: `gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0`

## Method

I compare process-level throughput (ops/s) for equivalent minimal tasks:
- build throughput: compile/build a minimal add kernel/program repeatedly
- run throughput: execute add with two decimal args repeatedly

This is an operational comparison, not a language-runtime microbenchmark.

## Results

| Workload | L0 (`l0c`) ops/s | GCC C ops/s |
|---|---:|---:|
| Build minimal add artifact | 1428 | 24 |
| Run minimal add artifact/program | 1951 | 1225 |

## Notes

- I run this on the local host, so values are machine-dependent.
- CI smoke/full perf gates remain the enforcement source for regressions.
