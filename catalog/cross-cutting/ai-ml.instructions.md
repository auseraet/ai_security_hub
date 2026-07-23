---
applyTo: "**/ai/**,**/ml/**,**/models/**,**/prompts/**,**/agents/**,**/rag/**,**/*prompt*.*,**/*embedding*.*,**/*llm*.*,**/*.ipynb"
---

# AI, ML, and LLM integration security

- Treat user input, retrieved documents, web content, tool output, memory, metadata, and model output as untrusted data. A prompt delimiter or instruction saying to ignore attacks is not a security boundary.
- Keep system/developer instructions separate from untrusted content using the model API's roles/structured fields. Clearly label provenance, but assume prompt injection can still succeed.
- Never place secrets, privileged credentials, unnecessary personal data, or inaccessible source material in prompts, embeddings, traces, fine-tuning data, or model-visible tool results.
- Authorize retrieval before returning documents and before adding them to model context. Enforce tenant/ACL filters in the data query, not only in the prompt, and preserve source provenance.
- Give tools narrow, task-specific schemas and least privilege. Require server-side authorization and validation for each tool call; never let the model decide its own permissions.
- Require human confirmation for high-impact or irreversible actions. Bind confirmation to the exact actor, target, parameters, and current state; do not treat model prose as approval.
- Validate model output for the destination context before rendering, querying, executing, or persisting it. Never pass model output directly to a shell, `eval`, SQL, templates, or security decisions.
- Constrain tokens, input/document size, retrieval count, iterations, tool calls, concurrency, time, and cost. Handle partial output, timeouts, and retries without duplicating actions.
- Load models and adapters only from trusted, pinned, integrity-verified sources. Prefer safe tensor/data formats; never deserialize untrusted pickle/joblib/native model objects.
- Defend training, fine-tuning, evaluation, and RAG ingestion with source approval, validation, deduplication, access controls, poisoning checks, and lineage.
- Log model and tool activity for audit using redacted metadata. Do not log raw prompts/responses by default; define retention and access appropriate to their sensitivity.
- Make safety and policy checks deterministic outside the model for authorization, financial limits, compliance, and data release. Test direct/indirect injection, cross-tenant retrieval, unsafe output, tool abuse, and resource exhaustion.
