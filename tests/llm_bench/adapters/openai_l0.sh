#!/usr/bin/env bash
set -euo pipefail

API_KEY="${OPENAI_API_KEY:-}"
BASE_URL="${L0_OPENAI_BASE_URL:-https://api.openai.com/v1}"
MODEL="${L0_OPENAI_MODEL:-gpt-4.1-mini}"
MAX_OUTPUT_TOKENS="${L0_OPENAI_MAX_OUTPUT_TOKENS:-512}"
TEMPERATURE="${L0_OPENAI_TEMPERATURE:-0}"
REQUEST_TIMEOUT_SEC="${L0_OPENAI_TIMEOUT_SEC:-90}"
USE_RESPONSES_API="${L0_OPENAI_USE_RESPONSES:-1}"

if [ -z "$API_KEY" ]; then
  echo "error: OPENAI_API_KEY is required" >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  echo "error: openai adapter requires curl and jq" >&2
  exit 1
fi

prompt="$(cat)"
if [ -z "$prompt" ]; then
  echo "error: empty prompt" >&2
  exit 1
fi

sys_prompt="$(cat <<'EOT'
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
- ID prefixes are strict: tN, kN, gN, fN, bN, vN (no other prefixes)
- one instruction per line
- terminators: br / cbr / ret
- no comments
- only valid L0 tokens/opcodes
- pointer type syntax is `p0<i8>` (never `byte*`)
- call target syntax is `call fN ...` (never numeric bare target)
- if a literal constant is needed, use `vN = const <int> : tX`
- do not invent constant IDs like `c0`
- for multiple entries in `types { ... }`, use commas between entries

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
EOT
)"

user_prompt="$(cat <<EOT
Task:
$prompt

Output exactly one valid canonical L0 module following the system rules.
EOT
)"

raw=""

if [ "$USE_RESPONSES_API" = "1" ]; then
  raw="$({
    curl -fsS --max-time "$REQUEST_TIMEOUT_SEC" "$BASE_URL/responses" \
      -H "Authorization: Bearer $API_KEY" \
      -H 'Content-Type: application/json' \
      -d "$(jq -cn \
        --arg model "$MODEL" \
        --arg sp "$sys_prompt" \
        --arg up "$user_prompt" \
        --argjson max_output_tokens "$MAX_OUTPUT_TOKENS" \
        --argjson temperature "$TEMPERATURE" \
        '{model:$model,input:[{role:"system",content:[{type:"input_text",text:$sp}]},{role:"user",content:[{type:"input_text",text:$up}]}],max_output_tokens:$max_output_tokens,temperature:$temperature}')" \
      | jq -r '(.output_text // ([.output[]?.content[]? | .text?] | join("")) // empty)'
  } 2>/dev/null || true)"
fi

if [ -z "$raw" ]; then
  raw="$({
    curl -fsS --max-time "$REQUEST_TIMEOUT_SEC" "$BASE_URL/chat/completions" \
      -H "Authorization: Bearer $API_KEY" \
      -H 'Content-Type: application/json' \
      -d "$(jq -cn \
        --arg model "$MODEL" \
        --arg sp "$sys_prompt" \
        --arg up "$user_prompt" \
        --argjson max_tokens "$MAX_OUTPUT_TOKENS" \
        --argjson temperature "$TEMPERATURE" \
        '{model:$model,messages:[{role:"system",content:$sp},{role:"user",content:$up}],max_tokens:$max_tokens,temperature:$temperature}')" \
      | jq -r '.choices[0].message.content // empty'
  } 2>/dev/null || true)"
fi

clean="$(printf '%s\n' "$raw" | sed -e '/^```[a-zA-Z0-9_-]*$/d' -e '/^```$/d')"

if [ -z "$clean" ]; then
  echo "error: empty response from OpenAI adapter" >&2
  exit 1
fi

printf '%s\n' "$clean"
