# Workflows

I use this document as my deterministic, runnable workflow reference for L0.

## Workflow 1: Arithmetic End-to-End

I use this when I want a minimal verify/build/run loop.

```sh
./bin/l0c verify docs/examples/01_arithmetic_add_wrap.l0
./bin/l0c build docs/examples/01_arithmetic_add_wrap.l0 /tmp/l0_wf_add.img
./bin/l0c imgcheck /tmp/l0_wf_add.img
./bin/l0c imgmeta /tmp/l0_wf_add.img
./bin/l0c run /tmp/l0_wf_add.img 5 8
```

Expected stable outputs:
- `verify`: `ok`
- `imgcheck`: `ok`
- `imgmeta` contains: `kernel_kind 1`, `code_size 7`
- `run` prints: `13`

## Workflow 2: Control-Flow End-to-End

I use this when I want to confirm conditional branch behavior and emitted branch kernel metadata.

```sh
./bin/l0c verify docs/examples/03_control_cbr_select.l0
./bin/l0c build docs/examples/03_control_cbr_select.l0 /tmp/l0_wf_cbr.img
./bin/l0c imgcheck /tmp/l0_wf_cbr.img
./bin/l0c imgmeta /tmp/l0_wf_cbr.img
./bin/l0c run /tmp/l0_wf_cbr.img 1
./bin/l0c run /tmp/l0_wf_cbr.img 0
```

Expected stable outputs:
- `verify`: `ok`
- `imgcheck`: `ok`
- `imgmeta` contains: `kernel_kind 25`, `code_size 4`
- `run ... 1` prints: `1`
- `run ... 0` prints: `0`

## Workflow 3: Debug Map and Trace Join End-to-End

I use this when I need to debug instruction ids and correlate trace records to code ranges.

```sh
./bin/l0c verify docs/examples/10_intrinsic_trace.l0
./bin/l0c build docs/examples/10_intrinsic_trace.l0 /tmp/l0_wf_trace.img \
  --debug-map /tmp/l0_wf_trace.map \
  --trace-schema /tmp/l0_wf_trace.schema
./bin/l0c imgcheck /tmp/l0_wf_trace.img
./bin/l0c imgmeta /tmp/l0_wf_trace.img
./bin/l0c schemacat /tmp/l0_wf_trace.schema
./bin/l0c mapcat /tmp/l0_wf_trace.map
./bin/l0c run /tmp/l0_wf_trace.img 123 >/tmp/l0_wf_trace.out 2>/tmp/l0_wf_trace.bin
./bin/l0c tracecat /tmp/l0_wf_trace.bin
./bin/l0c tracejoin /tmp/l0_wf_trace.bin /tmp/l0_wf_trace.map
```

Expected stable outputs:
- `verify`: `ok`
- `imgcheck`: `ok`
- `imgmeta` contains: `kernel_kind 24`
- `schemacat` output:
  - `version 1`
  - `record_size 16`
  - `fields 2`
- `mapcat` output:
  - `entries 2`
  - `code_size 51`
  - `inst_id 1 start 0 end 17`
  - `inst_id 2 start 17 end 51`
- `run` stdout prints: `0`
- `tracecat` prints:
  - `id 1`
  - `val 123`
- `tracejoin` prints:
  - `id 1`
  - `val 123`
  - `start 0`
  - `end 17`

## How I keep this reliable

I keep the scripted equivalents of these workflows in `tests/run.sh` so `make test` enforces them every run.
