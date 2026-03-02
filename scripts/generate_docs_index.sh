#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/docs/LLM_DOC_INDEX.json}"

cat > "$OUT" <<'EOF'
{
  "schema_version": 1,
  "language": "L0",
  "release": "v1.0.0",
  "commands": [
    "canon", "verify", "build", "build-elf", "imgcheck", "imgmeta", "run",
    "tracecat", "mapcat", "schemacat", "tracejoin"
  ],
  "terminators": ["br", "cbr", "ret"],
  "ops": [
    "arg", "const", "add.wrap", "add.trap", "sub.wrap", "sub.trap",
    "mul.wrap", "mul.trap", "and", "or", "xor", "shl", "shr", "icmp.eq",
    "call", "alloca", "ld", "st", "gep", "malloc", "free", "write", "exit", "trace"
  ],
  "types": [
    "i1", "i8", "i16", "i32", "i64",
    "u8", "u16", "u32", "u64",
    "p0<i8>", "s{...}", "aN<t>", "fn(args...)->ret"
  ],
  "error_classes": [
    "parser", "verifier", "image", "trace", "debug-map", "contract", "compatibility"
  ],
  "source_refs": {
    "index": "docs/INDEX.md",
    "language": "docs/LANGUAGE.md",
    "grammar_typing": "docs/GRAMMAR_AND_TYPING.md",
    "instruction_set": "docs/INSTRUCTION_SET.md",
    "opcode_examples": "docs/OPCODE_EXAMPLES.md",
    "command_reference": "docs/COMMAND_REFERENCE.md",
    "command_cookbook": "docs/COMMAND_COOKBOOK.md",
    "examples_catalog": "docs/EXAMPLES_CATALOG.md",
    "intrinsic_contracts": "docs/INTRINSIC_CONTRACTS.md",
    "debug_map_schema": "docs/DEBUG_MAP_SCHEMA.md",
    "trace_schema": "docs/TRACE_SCHEMA.md",
    "error_model": "docs/ERROR_MODEL.md",
    "compatibility_policy": "docs/COMPATIBILITY_POLICY.md",
    "production_readiness": "docs/PRODUCTION_READINESS.md"
  }
}
EOF

echo "ok"
