#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"
OUT_JSON="${3:-$ROOT/docs/LLM_MODEL_LEADERBOARD.json}"
OUT_MD="${4:-$ROOT/docs/LLM_MODEL_LEADERBOARD.md}"
HISTORY_JSONL="${5:-$ROOT/docs/LLM_MODEL_LEADERBOARD_HISTORY.jsonl}"
OUT_TRENDS_MD="${6:-$ROOT/docs/LLM_MODEL_LEADERBOARD_TRENDS.md}"
MODELS_CSV="${L0_LLM_MODELS:-}"
HISTORY_LIMIT="${L0_LLM_HISTORY_LIMIT:-120}"

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

snapshot_json="$WORK_DIR/snapshot.json"
jq -cn --slurpfile r "$OUT_JSON" '{
  generated_utc: $r[0].generated_utc,
  recommended_model: $r[0].recommended_model,
  total_models: $r[0].total_models,
  models: $r[0].models
}' > "$snapshot_json"

mkdir -p "$(dirname "$HISTORY_JSONL")"
touch "$HISTORY_JSONL"
# Keep only valid JSON lines and cap history length.
{ jq -c . "$HISTORY_JSONL" 2>/dev/null || true; jq -c . "$snapshot_json"; } | tail -n "$HISTORY_LIMIT" > "$WORK_DIR/history.trimmed.jsonl"
cp "$WORK_DIR/history.trimmed.jsonl" "$HISTORY_JSONL"

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

jq -s '
  . as $hist
  | {
      total_snapshots: ($hist|length),
      latest: ($hist[-1] // null),
      previous: ($hist[-2] // null),
      models_latest: (($hist[-1].models // []) | map(.model))
    }
' "$HISTORY_JSONL" > "$WORK_DIR/history.summary.json"

{
  echo "# LLM Model Leaderboard Trends"
  echo
  echo "I generated this report with \`tests/llm_model_matrix.sh\` from \`docs/LLM_MODEL_LEADERBOARD_HISTORY.jsonl\`."
  echo
  echo "- total_snapshots: \`$(jq -r '.total_snapshots' "$WORK_DIR/history.summary.json")\`"
  echo "- latest_generated_utc: \`$(jq -r '.latest.generated_utc // "n/a"' "$WORK_DIR/history.summary.json")\`"
  echo "- latest_recommended_model: \`$(jq -r '.latest.recommended_model // "n/a"' "$WORK_DIR/history.summary.json")\`"
  echo
  echo "## Recent Snapshots"
  echo
  echo "| generated_utc | recommended_model | total_models |"
  echo "|---|---|---:|"
  jq -r -s '.[-10:][] | "| " + (.generated_utc // "n/a") + " | " + (.recommended_model // "n/a") + " | " + ((.total_models // 0)|tostring) + " |"' "$HISTORY_JSONL"
  echo
  echo "## Latest vs Previous (Per Model)"
  echo
  echo "| Model | Verify latest | Verify delta | Semantic latest | Semantic delta | Attempts latest | Attempts delta |"
  echo "|---|---:|---:|---:|---:|---:|---:|"
  jq -r -s '
    def to_map(arr): reduce arr[] as $m ({}; .[$m.model] = $m);
    (.[-1].models // []) as $latest
    | (if (length>1) then (.[-2].models // []) else [] end) as $prev
    | (to_map($prev)) as $pm
    | $latest[]
    | . as $m
    | ($pm[$m.model] // {}) as $p
    | ($p | has("verify_success_rate_pct")) as $has_prev
    | (if $has_prev then ($m.verify_success_rate_pct - ($p.verify_success_rate_pct // 0) | tostring) else "n/a" end) as $dv
    | (if $has_prev then ($m.semantic_success_rate_pct - ($p.semantic_success_rate_pct // 0) | tostring) else "n/a" end) as $ds
    | (if $has_prev then ($m.avg_attempts_used - ($p.avg_attempts_used // 0) | tostring) else "n/a" end) as $da
    | "| " + $m.model
      + " | " + ($m.verify_success_rate_pct|tostring)
      + " | " + $dv
      + " | " + ($m.semantic_success_rate_pct|tostring)
      + " | " + $ds
      + " | " + ($m.avg_attempts_used|tostring)
      + " | " + $da
      + " |"
  ' "$HISTORY_JSONL"
  echo
  echo "## Notes"
  echo
  echo "- Deltas are latest minus previous snapshot for the same model when available."
  echo "- This trend report is only as representative as the configured model set and benchmark environment."
} > "$OUT_TRENDS_MD"

echo "ok"
