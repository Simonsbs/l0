#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"
OUT_DIR="${3:-$ROOT/dist}"
VERSION="${4:-0.1.0-rc1}"

if ! command -v sha256sum >/dev/null 2>&1; then
  echo "error: sha256sum is required for release pipeline" >&2
  exit 2
fi
if ! command -v tar >/dev/null 2>&1; then
  echo "error: tar is required for release pipeline" >&2
  exit 2
fi

mkdir -p "$OUT_DIR"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/l0_release.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

PKG_NAME="l0-${VERSION}-linux-x86_64"
PKG_DIR="$WORK_DIR/$PKG_NAME"
mkdir -p "$PKG_DIR"

cp "$BIN" "$PKG_DIR/l0c"
chmod 0755 "$PKG_DIR/l0c"

# Snapshot release metadata.
COMMIT="unknown"
if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  COMMIT="$(git -C "$ROOT" rev-parse --short HEAD)"
fi

cat > "$PKG_DIR/RELEASE_MANIFEST.txt" <<MANIFEST
name $PKG_NAME
version $VERSION
target linux-x86_64
commit $COMMIT
contract intrinsics.v1 docs/INTRINSIC_CONTRACTS.md
contract debugmap.v1 docs/DEBUG_MAP_SCHEMA.md
contract traceschema.v1 docs/TRACE_SCHEMA.md
contract detbuild.v1 docs/DETERMINISTIC_BUILDS.md
contract diffsem.v1 docs/DIFFERENTIAL_TESTING.md
contract fuzzstress.v1 docs/FUZZ_STRESS.md
contract perfbase.v1 docs/PERFORMANCE_BASELINES.md
contract errmodel.v1 docs/ERROR_MODEL.md
MANIFEST

cat > "$PKG_DIR/README_RELEASE.txt" <<README
This release candidate package contains the L0 bootstrap compiler for Linux x86-64.

Quick smoke test:
  ./l0c verify tests/valid_min.l0
  ./l0c build tests/valid_min.l0 /tmp/l0_release_smoke.img
  ./l0c run /tmp/l0_release_smoke.img 5 8
README

# End-to-end package smoke checks using the packaged binary.
"$PKG_DIR/l0c" verify "$ROOT/tests/valid_min.l0" >"$WORK_DIR/smoke_verify.out"
if ! grep -q '^ok$' "$WORK_DIR/smoke_verify.out"; then
  echo "error: release smoke verify failed" >&2
  exit 3
fi
"$PKG_DIR/l0c" build "$ROOT/tests/valid_min.l0" "$WORK_DIR/smoke.img" >"$WORK_DIR/smoke_build.out"
if ! grep -q '^ok$' "$WORK_DIR/smoke_build.out"; then
  echo "error: release smoke build failed" >&2
  exit 3
fi
"$PKG_DIR/l0c" imgcheck "$WORK_DIR/smoke.img" >"$WORK_DIR/smoke_imgcheck.out"
if ! grep -q '^ok$' "$WORK_DIR/smoke_imgcheck.out"; then
  echo "error: release smoke imgcheck failed" >&2
  exit 3
fi
"$PKG_DIR/l0c" run "$WORK_DIR/smoke.img" 5 8 >"$WORK_DIR/smoke_run.out"
if [ "$(cat "$WORK_DIR/smoke_run.out")" != "13" ]; then
  echo "error: release smoke run output mismatch" >&2
  exit 3
fi

# Deterministic tarball construction flags for reproducible packaging bytes.
TAR_PATH="$OUT_DIR/${PKG_NAME}.tar"
TGZ_PATH="$OUT_DIR/${PKG_NAME}.tar.gz"
(
  cd "$WORK_DIR"
  tar --sort=name --mtime='UTC 1970-01-01' --owner=0 --group=0 --numeric-owner -cf "$TAR_PATH" "$PKG_NAME"
)
gzip -n -f "$TAR_PATH"

# Per-artifact checksums and aggregate checksum list.
BIN_ARTIFACT="$OUT_DIR/${PKG_NAME}.l0c"
MANIFEST_ARTIFACT="$OUT_DIR/${PKG_NAME}.manifest.txt"
cp "$PKG_DIR/l0c" "$BIN_ARTIFACT"
cp "$PKG_DIR/RELEASE_MANIFEST.txt" "$MANIFEST_ARTIFACT"

BIN_SHA_FILE="$OUT_DIR/${PKG_NAME}.l0c.sha256"
MANIFEST_SHA_FILE="$OUT_DIR/${PKG_NAME}.manifest.sha256"
PKG_SHA_FILE="$OUT_DIR/${PKG_NAME}.tar.gz.sha256"
ALL_SHA_FILE="$OUT_DIR/${PKG_NAME}.sha256"

(
  cd "$OUT_DIR"
  sha256sum "${PKG_NAME}.l0c" > "${PKG_NAME}.l0c.sha256"
  sha256sum "${PKG_NAME}.manifest.txt" > "${PKG_NAME}.manifest.sha256"
  sha256sum "${PKG_NAME}.tar.gz" > "${PKG_NAME}.tar.gz.sha256"
)
cat "$BIN_SHA_FILE" "$MANIFEST_SHA_FILE" "$PKG_SHA_FILE" > "$ALL_SHA_FILE"

# Verify recorded checksums immediately.
(
  cd "$OUT_DIR"
  sha256sum -c "${PKG_NAME}.l0c.sha256" >/dev/null
  sha256sum -c "${PKG_NAME}.manifest.sha256" >/dev/null
  sha256sum -c "${PKG_NAME}.tar.gz.sha256" >/dev/null
)

# Also stage unpack check.
UNPACK_DIR="$WORK_DIR/unpack"
mkdir -p "$UNPACK_DIR"
tar -xzf "$TGZ_PATH" -C "$UNPACK_DIR"
"$UNPACK_DIR/$PKG_NAME/l0c" verify "$ROOT/tests/valid_min.l0" >"$WORK_DIR/unpack_verify.out"
if ! grep -q '^ok$' "$WORK_DIR/unpack_verify.out"; then
  echo "error: release unpack verify failed" >&2
  exit 3
fi

echo "ok"
