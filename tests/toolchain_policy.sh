#!/usr/bin/env bash
set -euo pipefail

as_line="$(as --version | head -n 1)"
ld_line="$(ld --version | head -n 1)"
make_line="$(make --version | head -n 1)"

if ! echo "$as_line" | rg -q '^GNU assembler'; then
  echo "FAIL: toolchain policy requires GNU assembler"
  exit 1
fi
if ! echo "$ld_line" | rg -q '^GNU ld'; then
  echo "FAIL: toolchain policy requires GNU ld"
  exit 1
fi
if ! echo "$make_line" | rg -q '^GNU Make'; then
  echo "FAIL: toolchain policy requires GNU Make"
  exit 1
fi

ver_ge() {
  local got="$1"
  local min="$2"
  [ "$(printf '%s\n' "$min" "$got" | sort -V | head -n1)" = "$min" ]
}

as_ver="$(echo "$as_line" | rg -o '[0-9]+\.[0-9]+' | head -n1)"
ld_ver="$(echo "$ld_line" | rg -o '[0-9]+\.[0-9]+' | head -n1)"
make_ver="$(echo "$make_line" | rg -o '[0-9]+\.[0-9]+' | head -n1)"

if ! ver_ge "$as_ver" "2.40"; then
  echo "FAIL: GNU assembler too old ($as_ver < 2.40)"
  exit 1
fi
if ! ver_ge "$ld_ver" "2.40"; then
  echo "FAIL: GNU ld too old ($ld_ver < 2.40)"
  exit 1
fi
if ! ver_ge "$make_ver" "4.3"; then
  echo "FAIL: GNU Make too old ($make_ver < 4.3)"
  exit 1
fi

echo "ok"
