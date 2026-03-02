#!/usr/bin/env bash
set -euo pipefail

MODEL="${L0_OLLAMA_MODEL:-qwen3-coder:latest}"
HOST="${L0_OLLAMA_HOST:-http://127.0.0.1:11434}"
NUM_PREDICT="${L0_OLLAMA_NUM_PREDICT:-512}"
REQUEST_TIMEOUT_SEC="${L0_OLLAMA_TIMEOUT_SEC:-90}"
TEMPERATURE="${L0_OLLAMA_TEMPERATURE:-0}"
USE_CHAT="${L0_OLLAMA_USE_CHAT:-1}"

prompt="$(cat)"
if [ -z "$prompt" ]; then
  echo "error: empty prompt" >&2
  exit 1
fi

sys_prompt="$(cat <<'EOF'
You generate canonical L0 source code only.
Return plain text L0 module only. No markdown, no YAML/JSON, no prose.

Canonical requirements:
- first line must be: ver 1
- section order exactly:
  ver
  types { ... }
  consts { ... }
  extern { ... }
  globals { ... }
  fns { ... }
- function/block/value/type ids are contiguous and canonical
- one instruction per line
- terminators: br / cbr / ret
- no comments
- only valid L0 tokens/opcodes

Canonical example:
ver 1
types { t0=i64 }
consts { }
extern { }
globals { }
fns {
fn f0 (t0,t0)->t0 {
b0:
  v0 = arg 0 : t0
  v1 = arg 1 : t0
  v2 = add.wrap v0 v1 : t0
  ret v2
}
}
EOF
)"

full_prompt="$(cat <<EOF
Task:
$prompt

Output exactly one valid canonical L0 module following the system rules.
EOF
)"

raw=""
if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  if [ "$USE_CHAT" = "1" ]; then
    raw="$(
      curl -fsS --max-time "$REQUEST_TIMEOUT_SEC" "$HOST/api/chat" \
        -H 'Content-Type: application/json' \
        -d "$(jq -cn \
          --arg model "$MODEL" \
          --arg sp "$sys_prompt" \
          --arg up "$full_prompt" \
          --argjson num_predict "$NUM_PREDICT" \
          --argjson temperature "$TEMPERATURE" \
          '{model:$model,stream:false,messages:[{role:"system",content:$sp},{role:"user",content:$up}],options:{num_predict:$num_predict,temperature:$temperature}}')" \
        | jq -r '.message.content // empty'
    )" || raw=""
  fi

  if [ -z "$raw" ]; then
    raw="$(
      curl -fsS --max-time "$REQUEST_TIMEOUT_SEC" "$HOST/api/generate" \
        -H 'Content-Type: application/json' \
        -d "$(jq -cn \
          --arg model "$MODEL" \
          --arg prompt "$full_prompt" \
          --argjson num_predict "$NUM_PREDICT" \
          --argjson temperature "$TEMPERATURE" \
          '{model:$model,prompt:$prompt,stream:false,options:{num_predict:$num_predict,temperature:$temperature}}')" \
        | jq -r '.response // empty'
    )" || raw=""
  fi
fi

if [ -z "$raw" ]; then
  if command -v timeout >/dev/null 2>&1; then
    raw="$(timeout "$REQUEST_TIMEOUT_SEC" ollama run "$MODEL" "$sys_prompt"$'\n\n'"$full_prompt" 2>/dev/null || true)"
  else
    raw="$(ollama run "$MODEL" "$sys_prompt"$'\n\n'"$full_prompt" 2>/dev/null || true)"
  fi
fi

# Remove common markdown fence wrappers if model returns them.
clean="$(printf '%s\n' "$raw" | sed -e '/^```[a-zA-Z0-9_-]*$/d' -e '/^```$/d')"
printf '%s\n' "$clean"
