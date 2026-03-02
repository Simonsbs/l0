# Opcode and Terminator Examples

I use this page as a fast deterministic reference for every L0 opcode and terminator in the current bootstrap surface.

## `arg`
Valid example: `tests/valid_add.l0`  
Failure example: `tests/invalid_arg_out_of_range.l0`

## `const`
Valid example: `tests/valid_const.l0`  
Failure example: `tests/invalid_const_bad_operand.l0`

## `add.wrap`
Valid example: `tests/valid_add.l0`  
Failure example: `tests/invalid_binary_operand_type_mismatch.l0`

## `add.trap`
Valid example: `tests/valid_add_trap.l0`  
Failure example: `tests/invalid_binary_operands.l0`

## `sub.wrap`
Valid example: `tests/valid_sub.l0`  
Failure example: `tests/invalid_binary_use_before_def.l0`

## `sub.trap`
Valid example: `tests/valid_sub_trap.l0`  
Failure example: `tests/invalid_binary_result_type_mismatch.l0`

## `mul.wrap`
Valid example: `tests/valid_mul.l0`  
Failure example: `tests/invalid_binary_operand_type_mismatch.l0`

## `mul.trap`
Valid example: `tests/valid_mul_trap.l0`  
Failure example: `tests/invalid_binary_operands.l0`

## `and`
Valid example: `tests/valid_and.l0`  
Failure example: `tests/invalid_binary_operand_type_mismatch.l0`

## `or`
Valid example: `tests/valid_or.l0`  
Failure example: `tests/invalid_binary_operand_type_mismatch.l0`

## `xor`
Valid example: `tests/valid_xor.l0`  
Failure example: `tests/invalid_binary_operand_type_mismatch.l0`

## `shl`
Valid example: `tests/valid_shl.l0`  
Failure example: `tests/invalid_binary_operand_type_mismatch.l0`

## `shr`
Valid example: `tests/valid_shr.l0`  
Failure example: `tests/invalid_binary_operand_type_mismatch.l0`

## `icmp.eq`
Valid example: `tests/valid_icmp_eq.l0`  
Failure example: `tests/invalid_icmp_result_not_i1.l0`

## `call`
Valid example: `tests/valid_call.l0`  
Failure example: `tests/invalid_call_arity_mismatch.l0`

## `alloca`
Valid example: `tests/valid_mem_roundtrip.l0`  
Failure example: `tests/invalid_alloca_bad_shape.l0`

## `ld`
Valid example: `tests/valid_mem_roundtrip.l0`  
Failure example: `tests/invalid_ld_ptr_not_pointer.l0`

## `st`
Valid example: `tests/valid_mem_roundtrip.l0`  
Failure example: `tests/invalid_st_ptr_not_pointer.l0`

## `gep`
Valid example: `tests/valid_mem_gep_roundtrip.l0`  
Failure example: `tests/invalid_gep_ptr_not_pointer.l0`

## `malloc`
Valid example: `tests/valid_malloc.l0`  
Failure example: `tests/invalid_malloc_size_pointer.l0`

## `free`
Valid example: `tests/valid_free_noop.l0`  
Failure example: `tests/invalid_free_ptr_not_pointer.l0`

## `write`
Valid example: `tests/valid_write_newline.l0`  
Failure example: `tests/invalid_write_len_undefined.l0`

## `exit`
Valid example: `tests/valid_exit.l0`  
Failure example: `tests/invalid_exit_code_pointer.l0`

## `trace`
Valid example: `tests/valid_trace_noop.l0`  
Failure example: `tests/invalid_trace_undefined.l0`

## `br`
Valid example: `tests/valid_branch.l0`  
Failure example: `tests/invalid_br_target_missing.l0`

## `cbr`
Valid example: `tests/valid_branch.l0`  
Failure example: `tests/invalid_cbr_cond_not_i1.l0`

## `ret`
Valid example: `tests/valid_min.l0`  
Failure example: `tests/invalid_ret_undefined_value.l0`
