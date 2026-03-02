#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"

bash "$ROOT/scripts/sync_wiki.sh" --check >/tmp/l0_docs_wiki_sync_check.out
if ! grep -q '^ok$' /tmp/l0_docs_wiki_sync_check.out; then
  echo "FAIL: docs/wiki sync check did not report ok"
  exit 1
fi

echo "ok"
