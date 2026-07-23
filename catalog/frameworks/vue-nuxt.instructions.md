---
applyTo: "**/*.vue,**/nuxt.config.js,**/nuxt.config.ts,**/plugins/**/*.js,**/plugins/**/*.ts,**/middleware/**/*.js,**/middleware/**/*.ts"
---

# Vue and Nuxt security

- Use interpolation for text. Avoid `v-html`; when rich HTML is required, sanitize with a maintained allowlist immediately before the directive.
- Do not compile user-controlled templates, enable a runtime compiler without need, or bind arbitrary external values to dynamic components. Map choices to a fixed component set.
- Validate URL schemes/origins for links, resources, redirects, and router navigation. Avoid inserting raw HTML through refs or third-party DOM plugins.
- Treat Vue/Nuxt route middleware and Pinia/Vuex role flags as UX only. Enforce authorization at server routes and data access.
- Do not place secrets/tokens in runtime public config, serialized Nuxt payload/state, stores persisted to web storage, markup, or source maps.
- Return only required fields from server data hooks and API routes. Prevent personalized SSR/ISR output from entering a shared cache.
- Prefer secure HttpOnly session cookies for browser auth and protect cookie-authenticated state changes from CSRF.
- Check exact origin/source/schema for `postMessage` and isolate third-party components/iframes with the minimum sandbox/permissions.
- Keep production devtools, detailed error overlays, and unneeded server/debug routes disabled; constrain image/proxy/fetch destinations and response sizes.
