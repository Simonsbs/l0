# Versioned Documentation and Snapshot Policy

I use this page to describe how I reference stable docs by release tag and how I compare against latest.

## Current Stable Snapshot

- tag: `v1.0.0`
- source commit: see git tag target
- frozen docs directory: `docs/releases/v1.0.0/`
- intended frozen contract set: all `*.v1` docs in `docs/`

## How I Read Tagged Docs

I treat two views as first-class:
- latest: main branch docs
- snapshot: tagged docs at `v1.0.0` plus `docs/releases/v1.0.0/`

I use tagged docs when I need strict reproducibility against a released version.

## Upgrade Reading Flow

1. Read `docs/COMPATIBILITY_POLICY.md`.
2. Compare contract docs between tag and main.
3. Re-run compatibility and production-readiness gates.
4. Verify `docs/releases/v1.0.0/MANIFEST.sha256`.

## Contract Drift Rule

When any frozen contract behavior changes, I:
- bump the corresponding contract version
- document migration impact
- update compatibility policy and release notes

## Snapshot-Oriented Checklist

- `make test` passes on current branch
- release pipeline gate passes
- compatibility matrix gate passes
- production readiness gate passes
- docs snapshot gate passes (`tests/docs_snapshot.sh`)
