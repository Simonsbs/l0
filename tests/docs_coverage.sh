#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"

CMD_DOC="$ROOT/docs/COMMAND_REFERENCE.md"
OPS_DOC="$ROOT/docs/INSTRUCTION_SET.md"
EX_DOC="$ROOT/docs/EXAMPLES_CATALOG.md"
MAT_DOC="$ROOT/docs/COVERAGE_MATRIX.md"
GRAMMAR_DOC="$ROOT/docs/GRAMMAR_AND_TYPING.md"
PROMPT_DOC="$ROOT/docs/LLM_PROMPT_PACK.md"

for f in "$CMD_DOC" "$OPS_DOC" "$EX_DOC" "$MAT_DOC" "$GRAMMAR_DOC" "$PROMPT_DOC"; do
  if [ ! -f "$f" ]; then
    echo "FAIL: docs coverage missing required file $(basename "$f")"
    exit 1
  fi
done

commands=(
  canon verify build build-elf imgcheck imgmeta run tracecat mapcat schemacat tracejoin
)
for cmd in "${commands[@]}"; do
  if ! rg -F -q "## \`$cmd\`" "$CMD_DOC"; then
    echo "FAIL: docs coverage missing command section for $cmd"
    exit 1
  fi
  if ! awk "/## \`$cmd\`/{flag=1;next}/^## /{flag=0}flag" "$CMD_DOC" | rg -F -q "Failure example:"; then
    echo "FAIL: docs coverage missing failure example for $cmd"
    exit 1
  fi
done

ops=(
  arg const add.wrap add.trap sub.wrap sub.trap mul.wrap mul.trap and or xor shl shr icmp.eq call
  alloca ld gep malloc st free write exit trace br cbr ret
)
for op in "${ops[@]}"; do
  if ! rg -F -q "$op" "$OPS_DOC"; then
    echo "FAIL: docs coverage missing op mention for $op"
    exit 1
  fi
done

example_count=0
while IFS= read -r p; do
  [ -n "$p" ] || continue
  case "$p" in
    docs/examples/*.l0)
      example_count=$((example_count + 1))
      if [ ! -f "$ROOT/$p" ]; then
        echo "FAIL: docs coverage example path missing: $p"
        exit 1
      fi
      ;;
  esac
done < <(rg -o "docs/examples/[A-Za-z0-9_./-]+\.l0" "$EX_DOC" | sort -u)

if [ "$example_count" -lt 10 ]; then
  echo "FAIL: docs coverage catalog unexpectedly small"
  exit 1
fi

# Ensure matrix points to baseline docs and gates.
required_refs=(
  docs/COMMAND_REFERENCE.md
  docs/INSTRUCTION_SET.md
  docs/GRAMMAR_AND_TYPING.md
  docs/LLM_PROMPT_PACK.md
  docs/INTRINSIC_CONTRACTS.md
  tests/verifier_matrix.sh
  tests/deterministic_builds.sh
  tests/error_model.sh
  tests/release_pipeline.sh
  tests/compatibility_matrix.sh
  tests/production_readiness.sh
  tests/docs_links.sh
  tests/docs_headings.sh
)
for ref in "${required_refs[@]}"; do
  if ! rg -q "$ref" "$MAT_DOC"; then
    echo "FAIL: docs coverage matrix missing reference $ref"
    exit 1
  fi
done

echo "ok"
