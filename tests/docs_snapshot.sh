#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
VERSION="${2:-v1.0.0}"
SNAP_DIR="$ROOT/docs/releases/$VERSION"
MANIFEST="$SNAP_DIR/MANIFEST.sha256"

if [ ! -d "$SNAP_DIR" ]; then
  echo "FAIL: missing docs snapshot dir $SNAP_DIR"
  exit 1
fi
if [ ! -f "$MANIFEST" ]; then
  echo "FAIL: missing docs snapshot manifest $MANIFEST"
  exit 1
fi

(
  cd "$SNAP_DIR"
  sha256sum -c MANIFEST.sha256 >/tmp/l0_docs_snapshot_check.out
)

if ! rg -q ": OK$" /tmp/l0_docs_snapshot_check.out; then
  echo "FAIL: snapshot manifest check produced no OK entries"
  exit 1
fi

echo "ok"
