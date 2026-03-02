#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"

fail=0
while IFS= read -r md; do
  dir="$(dirname "$md")"
  while IFS= read -r link; do
    target="$link"
    case "$target" in
      http://*|https://*|mailto:*|\#*|*.com*|*.org*) continue ;;
      '') continue ;;
    esac
    # strip optional anchor
    target="${target%%#*}"
    [ -n "$target" ] || continue

    case "$target" in
      /*) abs="$target" ;;
      *) abs="$dir/$target" ;;
    esac
    abs="$(realpath -m "$abs")"
    if [ ! -e "$abs" ]; then
      echo "FAIL: docs link broken in ${md#$ROOT/}: $link"
      fail=1
    fi
  done < <(rg -o "\]\(([^)]+)\)" "$md" | sed -E 's/^\]\((.*)\)$/\1/' | sort -u)
done < <(find "$ROOT/docs" -maxdepth 1 -type f -name '*.md' | sort)

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "ok"
