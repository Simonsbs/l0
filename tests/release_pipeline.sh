#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"

REL_SCRIPT="$ROOT/scripts/release_candidate.sh"
if [ ! -x "$REL_SCRIPT" ]; then
  echo "FAIL: M68 release script missing or not executable"
  exit 1
fi

OUT_A="$(mktemp -d "${TMPDIR:-/tmp}/l0_m68_a.XXXXXX")"
OUT_B="$(mktemp -d "${TMPDIR:-/tmp}/l0_m68_b.XXXXXX")"
trap 'rm -rf "$OUT_A" "$OUT_B"' EXIT

VERSION="0.1.0-rc-m68"
PKG="l0-${VERSION}-linux-x86_64"

"$REL_SCRIPT" "$BIN" "$ROOT" "$OUT_A" "$VERSION" >"$OUT_A/release.out"
if ! grep -q '^ok$' "$OUT_A/release.out"; then
  echo "FAIL: M68 release script first pass did not report ok"
  exit 1
fi

"$REL_SCRIPT" "$BIN" "$ROOT" "$OUT_B" "$VERSION" >"$OUT_B/release.out"
if ! grep -q '^ok$' "$OUT_B/release.out"; then
  echo "FAIL: M68 release script second pass did not report ok"
  exit 1
fi

for p in \
  "$OUT_A/${PKG}.tar.gz" \
  "$OUT_A/${PKG}.tar.gz.sha256" \
  "$OUT_A/${PKG}.l0c.sha256" \
  "$OUT_A/${PKG}.manifest.sha256" \
  "$OUT_A/${PKG}.sha256"; do
  if [ ! -f "$p" ]; then
    echo "FAIL: M68 expected release artifact missing: $(basename "$p")"
    exit 1
  fi
done

if ! cmp -s "$OUT_A/${PKG}.tar.gz" "$OUT_B/${PKG}.tar.gz"; then
  echo "FAIL: M68 release tarball is not reproducible across two runs"
  exit 1
fi
if ! cmp -s "$OUT_A/${PKG}.sha256" "$OUT_B/${PKG}.sha256"; then
  echo "FAIL: M68 checksum aggregate file differs across two runs"
  exit 1
fi

(
  cd "$OUT_A"
  sha256sum -c "${PKG}.tar.gz.sha256" >/dev/null
  sha256sum -c "${PKG}.l0c.sha256" >/dev/null
  sha256sum -c "${PKG}.manifest.sha256" >/dev/null
)

echo "ok"
