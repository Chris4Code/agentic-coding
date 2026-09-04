# 2026-09-04 · Run 2 · sw-factories · RPI (Research, Plan, Implement)

**Type:** `deep-book-research` skill run (research pass + planned chapter integration).

## Triggering request

User asked for a deep-book-research pass on **RPI (Research, Plan, Implement)** — Dex Horthy / HumanLayer's methodology for keeping AI coding agents focused and reducing errors by separating data gathering and architecture/plan design from actual code generation. Follow-up to a glossary request earlier in the same session (the initial glossary RPI entry was drafted from existing notes only). User asked that the findings be integrated into `src/agentic-coding-harnesses.md` and/or `src/sw-factories.md` (whichever suits) and that the glossary RPI entry be rewritten afterward.

## Seed

- **Chapter-file:** `src/sw-factories.md` (target chapter; RPI relates most directly to its `## Loop Engineering`, `### Leverage-Point Model`, and `### Why Not Just a Bigger Agent?` sections). No external source URL supplied.
- **Prior art consulted** (research is meant to extend, not repeat, these):
  - `notes/2026-08-17-1-sw-factories-dex-horthy-deep-research/raw-context-engineering-fundamentals--dumb-zone--12-factor-agents--code-review-failures--loop-engineering.md` — §5 (Loop Engineering / Ralph loop / first RPI description), §8 (Intentional Compaction / four-gate model), §2 (Dumb Zone), §11 (Model Training Limitations). Primary anchors: `ace-fca.md` and `wsff.md` in `humanlayer/advanced-context-engineering-for-coding-agents`, plus `humanlayer/12-factor-agents`.
  - `notes/2026-08-18-1-sw-factories-langchain-loop-engineering-deep-research/` — loop-engineering / LangChain framing.
  - `notes/2026-08-18-2-sw-factories-software-factory-models-corroboration/` — Full Human Review / Dark Factory / Leverage-Point Model corroboration.
  - `notes/2026-09-04-1-sw-factories-levels-of-agentic-coding/` — levels taxonomy.
  - `notes/2026-08-30-2-quality-design-by-contract-fact-check/summary-*.md` — flagged "PIV (Plan-Implement-Validate)" as a non-term and RPI (Research→Plan→Implement) as the recognised one.

## Subtopics targeted (one research pass each)

1. RPI methodology — origin, definition, primary sources (`ace-fca.md`, Horthy talks)
2. The Research phase — what artifact it produces, scoping, file/data-flow focus
3. The Plan phase — plan-document contents, "a bad line of plan → hundreds of bad lines of code" leverage argument
4. The Implement phase — phase-by-phase execution, compaction between phases, verification
5. Context-window utilization between phases — 40–60% target, "dumb zone" avoidance, fresh sessions seeded by artifacts
6. Brownfield vs greenfield applicability — why RPI "falls flat" on greenfield, the spec-first alternative
7. RPI vs spec-driven development (SDD / GitHub Spec Kit "Specify→Plan→Tasks→Implement") and vs the factory-level four-gate Leverage-Point model — same idea, different granularity
8. RPI and the Ralph loop / relationship to loop engineering and intentional compaction
9. Tooling and adoption — Claude Code plan mode, custom skills/commands implementing RPI, subagents for the research phase, CCPM and similar, secondary-practitioner writeups
10. Evidence and corroboration — HumanLayer's ~2–3x claim, any named large-PR / brownfield case studies, independent corroboration vs single-source

## Output

- `notes/2026-09-04-2-sw-factories-rpi-research-plan-implement/raw-rpi-methodology-and-origin--research-phase--plan-phase--implement-phase-and-compaction--context-utilization-between-phases.md`
- matching `summary-*.md`

## Same-day follow-up (part of this run)

After the initial integration, the user asked whether the **QRSPI** and **CRISPY** variants of RPI should be added to the
new chapter subsection. Rather than a separate research pass, a targeted web-research follow-up was done in the same
session and filed as `raw-qrspi-crispy-addendum.md` in the same notes folder (sources: the March 2026 "Everything We Got
Wrong About Research-Plan-Implement" talk page, alexlavaee.me "From RPI to QRSPI", Turing Post, Heavybit, The Humans in
the Loop, the HumanLayer skills docs, `dynaptik/crispy`, `dfrysinger/qrspi-plus`, and the
`advanced-context-engineering-for-coding-agents` repo file listing). Findings folded into the RPI subsection (a dedicated
QRSPI paragraph) and the glossary (new `QRSPI` headword).
