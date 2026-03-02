# LLM Model Leaderboard Trends

I generated this report with `tests/llm_model_matrix.sh` from `docs/LLM_MODEL_LEADERBOARD_HISTORY.jsonl`.

- total_snapshots: `4`
- latest_generated_utc: `2026-03-02T16:59:12Z`
- latest_recommended_model: `gpt-4.1-mini`

## Recent Snapshots

| generated_utc | recommended_model | total_models |
|---|---|---:|
| 2026-03-02T15:20:28Z | qwen2.5:1.5b | 2 |
| 2026-03-02T16:17:15Z | qwen2.5:3b | 2 |
| 2026-03-02T16:39:50Z | gpt-4.1-mini | 2 |
| 2026-03-02T16:59:12Z | gpt-4.1-mini | 2 |

## Latest vs Previous (Per Model)

| Model | Verify latest | Verify delta | Semantic latest | Semantic delta | Attempts latest | Attempts delta |
|---|---:|---:|---:|---:|---:|---:|
| gpt-4.1-mini | 100 | 66.66666666666666 | 100 | 83.33333333333333 | 1.5 | 0.5 |
| gpt-4.1 | 100 | 66.66666666666666 | 83.33333333333333 | 66.66666666666666 | 1.5 | 0.5 |

## Notes

- Deltas are latest minus previous snapshot for the same model when available.
- This trend report is only as representative as the configured model set and benchmark environment.
