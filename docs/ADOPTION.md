# Adoption guide

## Recommended rollout

Use the centrally enforced `full` preset in `path-specific` mode for VS Code/Visual Studio and GitHub Copilot code review. This installs every catalog module while allowing `applyTo` globs to select relevant instructions at request time. Pilot it with representative teams, review suggestions and friction weekly, then expand. Use `universal` mode only for JetBrains, Xcode, or another Copilot surface that consumes a single repository-wide file.

The adoption contract is:

- Instructions apply to code being changed and do not request unrelated rewrites.
- `MUST` is reserved for a clear high-confidence vulnerability boundary.
- `SHOULD` allows an equally safe project pattern or justified architecture choice.
- Conflicts are surfaced for a human decision rather than resolved by silently weakening security.
- Existing framework protections are preferred over extra custom code.

These choices make suggestions useful enough to keep enabled. Measure false positives, unnecessary code churn, repeated developer overrides, and security defects prevented or caught in review. Refine the smallest relevant module rather than making the core baseline longer.

## Plug-and-play distribution model

Developers should not select presets, technologies, or instruction modules. They should clone or pull an onboarded application repository, open its root in VS Code, and use Copilot normally. Repository-wide instructions and applicable path-specific instructions are then considered automatically by supported Copilot requests. The deeper review agent and prompts remain manually invoked to avoid adding latency to ordinary coding.

The central Skills Hub repository is not inherited automatically by every application repository. Organization onboarding automation must generate and commit the customization files into each application repository. From the application repository root, the normal command requires no options:

```bash
/path/to/skills-hub/scripts/build.sh
```

```powershell
C:\path\to\skills-hub\scripts\build.ps1
```

Both implementations default to the current repository, the `full` preset, `path-specific` mode, and review-pack installation. Every module is therefore available without depending on stack detection. Detection remains supported for explicitly selected narrower presets; technology-specific flags are exceptions for repository owners, not part of the developer workflow.

For organization-wide use:

1. Pin a reviewed Skills Hub release or tag in central onboarding automation.
2. Run the default generator against each application repository.
3. Open a normal pull request containing the generated `.github/` files.
4. Re-run generation when the Skills Hub version or repository stack changes.
5. Run `--check` or `-Check` in CI to detect drift without modifying the repository.

This makes the application repository self-contained for developers and allows Copilot to discover its customizations without a per-developer script, extension, or technology choice. See the [developer quickstart](../QUICKSTART.md) and [Copilot activation flow](COPILOT_FLOW.md).

## Choose an output mode

| Mode | Output | Best fit | Trade-off |
|---|---|---|---|
| `path-specific` | Core `.github/copilot-instructions.md` plus `.github/instructions/*.instructions.md` | VS Code, Visual Studio, Copilot cloud agent/code review | Precise and low-noise; some IDEs currently ignore path files |
| `universal` | One `.github/copilot-instructions.md` | JetBrains, Xcode, mixed/unknown IDE estate | Broad compatibility; applicable detected modules share the context |

GitHub's current documentation states that VS Code and Visual Studio support repository-wide and path-specific files. JetBrains and Xcode support a single repository-wide file. On GitHub.com, path-specific files are currently used by Copilot cloud agent and Copilot code review. Recheck the [official support documentation](https://docs.github.com/en/copilot/reference/custom-instructions-support) during each catalog review because Copilot surfaces evolve.

## Install into a repository

Preview first:

```bash
./scripts/build.sh --target /path/to/repository --preset full --mode path-specific --dry-run
```

Generate and review the resulting diff:

```bash
./scripts/build.sh --target /path/to/repository --preset full --mode path-specific
git -C /path/to/repository diff -- .github
```

On Windows, use the native equivalent:

```powershell
.\scripts\build.ps1 -Target C:\path\to\repository -Preset full -Mode path-specific -DryRun
.\scripts\build.ps1 -Target C:\path\to\repository -Preset full -Mode path-specific
git -C C:\path\to\repository diff -- .github
```

Detection adds matching language, framework, infrastructure, AI, mobile, and smart-contract modules. Add or remove an exceptional module explicitly:

```bash
./scripts/build.sh \
  --target /path/to/repository \
  --preset cloud-service \
  --include ai-ml \
  --exclude browser-web
```

Use `--no-detect` only when a repository owner wants a fully explicit module list. Use `--force` only after manually reconciling existing custom instructions; it allows replacing a file that Skills Hub does not own.

If a repository already has useful repository-wide instructions, move its project-specific build, test, architecture, and style guidance to `.github/skills-hub-local.md`. Skills Hub appends that unmanaged content to the generated `.github/copilot-instructions.md` in both modes. Do not duplicate security rules there or use it to weaken a central `MUST`; propose a catalog change or documented exception instead. Existing path-specific files with names not managed by Skills Hub remain untouched.

## Keep generated output current

The generator records its catalog version, selected modules, mode, and managed files in `.github/.skills-hub.json`. A CI job can check for drift without changing the repository:

```bash
/path/to/skills-hub/scripts/build.sh \
  --target . \
  --preset full \
  --mode path-specific \
  --check
```

```powershell
C:\path\to\skills-hub\scripts\build.ps1 -Target . -Preset full -Mode path-specific -Check
```

For reproducible organization-wide updates, invoke a pinned Skills Hub release/tag from the onboarding automation rather than an arbitrary working tree. Roll changes through normal pull requests and make instruction owners reviewers of `.github/copilot-instructions.md`, `.github/instructions/`, and `.github/.skills-hub.json`.

## Verify Copilot is using the files

In a supported Copilot Chat surface, request a change in a file covered by one of the instructions and expand the response's references. Confirm `.github/copilot-instructions.md` and, where supported, the matching `.instructions.md` file are listed. Test at least one safe behavior and one rejected/alternative behavior, such as a parameterized query versus query concatenation.

Do not validate by asking Copilot to recite confidential policy. Use a small test repository and observable code behavior. Repeat verification after Copilot extension upgrades and changes to instruction format support.

## Verify the manual review experience

In VS Code Copilot Chat, confirm that **Secure Code Review** appears in the agent picker and that `/secure-code-review`, `/review-security-changes`, and `/validate-security-finding` appear as prompts. Run `/review-security-changes` against a small controlled change and verify that the response references the review method plus the repository-wide and matching path-specific instructions.

The agent must remain read-only: it should report a suggested correction in chat rather than edit files, run a terminal command, install a scanner, or access the network. A candidate without a complete source-to-sink, authorization, business-invariant, dependency, or configuration proof must appear under `Needs verification`, not as a confirmed finding.

## Prevent removal without creating resentment

- Keep the baseline short and make technology guidance path-specific or detected.
- Publish the rationale and accept concrete developer feedback with examples.
- Route true exceptions through time-bound documented risk acceptance rather than forcing awkward code.
- Use CODEOWNERS/branch protection to require review of generated instruction changes, not to hide them from developers.
- Keep enforcement in CI and review. Instructions should help developers reach the policy, not pretend to be the policy gate.
- Track removals and opt-outs as product feedback. Investigate noisy modules before escalating governance.

Copilot code review reads instructions from the pull request's head branch. A branch can therefore change or remove its own guidance; protected review and CI must detect security-impacting changes independently.
