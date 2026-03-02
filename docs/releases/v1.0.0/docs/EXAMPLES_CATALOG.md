# L0 Examples Catalog

I use this as an index of runnable examples and what each example demonstrates.

## Arithmetic and Compare

- `docs/examples/01_arithmetic_add_wrap.l0`: two-arg `add.wrap` baseline
- `docs/examples/02_compare_icmp_eq.l0`: `icmp.eq` boolean result path

## Control Flow and CFG

- `docs/examples/03_control_cbr_select.l0`: `icmp.eq + cbr` select behavior
- `docs/examples/15_cfg_branch_const_select.l0`: branch-const multi-block CFG
- `docs/examples/16_cfg_merge_mem_select.l0`: branch/store/join merge CFG

## Memory

- `docs/examples/04_memory_roundtrip.l0`: `alloca` + `st` + `ld`
- `docs/examples/05_memory_gep_roundtrip.l0`: `alloca` + `st` + `gep` + `ld`

## Calls and ABI

- `docs/examples/06_call_add_two_function.l0`: two-function call lowering
- `docs/examples/18_sysv_abi_sum6_kernel.l0`: SysV six-argument entry mapping

## Intrinsics and Debugging

- `docs/examples/07_intrinsic_malloc.l0`: `malloc`
- `docs/examples/08_intrinsic_free.l0`: `free`
- `docs/examples/09_intrinsic_write.l0`: `write`
- `docs/examples/10_intrinsic_trace.l0`: `trace` plus debug-map/trace-schema workflow
- `docs/examples/11_intrinsic_exit.l0`: `exit`

## Type Forms

- `docs/examples/12_types_struct_sig.l0`: struct signature form
- `docs/examples/13_types_array_sig.l0`: fixed-array signature form
- `docs/examples/14_types_fn_sig.l0`: function-type signature form

## Stress and Regression Slices

- `docs/examples/17_spill_stress_kernel.l0`: deterministic spill/reload stress path

## Quick Verification Loop

```sh
for f in docs/examples/*.l0; do
  ./bin/l0c verify "$f"
done
```
