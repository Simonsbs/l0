# L0 Implementable Spec (Bootstrap + Forward Contract)

I use this document as my coding-facing contract for L0.
I keep every rule deterministic and machine-checkable.
I freeze runtime intrinsic compatibility in `docs/INTRINSIC_CONTRACTS.md` as `intrinsics.v1`.
I freeze debug-map compatibility in `docs/DEBUG_MAP_SCHEMA.md` as `debugmap.v1`.

## 1) Token-Level Grammar (Bootstrap-Implemented)

```ebnf
module      = ver_sec types_sec consts_sec extern_sec globals_sec fns_sec ;

ver_sec     = "ver" SP "1" NL ;

types_sec   = "types" SP "{" types_body "}" NL ;
types_body  = SP
            | SP type_entry ("," SP type_entry)* SP ;
type_entry  = type_id "=" type_tok ;

type_tok    = "i1" | "i8" | "i16" | "i32" | "i64"
            | "u8" | "u16" | "u32" | "u64"
            | "p0<i8>"
            | struct_tok
            | array_tok
            | fn_type_tok ;

struct_tok  = "s{" type_id ("," type_id)* "}" ;
array_tok   = "a" pos_int "<" type_id ">" ;
fn_type_tok = "fn(" fn_type_args ")->" type_id ;
fn_type_args = /* empty */ | type_id ("," type_id)* ;
pos_int     = nonzero_digit digit* ;
digit       = "0" | nonzero_digit ;
nonzero_digit = "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

consts_sec  = "consts" SP "{" sec_payload "}" NL ;
extern_sec  = "extern" SP "{" sec_payload "}" NL ;
globals_sec = "globals" SP "{" sec_payload "}" NL ;
sec_payload = *(any_byte_except_unmatched_close) ;

fns_sec     = "fns" SP "{" NL fn_def+ "}" NL? ;

fn_def      = "fn" SP fn_id SP "(" fn_args ")->" type_id SP "{" NL block+ "}" NL ;
fn_args     = /* empty */ | type_id ("," type_id)* ;

block       = block_id ":" NL instr+ ;

instr       = term_instr | value_instr | nonvalue_instr ;

term_instr  = IND "ret"
            | IND "ret" SP value_id
            | IND "br" SP block_id
            | IND "cbr" SP value_id SP block_id SP block_id ;

value_instr = IND value_id SP "=" SP opcode SP args SP ":" SP type_id ;
nonvalue_instr = (IND "st" SP value_id SP value_id)
              | (IND "free" SP value_id)
              | (IND "exit" SP value_id)
              | (IND "write" SP value_id SP value_id)
              | (IND "trace" SP dec_u (SP value_id)+) ;

opcode      = "arg" | "const" | "call"
            | "add.wrap" | "add.trap" | "sub.wrap" | "sub.trap" | "mul.wrap" | "mul.trap"
            | "and" | "or" | "xor" | "shl" | "shr"
            | "icmp.eq"
            | "ld" | "gep" | "alloca" | "malloc" ;

args        = arg_args
            | const_args
            | call_args
            | bin_args
            | icmp_eq_args
            | ld_args
            | gep_args
            | alloca_args
            | malloc_args ;

arg_args    = dec_u ;
const_args  = dec_s ;
call_args   = fn_id (SP value_id)* ;
bin_args    = value_id SP value_id ;
icmp_eq_args= value_id SP value_id ;
ld_args     = value_id ;
gep_args    = value_id SP dec_s ;
alloca_args = type_id "," SP dec_u ;
malloc_args = value_id ;

fn_id       = "f" dec_u ;
block_id    = "b" dec_u ;
value_id    = "v" dec_u ;
type_id     = "t" dec_u ;

IND         = "  " ;
SP          = " " ;
NL          = "\n" ;
dec_u       = digit+ ;
dec_s       = ["-"] digit+ ;
digit       = "0".."9" ;
```

## 2) Canonical Rules (Bootstrap-Implemented)

- Section order is fixed: `ver`, `types`, `consts`, `extern`, `globals`, `fns`.
- Function ids are contiguous and ordered: `f0`, `f1`, `f2`, ...
- Block ids are contiguous and ordered per function: `b0`, `b1`, `b2`, ...
- First block is always `b0`.
- Every instruction line uses two-space indent.
- Every block ends in a terminator.
- I reject unknown opcodes in value form.
- I reject non-canonical text instead of rewriting it.

## 3) Type Rules (Bootstrap-Implemented)

- Every referenced `tN` must exist in parsed `types`.
- Supported `types` RHS token forms:
  - primitive integers (`i1`, `i8`, `i16`, `i32`, `i64`, `u8`, `u16`, `u32`, `u64`)
  - pointer (`p0<i8>`)
  - struct (`s{tA,tB,...}` with one-or-more fields)
  - fixed array (`aN<tA>` with `N > 0`)
  - function type (`fn(tA,...)->tR`)
- In `types` RHS struct/array/function tokens, referenced `tN` ids are validated and forward/self refs are rejected in bootstrap parser mode.
- `arg N`:
  - `N < fn_arg_count`
  - result type suffix must equal declared argument `N` type
- `ret vX`:
  - `vX` must be defined before use
  - type(`vX`) must equal function return type
- `cbr vC bT bF`:
  - `vC` must be defined before use
  - type(`vC`) must be `i1`
- Binary ops (`add.wrap`, `add.trap`, `sub.wrap`, `sub.trap`, `mul.wrap`, `mul.trap`, `and`, `or`, `xor`, `shl`, `shr`):
  - args shape: `vA vB`
  - both operands defined before use
  - type(`vA`) == type(`vB`) == explicit result type suffix
- `icmp.eq`:
  - args shape: `vA vB`
  - both operands defined before use
  - type(`vA`) == type(`vB`)
  - explicit result type suffix must be `i1`
- `call`:
  - shape: `call fN [vA ...]`
  - target `fN` must exist
  - operand count must match callee arity
  - result type suffix must match callee return type
  - each value operand must be defined before use
- `ld`:
  - shape: `ld vPtr`
  - `vPtr` must be defined before use
  - type(`vPtr`) must be `p0<i8>`
- `gep`:
  - shape: `gep vPtr off`
  - `off` is signed decimal
  - `vPtr` must be defined before use and typed `p0<i8>`
  - explicit result type suffix must be `p0<i8>`
- `alloca`:
  - shape: `alloca tElem, N`
  - `tElem` must exist
  - `N` is unsigned decimal
  - explicit result type suffix must be `p0<i8>`
- `malloc`:
  - shape: `malloc vSize`
  - `vSize` must be defined before use
  - `vSize` must not be pointer-typed
  - explicit result type suffix must be `p0<i8>`
- `st` (non-value):
  - shape: `st vPtr vVal`
  - both operands must be defined before use
  - `vPtr` must be typed `p0<i8>`
- `free` (non-value):
  - shape: `free vPtr`
  - operand must be defined before use
  - `vPtr` must be typed `p0<i8>`
- `exit` (non-value):
  - shape: `exit vCode`
  - operand must be defined before use
  - `vCode` must not be pointer-typed
- `write` (non-value):
  - shape: `write vPtr vLen`
  - both operands must be defined before use
  - `vPtr` must be typed `p0<i8>`
  - `vLen` must not be pointer-typed
- `trace` (non-value):
  - shape: `trace N vVal...`
  - `N` is unsigned decimal
  - one-or-more traced values are required
  - each traced value must be defined before use

## 4) Core Semantics (Bootstrap Contract)

- Integer ops currently implemented in lowering are wrap semantics on 64-bit registers, except `add.trap` / `sub.trap` / `mul.trap` which trap on signed overflow (`jo` -> `ud2`, process-terminating trap in current runtime path).
- `icmp.eq` returns `0` or `1`.
- Pointer arithmetic and memory instruction semantics are defined at verifier level; full lowering/runtime semantics are still incremental.
- I keep behavior defined by default and avoid UB contracts.

## 5) x86-64 Lowering Rules (Current Bootstrap)

I currently lower deterministic canonical kernels:

- Two-arg kernels (`f0(t0,t0)->t0`, single block):
  - `add.wrap`, `add.trap`, `sub.wrap`, `sub.trap`, `mul.wrap`, `mul.trap`, `and`, `or`, `xor`, `shl`, `shr`
- Compare kernel:
  - `icmp.eq` returning `i1`
- Control-flow select kernel:
  - `icmp.eq` + `cbr` selecting `ret v0` or `ret v1`
- Two-function call kernels:
  - `f0` calls `f1` where `f1` is canonical `add.wrap` / `sub.wrap` / `mul.wrap`
- Memory kernels:
  - canonical `alloca + st + ld` roundtrip
  - canonical `alloca + st + gep + ld` roundtrip
- Intrinsic kernels:
  - canonical `malloc` kernel (syscall-backed `mmap` allocator path)
  - canonical `free` kernel (defined no-op returning zero in current slice)
  - canonical `exit` kernel (syscall-backed process exit path)
  - canonical `write` kernel (syscall-backed stdout write path)
  - canonical `trace` kernel (fixed 16-byte binary trace emission to stderr in current slice)
- Const-return kernel:
  - `const N` / `const -N` then `ret`

For verified modules outside these patterns, I emit fallback code payload: single-byte `ret` (`0xC3`).

## 6) L0IMG Binary Format (Bootstrap-Implemented)

All fields are little-endian `u64`.

Header (80 bytes):
- `qword[0]`: magic (`L0IM`)
- `qword[1]`: version (`1`)
- `qword[2]`: header size (`80`)
- `qword[3]`: flags (`0`)
- `qword[4]`: `src_off`
- `qword[5]`: `src_size`
- `qword[6]`: `code_off`
- `qword[7]`: `code_size`
- `qword[8]`: `debug_off`
- `qword[9]`: `debug_size`

Section order in file:
1. header
2. canonical source bytes
3. code bytes
4. debug semantic index bytes

## 7) Debug Semantic Index Schema (Bootstrap-Implemented)

`debug_size = 64` bytes (`L0IX` payload):
- `qword[0]`: magic (`L0IX`)
- `qword[1]`: version (`1`)
- `qword[2]`: function count
- `qword[3]`: type count
- `qword[4]`: kernel kind id
- `qword[5]`: emitted code size
- `qword[6]`: trace schema version (`1`)
- `qword[7]`: trace record size (`16`)

Current bootstrap `kernel kind id` mapping:
- `0`: fallback `ret`
- `1`: `add.wrap`
- `2`: `add.trap`
- `3`: `sub.wrap`
- `4`: `sub.trap`
- `5`: `mul.wrap`
- `6`: `and`
- `7`: `or`
- `8`: `xor`
- `9`: `shl`
- `10`: `shr`
- `11`: `icmp.eq`
- `12`: `icmp.eq + cbr` select
- `13`: const-return kernel
- `14`: memory roundtrip kernel (`alloca/st/ld`)
- `15`: `mul.trap`
- `16`: canonical call->add two-function kernel
- `17`: canonical call->sub two-function kernel
- `18`: canonical call->mul two-function kernel
- `19`: canonical `gep` memory roundtrip kernel
- `20`: canonical `malloc` kernel
- `21`: canonical `free` no-op kernel
- `22`: canonical `write` newline kernel
- `23`: canonical `exit` kernel
- `24`: canonical `trace` emit kernel

## 8) Runtime Execution Contract (Bootstrap-Implemented)

`l0c run <file.l0img> [u64_a] [u64_b]`:
- validates image header and code section bounds
- allocates executable memory via `mmap`
- copies code section
- calls code as `fn(u64,u64)->u64`
- prints returned value as unsigned decimal

Optional build-side bootstrap artifacts:
- `--trace-schema <out.bin>`:
  - 32-byte payload: `L0TS`, version `1`, record size `16`, field count `2`
- `--debug-map <out.bin>`:
  - variable-size payload: `L0DM`, version `2`, entry count `N`, code size, then `N` triplets of `inst_id/start/end`
- current bootstrap parser accepts either option independently or both together, and rejects duplicate optional flags

Native bootstrap decode helpers:
- `tracecat <trace.bin>`
- `mapcat <debug_map.bin>`
- `schemacat <trace_schema.bin>`
- `tracejoin <trace.bin> <debug_map.bin>`

## 9) Near-Term Completion Steps

To complete the M1 scope, I still need to finish:
- lowering for verified `ld/st/gep/alloca` modules (not only verify)
- non-kernel generalization of intrinsic/runtime surface (`write`/`malloc`/`free`/`exit`)
- extend debug-map coverage from kernel-template ranges to full per-L0-instruction lowering coverage for generalized codegen paths
- broader canonical rewrite mode (optional `--fix` path)
