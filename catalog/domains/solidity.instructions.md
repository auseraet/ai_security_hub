---
applyTo: "**/*.sol"
---

# Solidity and EVM secure development

- Define and test explicit invariants for authorization, asset conservation, accounting, upgradeability, pause/recovery, and external dependencies before implementation.
- Apply checks-effects-interactions and a proven reentrancy guard where callbacks can cross an invariant. Consider token hooks, fallback functions, cross-function, and read-only reentrancy.
- Restrict every privileged state change with an appropriate role/owner/governance check. Do not use `tx.origin` for authorization and do not assume a `private` value is confidential on-chain.
- Use Solidity 0.8+ checked arithmetic and constrain `unchecked` blocks with a demonstrated invariant. Handle precision, rounding direction, decimal conversion, and cast truncation deliberately.
- Check low-level call return values and bound gas/return-data handling where relevant. Avoid user-controlled `delegatecall`, implementation targets, and arbitrary call data under privileged context.
- Follow a reviewed proxy/upgrade pattern. Preserve storage layout, protect initializers, prevent implementation takeover, and make upgrade authority/timelock explicit.
- Use replay-protected typed structured signatures with chain ID, contract address, action, nonce, deadline, and signer/domain separation. Prefer audited signature libraries over raw `ecrecover`.
- Treat oracle inputs as adversarial: use manipulation-resistant sources, freshness/round checks, decimal normalization, bounds, and safe failure behavior. Do not trust a single instantaneous DEX spot price.
- Do not use block timestamp/hash, sender, or on-chain state as secure randomness. Use a reviewed verifiable-randomness/commit-reveal design appropriate to adversarial ordering.
- Protect against frontrunning/MEV where ordering changes outcomes using slippage/deadlines, commit-reveal, batch/auction design, or private flow as appropriate.
- Minimize external calls and privileged escape hatches. Pin audited library versions, compile reproducibly, and test with unit, invariant, fuzz, static, and upgrade/storage-layout checks.
- Make denial-of-service behavior explicit: avoid unbounded loops over growing storage, push payments, and a single external recipient that can block system progress.
