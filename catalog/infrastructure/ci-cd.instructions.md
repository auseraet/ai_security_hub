---
applyTo: "**/.github/workflows/*.yml,**/.github/workflows/*.yaml,**/.gitlab-ci.yml,**/Jenkinsfile,**/azure-pipelines*.yml,**/azure-pipelines*.yaml,**/.circleci/config.yml,**/bitbucket-pipelines.yml"
---

# CI/CD pipeline security

- Treat pipeline definitions as privileged executable code. Give tokens, OIDC roles, environments, runners, and secrets the minimum permissions and lifetime required per job.
- In GitHub Actions declare top-level/job `permissions` explicitly, defaulting to read-only. Pin third-party actions to a reviewed full commit SHA and retain an update mechanism.
- Never interpolate PR titles, branch names, issue bodies, commit messages, matrix values, or other untrusted context directly into a shell script. Pass them through a quoted environment/input channel and validate as data.
- Do not combine a privileged trigger (`pull_request_target`, `workflow_run`, protected branch job) with checkout or execution of untrusted fork/PR content.
- Keep secrets out of command lines, artifacts, caches, logs, generated files, and jobs that run untrusted code. Masking is not a security boundary; scope secrets to protected environments/jobs.
- Constrain cloud OIDC trust by organization, repository, ref/environment, audience, and workflow as supported. Avoid wildcard subjects and long-lived fallback cloud keys.
- Prefer ephemeral isolated runners. Do not run public/untrusted contributions on persistent self-hosted runners with network or credential access.
- Download from fixed HTTPS origins, verify signature/checksum, pin container images by digest, and never use `curl | sh`, disabled TLS checks, or mutable `latest` tags for privileged tooling.
- Separate build, test, sign, and deploy trust. Protect artifact provenance/integrity and ensure deployment consumes the exact reviewed artifact, not a rebuilt mutable source.
- Preserve SAST, SCA, secret, IaC, and artifact checks. Scope suppressions precisely with rationale/owner/expiry; do not make security jobs non-blocking merely to pass a pipeline.
- Quote platform expressions safely, set timeouts/concurrency, avoid writeable cross-trust caches, and prevent untrusted artifact names/paths from escaping the workspace.
