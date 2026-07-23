---
applyTo: "**/*.c,**/*.h,**/*.cc,**/*.cpp,**/*.cxx,**/*.hh,**/*.hpp,**/*.hxx"
---

# C and C++ secure coding

- Prefer memory-safe standard containers, views, strings, smart pointers, RAII, and checked algorithms over raw allocation, pointer arithmetic, C strings, and manual ownership.
- Validate all external lengths, counts, offsets, enum values, and integer conversions before allocation or access. Check for overflow/underflow before arithmetic and before narrowing or signed/unsigned conversion.
- Keep size and buffer types consistent (`size_t` where appropriate). Pass destination capacity explicitly and verify both source and terminator fit; avoid `strcpy`, `strcat`, `sprintf`, `gets`, and unbounded scanning.
- Do not use freed, moved-from, uninitialized, out-of-scope, or invalidated iterator/pointer state. Establish one clear owner and make lifetime visible in the type system.
- Use `std::span`, `std::string_view`, and references only while the backing storage is guaranteed alive. Do not return views/references to temporary or local data.
- Treat format strings as constants. Pass untrusted text as data, not as the format; use type-safe formatting APIs.
- Avoid invoking a shell. Pass a fixed executable and separated arguments through a platform process API, and validate any option-like values.
- Use checked filesystem APIs and race-resistant file creation. Avoid predictable temporary names, unsafe search paths, DLL/shared-library preloading, and time-of-check/time-of-use authorization.
- Minimize `unsafe` equivalents: casts, unions, variadic functions, inline assembly, custom allocators, and FFI. Document and test the invariant at each unavoidable boundary.
- Enable project hardening and warnings (stack protection, fortification, control-flow protections, ASLR/PIE, non-executable memory, sanitizers in tests) without weakening them for convenience.
- Use thread-safe ownership and synchronization; hold the lock across the complete invariant and avoid double-checked state unless the memory model makes it correct.
- Clear secrets with a platform guaranteed-zeroization API when required; an ordinary `memset` may be optimized away. Never log raw memory containing secrets.
