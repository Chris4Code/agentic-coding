# Summary: RPI (Research → Plan → Implement) as a methodology

Navigation aid for the raw file in this same folder
(`raw-rpi-methodology-and-origin--research-phase--plan-phase--implement-phase-and-compaction--context-utilization-between-phases.md`).
**Not a substitute** — every exact quote, figure, PR number, and citation must be pulled from the raw file, not copied
from here. This summary compresses; the raw file is the record.

Extends the prior pass `notes/2026-08-17-1-sw-factories-dex-horthy-deep-research/` (which covered RPI only at a summary
level inside Loop Engineering / Intentional Compaction). Primary anchors this pass actually fetched in full: `ace-fca.md`
and `wsff.md` (humanlayer/advanced-context-engineering-for-coding-agents), the three real workflow prompts
`research_codebase.md` / `create_plan.md` / `implement_plan.md` (humanlayer/humanlayer), `ghuntley.com/ralph`, and the
HumanLayer `/rpi:*` skills docs.

**Addendum in this folder:** `raw-qrspi-crispy-addendum.md` — a same-day follow-up on the QRSPI and CRISPI/CRISPY
variants (see the closing item below). QRSPI is Horthy's own early-2026 revision of RPI (talk-sourced, multiply
corroborated); CRISPY is just a community phonetic renaming of QRSPI in third-party plugins, not a distinct method.

## Per-subtopic findings, by sourcing confidence

1. **Origin & the "RPI" name — 🟠 mixed.** The written essays (`ace-fca.md`, Aug 2025) say lowercase "research, plan,
   implement" and hedge hard: it's "one concrete instantiation" of a broader family Horthy calls **"frequent intentional
   compaction"**, and "the core capabilities/learnings here are FAR more general than any specific workflow." `wsff.md`
   (2026) calls it "4 phases." **The initialism "RPI" appears only in Horthy's 2026 talk titles** ("Everything We Got
   Wrong About RPI", "From RPI to QRSPI", March 2026) and downstream secondary write-ups — 🟢 that it's his own retronym,
   not a third-party coinage; 🟠 that it was never a formal acronym in the primary text.
2. **Research phase — 🟢 primary, verbatim from the prompt file.** Produces a standalone markdown **research document**
   (`thoughts/shared/research/…`) that documents the existing codebase *only* — the `research_codebase.md` prompt opens
   "CRITICAL: YOUR ONLY JOB IS TO DOCUMENT AND EXPLAIN THE CODEBASE AS IT EXISTS TODAY" and forbids suggestions, root-cause
   analysis, critique, future enhancements. Sections: Research Question, Summary, Detailed Findings (with `file:line`),
   Code References, Architecture Documentation, Historical Context, Open Questions; YAML frontmatter with git commit.
   Uses **parallel read-only sub-agents** (`codebase-locator`, `codebase-analyzer`, `codebase-pattern-finder`,
   `thoughts-locator/analyzer`) purely for context control — "Subagents are not about playing house and anthropomorphizing
   roles. Subagents are about context control." Verified by the human reading it end to end; no partial-edit path — accept
   or discard-and-rerun (the BAML example: "I threw that research out and kicked off a new one, with more steering").
3. **Plan phase — 🟢 primary, verbatim.** Produces an **implementation plan** markdown doc
   (`thoughts/shared/plans/…`). `create_plan.md` template: Overview, Current State, Desired End State + "how to verify
   it", **What We're NOT Doing**, then **per-phase** "Changes Required" file-by-file with fenced code blocks, and success
   criteria split into **Automated Verification** (runnable commands, "use `make` whenever possible") vs **Manual
   Verification**. Each phase ends "pause here for manual confirmation from the human … before proceeding." Hard rule: "No
   Open Questions in Final Plan … STOP … Every decision must be made before finalizing." Type/method signatures + call-
   stack ordering are a `wsff.md`-era addition landing in the **Program Design** gate ("the shape of code"). Leverage
   argument, verbatim: *"a bad line of a plan could lead to hundreds of bad lines of code. And a bad line of research …
   could land you with thousands of bad lines of code"*; *"I can't read 2000 lines of golang daily. But I can read 200
   lines of a well-written implementation plan."* Review is interactive/multi-checkpoint ("Don't write the full plan in
   one shot. Get buy-in at each major step").
4. **Implement phase — 🟢 primary, verbatim.** "Step through the plan, phase by phase." `implement_plan.md`: implement
   each phase fully, check off `- [ ]` → `- [x]` **in the plan file itself**, one phase per invocation by default, resume
   in a fresh session by trusting existing checkmarks and picking up from the first unchecked item. Run the plan's own
   Automated Verification after each phase, then pause for human manual verification (fixed template). **Only this phase
   needs a git worktree — "We tend to do everything else on main"** (research/plan produce only markdown). Human
   involvement is lowest here but deliberately non-zero: "send off a model to do 1-3 slices at a time, and review the code
   as I go"; "you have to engage with your task when you're doing this or it WILL NOT WORK."
5. **Context utilization between phases — 🟢 primary for the band, 🟠 single-source for the tighter number.** Verbatim:
   "designing your ENTIRE WORKFLOW around context management, and keeping utilization in the **40%-60% range**." Each phase
   is a **new conversation seeded only by the previous phase's markdown artifact**, not the raw transcript — RPI is
   "intentional compaction" applied at three fixed pre-planned points instead of ad hoc when the window fills. Horthy
   gives **no token figures of his own** in `ace-fca.md` — he quotes Huntley's "**170k of context window** to work with …
   use as little of it as possible." The "keep under 40%, start fresh at 60%" tightening is 🟠 one practitioner blog
   (alexlavaee.me) reporting the March 2026 talk. The "smart zone ~300–400k / ~100k" figures are 🟡 from talks via prior
   notes, not the essay.
6. **Brownfield vs greenfield — 🟡 secondary for the blunt claim.** `ace-fca.md` is entirely brownfield-framed (original
   title "Getting AI to Work in Complex Codebases"; cites a Stanford finding that AI "work[s] well for greenfield
   projects, but [is] often counter-productive for brownfield codebases"). **But "RPI falls flat on greenfield" is NOT in
   either essay** — it's a secondary paraphrase (LinearB, htek.dev). The essays' actual position: **brownfield →
   research-first RPI; greenfield / new features → spec-first** (explicitly "something like sean's spec-driven
   development", Sean Grove; "We're pretty bullish on spec-first, agentic workflows"). Mechanism: on greenfield there's no
   existing system to *research*, so a behaviour/product spec is the higher-value upfront artifact. The QRSPI revision
   folds both in (a "PRD-Oriented" workflow beside the "RPI" workflow).
7. **RPI vs four-gate model vs SDD — 🟢 for the two Horthy models, 🟡 for the comparisons.** The four-gate Leverage-Point
   model (`wsff.md`) is **the same idea as RPI at a later date and finer granularity**: RPI's "Plan" exploded into
   Product Review / System Architecture / Program Design, RPI's "Implement" reshaped as Vertical Slices, RPI's "Research"
   folded into the Architecture gate. March 2026 "Everything We Got Wrong About RPI" revises again to **QRSPI/CRISPI**
   (adds a **Questions** phase + **Design Discussion** + **Structure Outline**) because the clean 3-phase boundary was "a
   useful fiction" — real agents iterate Research↔Plan, and over-detailed plans created a "plan-reading illusion"
   ("reading a plan is not the same as validating a plan"). 🟡 QRSPI phase names / "useful fiction" (talk not transcribed
   this pass). GitHub **Spec Kit** (`/specify → /plan → /tasks → /implement`) is structurally near-identical but
   greenfield-centred with no research phase; RPI's "Plan" ≈ Spec Kit's `/plan` + `/tasks`. Addy Osmani's "waterfall in
   15 minutes" = same claim, different label — 🟢 Horthy & Osmani are explicitly in dialogue (Osmani thanked in `wsff.md`,
   his vibe-vs-maintenance quote used there).
8. **RPI and the Ralph loop — 🟢 primary.** Ralph (Huntley) = `while :; do cat PROMPT.md | agent; done`, one item per
   loop, plan file as durable state, `git reset --hard` on a bad loop. Huntley already split work into two phases
   ("Generate" / "Backpressure"), so phasing predates RPI on the Ralph side. RPI keeps Ralph's discipline (tiny per-
   iteration context, frequent resets, plan-file state) and adds an upstream Research artifact + human approval gates +
   structured per-phase verification. HumanLayer ships RPI *as* Ralph-style loop commands (`ralph_research.md` /
   `ralph_plan.md` / `ralph_impl.md`) that pull the top Linear ticket, run one phase, write the artifact, move the ticket
   to an "in review" column, and stop. RPI is applied **selectively** — `wsff.md`: "~40% of tasks get oneshot." "Simpler
   loops fail in simpler ways" is 🟡 a real repeated talking point, not verbatim in any fetched primary source.
9. **Tooling & adoption — 🟢 for HumanLayer's own, 🟠 for third-party.** Verified HumanLayer: the three canonical prompts
   (+ `_generic`/`_nt`/`iterate`/`validate`/`oneshot`/`ralph_*` variants); the shipped **`/rpi:*` skill set** (22
   commands, four selectable workflows: RPI / PRD-Oriented / Oneshot / Freeform; artifacts numbered in
   `.humanlayer/tasks/<slug>/`; documented conflict precedence "plan > outline > TDD > PRD > design discussion > research
   > ticket", "live code beats any document"); CodeLayer / humanlayer.com the productised form. 🟠 Real-but-unaudited
   community repos: `bostonaholic/rpikit`, `mmanzini/rpi-methodology` (invents "FAR"/"FACTS" scales, claims Block Goose /
   Kilo.ai adoption — **unverified**), `acampb/claude-rpi-framework`, the Maciejdziuba gist (single-source community
   transcription the prior notes leaned on for `00-status.md` / "Approve Gate N"). Adjacent tools people compare RPI to:
   Spec Kit, Kiro (AWS), CCPM (`automazeio/ccpm`), BMAD-METHOD.
10. **Evidence — 🟢 negative case, 🟠 positive case, ❌ one misattribution to fix.** The "**2–3x faster, safely**" claim
    is `wsff.md` verbatim but **Horthy-self-reported, no external audit**. Named case study = **BAML** (BoundaryML/baml):
    PR **#2259** (research-backed fix, approved), #2258 (no-research, closed), issue #1252; larger follow-up ~35k LOC
    across #2357 + #2330, "7 hours (3 on research/plans, 4 on implementation)", BAML's own Vaibhav Gupta "estimated …
    3-5 days of work for a senior engineer" — **PR numbers real and checkable, effort/time figures self-reported.**
    Horthy also publishes a **failure**: the parquet-java / remove-hadoop attempt, 7 hours, "did not go well" (blamed on
    shallow research). The "front-load planning" thesis is corroborated **qualitatively** (MIT Sloan time-allocation study
    — Copilot users +12.4% core coding, −24.9% project management; Spec Kit; Osmani) but **not** with a controlled number.

## Named-entity corrections / misattributions flagged

- **❌ The chapter's "56% reduction in programming time" attributed to a "joint MIT Sloan / Microsoft Research / GitHub
  study" on spec-driven upfront planning is misattributed.** The 56% traces to **Peng, Kalliamvakou, Cihon, Demirer,
  "The Impact of AI on Developer Productivity: Evidence from GitHub Copilot" (arXiv 2302.06590, 2023)** — 95 contract
  devs building a JavaScript HTTP server, treatment group "completed the task 55.8% faster" (71 vs 161 min). It is a
  **plain GitHub Copilot autocomplete RCT on a greenfield toy task with no spec / plan / planning manipulation at all.**
  It's often re-hosted under MIT GenAI / summarised by MIT Sloan, which is the likely source of the mislabel. The
  research agent found **no** MIT/MSR/GitHub study supporting the sentence as written. **Fix options:** (a) cite
  2302.06590 accurately as a general Copilot-speed result and drop the "spec-driven upfront planning" gloss, or (b)
  replace it with the MIT Sloan *time-allocation* study (Hoffmann et al., "Generative AI and the Nature of Work" —
  −24.9% project-management time), which actually matches the "coding isn't the bottleneck" claim, or (c) present the
  56% with a `Research Note:` that it's a Copilot-speed RCT, not a planning study. This is a pre-existing chapter error
  surfaced by this pass, not something RPI integration introduced — worth fixing in the same edit.
- **"No Vibes Allowed" talk date:** htek.dev misdates it "AI Engineer World's Fair 2024"; `wsff.md` dates it 11/25 (Nov
  2025). `ace-fca.md` = Y Combinator talk, Aug 20 2025. `wsff.md` keynote = AI Engineer World's Fair 2026. Don't cite
  htek.dev's date.
- **`mmanzini/rpi-methodology`** dates RPI to "2024" (wrong — the written workflow is Aug 2025) and claims Block Goose /
  Kilo.ai adoption (unverified). The "FAR" / "FACTS" / "instruction budget ~150–200" scales are that repo's own
  invention, not HumanLayer's — the repo itself admits the budget is "not rigorously validated by HumanLayer."
- **"RPI" as a formal acronym** — attribute to Horthy's 2026 talks, not `ace-fca.md`.
- **"Falls flat on greenfield"** — attribute to secondary write-ups / talks, not the essays (which say "spec-first for
  greenfield" in softer words).

## What this means for the book (suggestion, to confirm)

**Home: `src/sw-factories.md`, a new `### Research, Plan, Implement (RPI)` subsection under `## Loop Engineering`**, placed
right after the section intro and before (or just after) "Make it run". Rationale: RPI is Horthy's per-task refinement of
the Ralph loop, one level below the factory and one level above a single agent's ReAct loop — exactly the gap "Loop
Engineering" already occupies. It also sets up the existing **Leverage-Point Model** subsection (which can gain one
sentence noting it's the same idea scaled to the factory, plus the QRSPI note that the 3-phase boundary is "a useful
fiction").

Proposed content, ~3–4 paragraphs + one mermaid diagram:
1. **What it is** — the three phases as deliberate context-boundary resets; each produces a durable markdown artifact
   (research doc / plan doc) that seeds the next fresh session; the "40–60% utilization" target and the Huntley 170k
   quote; "frequent intentional compaction" as the umbrella term; note "RPI" is Horthy's later retronym.
2. **Why separate research/planning from codegen** — the "bad line of research → thousands of bad lines of code" leverage
   argument; review a 200-line plan not 2000 lines of Go; the `research_codebase.md` "document what exists, don't
   critique" discipline and read-only sub-agents for context control; the human gate after research and after plan.
3. **Where it applies** — brownfield, not greenfield (spec-first there); applied selectively (~40% oneshot); shipped both
   as a linear checkpointed workflow and as `ralph_*` loop commands over a ticket queue.
4. **Evidence & caveats** — BAML PRs (real, self-reported effort); 2–3x self-reported; the published parquet-java
   failure; `Research Note:` that the speed payoff is single-source (Horthy) while the "front-load planning" thesis is
   corroborated only qualitatively.

**Also:** fix the misattributed "56%" in the Leverage-Point Model section in the same edit (see above).

**Glossary:** rewrite the `RPI (Research, Plan, Implement)` entry to (a) note it's Horthy's retronym for the
"research, plan, implement" / "frequent intentional compaction" workflow, (b) name the three artifact-producing phases and
the context-reset-between-phases mechanism, (c) keep the brownfield qualifier but soften "falls flat" to the essays'
"spec-first for greenfield", (d) point `See` at the new sw-factories subsection. Add a `frequent intentional compaction`
glossary entry (or fold it in) and consider a `Ralph loop` entry since both are now referenced.

**Minimal `src/agentic-coding-harnesses.md` touch (optional):** its "Context Window Quality Factors" section could gain a
one-line cross-reference to RPI as the workflow-level application of the same principle, but the substance belongs in
sw-factories.

## Addendum: QRSPI / CRISPY (same-day follow-up — see `raw-qrspi-crispy-addendum.md`)

- 🟡 **QRSPI** — Horthy's own early-2026 revision of RPI: **Questions, Research, Design discussion, Structure outline,
  Plan, Implement** (+ PR; some sources also count Worktree). From the March 2026 talk **"Everything We Got Wrong About
  Research-Plan-Implement"** / "From RPI to QRSPI" — no written essay (the repo still holds only `ace-fca.md` + `wsff.md`),
  but three independent write-ups (alexlavaee.me, Turing Post, Heavybit, The Humans in the Loop) report the same thing.
  Three named failure modes of 3-phase RPI: (1) **instruction-budget overflow** — 85+ instruction planning prompt vs the
  ~150–200 a frontier model follows reliably, so deep steps got silently skipped; fix = sub-steps under ~40 instructions;
  (2) **magic-words dependency** — only worked if the user pasted a trigger phrase; "if a tool requires magic words for
  basic functionality, the tool itself is broken"; (3) **plan-reading illusion** — "reading a plan is not the same as
  validating a plan"; fix = explicit Questions + Design-discussion steps. HumanLayer's shipped `/rpi:*` tooling already
  runs the QRSPI sequence under the "RPI" label.
- 🟠 **CRISPI / CRISPY** — **not Horthy's term and not a distinct method.** A community phonetic renaming of QRSPI:
  `dynaptik/crispy` ("how QRSPI sounds to me phonetically", an 8-phase state machine "based on the QRSPI methodology"),
  `dfrysinger/qrspi-plus`. Real repos, unaudited. The chapter gives it one subordinate clause, no more.
- **Applied to the chapter:** the one-sentence revision note in the RPI subsection was expanded into a dedicated QRSPI
  paragraph (three failure modes + phase list + the "shipped under the RPI name" point + a CRISPY clause); the Research
  Note now flags QRSPI as talk-sourced-but-corroborated. Glossary: added a `QRSPI` headword and a cross-link from `RPI`;
  no `CRISPY` headword.
