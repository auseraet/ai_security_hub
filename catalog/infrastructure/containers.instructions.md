---
applyTo: "**/Dockerfile,**/Dockerfile.*,**/*.dockerfile,**/docker-compose*.yml,**/docker-compose*.yaml,**/compose*.yml,**/compose*.yaml,**/.dockerignore"
---

# Container security

- Use a trusted minimal base pinned by immutable digest, with a documented update process. Prefer multi-stage builds and copy only required runtime artifacts.
- Run as a dedicated numeric non-root user with no unnecessary sudo/setuid binaries. Do not use `--privileged`, host PID/network, host devices, Docker socket, or added capabilities without an explicit need.
- Drop all capabilities then add the minimum; enable no-new-privileges, a read-only root filesystem, and constrained writable tmp/data mounts where the platform supports them.
- Never pass secrets through `ARG`, `ENV`, build command text, image layers, labels, or committed files. Use build/runtime secret mounts and ensure secret files are not copied from earlier stages.
- Keep package installation deterministic and minimal, verify downloads, remove package caches in the same layer, and do not curl remote scripts directly into a shell.
- Set a useful `.dockerignore` that excludes VCS metadata, credentials, local environments, test data, and unnecessary build context without hiding required provenance files.
- Expose only required ports and bind published development services deliberately. Do not bake production credentials, debug mode, or environment-specific trust into the image.
- Define health checks that reveal no secrets and cannot cause excessive load. Use exec-form `ENTRYPOINT`/`CMD`, correct signal handling, and bounded shutdown.
- Scan the final image and generate provenance/SBOM in delivery. Do not suppress a vulnerable base/runtime package without a scoped remediation decision.
- In Compose, avoid broad host mounts, host networking, privileged mode, plaintext secrets, and publicly bound databases/admin ports.
