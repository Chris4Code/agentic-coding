# Agentic Coding Background Knowledge

Study notes on **agentic coding** — using AI agents to write, review, and maintain software — synthesized from the research in the `notes` folder into a structured [mdBook](https://rust-lang.github.io/mdBook/). 99% of the prose is written by Claude Code from those research findings.

**Start reading:** [`src/README.md`](src/README.md) is the book's introduction — it lists every chapter and explains how the book is researched and written. The rendered book is produced by `mdbook build` into `book/` (git-ignored). A live version of this book can be found [here](https://chris4code.github.io/agentic-coding/).

## Repository layout

| Path | Contents |
| --- | --- |
| `src/` | The book chapters (Markdown), one file per chapter, wired together by `src/SUMMARY.md`. |
| `notes/` | The raw research behind the chapters — the source of truth for tool names, figures, benchmarks, and citations. One dated subfolder per research pass. |
| `history/` | Per-chapter bookkeeping trail: which skill or prompt-run touched a chapter and what went into it (inputs only). |
| `.claude/skills/` | Project skills (`deep-book-research`, `edit-chapter`, `fact-check`). |
| `book/` | Build output (git-ignored). |

The full set of conventions (note naming, chapter history, glossary upkeep, linguistic rules) lives in [`CLAUDE.md`](CLAUDE.md).

## How this book is written

The chapters of this book — the polished write-up — are contained in the `src` folder. The raw research behind them lives in the project's `notes` folder (outside the book itself) and is treated as the source of truth for anything concrete: named tools, specific numbers, benchmarks, and citation links.

Each note lives in its own dated subfolder, `notes/YYYY-MM-DD-<inc-num>-<chapter>-<topic-slug>/`, rather than as a loose file, so a topic can be revisited later without losing the earlier research. The original batch of notes this project started from sits in `notes/initial-notes/`. Two kinds of research land in these subfolders: manually written/curated notes, and full exports of Claude Deep Research sessions (kept complete and unabridged as `raw-<subtopics-slug>.md`, plus a `summary-<subtopics-slug>.md` for quick reference — the summary is only a navigation aid, never a substitute for the raw export when exact figures or citations matter).

A separate `history` folder tracks *which* skill or prompt-run touched each chapter and *what went into* that run — one subfolder per chapter (`history/<chapter-slug>/`), with one file per run (`YYYY-MM-DD-<inc-num>-<topic-slug>.md`) recording the run's inputs (the triggering request, notes/sources consulted, the scope targeted). It deliberately records inputs only, never outcomes — findings and changes already live in the matching `notes/` pair and in the chapter diff, so `history` stays a lightweight index rather than a second copy of the same content. A research pass that touches both gets one shared `inc-num`/`topic-slug`, reused in both places, so a `notes/` folder and its triggering `history/` entry are always trivially identifiable as the same run.

The `deep-book-research` Claude Code skill (`.claude/skills/deep-book-research/`) automates that second kind: given a topic — optionally seeded from an existing (possibly stub) chapter's own section headers, or from an external source like a podcast/article URL — it runs the research live via web search/fetch, then writes the same raw-export-plus-summary pair into a new dated `notes/` subfolder, named after up to five of the researched subtopics so repeated research passes on the same chapter don't collide.

Turning that research (or any other editorial goal) into an actual chapter revision is the job of the `edit-chapter` skill (`.claude/skills/edit-chapter/`). It runs in two passes: first it triages the source material, recommends where it fits, and annotates the chapter in place with `<!-- CONTENT-KEY-SUBJECTS -->` / `<!-- CONTENT-CHANGE -->` HTML comments — invisible in the rendered book — previewing the resulting structure for confirmation before anything is rewritten; then, once confirmed, it resolves each marker into finished prose matching the chapter's existing sourcing rigor and voice. It covers content, structural, and developmental editing alike, and can resume a partially-annotated chapter across sessions since the markers persist in the file until resolved.

Chapters written early in the project — before a research pass ever touched them — only have `notes/initial-notes/` (a single, ungrounded AI chat) behind them. The `fact-check` skill (`.claude/skills/fact-check/`) is the verification-side counterpart to the two skills above: instead of drafting new content, it reads an existing chapter, identifies its own checkable claims (concrete numbers, formulas, named products, mechanisms attributed to a specific system), researches each against primary sources, and applies the results directly — correcting anything found wrong or outdated, adding a section/paragraph-scoped `Research Note:` per `CLAUDE.md`'s evidence-quality convention wherever corroboration is only partial, and leaving well-supported prose untouched. It logs the same raw-export-plus-summary pair into a new dated `notes/` subfolder as the other two skills, so every fact-check pass stays traceable back to its sources.

## Building the book

This book is built with [mdBook](https://rust-lang.github.io/mdBook/), using the [mdbook-mermaid](https://github.com/badboy/mdbook-mermaid) preprocessor (already configured in `book.toml`) to render diagrams. From the project root:

```
mdbook serve
```

serves the book locally at `http://localhost:3000`.

The root `Makefile` wraps common workflows: `make build`
renders the book, `make serve` serves it with live reload, and `make help`
lists every target. See beow for `make install`.

### Installing mdBook + needed dependencies on Linux

The root `Makefile` also wraps the installation workflow described below: `make install` fetches the three
prebuilt binaries into `~/.local/bin`. The following steps describe how to install mdBook and the needed dependencies manually.

> **Don't install `mdbook` via `snap` / `apt`.** The Snap Store's `mdbook` package is an unofficial, abandoned build (`v0.0.28` from 2017) that predates the real 1.0+ project and has broken Markdown link handling — it will silently leave `.md` links unconverted. Install the official binaries from GitHub releases instead.

Neither tool needs Rust/`cargo` installed — both ship prebuilt Linux binaries. This installs both to `~/.local/bin` (no `sudo` required):

```bash
mkdir -p ~/.local/bin && cd /tmp

# mdBook
url=$(wget -qO- https://api.github.com/repos/rust-lang/mdBook/releases/latest \
  | grep browser_download_url | grep x86_64-unknown-linux-gnu | cut -d '"' -f4)
wget -q "$url" -O mdbook.tar.gz && tar xzf mdbook.tar.gz && mv mdbook ~/.local/bin/

# mdbook-mermaid
url=$(wget -qO- https://api.github.com/repos/badboy/mdbook-mermaid/releases/latest \
  | grep browser_download_url | grep x86_64-unknown-linux-gnu | cut -d '"' -f4)
wget -q "$url" -O mdbook-mermaid.tar.gz && tar xzf mdbook-mermaid.tar.gz && mv mdbook-mermaid ~/.local/bin/

# mdbook-linkcheck2
url=$(wget -qO- https://api.github.com/repos/marxin/mdbook-linkcheck2/releases/latest \
  | grep browser_download_url | grep x86_64-unknown-linux-gnu | cut -d '"' -f4)
wget -q "$url" -O mdbook-linkcheck2.tar.gz && tar xzf mdbook-linkcheck2.tar.gz && mv mdbook-linkcheck2 ~/.local/bin/

chmod +x ~/.local/bin/mdbook ~/.local/bin/mdbook-mermaid ~/.local/bin/mdbook-linkcheck2
```

> **Use `mdbook-linkcheck2`, not `mdbook-linkcheck`.** The original [`mdbook-linkcheck`](https://github.com/Michael-F-Bryan/mdbook-linkcheck) is unmaintained and its latest release (`v0.7.7`, 2022) can't parse the `RenderContext` emitted by current mdBook versions (fails with `missing field 'sections'`), so `mdbook build`/`mdbook serve` errors out. [`mdbook-linkcheck2`](https://github.com/marxin/mdbook-linkcheck2) is an actively maintained fork that fixes this; `book.toml` is already configured to use it via `[output.linkcheck2]`.

Make sure `~/.local/bin` is on your `PATH` (add this to `~/.bashrc` if it isn't already, then restart your shell or `source ~/.bashrc`):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

Verify all three are picked up correctly, then serve the book:

```bash
mdbook --version          # should print v0.4.x or newer, not v0.0.28
mdbook-mermaid --version
mdbook-linkcheck2 --version
mdbook serve
```

`mdbook build`/`mdbook serve` now also run `mdbook-linkcheck2` on every build (it's wired up as an `[output.linkcheck2]` renderer in `book.toml`), failing the build if a link inside `src/` points at a Markdown file, anchor, or asset that doesn't exist. It only checks local links by default (`follow-web-links = false`), so it stays fast; see the [mdbook-linkcheck2 README](https://github.com/marxin/mdbook-linkcheck2#configuration) if you want it to also validate external URLs.

If you're on ARM (e.g. Apple Silicon under Linux/Asahi), swap `x86_64-unknown-linux-gnu` for `aarch64-unknown-linux-musl` in the commands above.
