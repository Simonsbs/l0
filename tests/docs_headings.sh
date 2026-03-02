#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"

fail=0
while IFS= read -r md; do
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT
  rg '^#+' "$md" | sed -E 's/^#+[[:space:]]+//' | tr '[:upper:]' '[:lower:]' | sed -E 's/[[:space:]]+/ /g' > "$tmp"
  dups=$(sort "$tmp" | uniq -d || true)
  if [ -n "$dups" ]; then
    echo "FAIL: duplicate headings in ${md#$ROOT/}"
    echo "$dups"
    fail=1
  fi
  rm -f "$tmp"
  trap - EXIT
done < <(find "$ROOT/docs" -maxdepth 1 -type f -name '*.md' | sort)

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "ok"
