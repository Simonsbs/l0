#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"

# traceschema.v1 compatibility fixture: 32-byte L0TS schema payload.
printf '\x4c\x30\x54\x53\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x10\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00' >/tmp/l0_m62_schema_v1.bin
"$BIN" schemacat /tmp/l0_m62_schema_v1.bin >/tmp/l0_m62_schemacat_v1.out
if [ "$(cat /tmp/l0_m62_schemacat_v1.out)" != $'version 1\nrecord_size 16\nfields 2' ]; then
  echo "FAIL: M62 schemacat v1 decode"
  exit 1
fi
# Deterministic decode check.
"$BIN" schemacat /tmp/l0_m62_schema_v1.bin >/tmp/l0_m62_schemacat_v1_second.out
if ! cmp -s /tmp/l0_m62_schemacat_v1.out /tmp/l0_m62_schemacat_v1_second.out; then
  echo "FAIL: M62 schemacat non-deterministic output"
  exit 1
fi

# tracecat compatibility fixtures (fixed 16-byte records, decode order preserved).
printf '\x01\x00\x00\x00\x00\x00\x00\x00\x2a\x00\x00\x00\x00\x00\x00\x00' >/tmp/l0_m62_trace_one.bin
"$BIN" tracecat /tmp/l0_m62_trace_one.bin >/tmp/l0_m62_tracecat_one.out
if [ "$(cat /tmp/l0_m62_tracecat_one.out)" != $'id 1\nval 42' ]; then
  echo "FAIL: M62 tracecat one-record decode"
  exit 1
fi
printf '\x02\x00\x00\x00\x00\x00\x00\x00\x09\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x05\x00\x00\x00\x00\x00\x00\x00' >/tmp/l0_m62_trace_two.bin
"$BIN" tracecat /tmp/l0_m62_trace_two.bin >/tmp/l0_m62_tracecat_two.out
if [ "$(cat /tmp/l0_m62_tracecat_two.out)" != $'id 2\nval 9\nid 1\nval 5' ]; then
  echo "FAIL: M62 tracecat two-record decode"
  exit 1
fi
# Empty trace payload is valid and emits no output.
: >/tmp/l0_m62_trace_empty.bin
"$BIN" tracecat /tmp/l0_m62_trace_empty.bin >/tmp/l0_m62_tracecat_empty.out
if [ -s /tmp/l0_m62_tracecat_empty.out ]; then
  echo "FAIL: M62 tracecat empty payload output"
  exit 1
fi

# tracejoin compatibility using a fixed two-entry debug-map fixture.
printf '\x4c\x30\x44\x4d\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00\x03\x00\x00\x00\x00\x00\x00\x00\x07\x00\x00\x00\x00\x00\x00\x00' >/tmp/l0_m62_map_two.bin
"$BIN" tracejoin /tmp/l0_m62_trace_two.bin /tmp/l0_m62_map_two.bin >/tmp/l0_m62_tracejoin_two.out
if [ "$(cat /tmp/l0_m62_tracejoin_two.out)" != $'id 2\nval 9\nstart 3\nend 7\nid 1\nval 5\nstart 0\nend 3' ]; then
  echo "FAIL: M62 tracejoin two-record decode"
  exit 1
fi
"$BIN" tracejoin /tmp/l0_m62_trace_empty.bin /tmp/l0_m62_map_two.bin >/tmp/l0_m62_tracejoin_empty.out
if [ -s /tmp/l0_m62_tracejoin_empty.out ]; then
  echo "FAIL: M62 tracejoin empty payload output"
  exit 1
fi

# Tamper rejection matrix for traceschema.v1 and trace-record decoding.
cp /tmp/l0_m62_schema_v1.bin /tmp/l0_m62_schema_bad_magic.bin
printf '\x58\x58\x58\x58' | dd of=/tmp/l0_m62_schema_bad_magic.bin bs=1 seek=0 conv=notrunc status=none
if "$BIN" schemacat /tmp/l0_m62_schema_bad_magic.bin >/tmp/l0_m62_schema_bad_magic.out 2>/tmp/l0_m62_schema_bad_magic.err; then
  echo "FAIL: M62 schemacat accepted bad schema magic"
  exit 1
fi

cp /tmp/l0_m62_schema_v1.bin /tmp/l0_m62_schema_bad_version.bin
printf '\x02\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_m62_schema_bad_version.bin bs=1 seek=8 conv=notrunc status=none
if "$BIN" schemacat /tmp/l0_m62_schema_bad_version.bin >/tmp/l0_m62_schema_bad_version.out 2>/tmp/l0_m62_schema_bad_version.err; then
  echo "FAIL: M62 schemacat accepted bad schema version"
  exit 1
fi

cp /tmp/l0_m62_schema_v1.bin /tmp/l0_m62_schema_bad_recsize.bin
printf '\x08\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_m62_schema_bad_recsize.bin bs=1 seek=16 conv=notrunc status=none
if "$BIN" schemacat /tmp/l0_m62_schema_bad_recsize.bin >/tmp/l0_m62_schema_bad_recsize.out 2>/tmp/l0_m62_schema_bad_recsize.err; then
  echo "FAIL: M62 schemacat accepted bad record_size"
  exit 1
fi

cp /tmp/l0_m62_schema_v1.bin /tmp/l0_m62_schema_bad_fields.bin
printf '\x03\x00\x00\x00\x00\x00\x00\x00' | dd of=/tmp/l0_m62_schema_bad_fields.bin bs=1 seek=24 conv=notrunc status=none
if "$BIN" schemacat /tmp/l0_m62_schema_bad_fields.bin >/tmp/l0_m62_schema_bad_fields.out 2>/tmp/l0_m62_schema_bad_fields.err; then
  echo "FAIL: M62 schemacat accepted bad field_count"
  exit 1
fi

head -c 24 /tmp/l0_m62_schema_v1.bin >/tmp/l0_m62_schema_truncated.bin
if "$BIN" schemacat /tmp/l0_m62_schema_truncated.bin >/tmp/l0_m62_schema_truncated.out 2>/tmp/l0_m62_schema_truncated.err; then
  echo "FAIL: M62 schemacat accepted truncated schema payload"
  exit 1
fi

cp /tmp/l0_m62_trace_two.bin /tmp/l0_m62_trace_truncated.bin
printf '\x00' >> /tmp/l0_m62_trace_truncated.bin
if "$BIN" tracecat /tmp/l0_m62_trace_truncated.bin >/tmp/l0_m62_trace_truncated.out 2>/tmp/l0_m62_trace_truncated.err; then
  echo "FAIL: M62 tracecat accepted non-16-byte-aligned payload"
  exit 1
fi
if "$BIN" tracejoin /tmp/l0_m62_trace_truncated.bin /tmp/l0_m62_map_two.bin >/tmp/l0_m62_tracejoin_truncated.out 2>/tmp/l0_m62_tracejoin_truncated.err; then
  echo "FAIL: M62 tracejoin accepted non-16-byte-aligned payload"
  exit 1
fi

printf '\x09\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00' >/tmp/l0_m62_trace_unknown_id.bin
if "$BIN" tracejoin /tmp/l0_m62_trace_unknown_id.bin /tmp/l0_m62_map_two.bin >/tmp/l0_m62_trace_unknown_id.out 2>/tmp/l0_m62_trace_unknown_id.err; then
  echo "FAIL: M62 tracejoin accepted unknown trace id"
  exit 1
fi

echo "ok"
