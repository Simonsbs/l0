#!/usr/bin/env bash
set -euo pipefail

MODEL="${L0_OLLAMA_MODEL:-qwen3-coder:latest}"
HOST="${L0_OLLAMA_HOST:-http://127.0.0.1:11434}"
NUM_PREDICT="${L0_OLLAMA_NUM_PREDICT:-512}"
REQUEST_TIMEOUT_SEC="${L0_OLLAMA_TIMEOUT_SEC:-90}"
TEMPERATURE="${L0_OLLAMA_TEMPERATURE:-0}"

prompt="$(cat)"
if [ -z "$prompt" ]; then
  echo "error: empty prompt" >&2
  exit 1
fi

full_prompt="$(cat <<EOF
You are generating L0 source code.
Hard requirements:
- output ONLY raw L0 code (no markdown, no fences, no explanations)
- strict canonical section order: ver/types/consts/extern/globals/fns
- use contiguous ids and canonical formatting
- no comments
- one instruction per line
- no unsupported operations

Task:
$prompt
EOF
)"

if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  raw="$(
    curl -fsS --max-time "$REQUEST_TIMEOUT_SEC" "$HOST/api/generate" \
      -H 'Content-Type: application/json' \
      -d "$(jq -cn \
        --arg model "$MODEL" \
        --arg prompt "$full_prompt" \
        --argjson num_predict "$NUM_PREDICT" \
        --argjson temperature "$TEMPERATURE" \
        '{model:$model,prompt:$prompt,stream:false,options:{num_predict:$num_predict,temperature:$temperature}}')" \
      | jq -r '.response'
  )"
else
  if command -v timeout >/dev/null 2>&1; then
    raw="$(timeout "$REQUEST_TIMEOUT_SEC" ollama run "$MODEL" "$full_prompt")"
  else
    raw="$(ollama run "$MODEL" "$full_prompt")"
  fi
fi

# Remove common markdown fence wrappers if model returns them.
clean="$(printf '%s\n' "$raw" | sed -e '/^```[a-zA-Z0-9_-]*$/d' -e '/^```$/d')"
printf '%s\n' "$clean"
