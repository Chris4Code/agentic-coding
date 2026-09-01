# Summary: Dex Horthy / HumanLayer research

Distilled index for [`raw-context-engineering-fundamentals--dumb-zone--12-factor-agents--code-review-failures--loop-engineering.md`](./raw-context-engineering-fundamentals--dumb-zone--12-factor-agents--code-review-failures--loop-engineering.md) — the full backing research, gathered by following up on The Pragmatic Engineer's ["Context Engineering with Dex Horthy"](https://newsletter.pragmaticengineer.com/p/context-engineering-with-dex-horthy) episode (Dex Horthy, CEO of [HumanLayer](https://www.humanlayer.dev/)).

**This file is a map, not the source.** It compresses each subtopic to a few lines so you can decide what's worth pulling into a chapter — but exact figures, quotes, and citation links live only in the raw file. Before writing anything into `src/sw_factories.md` that states a number, a quote, or an attribution, open the matching `##` section in the raw file and copy from there, not from here.

Each item is tagged with how solid its sourcing is:
- 🟢 **primary** — traced to Horthy's own written essays (`wsff.md`, `ace-fca.md`) or the `12-factor-agents` repo.
- 🟡 **secondary** — consistent across multiple independent write-ups of his talks/podcasts, but not found in his own writing.
- 🟠 **single-source** — sourced to the Pragmatic Engineer podcast/newsletter only, not independently corroborated.

## The 12 subtopics, compressed

1. 🟢 **Context engineering fundamentals** — context window is "the ONLY lever" on output quality; distinct from prompt engineering (single instruction) by covering the whole multi-step pipeline. Term may have multiple independent originators (LangChain published a similar framing the same period) — don't over-attribute the coinage to Horthy alone.
2. 🟡 **The "Dumb Zone"** — quality degrades once context utilization crosses a threshold: ~300-400K tokens for 1M-window models, ~100K for smaller ones. His written essay describes the same effect via a 40-60% utilization target but doesn't use the term "dumb zone" — that phrase is talk-only. The oft-repeated "~100,000 sessions analyzed" figure is unverified.
3. 🟢 **12-Factor Agents** — full list of all 12 factors is in the raw file, sourced directly from the [repo README](https://github.com/humanlayer/12-factor-agents). Built from ~100 engineer interviews. Read this section if the chapter cites any specific factor by number.
4. 🟢 **Code review failures** — best-corroborated story in the whole research pass. July 2025: went "lights-off" (no human code review). Broke by ~Nov 2025 (a misrouted primary key bug even Opus 4.1 couldn't diagnose); cofounder spent two weeks manually rewriting. Independently backed by Faros AI telemetry (22,000 devs, 2 years): +31.3% PRs skip review, +242.7% incidents/PR, +54% bugs/dev, but also +34% task completion — the tradeoff is real both ways. This is the anecdote to lead with if the chapter wants one concrete failure case.
5. 🟢 **Loop engineering** — extends (doesn't just restate) the existing `Software Factory.md` note. Concrete example: the "Ralph loop" (Geoff Huntley, June 2025) — a bare bash loop, no framework, ~$10-12/hr running Sonnet overnight. Horthy's refinement: **RPI** (Research → Plan → Implement) with compaction between phases; explicitly brownfield-only, "falls flat" on greenfield work.
6. 🟢 **Software factory models** — four-stage progression, not three: pre-AI (human builds) → full-human-review-of-AI-code (30-50% gain) → lights-off/dark factory (his failed experiment, #4) → his recommended **leverage-point model** (~2-3x faster, every line still reviewed, but review is fast because a 4-gate pre-planning process front-loads the decisions). Key quote to preserve: "If you're drowning in PRs, you actually have too many bad PRs."
7. 🟡 **Trajectory poisoning** — sycophantic phrasing ("you're completely/absolutely right") as a tripwire signaling a session has drifted into repeating the same mistake; restart rather than argue with it. Term and the specific tell are talk-only, not in his written essays — the underlying "trajectory" concept is 🟢 primary (see #10).
8. 🟢 **Intentional compaction** — best process-level material in the research. Target 40-60% context utilization; distill to a markdown artifact before crossing out of it. Maps to a **4-gate workflow**: Product Review → System/Architecture → Program Design → Vertical Slices, each gate needing explicit human "Approve Gate N?" sign-off. Quote: "A bad line of a plan could lead to hundreds of bad lines of code." This is the most citable, most concrete material for a "how do you actually run a factory" section.
9. 🟠 **Token harder vs. token smarter** — catchy framing (max token burn vs. deliberate token spend), maps onto lights-off-vs-leverage-point, but the exact phrase wasn't located in either written essay. Use as a rhetorical contrast, attribute loosely.
10. 🟢 **Context window quality factors** — the actual primary-source list is **correctness → completeness → size → trajectory** (in that priority order), not "size/quality/missing/trajectory" as initially assumed from the podcast summary — reconcile this if the chapter quotes it. Failure severity ranking: incorrect info > missing info > too much noise. Noise sources named explicitly: search results, diffs, logs, raw JSON tool output.
11. 🟢 **Model training limitations** — arguably Horthy's most original argument, worth featuring. Coding models train against SWE-bench-style benchmarks with "no penalty for eroding codebase maintainability" because maintainability has no fast reward signal ("tests give feedback in seconds, the cost of bad architecture is measured in months"). Longer-horizon benchmarks (SWE-Marathon, up to ~400hr tasks) are an emerging but unsolved fix.
12. 🟠 **Optimization timing** — three-phase "make it run → make it right → make it fast/cheap"; only reach for cheaper models (example given: GPT-OSS-120B, claimed ~1/1000th frontier cost — directionally right per OpenRouter pricing, exact multiplier unverified) once engineering iteration speed stops being the bottleneck.

## Named entities — corrections worth remembering

- **Docker and HashiCorp were clients Horthy worked with during 7 years at Replicated** — not employers. The episode topic list implied otherwise; don't repeat that error in the chapter.
- **LangChain/CrewAI "rejected by interviewed engineers"** is 🟠 podcast-sourced only — plausible given the 12-factor design philosophy, but don't state it as independently verified fact.

## What this means for `src/sw_factories.md`

The chapter stub currently has two empty headers, "LangChain" and "Loop Engineering." This research suggests reframing around Horthy's four-stage factory model (#6) as the spine, with:
- The code-review-failure story (#4) as the motivating case against full automation.
- The 4-gate intentional-compaction workflow (#8) as the concrete "how" for the leverage-point model.
- The 12 factors (#3) and context-quality list (#10) as supporting/reference material, possibly glossary-linked rather than fully explained inline.
- Model training limitations (#11) as the principled "why humans stay in the loop" argument, distinct from the empirical Faros data.

This is a suggested structure, not a decision — worth confirming with the user before drafting the chapter.
