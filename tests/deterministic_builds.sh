#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"

# Fixture A: minimal image build must be byte-for-byte deterministic.
"$BIN" build "$ROOT/tests/valid_min.l0" /tmp/l0_m63_min_a.img >/tmp/l0_m63_min_a.out
"$BIN" build "$ROOT/tests/valid_min.l0" /tmp/l0_m63_min_b.img >/tmp/l0_m63_min_b.out
if ! grep -q '^ok$' /tmp/l0_m63_min_a.out || ! grep -q '^ok$' /tmp/l0_m63_min_b.out; then
  echo "FAIL: M63 valid_min build did not return ok"
  exit 1
fi
if ! cmp -s /tmp/l0_m63_min_a.img /tmp/l0_m63_min_b.img; then
  echo "FAIL: M63 valid_min image build is not deterministic"
  exit 1
fi

# Fixture B: image + debug-map + trace-schema must all be byte-for-byte deterministic.
"$BIN" build "$ROOT/tests/valid_trace_noop.l0" /tmp/l0_m63_trace_a.img --debug-map /tmp/l0_m63_trace_a.map --trace-schema /tmp/l0_m63_trace_a.schema >/tmp/l0_m63_trace_a.out
"$BIN" build "$ROOT/tests/valid_trace_noop.l0" /tmp/l0_m63_trace_b.img --debug-map /tmp/l0_m63_trace_b.map --trace-schema /tmp/l0_m63_trace_b.schema >/tmp/l0_m63_trace_b.out
if ! grep -q '^ok$' /tmp/l0_m63_trace_a.out || ! grep -q '^ok$' /tmp/l0_m63_trace_b.out; then
  echo "FAIL: M63 valid_trace_noop build did not return ok"
  exit 1
fi
if ! cmp -s /tmp/l0_m63_trace_a.img /tmp/l0_m63_trace_b.img; then
  echo "FAIL: M63 trace image build is not deterministic"
  exit 1
fi
if ! cmp -s /tmp/l0_m63_trace_a.map /tmp/l0_m63_trace_b.map; then
  echo "FAIL: M63 debug-map build is not deterministic"
  exit 1
fi
if ! cmp -s /tmp/l0_m63_trace_a.schema /tmp/l0_m63_trace_b.schema; then
  echo "FAIL: M63 trace-schema build is not deterministic"
  exit 1
fi

# Decode-level determinism: repeated decode output is identical for same artifact.
"$BIN" imgmeta /tmp/l0_m63_trace_a.img >/tmp/l0_m63_trace_imgmeta_1.out
"$BIN" imgmeta /tmp/l0_m63_trace_a.img >/tmp/l0_m63_trace_imgmeta_2.out
if ! cmp -s /tmp/l0_m63_trace_imgmeta_1.out /tmp/l0_m63_trace_imgmeta_2.out; then
  echo "FAIL: M63 imgmeta output is not deterministic"
  exit 1
fi
"$BIN" mapcat /tmp/l0_m63_trace_a.map >/tmp/l0_m63_trace_mapcat_1.out
"$BIN" mapcat /tmp/l0_m63_trace_a.map >/tmp/l0_m63_trace_mapcat_2.out
if ! cmp -s /tmp/l0_m63_trace_mapcat_1.out /tmp/l0_m63_trace_mapcat_2.out; then
  echo "FAIL: M63 mapcat output is not deterministic"
  exit 1
fi
"$BIN" schemacat /tmp/l0_m63_trace_a.schema >/tmp/l0_m63_trace_schemacat_1.out
"$BIN" schemacat /tmp/l0_m63_trace_a.schema >/tmp/l0_m63_trace_schemacat_2.out
if ! cmp -s /tmp/l0_m63_trace_schemacat_1.out /tmp/l0_m63_trace_schemacat_2.out; then
  echo "FAIL: M63 schemacat output is not deterministic"
  exit 1
fi

# Fixture C: non-trivial generalized lowering image determinism.
"$BIN" build "$ROOT/tests/valid_spill_stress_lowered.l0" /tmp/l0_m63_spill_a.img >/tmp/l0_m63_spill_a.out
"$BIN" build "$ROOT/tests/valid_spill_stress_lowered.l0" /tmp/l0_m63_spill_b.img >/tmp/l0_m63_spill_b.out
if ! grep -q '^ok$' /tmp/l0_m63_spill_a.out || ! grep -q '^ok$' /tmp/l0_m63_spill_b.out; then
  echo "FAIL: M63 spill stress build did not return ok"
  exit 1
fi
if ! cmp -s /tmp/l0_m63_spill_a.img /tmp/l0_m63_spill_b.img; then
  echo "FAIL: M63 spill stress image build is not deterministic"
  exit 1
fi

# Fixture D: ELF object build determinism.
"$BIN" build-elf "$ROOT/tests/valid_sysv_abi_sum6_lowered.l0" /tmp/l0_m63_sum6_a.o >/tmp/l0_m63_sum6_a.out
"$BIN" build-elf "$ROOT/tests/valid_sysv_abi_sum6_lowered.l0" /tmp/l0_m63_sum6_b.o >/tmp/l0_m63_sum6_b.out
if ! grep -q '^ok$' /tmp/l0_m63_sum6_a.out || ! grep -q '^ok$' /tmp/l0_m63_sum6_b.out; then
  echo "FAIL: M63 sum6 build-elf did not return ok"
  exit 1
fi
if ! cmp -s /tmp/l0_m63_sum6_a.o /tmp/l0_m63_sum6_b.o; then
  echo "FAIL: M63 ELF object build is not deterministic"
  exit 1
fi

echo "ok"
