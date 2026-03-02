# L0 Documentation Coverage Matrix

I use this matrix to ensure every major language ability and CLI command is documented, exemplified, and test-gated.

## Command Coverage

| Command | Reference | Success Example | Failure Example | Test/Gate |
|---|---|---|---|---|
| `canon` | `docs/COMMAND_REFERENCE.md` | `tests/valid_min.l0` | `tests/invalid_order.l0` | `tests/run.sh` |
| `verify` | `docs/COMMAND_REFERENCE.md` | `docs/examples/*.l0` | `tests/invalid_*.l0` | `tests/run.sh` + `tests/verifier_matrix.sh` |
| `build` | `docs/COMMAND_REFERENCE.md` | `docs/examples/01_arithmetic_add_wrap.l0` | missing input path | `tests/run.sh` |
| `build-elf` | `docs/COMMAND_REFERENCE.md` | `docs/examples/18_sysv_abi_sum6_kernel.l0` | missing input path | `tests/run.sh` + `tests/compatibility_matrix.sh` |
| `imgcheck` | `docs/COMMAND_REFERENCE.md` | built images | corrupt image payload | `tests/run.sh` |
| `imgmeta` | `docs/COMMAND_REFERENCE.md` | built images | corrupt image payload | `tests/run.sh` |
| `run` | `docs/COMMAND_REFERENCE.md` | multiple examples | bad run arg | `tests/run.sh` + `tests/error_model.sh` |
| `tracecat` | `docs/COMMAND_REFERENCE.md` | trace workflow | truncated trace payload | `tests/run.sh` + `tests/trace_schema_contracts.sh` |
| `mapcat` | `docs/COMMAND_REFERENCE.md` | trace workflow | bad debug-map magic | `tests/run.sh` + `tests/debug_map_schema.sh` |
| `schemacat` | `docs/COMMAND_REFERENCE.md` | trace workflow | bad schema magic | `tests/run.sh` + `tests/trace_schema_contracts.sh` |
| `tracejoin` | `docs/COMMAND_REFERENCE.md` | trace workflow | unknown trace id / missing files | `tests/run.sh` + `tests/trace_schema_contracts.sh` |

## Opcode Coverage

| Opcode | Reference | Example Fixture | Test/Gate |
|---|---|---|---|
| `arg` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_min.l0` | `tests/verifier_matrix.sh` |
| `const` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_const.l0` | `tests/run.sh` |
| `add.wrap` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_add_v7.l0` | `tests/run.sh` + `tests/differential_semantics.sh` |
| `add.trap` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_add_trap.l0` | `tests/run.sh` |
| `sub.wrap` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_sub.l0` | `tests/run.sh` + `tests/differential_semantics.sh` |
| `sub.trap` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_sub_trap.l0` | `tests/run.sh` |
| `mul.wrap` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_mul.l0` | `tests/run.sh` + `tests/differential_semantics.sh` |
| `mul.trap` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_mul_trap.l0` | `tests/run.sh` |
| `and` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_and.l0` | `tests/run.sh` + `tests/differential_semantics.sh` |
| `or` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_or.l0` | `tests/run.sh` + `tests/differential_semantics.sh` |
| `xor` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_xor.l0` | `tests/run.sh` + `tests/differential_semantics.sh` |
| `shl` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_shl.l0` | `tests/run.sh` + `tests/differential_semantics.sh` |
| `shr` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_shr.l0` | `tests/run.sh` + `tests/differential_semantics.sh` |
| `icmp.eq` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_icmp_eq.l0` | `tests/run.sh` + `tests/differential_semantics.sh` |
| `call` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_call_add_lowered.l0` | `tests/run.sh` |
| `alloca` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_mem_roundtrip.l0` | `tests/run.sh` |
| `ld` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_mem_roundtrip.l0` | `tests/run.sh` |
| `gep` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_mem_gep_roundtrip.l0` | `tests/run.sh` |
| `malloc` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` + `docs/INTRINSIC_CONTRACTS.md` | `tests/valid_malloc.l0` | `tests/intrinsic_contracts.sh` |
| `st` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_mem_roundtrip.l0` | `tests/run.sh` |
| `free` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` + `docs/INTRINSIC_CONTRACTS.md` | `tests/valid_free_noop.l0` | `tests/intrinsic_contracts.sh` |
| `write` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` + `docs/INTRINSIC_CONTRACTS.md` | `tests/valid_write_newline.l0` | `tests/intrinsic_contracts.sh` |
| `exit` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` + `docs/INTRINSIC_CONTRACTS.md` | `tests/valid_exit.l0` | `tests/intrinsic_contracts.sh` |
| `trace` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` + `docs/INTRINSIC_CONTRACTS.md` | `tests/valid_trace_noop.l0` | `tests/intrinsic_contracts.sh` |
| `br` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_branch.l0` | `tests/run.sh` |
| `cbr` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | `tests/valid_cbr_eq_select.l0` | `tests/run.sh` |
| `ret` | `docs/INSTRUCTION_SET.md` + `docs/OPCODE_EXAMPLES.md` | all valid fixtures | `tests/run.sh` |

## Type Coverage

| Type Family | Reference | Example | Gate |
|---|---|---|---|
| integers (`i*`,`u*`) | `docs/LANGUAGE.md` + `docs/GRAMMAR_AND_TYPING.md` | `docs/examples/01_arithmetic_add_wrap.l0` | `tests/verifier_matrix.sh` |
| pointer (`p0<i8>`) | `docs/LANGUAGE.md` + `docs/GRAMMAR_AND_TYPING.md` | `docs/examples/04_memory_roundtrip.l0` | `tests/verifier_matrix.sh` |
| struct (`s{...}`) | `docs/LANGUAGE.md` + `docs/GRAMMAR_AND_TYPING.md` | `docs/examples/12_types_struct_sig.l0` | `tests/verifier_matrix.sh` |
| fixed array (`aN<t>`) | `docs/LANGUAGE.md` + `docs/GRAMMAR_AND_TYPING.md` | `docs/examples/13_types_array_sig.l0` | `tests/verifier_matrix.sh` |
| function type (`fn(...)->...`) | `docs/LANGUAGE.md` + `docs/GRAMMAR_AND_TYPING.md` | `docs/examples/14_types_fn_sig.l0` | `tests/verifier_matrix.sh` |

## Error-Class Coverage

| Error Class | Reference | Representative Trigger | Gate |
|---|---|---|---|
| `usage: ...` | `docs/ERROR_MODEL.md` | no args / bad command | `tests/error_model.sh` |
| `error: cannot open input` | `docs/ERROR_MODEL.md` | missing file | `tests/error_model.sh` |
| `error: cannot read input` | `docs/ERROR_MODEL.md` | directory input to `verify` | `tests/error_model.sh` |
| `error: invalid module shape or non-canonical input` | `docs/ERROR_MODEL.md` | invalid parser/verifier/decode payload | `tests/error_model.sh` |
| `error: cannot write output image` | `docs/ERROR_MODEL.md` | build to denied path | `tests/error_model.sh` |
| `error: invalid or corrupt L0IMG` | `docs/ERROR_MODEL.md` | corrupt image to `imgcheck`/`run` | `tests/error_model.sh` |
| `error: invalid run argument (expected unsigned decimal)` | `docs/ERROR_MODEL.md` | non-decimal run argument | `tests/error_model.sh` |

## LLM Prompting Coverage

| Capability | Reference | Gate |
|---|---|---|
| deterministic prompt templates for generation/debug/minimization | `docs/LLM_PROMPT_PACK.md` | `tests/docs_coverage.sh` |
| deterministic machine-readable doc index for tool consumption | `docs/LLM_DOC_INDEX.json` + `docs/LLM_DOC_INDEX.md` | `tests/docs_index.sh` |

## Coverage Gates

I enforce documentation integrity with:
- `tests/wiki_sync.sh`
- `tests/docs_coverage.sh`
- `tests/docs_links.sh`
- `tests/docs_headings.sh`
- `tests/docs_index.sh`
- `tests/docs_snapshot.sh`

## Operations and Governance Coverage

| Capability | Reference | Gate |
|---|---|---|
| security disclosure and supported-version policy | `SECURITY.md` | process policy + CI/full test discipline |
| merge and branch-protection governance | `docs/GOVERNANCE.md` | `.github/workflows/ci.yml` + `.github/CODEOWNERS` |
| pinned toolchain policy | `docs/TOOLCHAIN_POLICY.md` | `tests/toolchain_policy.sh` |
| CI smoke performance regression gate | `docs/PERFORMANCE_BASELINES.md` | `tests/ci_smoke_bench.sh` |
| nightly/tag full performance regression gate | `docs/PERFORMANCE_BASELINES.md` | `.github/workflows/performance.yml` + `tests/performance_gates.sh` |
| local comparison snapshot vs host compiler(s) | `docs/PERFORMANCE_COMPARISON.md` | `tests/benchmark_compare.sh` |
| apples-to-apples function/harness comparison snapshot | `docs/PERFORMANCE_COMPARISON_APPLES_TO_APPLES.md` | `tests/benchmark_apples_to_apples.sh` |
| stable release notes and changelog maintenance | `docs/RELEASE_NOTES_v1.0.0.md` + `CHANGELOG.md` | release workflow discipline |

## Contract Gate Mapping

- runtime intrinsic contracts: `tests/intrinsic_contracts.sh`
- deterministic build contracts: `tests/deterministic_builds.sh`
- error model contracts: `tests/error_model.sh`
- release pipeline contracts: `tests/release_pipeline.sh`
- compatibility contracts: `tests/compatibility_matrix.sh`
- production readiness contracts: `tests/production_readiness.sh`
- verifier rule matrix: `tests/verifier_matrix.sh`
- toolchain baseline policy: `tests/toolchain_policy.sh`
- CI smoke benchmark baseline: `tests/ci_smoke_bench.sh`
- comparative benchmark snapshot: `tests/benchmark_compare.sh`
- apples-to-apples benchmark snapshot: `tests/benchmark_apples_to_apples.sh`

These are wired into `tests/run.sh` and therefore enforced by `make test`.
