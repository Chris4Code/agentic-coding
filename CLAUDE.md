# Agentic Coding Book Project

This workspace is an experiment to persist learning notes about agentic coding into an mdBook.

Folder `notes` contains the research behind the book, organized into topic subfolders (see below).

Notes are the source of truth for anything concrete or current: named tools/products, specific numbers, benchmarks, pricing, and citation links. Foundational, well-established concepts (e.g. how attention works) may be explained from general knowledge, but don't invent tool names, dates, or figures that aren't backed by a note file — check `notes` first.

The folder `src` contains markdown files of the book being compiled into a navigatable mdBook web page which will be located in the `book` folder.

## Notes folder structure

Every note lives in its own subfolder of `notes`, never as a loose file directly in `notes`:

* `notes/initial-notes/` – the original batch of manual research notes this project started from (Gemini chats on specific agentic-coding topics). Kept as-is, flat, for historical reference.
* `notes/YYYY-MM-DD-<inc-num>-<chapter>-<topic-slug>/` – every note added since, one dated subfolder per research pass. `chapter` is the chapter slug this research targets (a `src/*.md` filename without its extension), or `no-chapter` if the pass isn't seeded by or aimed at a specific chapter. `inc-num` is a daily run counter per chapter — **the same counter as that run's `history/` entry** (see below), reused rather than tracked separately, so the two stay trivially correlated. `topic-slug` is the same short dash-case label used in that run's `history/` entry filename. Because a topic can get revisited later, each pass gets its own dated subfolder rather than editing an old one in place — this keeps the history of what was known when. There are two kinds of content that land here:
  * **Manual research** – notes written/curated by hand, same style as `initial-notes`. Place the note file(s) directly in the dated subfolder.
  * **Claude Deep Research exports** – the full exported chat (prompts + verbose results) saved as `raw-<subtopics-slug>.md`, kept complete and unabridged so no detail from the research is lost. Alongside it, add `summary-<subtopics-slug>.md`, distilling the key findings, figures, and citation links for quick reference when writing a chapter. `subtopics-slug` joins (with `--`) up to five of the subtopics this specific pass researched, in hierarchical order — usually longer and more specific than the folder's own `topic-slug`. The summary is a navigation aid, not a replacement — it must never be the only place a fact lives; for exact figures, quotes, or citations, pull from the raw export itself, not just the summary. This kind of research can also be run directly via the `deep-book-research` skill (`.claude/skills/deep-book-research/`), which performs the research live (optionally seeded from a podcast/article URL) and produces the same `raw-*`/`summary-*` pair.

## Chapter history

Folder `history` tracks, per chapter, which skill or prompt-run touched its content and what went into that run — a bookkeeping trail that's otherwise only implicit (inferable from `notes/` folder names/dates and inline citations, but never indexed anywhere).

* `history/<chapter-slug>/` – one subfolder per chapter, named after that chapter's own `src/*.md` filename without the extension (e.g. `history/basics/` for `src/basics.md`). Created the first time a content-impacting run touches that chapter.
* Inside it, one file per run: `history/<chapter-slug>/YYYY-MM-DD-<inc-num>-<topic-slug>.md`, where `inc-num` is a run counter that starts at 1 and increments per **chapter**, per **day** (the second run on the same chapter on the same day is `2`, not a fresh `1`), and `topic-slug` is a short dash-case label for what that run was about. When the same run also produces a `notes/` research pass, that folder reuses this exact `inc-num` and `topic-slug` (see the `notes` folder structure above) — compute them once per run, not separately for each location.
* A "content-impacting skill or prompt-run" is any run of `deep-book-research`, `edit-chapter`, or `fact-check` against that chapter, or any other prompt that substantively edits or researches that chapter's content — not a typo fix or pure formatting pass.
* The file records **input data only** — what went into the run (the triggering request, notes/sources consulted or seeded, the scope/subtopics targeted) — never the outcome (findings, what changed, conclusions). The outcome already lives in the resulting `notes/` raw+summary pair and in the chapter diff itself; duplicating it here would just be a second, driftable copy of the same information.
* An entry written after the fact rather than during the run itself (e.g. backfilling history for work done before this convention existed) must say so plainly and note that it's a best-effort reconstruction from available evidence, not a live log.

## Linguistic and Content Conventions  

* Use language that is technical, objective, matter-of-fact, and as clear as possible, given that this book is frequently used by non-native speakers. While clarity is preferred, complex concepts should be explained with the necessary technical depth—without being oversimplified—since the book is aimed at software developers.
* Research evidence quality hints: Try to separate these aspects (i.e. "well corroborated", "could not be corroborated", "only a single source"), in separate dedicated paragraphs, prefixed with `Research Note:`. Do not mention well corroborated facts as this is the default for the content of this book. Only mention if facts are not well corroborated.

## File naming convention

Chapter files in `src` are named in `dash-case`, derived from the chapter title (e.g. "Spec Driven Development (SDD)" → `spec-driven-development.md`). Every new chapter file must also be linked from `SUMMARY.md`, otherwise it won't appear in the book.

## Glossary

`src/glossary.md` holds an alphabetically ordered glossary of relevant terms used throughout the book, each with a short explanation and a link to the section where it is explained in more detail. Whenever a new relevant term is introduced in any chapter, add it to the glossary in the same change.

## Skills

Claude Code skills for this project live under `.claude/skills/`. All skills need to be briefly documented in the root `README.md` — whenever a new skill is added, add a short paragraph about it there in the same change.

## Diagrams

The `mdbook-mermaid` preprocessor is set up (see `book.toml`), so ```mermaid fenced code blocks render as diagrams. When adding or revising book content, include a mermaid diagram wherever it would clarify a flow, architecture, or comparison better than prose/tables alone (e.g. request/data flows, before/after architecture contrasts, decision routing) — don't force one into sections that are just definitions or flat lists.

## Usefull mdbook commands

In the root folder of this project:

Serve the mdbook at `http://localhost:3000`
```
mdbook serve
```