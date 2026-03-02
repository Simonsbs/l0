# LLM Model Leaderboard Trends

I generated this report with `tests/llm_model_matrix.sh` from `docs/LLM_MODEL_LEADERBOARD_HISTORY.jsonl`.

- total_snapshots: `2`
- latest_generated_utc: `2026-03-02T16:17:15Z`
- latest_recommended_model: `qwen2.5:3b`

## Recent Snapshots

| generated_utc | recommended_model | total_models |
|---|---|---:|
| 2026-03-02T15:20:28Z | qwen2.5:1.5b | 2 |
| 2026-03-02T16:17:15Z | qwen2.5:3b | 2 |

## Latest vs Previous (Per Model)

| Model | Verify latest | Verify delta | Semantic latest | Semantic delta | Attempts latest | Attempts delta |
|---|---:|---:|---:|---:|---:|---:|
| qwen2.5:3b | 16.666666666666668 | 16.666666666666668 | 16.666666666666668 | 16.666666666666668 | 1 | -2 |
| qwen3:8b | 0 | n/a | 0 | n/a | 1 | n/a |

## Notes

- Deltas are latest minus previous snapshot for the same model when available.
- This trend report is only as representative as the configured model set and benchmark environment.
