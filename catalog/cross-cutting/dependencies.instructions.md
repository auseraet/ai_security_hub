---
applyTo: "**/package.json,**/package-lock.json,**/yarn.lock,**/pnpm-lock.yaml,**/requirements*.txt,**/pyproject.toml,**/poetry.lock,**/Pipfile*,**/pom.xml,**/build.gradle*,**/gradle.lockfile,**/go.mod,**/go.sum,**/Cargo.toml,**/Cargo.lock,**/Gemfile*,**/composer.json,**/composer.lock,**/*.csproj,**/packages.lock.json,**/Package.swift,**/Package.resolved,**/mix.exs,**/mix.lock"
---

# Dependencies and software supply chain

- Prefer the standard library or an already-approved dependency. Add the smallest maintained package that meets the requirement; do not suggest packages solely from a plausible name.
- Verify the package identity, official registry/source, maintainer/project provenance, release history, and license before adding it. Watch for typosquatting and dependency-confusion names.
- Pin reproducible direct and transitive versions using the ecosystem lockfile. Do not replace a lockfile with broad ranges or hand-edit resolved integrity data.
- Keep production dependencies separate from development/build tools. Avoid install/lifecycle scripts and packages with unnecessary filesystem, credential, or network behavior.
- Do not disable TLS, signature, checksum, or registry verification. Pin CI actions and downloaded build tools by immutable digest/commit and verify released artifacts.
- Choose a supported non-vulnerable version compatible with the project. If no fixed version exists, surface the risk and propose removal, isolation, or a reviewed compensating control instead of silently suppressing it.
- Preserve automated dependency and license scanning. Do not add blanket advisory ignores; scope any exception to the exact advisory/package/version with owner, rationale, and expiry.
- Remove unused dependencies and features. Treat model files, plugins, compiler extensions, containers, actions, Terraform modules, and vendored binaries as supply-chain dependencies too.
- Generate or retain an SBOM where the delivery process supports it. Ensure every manifest in a monorepo is included rather than scanning only the root.
