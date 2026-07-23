---
applyTo: "**/*.rb,**/*.rake,**/*.erb"
---

# Ruby secure coding

- Use Active Record/query placeholders or safe ORM APIs. Never interpolate input into SQL, `where`, `order`, `find_by_sql`, or raw fragments; allowlist dynamic sort/column values.
- Keep ERB/template source and view names static. Do not use `render inline:` with request data, and do not mark untrusted values `html_safe` or pass them to `raw`.
- Do not load untrusted `Marshal` or unsafe YAML objects. Prefer JSON and `YAML.safe_load` with the smallest permitted class set when necessary.
- Avoid `eval`, `class_eval`, user-controlled `send`/`constantize`, and dynamic method/class selection. Map allowed external names to fixed operations.
- Invoke a fixed command with separated arguments (`system(command, arg...)` or a suitable library). Avoid backticks and interpolated shell strings.
- Use explicit strong-parameter allowlists. Never use `permit!` or allow role, ownership, tenant, price, approval, or administrative fields from ordinary requests.
- Use `SecureRandom` for secrets and framework password/token APIs. Keep `secret_key_base`, credentials keys, and service secrets out of source and logs.
- Preserve CSRF protection for cookie-authenticated state changes; only exempt truly stateless token-authenticated endpoints with equivalent origin/auth controls.
- Authorize record ownership/tenant and action after loading the target, including Active Storage blobs, nested attributes, background jobs, and admin paths.
- Validate outbound URLs and resolved addresses, apply time/size limits, and do not use `URI.open` on arbitrary input.
- Generate upload/storage names, verify base-directory confinement, and avoid public-by-default blob access.
- Keep detailed exception pages and consoles out of production; bound jobs, regex, parsing, collections, and retries.
