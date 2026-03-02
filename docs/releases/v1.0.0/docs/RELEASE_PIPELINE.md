# Packaging and Release Pipeline (v1)

I use this document as the frozen release-pipeline contract for the current bootstrap toolchain.

Contract version: `relpipe.v1`

## What I Freeze in v1

I freeze a scripted, reproducible release-candidate build flow that:
- packages the `l0c` Linux x86-64 binary
- emits release metadata manifest
- emits per-artifact and aggregate SHA-256 checksum files
- verifies checksums in the same run
- validates package smoke execution before and after tarball unpack

## Release Script

I execute:
- `scripts/release_candidate.sh`

Inputs:
- compiler binary path
- repository root path
- output directory
- release version string

Outputs for `l0-<version>-linux-x86_64`:
- `l0-<version>-linux-x86_64.tar.gz`
- `l0-<version>-linux-x86_64.tar.gz.sha256`
- `l0-<version>-linux-x86_64.l0c.sha256`
- `l0-<version>-linux-x86_64.manifest.sha256`
- `l0-<version>-linux-x86_64.sha256` (aggregate)

## Reproducibility Controls in v1

I enforce deterministic archive construction with:
- sorted tar entries
- fixed mtime (`UTC 1970-01-01`)
- normalized owner/group (`0/0`, numeric)
- `gzip -n` to remove timestamp/name variability

Under fixed inputs and version string, this yields byte-stable package artifacts.

## Versioning Policy in v1

I use semantic versioning-style tags for releases:
- release candidate: `vMAJOR.MINOR.PATCH-rcN`
- production release: `vMAJOR.MINOR.PATCH`

I follow this bump policy:
- `PATCH`: bug fixes and internal hardening without contract-surface changes
- `MINOR`: backward-compatible feature additions
- `MAJOR`: any compatibility-breaking change to source/image/tool contracts

I treat frozen contract docs (`*.v1`) as compatibility anchors and bump the corresponding contract version when behavior changes.

## Enforcement

I enforce this contract in:
- `tests/release_pipeline.sh`

That harness runs the release script twice with fixed inputs and requires:
- both runs report `ok`
- expected release artifacts exist
- tarballs are byte-identical across runs
- aggregate checksum files are byte-identical across runs
- checksum verification passes

The harness is integrated into `tests/run.sh` and therefore enforced by `make test`.

## Out of Scope in v1

- Multi-platform packaging matrix (Windows/macOS artifacts).
- Signed attestations or external provenance systems.
- Git tag creation/publishing automation.
