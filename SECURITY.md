# Security Policy

I maintain L0 as a native toolchain project, so I treat parser/verifier robustness and artifact validation as security-critical surfaces.

## Supported Versions

I currently support security fixes for:

- `v1.0.x` (including `v1.0.0`)

Older tags are best-effort only.

## Reporting a Vulnerability

I ask that you do not open public issues for exploitable vulnerabilities.

Please report privately by either:
- GitHub Security Advisory workflow for this repository, or
- emailing me with:
  - minimal reproduction input
  - affected command(s)
  - expected vs actual behavior
  - environment details (`as`, `ld`, `make` versions and commit/tag)

I will acknowledge receipt, reproduce, and provide a remediation timeline.

## Security Baseline

I keep these baseline controls:
- strict parser/verifier rejection for malformed and non-canonical input
- `imgcheck`/`imgmeta` corruption rejection gates
- trace/debug schema validation gates
- deterministic regression suite (`make test`) including malformed-input stress harnesses
- documented compatibility and release contracts in `docs/`

## Disclosure Process

I follow coordinated disclosure:
1. reproduce and scope
2. patch and test
3. publish fix commit/tag
4. publish release notes and migration notes when needed
