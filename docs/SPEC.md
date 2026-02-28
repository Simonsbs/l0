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
- 20-byte bootstrap header:
  - bytes `0..3`: magic `L0IM`
  - bytes `4..11`: little-endian u64 version (`1`)
  - bytes `12..19`: reserved (`0`)
- followed by raw canonical source bytes as temporary payload.

This is an interim image format to validate end-to-end native build flow.

## Canonical policy

Canonical mode currently accepts already-canonical text only.
Non-canonical text is rejected (no rewrite yet).
