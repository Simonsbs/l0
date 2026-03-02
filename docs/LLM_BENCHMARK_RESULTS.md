# LLM Usability and Token Efficiency Results

I generated this report with `tests/llm_usability_bench.sh`.

- generated_utc: `2026-03-02T16:19:08Z`
- mode: `cmd`
- max_attempts: `1`
- total_tasks: `6`

## Summary

| Metric | Value |
|---|---:|
| Verify success rate | 16.666666666666668% |
| Semantic success rate | 16.666666666666668% |
| Avg turns to pass | 0.16666666666666666 |
| Avg attempts used | 1 |
| Avg prompt tokens base (proxy) | 24.333333333333332 |
| Avg prompt tokens total (proxy) | 24.333333333333332 |
| Avg completion tokens total (proxy) | 59.666666666666664 |
| Avg L0 tokens (proxy) | 59.666666666666664 |
| Avg C tokens (proxy) | 17.5 |
| Avg L0/C token ratio | 3.460516666666667 |
| Tokens per verified program | 504 |
| Tokens per semantic program | 504 |

## Pass@K

| K | Verify pass@k | Semantic pass@k |
|---:|---:|---:|
| 1 | 16.666666666666668% | 16.666666666666668% |

## Task Matrix

| Task | Verify | Semantic | Turns | Attempts | Err class | Prompt tok | Out tok | L0 tok | C tok | L0/C |
|---|---:|---:|---:|---:|---|---:|---:|---:|---:|---:|
| t01_add | true | true | 1 | 1/1 | none | 20 | 45 | 45 | 13 | 3.4615 |
| t02_icmp_eq | false | false | 0 | 1/1 | non_canonical | 22 | 52 | 52 | 13 | 4.0000 |
| t03_cbr_select | false | false | 0 | 1/1 | non_canonical | 26 | 48 | 48 | 13 | 3.6923 |
| t04_mem_roundtrip | false | false | 0 | 1/1 | non_canonical | 26 | 41 | 41 | 13 | 3.1538 |
| t05_call_add | false | false | 0 | 1/1 | non_canonical | 28 | 73 | 73 | 24 | 3.0417 |
| t06_sysv_sum6 | false | false | 0 | 1/1 | non_canonical | 24 | 99 | 99 | 29 | 3.4138 |

## Error Class Counts

- non_canonical: 5
- none: 1

## Notes

- Token values are whitespace-token proxies for deterministic relative tracking.
- `l0c verify` covers parser+verifier in this benchmark surface.
- In cmd mode, prompt/output token totals include all repair attempts.
