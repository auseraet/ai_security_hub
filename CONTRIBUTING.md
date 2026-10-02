# Contributing

Read [Authoring](docs/AUTHORING.md) and [Security model](docs/SECURITY_MODEL.md) before changing catalog content.

The catalog, `review-pack/`, and `plugin/` remain authoritative. After changing shipped customizations, run `npm run build`; do not hand-edit `agents/`, `skills/`, `com.github.copilot/`, `plugins/`, or `claude-plugins/`. See [plugin maintenance](docs/PLUGIN.md) for installation, optional pre-commit regeneration, and central integration.

All plugin changes must pass these cross-platform checks (Node.js 22+):

```text
npm ci --ignore-scripts
npm run build
npm run validate
npm test
```

Bump `plugin.json`, update `CHANGELOG.md`, and commit generated output for each plugin release. After committing, run `npm run plugin:check-versions -- --base origin/main` against the intended base. CI enforces version synchronization and rejects stale output.

Every change must preserve client formats and read-only review permissions, stay preventive rather than offensive, avoid confidential data, and pass:

```bash
./scripts/validate.sh
./tests/test-build.sh
```

```powershell
.\scripts\validate.ps1
.\tests\Test-Build.ps1
```

For material policy changes, include the source/rationale, affected modules and presets, compatibility impact, generated-output examples for both modes, and a developer-experience review.
