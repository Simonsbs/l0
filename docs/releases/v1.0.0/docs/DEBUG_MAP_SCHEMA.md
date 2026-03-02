# Debug Map Schema Contracts (v1)

I use this document as the frozen compatibility contract for debug-map artifacts.

Contract version: `debugmap.v1`

Current binary schema (frozen in this contract):
- magic: `L0DM`
- internal schema version field: `2`
- layout:
  - `qword[0]`: magic (`L0DM`)
  - `qword[1]`: schema version (`2`)
  - `qword[2]`: `entry_count`
  - `qword[3]`: `code_size`
  - followed by `entry_count` triplets (`inst_id`, `start`, `end`)

## Decode Contract

`mapcat` output is frozen as:
- `entries <count>`
- `code_size <bytes>`
- one repeated 3-line block per entry:
  - `inst_id <id>`
  - `start <off>`
  - `end <off>`

I freeze deterministic decode for compatibility fixtures in `tests/debug_map_schema.sh`.

## Validation Contract

I freeze these strict validation rules for both `mapcat` and `tracejoin`:
- magic must be `L0DM`
- version must be `2`
- payload size must be exactly `32 + entry_count*24`
- `inst_id` must be nonzero
- `inst_id` values must be strictly increasing
- each entry must satisfy `start <= end <= code_size`
- entry ranges must be monotonic non-overlapping

## Join Contract

`tracejoin` joins by `trace_id == inst_id` and preserves trace-record order in output.

## Compatibility Fixtures and Tamper Matrix

I enforce compatibility and tamper strictness in:
- `tests/debug_map_schema.sh`

That harness freezes:
- deterministic decode for one-entry and two-entry schema fixtures
- deterministic join behavior for a two-record trace fixture
- strict rejection for tampered map artifacts:
  - bad magic
  - bad version
  - mismatched `entry_count`
  - non-increasing `inst_id`
  - overlapping ranges
