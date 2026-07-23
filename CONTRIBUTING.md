# Contributing

Read [Authoring](docs/AUTHORING.md) and [Security model](docs/SECURITY_MODEL.md) before changing catalog content.

Every change must preserve native GitHub Copilot format, stay preventive rather than offensive, avoid confidential data, and pass:

```bash
./scripts/validate.sh
./tests/test-build.sh
```

```powershell
.\scripts\validate.ps1
.\tests\Test-Build.ps1
```

For material policy changes, include the source/rationale, affected modules and presets, compatibility impact, generated-output examples for both modes, and a developer-experience review.
