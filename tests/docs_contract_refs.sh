#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"

contracts=(
  docs/INTRINSIC_CONTRACTS.md
  docs/DEBUG_MAP_SCHEMA.md
  docs/TRACE_SCHEMA.md
  docs/DETERMINISTIC_BUILDS.md
  docs/DIFFERENTIAL_TESTING.md
  docs/FUZZ_STRESS.md
  docs/PERFORMANCE_BASELINES.md
  docs/ERROR_MODEL.md
  docs/RELEASE_PIPELINE.md
  docs/COMPATIBILITY_POLICY.md
  docs/PRODUCTION_READINESS.md
)

check_files=(
  "$ROOT/docs/INDEX.md"
  "$ROOT/docs/SPEC.md"
  "$ROOT/docs/IMPLEMENTABLE_SPEC.md"
)

for f in "${check_files[@]}"; do
  if [ ! -f "$f" ]; then
    echo "FAIL: docs contract refs missing required file ${f#$ROOT/}"
    exit 1
  fi
done

for c in "${contracts[@]}"; do
  for f in "${check_files[@]}"; do
    if ! rg -F -q "$c" "$f"; then
      echo "FAIL: docs contract refs missing '$c' in ${f#$ROOT/}"
      exit 1
    fi
  done
  if ! rg -F -q "|$c" "$ROOT/wiki/SOURCE_MAP.tsv"; then
    echo "FAIL: docs contract refs missing wiki source map entry for $c"
    exit 1
  fi
done

echo "ok"
