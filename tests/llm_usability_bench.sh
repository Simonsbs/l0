#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"
MODE="${3:-reference}"
OUT_JSON="${4:-$ROOT/docs/LLM_BENCHMARK_RESULTS.json}"
OUT_MD="${5:-$ROOT/docs/LLM_BENCHMARK_RESULTS.md}"
TASKS="${6:-$ROOT/tests/llm_bench/tasks.tsv}"

TMP_BASE="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "$TMP_BASE/l0_llm_bench.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

if [ ! -f "$TASKS" ]; then
  echo "FAIL: missing tasks file $TASKS"
  exit 1
fi

token_proxy() {
  # Deterministic whitespace token proxy for cross-format relative comparisons.
  wc -w | awk '{print $1}'
}

gen_candidate() {
  local prompt="$1"
  local expected="$2"
  local out="$3"
  if [ "$MODE" = "reference" ]; then
    cp "$expected" "$out"
    return 0
  fi
  if [ "$MODE" = "cmd" ]; then
    if [ -z "${L0_LLM_ADAPTER_CMD:-}" ]; then
      echo "FAIL: MODE=cmd requires L0_LLM_ADAPTER_CMD"
      exit 1
    fi
    # Adapter must read prompt text from stdin and print L0 source to stdout.
    cat "$prompt" | bash -lc "$L0_LLM_ADAPTER_CMD" >"$out"
    return 0
  fi
  echo "FAIL: unsupported mode '$MODE' (use reference or cmd)"
  exit 1
}

rows_json="$WORK_DIR/rows.jsonl"
: > "$rows_json"

while IFS='|' read -r id prompt_rel expected_rel c_rel run_args expected_stdout; do
  [ -n "$id" ] || continue
  case "$id" in
    \#*) continue ;;
  esac

  prompt="$ROOT/$prompt_rel"
  expected="$ROOT/$expected_rel"
  cfile="$ROOT/$c_rel"

  if [ ! -f "$prompt" ] || [ ! -f "$expected" ] || [ ! -f "$cfile" ]; then
    echo "FAIL: missing benchmark input for $id"
    exit 1
  fi

  cand="$WORK_DIR/$id.l0"
  gen_candidate "$prompt" "$expected" "$cand"

  prompt_tokens="$(token_proxy < "$prompt")"
  l0_tokens="$(token_proxy < "$cand")"
  c_tokens="$(token_proxy < "$cfile")"

  verify_ok=false
  semantic_ok=false
  turns_to_pass=0
  if "$BIN" verify "$cand" >/tmp/l0_llm_bench_verify.out 2>/tmp/l0_llm_bench_verify.err; then
    verify_ok=true
    turns_to_pass=1
    if [ -n "$run_args" ]; then
      img="$WORK_DIR/$id.img"
      "$BIN" build "$cand" "$img" >/tmp/l0_llm_bench_build.out 2>/tmp/l0_llm_bench_build.err || true
      if grep -q '^ok$' /tmp/l0_llm_bench_build.out; then
        # shellcheck disable=SC2086
        run_out="$("$BIN" run "$img" $run_args 2>/tmp/l0_llm_bench_run.err || true)"
        run_out="${run_out//$'\n'/}"
        if [ "$run_out" = "$expected_stdout" ]; then
          semantic_ok=true
        fi
      fi
    fi
  fi

  ratio_l0_vs_c="$(awk -v l="$l0_tokens" -v c="$c_tokens" 'BEGIN { if (c == 0) print "0.0"; else printf "%.4f", l/c }')"

  jq -cn \
    --arg id "$id" \
    --arg mode "$MODE" \
    --arg prompt_file "$prompt_rel" \
    --arg expected_l0 "$expected_rel" \
    --arg baseline_c "$c_rel" \
    --arg run_args "$run_args" \
    --arg expected_stdout "$expected_stdout" \
    --argjson prompt_tokens "$prompt_tokens" \
    --argjson l0_tokens "$l0_tokens" \
    --argjson c_tokens "$c_tokens" \
    --arg ratio_l0_vs_c "$ratio_l0_vs_c" \
    --argjson verify_ok "$verify_ok" \
    --argjson semantic_ok "$semantic_ok" \
    --argjson turns_to_pass "$turns_to_pass" \
    '{
      id: $id,
      mode: $mode,
      prompt_file: $prompt_file,
      expected_l0: $expected_l0,
      baseline_c: $baseline_c,
      run_args: $run_args,
      expected_stdout: $expected_stdout,
      prompt_tokens: $prompt_tokens,
      l0_tokens: $l0_tokens,
      c_tokens: $c_tokens,
      l0_vs_c_token_ratio: ($ratio_l0_vs_c|tonumber),
      verify_ok: $verify_ok,
      semantic_ok: $semantic_ok,
      turns_to_pass: $turns_to_pass
    }' >> "$rows_json"
done < "$TASKS"

jq -s '
  . as $rows
  | ($rows | map(select(.verify_ok)) | length) as $verify_count
  | ($rows | map(select(.semantic_ok)) | length) as $semantic_count
  | ($rows | length) as $total
  | {
      generated_utc: (now | todateiso8601),
      mode: ($rows[0].mode // "unknown"),
      total_tasks: $total,
      verify_success_count: $verify_count,
      verify_success_rate_pct: (if $total > 0 then ($verify_count * 100.0 / $total) else 0 end),
      semantic_success_count: $semantic_count,
      semantic_success_rate_pct: (if $total > 0 then ($semantic_count * 100.0 / $total) else 0 end),
      avg_turns_to_pass: (if $total > 0 then (($rows | map(.turns_to_pass) | add) / $total) else 0 end),
      avg_prompt_tokens: (if $total > 0 then (($rows | map(.prompt_tokens) | add) / $total) else 0 end),
      avg_l0_tokens: (if $total > 0 then (($rows | map(.l0_tokens) | add) / $total) else 0 end),
      avg_c_tokens: (if $total > 0 then (($rows | map(.c_tokens) | add) / $total) else 0 end),
      avg_l0_vs_c_token_ratio: (if $total > 0 then (($rows | map(.l0_vs_c_token_ratio) | add) / $total) else 0 end),
      tokens_per_verified_program: (
        if $verify_count > 0
        then (($rows | map(.prompt_tokens + .l0_tokens) | add) / $verify_count)
        else null
        end
      ),
      tokens_per_semantic_program: (
        if $semantic_count > 0
        then (($rows | map(.prompt_tokens + .l0_tokens) | add) / $semantic_count)
        else null
        end
      ),
      notes: [
        "Token counts are deterministic whitespace-token proxies for relative comparison.",
        "Parse and verify are combined under l0c verify in this benchmark."
      ],
      tasks: $rows
    }
' "$rows_json" > "$OUT_JSON"

jq -r '
  "# LLM Usability and Token Efficiency Results\n\n" +
  "I generated this report with `tests/llm_usability_bench.sh`.\n\n" +
  "- generated_utc: `" + .generated_utc + "`\n" +
  "- mode: `" + .mode + "`\n" +
  "- total_tasks: `" + (.total_tasks|tostring) + "`\n\n" +
  "## Summary\n\n" +
  "| Metric | Value |\n|---|---:|\n" +
  "| Verify success rate | " + (.verify_success_rate_pct|tostring) + "% |\n" +
  "| Semantic success rate | " + (.semantic_success_rate_pct|tostring) + "% |\n" +
  "| Avg turns to pass | " + (.avg_turns_to_pass|tostring) + " |\n" +
  "| Avg prompt tokens (proxy) | " + (.avg_prompt_tokens|tostring) + " |\n" +
  "| Avg L0 tokens (proxy) | " + (.avg_l0_tokens|tostring) + " |\n" +
  "| Avg C tokens (proxy) | " + (.avg_c_tokens|tostring) + " |\n" +
  "| Avg L0/C token ratio | " + (.avg_l0_vs_c_token_ratio|tostring) + " |\n" +
  "| Tokens per verified program | " + (.tokens_per_verified_program|tostring) + " |\n" +
  "| Tokens per semantic program | " + (.tokens_per_semantic_program|tostring) + " |\n\n" +
  "## Task Matrix\n\n" +
  "| Task | Verify | Semantic | Prompt tok | L0 tok | C tok | L0/C |\n|---|---:|---:|---:|---:|---:|---:|\n" +
  ( .tasks
    | map("| " + .id + " | " + (.verify_ok|tostring) + " | " + (.semantic_ok|tostring) + " | " + (.prompt_tokens|tostring) + " | " + (.l0_tokens|tostring) + " | " + (.c_tokens|tostring) + " | " + (.l0_vs_c_token_ratio|tostring) + " |")
    | join("\n")
  ) + "\n\n" +
  "## Notes\n\n" +
  "- Token values are whitespace-token proxies for deterministic relative tracking.\n" +
  "- `l0c verify` covers parser+verifier in this benchmark surface.\n"
' "$OUT_JSON" > "$OUT_MD"

echo "ok"
