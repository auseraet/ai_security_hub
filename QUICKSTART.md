# Developer quickstart

AI Security Hub gives GitHub Copilot secure-development context without requiring developers to choose a technology, module, or security checklist. Install the VS Code agent plugin once to use it across projects, or consume the generated `.github` files supplied by your repository owner.

Copilot CLI and Claude Code packages are also available through separate marketplaces. Follow the [client installation guide](docs/PLUGIN.md). They receive the same policy content through a preventive skill; Claude skill activation differs from VS Code's automatic file-pattern rules. Supply a diff when the reviewer's read-only tools cannot expose current changes.

## Start with the VS Code plugin

1. Follow the [plugin installation guide](docs/PLUGIN.md) to register a local checkout or install from Git/the included marketplace.
2. Open the application workspace, enable the plugin, and start a new **Local** chat session. The session-start hook reminds Copilot to use the security guidance.
3. Code normally. The baseline and rules matching the task's files provide preventive guidance.
4. For a deeper review, select **Secure Code Review** or choose one of the plugin's review commands from the `/` menu. The review skill remains internal to this workflow.

No generator runs in the application repository. The plugin guide includes team recommendations, versioned archives, update instructions, and steps to verify that VS Code loaded the customizations.

The remaining sections describe the **repository-copy installation**. If your repository already uses it, disable the plugin for that workspace until the team migrates to avoid duplicate customizations.

## What a developer needs

- A current VS Code installation with GitHub Copilot and Copilot Chat enabled.
- A Copilot-enabled company account.
- The application repository opened at its repository root in a trusted VS Code workspace.
- AI Security Hub files already committed under the application's `.github/` directory.

Developers do not run the AI Security Hub generator during normal work. Repository onboarding and catalog updates should be performed centrally and delivered through ordinary pull requests.

## Start coding

1. Clone or pull the application repository.
2. Open the application repository root in VS Code.
3. Use Copilot Chat, edits, or agent-based code generation as usual.
4. Review and test the result as normal.

For supported Copilot requests:

- `.github/copilot-instructions.md` supplies the compact secure-development baseline.
- Files under `.github/instructions/` are selected automatically when their `applyTo` glob matches a file involved in the task.
- Unrelated technology modules are not intended to enter the request context.
- No slash command is required for these preventive instructions.

For example, work on a JavaScript API route can activate the repository baseline plus the JavaScript/TypeScript and API instruction files. Work on a Terraform file activates the baseline plus applicable infrastructure guidance instead. The generator selects which technology modules exist in the repository; Copilot selects from those installed modules by file applicability at request time.

## Run an optional security review

The deeper source-code review workflow is deliberately manual so that it does not interrupt ordinary coding or add review latency to every request.

Use one of these options in Copilot Chat:

| Developer action | Use it for |
|---|---|
| Select **Secure Code Review** from the agent picker | A conversational, scoped security review |
| `/review-security-changes` | The normal daily review of current source-control changes |
| `/secure-code-review src/component` | A selected file, folder, component, or repository scope |
| `/validate-security-finding claim and location` | Independent confirmation, rejection, or identification of missing evidence for one claim |

Start with `/review-security-changes` for routine development. Scope larger reviews to a component rather than repeatedly reviewing an entire monorepo.

The review agent:

- Reads the repository-wide and matching path-specific secure-development instructions.
- Loads the internal secure-code-review method and only the references needed for the review.
- Uses read-only VS Code change, code search, usage search, and problem-inspection tools.
- Reports evidence-backed findings in chat.
- Does not edit files, open a terminal, run builds or scanners, install packages, use the network, reproduce secrets, or create exploit payloads.

## Confirm that customization is available

In VS Code Copilot Chat:

1. Confirm that **Secure Code Review** appears in the agent picker.
2. Type `/` and confirm that the three AI Security Hub prompts appear.
3. Ask Copilot for a focused change in a file covered by an instruction.
4. Expand the response's references or used-context section, when the current VS Code version exposes it.
5. Confirm that the repository-wide instructions and the matching path-specific instruction are used or reflected in the proposed code.

Test behavior rather than asking Copilot to repeat company policy. A database test should produce parameter binding rather than query concatenation; an authorization test should use the authenticated actor and persisted object rather than trusting client-supplied ownership.

The internal `secure-code-review-method` skill should not appear as a developer command. The selected review agent loads it when a review is explicitly requested.

## If the repository has not been onboarded

Repository owners or central automation can install AI Security Hub without selecting technologies or presets. Run the appropriate generator from the application repository root:

```bash
/path/to/ai-security-hub/scripts/build.sh
```

```powershell
C:\path\to\ai-security-hub\scripts\build.ps1
```

The no-option command uses the enforced maximum-coverage policy. Its explicit form is:

```bash
/path/to/ai-security-hub/scripts/build.sh --preset full --mode path-specific
```

```powershell
C:\path\to\ai-security-hub\scripts\build.ps1 -Preset full -Mode path-specific
```

The accepted values are:

```text
--preset baseline|web-service|cloud-service|ai-service|full
--mode   path-specific|universal

-Preset baseline|web-service|cloud-service|ai-service|full
-Mode   path-specific|universal
```

- `full` selects all 44 catalog modules and avoids depending on stack detection to make Java, Spring, C#, C/C++, CMS, or another module available.
- `path-specific` writes separate instruction files and lets Copilot select them using each file's `applyTo` patterns. This is the recommended mode for VS Code.
- `universal` merges relevant selected modules into one repository-wide instruction file for Copilot surfaces without path-specific support.
- With no values supplied, the scripts default to `full` and `path-specific`. Automatic detection remains available when a narrower preset is selected explicitly.

The complete meaning of every preset and mode appears in the [build script option reference](#build-script-option-reference).

With no arguments, both implementations:

1. Target the current repository.
2. Use the `full` preset so every catalog module is available.
3. Use precise `path-specific` instructions.
4. Detect languages, frameworks, infrastructure, and conditional domains from repository evidence.
5. Install the generated instructions and the read-only review pack.
6. Record the selected modules and managed files in `.github/.ai-security-hub.json`.

Review and commit the resulting `.github/` changes. Developers receive them on their next clone or pull. A central onboarding workflow or bot should perform this step across the company and open update pull requests when the AI Security Hub version or repository stack changes.

## Build script option reference

The Bash and PowerShell implementations have equivalent generation behavior. Bash requires Bash 4+ and `jq` 1.6+; PowerShell uses native JSON support and supports Windows PowerShell 5.1+ and PowerShell 7+.

```text
/path/to/ai-security-hub/scripts/build.sh [options]
& "C:\path\to\ai-security-hub\scripts\build.ps1" [parameters]
```

Module selection follows this rule:

```text
selected modules = preset modules + automatically detected modules + explicitly included modules - explicitly excluded modules
```

`core` is mandatory and cannot be excluded. The generated review pack is always enabled; neither script has an option to disable it.

| Purpose | Bash | PowerShell | Accepted value and meaning |
|---|---|---|---|
| Target repository | `--target DIR` | `-Target PATH` | Existing repository directory other than the filesystem root. Default: current directory (`.`). |
| Preset | `--preset NAME` | `-Preset NAME` | One of `baseline`, `web-service`, `cloud-service`, `ai-service`, or `full`. Default: `full`. Presets are described below. |
| Output mode | `--mode MODE` | `-Mode MODE` | `path-specific` or `universal`. Default: `path-specific`. |
| Add modules | `--include IDS` | `-Include IDS` | One or more catalog module IDs. Bash accepts a comma-separated value and allows the option to be repeated. PowerShell accepts a string array or comma-separated string. Explicit inclusion overrides a detection miss. |
| Remove modules | `--exclude IDS` | `-Exclude IDS` | One or more catalog module IDs in the same formats as `include`. Exclusion wins over the preset, detection, and inclusion. Excluding `core` is rejected. |
| Disable detection | `--no-detect` | `-NoDetect` | Select only the preset and explicit inclusions, minus exclusions. No value is supplied to this switch. |
| Replace unmanaged collisions | `--force` | `-Force` | Permit replacement of an existing file at an AI Security Hub-managed path even when it was not generated by AI Security Hub. Reconcile useful content first. No value is supplied. |
| Preview | `--dry-run` | `-DryRun` | Print files that would be written or removed without changing the target. Cannot be combined with `check`. |
| Drift check | `--check` | `-Check` | Make no changes; exit `0` when generated output is current, `1` when drift exists, and `2` for an input or processing error. Cannot be combined with `dry-run`. |
| List modules | `--list` | `-List` | Print catalog module IDs, groups, descriptions, and detection status, then exit without generating files. |
| Command help | `--help` or `-h` | No AI Security Hub help parameter | Bash prints its usage and exits. For PowerShell syntax, use `Get-Help C:\path\to\ai-security-hub\scripts\build.ps1`; the build parameters are the ones in this table. |

PowerShell also exposes standard common parameters because the script is an advanced script. They do not select AI Security Hub modules or output modes, and the script does not implement `-WhatIf`.

### Preset values

| Preset | Modules selected before automatic detection |
|---|---|
| `baseline` | `core` plus API, authentication, authorization/business logic, browser, cryptography, data/database, dependencies, event/messaging, file handling, logging/privacy, secrets/configuration, SaaS/webhook, and server-side guidance |
| `web-service` | Everything in `baseline`, plus `ci-cd`, `containers`, and `reverse-proxy` |
| `cloud-service` | Everything in `baseline`, plus `ci-cd`, `containers`, `iac-cloud`, `kubernetes`, and `reverse-proxy` |
| `ai-service` | Everything in `web-service`, plus `ai-ml` |
| `full` | Every catalog module. In `path-specific` mode this installs every path instruction and lets `applyTo` select at request time. In `universal` mode the generator embeds selected modules that were detected, explicitly included, or applicable to files already in the repository. |

Automatic detection remains enabled for every preset unless `no-detect` is supplied. For example, `baseline` still adds `java-kotlin` and `spring` when their evidence is found.

### Output mode values

| Mode | Result | Recommended use |
|---|---|---|
| `path-specific` | Writes the core baseline to `.github/copilot-instructions.md` and each selected path module to `.github/instructions/<id>.instructions.md`. Copilot can apply only instructions whose `applyTo` glob matches task files. | VS Code, Visual Studio, and other surfaces supporting path-specific instructions; recommended company default |
| `universal` | Writes one `.github/copilot-instructions.md` containing the core and the relevant selected module bodies. Those embedded modules share repository-wide context because their path frontmatter is removed. | Copilot surfaces that consume only a repository-wide instruction file |

### Accepted module IDs

Use these values with `include` or `exclude`; `list` prints the authoritative catalog from the installed AI Security Hub version.

- Core: `core`
- Cross-cutting: `api`, `authentication`, `authorization-business-logic`, `browser-web`, `cryptography`, `data-database`, `dependencies`, `event-messaging`, `file-handling`, `logging-privacy`, `secrets-configuration`, `saas-webhooks`, `server-side`, `ai-ml`
- Languages: `c-cpp`, `csharp-dotnet`, `go`, `java-kotlin`, `javascript-typescript`, `php`, `python`, `ruby`, `rust`, `shell-powershell`, `swift`
- Frameworks: `angular`, `aspnet-core`, `django-flask-fastapi`, `express-nest`, `laravel-symfony`, `mobile`, `next-react`, `rails`, `spring`, `vue-nuxt`, `wordpress-drupal`
- Infrastructure: `ci-cd`, `containers`, `iac-cloud`, `kubernetes`, `reverse-proxy`
- Domains: `payment-card`, `solidity`

### Common Bash examples

```bash
# Default plug-and-play generation: full + path-specific
/path/to/ai-security-hub/scripts/build.sh

# Preview maximum path-specific coverage
/path/to/ai-security-hub/scripts/build.sh --preset full --dry-run

# Generate into another repository and compensate for nonstandard Spring detection
/path/to/ai-security-hub/scripts/build.sh \
  --target /path/to/application \
  --preset baseline \
  --include spring

# Select deterministically without repository stack detection
/path/to/ai-security-hub/scripts/build.sh \
  --preset baseline \
  --no-detect \
  --include java-kotlin,spring \
  --exclude browser-web

# Generate a single portable instruction file
/path/to/ai-security-hub/scripts/build.sh --mode universal

# Check committed generated output in CI
/path/to/ai-security-hub/scripts/build.sh --check

# Inspect valid module IDs or command syntax
/path/to/ai-security-hub/scripts/build.sh --list
/path/to/ai-security-hub/scripts/build.sh --help
```

Use `--force` only after reconciling an unmanaged file that occupies a generated path. Combine it with `--dry-run` first to inspect the planned replacement.

### Common PowerShell examples

```powershell
# Default plug-and-play generation: full + path-specific
& "C:\path\to\ai-security-hub\scripts\build.ps1"

# Preview maximum path-specific coverage
& "C:\path\to\ai-security-hub\scripts\build.ps1" -Preset full -DryRun

# Generate into another repository and compensate for nonstandard Spring detection
& "C:\path\to\ai-security-hub\scripts\build.ps1" `
    -Target "C:\path\to\application" `
    -Preset baseline `
    -Include "spring"

# Select deterministically without repository stack detection
& "C:\path\to\ai-security-hub\scripts\build.ps1" `
    -Preset baseline `
    -NoDetect `
    -Include "java-kotlin","spring" `
    -Exclude "browser-web"

# Generate a single portable instruction file
& "C:\path\to\ai-security-hub\scripts\build.ps1" -Mode universal

# Check committed generated output in CI
& "C:\path\to\ai-security-hub\scripts\build.ps1" -Check

# Inspect valid module IDs or PowerShell syntax
& "C:\path\to\ai-security-hub\scripts\build.ps1" -List
Get-Help "C:\path\to\ai-security-hub\scripts\build.ps1"
```

Use `-Force` only after reconciling an unmanaged file that occupies a generated path. Combine it with `-DryRun` first to inspect the planned replacement.

## Troubleshooting

- **No agent or prompts:** update VS Code and the Copilot extensions, verify workspace trust and company Copilot policy, open the application repository root, and reload the VS Code window.
- **An expected instruction is absent:** inspect `.github/.ai-security-hub.json`, confirm that the technology module was detected, and verify that the target file matches the instruction's `applyTo` pattern.
- **Current-change review is unexpectedly large:** create a Git baseline first; the review sees the current source-control change set.
- **The review agent asks to edit or run a terminal:** stop the action and report it as a configuration defect. The generated agent must remain read-only.
- **A new technology was added:** rerun the generator or let central automation open an update pull request. Copilot cannot load a catalog module that has not yet been generated into the application repository.

See the [Copilot activation flow](docs/COPILOT_FLOW.md) for the complete onboarding and runtime sequence, and the [adoption guide](docs/ADOPTION.md) for organization-wide rollout.
