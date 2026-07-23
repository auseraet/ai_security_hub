---
applyTo: "**/*.py,**/*.pyi"
---

# Python secure coding

- Never pass untrusted data to `eval`, `exec`, `compile`, dynamic imports, or user-constructed template source. Use explicit parsers and dispatch maps.
- Do not unpickle or unmarshal untrusted data. Use JSON/data-only formats with schema validation; use `yaml.safe_load` for untrusted YAML and constrain size/depth.
- Run a fixed executable with `subprocess.run([...], shell=False, check=True, timeout=...)`. Do not compose a shell command; `shlex.quote` is not a substitute for an argument-array design.
- Use ORM filters or DB-API bound parameters. Never use f-strings/formatting in SQL, `.raw`, `.extra`, `RawSQL`, dynamic identifiers, or sort fragments.
- Keep Jinja/Django template source static and pass values separately. Autoescape prevents some output XSS but does not make user-controlled template source safe.
- Use `secrets` for tokens and secret choices, `hmac.compare_digest` where secret comparison is needed, and maintained cryptography/password-hashing APIs.
- Validate URL scheme, hostname, resolved address, port, redirects, and response size before server-side fetches. Set connect/read timeouts.
- Generate upload names, use safe path resolution and base-directory confinement, and validate content independently of filename and request MIME type.
- Use dedicated request/response models with runtime validation. Pydantic/dataclass/type hints do not provide authorization; explicitly scope database access to the actor/tenant.
- Keep framework debug modes and interactive consoles off outside local development. Return generic errors and log redacted exceptions.
- Bound request bodies, parsing, regex, decompression, task queues, multiprocessing, recursion, and collection sizes. Propagate cancellation/timeouts to external calls.
- Do not disable TLS verification, suppress security warnings globally, or hardcode Flask/Django signing keys and credentials.
