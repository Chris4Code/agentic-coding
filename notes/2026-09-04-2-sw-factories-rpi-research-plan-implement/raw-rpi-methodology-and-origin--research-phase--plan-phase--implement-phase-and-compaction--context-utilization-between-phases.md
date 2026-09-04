# Research: RPI (Research → Plan → Implement) as a Methodology in Its Own Right

Deep-dive backing research for the "Software Factories" chapter (`src/sw-factories.md`), extending the prior pass in
`notes/2026-08-17-1-sw-factories-dex-horthy-deep-research/` (which established RPI only at a summary level inside its
"Loop Engineering" and "Intentional Compaction" sections). This pass goes phase-by-phase into the mechanics, tooling, and
evidence for RPI. It assumes the reader already knows: the Ralph loop (Geoff Huntley, June 2025), that Horthy's refinement
is "Research → Plan → Implement," the 40–60% context-utilization target, "intentional compaction," and the four-gate
Leverage-Point model.

**Primary-source anchors actually fetched for this pass (full text read, not summaries):**

- [`ace-fca.md` — "Getting AI to Work in Complex Codebases" / "Advanced Context Engineering for Coding Agents"](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md) (raw file, humanlayer repo). This is where the written "research, plan, implement" workflow lives. Based on [a talk given at Y Combinator on August 20, 2025](https://hlyr.dev/ace).
- [`wsff.md` — "Why Software Factories Fail (or: harness engineering is not enough)"](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/wsff.md) (raw file). Based on [Horthy's keynote at AI Engineer World's Fair 2026](https://www.youtube.com/watch?v=Ib5GBkD555M). Contains the four-phase model.
- [`side-quests/where-does-the-time-go.md`](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/side-quests/where-does-the-time-go.md) (raw file) — the "80/20 rule of AI coding leverage" carve-out from `wsff.md`.
- The three actual HumanLayer workflow prompts referenced from `ace-fca.md`, fetched raw from `humanlayer/humanlayer`:
  [`.claude/commands/research_codebase.md`](https://github.com/humanlayer/humanlayer/blob/main/.claude/commands/research_codebase.md),
  [`.claude/commands/create_plan.md`](https://github.com/humanlayer/humanlayer/blob/main/.claude/commands/create_plan.md),
  [`.claude/commands/implement_plan.md`](https://github.com/humanlayer/humanlayer/blob/main/.claude/commands/implement_plan.md). Also inspected the `ralph_research.md` / `ralph_plan.md` / `ralph_impl.md` and `*_generic.md` / `*_nt.md` variants in the same directory.
- [Geoff Huntley, "Ralph Wiggum as a 'software engineer'"](https://ghuntley.com/ralph/) (ghuntley.com, dated 14 Jul 2025) — fetched, key passages extracted.
- [HumanLayer docs — Skills and workflows reference](https://docs.humanlayer.com/reference/skills-workflows) — the shipped `/rpi:*` skill set.

Secondary sources are labelled inline. Findings are tagged **[PRIMARY]** (Horthy's or Huntley's own essay / repo / prompt
files / talk), **[SECONDARY-CORROBORATED]** (multiple independent secondary write-ups agree), or **[SINGLE-SOURCE]** (one
secondary source or blog only).

---

## 1. RPI methodology — origin, definition, primary sources

**The acronym "RPI" is not used in either primary essay.** In `ace-fca.md` Horthy writes it lowercase and hedged:
"We use a **'research, plan, implement'** workflow, but the core capabilities/learnings here are FAR more general than any
specific workflow or set of prompts" ([ace-fca.md](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md)). He also calls the umbrella technique **"frequent intentional compaction"** — "a family of
techniques I call 'frequent intentional compaction' - deliberately structuring how you feed context to the AI throughout
the development process" — and describes research/plan/implement as one concrete instantiation of it, not the point itself.
`wsff.md` describes the same idea as "**4 phases**" (Product Requirements, System Architecture, Program Design, Vertical
Slices) and again never spells out "RPI" in body text. **[PRIMARY]**

The initialism "RPI" surfaces in Horthy's **talk titles and slugs from late 2025 onward**, e.g. the March 2026 talk
["Everything We Got Wrong About RPI"](https://www.youtube.com/watch?v=YwZR6tc7qYg) (`hlyr.dev/qrspi-mlops`,
also given as ["From RPI to QRSPI"](https://www.youtube.com/watch?v=5MWl3eRXVQk) at the Coding Agents conference, Computer
History Museum, March 3 2026). So "RPI" is best treated as **Horthy's own retronym for the workflow, popularised through
his 2026 talks and then adopted wholesale by secondary write-ups** ([LinearB/Dev Interrupted](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop), [Dev Interrupted podcast #262](https://devinterrupted.substack.com/p/dex-horthy-on-ralph-rpi-and-escaping), community repos below), rather than a term coined by a third party. **[SECONDARY-CORROBORATED]**

Timeline of the written record:

- **~April 2025** — Horthy popularises "context engineering" as distinct from prompt engineering (covered in prior notes).
- **June 2025** — Geoff Huntley's Ralph loop appears; Horthy is in the Twitter group DM where Huntley demos it
  ([LinearB](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop), **[SINGLE-SOURCE]** for the DM detail).
- **August 20, 2025** — Horthy's Y Combinator talk that `ace-fca.md` is based on; `ace-fca.md` published late Aug 2025.
  First written statement of the "research, plan, implement" flow. **[PRIMARY]**
- **November 2025** — "No Vibes Allowed — Solving Hard Problems in Complex Codebases" talk
  ([YouTube `rmvDxxNubIg`](https://www.youtube.com/watch?v=rmvDxxNubIg), `hlyr.dev/nva`; `wsff.md` dates it "11/25").
  (One secondary write-up, [htek.dev](https://htek.dev/articles/research-plan-implement-anti-vibe-coding-workflow/), misdates
  this as "AI Engineer World's Fair 2024" — the year is wrong; flag if citing that source.) **[PRIMARY]** for the talk, **[SINGLE-SOURCE + error]** for the htek attribution.
- **March 2026** — "Everything We Got Wrong About RPI" / "From RPI to QRSPI"; RPI now named explicitly, and revised (see §7, §9). **[PRIMARY]**
- **2026** — `wsff.md` published, based on the AI Engineer World's Fair 2026 keynote. **[PRIMARY]**

**Relationship to "context engineering" and the Ralph loop.** Horthy frames the causal chain explicitly in `ace-fca.md`:
LLMs are stateless functions, "the contents of your context window are the ONLY lever you have to affect the quality of
your output," therefore the entire dev process should be engineered around what enters the window. Ralph is Huntley's
minimalist answer to that same constraint (run a dumb bash loop, keep each iteration's context tiny); RPI is Horthy's
higher-structure answer to it for brownfield work. Horthy quotes Huntley's "170k of context window to work with … use as
little of it as possible" directly, then says of Ralph: "Geoff describes ralph as a 'hilariously dumb' solution to the
context window problem. [I'm not entirely sure that it is dumb]." **[PRIMARY]**

---

## 2. The Research phase

**Artifact produced:** a standalone **research document** in markdown, written to a shared `thoughts/` directory
(`thoughts/shared/research/YYYY-MM-DD-ENG-XXXX-description.md` in HumanLayer's repo). `ace-fca.md` links a real example:
[`2025-08-05_05-15-59_baml_test_assertions.md`](https://github.com/ai-that-works/ai-that-works/blob/main/2025-08-05-advanced-context-engineering-for-coding-agents/thoughts/shared/research/2025-08-05_05-15-59_baml_test_assertions.md). **[PRIMARY]**

**What goes in it.** From `ace-fca.md`, the research step is: "Understand the codebase, the files relevant to the issue,
and how information flows, and perhaps potential causes of a problem." From the actual
[`research_codebase.md`](https://github.com/humanlayer/humanlayer/blob/main/.claude/commands/research_codebase.md) prompt,
the document template has these sections: Research Question, Summary, Detailed Findings (per component/area, *with
`file.ext:line` references*), **Code References** (explicit `path/to/file.py:123 – description` list), Architecture
Documentation (existing patterns/conventions), Historical Context (from `thoughts/`), Related Research, and Open Questions.
It carries YAML frontmatter (date, researcher, git commit, branch, repo, topic, tags, status). GitHub permalinks at a
pinned commit are substituted for local paths where possible. **[PRIMARY]**

**What is deliberately excluded.** The `research_codebase.md` prompt is emphatic and repetitive about this — its opening
line is "**CRITICAL: YOUR ONLY JOB IS TO DOCUMENT AND EXPLAIN THE CODEBASE AS IT EXISTS TODAY**", followed by: "DO NOT
suggest improvements or changes … DO NOT perform root cause analysis unless the user explicitly asks … DO NOT propose
future enhancements … DO NOT critique the implementation … ONLY describe what exists, where it exists, how it works, and
how components interact." Sub-agents are told to be "documentarians, not critics." Rationale (implicit): the research doc
is the seed for the *next* fresh session, so it must be pure fact with no speculative drift baked in. **[PRIMARY]**

**Subagents / separate session.** Yes on both counts. Research is its own session (own slash command). Within it, the
main agent spawns **parallel read-only sub-agents** — named `codebase-locator` (finds *where* things live),
`codebase-analyzer` (explains *how* code works, no critique), `codebase-pattern-finder` (finds existing examples),
`thoughts-locator` / `thoughts-analyzer` (mine prior docs). `ace-fca.md` notes the humanlayer repo uses "custom
subagents" but "in other repos I use a more generic version that uses the claude code `Task()` tool with `general-agent`.
The generic one works almost as well." The stated purpose of sub-agents is context hygiene, not role-play: "Subagents are
not about playing house and anthropomorphizing roles. Subagents are about context control" — they let a fresh window
absorb the `Glob`/`Grep`/`Read` noise and hand back only a distilled summary. **[PRIMARY]**

**Verification before moving on.** `ace-fca.md`'s worked BAML example is the canonical illustration of "verify the
research": "I created a piece of research, I read it. Claude decided the bug was invalid and the codebase was correct. I
threw that research out and kicked off a new one, with more steering." The human reads the research doc end-to-end and
either accepts it or discards and re-runs with corrections; there is no partial-edit path at this stage. The shipped
`/rpi:*` skill set adds an explicit gate: a research doc is validated against a "FAR" bar in one community codification
(Factual / Actionable / Relevant) — but note that scale is from [mmanzini/rpi-methodology](https://github.com/mmanzini/rpi-methodology), a **[SINGLE-SOURCE]** community doc, not from HumanLayer.

**The "bad line of research → thousands of bad lines of code" argument.** Verbatim from `ace-fca.md`: "A bad line of
code is… a bad line of code. But a bad line of a **plan** could lead to hundreds of bad lines of code. And a bad line of
**research**, a misunderstanding of how the codebase works or where certain functionality is located, could land you with
thousands of bad lines of code." Hence: "focus human effort and attention on the HIGHEST LEVERAGE parts of the pipeline."
The `wsff.md` "Eggs on Faces" counter-example (the failed 7-hour parquet-java / remove-hadoop attempt) is attributed
squarely to a research miss: "the research steps didn't go deep enough through the dependency tree, and assumed classes
could be moved upstream without introducing deeply nested hadoop dependencies." **[PRIMARY]**

---

## 3. The Plan phase

**Artifact:** an **implementation plan** markdown doc, `thoughts/shared/plans/YYYY-MM-DD-ENG-XXXX-description.md`.
`ace-fca.md` links two real ones for the same BAML bug — [one with no research](https://github.com/ai-that-works/ai-that-works/blob/main/2025-08-05-advanced-context-engineering-for-coding-agents/thoughts/shared/plans/fix-assert-syntax-validation-no-research.md) and [one built on the research doc](https://github.com/ai-that-works/ai-that-works/blob/main/2025-08-05-advanced-context-engineering-for-coding-agents/thoughts/shared/plans/baml-test-assertion-validation-with-research.md) — noting both "would have worked" but the research-backed one "fixed the problem in the *best* place and prescribed testing that was in line with the codebase conventions." **[PRIMARY]**

**Plan-document contents.** From `ace-fca.md`: "Outline the exact steps we'll take to fix the issue, and the files we'll
need to edit and how, being super precise about the testing / verification steps in each phase." From the actual
[`create_plan.md`](https://github.com/humanlayer/humanlayer/blob/main/.claude/commands/create_plan.md) template:

- **Overview**, **Current State Analysis**, **Desired End State** (+ "how to verify it"), **Key Discoveries** (with
  `file:line` refs), **What We're NOT Doing** (explicit out-of-scope list to prevent scope creep).
- **Per-phase sections**: "Changes Required" listed file-by-file (`**File**: path` + summary + a fenced code block of the
  *specific code to add/modify*), then **Success Criteria split into two named buckets**:
  - **Automated Verification** — runnable commands (`make migrate`, `go test ./...`, `npm run typecheck`, `golangci-lint
    run`, `curl localhost:8080/...`); the prompt insists automated steps "use `make` whenever possible."
  - **Manual Verification** — UI/UX, performance under load, edge cases hard to automate.
  - Each phase ends with a literal instruction: "After completing this phase and all automated verification passes, pause
    here for manual confirmation from the human … before proceeding to the next phase."
- **Testing Strategy** (unit / integration / manual steps), Performance Considerations, Migration Notes, References.
- Hard rule: "**No Open Questions in Final Plan** … If you encounter open questions during planning, STOP … Every decision
  must be made before finalizing the plan." **[PRIMARY]**

Type/method signatures and call-stack ordering are a `wsff.md`-era addition, landing in the **Program Design** gate rather
than the generic plan: "we go a level down from architecture into the **shape of code**: the types, the method signatures,
the program layout, and the call stacks" — expressed as call-stack trees (diff syntax), file-tree diffs, and TypeScript
interface/function-signature stubs "for the key new functions — the stuff that's too internal for an architecture doc but
that an agent might still get wrong." **[PRIMARY]**

**"Least confident decisions."** The prior notes attributed "an explicit list of the least confident design decisions" to
the David Ondrej-podcast four-gate summary. `wsff.md`'s Program Design section corroborates the substance in Horthy's own
words: the doc should surface "the decisions the agent is least confident about" (as rendered in the
[Maciejdziuba gist](https://gist.github.com/Maciejdziuba/88890d7e0eeefa5a8738bbe9fd5e20b8): "file locations, type
signatures … call stacks, test cases, and 'the decisions the agent is least confident about'"). Treat the exact phrasing
as **[SECONDARY-CORROBORATED]** (gist + talk summaries), the concept as **[PRIMARY]** (`wsff.md`).

**Why the plan is the highest-leverage review artifact.** `ace-fca.md`: "When you review the research and the plans, you
get more leverage than you do when you review the code." And: "I can't read 2000 lines of golang daily. But I *can* read
200 lines of a well-written implementation plan." `wsff.md` frames the Program Design artifacts as "every one of them is a
decision you'd otherwise be making implicitly during code review — at the most expensive possible time to change your
mind." **[PRIMARY]**

**How human review of the plan works.** `create_plan.md` mandates an interactive, multi-checkpoint process — "Don't write
the full plan in one shot. Get buy-in at each major step" — with the agent presenting informed understanding + focused
questions, then a phase outline for approval, then the draft doc for line review ("Are the phases properly scoped? Are the
success criteria specific enough?"). The shipped `/rpi:*` skills split this into `create-plan` / `iterate-plan` (and, in
the QRSPI revision, `create-design-discussion`, `create-tdd`, `create-outline` with separate approvals for "System Design"
and "Program Design"), where "Feedback on an outline or plan revises the document — it never starts implementation"
([HumanLayer docs](https://docs.humanlayer.com/reference/skills-workflows)). **[PRIMARY]**

**Relationship to Claude Code "plan mode."** Not addressed in either essay or the prompt files (the prompts predate or
ignore it; `create_plan.md` drives planning through an ordinary session + slash command + a written artifact, not the
built-in plan-mode toggle). Any equivalence is the book's own analysis, not Horthy's: Claude Code plan mode enforces
read-only tool use and ends with an approve/reject step, which mirrors RPI's plan gate at the tool level but produces an
ephemeral in-context plan rather than RPI's durable, re-seedable markdown file. Flag as **[not in primary sources]**.

---

## 4. The Implement phase

**Execution model.** From `ace-fca.md`: "Step through the plan, phase by phase. For complex work, I'll often compact the
current status back into the original plan file after each implementation phase is verified." From
[`implement_plan.md`](https://github.com/humanlayer/humanlayer/blob/main/.claude/commands/implement_plan.md): "Implement
each phase fully before moving to the next … Update checkboxes in the plan as you complete sections … Check off completed
items in the plan file itself using Edit." **[PRIMARY]**

**What "compacting status between phases" means concretely.** Three moves, from the prompt files:

1. **Write progress into the plan doc itself** — the agent edits `- [ ]` → `- [x]` on completed items and (for complex
   work) appends a status note back into the plan file. The plan file thus doubles as the durable state store.
2. **End the session / clear context** — `implement_plan.md` assumes one phase per invocation by default: "If instructed
   to execute multiple phases consecutively, skip the pause until the last phase. Otherwise, assume you are just doing one
   phase."
3. **Resume in a fresh session** — "If the plan has existing checkmarks: Trust that completed work is done. Pick up from
   the first unchecked item. Verify previous work only if something seems off." The re-seeded context is: the plan file
   (with checkmarks) + the original ticket + files the plan references. **[PRIMARY]**

**Verification during implementation.** After each phase the agent runs the plan's own Automated Verification commands
("usually `make check test` covers everything"), fixes failures before proceeding, then **pauses for human manual
verification** using a fixed template ("Phase [N] Complete — Ready for Manual Verification / Automated verification
passed: … / Please perform the manual verification steps: …"). Rule: "do not check off items in the manual testing steps
until confirmed by the user." Sub-agents are used "sparingly — mainly for targeted debugging or exploring unfamiliar
territory." **[PRIMARY]**

**How much human involvement.** Least of the three phases, but non-zero and deliberately so. `wsff.md`: "in most cases,
I'll send off a model to do 1-3 slices at a time, and review the code as I go … It's a lot easier to resteer early on …
than to end up on the other side of 2k+ lines of code with no idea what's broken." And, on the Vertical-Slices approach
specifically: "If I care about the code a lot or [am] skeptical about the model's ability to do good work in this part of
the codebase, I'm reviewing the code at each step too. Checking 100-200 lines and resteering is a lot cheaper."
`ace-fca.md`: "you have to engage with your task when you're doing this or it WILL NOT WORK." **[PRIMARY]**

**Worktree note.** `ace-fca.md`: "if you've been hearing a lot about git worktrees, this is the only step that needs to
be done in a worktree. We tend to do everything else on main." (Research and Plan produce only markdown, committed to
`main` / synced via HumanLayer's "thoughts tool"; only Implement touches source.) **[PRIMARY]**

---

## 5. Context-window utilization between phases

**The 40–60% target — verbatim.** `ace-fca.md`: "Essentially, this means designing your ENTIRE WORKFLOW around context
management, and keeping utilization in the **40%-60% range** (depends on complexity of the problem)." And on the split:
"The way we do it is to split into three (ish) steps. I say 'ish' because sometimes we skip the research and go straight
to planning, and sometimes we'll do multiple passes of compacted research before we're ready to implement." **[PRIMARY]**

**Phase boundaries as deliberate context resets.** Each RPI phase is a *new conversation*, seeded only by the previous
phase's markdown artifact rather than the raw transcript. This is the "intentional compaction" mechanism operating as the
connective tissue between phases: `ace-fca.md`'s "Slightly Smarter: Intentional Compaction" section describes the generic
move ("Write everything we did so far to progress.md … then start over with a fresh context window"), and RPI is that move
applied at three fixed, pre-planned points instead of ad hoc when the window fills. The essay's list of "what eats up
context" (searching for files, understanding code flow, applying edits, test/build logs, huge JSON blobs from tools) is
exactly what the research doc / plan doc strip back out. **[PRIMARY]**

**Placement relative to the "dumb zone."** The prior notes established the "dumb zone" as a mostly-spoken term for the
40–60% mid-window degradation band; `ace-fca.md` itself only says to keep utilization *in* 40–60% and never let a session
run long. The QRSPI-era practitioner distillation tightens this to "keep context window utilization under 40%; start fresh
at 60%" ([alexlavaee.me](https://alexlavaee.me/blog/from-rpi-to-qrspi/)), i.e. the phase boundary is meant to land *before*
the smart zone ends, not at the point of observed degradation. Treat "under 40% / fresh at 60%" as **[SINGLE-SOURCE]**
(one practitioner blog reporting on the March 2026 talk); the 40–60% band itself is **[PRIMARY]**.

**Specific token figures Horthy gives.** He gives *none of his own* in `ace-fca.md` — he quotes Geoff Huntley's number
instead: "you only have approximately **170k of context window** to work with. So it's essential to use as little of it as
possible. The more you use the context window, the worse the outcomes you'll get." (Huntley's ghuntley.com/ralph adds a
degradation onset "around 147k–152k usage" — **[PRIMARY]** to Huntley, **[SINGLE-SOURCE]** overall.) The "smart zone ~300–400k
for 1M-context frontier models, ~100k for smaller models" figures are from Horthy's *talks* via secondary reporting
(prior notes), not `ace-fca.md`. **[PRIMARY]** for the 170k quote; **[SECONDARY]** for the 300–400k / 100k figures.

---

## 6. Brownfield vs greenfield applicability

**`ace-fca.md` is framed entirely around brownfield / complex codebases** — its original title is literally "Getting AI to
Work in Complex Codebases," and its four goals are "AI that Works Well in Brownfield Codebases / AI that Solves Complex
Problems / No Slop / Maintain Mental Alignment across the team." It cites Yegor's Stanford-study finding that "AI tools
work well for greenfield projects, but are often counter-productive for brownfield codebases and complex tasks" as the
problem RPI is built to solve. **[PRIMARY]**

**However — the specific claim that RPI "falls flat on greenfield" is NOT in either essay.** It is a
secondary-source paraphrase (used in the prior notes, sourced to [LinearB](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop) and echoed by [htek.dev](https://htek.dev/articles/research-plan-implement-anti-vibe-coding-workflow/): RPI is "specifically tailored for agentic coding in brownfield codebases" and "falls flat for greenfield work"). What the *essays* actually say about greenfield:

- `ace-fca.md`, on the team's own origin story: "Our approach was to adopt something like sean's **spec-driven
  development**" — referencing [Sean Grove's "Specs are the new code" talk](https://www.youtube.com/watch?v=8rABwKRsec4).
- `ace-fca.md` closing: "We're pretty bullish on **spec-first, agentic workflows**."
- `wsff.md` never uses "greenfield"; it draws the line at "brownfield" meaning any codebase (including an agent-built one)
  that "starts to struggle after maybe **three to six months**" — at which point "the way you approach adding new things
  has to change."

So: **the essays' position is "brownfield → research-first RPI; greenfield / new features → spec-first (à la Sean Grove)."**
The blunt "RPI falls flat on greenfield" framing should be attributed to Horthy's spoken talks / secondary write-ups, not
quoted as if from `ace-fca.md`. **[SECONDARY-CORROBORATED]** for the brownfield-vs-greenfield split; **[PRIMARY]** only for
the softer "we're bullish on spec-first" wording. The mechanism is intuitive and stated across sources: on greenfield there
is no existing system to *research*, so the Research phase has little to bite on and a written product/behaviour spec is
the higher-value upfront artifact.

The QRSPI revision partially dissolves the distinction by adding a product-design track (PRD workflow) alongside the
codebase-research track, so the shipped tool now has a "PRD-Oriented" workflow for feature/greenfield work and an "RPI"
workflow for brownfield ([HumanLayer docs](https://docs.humanlayer.com/reference/skills-workflows)). **[PRIMARY]**

---

## 7. RPI vs spec-driven development and vs the four-gate Leverage-Point model

**(a) RPI (3-phase per-task loop) vs the factory-level four-gate model.** These are **the same idea at two different
granularities and two different dates**, from the same author:

| | RPI (`ace-fca.md`, Aug 2025) | Four-gate Leverage-Point model (`wsff.md`, 2026) |
|---|---|---|
| Phases | Research → Plan → Implement (3, "ish") | Product Review → System Architecture → Program Design → Vertical Slices (4) |
| Framed as | per-feature / per-bug agent workflow | factory-level pre-planning process with human approval gates |
| Where review lands | research doc + plan doc | one human-approved doc per gate + `00-status.md` |
| Greenfield handling | weak (spec-first instead) | Product Review gate covers it |

The four-gate model is essentially **RPI's "Plan" phase exploded into three ordered sub-gates (Product / Architecture /
Program Design) plus RPI's "Implement" phase reshaped as Vertical Slices**, with RPI's "Research" folded into the
Architecture gate ("grounded in actual codebase inspection"). `wsff.md` presents the four phases as the answer to the same
question `ace-fca.md` asked ("focus human effort on the highest-leverage parts of the pipeline"). The March 2026
"Everything We Got Wrong About RPI" talk makes the lineage explicit and revises again into **QRSPI / CRISPI** — adding a
**Questions** phase before Research and a **Design Discussion** + **Structure Outline** between Research and Plan, because
(per [multiple](https://alexlavaee.me/blog/from-rpi-to-qrspi/) [secondary](https://podwise.ai/episodes/7669928)
write-ups of the talk) the clean 3-phase boundary was "a useful fiction" — in practice good agents iterate back and forth
between Research and Plan, and over-detailed plan files created a "plan-reading illusion" where "reading a plan is not the
same as validating a plan." **[PRIMARY]** for the two models; **[SECONDARY-CORROBORATED]** for the QRSPI phase names and the
"useful fiction" framing (talk not directly transcribed in this pass).

**(b) RPI vs SDD / GitHub Spec Kit "Specify → Plan → Tasks → Implement."** Structurally near-identical four-stage
pipelines with a different centre of gravity:

- **Spec Kit** ([github.blog](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/), [Microsoft for Developers](https://developer.microsoft.com/blog/spec-driven-development-spec-kit/)):
  `/specify` a *what/why* spec → `/plan` a technical plan → `/tasks` a task breakdown → `/implement`. Greenfield-friendly;
  the spec is the source of truth; no explicit "go read the existing codebase" phase.
- **RPI**: leads with **Research** (document the existing system, `file:line` accurate) precisely because the target is
  brownfield. Its "Plan" ≈ Spec Kit's `/plan` + `/tasks` merged. Both end in a mechanical Implement step against a
  checkbox list.
- **Genuinely different:** RPI's insistence on a *research/discovery* artifact and on 40–60% context resets between
  phases; Spec Kit's insistence on a machine-readable spec/constitution and templated command scaffolding. **Same idea:**
  front-load a human-reviewed *what*, then a human-reviewed *how*, then let the agent execute against it. **[SECONDARY-CORROBORATED]** (both frameworks publicly documented; the comparison is the book's synthesis).

**(c) Addy Osmani's "waterfall in 15 minutes."** Same idea, different label — the observation that AI compresses a
full plan-design-build-test cycle into minutes, so it pays to *do the cycle* rather than skip to build. Osmani is thanked
by name in `wsff.md`'s acknowledgements and his vibe-coding-vs-maintenance distinction is quoted at length there
("A developer vibe-coding a side project a dozen people will ever run, and a team keeping a ten-year-old enterprise system
alive for another quarter, share almost no constraints worth naming"). So Horthy and Osmani are explicitly in dialogue;
"waterfall in 15 minutes" and RPI/four-gate are the same underlying claim from two writers. **[PRIMARY]** for the
Horthy↔Osmani link; the "waterfall in 15 minutes" phrasing itself is Osmani's (prior-notes / chapter, not re-verified this pass).

---

## 8. RPI and the Ralph loop / loop engineering

**How RPI layers on the bare Ralph loop.** Ralph (Huntley) = `while :; do cat PROMPT.md | <agent>; done` — one item per
loop, deterministic stack of files (`fix_plan.md`, `specs/`, `AGENT.md`, `PROMPT.md`), reset with `git reset --hard` when
a loop trashes the tree ([ghuntley.com/ralph](https://ghuntley.com/ralph/)). Huntley's own words: "Ralph is a technique.
In its purest form, Ralph is a Bash loop"; "the technique is deterministically bad in an undeterministic world"; "One item
per loop. I need to repeat myself here—one item per loop." He already splits work into **two phases — "Generate" and
"Backpressure"** (types, tests, security scanners, static analysers) — so a phase concept predates RPI on the Ralph side.
**[PRIMARY]**

RPI keeps Ralph's core discipline (tiny per-iteration context, frequent resets, a plan file as durable state) and adds:
(1) an explicit upstream **Research** artifact, (2) a human **approval gate** on research and plan before any code, (3)
structured per-phase verification. HumanLayer actually ships RPI *as* Ralph-style loop commands —
[`.claude/commands/ralph_research.md` / `ralph_plan.md` / `ralph_impl.md`](https://github.com/humanlayer/humanlayer/tree/main/.claude/commands) — which pull the highest-priority Linear ticket, run the corresponding RPI phase, write the artifact to
`thoughts/`, move the ticket to a "…in review" column, and stop. I.e. each RPI phase can itself be the body of a Ralph
loop, with the Linear board as the loop's work queue and "in review" columns as the human gates. **[PRIMARY]**

**"Simpler loops fail in simpler ways."** This is a real, repeated Horthy/Huntley talking point (prior notes;
[LinearB](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop) renders it "Simpler loops fail in
simpler, more diagnosable ways"). It does **not appear verbatim in `ace-fca.md`, `wsff.md`, or ghuntley.com/ralph** — it's
from their spoken commentary (e.g. the ["Great Loops Debate" panel](https://www.youtube.com/watch?v=c35YoMdnI78) with
Horthy, Huntley et al. at AIE World's Fair 2026). Treat as **[SECONDARY-CORROBORATED]** (multiple write-ups, consistent
wording, but no fetched primary transcript).

**Loop or linear one-pass?** Both, depending on framing. `ace-fca.md`'s worked examples read as a **linear one-pass**
workflow with human checkpoints (research → read it → plan → read it → implement phase-by-phase). The `ralph_*` commands
wrap the phases in a **loop** over a ticket queue. `wsff.md`'s distribution ("~40% of tasks get oneshot") shows RPI is
applied selectively, not as a blanket loop. The QRSPI revision's "phases function more like a negotiation" framing
explicitly rejects a rigid linear pass in favour of Research↔Plan iteration. **[PRIMARY]** / **[SECONDARY]** as noted.

---

## 9. Tooling and adoption

**HumanLayer's own, verifiable:**

- The three canonical prompts in `humanlayer/humanlayer` `.claude/commands/`: `research_codebase.md`, `create_plan.md`,
  `implement_plan.md` (plus `_generic` variants that swap custom sub-agents for the stock `Task()` tool, `_nt` variants,
  and `iterate_plan.md`, `validate_plan.md`, `create_handoff.md`, `oneshot.md`, `ralph_research/plan/impl.md`). Linked
  directly from `ace-fca.md`. **[PRIMARY, verified]**
- The shipped **`/rpi:*` skill set** documented at [docs.humanlayer.com/reference/skills-workflows](https://docs.humanlayer.com/reference/skills-workflows) — 22 commands across four selectable workflows (**RPI**, **PRD-Oriented**,
  **Oneshot**, **Freeform**). RPI-workflow phase order there: "Questions, research, design discussion, structure outline,
  implementation, PR." Artifacts numbered `01-`, `02-`… in `.humanlayer/tasks/<task-slug>/`; documented precedence when
  artifacts conflict: "plan > outline > TDD > PRD > design discussion > research > ticket," and "during research, live
  code beats any document." Auto-advance transitions between phases; `/rpi:iterate-*` skills for resuming a phase in a
  fresh session. **[PRIMARY, verified]** This is the current productised form of RPI (post-QRSPI).
- `CodeLayer` / `humanlayer.com` — the "post-IDE IDE" / agentic collaboration product built to scale these workflows
  across teams (`ace-fca.md` launch note; `wsff.md` PS). **[PRIMARY]**

**Third-party implementations (verify individually before citing):**

- [`bostonaholic/rpikit`](https://github.com/bostonaholic/rpikit) — "A Claude Code plugin implementing the
  Research-Plan-Implement (RPI) framework"; runs the full pipeline in one session with parallel sub-agents + approval
  gates between phases, implementation in an isolated worktree. **[SINGLE-SOURCE / real repo, unaudited]**
- [`mmanzini/rpi-methodology`](https://github.com/mmanzini/rpi-methodology) — documentation repo; codifies "FAR"
  (research: Factual/Actionable/Relevant) and "FACTS" (plan: Feasible/Atomic/Clear/Testable/Scoped) validation scales,
  and an "instruction budget" of ~150–200 that it itself flags as "partially supported by academic research but not
  rigorously validated by HumanLayer." Attributes RPI to "HumanLayer (Dexter Horthy, 2024)" [sic — the written workflow
  is 2025] and claims adoption "by Block's Goose tool and documented by Kilo.ai." **[SINGLE-SOURCE]** — the Goose/Kilo
  adoption claims were **not independently verified in this pass**; treat as unconfirmed.
- [`acampb/claude-rpi-framework`](https://github.com/acampb/claude-rpi-framework) — setup scripts/commands for RPI in
  Claude Code. **[SINGLE-SOURCE / real repo, unaudited]**
- The [Maciejdziuba gist](https://gist.github.com/Maciejdziuba/88890d7e0eeefa5a8738bbe9fd5e20b8) (four-gate workflow as an
  installable skill, transcribed from a David Ondrej podcast with Horthy) — this is the source the prior notes leaned on
  for `00-status.md` and "Approve Gate N, or what should change?"; it is a **[SINGLE-SOURCE]** community transcription, not a
  HumanLayer artifact, though its content lines up with `wsff.md`.
- Practitioner write-ups reporting adoption: [htek.dev](https://htek.dev/articles/research-plan-implement-anti-vibe-coding-workflow/) (author says they adopted RPI after an AI-generated hallucinated article — "PR #105" — nearly shipped);
  [alexlavaee.me](https://alexlavaee.me/blog/from-rpi-to-qrspi/). Both **[SINGLE-SOURCE]** blogs.

**Adjacent structured-planning tools people compare RPI to** (all real, independently verifiable projects; the *comparison*
is practitioner commentary, **[SECONDARY]**):

- **GitHub Spec Kit** — `/specify → /plan → /tasks → /implement` ([github.blog](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)).
- **Kiro** (AWS) — spec-driven IDE (requirements → design → tasks).
- **CCPM / Claude Code PM** ([`automazeio/ccpm`](https://github.com/automazeio/ccpm)) — GitHub-Issues-backed
  spec→epic→task→PR pipeline with parallel agents. (Real repo; not re-verified this pass.)
- **BMAD-METHOD** ("Breakthrough Method of Agile AI-Driven Development") — agent-persona planning framework. (Real; not
  re-verified.)

---

## 10. Evidence and corroboration

**"Ship 2–3x faster without AI slop" — the HumanLayer claim.** Stated in `wsff.md` in Horthy's own words: "you could
embrace the constraints and move **2-3x faster, safely**"; and the product PS: "helping you move 2-3x faster while
maintaining a human (or pretty-dang-close-to-human) level of code quality." YC's HumanLayer page carries the same line
("ship 2-3x faster without AI slopping up your codebase," prior notes). This is **Horthy self-reported**, from his own
team's experience; no external audit. **[PRIMARY, self-reported]**

**The named case study behind it — BAML.** Concrete and verifiable in `ace-fca.md`:

- **[BoundaryML/baml PR #2259](https://github.com/BoundaryML/baml/pull/2259#issuecomment-3155883849)** — a bug fix in a
  "300k LOC Rust codebase" (BAML, a language for working with LLMs). Horthy: "at best an amateur Rust dev … never worked
  in the BAML codebase before." "Within an hour or so" to a PR, "approved by @aaron the next morning." A competing
  no-research plan produced [PR #2258](https://github.com/BoundaryML/baml/pull/2258/files), which was closed. The bug
  itself: [BAML issue #1252](https://github.com/BoundaryML/baml/issues/1252) (test-assertion syntax validation) — Horthy
  calls it "an (admittedly small-ish) bug."
- **Larger follow-up:** ~35k LOC across two PRs — [cancellation support #2357](https://github.com/BoundaryML/baml/pull/2357)
  (reported merged) and [WASM compilation #2330](https://github.com/BoundaryML/baml/pull/2330) (reported still open, with a
  working browser demo). "7 hours (3 hours on research/plans, 4 hours on implementation)," paired with BAML's
  [@hellovai / Vaibhav Gupta](https://x.com/hellovai). "Vaibhav estimated that each of these PRs would have been 3-5 days
  of work for a senior engineer on the BAML team." **[PRIMARY, self-reported]** — the PR numbers and repo are real and
  checkable; the time and effort figures are Horthy's account. (PR merge status as of the essay; not re-checked live this
  pass.)
- **Counter-example, same essay:** the parquet-java / remove-hadoop attempt with [@blakesmith], 7 hours, "did not go
  well" — [plan doc](https://github.com/dexhorthy/parquet-java/blob/remove-hadoop/thoughts/shared/plans/remove-hadoop-dependencies.md). Horthy publishes his failures alongside his wins. **[PRIMARY]**
- Other self-reported throughput: "team of three averaging about $12k on opus per month"; "our intern shipped 2 PRs on his
  first day, and 10 on his 8th day"; "I shipped 6 PRs in a day"; "2 weeks spinning circles on a really tricky race
  condition" (MCP sHTTP keepalives). All **[PRIMARY, self-reported, unaudited]**.

**Independent studies supporting "front-load planning":**

- **The MIT Sloan / Microsoft Research / GitHub "56%" figure — MISATTRIBUTED in the chapter as currently described.**
  The 56% traces to [Peng, Kalliamvakou, Cihon, Demirer, "The Impact of AI on Developer Productivity: Evidence from GitHub
  Copilot" (arXiv 2302.06590, 2023)](https://arxiv.org/abs/2302.06590): 95 contract developers, build an HTTP server in
  JavaScript, treatment group "completed the task **55.8% faster** (95% CI: 21–89%)" — 71 min vs 161 min. That is a
  **plain GitHub Copilot autocomplete RCT on a greenfield toy task**, with **no spec / plan / upfront-planning
  manipulation whatsoever**. It is often re-hosted under MIT (mit-genai.pubpub.org) and summarised by MIT Sloan, which is
  likely where the "MIT Sloan" attribution came from. The chapter's phrasing ("spec-driven upfront planning associated
  with 56% reduction in programming time") **does not match this study** and I could not find any MIT/MSR/GitHub study that
  does support that specific sentence. **Recommend the chapter either (a) drop the "spec-driven upfront planning"
  gloss and cite 2302.06590 accurately as a general Copilot-speed result, or (b) replace it with a study that actually
  manipulates planning.** **[independently checked — flag]**
- **Better-matched corroboration for the planning thesis** (from `wsff.md` / prior notes, still valid): the MIT
  Sloan / GitHub time-allocation study ([Hoffmann, Boysel, Nagle, Peng, Xu, "Generative AI and the Nature of Work"](https://mitsloan.mit.edu/ideas-made-to-matter/generative-ai-changes-how-employees-spend-their-time)) — Copilot users
  spend +12.4% of time on core coding and −24.9% on project-management tasks; directionally consistent with "coding is no
  longer the bottleneck, the surrounding work is," but not a 56% planning result. **[SECONDARY-CORROBORATED]**
- **Addy Osmani / Microsoft & GitHub Spec Kit** "a small amount of upfront work to create a spec and a plan ensures the AI
  builds what you actually intend" ([Microsoft for Developers](https://developer.microsoft.com/blog/spec-driven-development-spec-kit/)) — supports the thesis qualitatively, no controlled number. **[SECONDARY]**

**Reward-hacking / maintainability literature** (already in the chapter, re-confirmed from `wsff.md` this pass):
SWE-bench Multilingual scores only `FAIL_TO_PASS` + `PASS_TO_PASS`, "there is **no penalty** for eroding codebase
maintainability"; "Tests give you feedback in seconds, but the cost function of bad architecture is measured in weeks,
months, maybe even years"; "if a model could reliably tell good code from bad, it might have written the good version to
begin with, but **maintainability has no fast oracle**, so we can't reward for it during RL." Frontier attempts named:
[SWE-Marathon](https://www.swe-marathon.org/) (~400-hr tasks, compound reward), [DeepSWE](https://deepswe.datacurve.ai/blog/deepswe), [Frontier Code](https://cognition.com/blog/frontier-code) (Cognition — mutation-testing-style check + a
judge model over the diff for code-quality rules). **[PRIMARY]** (Horthy's essay) + the benchmarks are real.

**Faros AI "Acceleration Whiplash" report** (correlational, cited in `wsff.md`): +25% review comments, +22.7% longer
comments, +31.3% of PRs skip review entirely, incidents per PR +242.7%, monthly incidents +57.9%, bugs per developer
+54%. Horthy himself calls it "more of a correlation signal than a verifiable smoking gun." Supports "too many bad PRs,"
not RPI specifically. **[PRIMARY citation of a SECONDARY dataset]**

**Bottom line on evidence:** RPI's *speed/quality* payoff is **entirely Horthy-self-reported** (2–3x; BAML PRs — real PRs,
self-reported effort). The *general* "front-load planning / coding isn't the bottleneck" thesis is **independently
corroborated qualitatively** (MIT Sloan time-allocation, Spec Kit, Osmani) but the **specific "56%" number the chapter
attaches to it is misattributed** and should be fixed. The *negative* case (lights-off fails, maintainability has no
oracle) is the best-supported part — Horthy's own named failure plus the Faros telemetry plus the benchmark-design
argument.

---

## Sources

1. [`ace-fca.md` — "Getting AI to Work in Complex Codebases" / "Advanced Context Engineering for Coding Agents" (raw, humanlayer repo)](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md)
2. [`wsff.md` — "Why Software Factories Fail" (raw, humanlayer repo)](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/wsff.md)
3. [`side-quests/where-does-the-time-go.md` (raw, humanlayer repo)](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/side-quests/where-does-the-time-go.md)
4. [`humanlayer/humanlayer` `.claude/commands/research_codebase.md`](https://github.com/humanlayer/humanlayer/blob/main/.claude/commands/research_codebase.md)
5. [`humanlayer/humanlayer` `.claude/commands/create_plan.md`](https://github.com/humanlayer/humanlayer/blob/main/.claude/commands/create_plan.md)
6. [`humanlayer/humanlayer` `.claude/commands/implement_plan.md`](https://github.com/humanlayer/humanlayer/blob/main/.claude/commands/implement_plan.md)
7. [`humanlayer/humanlayer` `.claude/commands/` — ralph_research / ralph_plan / ralph_impl and generic/nt variants](https://github.com/humanlayer/humanlayer/tree/main/.claude/commands)
8. [Geoff Huntley — "Ralph Wiggum as a 'software engineer'" (ghuntley.com/ralph, 14 Jul 2025)](https://ghuntley.com/ralph/)
9. [HumanLayer docs — Skills and workflows reference (`/rpi:*` skill set)](https://docs.humanlayer.com/reference/skills-workflows)
10. [BoundaryML/baml PR #2259 (research-backed bug fix, approved)](https://github.com/BoundaryML/baml/pull/2259#issuecomment-3155883849)
11. [BoundaryML/baml PR #2258 (no-research plan, closed)](https://github.com/BoundaryML/baml/pull/2258/files)
12. [BoundaryML/baml issue #1252 (the bug)](https://github.com/BoundaryML/baml/issues/1252)
13. [BoundaryML/baml PR #2357 (cancellation support)](https://github.com/BoundaryML/baml/pull/2357)
14. [BoundaryML/baml PR #2330 (WASM compilation)](https://github.com/BoundaryML/baml/pull/2330)
15. [dexhorthy/parquet-java remove-hadoop plan doc (the failed attempt)](https://github.com/dexhorthy/parquet-java/blob/remove-hadoop/thoughts/shared/plans/remove-hadoop-dependencies.md)
16. [ai-that-works — BAML research doc example](https://github.com/ai-that-works/ai-that-works/blob/main/2025-08-05-advanced-context-engineering-for-coding-agents/thoughts/shared/research/2025-08-05_05-15-59_baml_test_assertions.md)
17. [ai-that-works — BAML plan (no research)](https://github.com/ai-that-works/ai-that-works/blob/main/2025-08-05-advanced-context-engineering-for-coding-agents/thoughts/shared/plans/fix-assert-syntax-validation-no-research.md)
18. [ai-that-works — BAML plan (with research)](https://github.com/ai-that-works/ai-that-works/blob/main/2025-08-05-advanced-context-engineering-for-coding-agents/thoughts/shared/plans/baml-test-assertion-validation-with-research.md)
19. [Sean Grove — "The New Code" / "Specs are the new code" (YouTube)](https://www.youtube.com/watch?v=8rABwKRsec4)
20. ["No Vibes Allowed — Solving Hard Problems in Complex Codebases" — Dex Horthy (YouTube rmvDxxNubIg)](https://www.youtube.com/watch?v=rmvDxxNubIg)
21. ["Everything We Got Wrong About Research-Plan-Implement" — Dexter Horthy (YouTube YwZR6tc7qYg)](https://www.youtube.com/watch?v=YwZR6tc7qYg)
22. ["From RPI to QRSPI" — Dexter Horthy, Coding Agents 2026 (YouTube 5MWl3eRXVQk)](https://www.youtube.com/watch?v=5MWl3eRXVQk)
23. ["The Great Loops Debate" — Horthy, Huntley, et al., AIE World's Fair 2026 (YouTube c35YoMdnI78)](https://www.youtube.com/watch?v=c35YoMdnI78)
24. [LinearB / Dev Interrupted — "Ralph loops make agentic coding reliable with ruthless context resets"](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop)
25. [Dev Interrupted (Substack) — "Dex Horthy on Ralph, RPI, and escaping the 'Dumb Zone'"](https://devinterrupted.substack.com/p/dex-horthy-on-ralph-rpi-and-escaping)
26. [htek.dev — "Research → Plan → Implement — The Anti-Vibe-Coding Workflow"](https://htek.dev/articles/research-plan-implement-anti-vibe-coding-workflow/)
27. [alexlavaee.me — "From RPI to QRSPI: Rebuilding the First Structured Workflow for Coding Agents"](https://alexlavaee.me/blog/from-rpi-to-qrspi/)
28. [Podwise — "Everything We Got Wrong About Research-Plan-Implement" (AAIF Live) episode notes](https://podwise.ai/episodes/7669928)
29. [Maciejdziuba gist — "The Software Factory Playbook" 4-gate skill (from David Ondrej podcast)](https://gist.github.com/Maciejdziuba/88890d7e0eeefa5a8738bbe9fd5e20b8)
30. [bostonaholic/rpikit — Claude Code plugin implementing RPI](https://github.com/bostonaholic/rpikit)
31. [mmanzini/rpi-methodology — community RPI documentation (FAR / FACTS scales)](https://github.com/mmanzini/rpi-methodology)
32. [acampb/claude-rpi-framework — RPI setup for Claude Code](https://github.com/acampb/claude-rpi-framework)
33. [GitHub Blog — "Spec-driven development with AI: get started with a new open source toolkit" (Spec Kit)](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
34. [Microsoft for Developers — "Diving Into Spec-Driven Development With GitHub Spec Kit"](https://developer.microsoft.com/blog/spec-driven-development-spec-kit/)
35. [Peng et al. — "The Impact of AI on Developer Productivity: Evidence from GitHub Copilot" (arXiv 2302.06590) — the real source of the "56% faster" figure](https://arxiv.org/abs/2302.06590)
36. [MIT Sloan Ideas Made to Matter — "Generative AI changes how employees spend their time" (Hoffmann, Boysel, Nagle, Peng, Xu)](https://mitsloan.mit.edu/ideas-made-to-matter/generative-ai-changes-how-employees-spend-their-time)
37. [MIT GenAI (pubpub) re-host of the GitHub Copilot field-experiment paper](https://mit-genai.pubpub.org/pub/v5iixksv)
38. [SWE-bench Multilingual dataset (Hugging Face)](https://huggingface.co/datasets/SWE-bench/SWE-bench_Multilingual)
39. [SWE-Marathon](https://www.swe-marathon.org/)
40. [Frontier Code — Cognition](https://cognition.com/blog/frontier-code)
41. [Faros AI — "The AI Acceleration Whiplash" report](https://www.faros.ai/research/ai-acceleration-whiplash)
42. [12-factor-agents (GitHub, humanlayer)](https://github.com/humanlayer/12-factor-agents)
