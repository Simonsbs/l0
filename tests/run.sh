#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$ROOT/bin/l0c"

"$BIN" verify "$ROOT/tests/valid_min.l0" >/tmp/l0_ok.out
if ! grep -q '^ok$' /tmp/l0_ok.out; then
  echo "FAIL: verify valid_min"
  exit 1
fi

"$BIN" build "$ROOT/tests/valid_min.l0" /tmp/l0_test.img >/tmp/l0_build.out
if ! grep -q '^ok$' /tmp/l0_build.out; then
  echo "FAIL: build valid_min"
  exit 1
fi
if [ ! -s /tmp/l0_test.img ]; then
  echo "FAIL: build output missing"
  exit 1
fi
if [ "$(head -c 4 /tmp/l0_test.img)" != "L0IM" ]; then
  echo "FAIL: build header magic"
  exit 1
fi
in_size=$(wc -c < "$ROOT/tests/valid_min.l0")
img_size=$(wc -c < /tmp/l0_test.img)
expected_size=$((80 + in_size))
if [ "$img_size" -ne "$expected_size" ]; then
  echo "FAIL: build image size mismatch"
  exit 1
fi
version=$(od -An -t u8 -j 8 -N 8 /tmp/l0_test.img | tr -d ' ')
hdr_size=$(od -An -t u8 -j 16 -N 8 /tmp/l0_test.img | tr -d ' ')
src_off=$(od -An -t u8 -j 32 -N 8 /tmp/l0_test.img | tr -d ' ')
src_size=$(od -An -t u8 -j 40 -N 8 /tmp/l0_test.img | tr -d ' ')
if [ "$version" != "1" ] || [ "$hdr_size" != "80" ] || [ "$src_off" != "80" ] || [ "$src_size" != "$in_size" ]; then
  echo "FAIL: build header fields"
  exit 1
fi

if "$BIN" verify "$ROOT/tests/invalid_order.l0" >/tmp/l0_bad.out 2>/tmp/l0_bad.err; then
  echo "FAIL: invalid_order unexpectedly passed"
  exit 1
fi

echo "PASS"
