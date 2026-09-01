---
name: Fact Check Chapter
description: Runs an independent corroboration pass over an existing book chapter under src/ — identifying its own checkable subtopics (concrete numbers, formulas, named products/companies, specific mechanisms), researching each against primary sources, then applying the results directly to the chapter (correcting anything found wrong or outdated, inserting section/paragraph-scoped `Research Note:` paragraphs per CLAUDE.md's evidence-quality convention where corroboration is partial, and leaving well-corroborated prose untouched) — with the raw research and a distilled summary logged under notes/YYYY-MM-DD-<inc-num>-<chapter>-<topic-slug>/, per the notes convention in CLAUDE.md.
when_to_use: Use when the user asks to "fact-check", "verify", or "corroborate" an existing chapter — especially one drafted early in the project purely from notes/initial-notes/ (a single ungrounded AI research chat) with no independent verification pass since. Also use when the user references this skill by name. Not for drafting new chapter content from scratch (see `deep-book-research` for researching a topic, `edit-chapter` for integrating new research or restructuring) — this skill only verifies and corrects claims already written into an existing chapter.
argument-hint: [chapter-file] [subtopic-or-section]
arguments: chapter_file, scope
---

# Fact Check Chapter

Takes a chapter that already has finished prose and checks whether that prose is actually true — not by rewriting it wholesale, but by identifying its concrete, checkable claims, verifying each one against primary sources, and then either leaving well-supported prose alone, correcting what turns out to be wrong or outdated, or annotating what's only partially corroborated with a `Research Note:` paragraph right where the claim is made.

`$ARGUMENTS` (or `$0` / `$1`) gives the `chapter_file` (a path under `src/`, e.g. `basics.md`) and, optionally, a `scope` — a specific section or subtopic to focus on if the user only wants part of the chapter checked. If `scope` isn't given, check the whole chapter.

This is the verification-side counterpart to `deep-book-research` (which researches a topic to draft *new* content) and `edit-chapter` (which restructures or integrates *new* research into a chapter). This skill instead takes prose that's already there and asks: is it actually right?

## Steps

1. **Read the full chapter.** `Read` `chapter_file` completely, not just the sections implied by `scope` — surrounding sections often share context (a formula defined in one section, used in another) that changes how a claim should be checked or corrected.

2. **Identify the chapter's own checkable subtopics — don't ask the user to enumerate them.** Go through the chapter and pull out every claim that is concrete enough to verify or refute:
   - Specific numbers, percentages, ranges, or formulas presented as fact (benchmark figures, cost/savings percentages, architecture parameters).
   - Named products, companies, papers, or people — especially ones the chapter treats as established but that read as unfamiliar or suspicious (an unusual product name, a domain that doesn't match a known org, a citation trail that traces back to only one source).
   - Specific mechanisms attributed to a named system ("Claude Code does X", "vLLM achieves Y") — these are checkable against that system's own docs/repo/paper even when the general concept behind them is well-established.
   - Skip claims about foundational, well-established concepts with no specific attached figure (e.g. "attention lets tokens weigh each other's relevance") — per `CLAUDE.md`, these may be explained from general knowledge and don't need a citation hunt. The moment a specific number, product name, or benchmark gets attached to such a concept, it becomes checkable again.
   - Group the resulting claims into subtopics that roughly track the chapter's own section structure — this keeps the eventual `Research Note:` paragraphs anchored to the section that made the claim, rather than producing one undifferentiated list.

3. **Check prior art.** Search `notes/` broadly (`notes/initial-notes/` and every dated subfolder, matched by name or content, not just an exact chapter-name pattern) for research that already backs — or already contradicts — the chapter's claims. A chapter can accumulate research from more than one earlier pass (e.g. `sw-factories.md` already carries `Research Note:` paragraphs from a prior `deep-book-research` + `edit-chapter` pass); don't re-research what's already been independently corroborated and written up. This step also often reveals *which* claims trace back only to `notes/initial-notes/` (a single, ungrounded AI chat with no follow-up verification) — those are usually the highest-priority subtopics to check, since they were never verified in the first place.

4. **Confirm the subtopic list only if it's ambiguous or large** (more than ~8 subtopics for one research pass) — otherwise proceed directly. If the user gave a narrow `scope`, skip confirmation entirely.

5. **Establish this run's identity — inc-num, topic-slug, and subtopics-slug — then set up the folder/file names and the history entry together.** These are shared between the `notes/` folder and the `history/` entry for this same run, so compute them once, here, rather than separately in two places:
   - **`chapter`** — the slug of `chapter_file` (its filename without extension); always known for this skill, since `chapter_file` is required.
   - **`inc-num`** — a daily run counter, scoped per `chapter`. Look at both `notes/` (folders already starting with today's date and this chapter) and `history/<chapter>/` (files already starting with today's date) to find the highest counter used so far today for this chapter, and use one past it (or `1` if none exist yet).
   - **`topic-slug`** — a short (2–5 word) dash-case label summarizing what this run is about (e.g. `kv-cache-prompt-caching-fact-check`).
   - **`subtopics-slug`** — take the first five subtopics from step 2, in document order, slugify each (lowercase, kebab-case), and join with `--`.
   - Create `notes/YYYY-MM-DD-<inc-num>-<chapter>-<topic-slug>/` (today's date). The two output files inside it are `raw-<subtopics-slug>.md` and `summary-<subtopics-slug>.md`.

6. **Write the chapter-history entry.** Per `CLAUDE.md`'s `history` convention: create `history/<chapter>/` if it doesn't exist yet, and write `history/<chapter>/YYYY-MM-DD-<inc-num>-<topic-slug>.md` — reusing the exact same `inc-num` and `topic-slug` from step 5 — recording this run's **inputs only** — the triggering request, `scope` if one was given, the subtopic list from step 2, and which prior-art notes (step 3) fed into it. Do not record findings, corrections, or verdicts here — those are the outcome, and they belong in the raw/summary files and in the chapter edits themselves.

7. **Delegate the research.** Spawn a `general-purpose` Agent (background is fine — this is a multi-tool-call, multi-minute task) with a self-contained brief that includes:
   - The chapter's own relevant text for each subtopic, quoted directly (don't just point at the file path) — the agent needs the exact wording being checked, including surrounding context.
   - The full subtopic list from step 2, one research pass per subtopic, plus any specific "red flags" you noticed while reading (a suspicious product name, a suspiciously precise percentage, a citation trail that traces to only one blog).
   - An explicit instruction to prioritize primary sources (the paper itself, the vendor's own current docs, the standards body) over secondary blog summaries — and where a formula or arithmetic claim is involved, to *independently recompute it* rather than just re-stating the chapter's numbers.
   - A confidence-tagging convention for every claim checked: 🟢 primary / 🟡 corroborated-secondary / 🟠 single-source / ⚪ could not be corroborated — matching the convention already used in prior fact-check/research passes under `notes/`.
   - An explicit no-fabrication rule, and permission to say plainly "could not be corroborated" — that is a valid, useful finding, not a failure to search harder.
   - If a red-flagged named entity turns out to be real, don't stop at "it exists" — check whether the *specific* claims attached to it (a number, an architecture detail) actually appear in its own primary material, since a real product can still have invented specifics bolted onto it by an earlier ungrounded pass.
   - The exact output path from step 5, and the same one-`##`-section-per-subtopic / inline-citation-links / deduplicated-source-list format `deep-book-research` uses.
   - A request to end its report to you with, per subtopic: strongly corroborated / corrected / weakly corroborated / not corroborated — you need this breakdown to decide what step 9 does with each claim.

8. **Write the summary yourself — do not delegate this step.** Read the raw file fully and write `summary-<subtopics-slug>.md` following the same shape `deep-book-research` uses (pointer back to the raw file, one compressed confidence-tagged entry per subtopic, a closing section connecting findings back to `chapter_file`) — except the closing section here should state, per subtopic, exactly what step 9 changed in the chapter (corrected / annotated with a Research Note / left alone), not a proposal for future drafting.

9. **Apply the findings to the chapter — this is this skill's distinguishing step.** Work through the chapter section by section and, per `CLAUDE.md`'s "well corroborated is the default, don't call it out" rule:
   - **Strongly corroborated claim** → leave the prose exactly as it is. Do not add a `Research Note:` congratulating it on being correct.
   - **Claim found to be wrong, outdated, or using superseded terminology** → correct the prose in place, matching the chapter's existing voice, so it states the current, correct fact. This is a direct fix, not a footnote — don't leave an inaccurate claim standing next to a note that contradicts it.
   - **Claim that's only single-source, partially corroborated, or has a plausible-but-unconfirmed range** → keep the claim (unless it's actively misleading) and add a `Research Note:` paragraph immediately after the paragraph or table it qualifies — never batched into one note at the end of the chapter or section, since the whole point is that a reader hits the evidence-quality caveat right next to the specific claim it covers.
   - **Specific number/figure found to be an outright misattribution** (e.g. a real, well-known figure that measures something different from what the chapter's table cell implies) → don't just flag this with a note; fix the actual value or drop the unsupported figure and describe the real, underlying mechanism instead. A `Research Note:` explaining *why* the old figure was wrong is still warranted, right after the correction.
   - Keep every `Research Note:` short and specific: what's corroborated, what isn't, and why a reader should weight it accordingly — not a restatement of the whole research subtopic.

10. **Update the glossary in the same change, if warranted.** This is rare for a fact-check pass (most changes are corrections/annotations of existing terms), but if a correction introduces a term the glossary doesn't yet have (e.g. current terminology replacing something outdated), or invalidates the framing of an existing glossary entry (e.g. an entry now needs the same caveat the chapter got), update the `src/glossary.md` entry per `CLAUDE.md` in this same pass.

11. **Verify the book still builds.** Run `mdbook build` (or check for an existing project-specific way to do this) and confirm no broken links or errors were introduced by the edits — inserted `Research Note:` paragraphs and corrected prose are still just Markdown, but a citation link typo is an easy mistake to make while writing them.

12. **Report what changed**, section by section: which claims were corrected (old → new), which got a `Research Note:` (and the gist of why), and which were checked and left untouched because they held up. Point to the new `notes/` folder for the full research trail.

## Notes

- This skill is the verification-side counterpart to `deep-book-research` (new content) and `edit-chapter` (restructuring/integrating research) — all three share the same `notes/YYYY-MM-DD-<inc-num>-<chapter>-<topic-slug>/` raw+summary convention so research stays discoverable regardless of which skill produced it.
- A named entity turning out to be real is not the end of the check — the specific numbers attached to it still need their own verification, since invented specifics get bolted onto real product names too.
- Resist the urge to add a `Research Note:` to everything "just in case" — per `CLAUDE.md`, well-corroborated facts are the expected default for this book and shouldn't be called out; over-noting buries the genuinely uncertain claims the convention exists to surface.
- The `history/<chapter>/` entry from step 6 records only this run's inputs (the trigger, the subtopics, the prior art found). It's a separate, lightweight thing from the `notes/` raw+summary pair and from the chapter edits themselves — they share an `inc-num`/`topic-slug` identity, not their content.
