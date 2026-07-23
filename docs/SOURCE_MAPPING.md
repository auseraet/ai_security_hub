# Source mapping and modernization record

The source material provides direction and internal expectations. AI Security Hub translates it into short preventive instructions; it does not copy documents verbatim. Current primary guidance and secure framework defaults take precedence where older material is unsafe or obsolete.

## Internal standards and guidelines

| Source area | AI Security Hub modules |
|---|---|
| General Secure Software Development Standard | `core`, `authentication`, `authorization-business-logic`, `data-database`, `file-handling`, `logging-privacy`, `server-side` |
| Secure Web Development / Deployment / Exposed HTTP Service | `browser-web`, `server-side`, `authentication`, `reverse-proxy`, `containers`, `kubernetes` |
| Secure API Development Standard | `api`, `authentication`, `authorization-business-logic`, `event-messaging`, `saas-webhooks` |
| Database Security Standard | `data-database`, `cryptography`, `logging-privacy`, `iac-cloud` |
| Application Encryption / Secure Communications / Hashing vs Encryption | `cryptography`, `authentication`, `reverse-proxy` |
| Secrets Management | `core`, `secrets-configuration`, `authentication`, `cryptography`, `ci-cd`, `containers`, `iac-cloud`, language modules |
| Anti-Bruteforce / MFA / MFA M2M | `authentication`, `api`, `saas-webhooks`, `event-messaging` |
| Open Source Libraries | `dependencies`, `ci-cd`, `containers`, `iac-cloud`, `ai-ml` |
| SaaS Integration | `saas-webhooks`, `api`, `authentication`, `logging-privacy`, `cryptography` |
| C/C++, C#, Java, JavaScript, NodeJS, PHP, Python | matching language and framework modules |
| AngularJS, ReactJS | `angular`, `next-react`, `browser-web`, `javascript-typescript` |
| WordPress, Drupal, CMS hardening | `wordpress-drupal`, `php`, `reverse-proxy` |
| CSRF guidance | `browser-web` and cookie-authenticated framework modules |
| DLL security | `c-cpp`, `csharp-dotnet`, `ci-cd` supply-chain/search-path guidance |
| Application Security General Guidelines | `core`, `browser-web`, `cryptography`, `dependencies`, `logging-privacy` |

All documents under the supplied `Security Guidelines/` and `Standards/` collections were inventoried, including DOCX, PDF, and PPTX material. Document titles/versions remain in the source collection and are not redistributed here.

## Argus review knowledge converted to prevention

| Argus knowledge | Preventive modules |
|---|---|
| `injection` | Core plus language/framework query, command, template, expression, XML, LDAP, and spreadsheet-export instructions |
| `server-side` | `server-side`, `file-handling`, language/framework modules |
| `client-side` | `browser-web`, Angular/React/Vue/JavaScript instructions |
| `authentication` | `authentication`, `reverse-proxy`, framework session/identity instructions |
| `api-security` | `api`, `authorization-business-logic`, `event-messaging`, `ai-ml` |
| `web-app-logic` | `authorization-business-logic`, API/framework modules |
| `ai-ml-code-review` | `ai-ml`, `api`, `dependencies` |
| `smart-contract-review` | `solidity` |
| `pci-secure-software` | `payment-card` plus core, cryptography, dependency, logging, and delivery controls |
| Per-language and per-framework review skills | Matching language/framework instruction modules |
| `dependency-sca` / `malicious-code-review` | `dependencies`, `ci-cd`, `containers`, `iac-cloud` |
| `iac-security` / `cicd-security` | All infrastructure modules |
| `secrets-detection` | `secrets-configuration`, core, and secret-handling guidance across every relevant module |

Offensive payloads and review procedures were intentionally excluded. They were reduced to construction rules that prevent the source-to-sink condition.

For the manually invoked source-review capability, safe workflow and evidence procedures are separately distilled into the generated Copilot agent, prompts, and `secure-code-review-method` skill. The preventive modules remain the reviewer's primary control expectations. See [Argus review-pack conversion](ARGUS_REVIEW_PACK.md) for coverage and exclusions.

## Deliberate modernizations

| Older direction | AI Security Hub decision |
|---|---|
| Direct SHA-256/SHA-2 password hashing | Use a password KDF: Argon2id preferred, otherwise approved scrypt/bcrypt/PBKDF2; support rehash migration |
| Fixed password composition, periodic rotation, and restrictive maximum length | Support long password-manager-friendly values; avoid composition/rotation unless current explicit policy requires it |
| Encrypting password databases as the password-storage control | Hash passwords with a password KDF; storage encryption remains defense in depth for other data |
| `POST` only updates and `PUT` only creates | Use current HTTP semantics: POST processes/creates, PUT replaces at a known URI, PATCH partially updates |
| UUIDs prevent API object access | Opaque IDs reduce enumeration only; enforce object-level authorization |
| Bind session/token security to IP/user-agent | Use secure session lifecycle and risk signals; avoid brittle binding that breaks legitimate users/proxies |
| Browser local storage as an ordinary bearer-token location | Prefer protected backend/HttpOnly-cookie sessions where suitable |
| New cookie after any invalid cookie | Reject invalid state and use framework session rotation; never adopt attacker-supplied identifiers |
| `autocomplete=off` for credentials | Support password managers and modern browser behavior; focus on transport, storage, MFA, and recovery |
| Sanitizing every input and Base64 as protection | Validate at boundaries, bind data to interpreters, and encode at the final output context; Base64 is not security |
| Non-default ports as database protection | Do not rely on obscurity; use network policy, identity, TLS, least privilege, and monitoring |
| Static browser versions and legacy cipher lists | Require supported clients and maintained TLS 1.2+/1.3 profiles; avoid freezing obsolete version/cipher inventories in code guidance |
| Email/SMS/location or multiple knowledge checks described as MFA | Prefer phishing-resistant factors; do not count two factors from one category or IP location as MFA |
| M2M “MFA” based on combinations of static credentials and IP | Use workload identity, short-lived scoped tokens, mTLS/request signing, protected keys, replay controls, and network policy |
| Always block/archive types by extension | Validate purpose/content and isolate processing; apply archive limits and scanning according to risk |
| Framework/library lists tied to old runtime versions | Prefer current maintained platform APIs and organization-approved libraries without hardcoding obsolete versions |

These decisions should be revisited during every major catalog review and whenever company policy is updated.
