# Source inventory

Inventory completed on 22 July 2026. Content was used as direction, reconciled with current primary guidance, and converted into preventive instructions. No source document is copied into generated output.

## Security Guidelines (27 files)

| Source | Main catalog coverage |
|---|---|
| SaaS Integration Security Guidelines v0.1 | SaaS/webhooks, API, identity, logging |
| PHP Secure Guidelines v1.1 | PHP, Laravel/Symfony, WordPress/Drupal |
| ReactJS Security Guidelines v1.1 | React/Next, browser/web |
| Secrets Management Solutions Guidelines v1.0 | Core, auth, crypto, CI/CD, IaC |
| Secure Web Application Development/Deployment v0.2 | Browser/web, server-side, file, edge |
| WordPress Security Guidelines v1.1 | WordPress/Drupal, PHP |
| Java Security Guideline v1.0 | Java/Kotlin, Spring |
| Open Source Libraries Guidelines v0.3 | Dependencies and supply chain |
| Python Security Guideline v1.0 | Python and Python web frameworks |
| MFA for M2M Security Guidelines v1.0 | Workload identity, APIs, messaging |
| Anti-Bruteforce Techniques Guidelines v0.2 | Authentication and recovery |
| NodeJS Security Guideline v1.0 | JavaScript/TypeScript, Express/Nest |
| Hashing vs Encryption – Key Differences (two PPTX revisions) | Crypto and password-storage modernization |
| C and C++ Security Guideline v1.1 | C/C++ |
| DLL Security Guideline v1.1 | C/C++, .NET, supply-chain/search paths |
| MFA Security Guidelines v2.1 | Authentication, MFA, recovery |
| Secure Guidelines on Application Security | Core, web headers, crypto, dependencies |
| AngularJS Security Guidelines v1.2 | Angular and browser/web |
| Drupal Security Guidelines v1.2 | WordPress/Drupal, PHP |
| CMS Hardening: Drupal Security Guidelines | WordPress/Drupal, infrastructure |
| CMS Hardening: WordPress Security Guidelines | WordPress/Drupal, infrastructure |
| C# Security Guideline v1.0 | .NET and ASP.NET Core |
| Exposed HTTP Service Security Standard v1.2 | Edge, web, auth, logging |
| JavaScript Security Guideline v1.0 | JavaScript/TypeScript and browser/web |
| CSRF Explained | Browser/web and cookie-auth frameworks |
| CSRF v1.0 | Browser/web and cookie-auth frameworks |

The two hashing/encryption presentations count as two inventory files; related duplicate/variant web-deployment material was evaluated independently.

## Standards (7 files)

| Source | Main catalog coverage |
|---|---|
| Secure API Development Standard v1.1 | API, auth, authorization, limits, logging |
| Secure Web Development Standard v1.3 | Browser/web, sessions, CSRF, SSRF |
| Database Security Standards v1.0 | Database, data protection, infrastructure |
| Application Encryption Standard 1.4 | Crypto, passwords, TLS, keys |
| General Secure Software Development Standard v1.5 | Core and all cross-cutting modules |
| Secure Web Application Deployment Standard v1.0 | Edge, containers, Kubernetes, IaC |
| Secure Communications Standard 1.0 | Crypto, TLS, edge, service communication |

## Argus knowledge selected for preventive conversion

The review-oriented sources used were the vulnerability-class skills (`injection`, `server-side`, `client-side`, `authentication`, `api-security`, `web-app-logic`, `ai-ml-code-review`, `smart-contract-review`), all available per-language and per-framework security-review skills, and `dependency-sca`, `malicious-code-review`, `secrets-detection`, `iac-security`, `cicd-security`, `firewall-review`, and `pci-secure-software`.

Workflow, review orchestration, exploit demonstration, reporting, scanner execution, and CVE-scoring procedures were not copied into developer instructions because they do not guide construction and would add noise or offensive detail. Their underlying prevention lessons are represented where applicable.

The optional, manually invoked review experience now converts the safe portions of workflow and reporting into a read-only Copilot review pack. It still excludes exploit demonstration, scanner execution, live credential/CVE lookup, autonomous orchestration, and target mutation. See [Argus review-pack conversion](ARGUS_REVIEW_PACK.md).

See [Source mapping](SOURCE_MAPPING.md) for modernization decisions and [Reference baseline](REFERENCES.md) for current external guidance.
