# Authoring instructions

## Purpose and voice

Write preventive implementation guidance for Copilot, not an audit checklist and not an attack playbook. Each instruction should help generate a safe implementation at the moment a relevant file is changed.

Use direct language:

- Good: `Use bound parameters for every data value.`
- Good: `When identifiers cannot be bound, map an allowed external value to a fixed identifier.`
- Avoid: `Check for SQL injection.`
- Avoid: payloads, exploit walkthroughs, product-specific absolutes without context, or long background explanations.

Preserve developer flow. Ask for the smallest relevant secure change, prefer existing framework controls, and do not direct Copilot to refactor unrelated code.

## Normative strength

- Use `MUST`/`MUST NOT` only when the unsafe alternative directly creates a high-confidence vulnerability or violates a firm company requirement across the module's scope.
- Use `SHOULD` for the secure default when architectures can have equally safe alternatives.
- State the precondition when a control is conditional: for example, CSRF protection for cookie-authenticated state changes, not every stateless API.
- Avoid arbitrary numeric thresholds unless a current policy mandates them. Ask the project to choose a risk-appropriate bound and ensure one exists.

The core defines conflict behavior. Do not repeat severity language in every module.

## File format

Repository-wide content lives under `catalog/core/` without frontmatter. Path-specific modules must be named `NAME.instructions.md` and begin with:

```markdown
---
applyTo: "**/*.example,**/relevant/**"
---
```

Use comma-separated GitHub glob patterns. Test top-level and nested paths. Keep patterns narrow enough that unrelated technologies do not receive the module. Framework modules must also have a detection rule in `catalog/catalog.json` whenever file extensions alone are ambiguous.

Each path module must:

- Be self-contained because multiple matching files can combine.
- Start with one H1 title and contain at least five actionable bullets.
- Stay below 500 words; prefer 200–350.
- Avoid references to local source-document paths in generated guidance.
- Avoid secrets, internal endpoints, real exploit payloads, personal data, and confidential operational details.

## Adding or changing a module

1. Identify the trust boundary and desired secure construction behavior.
2. Check current primary guidance and the relevant internal standard/review knowledge.
3. Resolve outdated or conflicting guidance explicitly in `SOURCE_MAPPING.md`.
4. Add/update the native instruction file and its `catalog/catalog.json` record.
5. Add focused detection and generator tests where the technology is new.
6. Run validation and tests.
7. Generate both modes against a small representative fixture and inspect what Copilot will receive.

```bash
./scripts/validate.sh
./tests/test-build.sh
./scripts/build.sh --target /tmp/example --dry-run
```

```powershell
.\scripts\validate.ps1
.\tests\Test-Build.ps1
.\scripts\build.ps1 -Target $env:TEMP\skills-hub-example -DryRun
```

Changes to generation behavior must remain equivalent in Bash and PowerShell. The cross-platform test compares their complete `.github` output byte for byte.

## Review checklist

- Is every absolute statement true in the declared path scope?
- Does the guidance distinguish authentication, authorization, validation, sanitization, and encoding correctly?
- Does it account for write paths, object/tenant scope, asynchronous paths, and alternate entry points?
- Does it avoid security-by-obscurity and scanner-only thinking?
- Does it preserve standard framework protections rather than proposing custom security code?
- Would the instruction still be current after a minor framework/runtime upgrade?
- Is a safe exception or compensating-control path clear without encouraging bypass?
- Does it add less friction than the vulnerability it prevents?
