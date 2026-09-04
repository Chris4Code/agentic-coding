# Fact-check: "Levels of Agentic Coding" — corroboration findings

Manual research pass (web search + primary-source reads), 2026-09-04. Feeds the new
`### The Levels of Agentic Coding` subsection in `src/sw-factories.md`.

## The claim being checked

User-supplied 6-level taxonomy:

1. **Interactive / In-the-Loop** — AI as fast pair-programmer / terminal assistant; manual prompt every step, approve each tool call.
2. **Context-Aware / Expertise** — custom project instructions (persistent `CLAUDE.md` / local memory) retain learning across sessions; human still step-by-step.
3. **Task Delegation / Sub-agents** — a primary agent decomposes a goal and delegates to specialized internal sub-agents (scouts, builders, reviewers) within one session.
4. **Human Orchestration (Parallel Sessions)** — multiple concurrent agent sessions across terminals / isolated git worktrees; human orchestrates, manages parallel PRs, resolves integration conflicts.
5. **System Orchestration / Autonomous Operator** — a coordinator agent manages worker agents in automated sandboxes; triggered by external signals (e.g. a GitHub issue number); end-to-end execution, self-correction, testing; humans review exceptions.
6. **Full Automation / Dark Factory** — entire lifecycle (triage → planning → coding → verification → deployment) runs continuously without direct human intervention.

Citation markers in the source were partial / broken (`[1,2,4]`, `[1,3,4]`, `[1]`, `[]`, `[, 3]`).

## Verdict

**A similar level structure is well corroborated → section added.** The *specific 6-level list, its names, and its cut points are not a standard* — they read as a synthesis blending several real frameworks. Per-item:

| User level | Corroboration | Notes |
|---|---|---|
| 1 In-the-Loop | 🟢 Strong | Universal bottom band. Shapiro L1–2, Yegge L2–4, Osmani L0–1, every vendor ladder. |
| 2 Context-Aware / Expertise (`CLAUDE.md`) | 🟠 Single-source as a *level* | Only the arXiv ACMM (Anderson, IBM Research — single author, AI-assisted writing) makes "encoded preferences / instruction files" its own rung (its L2 "Instructed"). Shapiro / Yegge / Osmani treat persistent project context as an orthogonal practice, not a rung. Flagged with a dedicated Research Note in the chapter. |
| 3 Task Delegation / Sub-agents | 🟢 Strong (concept); 🟡 "scouts/builders/reviewers" naming | Sub-agent decomposition well attested (Osmani "Code Agent Orchestra", freecodecamp 7-subagent factory, MindStudio "Harness-Driven Development" L4). Exact role names vary: ACMM says "scanner, reviewer, architect, outreach"; freecodecamp "researcher / story-writer / spec-writer / backend-builder / frontend-builder / test-verifier / validator". "Scout" is not a common term. |
| 4 Human Orchestration (Parallel Sessions) | 🟢 Strong | Osmani L4 "Parallel Delegation", Yegge L6–7 ("several agents in parallel", "10+ agents by hand"). Worktree isolation is a named practice across all multi-agent framings. |
| 5 System Orchestration / Autonomous Operator | 🟢 Strong | Osmani L5 "Managed-by-Exception Orchestration", Yegge L8 "Custom Orchestrator" (shared task queue + coordinator + checkpoint recovery), ACMM L6 (supervisor agent coordinates executors, cron/issue-triggered, work ledger, push-notification escalation). "Management by exception" is Osmani's own phrase. |
| 6 Full Automation / Dark Factory | 🟢 Strong; already in chapter | Shapiro L5, MindStudio/Swarmia top rung, ACMM L6. "Dark factory" origin + StrongDM/Horthy already covered in `### Dark Factory`. |

The endpoints (in-the-loop assistance ↔ dark factory) and the rough middle (bounded delegation → parallel → orchestration-by-exception) are agreed across ≥4 independent authors. What is **not** agreed: rung count (5 / 6 / 8), boundaries, and the defining axis.

## The real frameworks (primary/near-primary)

- **Dan Shapiro, "The Five Levels: from Spicy Autocomplete to the Dark Factory"** — https://www.danshapiro.com/blog/2026/01/the-five-levels-from-spicy-autocomplete-to-the-software-factory/ (2026-01-23). Axis = autonomy. Explicitly modeled on SAE "levels of driving automation." L0 manual → L1 AI for discrete tasks → L2 pair programming → L3 developer-as-code-reviewer → L4 developer-as-product-manager → L5 dark factory (specs in, software out). Most-cited version. Relayed/endorsed by **Simon Willison** — https://simonwillison.net/2026/Jan/28/the-five-levels/ (2026-01-28).
- **Steve Yegge, 8 levels** — via The Pragmatic Engineer (Gergely Orosz): https://newsletter.pragmaticengineer.com/p/from-ides-to-ai-agents-with-steve . Axis = trust in a single agent. 1 no AI · 2 IDE agent, approvals on · 3 IDE agent, YOLO mode · 4 watch the agent, not diffs · 5 CLI-first, IDE abandoned · 6 several agents in parallel (2–5) · 7 10+ agents by hand · 8 custom orchestrator (shared task queue, coordinator, checkpoint recovery). Yegge also built "Gas Town", an open-source agent orchestrator.
- **Addy Osmani, "Agentic Autonomy Levels"** — https://addyosmani.com/blog/agentic-autonomy-levels/ (July 2026). Explicitly builds on Yegge's single-axis ladder, adds a 2nd axis (agency × orchestration) because one number can't place a multi-agent setup. Six rungs 0–5: Assist · Supervised Action · Scoped Task Delegation · Goal-Driven Autonomy · Parallel Delegation · Managed-by-Exception Orchestration. Related: Osmani / O'Reilly "Conductors to Orchestrators" (https://www.oreilly.com/radar/conductors-to-orchestrators-the-future-of-agentic-coding/) — a conductor↔orchestrator *spectrum*, not numbered levels; critical break = conductor→orchestrator.
- **Andy Anderson (IBM Research), "The AI Codebase Maturity Model (ACMM)"** — arXiv 2604.09388. Practitioner experience report, single author, written with AI assistance (interviewed by Claude Code), not peer-reviewed. 6 levels defined by *feedback-loop topology*, not autonomy: 1 Assisted (prompt & review) · 2 Instructed (encoded preferences — `CLAUDE.md`, copilot-instructions.md) · 3 Measured (metrics/test suites visible) · 4 Adaptive (loops act on their own metrics) · 5 Semi-Automated (system proposes, humans approve) · 6 Fully Autonomous (supervisor agent + executor fleet, cron/issue-triggered, "Beads" work ledger, push-notification escalation). Case study: KubeStellar Console (CNCF), reference impl "Hive". Its §2.3 surveys the other models (Shapiro, ELEKS AI-SDLC, AIDMM, Gigacore AI-MM SET).
- **Swarmia, "Five levels of AI coding agent autonomy"** — https://www.swarmia.com/blog/five-levels-ai-agent-autonomy/ . Assistive · Conversational · Task agent · Autonomous teammate · Agentic avalanche (orchestrators spawning subagents).
- Vendor explainers (lower authority, converge on the same shape): MindStudio "Agentic Coding Levels Explained" / "5 Levels of AI Coding Autonomy" (both end at "Dark Factory"); freecodecamp "How to Build a Software Factory with Claude Code" (7 specialized subagents; not a numbered ladder).

## Chapter changes made

- `src/sw-factories.md`: new `### The Levels of Agentic Coding` subsection at the end of `## Software factory models` (after Leverage-Point Model), with the convergent-progression table, a mermaid flow, and two Research Notes (non-standardization; the single-source `CLAUDE.md`-as-a-level caveat). One-line tweak to the section intro.
- `src/glossary.md`: new "Levels of agentic coding" entry (between "Lethal trifecta" and "Leverage-Point Model").
- `history/sw-factories/2026-09-04-1-levels-of-agentic-coding-fact-check.md`.
