#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"
MODE="${3:-reference}"
OUT_JSON="${4:-$ROOT/docs/LLM_BENCHMARK_RESULTS.json}"
OUT_MD="${5:-$ROOT/docs/LLM_BENCHMARK_RESULTS.md}"
TASKS="${6:-$ROOT/tests/llm_bench/tasks.tsv}"
MAX_ATTEMPTS_DEFAULT="${L0_LLM_MAX_ATTEMPTS:-3}"
ENABLE_REPAIR_LOOP="${L0_LLM_ENABLE_REPAIR_LOOP:-1}"
AUTO_CANON_FIX="${L0_LLM_AUTO_CANON_FIX:-1}"
KEEP_WORK_DIR="${L0_LLM_KEEP_WORK_DIR:-0}"

TMP_BASE="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "$TMP_BASE/l0_llm_bench.XXXXXX")"
if [ "$KEEP_WORK_DIR" = "1" ]; then
  trap 'echo "llm_bench_work_dir $WORK_DIR" >&2' EXIT
else
  trap 'rm -rf "$WORK_DIR"' EXIT
fi

if [ ! -f "$TASKS" ]; then
  echo "FAIL: missing tasks file $TASKS"
  exit 1
fi

if [ "$MODE" != "reference" ] && [ "$MODE" != "cmd" ]; then
  echo "FAIL: unsupported mode '$MODE' (use reference or cmd)"
  exit 1
fi

if [ "$MODE" = "cmd" ] && [ -z "${L0_LLM_ADAPTER_CMD:-}" ]; then
  echo "FAIL: MODE=cmd requires L0_LLM_ADAPTER_CMD"
  exit 1
fi

token_proxy() {
  # Deterministic whitespace token proxy for cross-format relative comparisons.
  wc -w | awk '{print $1}'
}

gen_candidate_reference() {
  local expected="$1"
  local out="$2"
  cp "$expected" "$out"
}

gen_candidate_cmd() {
  local prompt_text="$1"
  local out="$2"
  # Adapter must read prompt text from stdin and print L0 source to stdout.
  printf '%s\n' "$prompt_text" | bash -lc "$L0_LLM_ADAPTER_CMD" >"$out"
}

sanitize_candidate() {
  local in="$1"
  local out="$2"
  local tmp="$WORK_DIR/sanitize.tmp"
  local trimmed="$WORK_DIR/sanitize.trimmed.tmp"
  local norm="$WORK_DIR/sanitize.norm.tmp"
  local norm2="$WORK_DIR/sanitize.norm2.tmp"

  sed -e 's/\r$//' -e '/^```[a-zA-Z0-9_-]*$/d' -e '/^```$/d' "$in" >"$tmp"
  awk '
    BEGIN { started = 0; emitted = 0 }
    /^ver[[:space:]][0-9]+$/ { started = 1 }
    {
      if (started) {
        print
        emitted = 1
      }
    }
  ' "$tmp" >"$trimmed" || true

  if [ -s "$trimmed" ]; then
    cp "$trimmed" "$out"
  else
    cp "$tmp" "$out"
  fi

  # Normalize common near-canonical top-level section layouts into single-line canonical section forms.
  awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    BEGIN { insec = 0; sec = ""; buf = "" }
    {
      line = $0
      t = trim(line)

      if (insec == 0) {
        if (match(t, /^(types|consts|extern|globals)[ \t]*\{[ \t]*$/)) {
          sec = substr(t, RSTART, RLENGTH)
          sub(/[ \t]*\{[ \t]*$/, "", sec)
          insec = 1
          buf = ""
          next
        }
        if (match(t, /^(types|consts|extern|globals)[ \t]*\{.*\}[ \t]*$/)) {
          sec = t
          sub(/[ \t]*\{.*/, "", sec)
          body = t
          sub(/^[^{]*\{/, "", body)
          sub(/\}[ \t]*$/, "", body)
          body = trim(body)
          if (body == "") print sec " { }"
          else print sec " { " body " }"
          next
        }
        print line
      } else {
        if (t ~ /^\}[ \t]*$/) {
          body = trim(buf)
          if (body == "") print sec " { }"
          else print sec " { " body " }"
          insec = 0
          sec = ""
          buf = ""
          next
        }
        if (t != "") {
          if (buf == "") buf = t
          else buf = buf " " t
        }
      }
    }
    END {
      if (insec == 1) {
        body = trim(buf)
        if (body == "") print sec " { }"
        else print sec " { " body " }"
      }
    }
  ' "$out" >"$norm"
  awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    BEGIN { in_fn = 0 }
    {
      line = $0
      t = trim(line)
      if (t == "") next

      if (t == "fns{" || t == "fns {") {
        print "fns {"
        next
      }

      if (t ~ /^fn[ \t]/) {
        print t
        in_fn = 1
        next
      }

      if (t ~ /^b[0-9]+:$/) {
        print t
        next
      }

      if (t == "}") {
        print "}"
        if (in_fn == 1) in_fn = 0
        next
      }

      if (in_fn == 1) {
        print "  " t
        next
      }

      print t
    }
  ' "$norm" >"$norm2"
  cp "$norm2" "$out"
}

canon_fix_candidate() {
  local in="$1"
  local out="$2"
  local canon_tmp="$WORK_DIR/canon.tmp"
  if [ "$AUTO_CANON_FIX" = "1" ]; then
    if "$BIN" canon "$in" >"$canon_tmp" 2>"$WORK_DIR/canon.err"; then
      cp "$canon_tmp" "$out"
      return 0
    fi
  fi
  cp "$in" "$out"
  return 1
}

classify_verify_error() {
  local err_file="$1"
  if [ ! -s "$err_file" ]; then
    echo "none"
    return 0
  fi
  if grep -Eqi "non-canonical|invalid module shape" "$err_file"; then
    echo "non_canonical"
    return 0
  fi
  if grep -Eqi "type|typed|pointer" "$err_file"; then
    echo "type_or_pointer"
    return 0
  fi
  if grep -Eqi "ssa|def-before-use|def before use" "$err_file"; then
    echo "ssa_or_defuse"
    return 0
  fi
  if grep -Eqi "terminator|\bret\b|\bbr\b|\bcbr\b|unreachable" "$err_file"; then
    echo "terminator_or_cfg"
    return 0
  fi
  if grep -Eqi "\barg\b" "$err_file"; then
    echo "arg_usage"
    return 0
  fi
  if grep -Eqi "parse|syntax" "$err_file"; then
    echo "parse"
    return 0
  fi
  echo "other"
}

effective_max_attempts() {
  if [ "$MODE" = "reference" ]; then
    echo "1"
    return 0
  fi
  if [ "$ENABLE_REPAIR_LOOP" = "1" ]; then
    echo "$MAX_ATTEMPTS_DEFAULT"
    return 0
  fi
  echo "1"
}

repair_hint() {
  local task_id="$1"
  local err_class="$2"
  case "$err_class" in
    non_canonical)
      cat <<'EOT'
Canonical repair requirements:
- Keep exact top-level section order and exact canonical section line format.
- In `types { ... }`, separate multiple entries with commas (example: `types { t0=i64, t1=i1 }`).
- Use only canonical memory ops/opcode spellings:
  - `v1 = alloca t0, 1 : t1`
  - `st v1 v0`
  - `v2 = ld v1 : t0`
- Use canonical compare spelling: `v2 = icmp.eq v0 v1 : t1`
- Use only `br`, `cbr`, `ret` as terminators.
- Return only one plain canonical L0 module. No comments and no prose.
EOT
      ;;
    type_or_pointer)
      cat <<'EOT'
Type repair requirements:
- Ensure all value result types exactly match opcode rules.
- For `icmp.*`, result type must be `i1`.
- For memory, pointer values must have pointer type and `ld`/`st` use pointer operand first.
EOT
      ;;
    ssa_or_defuse)
      cat <<'EOT'
SSA repair requirements:
- Every `vN` must be defined before use.
- Do not redefine the same `vN`.
- Keep block/value numbering contiguous and deterministic.
EOT
      ;;
    terminator_or_cfg)
      cat <<'EOT'
CFG repair requirements:
- Every block ends with exactly one terminator (`br`, `cbr`, or `ret`).
- No instructions after a terminator.
- Branch targets must refer to existing blocks.
EOT
      ;;
    *)
      echo "Return a valid canonical L0 module only."
      ;;
  esac

  case "$task_id" in
    t03_cbr_select)
      cat <<'EOT'
Task-specific hint:
- Input type is `i1`, so canonical solution is direct branch with two returns.
- Use only `cbr` + blocks + `ret`; do not use `phi`, `zext`, or any cast ops.
- Valid shape:
  - `fn f0 (t0)->t0`
  - `b0: cbr v0 b1 b2`
  - `b1: ret v0`
  - `b2: ret v0`
EOT
      ;;
    t04_mem_roundtrip)
      cat <<'EOT'
Task-specific hint:
- Roundtrip one i64 through stack memory using `alloca`, `st`, and `ld`.
- Example shape: `alloca t0, 1 : t1` where `t1` is a byte pointer type.
EOT
      ;;
    t06_sysv_sum6)
      cat <<'EOT'
Task-specific hint:
- Sum exactly six arguments: `arg 0` through `arg 5`.
- Return only the final accumulated sum.
EOT
      ;;
  esac
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

  prompt_tokens_base="$(token_proxy < "$prompt")"
  c_tokens="$(token_proxy < "$cfile")"

  attempts_max="$(effective_max_attempts)"
  attempts_used=0
  verify_pass_attempt=0
  semantic_pass_attempt=0
  verify_ok=false
  semantic_ok=false
  last_error_class="none"
  canonicalized=false
  prompt_tokens_total=0
  completion_tokens_total=0

  base_prompt_text="$(cat "$prompt")"
  previous_error_line=""
  previous_error_class="none"
  previous_candidate_text=""
  cand="$WORK_DIR/$id.final.l0"
  : > "$cand"

  for attempt in $(seq 1 "$attempts_max"); do
    attempts_used="$attempt"
    raw="$WORK_DIR/$id.attempt${attempt}.raw.l0"
    sanitized="$WORK_DIR/$id.attempt${attempt}.san.l0"
    fixed="$WORK_DIR/$id.attempt${attempt}.fix.l0"
    verify_out="$WORK_DIR/$id.attempt${attempt}.verify.out"
    verify_err="$WORK_DIR/$id.attempt${attempt}.verify.err"

    if [ "$MODE" = "reference" ]; then
      gen_candidate_reference "$expected" "$raw"
      prompt_tokens_total="$((prompt_tokens_total + prompt_tokens_base))"
    else
      prompt_text="$base_prompt_text"
      if [ "$attempt" -gt 1 ]; then
        repair_guidance="$(repair_hint "$id" "$previous_error_class")"
        prompt_text="$(cat <<EOP
$base_prompt_text

Repair attempt $attempt of $attempts_max.
Previous verifier error class: $previous_error_class
Previous verifier error: $previous_error_line
Return only corrected canonical L0 source for the same task.
$repair_guidance

Previous candidate:
$previous_candidate_text
EOP
)"
      fi
      pt="$(printf '%s\n' "$prompt_text" | token_proxy)"
      prompt_tokens_total="$((prompt_tokens_total + pt))"
      if ! gen_candidate_cmd "$prompt_text" "$raw"; then
        previous_error_line="adapter invocation failed"
        previous_error_class="adapter"
        last_error_class="adapter"
        continue
      fi
    fi

    sanitize_candidate "$raw" "$sanitized"
    if canon_fix_candidate "$sanitized" "$fixed"; then
      canonicalized=true
    fi

    ct="$(token_proxy < "$fixed")"
    completion_tokens_total="$((completion_tokens_total + ct))"
    cp "$fixed" "$cand"

    if "$BIN" verify "$cand" >"$verify_out" 2>"$verify_err"; then
      verify_ok=true
      verify_pass_attempt="$attempt"
      break
    fi

    previous_error_line="$(head -n1 "$verify_err" | tr -d '\r')"
    previous_error_class="$(classify_verify_error "$verify_err")"
    last_error_class="$previous_error_class"
    previous_candidate_text="$(cat "$cand")"
  done

  turns_to_pass=0
  if [ "$verify_pass_attempt" -gt 0 ]; then
    verify_ok=true
    turns_to_pass="$verify_pass_attempt"
    if [ -n "$run_args" ]; then
      img="$WORK_DIR/$id.img"
      "$BIN" build "$cand" "$img" >"$WORK_DIR/$id.build.out" 2>"$WORK_DIR/$id.build.err" || true
      if grep -q '^ok$' "$WORK_DIR/$id.build.out"; then
        # shellcheck disable=SC2086
        run_out="$($BIN run "$img" $run_args 2>"$WORK_DIR/$id.run.err" || true)"
        run_out="${run_out//$'\n'/}"
        if [ "$run_out" = "$expected_stdout" ]; then
          semantic_ok=true
          semantic_pass_attempt="$verify_pass_attempt"
        fi
      fi
    fi
  fi

  l0_tokens="0"
  if [ -s "$cand" ]; then
    l0_tokens="$(token_proxy < "$cand")"
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
    --argjson prompt_tokens "$prompt_tokens_total" \
    --argjson prompt_tokens_base "$prompt_tokens_base" \
    --argjson l0_tokens "$l0_tokens" \
    --argjson completion_tokens_total "$completion_tokens_total" \
    --argjson c_tokens "$c_tokens" \
    --arg ratio_l0_vs_c "$ratio_l0_vs_c" \
    --argjson attempts_max "$attempts_max" \
    --argjson attempts_used "$attempts_used" \
    --argjson verify_ok "$verify_ok" \
    --argjson semantic_ok "$semantic_ok" \
    --argjson turns_to_pass "$turns_to_pass" \
    --argjson verify_pass_attempt "$verify_pass_attempt" \
    --argjson semantic_pass_attempt "$semantic_pass_attempt" \
    --arg last_error_class "$last_error_class" \
    --argjson canonicalized "$canonicalized" \
    '{
      id: $id,
      mode: $mode,
      prompt_file: $prompt_file,
      expected_l0: $expected_l0,
      baseline_c: $baseline_c,
      run_args: $run_args,
      expected_stdout: $expected_stdout,
      prompt_tokens: $prompt_tokens,
      prompt_tokens_base: $prompt_tokens_base,
      l0_tokens: $l0_tokens,
      completion_tokens_total: $completion_tokens_total,
      c_tokens: $c_tokens,
      l0_vs_c_token_ratio: ($ratio_l0_vs_c|tonumber),
      attempts_max: $attempts_max,
      attempts_used: $attempts_used,
      verify_ok: $verify_ok,
      semantic_ok: $semantic_ok,
      turns_to_pass: $turns_to_pass,
      verify_pass_attempt: $verify_pass_attempt,
      semantic_pass_attempt: $semantic_pass_attempt,
      last_error_class: $last_error_class,
      canonicalized: $canonicalized
    }' >> "$rows_json"
done < "$TASKS"

jq -s '
  . as $rows
  | ($rows | map(select(.verify_ok)) | length) as $verify_count
  | ($rows | map(select(.semantic_ok)) | length) as $semantic_count
  | ($rows | length) as $total
  | ($rows | map(.attempts_max) | max // 1) as $max_attempts
  | {
      generated_utc: (now | todateiso8601),
      mode: ($rows[0].mode // "unknown"),
      max_attempts: $max_attempts,
      total_tasks: $total,
      verify_success_count: $verify_count,
      verify_success_rate_pct: (if $total > 0 then ($verify_count * 100.0 / $total) else 0 end),
      semantic_success_count: $semantic_count,
      semantic_success_rate_pct: (if $total > 0 then ($semantic_count * 100.0 / $total) else 0 end),
      avg_turns_to_pass: (if $total > 0 then (($rows | map(.turns_to_pass) | add) / $total) else 0 end),
      avg_attempts_used: (if $total > 0 then (($rows | map(.attempts_used) | add) / $total) else 0 end),
      avg_prompt_tokens_base: (if $total > 0 then (($rows | map(.prompt_tokens_base) | add) / $total) else 0 end),
      avg_prompt_tokens: (if $total > 0 then (($rows | map(.prompt_tokens) | add) / $total) else 0 end),
      avg_completion_tokens_total: (if $total > 0 then (($rows | map(.completion_tokens_total) | add) / $total) else 0 end),
      avg_l0_tokens: (if $total > 0 then (($rows | map(.l0_tokens) | add) / $total) else 0 end),
      avg_c_tokens: (if $total > 0 then (($rows | map(.c_tokens) | add) / $total) else 0 end),
      avg_l0_vs_c_token_ratio: (if $total > 0 then (($rows | map(.l0_vs_c_token_ratio) | add) / $total) else 0 end),
      verify_pass_at_k_pct: (
        reduce range(1; ($max_attempts + 1)) as $k ({};
          . + {
            ("k" + ($k|tostring)):
              (if $total > 0
               then (($rows | map(select(.verify_pass_attempt > 0 and .verify_pass_attempt <= $k)) | length) * 100.0 / $total)
               else 0 end)
          }
        )
      ),
      semantic_pass_at_k_pct: (
        reduce range(1; ($max_attempts + 1)) as $k ({};
          . + {
            ("k" + ($k|tostring)):
              (if $total > 0
               then (($rows | map(select(.semantic_pass_attempt > 0 and .semantic_pass_attempt <= $k)) | length) * 100.0 / $total)
               else 0 end)
          }
        )
      ),
      error_class_counts: (
        ($rows | map(.last_error_class) | sort | group_by(.) | map({key: .[0], value: length}) | from_entries)
      ),
      tokens_per_verified_program: (
        if $verify_count > 0
        then (($rows | map(.prompt_tokens + .completion_tokens_total) | add) / $verify_count)
        else null
        end
      ),
      tokens_per_semantic_program: (
        if $semantic_count > 0
        then (($rows | map(.prompt_tokens + .completion_tokens_total) | add) / $semantic_count)
        else null
        end
      ),
      notes: [
        "Token counts are deterministic whitespace-token proxies for relative comparison.",
        "Parse and verify are combined under l0c verify in this benchmark.",
        "In cmd mode, repair-loop prompt/completion totals include all attempts."
      ],
      tasks: $rows
    }
' "$rows_json" > "$OUT_JSON"

{
  echo "# LLM Usability and Token Efficiency Results"
  echo
  echo "I generated this report with \`tests/llm_usability_bench.sh\`."
  echo
  echo "- generated_utc: \`$(jq -r '.generated_utc' "$OUT_JSON")\`"
  echo "- mode: \`$(jq -r '.mode' "$OUT_JSON")\`"
  echo "- max_attempts: \`$(jq -r '.max_attempts' "$OUT_JSON")\`"
  echo "- total_tasks: \`$(jq -r '.total_tasks' "$OUT_JSON")\`"
  echo
  echo "## Summary"
  echo
  echo "| Metric | Value |"
  echo "|---|---:|"
  echo "| Verify success rate | $(jq -r '.verify_success_rate_pct' "$OUT_JSON")% |"
  echo "| Semantic success rate | $(jq -r '.semantic_success_rate_pct' "$OUT_JSON")% |"
  echo "| Avg turns to pass | $(jq -r '.avg_turns_to_pass' "$OUT_JSON") |"
  echo "| Avg attempts used | $(jq -r '.avg_attempts_used' "$OUT_JSON") |"
  echo "| Avg prompt tokens base (proxy) | $(jq -r '.avg_prompt_tokens_base' "$OUT_JSON") |"
  echo "| Avg prompt tokens total (proxy) | $(jq -r '.avg_prompt_tokens' "$OUT_JSON") |"
  echo "| Avg completion tokens total (proxy) | $(jq -r '.avg_completion_tokens_total' "$OUT_JSON") |"
  echo "| Avg L0 tokens (proxy) | $(jq -r '.avg_l0_tokens' "$OUT_JSON") |"
  echo "| Avg C tokens (proxy) | $(jq -r '.avg_c_tokens' "$OUT_JSON") |"
  echo "| Avg L0/C token ratio | $(jq -r '.avg_l0_vs_c_token_ratio' "$OUT_JSON") |"
  echo "| Tokens per verified program | $(jq -r '.tokens_per_verified_program' "$OUT_JSON") |"
  echo "| Tokens per semantic program | $(jq -r '.tokens_per_semantic_program' "$OUT_JSON") |"
  echo
  echo "## Pass@K"
  echo
  echo "| K | Verify pass@k | Semantic pass@k |"
  echo "|---:|---:|---:|"
  maxk="$(jq -r '.max_attempts' "$OUT_JSON")"
  for k in $(seq 1 "$maxk"); do
    vk="$(jq -r ".verify_pass_at_k_pct.k$k" "$OUT_JSON")"
    sk="$(jq -r ".semantic_pass_at_k_pct.k$k" "$OUT_JSON")"
    echo "| $k | ${vk}% | ${sk}% |"
  done
  echo
  echo "## Task Matrix"
  echo
  echo "| Task | Verify | Semantic | Turns | Attempts | Err class | Prompt tok | Out tok | L0 tok | C tok | L0/C |"
  echo "|---|---:|---:|---:|---:|---|---:|---:|---:|---:|---:|"
  jq -r '.tasks[] | "| " + .id + " | " + (.verify_ok|tostring) + " | " + (.semantic_ok|tostring) + " | " + (.turns_to_pass|tostring) + " | " + (.attempts_used|tostring) + "/" + (.attempts_max|tostring) + " | " + .last_error_class + " | " + (.prompt_tokens|tostring) + " | " + (.completion_tokens_total|tostring) + " | " + (.l0_tokens|tostring) + " | " + (.c_tokens|tostring) + " | " + (.l0_vs_c_token_ratio|tostring) + " |"' "$OUT_JSON"
  echo
  echo "## Error Class Counts"
  echo
  jq -r '.error_class_counts | to_entries | sort_by(.key)[] | "- " + .key + ": " + (.value|tostring)' "$OUT_JSON"
  echo
  echo "## Notes"
  echo
  echo "- Token values are whitespace-token proxies for deterministic relative tracking."
  echo "- \`l0c verify\` covers parser+verifier in this benchmark surface."
  echo "- In cmd mode, prompt/output token totals include all repair attempts."
} > "$OUT_MD"

echo "ok"
