# L0 MVP Spec (Initial Freeze)

I use this as the first frozen subset for implementation.

For language-level reference, also see `docs/LANGUAGE.md`.

## Module shape (strict)

Exact section order is mandatory:
1. `ver`
2. `types`
3. `consts`
4. `extern`
5. `globals`
6. `fns`

## Current parser subset

In the bootstrap phase, I currently validate module-level section order and required braces/newlines.
I now also validate a canonical bootstrap `types` table shape:
- empty: `types { }`
- non-empty: `types { t0=<tok>, t1=<tok>, ... }` with contiguous ids
- bootstrap `<tok>` currently allowed set:
  - `i1`, `i8`, `i16`, `i32`, `i64`
  - `u8`, `u16`, `u32`, `u64`
  - `p0<i8>`

I also enforce a structural subset inside `fns`:
- at least one function
- function headers must match canonical `fn fN (arg_types)->tN {` shape
- function ids must appear in contiguous canonical order: `f0`, `f1`, `f2`, ...
- argument type list must be empty or comma-separated `tN` entries
- every referenced signature type `tN` must exist in the parsed `types` table
- block labels must be `bN:`
- first block in every function must be `b0:`
- `b0:` may not appear again later in the same function
- all block labels must be unique within each function
- block labels must appear in contiguous canonical order: `b0`, `b1`, `b2`, ...
- instruction lines must be indented
- every block must end with a terminator before next block/function close
- no instruction may appear after a terminator within the same block
- accepted terminators in bootstrap verifier: `ret`, `ret vN`, `br bN`, `cbr vN bN bN`
- `br`/`cbr` branch targets must reference block labels declared in the same function
- `cbr` condition value must be typed as `i1`
- non-terminator instruction lines must match canonical value form:
  - `vN = <opcode> <args> : tN`
  - opcode token is limited to `[a-z.]` in the bootstrap verifier
  - opcode must be in the current bootstrap-supported opcode set (unknown opcodes are rejected)
  - value result type suffix `tN` must exist in the parsed `types` table
- opcode-specific bootstrap checks now include:
  - `arg` requires numeric index operand
  - `arg` index must be within the function argument count
  - `arg` result type must match the declared type of function argument index `N`
  - `const` requires a decimal literal operand (`N` or `-N`)
  - `call` requires args in canonical shape: `fN` followed by zero-or-more `vN` operands
  - `call` target `fN` must exist in the module function table
  - `call` result type suffix must match callee return type
  - `call` argument count must match callee function signature arity
  - `icmp.eq` requires `vN vN` operands and an `i1` result type suffix
  - `icmp.eq` requires both operand value types to match
  - `ld` requires a single `vN` operand and that operand must be typed as `p0<i8>`
  - `gep` requires `vN <signed_decimal>` and both operand/result pointer typing must be `p0<i8>`
  - `alloca` requires `tN, N` operands and a `p0<i8>` result type
  - `malloc` requires `vN` operand, a non-pointer `vN` value type, and a `p0<i8>` result type
  - binary ops (`add.wrap`, `add.trap`, `sub.wrap`, `sub.trap`, `mul.wrap`, `mul.trap`, `and`, `or`, `xor`, `shl`, `shr`) require `vN vN` operands
  - binary ops require operand value types to match the explicit result type suffix
  - non-value instruction `st vPtr vVal` is accepted and requires `vPtr` to be `p0<i8>` and both operands to be defined
  - non-value instruction `free vPtr` is accepted and requires `vPtr` to be `p0<i8>` and defined
  - non-value instruction `exit vCode` is accepted and requires `vCode` to be defined and non-pointer typed
  - non-value instruction `write vPtr vLen` is accepted and requires both operands defined, `vPtr` typed as `p0<i8>`, and `vLen` non-pointer typed
  - non-value instruction `trace N vVal...` is accepted and requires decimal `N` plus one-or-more defined traced values
- SSA bootstrap check:
  - each `vN` may be defined only once per function
  - def-before-use is enforced for currently validated uses:
    - `ret vN` (and `vN` type must match function return type)
    - `cbr vN bT bF` condition value
    - `call fN vA vB ...` value operands (`vA`, `vB`, ...)
    - `ld vN`, `gep vN off`, and `st vPtr vVal` value operands
    - `malloc vN` and `free vPtr` value operands
    - `exit vCode` value operands
    - `write vPtr vLen` value operands
    - `trace N vVal...` value operands
    - bootstrap binary op operands (`vN vN`)

## Current build artifact subset

`l0c build <in.l0> <out.l0img>` (or `l0c build <in.l0> -o <out.l0img>`) currently emits:
- I write a fixed 80-byte bootstrap header (all little-endian u64 words):
  - `qword[0]`: magic (`L0IM`)
  - `qword[1]`: version (`1`)
  - `qword[2]`: header size (`80`)
  - `qword[3]`: flags (`0`, reserved in bootstrap)
  - `qword[4]`: `src_off` (`80`)
  - `qword[5]`: `src_size`
  - `qword[6]`: `code_off` (`src_off + src_size`)
  - `qword[7]`: `code_size` (bootstrap-selected code payload size)
  - `qword[8]`: `debug_off` (`code_off + code_size`)
  - `qword[9]`: `debug_size` (`64` in bootstrap)
- I then write raw canonical source bytes at `src_off`
- I then write bootstrap code section bytes at `code_off`:
  - I lower canonical two-arg kernels with the shape:
    - `v0 = arg 0 : t0`
    - `v1 = arg 1 : t0`
    - `v2 = <op> v0 v1 : t0`
    - `ret v2`
  - I currently lower these ops: `add.wrap`, `add.trap`, `sub.wrap`, `sub.trap`, `mul.wrap`, `mul.trap`, `and`, `or`, `xor`, `shl`, `shr`
  - I accept canonical swapped-operand form (`v1 v0`) for commutative ops in this set: `add.wrap`, `add.trap`, `mul.wrap`, `mul.trap`, `and`, `or`, `xor`
  - I accept canonical nonzero result value ids for this kernel shape when `ret` references the same value id (`vN = <op> ...`, `ret vN`)
  - `add.trap`/`sub.trap`/`mul.trap` currently trap via `jo` to `ud2` on signed overflow
  - I lower `icmp.eq` kernel shape (`v2 = icmp.eq v0 v1 : t1`, `ret v2`)
  - I also accept swapped compare form for that kernel (`v2 = icmp.eq v1 v0 : t1`)
  - I also accept canonical nonzero compare-result ids for that kernel when `ret` references the same value id (`vN = icmp.eq ...`, `ret vN`)
  - I lower canonical `icmp.eq + cbr` select kernel shape:
    - `v2 = icmp.eq v0 v1 : t1`
    - `cbr v2 b1 b2`
    - `b1: ret v0`
    - `b2: ret v1`
  - I also accept swapped compare form in that select kernel (`v2 = icmp.eq v1 v0 : t1`)
  - I also accept canonical nonzero compare-result ids in that select kernel when `cbr` references the same value id (`vN = icmp.eq ...`, `cbr vN ...`)
  - I lower canonical memory roundtrip kernel shape:
    - `v1 = alloca t0, 1 : t1`
    - `st v1 v0`
    - `v2 = ld v1 : t0`
    - `ret v2`
  - for memory roundtrip, I also accept canonical nonzero ids across arg/alloca/st/ld/ret when all uses reference the corresponding defs
  - I lower canonical `gep` memory roundtrip kernel shape:
    - `v1 = alloca t0, 1 : t1`
    - `st v1 v0`
    - `v2 = gep v1 0 : t1`
    - `v3 = ld v2 : t0`
    - `ret v3`
  - I lower canonical two-function call kernel shapes:
    - `f0` computes args and calls `f1`
    - `f1` is canonical `add.wrap`, `sub.wrap`, or `mul.wrap` kernel
    - current bootstrap lowering maps these shapes to corresponding direct arithmetic payloads
    - for `f1` in `add.wrap`/`mul.wrap`, I also accept swapped call-arg order in `f0` (`call f1 v1 v0`)
    - I also accept canonical nonzero call-result ids in `f0` when `ret` references the same value id (`vN = call ...`, `ret vN`)
  - I lower canonical intrinsic kernel shapes:
    - `malloc` kernel (`v1 = malloc v0 : t1`, `ret v1`) via syscall-backed allocation stub
    - for `malloc`, I also accept canonical nonzero arg/result ids when dataflow matches (`vN = arg 0`, `vM = malloc vN`, `ret vM`)
    - `free` kernel (`free v0` + `const 0` + `ret`) via defined no-op free stub
    - for `free`, I also accept canonical nonzero arg/const-ret ids when dataflow matches (`vN = arg 0`, `free vN`, `vM = const 0`, `ret vM`)
    - `exit` kernel (`exit v0`) via syscall `exit` stub
    - for `exit`, I also accept canonical nonzero arg/return ids when dataflow matches (`vN = arg 0`, `exit vN`, `ret vN`)
    - `write` kernel (`write vPtr vLen`) via syscall `write` stub (current canonical test writes newline and returns `0`)
    - for bootstrap newline `write`, I also accept canonical nonzero ids across alloca/const/store/write/return when all value-id uses match their corresponding defs
    - `trace` kernel (`trace 1 v0`) via fixed 16-byte binary record emission to stderr in current bootstrap slice
    - for `trace`, I also accept canonical nonzero traced-arg id and nonzero const/return id when dataflow matches (`vN = arg 0`, `trace 1 vN`, `vM = const 0`, `ret vM`)
  - I also lower canonical const-return kernel shape:
    - `v0 = const N : t0`
    - `v0 = const -N : t0`
    - `ret v0`
  - I also accept canonical const-return with nonzero value ids when `ret` references the same defined const value (`vN = const ...`, `ret vN`)
  - I currently use `c3` (`ret`) as the fallback for other verified inputs
- I then write a 64-byte bootstrap debug semantic index (`L0IX`):
  - `qword[0]`: magic (`L0IX`)
  - `qword[1]`: version (`1`)
  - `qword[2]`: function count
  - `qword[3]`: type count
  - `qword[4]`: kernel kind id (bootstrap lowering selector output)
  - `qword[5]`: emitted code size
  - `qword[6]`: trace schema version (`1` in current bootstrap)
  - `qword[7]`: trace record size (`16` bytes in current bootstrap)
  - current kernel kind ids are documented in `docs/IMPLEMENTABLE_SPEC.md`

`l0c imgcheck <file.l0img>` validates bootstrap container integrity:
- magic match
- version match (`1`)
- header size match
- flags match (`0` in bootstrap)
- source range consistency (`src_off >= header_size`, exact payload-end check)
- code/debug section pair validity:
  - either both offset/size are zero
  - or both are non-zero and within file bounds
- for non-zero debug section, bootstrap schema checks:
  - debug size must be `64`
  - `L0IX` magic/version must match
  - `L0IX` kernel kind id must be in the current bootstrap range
  - debug `code_size` field must match header `code_size`
  - debug trace schema/version fields must match current bootstrap constants

`l0c run <file.l0img> [u64_a] [u64_b]` currently:
- I validate image magic/version/header and code section bounds.
- I `mmap` an executable buffer, copy the image code section, and invoke it as `fn(u64,u64)->u64`.
- I pass optional unsigned decimal CLI args as `rdi` and `rsi` (default `0,0`) and print the returned `u64`.
- I reject non-decimal run arguments with a deterministic error.

`l0c tracecat <trace.bin>` currently:
- I load a binary trace file and require payload size to be a multiple of 16 bytes.
- I decode each record as (`u64 trace_id`, `u64 traced_value`).
- I print deterministic text lines for each record: `id <trace_id>` and `val <traced_value>`.
- zero-length trace payload is valid and produces no output.

`l0c mapcat <debug_map.bin>` currently:
- I load a bootstrap debug-map payload and validate:
  - minimum size `32`
  - exact size `32 + (entry_count * 24)`
  - magic `L0DM`
  - version `2`
  - each entry has non-zero `inst_id`
  - `inst_id` values are strictly increasing
  - each entry range satisfies `start <= end <= code_size`
  - ranges are monotonic/non-overlapping (`start >= previous_end`)
- I print deterministic text lines: `entries <count>`, `code_size <bytes>`, then one `(inst_id,start,end)` triplet per entry.

`l0c schemacat <trace_schema.bin>` currently:
- I load a 32-byte trace-schema payload and validate magic/version.
- I print deterministic text lines: `version <n>`, `record_size <bytes>`, `fields <count>`.

`l0c tracejoin <trace.bin> <debug_map.bin>` currently:
- I load and validate debug-map payload (`L0DM`, version `2`).
- I enforce debug-map entry validity (non-zero strictly increasing `inst_id`, `start <= end <= code_size`, monotonic non-overlapping ranges).
- I load and decode trace payload as fixed 16-byte records.
- I require every trace record id to resolve to a debug-map `inst_id` entry; unknown ids are rejected.
- I reject truncated/non-aligned trace payloads (size must be a multiple of 16 bytes).
- zero-length trace payload is valid and produces no joined output.
- For each trace record, I join by `trace_id == inst_id` and print:
  - `id <trace_id>`
  - `val <value>`
  - `start <offset>`
  - `end <offset>`

`l0c imgmeta <file.l0img>` currently:
- I validate core header and debug-section bounds for bootstrap images.
- I enforce debug-index schema constraints before printing metadata:
  - kernel kind id in bootstrap range (`<= 24`)
  - debug `code_size` equals header `code_size`
  - trace schema/version constants match bootstrap (`1`, `16`)
- I print deterministic metadata lines:
  - `version <n>`
  - `src_size <bytes>`
  - `code_size <bytes>`
  - `fn_count <n>`
  - `type_count <n>`
  - `kernel_kind <id>`
  - `trace_schema_ver <n>`
  - `trace_record_size <bytes>`

`l0c build ... --trace-schema <out.bin>` currently writes a 32-byte schema payload:
- `qword[0]`: magic (`L0TS`)
- `qword[1]`: version (`1`)
- `qword[2]`: trace record size (`16`)
- `qword[3]`: field count (`2`)

`l0c build ... --debug-map <out.bin>` currently writes a variable-size bootstrap map payload:
- `qword[0]`: magic (`L0DM`)
- `qword[1]`: version (`2`)
- `qword[2]`: instruction-entry count (`N`)
- `qword[3]`: code size (`code_size` from emitted image)
- entries follow at `qword[4+]`, each entry is:
  - `inst_id`
  - `start`
  - `end`
- current bootstrap emits kernel-kind-specific deterministic ranges:
  - fallback/const kernels: single full-range entry
  - arithmetic/bitwise/call-kernel families: fixed opcode-boundary splits
  - memory/intrinsic kernels (`malloc`, `free`, `write`, `exit`, `trace`): fixed per-kernel splits
  - current `trace` kernel map is fixed to two entries: `id 1 -> [0,17)`, `id 2 -> [17,code_size)`
  - unknown future kernel kinds still fall back to deterministic contiguous synthetic partitions

Current bootstrap parser accepts either side artifact independently or both together in one build command, and rejects duplicate optional side-artifact flags.

This is an interim image format to validate end-to-end native build flow.

## Canonical policy

Canonical mode currently accepts already-canonical text only.
Non-canonical text is rejected (no rewrite yet).
