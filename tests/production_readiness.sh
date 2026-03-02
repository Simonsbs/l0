#!/usr/bin/env bash
set -euo pipefail

BIN="${1:-./bin/l0c}"
ROOT="${2:-$(cd "$(dirname "$0")/.." && pwd)}"

ensure_gate_ok() {
  local path="$1"
  local label="$2"
  shift 2
  if [ ! -f "$path" ]; then
    "$@" >"$path"
  fi
  if ! grep -q '^ok$' "$path"; then
    echo "FAIL: M70 prerequisite gate not ok for $label"
    exit 1
  fi
}

# M52-M69 gate outputs from current run.sh execution.
ensure_gate_ok /tmp/l0_m52_parser_fuzz.out M52 bash "$ROOT/tests/parser_fuzz_regress.sh" "$BIN" "$ROOT/tests/fuzz/parser_seeds"
ensure_gate_ok /tmp/l0_m53_verifier_matrix.out M53 bash "$ROOT/tests/verifier_matrix.sh" "$BIN" "$ROOT/tests/verifier_matrix.tsv"
ensure_gate_ok /tmp/l0_m60_intrinsic_contracts.out M60 bash "$ROOT/tests/intrinsic_contracts.sh" "$BIN" "$ROOT"
ensure_gate_ok /tmp/l0_m61_debug_map_schema.out M61 bash "$ROOT/tests/debug_map_schema.sh" "$BIN"
ensure_gate_ok /tmp/l0_m62_trace_schema_contracts.out M62 bash "$ROOT/tests/trace_schema_contracts.sh" "$BIN"
ensure_gate_ok /tmp/l0_m63_deterministic_builds.out M63 bash "$ROOT/tests/deterministic_builds.sh" "$BIN" "$ROOT"
ensure_gate_ok /tmp/l0_m64_differential_semantics.out M64 bash "$ROOT/tests/differential_semantics.sh" "$BIN" "$ROOT"
ensure_gate_ok /tmp/l0_m65_fuzz_stress.out M65 bash "$ROOT/tests/m65_fuzz_stress.sh" "$BIN" "$ROOT"
ensure_gate_ok /tmp/l0_m66_performance_gates.out M66 bash "$ROOT/tests/performance_gates.sh" "$BIN" "$ROOT"
ensure_gate_ok /tmp/l0_m67_error_model.out M67 bash "$ROOT/tests/error_model.sh" "$BIN" "$ROOT"
ensure_gate_ok /tmp/l0_m68_release_pipeline.out M68 bash "$ROOT/tests/release_pipeline.sh" "$BIN" "$ROOT"
ensure_gate_ok /tmp/l0_m69_compatibility_matrix.out M69 bash "$ROOT/tests/compatibility_matrix.sh" "$BIN" "$ROOT"

# Representative milestone slices for M54-M59 are asserted in run.sh; verify those checkpoints are present and green.
if [ ! -f /tmp/l0_ok_types_struct_sig.out ]; then
  "$BIN" verify "$ROOT/tests/valid_types_struct_sig.l0" >/tmp/l0_ok_types_struct_sig.out
fi
if [ ! -f /tmp/l0_ok_branch_const_select_lowered.out ]; then
  "$BIN" verify "$ROOT/tests/valid_branch_const_select_lowered.l0" >/tmp/l0_ok_branch_const_select_lowered.out
fi
if [ ! -f /tmp/l0_ok_merge_mem_select_lowered.out ]; then
  "$BIN" verify "$ROOT/tests/valid_merge_mem_select_lowered.l0" >/tmp/l0_ok_merge_mem_select_lowered.out
fi
if [ ! -f /tmp/l0_ok_spill_stress_lowered.out ]; then
  "$BIN" verify "$ROOT/tests/valid_spill_stress_lowered.l0" >/tmp/l0_ok_spill_stress_lowered.out
fi
if [ ! -f /tmp/l0_ok_sysv_abi_sum6_lowered.out ]; then
  "$BIN" verify "$ROOT/tests/valid_sysv_abi_sum6_lowered.l0" >/tmp/l0_ok_sysv_abi_sum6_lowered.out
fi
if [ ! -f /tmp/l0_buildelf_sysv_abi_sum6.out ]; then
  "$BIN" build-elf "$ROOT/tests/valid_sysv_abi_sum6_lowered.l0" /tmp/l0_m70_tmp_sum6.o >/tmp/l0_buildelf_sysv_abi_sum6.out
fi
if ! grep -q '^ok$' /tmp/l0_ok_types_struct_sig.out; then
  echo "FAIL: M70 representative M54 checkpoint failed"
  exit 1
fi
if ! grep -q '^ok$' /tmp/l0_ok_branch_const_select_lowered.out; then
  echo "FAIL: M70 representative M55 checkpoint failed"
  exit 1
fi
if ! grep -q '^ok$' /tmp/l0_ok_merge_mem_select_lowered.out; then
  echo "FAIL: M70 representative M56 checkpoint failed"
  exit 1
fi
if ! grep -q '^ok$' /tmp/l0_ok_spill_stress_lowered.out; then
  echo "FAIL: M70 representative M57 checkpoint failed"
  exit 1
fi
if ! grep -q '^ok$' /tmp/l0_ok_sysv_abi_sum6_lowered.out; then
  echo "FAIL: M70 representative M58 checkpoint failed"
  exit 1
fi
if ! grep -q '^ok$' /tmp/l0_buildelf_sysv_abi_sum6.out; then
  echo "FAIL: M70 representative M59 checkpoint failed"
  exit 1
fi

# Ensure all frozen v1 contract docs are present.
for doc in \
  docs/INTRINSIC_CONTRACTS.md \
  docs/DEBUG_MAP_SCHEMA.md \
  docs/TRACE_SCHEMA.md \
  docs/DETERMINISTIC_BUILDS.md \
  docs/DIFFERENTIAL_TESTING.md \
  docs/FUZZ_STRESS.md \
  docs/PERFORMANCE_BASELINES.md \
  docs/ERROR_MODEL.md \
  docs/RELEASE_PIPELINE.md \
  docs/COMPATIBILITY_POLICY.md \
  docs/PRODUCTION_READINESS.md; do
  if [ ! -f "$ROOT/$doc" ]; then
    echo "FAIL: M70 missing contract doc $doc"
    exit 1
  fi
done

# Final release-candidate smoke via packaging pipeline.
REL_OUT="$(mktemp -d "${TMPDIR:-/tmp}/l0_m70_rc.XXXXXX")"
trap 'rm -rf "$REL_OUT"' EXIT
VERSION="1.0.0-rc1"
PKG="l0-${VERSION}-linux-x86_64"

"$ROOT/scripts/release_candidate.sh" "$BIN" "$ROOT" "$REL_OUT" "$VERSION" >"$REL_OUT/release.out"
if ! grep -q '^ok$' "$REL_OUT/release.out"; then
  echo "FAIL: M70 release candidate pipeline did not report ok"
  exit 1
fi
for p in \
  "$REL_OUT/${PKG}.tar.gz" \
  "$REL_OUT/${PKG}.tar.gz.sha256" \
  "$REL_OUT/${PKG}.l0c.sha256" \
  "$REL_OUT/${PKG}.manifest.sha256" \
  "$REL_OUT/${PKG}.sha256"; do
  if [ ! -f "$p" ]; then
    echo "FAIL: M70 missing release-candidate artifact $(basename "$p")"
    exit 1
  fi
done
(
  cd "$REL_OUT"
  sha256sum -c "${PKG}.tar.gz.sha256" >/dev/null
  sha256sum -c "${PKG}.l0c.sha256" >/dev/null
  sha256sum -c "${PKG}.manifest.sha256" >/dev/null
)

echo "ok"
