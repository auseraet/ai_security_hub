---
applyTo: "**/settings.py,**/urls.py,**/views.py,**/serializers.py,**/schemas.py,**/routers.py,**/wsgi.py,**/asgi.py"
---

# Django, Flask, and FastAPI security

- Use framework request/schema validation with dedicated DTOs, then perform explicit authorization. Serializers/Pydantic validate shape, not ownership or permission.
- Keep SQL in ORM filters or bound parameters. Avoid interpolated `.raw`, `.extra`, `RawSQL`, cursors, and dynamic sort/column fragments.
- Keep template source static and preserve autoescape. Do not pass untrusted values to `mark_safe`, `|safe`, or `render_template_string` as template source.
- Keep `DEBUG`/interactive Werkzeug debugger off and secret/signing keys external in every non-local environment. Configure trusted hosts and proxy headers explicitly.
- Preserve Django CSRF middleware/decorators for cookie-authenticated state changes. In Flask/FastAPI, add the framework-equivalent CSRF protection when cookies authenticate requests.
- In Django REST Framework/FastAPI dependencies/Flask Blueprints, ensure authentication and permission checks cover every router/blueprint and run before protected handlers.
- Generate upload names and confine storage. Use Django storage or Werkzeug-safe filename handling as one layer, then verify content and authorization.
- Configure secure session/CSRF cookie flags and session rotation. Do not rely on Flask client-side signed session contents for secrets or authorization without server revalidation.
- Return generic production errors, restrict admin/docs/metrics endpoints, and avoid serializing entire model objects or secret fields.
- Bound request bodies, multipart parts, pagination, query cost, background tasks, and outbound HTTP; set timeouts and avoid blocking async FastAPI handlers.
