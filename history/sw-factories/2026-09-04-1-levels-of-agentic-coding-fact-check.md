# 2026-09-04 · run 1 · levels-of-agentic-coding-fact-check

**Skill:** fact-check (invoked ad hoc via direct prompt, not the packaged skill)
**Chapter:** src/sw-factories.md
**Scope:** corroboration check for a user-supplied 6-level "Levels of Agentic Coding" definition (Interactive / Context-Aware / Task Delegation / Human Orchestration / System Orchestration / Full Automation–Dark Factory), with instruction to add a section to "Software factory models" only if the levels or a similar level structure is well corroborated.

## Trigger

User pasted a 6-level taxonomy (with partial, partly-broken citation markers `[1,2,4]` … `[]` … `[, 3]`) and asked for a fact-check, conditional on corroboration adding a section to the `## Software factory models` section of `sw-factories.md`.

## Input materials

- The user-supplied definition text (in the triggering prompt).
- Existing chapter context: `src/sw-factories.md` "Software factory models" section (Full Human Review / Dark Factory / Leverage-Point Model) and its dark-factory manufacturing-origin material.
- `notes/2026-08-18-2-sw-factories-software-factory-models-corroboration/` — prior pass; already noted "a reported Simon Willison five-level framework" (identified in this pass as Dan Shapiro's, relayed by Willison).

## Sources consulted (web)

- Dan Shapiro, "The Five Levels: from Spicy Autocomplete to the Dark Factory" (danshapiro.com, 2026-01-23); Simon Willison's relay (simonwillison.net, 2026-01-28).
- Steve Yegge's 8 levels — via The Pragmatic Engineer (Gergely Orosz) interview + Augment Code's write-up.
- Addy Osmani, "Agentic Autonomy Levels" (addyosmani.com, July 2026); "Conductors to Orchestrators" (O'Reilly Radar / Osmani).
- Andy Anderson (IBM Research), "The AI Codebase Maturity Model: From Assisted Coding to Fully Autonomous Systems" (arXiv 2604.09388) — 6-level ACMM, single-author practitioner report, AI-assisted writing.
- Swarmia, "Five levels of AI coding agent autonomy."
- MindStudio blog level explainers (vendor); freecodecamp "software factory with Claude Code" (7-subagent pattern).
- Secondary mentions: ELEKS AI-SDLC Maturity Model, AIDMM, AI-MM SET, arXiv "Levels of Autonomy for AI Agents" (2506.12469).

## Outcome pointer

Full findings + the exact per-level corroboration verdict live in `notes/2026-09-04-1-sw-factories-levels-of-agentic-coding/` and in the chapter diff (new `### The Levels of Agentic Coding` subsection + glossary entry).
