#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"

# debugmap.v1 compatibility fixture A: one-entry map over code_size=7
printf '\x4c\x30\x44\x4d\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x00\x00\x00\x00' >/tmp/l0_m61_map_one.bin
"$BIN" mapcat /tmp/l0_m61_map_one.bin >/tmp/l0_m61_map_one.out
if [ "$(cat /tmp/l0_m61_map_one.out)" != $'entries 1\ncode_size 7\ninst_id 1\nstart 0\nend 7' ]; then
  echo "FAIL: M61 map fixture one decode"
  exit 1
fi
printf '\x01\x00\x00\x00\x00\x00\x00\x00\x2a\x00\x00\x00\x00\x00\x00\x00' >/tmp/l0_m61_trace_one.bin
"$BIN" tracejoin /tmp/l0_m61_trace_one.bin /tmp/l0_m61_map_one.bin >/tmp/l0_m61_tracejoin_one.out
if [ "$(cat /tmp/l0_m61_tracejoin_one.out)" != $'id 1\nval 42\nstart 0\nend 7' ]; then
  echo "FAIL: M61 tracejoin fixture one decode"
  exit 1
fi

# debugmap.v1 compatibility fixture B: two-entry map, stable decode and join per record order
printf '\x4c\x30\x44\x4d\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x00\x00\x00\x00' >/tmp/l0_m61_map_two.bin
"$BIN" mapcat /tmp/l0_m61_map_two.bin >/tmp/l0_m61_map_two.out
if [ "$(cat /tmp/l0_m61_map_two.out)" != $'entries 2\ncode_size 7\ninst_id 1\nstart 0\nend 3\ninst_id 2\nstart 3\nend 7' ]; then
  echo "FAIL: M61 map fixture two decode"
  exit 1
fi
# Decode determinism: same file, same output.
"$BIN" mapcat /tmp/l0_m61_map_two.bin >/tmp/l0_m61_map_two_second.out
if ! cmp -s /tmp/l0_m61_map_two.out /tmp/l0_m61_map_two_second.out; then
  echo "FAIL: M61 map fixture two non-deterministic decode"
  exit 1
fi
printf '\x02\x00\x00\x00\x00\x00\x00\x00\x09\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x05\x00\x00\x00\x00\x00\x00\x00' >/tmp/l0_m61_trace_two.bin
"$BIN" tracejoin /tmp/l0_m61_trace_two.bin /tmp/l0_m61_map_two.bin >/tmp/l0_m61_tracejoin_two.out
if [ "$(cat /tmp/l0_m61_tracejoin_two.out)" != $'id 2\nval 9\nstart 3\nend 7\nid 1\nval 5\nstart 0\nend 3' ]; then
  echo "FAIL: M61 tracejoin fixture two decode"
  exit 1
fi

# Strict tamper rejection freeze (mapcat + tracejoin)
cp /tmp/l0_m61_map_two.bin /tmp/l0_m61_bad_magic.bin
printf '\x58\x58\x58\x58' | dd of=/tmp/l0_m61_bad_magic.bin bs=1 seek=0 conv=notrunc status=none
if "$BIN" mapcat /tmp/l0_m61_bad_magic.bin >/tmp/l0_m61_bad_magic.out 2>/tmp/l0_m61_bad_magic.err; then
  echo "FAIL: M61 mapcat accepted bad debug-map magic"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_m61_trace_two.bin /tmp/l0_m61_bad_magic.bin >/tmp/l0_m61_bad_magic_tj.out 2>/tmp/l0_m61_bad_magic_tj.err; then
  echo "FAIL: M61 tracejoin accepted bad debug-map magic"
  exit 1
fi

cp /tmp/l0_m61_map_two.bin /tmp/l0_m61_bad_version.bin
printf '\x03\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_m61_bad_version.bin bs=1 seek=8 conv=notrunc status=none
if "$BIN" mapcat /tmp/l0_m61_bad_version.bin >/tmp/l0_m61_bad_version.out 2>/tmp/l0_m61_bad_version.err; then
  echo "FAIL: M61 mapcat accepted bad debug-map version"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_m61_trace_two.bin /tmp/l0_m61_bad_version.bin >/tmp/l0_m61_bad_version_tj.out 2>/tmp/l0_m61_bad_version_tj.err; then
  echo "FAIL: M61 tracejoin accepted bad debug-map version"
  exit 1
fi

cp /tmp/l0_m61_map_two.bin /tmp/l0_m61_bad_count.bin
printf '\x03\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_m61_bad_count.bin bs=1 seek=16 conv=notrunc status=none
if "$BIN" mapcat /tmp/l0_m61_bad_count.bin >/tmp/l0_m61_bad_count.out 2>/tmp/l0_m61_bad_count.err; then
  echo "FAIL: M61 mapcat accepted mismatched entry_count"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_m61_trace_two.bin /tmp/l0_m61_bad_count.bin >/tmp/l0_m61_bad_count_tj.out 2>/tmp/l0_m61_bad_count_tj.err; then
  echo "FAIL: M61 tracejoin accepted mismatched entry_count"
  exit 1
fi

cp /tmp/l0_m61_map_two.bin /tmp/l0_m61_bad_inst_order.bin
printf '\x02\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_m61_bad_inst_order.bin bs=1 seek=32 conv=notrunc status=none
if "$BIN" mapcat /tmp/l0_m61_bad_inst_order.bin >/tmp/l0_m61_bad_inst_order.out 2>/tmp/l0_m61_bad_inst_order.err; then
  echo "FAIL: M61 mapcat accepted non-increasing inst_id order"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_m61_trace_two.bin /tmp/l0_m61_bad_inst_order.bin >/tmp/l0_m61_bad_inst_order_tj.out 2>/tmp/l0_m61_bad_inst_order_tj.err; then
  echo "FAIL: M61 tracejoin accepted non-increasing inst_id order"
  exit 1
fi

cp /tmp/l0_m61_map_two.bin /tmp/l0_m61_bad_overlap.bin
printf '\x02\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_m61_bad_overlap.bin bs=1 seek=64 conv=notrunc status=none
if "$BIN" mapcat /tmp/l0_m61_bad_overlap.bin >/tmp/l0_m61_bad_overlap.out 2>/tmp/l0_m61_bad_overlap.err; then
  echo "FAIL: M61 mapcat accepted overlapping ranges"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_m61_trace_two.bin /tmp/l0_m61_bad_overlap.bin >/tmp/l0_m61_bad_overlap_tj.out 2>/tmp/l0_m61_bad_overlap_tj.err; then
  echo "FAIL: M61 tracejoin accepted overlapping ranges"
  exit 1
fi

echo "ok"
