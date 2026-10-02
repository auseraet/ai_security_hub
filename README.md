# AI Security Hub

AI Security Hub is a versioned security-customization marketplace for GitHub Copilot in VS Code, Copilot CLI, and Claude Code. One source catalog builds client-specific agents, skills, instructions, review commands, and hooks that can be installed across projects. VS Code applies native instruction patterns; other clients also receive a preventive skill with the same security content.

The catalog is intentionally adoption-oriented. It uses `MUST` only for controls that prevent a clear, high-confidence vulnerability, `SHOULD` for secure defaults, and conditional language where the correct control depends on architecture. Instructions ask Copilot to preserve intended behavior and avoid unrelated rewrites.

Developers should begin with the [developer quickstart](QUICKSTART.md). The [Copilot activation flow](docs/COPILOT_FLOW.md) shows exactly when instructions, prompts, the review agent, its internal skill, and read-only tools are used.

## Install the plugins

The repository follows the company project's two-marketplace distribution model. Copilot packages live under `plugins/`, Claude packages under `claude-plugins/`, and each client has its own marketplace manifest. A native VS Code Agent Plugins 1.0 variant remains available at the repository root.

| Client | Package | Marketplace |
|---|---|---|
| VS Code / Copilot CLI | `plugins/ai-security-hub` | `ai-security-hub-marketplace` |
| Claude Code | `claude-plugins/ai-security-hub` | `ai-security-hub-claude` |

See the [installation guide](docs/PLUGIN.md) for commands for each client, local testing, updates, and company-marketplace integration.

Use a current VS Code release supporting Agent Plugins 1.0 with GitHub Copilot enabled. Register this checkout in **Preferences: Open User Settings (JSON)**:

```json
{
  "chat.plugins.enabled": true,
  "chat.useHooks": true,
  "chat.pluginLocations": {
    "/absolute/path/to/ai_security_hub": true
  }
}
```

Use `C:/tools/ai_security_hub` or another absolute path on Windows. Open a trusted application workspace and start a new **Local** chat session. The plugin supplies all 44 security modules, the review agent, three review commands, the internal review skill, and a session-start reminder. Enable or disable it per workspace through **Chat: Open Customizations → Plugins**.

After these files are published to the remote, the repository can also be installed through **Chat: Install Plugin From Source** using `https://github.com/auseraet/ai_security_hub`, or through its included marketplace. See the [plugin installation and distribution guide](docs/PLUGIN.md) for Git installation, team recommendations, archives, updates, migration, and compatibility.

Maintainers can rebuild, check, and package with Node.js 22+, npm, Git, and `tar`:

```text
npm ci --ignore-scripts
npm run build
npm run validate
npm test
npm run package
```

Archives and SHA-256 checksums for the native, Copilot, Claude, and central-integration distributions are written to `dist/`. Generated files are committed so installation needs no build. Avoid enabling multiple variants or enabling a plugin alongside the Hub's generated `.github` customizations in the same workspace.

## Repository onboarding quick start

For teams that need committed `.github` files, including Copilot surfaces outside VS Code, the existing repository-copy installer remains available.

For plug-and-play onboarding, run the generator from the application repository root with no options. The enforced defaults select every catalog module, use path-specific output, and install the review pack:

```bash
/path/to/ai-security-hub/scripts/build.sh
```

```powershell
C:\path\to\ai-security-hub\scripts\build.ps1
```

The no-option command is equivalent to this explicit company policy:

```bash
/path/to/ai-security-hub/scripts/build.sh --preset full --mode path-specific
```

```powershell
C:\path\to\ai-security-hub\scripts\build.ps1 -Preset full -Mode path-specific
```

The two value-taking options in that command accept exactly these catalog-defined values:

```text
--preset baseline|web-service|cloud-service|ai-service|full
--mode   path-specific|universal

-Preset baseline|web-service|cloud-service|ai-service|full
-Mode   path-specific|universal
```

- `--preset full` / `-Preset full` selects all 44 catalog modules rather than relying on technology detection to make a module available.
- `--mode path-specific` / `-Mode path-specific` writes separate `.github/instructions/*.instructions.md` files. Copilot then uses each file's `applyTo` patterns to select relevant instructions for the files in the task.
- `--mode universal` / `-Mode universal` combines relevant selected modules into the repository-wide `.github/copilot-instructions.md`; use it only for Copilot surfaces that cannot consume path-specific files.
- Omitting both options uses `full` and `path-specific`. Automatic detection remains available for narrower presets and compatibility workflows.

The preset and mode tables in the [complete build script reference](#complete-build-script-reference) explain every value in detail.

This is an owner or central-automation operation, not a daily developer step. Commit the generated `.github/` files so that developers receive them with the application repository.

The target can also be supplied explicitly to generate instructions into another repository:

```bash
./scripts/build.sh --target /path/to/project --preset full
```

Or from PowerShell:

```powershell
.\scripts\build.ps1 -Target C:\path\to\project -Preset full
```

The Bash implementation requires Bash 4+ and `jq` 1.6+. The PowerShell implementation uses native JSON support and works with Windows PowerShell 5.1+ or PowerShell 7+. They generate byte-equivalent output.

The default `path-specific` mode writes:

```text
.github/
├── copilot-instructions.md
└── instructions/
    └── *.instructions.md
```

Technology-specific instructions are detected from the target repository. Repository owners can add an exceptional module or choose another preset when needed:

```bash
./scripts/build.sh --target /path/to/project --preset web-service
./scripts/build.sh --target /path/to/project --include ai-ml,saas-webhooks
./scripts/build.sh --list
```

For an IDE that only supports repository-wide instructions, generate a single portable file:

```bash
./scripts/build.sh --target /path/to/project --preset baseline --mode universal
```

Existing instruction files are never overwritten unless they were generated by AI Security Hub or `--force` is supplied. Preview a change with `--dry-run`.

PowerShell uses the equivalent `-Mode`, `-Include`, `-Exclude`, `-Force`, and `-DryRun` parameters.

Keep repository-specific build, test, architecture, and style guidance in `.github/ai-security-hub-local.md`. The generator appends that unmanaged file to the generated repository-wide instructions, so local context survives catalog updates. Existing unrelated path-specific instruction files are also left untouched.

## Complete build script reference

Both implementations use equivalent defaults and generate byte-equivalent output:

```text
./scripts/build.sh [options]
& ".\scripts\build.ps1" [parameters]
```

Selection is evaluated as `preset + detected + included - excluded`. The `core` module is mandatory, and the review pack is always installed.

| Purpose | Bash | PowerShell | Accepted value and behavior |
|---|---|---|---|
| Target repository | `--target DIR` | `-Target PATH` | Existing directory other than the filesystem root. Default: current directory (`.`). |
| Preset | `--preset NAME` | `-Preset NAME` | `baseline`, `web-service`, `cloud-service`, `ai-service`, or `full`. Default: `full`. |
| Output mode | `--mode MODE` | `-Mode MODE` | `path-specific` or `universal`. Default: `path-specific`. |
| Add modules | `--include IDS` | `-Include IDS` | Catalog module IDs. Bash accepts comma-separated IDs and repeated options; PowerShell accepts a string array or comma-separated string. Explicitly included modules do not depend on detection. |
| Remove modules | `--exclude IDS` | `-Exclude IDS` | Catalog module IDs in the same formats as `include`. Exclusion wins over every other selection source. `core` cannot be excluded. |
| Disable detection | `--no-detect` | `-NoDetect` | Use only preset and explicit selections. This is a value-free switch. |
| Replace unmanaged collisions | `--force` | `-Force` | Allow replacement of an existing file at an AI Security Hub-managed output path when it was not generated by AI Security Hub. Reconcile useful content before using it. This is a value-free switch. |
| Preview | `--dry-run` | `-DryRun` | Report planned writes and removals without changing files. Mutually exclusive with `check`. |
| Drift check | `--check` | `-Check` | Make no changes; exit `0` when current, `1` for drift, and `2` for an input or processing error. Mutually exclusive with `dry-run`. |
| List modules | `--list` | `-List` | Print module groups, IDs, descriptions, and detection status, then exit. |
| Help | `--help` or `-h` | No AI Security Hub help parameter | Bash prints command usage. Use `Get-Help .\scripts\build.ps1` for PowerShell syntax. |

PowerShell standard common parameters are also accepted because `build.ps1` is an advanced script, but they do not control AI Security Hub selection or output. The script does not implement `-WhatIf`.

### Presets

| Value | Meaning |
|---|---|
| `baseline` | `core` plus API, authentication, authorization/business logic, browser, cryptography, data/database, dependencies, event/messaging, file handling, logging/privacy, secrets/configuration, SaaS/webhook, and server-side controls |
| `web-service` | `baseline` plus `ci-cd`, `containers`, and `reverse-proxy` |
| `cloud-service` | `baseline` plus `ci-cd`, `containers`, `iac-cloud`, `kubernetes`, and `reverse-proxy` |
| `ai-service` | `web-service` plus `ai-ml` |
| `full` | Every catalog module. `path-specific` emits every instruction file; `universal` embeds modules detected, explicitly included, or applicable to existing repository files. |

Detection remains active with every preset unless `no-detect` is supplied. A `baseline` build can therefore add Java, Spring, C#, ASP.NET, C/C++, CMS, or other technology modules when repository evidence matches.

### Output modes

| Value | Meaning |
|---|---|
| `path-specific` | Writes `.github/copilot-instructions.md` plus `.github/instructions/<id>.instructions.md`. Supported Copilot surfaces use `applyTo` globs to select relevant instructions. This is the recommended VS Code default. |
| `universal` | Combines the core and relevant selected module bodies into `.github/copilot-instructions.md`. Use it for a surface that cannot consume path-specific files; embedded modules then share repository-wide context. |

### Module IDs accepted by `include` and `exclude`

- Core: `core`
- Cross-cutting: `api`, `authentication`, `authorization-business-logic`, `browser-web`, `cryptography`, `data-database`, `dependencies`, `event-messaging`, `file-handling`, `logging-privacy`, `secrets-configuration`, `saas-webhooks`, `server-side`, `ai-ml`
- Languages: `c-cpp`, `csharp-dotnet`, `go`, `java-kotlin`, `javascript-typescript`, `php`, `python`, `ruby`, `rust`, `shell-powershell`, `swift`
- Frameworks: `angular`, `aspnet-core`, `django-flask-fastapi`, `express-nest`, `laravel-symfony`, `mobile`, `next-react`, `rails`, `spring`, `vue-nuxt`, `wordpress-drupal`
- Infrastructure: `ci-cd`, `containers`, `iac-cloud`, `kubernetes`, `reverse-proxy`
- Domains: `payment-card`, `solidity`

Run `./scripts/build.sh --list` or `.\scripts\build.ps1 -List` to obtain the authoritative list from the installed catalog version.

### Representative commands

```bash
# Defaults: current repository, full, path-specific
./scripts/build.sh

# Install all modules but let applyTo select them in VS Code
./scripts/build.sh --preset full --mode path-specific

# Preview an explicit selection without automatic detection
./scripts/build.sh --preset baseline --no-detect \
  --include java-kotlin,spring --exclude browser-web --dry-run

# CI drift check, module listing, and Bash help
./scripts/build.sh --check
./scripts/build.sh --list
./scripts/build.sh --help
```

```powershell
# Defaults: current repository, full, path-specific
& ".\scripts\build.ps1"

# Install all modules but let applyTo select them in VS Code
& ".\scripts\build.ps1" -Preset full -Mode path-specific

# Preview an explicit selection without automatic detection
& ".\scripts\build.ps1" -Preset baseline -NoDetect `
    -Include "java-kotlin","spring" -Exclude "browser-web" -DryRun

# CI drift check, module listing, and PowerShell syntax
& ".\scripts\build.ps1" -Check
& ".\scripts\build.ps1" -List
Get-Help ".\scripts\build.ps1"
```

`force` is intentionally absent from routine examples. Use `--force` or `-Force` only after inspecting the collision and preferably previewing the replacement with `dry-run`.

## Design

- `plugin.json` identifies the Agent Plugins 1.0 package and its release version.
- `plugins/` and `claude-plugins/` contain company-style Copilot and Claude packages; `.claude-plugin/marketplace.json` registers the Claude distribution.
- `skills/` and `com.github.copilot/` contain generated, installable customizations; `.github/plugin/marketplace.json` makes the repository a plugin marketplace.
- `plugin/hooks/` contains the source for the session-start reminder.
- `scripts/plugin.mjs` builds, checks, and packages the plugin using the existing catalog and review pack.
- `catalog/core/` contains the compact baseline used in every generated repository.
- `catalog/**.instructions.md` contains native GitHub Copilot path-specific instructions.
- `catalog/catalog.json` defines discovery signals, presets, and output ordering.
- `review-pack/` contains the manually invoked, read-only secure-code-review agent, prompts, skill, and references.
- `scripts/build.sh` and `scripts/build.ps1` detect a target stack and generate Copilot-compatible files without Python.
- `scripts/validate.sh` and `scripts/validate.ps1` check the catalog, review pack, frontmatter, presets, and generated output.
- `docs/` explains adoption, authoring, compatibility, and source traceability.
- `QUICKSTART.md` explains the zero-configuration developer experience.

## Developer-invoked security review

Every generated repository receives a dormant review pack. In VS Code, developers can select the **Secure Code Review** agent or run `/secure-code-review`, `/review-security-changes`, or `/validate-security-finding` from Copilot Chat. The reviewer is limited to read-only search/change/problem tools and returns evidence-backed findings in chat. It does not edit code, run commands or scanners, use the network, reproduce secrets, or generate exploit payloads.

The reviewer reads the generated repository-wide instructions and all path-specific instructions applicable to the reviewed files before applying the distilled Argus method. See [Argus review-pack conversion](docs/ARGUS_REVIEW_PACK.md).

Preventive instructions are automatic during supported Copilot requests. The agent and prompts are deliberately manual because they perform a deeper review that would add latency if invoked during every coding interaction. The internal review skill is loaded by the agent and is not a separate developer command.

Start with [Adoption](docs/ADOPTION.md), then read [Authoring](docs/AUTHORING.md) before changing instruction content. The [Source inventory](docs/SOURCE_INVENTORY.md) and [Source mapping](docs/SOURCE_MAPPING.md) record what informed the catalog and what was deliberately modernized.

## Important boundary

Copilot instructions influence suggestions; they are not an enforcement control and can be disabled or changed in a branch. Retain branch protection, code review, SAST, SCA, secret scanning, IaC scanning, and security tests. See [Security model](docs/SECURITY_MODEL.md).

## Validation

Plugin checks run identically in Bash and PowerShell after `npm ci --ignore-scripts`:

```text
npm run validate
npm test
```

Repository installer checks:

```bash
./scripts/validate.sh
./tests/test-build.sh
./scripts/build.sh --target . --preset full --mode path-specific --check
```

```powershell
.\scripts\validate.ps1
.\tests\Test-Build.ps1
.\scripts\build.ps1 -Target . -Preset full -Mode path-specific -Check
```

This repository and its source mappings are intended for internal use.
