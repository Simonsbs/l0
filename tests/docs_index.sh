#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
EXPECTED="$ROOT/docs/LLM_DOC_INDEX.json"
TMP="$(mktemp "${TMPDIR:-/tmp}/l0_docs_index.XXXXXX")"
trap 'rm -f "$TMP"' EXIT

bash "$ROOT/scripts/generate_docs_index.sh" "$TMP" >/tmp/l0_docs_index_gen.out
if ! grep -q '^ok$' /tmp/l0_docs_index_gen.out; then
  echo "FAIL: docs index generator did not report ok"
  exit 1
fi

if [ ! -f "$EXPECTED" ]; then
  echo "FAIL: missing docs index $EXPECTED"
  exit 1
fi

if ! cmp -s "$TMP" "$EXPECTED"; then
  echo "FAIL: docs index drift (run scripts/generate_docs_index.sh)"
  exit 1
fi

echo "ok"
