# Governance and Merge Policy

I use this document to define how I keep `main` stable and production-focused.

## Ownership

- code ownership: `.github/CODEOWNERS`
- default owner: `@Simonsbs`

## Contribution Templates

I enforce structured contribution metadata with:
- `.github/ISSUE_TEMPLATE/bug_report.yml`
- `.github/ISSUE_TEMPLATE/feature_request.yml`
- `.github/pull_request_template.md`

## Required Status Checks on `main`

I require these checks before merge:
- `build (ubuntu-22.04)`
- `build (ubuntu-latest)`
- `test (smoke)`
- `test (full)`
- `wiki-sync` (when docs or wiki-mapped files change)

I configure this in GitHub branch protection rules for `main`.

## Branch Protection Settings I Use

I keep these settings enabled:
- require pull request before merging
- require status checks to pass before merging
- require branch to be up to date before merging
- require review from code owners
- disallow force pushes
- disallow branch deletion

## Change Control

For behavior changes, I require:
1. tests first (or tests in same change)
2. docs update in first person
3. compatibility impact review
4. release note entry for user-visible changes
