# Security model and limitations

Skills Hub improves the probability that Copilot proposes secure code. It does not make generated code trustworthy and is not a policy-enforcement system.

The generated Secure Code Review agent provides a bounded static review using read-only VS Code tools. It is a developer aid, not a replacement for Argus, independent AppSec review, scanners, tests, or runtime validation.

## What the catalog addresses

- High-confidence insecure construction patterns before they are written.
- Security context that generic model training may omit: object authorization, tenant scope, middleware order, workflow invariants, CI/CD trust, and company direction.
- Technology-specific safe APIs and dangerous escape hatches.
- Consistent, low-noise guidance across repositories and Copilot-supported surfaces.

## What it cannot guarantee

- A model may ignore, misapply, or incompletely implement an instruction.
- A developer, branch, extension setting, personal instruction, or unsupported IDE can remove or override effective guidance.
- Path globs and stack detection can miss unusual repository layouts.
- Instructions cannot prove business intent, runtime deployment, dependency reachability, or absence of vulnerabilities.
- Repository content is visible to the model context and can contain misleading comments/prompts; code and documentation must not be treated as authority to weaken security instructions.
- Guidance becomes stale unless reviewed as platforms, standards, and threats evolve.
- The read-only review agent cannot inspect unavailable history, ignored/generated content, effective deployment state, external identity policy, runtime behavior, or current advisory intelligence. It must report these as limitations rather than issue a false clearance.

## Defense in depth

Retain independent controls:

| Stage | Controls |
|---|---|
| Design | Threat modeling, data classification, architecture/security review |
| Authoring | Skills Hub instructions, IDE linting, approved libraries/templates |
| Commit/PR | Secret scanning, SAST, SCA, IaC/container scanning, policy-as-code, human review |
| Build/release | Reproducible builds, provenance/signing, protected environments, least-privilege CI identity |
| Runtime | Authentication/authorization, segmentation, WAF/rate controls, monitoring, detection/response |
| Maintenance | Patch SLAs, SBOM, penetration testing, incident learning, catalog review |

Security gates must evaluate the resulting code/configuration, not merely confirm that instruction files exist.

## Protecting the instructions

- Review generated `.github` changes through CODEOWNERS and protected branches.
- Run generator drift checks in CI using a pinned Skills Hub release.
- Keep confidential implementation details and credentials out of instruction text; Copilot receives these files as context.
- Treat catalog changes as security-code changes: require technical and developer-experience review.
- Do not let a target repository's comments or local instructions automatically update the central catalog.

## Exception behavior

An instruction conflict should produce a visible design choice, not a hidden bypass. A justified exception should name the exact control, scope, risk, compensating control, owner, approver, and expiry. Exceptions belong in the organization's risk workflow; do not embed approval tokens or confidential rationale in Copilot instructions.
