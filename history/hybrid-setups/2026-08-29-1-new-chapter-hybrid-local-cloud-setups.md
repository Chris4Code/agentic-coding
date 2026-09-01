# 2026-08-29 · run 1 · new-chapter-hybrid-local-cloud-setups

**Skill:** none (direct drafting prompt)
**Chapter:** src/hybrid-setups.md — new chapter, created this run
**Scope:** whole chapter, from scratch

## Trigger

User asked to introduce a new chapter `Hybrid Setups`, positioned between "Local Models and Hybrid Cloud usage" (`local-models.md`) and "RAGs" (`rags.md`), describing several technical setups for hybrid local/cloud LLM usage. Stated key factors: **Users** — Single Developer, Small Teams, Enterprise Teams; **Hardware** — Dedicated PCs, Single Consumer GPU, AI-Workstations. This followed the same-session rename of `local-models.md` to "Local Models and Hybrid Cloud usage" and the deletion of the empty `hybrid-cloud-usage.md` stub.

## Input materials

Not a research pass — synthesized from research already filed for the `local-models` chapter earlier the same day, plus general architecture reasoning:

- `notes/2026-08-29-1-local-models-local-inference-engines-and-hardware/` — inference engines (llama.cpp / Ollama / vLLM concurrency model), hardware tiers (CPU PC bandwidth limits, consumer GPU VRAM thresholds, AI-workstation unified-memory trade-off), 2026 hardware pricing.
- `notes/2026-08-29-2-local-models-local-models-quantization-moe/` — model landscape by hardware class, MoE "pay memory for all, bandwidth for active" behaviour, model names per tier.
- `notes/2026-08-29-3-local-models-frontends-proxies-terminals-security/` — LiteLLM (virtual keys, budgets, fallbacks, Anthropic pass-through), claude-code-router, OpenRouter (ZDR / `data_collection` / in-region `eu.`/`us.` routing, BYOK), Langfuse (self-host, LiteLLM callback), Claude Code `ANTHROPIC_BASE_URL` / `ANTHROPIC_MODEL` / `ANTHROPIC_SMALL_FAST_MODEL`, no-auth-by-default inference servers, OWASP LLM01/LLM06.
- `src/local-models.md` (current) — the preceding chapter, cross-referenced throughout rather than duplicated.
- `src/basics.md` — communication tax / loop engineering / subagent condensed-return pattern, referenced for the "local preprocessing, cloud generation" pattern.

## Scope targeted (chapter section outline as drafted)

1. Intro — the two defining questions: routing and governance.
2. Why hybrid — factor table (cost, capability, latency, concurrency, data exposure, offline tolerance, maintenance).
3. Routing patterns — task-tier routing, capability cascade, data-classification routing, local-preprocessing/cloud-generation, cloud-primary/local-fallback (with a mermaid routing diagram).
4. Setups by user scale × hardware — a matrix table, then a subsection per user scale (single developer / small team / enterprise) walking the hardware classes: Dedicated PC, Single Consumer GPU, AI Workstation, plus Datacenter GPU Stack for the enterprise scenario (added on a follow-up request).
5. Cost and capability trade-offs — ownership-vs-per-token crossover rules of thumb (flagged as rules of thumb in a Research Note, cross-ref Cost Control).
6. Governance in hybrid setups — silent-leakage risk and the layered controls (allow-lists, disabled blind fallbacks, ZDR/in-region, egress filtering, audit).

## Notes

- Written from scratch (no prior chapter file, no `<!-- CONTENT-KEY-SUBJECTS -->` seed). The `edit-chapter` skill explicitly does not cover brand-new chapters; `deep-book-research` was not invoked because the building blocks were already researched for `local-models` the same day.
- One `Research Note:` added (cost-crossover thresholds are structural rules of thumb, not measured break-even points). The hybrid *patterns* themselves are architecture synthesis over independently-verified components, consistent with how `rags.md` handles its combined architectures.
