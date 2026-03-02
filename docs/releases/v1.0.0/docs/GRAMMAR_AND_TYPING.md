# L0 Grammar and Typing Rules

I use this page as my consolidated normative reference for token-level grammar and typing judgments.

## Token-Level Grammar (Consolidated)

```ebnf
module      = ver_sec types_sec consts_sec extern_sec globals_sec fns_sec ;
ver_sec     = "ver" SP "1" NL ;
types_sec   = "types" SP "{" types_body "}" NL ;
types_body  = SP | SP type_entry ("," SP type_entry)* SP ;
type_entry  = type_id "=" type_tok ;

type_tok    = "i1" | "i8" | "i16" | "i32" | "i64"
            | "u8" | "u16" | "u32" | "u64"
            | "p0<i8>" | struct_tok | array_tok | fn_type_tok ;
struct_tok  = "s{" type_id ("," type_id)* "}" ;
array_tok   = "a" pos_int "<" type_id ">" ;
fn_type_tok = "fn(" fn_type_args ")->" type_id ;
fn_type_args = /* empty */ | type_id ("," type_id)* ;

consts_sec  = "consts" SP "{" sec_payload "}" NL ;
extern_sec  = "extern" SP "{" sec_payload "}" NL ;
globals_sec = "globals" SP "{" sec_payload "}" NL ;

fns_sec     = "fns" SP "{" NL fn_def+ "}" NL? ;
fn_def      = "fn" SP fn_id SP "(" fn_args ")->" type_id SP "{" NL block+ "}" NL ;
fn_args     = /* empty */ | type_id ("," type_id)* ;

block       = block_id ":" NL instr+ ;
instr       = term_instr | value_instr | nonvalue_instr ;

term_instr  = IND "ret" | IND "ret" SP value_id
            | IND "br" SP block_id
            | IND "cbr" SP value_id SP block_id SP block_id ;

value_instr = IND value_id SP "=" SP opcode SP args SP ":" SP type_id ;
nonvalue_instr = IND "st" SP value_id SP value_id
              | IND "free" SP value_id
              | IND "exit" SP value_id
              | IND "write" SP value_id SP value_id
              | IND "trace" SP dec_u (SP value_id)+ ;

opcode      = "arg" | "const" | "call"
            | "add.wrap" | "add.trap" | "sub.wrap" | "sub.trap" | "mul.wrap" | "mul.trap"
            | "and" | "or" | "xor" | "shl" | "shr"
            | "icmp.eq" | "ld" | "gep" | "alloca" | "malloc" ;
```

## Canonical Structural Rules

- section order is fixed
- function ids are contiguous from `f0`
- block ids are contiguous from `b0` per function
- every block has exactly one terminator
- no instruction appears after a terminator in a block
- value ids are single-assignment per function

## Typing Judgments (Bootstrap Contract)

I write judgments as `Gamma |- instr ok`.

### Function Signatures

- every `tN` referenced by function args/return must exist in parsed `types`
- `arg I` requires `I < arity(f)`
- `arg` result type must equal declared argument type at index `I`

### Value Producers

- binary ops: operand types must match each other and explicit result type
- `icmp.eq`: operand types must match; explicit result type must be `i1`
- `call`: callee must exist; arity and types must match declared callee signature
- `ld`: operand must be `p0<i8>`
- `gep`: pointer operand and explicit result must be `p0<i8>`
- `alloca`: explicit result must be `p0<i8>`
- `malloc`: size operand must be non-pointer; explicit result must be `p0<i8>`

### Non-Value Ops

- `st`: first operand must be `p0<i8>`
- `free`: operand must be `p0<i8>`
- `write`: first operand `p0<i8>`, second operand non-pointer
- `exit`: operand non-pointer
- `trace`: one-or-more value operands, each defined before use

### Terminators

- `ret vX`: type(`vX`) must equal function return type
- `cbr vC bT bF`: type(`vC`) must be `i1`, branch targets must exist in same function
- `br bK`: target block must exist in same function

## Def-Before-Use Rules

I require every referenced `vN` to be previously defined in the same function for:
- `ret vN`
- `cbr vN ...`
- value-op operands (`call`, binary, `icmp.eq`, `ld`, `gep`, `malloc`)
- non-value-op operands (`st`, `free`, `write`, `exit`, `trace`)

## Related References

- implementable contract: `docs/IMPLEMENTABLE_SPEC.md`
- language reference: `docs/LANGUAGE.md`
- instruction reference: `docs/INSTRUCTION_SET.md`
