---
applyTo: "**/k8s/**/*.yml,**/k8s/**/*.yaml,**/kubernetes/**/*.yml,**/kubernetes/**/*.yaml,**/charts/**/*.yaml,**/templates/**/*.yaml,**/Chart.yaml,**/values*.yaml"
---

# Kubernetes and Helm security

- Set pod/container security contexts: non-root numeric user/group, `allowPrivilegeEscalation: false`, read-only root filesystem where possible, seccomp `RuntimeDefault`, and drop all capabilities before minimal additions.
- Do not use privileged containers, host namespaces, hostPath, Docker/container-runtime sockets, host ports, or unrestricted device access without an explicit reviewed requirement.
- Use a dedicated service account per workload and set `automountServiceAccountToken: false` unless the pod calls the API. Grant namespaced RBAC verbs/resources only as required; avoid wildcards and secret read.
- Apply default-deny ingress and egress NetworkPolicies, then allow required peers/ports. Remember policies require a supporting CNI and do not replace application auth/TLS.
- Keep secrets out of manifests, values, ConfigMaps, annotations, and command arguments. Use the approved external-secret/sealed-secret mechanism with restricted RBAC and rotation.
- Pin images by digest from an approved registry, enforce signature/provenance policy where available, and prevent mutable tags or unexpected registries.
- Set CPU/memory/ephemeral-storage requests and limits plus safe probe/timeouts. Bound autoscaling and disruption behavior to avoid trivial denial of service.
- Configure Ingress/Gateway TLS, trusted forwarded headers, body/time limits, and internal/admin exposure deliberately. Do not expose dashboards, metrics, or debug endpoints publicly.
- Separate sensitive tenants/environments with namespaces plus policy, not namespace names alone. Use Pod Security Admission/enforcement appropriate to the workload.
- In Helm, quote/type values safely, avoid `tpl` over untrusted values, validate required security settings, and make secure defaults survive an omitted values file.
