# 2026-09-08 — Open-source DLT agent frameworks deep research

**Triggering request:** User asked to run `deep-book-research` for "open-source frameworks facilitating public DLT usage for agentic factories like ElizaOS" and to integrate the findings into `src/special-use-cases/dlt-sw-factories.md`.

**Seed:**
- The chapter file `src/special-use-cases/dlt-sw-factories.md` itself — already covers public DLT fundamentals, why agentic factories would use them, network choice, and identity/payment protocols (x402, EIP-7702/ERC-7715, ERC-8004, AP2, MPP, W3C DID/VC), but has no coverage of the open-source agent-framework layer (e.g. ElizaOS) that developers actually build these crypto-native agents with.
- `notes/initial-notes/dlt-and-sw-factories-1.md` lines ~17 and ~141–208 — a prior Gemini chat's claims about ElizaOS's plugin architecture and its multichain support (`@elizaos/plugin-sui`, `@elizaos/plugin-aptos`, `@elizaos/plugin-evm` on IOTA EVM, GOAT/LayerZero bridging for non-EVM IOTA), flagged for verification rather than direct reuse.
- Prior research pass `notes/2026-09-04-1-dlt-sw-factories-public-dlt-agentic-factories/` (protocols/networks for this same chapter) — consulted for house style and citation conventions, not re-researched.

**Subtopics targeted (explicit, in order):**
1. ElizaOS itself — origins/governance/maturity, plugin architecture, chain support (EVM, Solana, Move-based: Sui/Aptos/IOTA), agent-to-agent payments/treasury management, adoption evidence, known limitations/criticisms.
2. Other comparable open-source frameworks in the same space (e.g. GAME by Virtuals Protocol, Olas/Autonolas framework tooling, Rig, others) — which are genuinely comparable vs. merely adjacent.
3. Common architectural pattern across these frameworks — how multi-chain wallet management, transaction signing, and agent-to-agent value transfer are abstracted as a reusable plugin/tool layer on an LLM-driven agent loop.
4. Evidence quality — single-source vs. corroborated claims, marketing copy vs. independent fact, retrieval-dated activity metrics (GitHub stars etc.).
