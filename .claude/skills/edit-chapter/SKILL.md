---
name: Edit Chapter
description: Runs a structured editing pass on an existing book chapter under src/ — triaging new research notes or an editorial goal against the chapter's current content, annotating the chapter in place with `<!-- CONTENT-KEY-SUBJECTS -->` and `<!-- CONTENT-CHANGE -->` markers, previewing the resulting structure for the user's confirmation, then resolving each marker into finished prose that matches the chapter's established sourcing rigor and voice — with a same-change glossary update per CLAUDE.md.
when_to_use: Use when the user wants to (1) integrate new research notes into an existing chapter (content editing), (2) restructure/reorganize a chapter's sections or heading hierarchy (structural editing), or (3) tighten, condense, or rewrite a chapter's existing prose (developmental editing) — including any combination of the three in one pass. Also use when the user references this skill by name or says "edit this chapter." Not for drafting a brand-new chapter from scratch with no existing file, and not for the research itself (see `deep-book-research` for that).
argument-hint: [chapter-file] [source-notes-or-goal]
arguments: chapter_file, source
---

# Edit Chapter

Turns an editorial goal — new research notes to fold in, a restructuring request, or a plain "this section is too long/messy" — into a finished revision of an existing `src/*.md` chapter, without skipping the confirmation points that keep editorial judgment calls visible to the user before they're baked into prose.

`$ARGUMENTS` (or `$0` / `$1`) gives the `chapter_file` (a path under `src/`, e.g. `sw-factories.md`) and, optionally, a `source` — a path to new research notes under `notes/`, or a plain-language description of the editing goal ("condense the historical section," "the four quotes in this section repeat the same point," "restructure so X sits under Y"). If neither a source nor a clear goal is given, ask before proceeding — don't invent an editorial agenda from nothing.

This skill runs as a two-session shape by design: a **planning session** (steps 1–5) that ends in a marked-up but not-yet-rewritten file, and a **writing session** (step 6) that resolves those marks into prose. They don't have to happen back to back — the markers are HTML comments, invisible in the rendered book, so a marked-up file is safe to leave mid-pass across turns or even across separate conversations. **Check for this first**: if `chapter_file` already contains `CONTENT-KEY-SUBJECTS` or `CONTENT-CHANGE` markers, a planning pass already happened — skip straight to step 6 for the remaining markers instead of re-deriving a plan from scratch. Still do step 4 (the history entry) even when skipping ahead like this, since resuming to write prose is itself a content-impacting run and hasn't been logged yet if the planning pass happened in an earlier session.

## The two marker types

Both are HTML comments, placed on the line(s) immediately after the heading they apply to and before any existing prose. Being HTML comments, they render as nothing in mdBook — safe to commit, safe to leave half-resolved.

* **`<!-- CONTENT-KEY-SUBJECTS ... -->`** — under a heading with no prose yet (a new section, or an existing stub), a bullet list of the facts, questions, tools, or claims that section needs to cover once written. Describes *what*, not *how phrased* — the actual wording is step 6's job, not this one's.
* **`<!-- CONTENT-CHANGE ... -->`** — under a heading that already has prose, specific instructions for how that prose should change (condense, refocus, re-source, merge, split). Points at what's wrong or missing with the *current* text, not a rewrite of it.

Never write finished prose inside a marker — that defeats the point of separating the planning pass from the writing pass, and blocks the user from redirecting the plan cheaply before it's expensive to unwind.

## Steps

1. **Read before proposing anything.** `Read` the full `chapter_file` — not just the sections that seem relevant, the whole thing, since a structural fix in one place (e.g. a misnested heading) often only becomes visible by seeing the surrounding hierarchy. If `source` points at a notes file or folder, `Read` that too, in full.

2. **Triage the source before trusting it.** This step is what separates this skill from a plain rewrite. If `source` is new research:
   - Distinguish independently-verifiable claims (named companies/products/figures a reader could confirm) from single-source or vendor-only claims, the same way the chapter's own existing prose already does — look at how already-written sections in this chapter hedge claims (e.g. "vendor-reported and not independently audited," "could not be independently confirmed") and hold new material to the same bar.
   - Flag anything that reads as possibly fabricated or unverifiable — a note that's a raw, ungrounded AI chat transcript is a different reliability tier than a "Claude Deep Research export" per `CLAUDE.md`'s own distinction, even when both live under `notes/`. Thin citations (a bare video link, an unfamiliar blog domain) are a signal to hedge or omit, not to repeat at face value.
   - This triage result feeds directly into which markers get written in step 5 (a `CONTENT-KEY-SUBJECTS` bullet should already say "verified: X, Y; flag-as-unverified: Z" rather than leaving that judgment for the writing pass to rediscover).

3. **Recommend before touching the file.** Work out: where does new material actually fit — a new section, or does it flesh out an existing stub? What in the current chapter is redundant, misplaced (wrong heading level, orphaned nesting, a heading with content that doesn't match its title), or ripe for condensing? Present this as a recommendation with a brief rationale, the way you'd answer an exploratory "what do you think?" question — not an exhaustive essay, and not something you act on unprompted. Stop here and let the user redirect before editing anything. Skip this step only if the user already gave an unambiguous, narrow instruction (e.g. "condense paragraph 3") that doesn't need a recommendation first.

4. **Write the chapter-history entry.** Per `CLAUDE.md`'s `history` convention: create `history/<chapter-slug>/` (named after `chapter_file` without its extension) if it doesn't exist yet, work out the next daily run counter for that chapter, and write `history/<chapter-slug>/YYYY-MM-DD-<inc-num>-<topic-slug>.md` recording this run's **inputs only** — the editorial goal or `source` given, which notes/research fed the triage in step 2, and the direction confirmed in step 3. Do not record what the edit actually changed here — that's the outcome, and it's already visible in the chapter diff itself.

5. **Annotate the file, and preview the result.** Once the direction is confirmed:
   - Insert `CONTENT-KEY-SUBJECTS` markers under new/stub headings and `CONTENT-CHANGE` markers under existing prose that needs to change, per the format above.
   - Fix structural issues directly in this pass rather than deferring them — move a misnested section to the right parent heading, correct a heading level, remove an orphaned heading with no content. Structural moves are cheap to redo if wrong; don't gate them behind a second confirmation the way prose is gated.
   - Cross-reference rather than duplicate: if two sections will cover related ground (e.g. a general pattern and a specific architecture built on it), note in the markers which one owns which slice, and have the eventual prose link to the other via mdBook's heading-slug anchor (`## Some Heading` → `#some-heading`, lowercase, hyphens, punctuation stripped) instead of restating it.
   - After annotating, output a preview of the resulting heading hierarchy (indented list, top to bottom) with a tag per heading — `[NEW]`, `[CONDENSE]`, `[MOVED]`, `[unchanged]` — so the user can review the *shape* of the edit before any prose is written. Treat this as a hard gate: do not proceed to step 6 without the user confirming the preview, since annotation choices bake in real editorial judgment that's far cheaper to redirect now than after prose exists.

6. **Resolve markers into prose.** Work through the file top to bottom (or pick up wherever unresolved markers remain, per the skip-to-step-6 note above). For each marker:
   - Write prose that fulfills the marker's bullets, matching the chapter's established voice: hedge appropriately, distinguish "reported by X" from "independently corroborated," cite real sources with working links, and never invent a quote, figure, or product name that isn't backed by the source material or the chapter's existing content (per `CLAUDE.md`'s "notes are the source of truth for anything concrete" rule).
   - Delete the marker comment once its content is written — it's a to-do, not a permanent annotation.
   - For a `CONTENT-CHANGE` marker, replace exactly the prose it points at; don't let the rewrite creep into neighboring, unmarked paragraphs.
   - Prefer condensing multiple sources making the same point into one attributed statement per source over quoting each at length, when a marker calls for it — matching how already-tightened sections in the chapter read.

7. **Update the glossary in the same change.** Per `CLAUDE.md`, any new relevant term introduced while writing prose (a named pattern, an acronym, a coined phrase this chapter now treats as a first-class concept) gets a `src/glossary.md` entry in the same pass — alphabetically placed, one line, linking back to the chapter section with the correct heading-slug anchor. Don't defer this to a follow-up.

8. **Report what changed.** Summarize section by section — condensed / rewritten / moved / added — rather than re-printing the whole diff. If the project has a link-checking setup already serving the book (check for this rather than assuming), note that cross-reference anchors should be verified there rather than re-deriving a manual anchor-check process.

## Notes

- This skill is the editing-side counterpart to `deep-book-research`: that skill turns a topic into new notes; this one turns notes (or a plain editorial goal) plus an existing chapter into a revised chapter.
- The marker convention is deliberately durable across sessions — grepping a chapter file for `CONTENT-KEY-SUBJECTS\|CONTENT-CHANGE` at the start of any editing task is a cheap way to discover an in-progress pass before starting a redundant new one.
- Steps 1–5 (planning) and step 6 (writing) are separable on purpose. A planning-only request ("just show me the structure") stops after step 5's preview; don't write prose unless the user has confirmed it or explicitly asked for the full pass upfront.
- The `history/<chapter-slug>/` entry from step 4 records only this run's inputs (the editorial goal, the source material). It's a separate, lightweight thing from the annotated markers and the eventual prose — don't fold outcome details into it.
