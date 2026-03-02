#!/usr/bin/env bash
set -euo pipefail

as_out="$(as --version)"
ld_out="$(ld --version)"
make_out="$(make --version)"
as_line="${as_out%%$'\n'*}"
ld_line="${ld_out%%$'\n'*}"
make_line="${make_out%%$'\n'*}"

if ! echo "$as_line" | grep -q '^GNU assembler'; then
  echo "FAIL: toolchain policy requires GNU assembler"
  exit 1
fi
if ! echo "$ld_line" | grep -q '^GNU ld'; then
  echo "FAIL: toolchain policy requires GNU ld"
  exit 1
fi
if ! echo "$make_line" | grep -q '^GNU Make'; then
  echo "FAIL: toolchain policy requires GNU Make"
  exit 1
fi

ver_ge() {
  local got="$1"
  local min="$2"
  [ "$(printf '%s\n' "$min" "$got" | sort -V | head -n1)" = "$min" ]
}

as_ver="$(echo "$as_line" | grep -Eo '[0-9]+\.[0-9]+' | head -n1)"
ld_ver="$(echo "$ld_line" | grep -Eo '[0-9]+\.[0-9]+' | head -n1)"
make_ver="$(echo "$make_line" | grep -Eo '[0-9]+\.[0-9]+' | head -n1)"

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
