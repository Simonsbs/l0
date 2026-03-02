#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"
OUT_JSON="${3:-$ROOT/docs/LLM_MODEL_LEADERBOARD.json}"
OUT_MD="${4:-$ROOT/docs/LLM_MODEL_LEADERBOARD.md}"
MODELS_CSV="${L0_LLM_MODELS:-}"

TMP_BASE="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "$TMP_BASE/l0_llm_model_matrix.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

if [ -z "${L0_LLM_ADAPTER_CMD:-}" ]; then
  echo "FAIL: L0_LLM_ADAPTER_CMD is required"
  exit 1
fi

if [ -z "$MODELS_CSV" ]; then
  echo "FAIL: L0_LLM_MODELS is required (comma-separated model list)"
  exit 1
fi

rows="$WORK_DIR/rows.jsonl"
: > "$rows"

IFS=',' read -r -a MODELS <<< "$MODELS_CSV"
for raw_model in "${MODELS[@]}"; do
  model="$(echo "$raw_model" | xargs)"
  [ -n "$model" ] || continue

  run_json="$WORK_DIR/$model.json"
  run_md="$WORK_DIR/$model.md"
  t0="$(date +%s)"

  L0_OLLAMA_MODEL="$model" \
  bash "$ROOT/tests/llm_usability_bench.sh" \
    "$BIN" "$ROOT" cmd "$run_json" "$run_md"

  t1="$(date +%s)"
  elapsed="$((t1 - t0))"

  jq -cn \
    --arg model "$model" \
    --argjson duration_sec "$elapsed" \
    --slurpfile r "$run_json" \
    '{
      model: $model,
      duration_sec: $duration_sec,
      verify_success_rate_pct: ($r[0].verify_success_rate_pct // 0),
      semantic_success_rate_pct: ($r[0].semantic_success_rate_pct // 0),
      avg_attempts_used: ($r[0].avg_attempts_used // 0),
      avg_prompt_tokens: ($r[0].avg_prompt_tokens // 0),
      avg_completion_tokens_total: ($r[0].avg_completion_tokens_total // 0),
      avg_l0_vs_c_token_ratio: ($r[0].avg_l0_vs_c_token_ratio // 0),
      verify_pass_at_k_pct: ($r[0].verify_pass_at_k_pct // {}),
      semantic_pass_at_k_pct: ($r[0].semantic_pass_at_k_pct // {}),
      error_class_counts: ($r[0].error_class_counts // {}),
      source_report_json: ("tmp/" + $model + ".json")
    }' >> "$rows"
done

jq -s '
  . as $models
  | {
      generated_utc: (now | todateiso8601),
      total_models: ($models | length),
      models: $models,
      recommended_model: (
        $models
        | sort_by(
            -(.verify_success_rate_pct // 0),
            -(.semantic_success_rate_pct // 0),
            (.avg_attempts_used // 999999),
            (.avg_prompt_tokens + .avg_completion_tokens_total)
          )
        | .[0].model
      )
    }
' "$rows" > "$OUT_JSON"

{
  echo "# LLM Model Leaderboard"
  echo
  echo "I generated this report with \`tests/llm_model_matrix.sh\`."
  echo
  echo "- generated_utc: \`$(jq -r '.generated_utc' "$OUT_JSON")\`"
  echo "- total_models: \`$(jq -r '.total_models' "$OUT_JSON")\`"
  echo "- recommended_model: \`$(jq -r '.recommended_model' "$OUT_JSON")\`"
  echo
  echo "## Leaderboard"
  echo
  echo "| Model | Verify % | Semantic % | Avg attempts | Prompt tok | Completion tok | L0/C ratio | Duration sec |"
  echo "|---|---:|---:|---:|---:|---:|---:|---:|"
  jq -r '.models
    | sort_by(-.verify_success_rate_pct, -.semantic_success_rate_pct, .avg_attempts_used, (.avg_prompt_tokens + .avg_completion_tokens_total))
    | .[]
    | "| " + .model
      + " | " + (.verify_success_rate_pct|tostring)
      + " | " + (.semantic_success_rate_pct|tostring)
      + " | " + (.avg_attempts_used|tostring)
      + " | " + (.avg_prompt_tokens|tostring)
      + " | " + (.avg_completion_tokens_total|tostring)
      + " | " + (.avg_l0_vs_c_token_ratio|tostring)
      + " | " + (.duration_sec|tostring)
      + " |"
  ' "$OUT_JSON"
  echo
  echo "## Notes"
  echo
  echo "- I rank models by verify success, then semantic success, then lower attempts/tokens."
  echo "- This is adapter-driven and depends on the configured backend and prompt profile."
} > "$OUT_MD"

echo "ok"
