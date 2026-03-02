# LLM Usability and Token Efficiency Results

I generated this report with `tests/llm_usability_bench.sh`.

- generated_utc: `2026-03-02T16:58:18Z`
- mode: `cmd`
- max_attempts: `3`
- total_tasks: `6`

## Summary

| Metric | Value |
|---|---:|
| Verify success rate | 100% |
| Semantic success rate | 100% |
| Avg turns to pass | 1.5 |
| Avg attempts used | 1.5 |
| Avg prompt tokens base (proxy) | 24.333333333333332 |
| Avg prompt tokens total (proxy) | 143.33333333333334 |
| Avg completion tokens total (proxy) | 89.66666666666667 |
| Avg L0 tokens (proxy) | 59.333333333333336 |
| Avg C tokens (proxy) | 17.5 |
| Avg L0/C token ratio | 3.449033333333333 |
| Tokens per verified program | 233 |
| Tokens per semantic program | 233 |

## Pass@K

| K | Verify pass@k | Semantic pass@k |
|---:|---:|---:|
| 1 | 50% | 50% |
| 2 | 100% | 100% |
| 3 | 100% | 100% |

## Task Matrix

| Task | Verify | Semantic | Turns | Attempts | Err class | Prompt tok | Out tok | L0 tok | C tok | L0/C |
|---|---:|---:|---:|---:|---|---:|---:|---:|---:|---:|
| t01_add | true | true | 1 | 1/3 | none | 20 | 45 | 45 | 13 | 3.4615 |
| t02_icmp_eq | true | true | 1 | 1/3 | none | 22 | 46 | 46 | 13 | 3.5385 |
| t03_cbr_select | true | true | 2 | 2/3 | non_canonical | 294 | 111 | 46 | 13 | 3.5385 |
| t04_mem_roundtrip | true | true | 2 | 2/3 | non_canonical | 248 | 93 | 49 | 13 | 3.7692 |
| t05_call_add | true | true | 2 | 2/3 | non_canonical | 252 | 146 | 73 | 24 | 3.0417 |
| t06_sysv_sum6 | true | true | 1 | 1/3 | none | 24 | 97 | 97 | 29 | 3.3448 |

## Error Class Counts

- non_canonical: 3
- none: 3

## Notes

- Token values are whitespace-token proxies for deterministic relative tracking.
- `l0c verify` covers parser+verifier in this benchmark surface.
- In cmd mode, prompt/output token totals include all repair attempts.
