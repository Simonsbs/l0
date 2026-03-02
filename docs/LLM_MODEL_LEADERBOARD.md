# LLM Model Leaderboard

I generated this report with `tests/llm_model_matrix.sh`.

- generated_utc: `2026-03-02T16:17:15Z`
- total_models: `2`
- recommended_model: `qwen2.5:3b`

## Leaderboard

| Model | Verify % | Semantic % | Avg attempts | Prompt tok | Completion tok | L0/C ratio | Duration sec |
|---|---:|---:|---:|---:|---:|---:|---:|
| qwen2.5:3b | 16.666666666666668 | 16.666666666666668 | 1 | 24.333333333333332 | 59.666666666666664 | 3.460516666666667 | 45 |
| qwen3:8b | 0 | 0 | 1 | 24.333333333333332 | 0 | 0 | 270 |

## Notes

- I rank models by verify success, then semantic success, then lower attempts/tokens.
- This is adapter-driven and depends on the configured backend and prompt profile.
