#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"

TMP_BASE="${TMPDIR:-/tmp}"
WORK_DIR="$(mktemp -d "$TMP_BASE/l0_m64_diff.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT

build_img() {
  local src="$1"
  local out="$2"
  local log="$3"
  "$BIN" build "$src" "$out" >"$log"
  if ! grep -q '^ok$' "$log"; then
    echo "FAIL: M64 build did not return ok for $(basename "$src")"
    exit 1
  fi
}

run_and_capture() {
  local img="$1"
  local out="$2"
  shift 2
  "$BIN" run "$img" "$@" >"$out"
}

# name|left_fixture|right_fixture|arity|profile
# profiles:
#   g2: general 2-arg arithmetic/bitwise/compare vectors
#   s2: shift-safe 2-arg vectors (second arg is shift count)
#   g1: general 1-arg vectors
#   g6: general 6-arg vectors
#   z0: zero-arg vectors
PAIRS=$(cat <<'PAIRS_EOF'
add.wrap.ids|tests/valid_add_v7.l0|tests/valid_add_argids_v7_v9_lowered.l0|2|g2
add.wrap.argdef|tests/valid_add_v7.l0|tests/valid_add_argdef_order_swapped_lowered.l0|2|g2
mul.wrap.call|tests/valid_mul.l0|tests/valid_call_mul_lowered.l0|2|g2
sub.wrap.call|tests/valid_sub.l0|tests/valid_call_sub_lowered.l0|2|g2
and.call|tests/valid_and.l0|tests/valid_call_and_lowered.l0|2|g2
or.call|tests/valid_or.l0|tests/valid_call_or_lowered.l0|2|g2
xor.call|tests/valid_xor.l0|tests/valid_call_xor_lowered.l0|2|g2
shl.call|tests/valid_shl.l0|tests/valid_call_shl_lowered.l0|2|s2
shr.call|tests/valid_shr.l0|tests/valid_call_shr_lowered.l0|2|s2
icmp.eq.deadconst|tests/valid_icmp_eq.l0|tests/valid_icmp_eq_with_dead_const_general_lowered.l0|2|g2
cbr.select.deadconst|tests/valid_cbr_eq_select.l0|tests/valid_cbr_eq_select_with_dead_const_general_lowered.l0|2|g2
mem.roundtrip.deadconst|tests/valid_mem_roundtrip.l0|tests/valid_mem_roundtrip_with_dead_const_general_lowered.l0|1|g1
mem.gep.roundtrip.deadconst|tests/valid_mem_gep_roundtrip.l0|tests/valid_mem_gep_roundtrip_with_dead_const_general_lowered.l0|1|g1
sysv.sum6.deadconst|tests/valid_sysv_abi_sum6_lowered.l0|tests/valid_sysv_abi_sum6_with_dead_const_general_lowered.l0|6|g6
const.deadconst|tests/valid_const_v123.l0|tests/valid_const_v123_with_dead_const_general_lowered.l0|0|z0
PAIRS_EOF
)

case_vectors() {
  local profile="$1"
  case "$profile" in
    g2)
      cat <<'EOF_V'
0 0
1 2
7 3
123456789 987654321
9223372036854775807 1
18446744073709551615 1
EOF_V
      ;;
    s2)
      cat <<'EOF_V'
0 0
1 0
1 1
1 7
8 2
123456 31
987654321 63
EOF_V
      ;;
    g1)
      cat <<'EOF_V'
0
1
42
99
9223372036854775807
18446744073709551615
EOF_V
      ;;
    g6)
      cat <<'EOF_V'
0 0 0 0 0 0
1 2 3 4 5 6
10 20 30 40 50 60
1000 2000 3000 4000 5000 6000
9223372036854775807 1 0 1 2 2
EOF_V
      ;;
    z0)
      cat <<'EOF_V'

EOF_V
      ;;
    *)
      echo "FAIL: M64 unknown vector profile '$profile'"
      exit 1
      ;;
  esac
}

pair_count=0
case_count=0
while IFS='|' read -r name left_rel right_rel arity profile; do
  [ -n "$name" ] || continue
  pair_count=$((pair_count + 1))

  left="$ROOT/$left_rel"
  right="$ROOT/$right_rel"

  left_img="$WORK_DIR/${name}_left.img"
  right_img="$WORK_DIR/${name}_right.img"

  build_img "$left" "$left_img" "$WORK_DIR/${name}_left_build.out"
  build_img "$right" "$right_img" "$WORK_DIR/${name}_right_build.out"

  this_case=0
  while IFS= read -r vector || [ -n "$vector" ]; do
    if [ "$arity" -eq 0 ]; then
      args=()
    else
      read -r -a args <<<"$vector"
      if [ "${#args[@]}" -ne "$arity" ]; then
        echo "FAIL: M64 bad vector arity in profile '$profile' for pair '$name'"
        exit 1
      fi
    fi

    run_and_capture "$left_img" "$WORK_DIR/${name}_left_run_${this_case}.out" "${args[@]}"
    run_and_capture "$right_img" "$WORK_DIR/${name}_right_run_${this_case}.out" "${args[@]}"

    if ! cmp -s "$WORK_DIR/${name}_left_run_${this_case}.out" "$WORK_DIR/${name}_right_run_${this_case}.out"; then
      echo "FAIL: M64 semantic mismatch for pair '$name' case #$this_case"
      echo " left:  $(cat "$WORK_DIR/${name}_left_run_${this_case}.out")"
      echo " right: $(cat "$WORK_DIR/${name}_right_run_${this_case}.out")"
      exit 1
    fi

    this_case=$((this_case + 1))
    case_count=$((case_count + 1))
  done < <(case_vectors "$profile")
done <<<"$PAIRS"

if [ "$pair_count" -lt 10 ]; then
  echo "FAIL: M64 differential corpus unexpectedly small"
  exit 1
fi
if [ "$case_count" -lt 60 ]; then
  echo "FAIL: M64 differential case corpus unexpectedly small"
  exit 1
fi

echo "ok"
