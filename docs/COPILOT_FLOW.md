# GitHub Copilot activation flow

This diagram separates central repository onboarding from developer-time Copilot behavior. Technology selection is deterministic during generation; instruction applicability is automatic during a supported Copilot request; the deeper source-code review workflow remains explicitly developer-invoked.

```mermaid
flowchart TB
    subgraph onboarding["Central onboarding or catalog update — no developer action"]
        hub["Versioned Skills Hub catalog<br/>preventive modules + review pack"]
        repository["Application repository<br/>source, manifests, configuration"]
        generator["Bash or PowerShell generator<br/>default: full + path-specific"]
        detection["Detect languages, frameworks,<br/>infrastructure, and conditional domains"]
        generated["Generate managed .github files"]
        delivery["Review and commit through a pull request"]

        hub --> generator
        repository --> generator
        generator --> detection
        detection --> generated
        generated --> delivery
    end

    subgraph artifacts["Files delivered with the application repository"]
        core["copilot-instructions.md<br/>repository-wide secure baseline"]
        path["instructions/*.instructions.md<br/>narrow applyTo globs"]
        prompts["prompts/*.prompt.md<br/>three developer commands"]
        agent["agents/secure-code-review.agent.md<br/>manual read-only reviewer"]
        skill["skills/secure-code-review-method/SKILL.md<br/>internal review procedure"]
        references["Skill references<br/>workflow, coverage, evidence, report"]
        state[".skills-hub.json<br/>version, mode, modules, managed files"]

        generated --> core
        generated --> path
        generated --> prompts
        generated --> agent
        generated --> skill
        generated --> state
        skill --> references
    end

    delivery --> open["Developer pulls and opens<br/>the repository root in VS Code"]
    open --> request{"Normal coding request<br/>or explicit security review?"}

    subgraph normal["Normal coding — automatic, no Skills Hub command"]
        coding["Copilot receives the request<br/>and relevant file context"]
        matcher["Evaluate path instruction<br/>applyTo globs against task files"]
        codingContext["Injected request context:<br/>repository baseline + matching path instructions"]
        suggestion["Copilot proposes code or guidance<br/>using the applicable secure defaults"]

        coding --> matcher
        core --> codingContext
        path --> matcher
        matcher --> codingContext
        codingContext --> suggestion
    end

    request -->|Normal coding| coding

    subgraph review["Security review — explicitly invoked"]
        invoke{"Developer selects the agent<br/>or enters a review prompt"}
        reviewAgent["Secure Code Review agent"]
        instructionRead["Read repository-wide and all matching<br/>path-specific security instructions"]
        methodRead["Load internal review skill and<br/>only relevant references"]
        tools["Allowed read-only VS Code tools:<br/>changes, codebase, usages, problems"]
        evidence["Trace source, control, decision,<br/>sink, configuration, and impact"]
        report["Evidence-backed report in chat<br/>Confirmed / Needs verification / Rejected"]

        invoke -->|Slash prompt sets agent and scope| reviewAgent
        invoke -->|Direct agent selection| reviewAgent
        prompts --> invoke
        agent --> reviewAgent
        reviewAgent --> instructionRead
        core --> instructionRead
        path --> instructionRead
        reviewAgent --> methodRead
        skill --> methodRead
        references --> methodRead
        reviewAgent --> tools
        instructionRead --> evidence
        methodRead --> evidence
        tools --> evidence
        evidence --> report
    end

    request -->|Explicit review| invoke

    blocked["Not available to the review agent:<br/>edits, terminal, builds, scanners,<br/>package installation, network, exploit payloads"]
    reviewAgent -. blocked boundary .-> blocked
```

## Activation rules

| Surface | When it is used | What it supplies or calls |
|---|---|---|
| Repository-wide instruction | Automatically for supported Copilot requests in the repository | Compact secure-development baseline |
| Path-specific instruction | Automatically when its `applyTo` glob matches a file involved in the task | Language, framework, infrastructure, domain, or cross-cutting controls |
| Prompt | Only when a developer enters its slash command | Scope and task text; selects the **Secure Code Review** agent |
| Secure Code Review agent | Only when selected directly or by one of the review prompts | Read-only operating boundary, evidence standard, instructions, skill, and allowed tools |
| Secure-code-review skill | Internally when the review agent follows its linked method | Workflow, review coverage, evidence validation, and report format |
| Skill reference | Progressively, when relevant to the active review | Detailed method guidance without loading every reference into every request |
| Read-only VS Code tools | At the review agent's discretion within the selected scope | Current changes, code search, usage search, and existing problems |

## Important boundaries

- The central Skills Hub repository is not automatically visible to Copilot in every application. Generated customization files must be delivered into each application repository, normally by central automation and a pull request.
- Automatic stack detection happens when the generator runs. If a repository later adds a technology, rerun the generator so its module becomes available.
- At request time, Copilot uses the generated repository-wide instruction and applicable path modules. Developers do not choose the technology manually.
- Prompts are entry points, not passive policy. They invoke the read-only agent only when a developer asks for a deeper review.
- The internal review skill is not a developer command and is not used during ordinary coding. The review agent follows it explicitly.
- Instructions influence Copilot behavior; they do not replace branch protection, human review, SAST, SCA, secret scanning, security tests, or runtime controls.

For the developer workflow, see the [quickstart](../QUICKSTART.md). For deployment and updates, see the [adoption guide](ADOPTION.md).
