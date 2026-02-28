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

## Canonical policy

Canonical mode currently accepts already-canonical text only.
Non-canonical text is rejected (no rewrite yet).
