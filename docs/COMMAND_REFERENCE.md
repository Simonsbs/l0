# L0 Command Reference

I use this as my complete command-line reference for `l0c` in the current v1 toolchain.

## Command Model

I keep CLI behavior deterministic:
- success path prints stable text output (`ok`, metadata lines, or run result)
- failure path uses stable `usage: ...` or `error: ...` forms
- exit-code/error class stability is frozen in `docs/ERROR_MODEL.md`

## `canon`

Canonicalize a module and emit canonical source.

Forms:
- `./bin/l0c canon <module.l0>`
- `./bin/l0c canon <module.l0> -o <out.l0>`

Example:
```sh
./bin/l0c canon tests/valid_min.l0 -o /tmp/min.canon.l0
```

## `verify`

Parse and verify canonical module validity.

Form:
- `./bin/l0c verify <module.l0>`

Example:
```sh
./bin/l0c verify tests/valid_min.l0
```

## `build`

Build L0 source to L0 image, optionally emitting debug-map and trace-schema side artifacts.

Forms:
- `./bin/l0c build <module.l0> <out.l0img>`
- `./bin/l0c build <module.l0> -o <out.l0img>`
- `./bin/l0c build <module.l0> <out.l0img> --debug-map <out.map> --trace-schema <out.schema>`

Example:
```sh
./bin/l0c build tests/valid_trace_noop.l0 /tmp/trace.img \
  --debug-map /tmp/trace.map \
  --trace-schema /tmp/trace.schema
```

## `build-elf`

Build L0 source to ELF64 relocatable object output.

Form:
- `./bin/l0c build-elf <module.l0> <out.o>`

Example:
```sh
./bin/l0c build-elf tests/valid_sysv_abi_sum6_lowered.l0 /tmp/sum6.o
```

## `imgcheck`

Validate L0 image container integrity and schema constraints.

Form:
- `./bin/l0c imgcheck <file.l0img>`

Example:
```sh
./bin/l0c imgcheck /tmp/trace.img
```

## `imgmeta`

Print stable decoded metadata for a valid L0 image.

Form:
- `./bin/l0c imgmeta <file.l0img>`

Example:
```sh
./bin/l0c imgmeta /tmp/trace.img
```

## `run`

Execute code payload from L0 image and print returned `u64` value.

Form:
- `./bin/l0c run <file.l0img> [u64_a] [u64_b] [u64_c] [u64_d] [u64_e] [u64_f]`

Example:
```sh
./bin/l0c run /tmp/trace.img 123
```

## `tracecat`

Decode binary trace records into stable text output.

Form:
- `./bin/l0c tracecat <trace.bin>`

Example:
```sh
./bin/l0c tracecat /tmp/trace.bin
```

## `mapcat`

Decode debug-map payload into stable text output.

Form:
- `./bin/l0c mapcat <debug_map.bin>`

Example:
```sh
./bin/l0c mapcat /tmp/trace.map
```

## `schemacat`

Decode trace-schema payload into stable text output.

Form:
- `./bin/l0c schemacat <trace_schema.bin>`

Example:
```sh
./bin/l0c schemacat /tmp/trace.schema
```

## `tracejoin`

Join trace records against debug-map entries and print correlated output.

Form:
- `./bin/l0c tracejoin <trace.bin> <debug_map.bin>`

Example:
```sh
./bin/l0c tracejoin /tmp/trace.bin /tmp/trace.map
```

## Related References

- error model: `docs/ERROR_MODEL.md`
- workflows: `docs/WORKFLOWS.md`
- binary/trace schema contracts: `docs/DEBUG_MAP_SCHEMA.md`, `docs/TRACE_SCHEMA.md`
