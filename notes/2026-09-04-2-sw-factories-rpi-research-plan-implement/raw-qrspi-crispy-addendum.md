# Addendum: QRSPI and CRISPI / CRISPY

Follow-up to the main raw file in this folder, researched the same day (2026-09-04) in the same session after the user
asked whether the "QRSPI" and "CRISPY" variants of RPI deserve their own treatment in the chapter. Targeted web research
(no subagent), sources labelled inline. The main file's §7 and §1 already flagged QRSPI/CRISPI as secondary-sourced from
Horthy's March 2026 talk; this addendum firms that up and settles what CRISPY is.

## What QRSPI is

**Horthy's own revision of RPI**, presented in the talk **"Everything We Got Wrong About Research-Plan-Implement"**
([YouTube `YwZR6tc7qYg`](https://www.youtube.com/watch?v=YwZR6tc7qYg)), also given as **"From RPI to QRSPI"** at the
Coding Agents conference (Computer History Museum, ~3 March 2026). No dedicated essay exists — the
`humanlayer/advanced-context-engineering-for-coding-agents` repo still contains only `ace-fca.md` and `wsff.md` (plus two
unrelated benchmark files), confirmed by directory listing. So QRSPI is **talk-sourced from Horthy plus multiple
independent secondary write-ups of that talk**, all consistent. **[SECONDARY-CORROBORATED]**

**Phases.** Sources agree on the alignment half and vary by one on whether "Worktree" counts as a named phase:

- [Turing Post](https://www.turingpost.com/p/aisoftwarestack) (17 Mar 2026) and [Heavybit](https://www.heavybit.com/library/article/whats-missing-to-make-ai-agents-mainstream): **Questions, Research, Design, Structure, Plan, Worktree, Implement** (7 steps).
- [alexlavaee.me "From RPI to QRSPI"](https://alexlavaee.me/blog/from-rpi-to-qrspi/): 8 phases = five **alignment** stages
  (Questions Q, Research R, Design Discussion D, Structure Outline S, Plan P) + three **execution** phases (Work Tree,
  Implement I, Pull Request PR).
- [HumanLayer's shipped `/rpi:*` skills docs](https://docs.humanlayer.com/reference/skills-workflows) call the default
  workflow **"RPI"** but its sequence is the revised one: **"Questions, research, design discussion, structure outline,
  implementation, PR"** — i.e. the productised tool already ships QRSPI under the "RPI" label. A separate **"PRD-Oriented"**
  workflow inserts PRD + TDD ("Questions, research, PRD, TDD, structure outline, implementation, PR"); **"Oneshot"** is
  just "Implementation, PR"; **"Freeform"** has no fixed phases.

Phase glosses from the HumanLayer docs (quoted):
- **Questions** — convert tickets into "focused questions about the current codebase."
- **Research** — answer them with "facts from the live codebase and its tests."
- **Design discussion** — turn findings into "clear options and user-owned design decisions."
- **PRD** — "the product problem, success measure, and approved solution."
- **TDD** (Technical Design Document) — "the technical HOW, from behavior between components to code shape."
- **Structure outline** — split the design into "ordered vertical phases you can test one at a time."

## Why RPI was revised — three named failure modes

Consistent across [alexlavaee.me](https://alexlavaee.me/blog/from-rpi-to-qrspi/),
[Turing Post](https://www.turingpost.com/p/aisoftwarestack),
[Heavybit](https://www.heavybit.com/library/article/whats-missing-to-make-ai-agents-mainstream), and
[The Humans in the Loop](https://thehumansintheloop.substack.com/p/making-agents-mainstream-for-dev-with-dexter-horthy).
**[SECONDARY-CORROBORATED]** (multiple independent write-ups of the same talk; talk not transcribed directly here).

1. **Instruction-budget overflow.** Frontier models follow only ~**150–200 instructions** with good consistency; the RPI
   planning prompt alone was **85+ instructions**, so models silently skipped the steps buried deepest — typically the
   interactive "present options / get feedback before writing the plan" steps. Horthy's framing of the irony (Turing Post):
   "We got on stage and said 'full-fat agents don't work, build workflows and micro agents, use control flow for control
   flow.' Then we turned around and wrote a giant monolithic 85-instruction prompt." Fix: split the monolith into focused
   micro-steps, each **under ~40 instructions**.
2. **Magic-words dependency.** RPI only behaved if the user pasted a trigger phrase — "**Work back and forth with me,
   starting with your open questions and outline before writing the plan**." Horthy (paraphrased across sources):
   "I found myself standing in workshops full of enterprise engineers saying, 'Folks, here's the software, but don't forget
   to say the magic words'" and "if a tool requires magic words for basic functionality, the tool itself is broken."
3. **Plan-reading illusion.** Over-detailed plan files "felt persuasive" but masked architectural misunderstanding —
   "reading a plan is not the same as validating a plan." An agent can write a coherent plan narrative without actually
   grasping the existing codebase's constraints. This is why QRSPI adds an explicit **Design Discussion** step (surface
   options and decisions) between Research and Plan, and de-emphasises exhaustive plan detail.

The "useful fiction" point from the main file's §7 belongs here too: the clean 3-phase boundary doesn't hold because
capable agents iterate between Research and Plan rather than crossing a one-way gate.

## What CRISPI / CRISPY is

**Not Horthy's term, and not a distinct methodology.** CRISPY is a **community phonetic renaming of QRSPI**:

- [`dynaptik/crispy`](https://github.com/dynaptik/crispy) — a multi-agent orchestration plugin, self-described as
  "CRISPY (how QRSPI sounds to me phonetically) … an 8-phase state machine based on the QRSPI methodology (Question,
  Research, Structure, Plan, Implement)," "grounded in the research by Dexter Horthy, the articles of Alex Lavaee and the
  QRSPI prompt-engineering work by Matan Shavit." **[SINGLE-SOURCE / real repo, unaudited]**
- [`dfrysinger/qrspi-plus`](https://github.com/dfrysinger/qrspi-plus) — another community pipeline, "extends QRSPI with
  worktree parallelization, tiered reviews, integration verification, acceptance testing, and replanning."
  **[SINGLE-SOURCE / real repo, unaudited]**
- alexlavaee treats "QRSPI/CRISPY" as interchangeable labels for the same 8-phase framework.

So "CRISPI"/"CRISPY" is downstream tooling vocabulary, not a third method alongside RPI and QRSPI.

## Recommendation for the chapter

- **Add QRSPI** — expand the existing one-sentence revision note in the RPI subsection into a short paragraph: the three
  named failure modes (instruction budget ~150–200 vs RPI's 85, magic words, plan-reading illusion), the added
  **Questions** and **Design Discussion** phases, and that HumanLayer's shipped tool now runs this sequence under the
  "RPI" label. Attribute to the March 2026 talk; no primary essay exists, so keep the Research Note that this is
  talk-sourced-but-multiply-corroborated.
- **Do not give CRISPY its own treatment** — at most one subordinate clause ("community implementations such as
  `dynaptik/crispy` rename QRSPI phonetically to CRISPY"). It adds no methodology the chapter needs to explain.
- Glossary: fold a one-line QRSPI mention into the existing **RPI** entry rather than a separate headword; skip CRISPY.

## Sources

1. [Everything We Got Wrong About Research-Plan-Implement — Dexter Horthy (YouTube YwZR6tc7qYg)](https://www.youtube.com/watch?v=YwZR6tc7qYg)
2. [From RPI to QRSPI — alexlavaee.me](https://alexlavaee.me/blog/from-rpi-to-qrspi/)
3. [Agentic Coding: RPI, Context Engineering & Subagents — Turing Post (17 Mar 2026)](https://www.turingpost.com/p/aisoftwarestack)
4. [What's Missing to Make AI Agents Mainstream? — Heavybit](https://www.heavybit.com/library/article/whats-missing-to-make-ai-agents-mainstream)
5. [The Humans in the Loop Deep Dive: Making AI Agents Mainstream with Dexter Horthy](https://thehumansintheloop.substack.com/p/making-agents-mainstream-for-dev-with-dexter-horthy)
6. [HumanLayer docs — Skills and workflows reference](https://docs.humanlayer.com/reference/skills-workflows)
7. [dynaptik/crispy — CRISPY multi-agent orchestration plugin](https://github.com/dynaptik/crispy)
8. [dfrysinger/qrspi-plus — QRSPI-plus pipeline](https://github.com/dfrysinger/qrspi-plus)
9. [humanlayer/advanced-context-engineering-for-coding-agents (repo file listing — only ace-fca.md + wsff.md)](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents)
