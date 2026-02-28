# L0 MVP Spec (Initial Freeze)

This is the first frozen subset for implementation.

## Module shape (strict)

Exact section order is mandatory:
1. `ver`
2. `types`
3. `consts`
4. `extern`
5. `globals`
6. `fns`

## Current parser subset

The bootstrap parser currently validates module-level section order and required braces/newlines.
Function-level grammar is staged next.

## Current build artifact subset

`l0c build <in.l0> <out.l0img>` currently emits:
- fixed 80-byte bootstrap header (all little-endian u64 words):
  - `qword[0]`: magic (`L0IM`)
  - `qword[1]`: version (`1`)
  - `qword[2]`: header size (`80`)
  - `qword[3]`: flags (`0`)
  - `qword[4]`: `src_off` (`80`)
  - `qword[5]`: `src_size`
  - `qword[6]`: `code_off` (`0` in bootstrap)
  - `qword[7]`: `code_size` (`0` in bootstrap)
  - `qword[8]`: `debug_off` (`0` in bootstrap)
  - `qword[9]`: `debug_size` (`0` in bootstrap)
- followed by raw canonical source bytes at `src_off`.

`l0c imgcheck <file.l0img>` validates bootstrap container integrity:
- magic match
- header size match
- source offset match
- image size consistency (`src_off + src_size == file_size`)

This is an interim image format to validate end-to-end native build flow.

## Canonical policy

Canonical mode currently accepts already-canonical text only.
Non-canonical text is rejected (no rewrite yet).
