# Argus review-pack conversion

Skills Hub preserves its preventive instruction catalog and adds an explicitly invoked, read-only source-code review experience for GitHub Copilot in VS Code. The review pack is not a copy of Argus and does not attempt to reproduce its autonomous VM/scanner environment.

## Source scope

The 22 July 2026 inventory covers the Argus skill tree at `/home/diferreira/code_review/argus/skills/`:

- 51 `SKILL.md` files and role definitions;
- 560 Markdown files in total;
- 508 reference files, including 252 scenario files.

Every source path was inventoried by owning skill and scenario family. Preventive lessons were already represented in the 44 Skills Hub instruction modules. This conversion adds the safe review workflow, source-to-sink reasoning, authorization/business-invariant analysis, independent-result triage, evidence gate, coverage routing, and concise reporting needed for a developer-invoked review.

### Scenario-family coverage

All 252 files below were inventoried by path. Their defensive lesson was distilled at the family level; payloads and operational attack steps were not copied.

| Owning Argus skill | Scenario files | Defensive review coverage |
|---|---:|---|
| `ai-ml-code-review` | 13 | Direct/indirect prompt injection, output sinks, poisoning, resource exhaustion, model supply chain, disclosure, RAG isolation, tool confused-deputy paths and LLM-as-authorization mistakes |
| `api-security` | 30 | GraphQL authorization, CSRF/content type, complexity/batching, federation/introspection; REST gateway, BOLA/BOPLA and mass assignment; WebSocket handshake/message authorization; LLM-backed API sinks |
| `authentication` | 48 | MFA enrollment/verification/recovery and races; JWT algorithm/key/claim validation; OAuth state, PKCE, redirect and scope binding; modern identity tenant/workload boundaries; resistance to credential attacks without reproducing them |
| `client-side` | 32 | DOM sinks, clobbering, postMessage, prototype pollution, framework escape hatches, XSS consequences and contextual prevention |
| `iac-security` | 13 | Cloud IAM/storage/serverless scope, container privilege, Kubernetes RBAC/GitOps/mesh/workload identity and secrets-manager policy, limited to static configuration evidence |
| `injection` | 23 | Code, SQL/NoSQL/CQL and second-order interpreter flows, reduced to binding, typing, allowlist and safe-API control analysis |
| `pci-secure-software` | 9 | Software composition, account data, POI/web/SDK applicability, cryptographic key management, sensitive assets and deployment modes without a formal compliance verdict |
| `server-side` | 34 | Native deserialization, file upload/storage, host trust, request parsing/smuggling boundaries, traversal and SSRF/redirect/address validation |
| `smart-contract-review` | 6 | Governance/timelock, bridge, flash-loan, MEV, oracle and reentrancy assumptions from source only |
| `web-app-logic` | 44 | Object/function access control, authoritative business values and workflows, cache key/path normalization, information exposure, state-machine and race/TOCTOU invariants |

## Conversion map

| Argus area | Review-pack result |
|---|---|
| `coordination`, `review-workflow` | Single-agent scope, source-first workflow, confirmation gate, coverage disclosure and report discipline |
| `codebase-intake`, `techstack-identification` | Read-only stack, entry-point, trust-boundary and artifact inventory using repository evidence |
| `source-code-scanning` | Independent source review before optional existing SARIF/diagnostic triage; source-to-sink tracing |
| `injection`, `client-side`, `server-side`, `authentication`, `api-security`, `web-app-logic` | Review coverage routed to existing cross-cutting preventive instructions; scenario families distilled into defensive trace questions |
| Language and framework review skills | Existing detected language/framework instructions are the reviewer’s dangerous-API and safe-pattern criteria |
| `ai-ml-code-review`, `smart-contract-review` | Conditional AI/ML and Solidity coverage tied to detected modules |
| `dependency-sca`, `malicious-code-review` | Manifest/lockfile/provenance and suspicious-code inspection; no live advisory lookup or package execution |
| `iac-security`, `cicd-security`, `firewall-review` | Static effective-scope analysis for cloud, container, K8s, edge, identity, network and pipeline configuration |
| `secrets-detection` | Manual source/config evidence with mandatory redaction; no credential validation and no unsupported full-history clearance |
| `pci-secure-software` | Risk-based payment/account-data review; no claim of a formal compliance assessment |
| `cve-risk-score` | Existing trusted advisory/CVSS evidence may be cited; no network lookup and no invented CVSS vector |
| `essential-tools` | Methodology retained; tool installation and execution removed |
| `github-workflow` | Current-change inspection only through VS Code’s read-only change tool; no branch/PR mutation |

The eight language skills (`python`, `javascript`, `java`, `go`, `ruby`, `php`, `rust`, and `csharp-dotnet`) and ten framework skills (Spring Boot, Django, Flask, Rails, Laravel, Express, Next.js, React, Vue/Nuxt, and Angular) map to the existing detected instruction modules. The six nested tech-stack identification skills collapse into the inventory phase. Argus coordinator, executor, skeptic, and finding/engagement-validator role lessons collapse into a single-agent workflow plus the separate `/validate-security-finding` prompt; no subagent execution is retained.

## Intentionally excluded

- `cve-poc-generator`, exploitation and payload instructions;
- password attacks, phishing, credential use, lateral movement and persistence;
- live endpoint, identity-provider, cloud, container, firewall or secret probing;
- scanner installation/execution, builds, tests, target executables and network access;
- subagent orchestration, autonomous continuation and disposable-VM assumptions;
- Argus engagement scaffolding, Python utilities, PDF/VRC generation and formal compliance verdicts;
- skill-maintenance operations from `skill-update`, `skill-prune` and `script-generator`.

These exclusions keep the developer version safe, predictable, portable, and non-disruptive. Missing dynamic or historical evidence is reported under `Needs verification` rather than inferred.

## Generated Copilot surfaces

| Surface | Purpose |
|---|---|
| `.github/agents/secure-code-review.agent.md` | Manually selected reviewer with only read-only VS Code tools |
| `.github/prompts/secure-code-review.prompt.md` | Scoped source/repository review |
| `.github/prompts/review-security-changes.prompt.md` | Current-change security regression review |
| `.github/prompts/validate-security-finding.prompt.md` | Independent confirmation/rejection of one claim |
| `.github/skills/secure-code-review-method/` | Progressively referenced workflow, coverage, evidence and report method |

The agent reads the generated repository-wide instruction and all path-specific instructions matching each reviewed file. This makes the existing Skills Hub guidance the primary source of expected secure behavior rather than maintaining a competing review checklist.
