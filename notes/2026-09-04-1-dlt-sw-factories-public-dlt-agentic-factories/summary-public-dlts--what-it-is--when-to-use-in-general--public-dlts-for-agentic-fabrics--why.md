# Summary — Public DLT-leveraged agentic software factories

Distilled index of [raw-public-dlts--what-it-is--when-to-use-in-general--public-dlts-for-agentic-fabrics--why.md](raw-public-dlts--what-it-is--when-to-use-in-general--public-dlts-for-agentic-fabrics--why.md). **This summary is a navigation aid, not a substitute** — exact figures, quotes, and citation links must be pulled from the raw file, not copied from here.

## Per-subtopic findings (sourcing-confidence tagged)

1. **Public DLTs (umbrella)** — 🟢 permissionless vs. permissioned/consortium distinction, consensus/finality, programmable VMs (EVM/MoveVM/SVM) are all well-corroborated, primary-sourced framing. Straightforward, no controversy.

2. **What it is** — 🟢/🟡 "blockchain" ⊂ "DLT" distinction is primary-sourced. Three chain families matter for later sections: account-based EVM (Ethereum/Base/Gnosis), object-centric Move (Sui, and IOTA since May 2025), account-based Move (Aptos, Block-STM parallelism). ❌ **Correction**: seed chat 1's claim that ElizaOS agents "execute PTBs" on Aptos is wrong — PTB is Sui/IOTA-specific terminology, Aptos has no such mechanism.

3. **When to use in general** — 🟢 balanced, vendor-neutral criteria (mutually distrusting parties, censorship-resistance, public verifiability vs. throughput/cost/simplicity). **Research Note carried into the raw file**: substantial critical literature (CIO.com, a peer-reviewed Journal of Operations Management study, Forbes, the TradeLens case study) converges on most 2017–2022 enterprise blockchain pilots failing for non-technical, coordination reasons — "solution in search of a problem" is a fair characterization. This critique should appear in the chapter, not just the pro-DLT case.

4. **Public DLTs for Agentic Fabrics (why, general)** — 🟢 core argument (crypto keypair as a payable/authenticatable identity independent of KYC'd banking rails) is well-corroborated. Named-entity verification results:
   - 🟢 Skyfire — real, active, exited beta March 2025.
   - 🟢 Coinbase Developer Platform "Agentic Wallets" — real and more developed than the seed chat implied (MPC, session caps, native x402, MCP-server interface, open-source `agentkit`).
   - 🟢 Fireblocks Policy Engine — real, spend limits/allowlists/time windows enforced at custody layer.
   - 🟠 "The Grid" — **mischaracterized in seed chat 2**. It's a Web3 project *directory*, not itself a bonding-curve funding platform; that pattern exists elsewhere (e.g. Berry Launchpad), found *via* The Grid's listings.
   - 🟢 Fortanix — real, current (Armet AI + NVIDIA confidential-computing GPUs), but it's a confidential-computing layer, not a DLT.
   - 🟢 Autonolas/Olas — real, active, bigger than the seed chat suggested (18.7M+ cumulative transactions across 8 chains as of an Aug-2026 tracker, ~96% on Gnosis Chain).
   - 🟢/🟡 Fetch.ai/ASI Alliance — real but the seed chat's framing is dated; by 2026 the Alliance ships ASI:One, ASI-1, ASI:Cloud, and a new ASI:Chain L1 (targeting mainnet late 2026/2027), with a FET→ASI rebrand still in flight.

5. **Why, specifically for Software Fabrics** — mixed confidence, important nuance:
   - ❌ ERC-721/1155-for-build-artifacts — the token standards are real, but no evidence anyone tokenizes builds/PRs this way. Flag as speculative extrapolation, not practice.
   - 🟠 "LangChain-brain / DLT-backbone" hybrid orchestration — sound engineering logic (keep non-deterministic LLM work off-chain, use the ledger only for atomic settlement), but **not documented anywhere as a named pattern** — appears to be the seed chat's own reasoning, not sourced. Present as reasoned inference, explicitly flagged as uncorroborated.
   - 🟢 Code provenance / paying agents per SDLC contribution is the strongest part — but the evidence lives in the *protocols* (ERC-8004, x402, MPP), not in named real-world "software factory" case studies. No end-to-end example product was found; this composition remains coherent-but-hypothetical.

6–7. **Which DLT network to use / Requirements** — 🟢 four real axes (throughput/finality, cost per tx for micro/nanopayments, atomic multi-step support, identity/authorization primitives). **PTBs**: 🟢 confirmed real and Sui-originated (up to 1,024 chained Move commands, atomic all-or-nothing), now also on IOTA post-Rebased — explicitly **not** an Aptos feature (correcting seed chat 1). **"IOTA Rebased"**: 🟢 confirmed accurate, current official terminology — the May 2025 mainnet upgrade to MoveVM-based L1 (>50,000 TPS benchmarked) is still called this in IOTA's own docs/blog.

8. **Suitable existing Networks** — 🟡 comparative figures (Ethereum ~13min finality/$0.50–5+ fees; Base ~2s blocks/$0.01–0.30; Solana ~2.5s finality/~$0.0001–0.01; Sui ~400ms finality; IOTA post-Rebased >50,000 TPS benchmark) are secondary-sourced and explicitly flagged in the raw file as **not stable** — fast-moving landscape, treat as illustrative not authoritative. 🟢 IOTA EVM Chain ID 8822 confirmed. Gnosis Chain's relevance is evidenced empirically (it carries the bulk of Olas's agent-transaction volume) rather than via published throughput/cost figures.

9. **Relevant protocols and standards** — the most load-bearing section for the chapter's existing outline stub:
   - 🟢 **x402** — real, chain-agnostic, mandatory/foundational. Linux Foundation governance claim **confirmed accurate**: x402 Foundation reached full operational status July 14, 2026, 40 member orgs (Visa, Mastercard, AWS, Google, Stripe, Amex, Coinbase), vendor-neutral — Coinbase does not control it.
   - 🟢 **EIP-7702** — confirmed shipped (Pectra, May 7 2025), status **Final**, Ethereum/EVM-only. Nuance: the EIP itself is a *persistent* delegation mechanism, not inherently time-limited — the "session key" framing both seed chats use is an application-layer pattern built on top (via ERC-7715), not a protocol-level guarantee of EIP-7702 itself.
   - 🟢 **ERC-4337** — real, complementary to (not competing with) EIP-7702, EVM-only.
   - 🟢 **ERC-7715** — real draft ERC ("Grant Permissions from Wallets"), the standard that actually delivers scoped/self-expiring session-key behavior, composed with EIP-7702.
   - 🟢 **ERC-8004 "Trustless Agents"** — real, but status is **Draft**, not finalized. Three registries (Identity/Reputation/Validation), interoperable with MCP and A2A by design. Real authors (MetaMask, Ethereum Foundation, Google, Coinbase contributors) and real testnet+mainnet reference deployments as of Q2 2026 — present as credible-and-active-but-not-yet-settled.
   - 🟢 **MPP** — **contradiction between the seed chats resolved decisively in favor of seed chat 2, with a correction**: MPP is Stripe/Tempo-backed (launched with Tempo mainnet, March 18 2026), explicitly **not** Bitcoin Lightning-based, network-agnostic/multi-rail, session-based allowances (contrasted with x402's per-request model). Seed chat 1's Lightning-Network description is wrong and should not appear in the chapter.
   - 🟢 **AP2** — real, Google-originated (Sept 2025, 60+ partners), payment-method-agnostic. New detail beyond both seed chats: Google is **donating AP2 to the FIDO Alliance** for platform-agnostic governance.
   - 🟢 **W3C DID/VC** — real, mature, actively revised specs (DID v1.1 Candidate Recommendation, March 2026). Application to *AI-agent* identity specifically is early-stage/thin (one named example, Nuggets) — contrast with ERC-8004, which was purpose-built for agents.
   - 🟢 **MCP** — confirmed Anthropic origin, now under the Linux Foundation's Agentic AI Foundation (Dec 2025). Kept brief per instructions since it's likely covered elsewhere in the book; its DLT-specific relevance is as the tool-connection/logging layer that would feed a DLT anchor, and its explicit interoperability listing inside ERC-8004.
   - 🟡 **ERC-721/1155 for build artifacts** — standards real, application speculative (see subtopic 5).
   - 🟢 **Reclaim Protocol / TLSNotary** — real zkTLS projects; "prove tests passed without revealing logs" is an accurate characterization of the technology class, though no CI-specific example was directly documented.

## Additional corrections found (not mapped to a single subtopic)

- **ElizaOS Move-chain support**: `@elizaos/plugin-aptos` is 🟢 confirmed real/maintained. Sui support is 🟡 plausible (migrated into the main `elizaos/eliza` monorepo) but not confirmed with the same certainty.
- **"GOAT" framework**: real (🟢 "Great Onchain Agent Toolkit," from Crossmint), but seed chat 1's expansion — "Gastoken Open Agent Toolkit" — is a **fabrication**. GOAT is a general 30+-chain multi-tool library, not an IOTA-Move-specific bridge as seed chat 1 implied.
- **IOTA EVM Chain ID 8822**: 🟢 confirmed accurate.

## Named-entity corrections/misattributions to fix when drafting

1. MPP ≠ Bitcoin Lightning (it's Stripe/Tempo, multi-rail) — seed chat 1 wrong, seed chat 2 right.
2. PTBs are Sui/IOTA-only, not an Aptos mechanism — seed chat 1 wrong.
3. GOAT = "Great Onchain Agent Toolkit," not "Gastoken..." — seed chat 1 fabricated the expansion.
4. EIP-7702 is a persistent delegation mechanism at the protocol level; "session key" behavior is layered on top via ERC-7715, not native to EIP-7702 itself — both seed chats slightly overstate this.
5. "The Grid" is a project directory, not a bonding-curve funding platform itself — seed chat 2 mischaracterized it.
6. ERC-8004 and MPP are both real but should be presented as **Draft/early-2026-launched**, not settled standards — seed chats present them with more confidence than their actual maturity warrants.

## What this means for the book (suggestion, not a decision)

The existing stub outline in `src/niche-topics/dlt-sw-factories.md` maps cleanly onto this research and needs no restructuring — the research followed its exact section order. Proposed drafting approach per section:

- **Public DLTs / What it is**: straightforward, primary-sourced definitional content — low risk, can be written directly.
- **When to use in general**: should explicitly include the critical/counter-argument material (the "Research Note" in the raw file) — this book values that kind of balance, and it directly supports the "why *agents specifically* change the calculus" argument used in the next section.
- **Public DLTs for Agentic Fabrics (Why / Why for SW Fabrics)**: solid to draft, but two things need explicit "Research Note" framing per `CLAUDE.md`'s evidence-quality convention: (a) the ERC-721/1155-for-build-artifacts idea as speculative extrapolation, and (b) the LangChain-brain/DLT-backbone hybrid pattern as reasoned inference rather than a documented industry pattern. Both are still worth including — they're plausible and useful for the reader — just not stated as established fact.
- **Which DLT network to use / Requirements / Suitable existing Networks**: draftable now; the comparative throughput/cost/finality table idea from the seed chats is good for readability, but the chapter should flag (as the raw file does) that these numbers move fast and are illustrative, not authoritative reference points.
- **Relevant protocols and standards**: the richest section — recommend a table (protocol × mandatory-or-optional × chain availability × current status) similar to the seed chats' own table format, but corrected per the "named-entity corrections" list above, and with each protocol's actual maturity stated honestly (e.g. ERC-8004 and MPP as young/Draft, x402/EIP-7702/ERC-4337 as shipped/Final).

Recommend confirming with the user before drafting whether to (a) keep the Research Note framing inline per section (per `CLAUDE.md` convention) or consolidate weaker-corroboration items into one dedicated note near the end of the protocols section, and (b) how much of the "critique of blockchain hype" material from subtopic 3 to include, given this chapter's overall pro-DLT-for-agents argument.
