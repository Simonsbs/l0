#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:-v1.0.0}"
SNAP_DIR="$ROOT/docs/releases/$VERSION"
SNAP_DOCS_DIR="$SNAP_DIR/docs"

mkdir -p "$SNAP_DOCS_DIR"

# Freeze canonical docs into a versioned snapshot folder.
find "$ROOT/docs" -maxdepth 1 -type f \( -name '*.md' -o -name '*.json' \) -print0 | sort -z | while IFS= read -r -d '' f; do
  base="$(basename "$f")"
  cp "$f" "$SNAP_DOCS_DIR/$base"
done

{
  echo "# $VERSION Documentation Snapshot"
  echo
  echo "I generated this snapshot from canonical docs in \`docs/\`."
  echo "I treat this directory as frozen release documentation for $VERSION."
  echo
  echo "Generated UTC: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
} > "$SNAP_DIR/README.md"

(
  cd "$SNAP_DIR"
  rm -f MANIFEST.sha256
  find docs -type f \( -name '*.md' -o -name '*.json' \) | sort | while IFS= read -r p; do
    sha256sum "$p"
  done > MANIFEST.sha256
)

echo "ok"
