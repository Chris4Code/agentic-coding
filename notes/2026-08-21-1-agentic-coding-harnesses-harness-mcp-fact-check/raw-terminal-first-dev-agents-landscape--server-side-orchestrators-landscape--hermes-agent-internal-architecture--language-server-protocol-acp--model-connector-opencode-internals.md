# Fact-check pass: agentic-coding-harnesses.md (harnesses + MCP claims)

Corroboration pass against PRIMARY sources for the claims in `src/agentic-coding-harnesses.md`, sourced from the single ungrounded Gemini chat exports `notes/initial-notes/harnesses.md`, `Hermes.md`, `MCP.md`, `MCP vs CLI.md`. Confidence tags used throughout:

🟢 primary (vendor's own current docs/repo/spec, the paper itself, or independently recomputed)
🟡 corroborated-secondary (consistent across multiple independent secondary sources, not primary)
🟠 single-source (only one source found, of any kind)
⚪ could not be corroborated

Date of research: 2026-08-21.

---

## 1. Terminal-first dev agents landscape

**OpenCode / OpenWork.** Real, but two distinct (related) products, and there is a naming-collision trap. 🟢 `opencode` is a real, extremely popular ("model-agnostic harness... 160,000+ GitHub stars") terminal coding agent — [github.com/sst/opencode](https://github.com/sst/opencode), [opencode.ai](https://opencode.ai). It supports 75+ model providers including local models via Ollama, has a polished TUI, and is MIT-licensed with no Anthropic dependency — the chapter's functional description is accurate. 🟢 `OpenWork` is also real and distinct: [github.com/different-ai/openwork](https://github.com/different-ai/openwork), self-described as "the open-source alternative to Claude Cowork (powered by opencode)" — i.e. OpenWork is a desktop/workflow app *built on top of* OpenCode, not a synonym for it. The chapter's "OpenCode / OpenWork" slash-conflation understates that these are two different tools (agent vs. the desktop app wrapping it), though the "powered by" relationship makes the conflation far less severe than the Pi/Kilo case below.

Important nuance not in the chapter: there was a **naming dispute** in 2025 — the original Go-based "OpenCode" creator moved to Charm (whose continuation is now called "Crush"), while other contributors forked, kept the "OpenCode" name and domain, and built what is now the dominant `sst/opencode` project. This matters directly for subtopic 5 below (the dominant OpenCode is TypeScript/Bun, not Go). Source: [BigGo News, "OpenCode Name Dispute Erupts as Two AI Coding Tools Claim Same Identity"](https://biggo.com/news/202507070115_OpenCode_Name_Dispute).

**Goose.** 🟢 Strongly corroborated, primary. Originally built at Block (Square's parent), donated to the Linux Foundation. The **"Agentic AI Foundation" (AAIF) is a real, exact foundation name** — confirmed via the Linux Foundation's own press release: ["Linux Foundation Announces the Formation of the Agentic AI Foundation (AAIF), Anchored by New Project Contributions Including... goose"](https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation) (announced Dec 9, 2025; Platinum members include AWS, Anthropic, Block, Bloomberg, Cloudflare, Google, Microsoft, OpenAI). Goose's own repo/site ([github.com/block/goose](https://github.com/block/goose)) confirms: "Built in Rust for performance and portability," "a general-purpose AI agent that runs on your machine," ships as desktop app / CLI / API, and states "goose is part of the Agentic AI Foundation (AAIF) at the Linux Foundation." The "70+ extensions" figure is also confirmed verbatim on Goose's own site ("Connect to 70+ extensions via the Model Context Protocol") — 🟢 primary.

**Aider.** 🟢 Strongly corroborated, primary. Aider's own site documents the tree-sitter-based repository map in detail: ["Building a better repository map with tree sitter"](https://aider.chat/2023/10/22/repomap.html) — a token-budgeted (`--map-tokens`, default ~1k), PageRank-style graph-ranked symbol index. Auto-commit-to-git behavior is also confirmed on aider.chat. Matches the chapter's claims closely.

**Pi / Kilo CLI — confirmed red flag (a): these are two unrelated products conflated into one bullet.**
- 🟢 **Pi** is real: a minimalist terminal coding agent created by Mario Zechner (of libGDX fame), installed via `npm install -g @mariozechner/pi-coding-agent`, with only four core tools (read/write/edit/bash) and a system prompt + tool definitions kept under ~1,000 tokens, extended via a TypeScript SDK. This matches the chapter's "tiny base system prompt... agent should write its own plugins" description well.
- 🟢 **Kilo CLI** is a *separate, unrelated* product from a different origin (Kilo Code / kilo.ai), an open-source CLI agent supporting 500+ models via `npm i @kilocode/cli`, with distinct "Code / Plan / Ask / Debug" agent modes. It is not built by, derived from, or related to Pi.
- **Verdict on red flag (a): confirmed.** The chapter's "Pi / Kilo CLI" bullet incorrectly presents these as one entity (or interchangeable names for the same tool); they are two different projects from two different teams that happen to share the "hyper-minimalist terminal agent" category.

**OpenAI Codex (CLI / App Server mode).** 🟡 Corroborated-secondary / directionally true but time-sensitive. "SWE-bench Pro" and "Terminal-Bench" are real, named benchmarks that OpenAI itself cites for Codex models (confirmed via OpenAI's own posts, e.g. ["Introducing GPT-5.2-Codex"](https://openai.com/index/introducing-gpt-5-2-codex/): "state-of-the-art performance on SWE-Bench Pro and Terminal-Bench 2.0"). However, the specific "frequently match or beat Claude" framing is a fast-moving target: as of this research date (Aug 2026), third-party trackers show a near-tie — e.g. [morphllm.com's leaderboard](https://www.morphllm.com/ai-coding-agent) cites "Codex CLI runs GPT-5.6 Sol, #1 on Terminal-Bench 2.1 at 89.5%; Claude Code runs Opus 5 at 89.1%" — a 0.4-point gap, not a clear or consistent lead either direction. The general claim is reasonable but should be treated as a snapshot, not a stable fact.

**Cursor & Windsurf (Devin Desktop) — confirmed red flag (b), with an interesting twist.**
Devin (Cognition Labs) and Windsurf are *not* unrelated as the red-flag hypothesis assumed — but the chapter's specific framing is still wrong. 🟢 Cognition (maker of Devin) **acquired Windsurf** on July 14, 2025 (confirmed via [TechCrunch](https://techcrunch.com/2025/07/14/cognition-maker-of-the-ai-coding-agent-devin-acquires-windsurf/), [Cognition's own blog](https://cognition.com/blog/windsurf)), and on June 2, 2026 **rebranded Windsurf itself as "Devin Desktop"** — i.e., "Devin Desktop" is not a nickname or footnote to Windsurf, it *is* the current name of what used to be the standalone Windsurf IDE, now positioned as an "agent-neutral" IDE that can run Codex, Claude Agent, OpenCode, or Devin itself (confirmed via Cognition's own X/Devin blog post and multiple press: [Digg](https://digg.com/ai/11vqsnys), [TechEdt](https://www.techedt.com/cognition-launches-devin-desktop-for-managing-ai-coding-agents-across-engineering-workflows)).
**Correction:** Cursor (Anysphere) remains an entirely separate, unrelated company/product with no ownership tie to Cognition or Windsurf/Devin Desktop. The chapter's parenthetical "(Devin Desktop)" attached after "Cursor & Windsurf" is misleading in a specific, checkable way: it implies Devin Desktop is a subsidiary/branch of the Cursor-Windsurf pairing, when in fact Windsurf *became* Devin Desktop under Cognition (a third, separate company from both Anysphere/Cursor and — obviously — Anthropic). The chapter should either split this into two bullets (Cursor; Devin Desktop [formerly Windsurf]) or explain the acquisition explicitly.

Sources: [OpenCode GitHub](https://github.com/sst/opencode), [OpenCode.ai](https://opencode.ai), [OpenWork GitHub](https://github.com/different-ai/openwork), [BigGo naming dispute article](https://biggo.com/news/202507070115_OpenCode_Name_Dispute), [Linux Foundation AAIF press release](https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation), [Goose GitHub](https://github.com/block/goose), [Aider repo map docs](https://aider.chat/2023/10/22/repomap.html), [Pi coding agent overview](https://allthings.how/pi-coding-agent-the-minimal-terminal-harness-you-extend-yourself/), [Kilo CLI](https://kilo.ai/cli), [OpenAI GPT-5.2-Codex announcement](https://openai.com/index/introducing-gpt-5-2-codex/), [morphllm.com leaderboard](https://www.morphllm.com/ai-coding-agent), [TechCrunch Cognition-Windsurf acquisition](https://techcrunch.com/2025/07/14/cognition-maker-of-the-ai-coding-agent-devin-acquires-windsurf/), [Cognition Devin Desktop launch coverage](https://digg.com/ai/11vqsnys).

---

## 2. Server-side orchestrators landscape

**Claude Cowork — confirmed real, current Anthropic product** (red flag a resolved: it's not fabricated/outdated). 🟡 Corroborated-secondary via many independent, reputable outlets (Anthropic's own `/news/claude-cowork` URL 404'd at check time, but the product's existence and description are extremely well corroborated in press): announced Jan 12, 2026 ([TechCrunch](https://www.techcrunch.com/2026/01/12/anthropics-new-cowork-tool-offers-claude-code-without-the-code/), [Axios](https://axios.com/2026/01/12/ai-anthropic-claude-jobs), [The Register](https://www.theregister.com/2026/01/13/anthropic_previews_claude_cowork_for/)), expanded to enterprise integrations Feb 2026 ([CNBC](https://www.cnbc.com/2026/02/24/anthropic-claude-cowork-office-worker.html)), and to web/mobile July 2026 ([VentureBeat](https://venturebeat.com/technology/anthropic-brings-claude-cowork-to-mobile-and-web-as-usage-data-shows-most-users-arent-coding), [TechCrunch](https://techcrunch.com/2026/07/07/the-coding-agent-wars-are-spilling-into-the-rest-of-the-office-claude-cowork/)). Description matches the chapter closely: "hands-free," folder-scoped file agent, plans and executes without step-by-step prompting.

**Symphony — real, but the chapter omits a load-bearing fact: it's OpenAI's own project, not an independent/neutral competitor.** 🟢 Confirmed via direct repo fetch: [github.com/openai/symphony](https://github.com/openai/symphony), owned by the `openai` GitHub org. README: "turns project work into isolated, autonomous implementation runs, allowing teams to manage work instead of supervising coding agents." Demo material confirms: "Symphony monitors a Linear board for work and spawns agents to handle the tasks. The agents complete the tasks and provide proof of work: CI status, PR review feedback, complexity analysis, and walkthrough videos" — this matches the chapter's "poll project boards... spin up isolated workspaces, run code until tests pass, and generate human-verifiable proof-of-work summaries" claim almost exactly. Confirmed adapters exist for Linear, GitHub Issues, Jira Cloud, Asana, GitLab.
**Correction:** the chapter presents "Symphony" as a generic, standalone open-source challenger alongside OpenClaw/DeerFlow with no attribution — but it is specifically OpenAI's own orchestration layer, built to run *Codex* agents in isolated per-issue workspaces. This is a materially different category (a vendor's own orchestrator vs. an independent open-source project) and should be attributed as such. (Note: there is also an unrelated third-party clone with a similar concept, `broomva/symphony`, a Rust daemon — worth disambiguating if this name is kept.)

**DeerFlow.** 🟢 Confirmed real and ByteDance-backed via its own repo: [github.com/bytedance/deer-flow](https://github.com/bytedance/deer-flow), "An open-source long-horizon SuperAgent harness that researches, codes, and creates. With the help of sandboxes, memories, tools, skill, subagents and message gateway..." Each agent runs in an isolated Docker container with its own filesystem/terminal — matches the chapter's "isolated sub-agents, persistent memory graphs, and containerized sandboxed background work" description well.

**Perplexity Computer.** 🟡 Strongly corroborated-secondary (near-primary via CEO's own public statement, quoted across many outlets). Launched Feb 25, 2026; CEO Aravind Srinivas: "Perplexity Computer orchestrates 19 models" ("One reasons, another codes, another writes") — the exact "19-model" figure is confirmed, not fabricated. Runs in an isolated cloud sandbox per job (2 vCPU/8GB RAM), 400+ managed OAuth connectors. Matches the chapter's description well, though note the product's marketing name varies slightly across sources ("Perplexity Computer" / "Perplexity's Personal Computer agent") — "Perplexity Computer" (as the chapter uses) is the primary/original name at launch.

**OpenClaw.** 🟡 Corroborated-secondary, close but not exact on the numbers. Real, large (180K+ GitHub-star-class) open-source always-on agent framework interfacing over messaging platforms. Sources give **23+ messaging/communication channels** (not "24+" exactly, but within rounding: Telegram, WhatsApp, Discord, Signal, Slack, Teams, iMessage, Matrix, etc.) and separately "50+ integrations" spanning chat, AI models, productivity, smart home, etc. "Thousands of modular tool skills" is confirmed independently — the community ClawHub/skills registry lists "thousands" of skills, with one tracking repo listing "5,400+ skills filtered and categorized from the official OpenClaw Skills Registry." Overall: directionally accurate, exact "24+" figure not found verbatim (closest primary-adjacent figure is 23+).

Sources: [Claude Cowork TechCrunch launch](https://www.techcrunch.com/2026/01/12/anthropics-new-cowork-tool-offers-claude-code-without-the-code/), [Claude Cowork CNBC](https://www.cnbc.com/2026/02/24/anthropic-claude-cowork-office-worker.html), [Claude Cowork VentureBeat](https://venturebeat.com/technology/anthropic-brings-claude-cowork-to-mobile-and-web-as-usage-data-shows-most-users-arent-coding), [OpenAI Symphony GitHub](https://github.com/openai/symphony), [DeerFlow GitHub](https://github.com/bytedance/deer-flow), [Perplexity Computer coverage (therundown.ai)](https://www.therundown.ai/p/perplexitys-19-model-ai-computer), [Perplexity Computer coverage (sci-tech-today)](https://www.sci-tech-today.com/news/perplexity-computer-19-model-ai-agent/), [OpenClaw guide (elest.io)](https://blog.elest.io/openclaw-free-open-source-ai-agent-running-24-7-on-your-server/), [awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills).

---

## 3. Hermes Agent internal architecture — HIGH PRIORITY

**The chapter's file tree is WRONG in structure, though most individual filenames are real.** Verified directly against the live repo (`github.com/NousResearch/hermes-agent`, confirmed real via GitHub API — MIT license, Python, active, topics include `ai-agent`, `nous-research`; and against Nous's own docs site `hermes-agent.nousresearch.com/docs/`).

Chapter's claimed tree (all six files flat under repo root):
```
hermes-agent/
├── run_agent.py
├── model_tools.py
├── toolsets.py
├── context_engine.py
├── context_compressor.py
└── hermes_state.py
```

**Actual structure, confirmed via the GitHub Contents API and Nous's own architecture docs:**
- 🟢 `run_agent.py`, `model_tools.py`, `toolsets.py`, `hermes_state.py` **are** real, top-level files at the repo root (confirmed via `api.github.com/repos/NousResearch/hermes-agent/contents/`).
- 🟢 **`context_engine.py`, `context_compressor.py`, and `prompt_builder.py` are real files but live inside an `agent/` subdirectory** (`agent/context_engine.py`, `agent/context_compressor.py`, `agent/prompt_builder.py`), not at the repo root as the chapter's tree implies. Confirmed via GitHub search results directly showing `hermes-agent/agent/context_compressor.py at main · NousResearch/hermes-agent` and `hermes-agent/agent/prompt_builder.py at main · NousResearch/hermes-agent`, and via `deepwiki.com/NousResearch/hermes-agent` listing `agent/agent_init.py`, `agent/context_breakdown.py`, `agent/prompt_builder.py`, `agent/system_prompt.py`, `agent/redact.py` under a top-level `agent/` directory.
- The real repo root is far larger and more complex than six files — it includes `acp_adapter/`, `agent/`, `apps/`, `cli.py`, `cron/`, `gateway/`, `hermes/`, `hermes_state_common.py`, `hermes_state_portability.py`, `hermes_state_schema.py`, `hermes_state_search.py`, `mcp_serve.py`, `optional-mcps/`, `optional-skills/`, `plugins/`, `providers/`, `skills/`, `tools/`, `trajectory_compressor.py`, `tui_gateway/`, `website/`, and dozens more files. The `hermes_state.py` persistence layer is itself split across several `hermes_state_*.py` files, not one monolithic file.
- **Verdict on the file tree specifically: corrected.** The individual filenames the chapter cites are mostly real, but presenting them as six flat files directly under `hermes-agent/` is inaccurate — three of the six actually live under `agent/`, and the repo is vastly larger than a 6-file layout suggests. This is a milder version of the "real product + invented specifics" pattern flagged in CLAUDE.md: here the specifics (filenames) are largely real, but their *arrangement* is fabricated/simplified in a way that misrepresents the actual repo.

**`AIAgent` class in `run_agent.py`:** 🟢 Confirmed via direct fetch of the raw file (`raw.githubusercontent.com/NousResearch/hermes-agent/main/run_agent.py`). It defines `class AIAgent:` with docstring "AI Agent with tool calling capabilities... manages the conversation flow, tool execution, and response handling." Nous's own architecture docs describe it as the "synchronous orchestration engine" that "Handles provider selection, prompt construction, tool execution, retries, fallback, callbacks, compression, and persistence." Constructor parameters confirmed: `reasoning_config`, `max_tokens`, `run_budget_seconds` (wall-clock budget), `iteration_budget` (an `IterationBudget` object — i.e., a real max-reasoning-step-count mechanism, though not literally called "max reasoning depth" in the code). **Verdict: strongly corroborated**, chapter's characterization is accurate in substance even if not verbatim in naming.

**`model_tools.py` tool discovery/dispatch:** 🟡 Corroborated but not exactly as described. Nous's docs describe `model_tools.py` as importing "tools/registry + triggers tool discovery," and separately note a **central tool registry (`tools/registry.py`) with "70+ registered tools across ~28 toolsets"** where tools "self-register at import time." The chapter's claim that `model_tools.py` "auto-generates JSON tool specs from Python functions" is directionally right (there is automatic discovery/schema generation) but the actual architecture centers on a separate `tools/registry.py`, not solely `model_tools.py`. Note: Hermes's own "70+ tools" figure is coincidentally close to Goose's separately-confirmed "70+ extensions" (§1) — likely coincidence given both are real, independently-sourced numbers for different products, but worth flagging since the source chat may have blurred the two.

**`hermes_state.py` — SQLite + FTS5:** 🟢 Strongly confirmed, primary, via direct fetch of the raw file. Docstring: "Provides persistent session storage with FTS5 full-text search, replacing the per-session JSONL file approach." Confirmed: WAL mode, `messages_fts`, `messages_fts_trigram`, `messages_fts_cjk` virtual tables, `sessions`/`messages` tables. **Matches the chapter's claim exactly.**

**`context_compressor.py` — algorithmic dropping / LLM-based compaction:** 🟡 Corroborated. Nous's docs describe it as "the default context engine, using lossy summarization" and a `ContextCompressor` class that "summarizes conversation history to fit within model limits while protecting recent turns." `context_engine.py` is described as "an abstract base class for pluggable compression strategies." This matches the chapter's description reasonably well, though "algorithmically drops redundant middle steps" specifically wasn't found verbatim — the confirmed mechanism is LLM-based summarization of middle turns while protecting recent ones.

**Dynamic Memory / Skills system — one specific claim is corrected: it does NOT use vector search.** This is the most significant finding in this subtopic.
- 🟢 Confirmed real and matches the chapter closely: skills **are** distilled from successful task trajectories into Markdown files, stored at **`~/.hermes/skills/`** exactly as the chapter claims (confirmed via Nous's own docs, e.g. [work-with-skills.md on GitHub](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/guides/work-with-skills.md) and [hermes-agent.nousresearch.com/docs/user-guide/features/skills](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills): "All skills live in `~/.hermes/skills/`," organized as `<skill-name>/SKILL.md` plus optional `references/`, `templates/`, `scripts/` subdirectories). A secondary source (Medium review) states: "After a task finishes with five or more tool calls, a background process summarizes the trajectory into a Markdown skill file with a YAML frontmatter header" — matching the chapter's "successful task trajectories get distilled into markdown 'skill' files" claim well.
- **🔴 Correction: retrieval is explicit keyword/full-text search (SQLite+FTS5), not vector search.** The same secondary source states directly: "the agent searches its own logbook by keyword, not by embedding similarity, which in practice is more reliable than a vector search... Hermes chose SQLite + FTS5 (Full-Text Search 5) over a vector database." This is consistent with — and reinforced by — the primary-source confirmation that `hermes_state.py` is built entirely around SQLite FTS5 virtual tables, with no vector-embedding infrastructure found anywhere in the confirmed file listing or docs. The chapter's claim that skills are "later retrieved via vector search by a `prompt_builder.py`" therefore appears to be an invented detail — Hermes deliberately chose the opposite (keyword/FTS5) approach.
- `prompt_builder.py` itself is real (confirmed location: `agent/prompt_builder.py`) and is accurately described by Nous's own docs as assembling "the ordered system-prompt tiers (stable → context → volatile): identity/tool guidance/skills, context files, then memory/profile/timestamp blocks" — i.e., it does inject a skills index into the system prompt, just not via vector search.

**Verdict on subtopic 3 overall: corrected.** Nous Research's Hermes Agent is real and its architecture is broadly as sophisticated as claimed, and most individual filenames/classes are real and directly verifiable — but (1) the presented file tree misstates which files live at repo root vs. under `agent/`, and (2) the specific "vector search" retrieval mechanism for skills is very likely fabricated; primary and secondary evidence converge on FTS5 keyword search instead. This is a milder instance of the "real product + invented specifics" pattern the project has seen before, and is worth a `Research Note:` in the chapter.

Sources: [NousResearch/hermes-agent GitHub](https://github.com/NousResearch/hermes-agent), [GitHub Contents API root listing](https://api.github.com/repos/NousResearch/hermes-agent/contents/), [GitHub Contents API agent/ listing](https://api.github.com/repos/NousResearch/hermes-agent/contents/agent), [raw run_agent.py](https://raw.githubusercontent.com/NousResearch/hermes-agent/main/run_agent.py), [raw hermes_state.py](https://raw.githubusercontent.com/NousResearch/hermes-agent/main/hermes_state.py), [Hermes Agent architecture docs](https://hermes-agent.nousresearch.com/docs/developer-guide/architecture), [Hermes Agent prompt-assembly docs](https://hermes-agent.nousresearch.com/docs/developer-guide/prompt-assembly), [Hermes Agent skills docs](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills), [work-with-skills.md](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/guides/work-with-skills.md), [DeepWiki context-and-prompt-management page](https://deepwiki.com/NousResearch/hermes-agent/4.2-context-and-prompt-management), [Hermes Agent review (Medium, kisztof)](https://kisztof.medium.com/hermes-agent-review-nous-researchs-self-improving-ai-agent-e72bc244435a).

---

## 4. Language Server Protocol (LSP) & Agent Client Protocol (ACP)

🟢 **Strongly corroborated, primary, no corrections needed.**

- LSP origin: confirmed Microsoft-created, via the official spec site itself (`microsoft.github.io/language-server-protocol`), which references the `Microsoft/vscode-languageserver-node` and `Microsoft/language-server-protocol` repos directly.
- All four JSON-RPC method names checked against the official LSP 3.17 specification and confirmed exact: `textDocument/definition`, `textDocument/references`, `textDocument/rename`, `textDocument/publishDiagnostics`.
- ACP origin: confirmed to be Zed Industries, not a guess — "originally published by Zed Industries in August 2025" ([tessl.io](https://tessl.io/blog/zed-debuts-agent-client-protocol-to-connect-ai-coding-agents-to-any-editor/), [zed.dev/acp](https://zed.dev/acp)). JSON-RPC 2.0 over stdin/stdout, editor spawns agent as subprocess. As of October 2025, JetBrains partnered with Zed to co-develop ACP and bring native support to IntelliJ/PyCharm/WebStorm, with a shared ACP Agent Registry — confirming current, active status. Apache-licensed, open source.

**Verdict: strongly corroborated**, matches the chapter's brief mention exactly.

Sources: [LSP 3.17 specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification), [Zed ACP overview](https://zed.dev/acp), [tessl.io ACP announcement coverage](https://tessl.io/blog/zed-debuts-agent-client-protocol-to-connect-ai-coding-agents-to-any-editor/), [@zed-industries/agent-client-protocol npm package](https://www.npmjs.com/package/@zed-industries/agent-client-protocol).

---

## 5. Model Connector — OpenCode internals

**🔴 Correction: the chapter's claim is real, but for a different (superseded) OpenCode than the one the book otherwise means.**

- 🟢 Confirmed via `pkg.go.dev`: `github.com/opencode-ai/opencode/internal/llm/provider` is a real Go package, exporting a `Provider` interface with `SendMessages()`, `StreamResponse()`, `Model()`, and a `NewProvider()` constructor supporting Anthropic, Bedrock, Copilot, Gemini, OpenAI, and others. So an `internal/llm`-shaped, Go-based model connector abstraction genuinely exists at that exact import path — the chapter's specific technical claim is not invented.
- 🔴 **However**, `opencode-ai/opencode` is the *original*, Go-based OpenCode — the one that lost the 2025 naming dispute (see §1) and whose creator moved to Charm (continuation now called "Crush"). It is **not** the "OpenCode" that is dominant today and that the chapter itself introduces in §1 as "one of the most prominent open-source 1:1 replacements for Claude Code" with "160,000+ GitHub stars." That dominant, currently-active project is **`github.com/sst/opencode`**, confirmed via direct repo fetch to be built in **TypeScript on Bun** (repo root shows `package.json`, `tsconfig.json`, `turbo.json`, `bunfig.toml`; a GitHub issue is literally titled ["question] Why the typescript and npm?"](https://github.com/sst/opencode/issues/2143)), with **no `internal/llm` directory** — its structure uses `packages/`, `infra/`, `sdks/`, `specs/` instead.
- **Verdict:** the chapter's "OpenCode's Go-based `internal/llm` abstraction" claim is a real, checkable, primary-sourced fact — but about the wrong OpenCode. The 160k-star OpenCode the book actually means (per its own §1 description) is TypeScript, not Go, and has no `internal/llm` path. This is exactly the "naming confusion between multiple projects with the same name" risk flagged in the task brief, confirmed to have occurred.
- The second half of the claim (Claude Code's connector being hardcoded to Anthropic's APIs, assuming native prompt caching / Anthropic-specific tool-calling / token-counting) is a reasonable, unfalsifiable-in-detail architectural inference about closed-source software — Anthropic does not publish Claude Code's internals, so this cannot be verified against a primary source either way; treat as ⚪ could not be corroborated (plausible but unconfirmable) for the specific internal claim, though it's consistent with Claude Code being a single-vendor CLI in every public description.

Sources: [pkg.go.dev opencode-ai/opencode/internal/llm/provider](https://pkg.go.dev/github.com/opencode-ai/opencode/internal/llm/provider), [sst/opencode GitHub repo](https://github.com/sst/opencode), [sst/opencode issue #2143 on TypeScript/npm](https://github.com/sst/opencode/issues/2143), [BigGo naming dispute article](https://biggo.com/news/202507070115_OpenCode_Name_Dispute), [DeepWiki sst/opencode provider docs](https://deepwiki.com/sst/opencode/3.3-provider-and-model-configuration).

---

## 6. MCP fundamentals

🟢 **Strongly corroborated, primary. No corrections.**

Confirmed directly via Anthropic's own announcement and the official spec site:
- Introduction date: **November 25, 2024**, Anthropic open-sourced MCP (confirmed via [Anthropic's own news post](https://www.anthropic.com/news/model-context-protocol) and secondary coverage, e.g. VentureBeat, Wikipedia). Created by Anthropic engineers David Soria Parra and Justin Spahr-Summers. Initial reference servers: Google Drive, Slack, GitHub, Git, Postgres, Puppeteer; initial dev-tool partners: Zed, Replit, Codeium, Sourcegraph.
- Architecture and terminology: confirmed via [modelcontextprotocol.io](https://modelcontextprotocol.io/introduction) itself — host/client/server model, JSON-RPC-based, "USB-C port for AI applications" analogy. The three primitives (tools, resources, prompts) match the chapter's description; the official intro page explicitly enumerates "data sources... tools... workflows (e.g. specialized prompts)."

**Verdict: strongly corroborated.**

Sources: [Anthropic's original MCP announcement](https://www.anthropic.com/news/model-context-protocol), [modelcontextprotocol.io introduction](https://modelcontextprotocol.io/introduction), [Wikipedia MCP overview](https://en.wikipedia.org/wiki/Model_Context_Protocol).

---

## 7. REST/OpenAPI MCP translation tooling

**🔴 Correction: the flagship npm package name is fabricated / does not exist; the PyPI equivalent is real.**

- 🔴 **`@modelcontextprotocol/server-openapi` does NOT exist.** Confirmed via a direct query to the npm registry API (`registry.npmjs.org/@modelcontextprotocol/server-openapi`), which returned **HTTP 404 Not Found**. A full listing of the official `@modelcontextprotocol` npm scope (55 packages, fetched via `registry.npmjs.org/-/user/modelcontextprotocol/package`) confirms the official reference servers are things like `postgres`, `redis`, `gdrive`, `github`, `gitlab`, `slack`, `brave-search`, `google-maps`, `aws-kb-retrieval`, `puppeteer`, `pdf`, `filesystem`, `memory`, `sequential-thinking`, plus SDK/framework packages (`sdk`, `create-server`, Express/Hono/Fastify adapters, an Inspector) — **there is no official OpenAPI server package**. Real, functioning OpenAPI-to-MCP bridges do exist on npm, but under different, unofficial, third-party names (e.g. `@ivotoby/openapi-mcp-server`, `openapi-mcp-converter`, `openapi-to-mcp-converter`) — none scoped under `@modelcontextprotocol`.
- 🟢 **`openapi-mcp` on PyPI, however, is real** — confirmed via a direct query to the PyPI JSON API (`pypi.org/pypi/openapi-mcp/json`): package exists, version 0.1.0, released March 12, 2025, maintained by Tadata Inc., described as "Automatic MCP server generator for OpenAPI applications — converts OpenAPI endpoints to MCP tools for LLM integration." So the chapter's parenthetical "(or Python equivalents like `openapi-mcp`)" is accurate even though the primary npm claim it's attached to is not.
- **Verdict: the "dominant open-source tool" framing needs correcting** — there is no single dominant official `@modelcontextprotocol`-scoped OpenAPI bridge; the ecosystem is a handful of independent, unofficial third-party tools (npm and PyPI both), of which `openapi-mcp` (PyPI) happens to be real as named but `@modelcontextprotocol/server-openapi` (npm) is not.

Sources: [npm registry API — package not found](https://registry.npmjs.org/@modelcontextprotocol/server-openapi) (404), [npm registry API — full @modelcontextprotocol scope listing](https://registry.npmjs.org/-/user/modelcontextprotocol/package), [PyPI JSON API — openapi-mcp exists](https://pypi.org/pypi/openapi-mcp/json), [janwilmake/openapi-mcp-server (real, unofficial, npm-scope-adjacent alternative)](https://github.com/janwilmake/openapi-mcp-server), [ivo-toby/mcp-openapi-server](https://github.com/ivo-toby/mcp-openapi-server).

---

## 8. GraphQL MCP translation tooling

🟡 Mostly corroborated, with one product-name correction.

- 🟡 **`graphql-mcp.com` is a real, live tool/site.** Direct fetch confirms it describes itself as reading a GraphQL schema and generating AI-ready tools automatically ("Every query becomes a read tool. Every mutation becomes a write tool"), with three usage modes (hosted Bridge, local Python library integration for Strawberry/Ariadne/Graphene, and remote endpoint introspection/proxying). Matches the chapter's description well.
- 🔴 **"Apollo's AI Gateway" is not the correct product name.** Apollo GraphQL's real, current product for bridging AI agents to GraphQL schemas is called **"Apollo MCP Server"** — confirmed directly from Apollo's own blog post (the exact URL the chapter's source notes cite): "Apollo MCP Server solves this by treating your GraphQL schema as a first-class tool in the agent's environment" ([apollographql.com/blog/how-to-build-ai-agents-using-your-graphql-schema](https://www.apollographql.com/blog/how-to-build-ai-agents-using-your-graphql-schema)). Apollo separately has an unrelated, pre-existing product literally called "Apollo Gateway" (GraphQL federation, nothing to do with AI — `@apollo/gateway` on npm), and a broader "GraphOS Context Graph" enterprise-AI narrative. "AI Gateway" as a specific product name does not appear anywhere in Apollo's own materials or in press coverage of the launch (InfoQ, MojoAuth, Security Boulevard, Techstrong.ai all say "MCP Server"). The underlying functionality claimed in the chapter is real and well corroborated — only the specific product name is wrong.
- 🟢 **`mcp-graphql` is real, confirmed on both platforms cited in the source notes.** PyPI: confirmed via direct PyPI JSON API query — package exists, v0.4.1, requires Python 3.11+, depends on `aiohttp`/`click`/`gql`/`mcp[cli]`, introspects GraphQL schemas and turns queries into MCP tools (mutations explicitly listed as "planned feature," not yet supported). GitHub: `github.com/blurrah/mcp-graphql` also confirmed to exist, described similarly ("schema introspection and query execution capabilities"). Note these may be two independently-maintained same-named projects (Python vs. likely TypeScript/Node) rather than one project mirrored across registries — worth a footnote if precision matters, but both individually check out as real and on-topic.

**Verdict: weakly corroborated** — the tooling category and two of three named tools are real and accurately described; the "Apollo's AI Gateway" name is a corrigible error (should read "Apollo MCP Server").

Sources: [graphql-mcp.com](https://graphql-mcp.com), [Apollo's own blog post on AI agents + GraphQL schema](https://www.apollographql.com/blog/how-to-build-ai-agents-using-your-graphql-schema), [InfoQ coverage of Apollo MCP Server launch](https://www.infoq.com/news/2025/05/apollo-graphql-mcp/), [PyPI JSON API — mcp-graphql](https://pypi.org/pypi/mcp-graphql/json), [github.com/blurrah/mcp-graphql](https://github.com/blurrah/mcp-graphql).

---

## 9. gRPC MCP translation tooling

🟢 **Strongly corroborated across all named tools, one minor naming imprecision.**

- 🟢 Redpanda's `protoc-gen-go-mcp`: confirmed via direct fetch of the exact URL the chapter cites — "Protoc-gen-go-mcp is a Protocol Buffers compiler plugin that generates Go code to translate between MCP and gRPC," auto-generates MCP handlers and JSON Schema from `.proto` definitions, produces `*.pb.mcp.go` files, Apache 2.0 licensed. Matches the chapter exactly.
- 🟢 `adiom-data/grpcmcp`: confirmed real at the exact GitHub URL cited — "A simple MCP server that will proxy to a grpc backend based on a provided descriptors file or using reflection," supports `--reflect` mode, exposes unary gRPC methods as MCP tools, supports Streamable HTTP/SSE. Matches the chapter exactly.
- 🟡 ConnectRPC "(formerly Buf Connect)" — **minor imprecision, not a fabrication.** Confirmed the project was originally released and named simply **"Connect"** by Buf in 2022, and was later rebranded **"ConnectRPC"** specifically because "Connect" was too ambiguous/poor for SEO (multiple unrelated products share the name) — confirmed via [kmcd.dev's "ConnectRPC: Where is it now?"](https://kmcd.dev/posts/connectrpc-where-is-it-now/) and Buf's own blog (["Connect: A better gRPC"](https://buf.build/blog/connect-a-better-grpc)). So the former name was literally **"Connect"** (a Buf project), not a compound "Buf Connect" — the chapter's parenthetical is directionally correct (same company, same rename direction) but not the exact former name.
- 🟢 ggRMCP Gateway (context only, not currently in the chapter): confirmed real — `github.com/aalobaidi/ggRMCP`, "a gateway that converts gRPC services into MCP-compatible tools... acts as a translator between the gRPC world and the MCP ecosystem," uses gRPC reflection, experimental/not production-ready per its own README.

**Verdict: strongly corroborated**, with one minor, low-stakes naming nuance on ConnectRPC's former name.

Sources: [Redpanda blog — protoc-gen-go-mcp](https://www.redpanda.com/blog/turn-grpc-api-into-mcp-server), [github.com/adiom-data/grpcmcp](https://github.com/adiom-data/grpcmcp), [kmcd.dev — ConnectRPC where is it now](https://kmcd.dev/posts/connectrpc-where-is-it-now/), [Buf's own "Connect: A better gRPC" blog post](https://buf.build/blog/connect-a-better-grpc), [github.com/aalobaidi/ggRMCP](https://github.com/aalobaidi/ggRMCP).

---

## 10. Human-vs-Machine CLI/MCP generation tooling

🟡 Mostly corroborated; one likely-fabricated citation identified.

- 🟢 **FastMCP's `fastmcp generate-cli` command is real**, confirmed via FastMCP's own docs (`gofastmcp.com/cli/generate-cli`): exact syntax `fastmcp generate-cli <server-target> [output-path] [options]`, e.g. `fastmcp generate-cli server.py my_weather_cli.py`. **Correction:** FastMCP's own docs mention **only Python's `cyclopts`** for the generated CLI ("`generate-cli` maps that into cyclopts commands") — there is **no mention of Node's `commander`** anywhere in FastMCP's own documentation for this feature. `commander` is a real, widely-used Node.js CLI-building library in general, but it is not part of FastMCP's `generate-cli` feature as the chapter implies; FastMCP's generated CLI is Python-only.
- 🟢 **Apify's `mcpc` is real**, confirmed via direct repo fetch at the exact URL cited (`github.com/apify/mcpc`, 753 stars, 72 forks at check time): "a command-line client for the Model Context Protocol (MCP) that maps every MCP operation to an intuitive shell command," with OAuth 2.1, persistent sessions, JSON output for scripting. Matches the chapter closely.
- 🟢 **MCPLI is real**, confirmed at `github.com/cameroncooke/mcpli`: "turns any stdio-based MCP server into a discoverable, script-friendly, agent-friendly CLI," backed by a persistent daemon, composable with standard shell tools (`| jq`, etc.). Matches the chapter's description well.
- 🟢 **`mcp-cli-adapter` is real**, confirmed at `github.com/inercia/mcp-cli-adapter` (also branded "MCPShell"), listed on the exact `mcpservers.org` URL the source notes cite: "securely use command line tools as MCP tools," usable with Claude/Cursor/VS Code. Matches the chapter's direction (wrapping CLI/shell tools into MCP) well, though it runs the opposite direction from a pure "human CLI → MCP bridge for a specific product's own CLI" — it's a generic shell-script-to-MCP-tool wrapper.
- 🔴 **"LobeHub's CLI-as-MCP" could not be corroborated, and there's a specific red flag in its own citation.** No tool by the literal name "CLI-as-MCP" was found on LobeHub or elsewhere despite direct searching. LobeHub's MCP marketplace does host several *different*, separately-named CLI-wrapping tools (`any-cli-mcp-server`, `cli-mcp`, `mcp-cli`, a `CLIMCPServer` built into "MCP Chain") — but none of these is named "CLI-as-MCP." Critically, the chapter's own source notes (`notes/initial-notes/MCP vs CLI.md`) cite this tool at the URL `lobehub.com/mcp/yourusername-cli-as-mcp` — **the slug literally contains the placeholder string "yourusername,"** which is a strong, self-evident signal that this citation is a template/example artifact rather than a real, resolved listing page. **Verdict: could not be corroborated; likely fabricated/hallucinated citation** and should be removed or replaced with one of the real, differently-named LobeHub-hosted tools if this category needs a LobeHub example.

**Verdict: weakly corroborated** — four of five named tools are real and accurately described (with one small correction on FastMCP/commander); the fifth ("LobeHub's CLI-as-MCP") could not be found and its own source citation contains a template placeholder, a strong signal of fabrication.

Sources: [FastMCP generate-cli docs](https://gofastmcp.com/cli/generate-cli), [github.com/apify/mcpc](https://github.com/apify/mcpc), [github.com/cameroncooke/mcpli](https://github.com/cameroncooke/mcpli), [mcpservers.org — mcp-cli-adapter](https://mcpservers.org/servers/inercia/mcp-cli-adapter), [github.com/inercia/mcp-cli-adapter](https://github.com/inercia/mcp-cli-adapter), [LobeHub MCP marketplace search results (no "CLI-as-MCP" match found)](https://lobehub.com/mcp/eirikb-any-cli-mcp-server).

---

## All sources cited (deduplicated)

- [github.com/sst/opencode](https://github.com/sst/opencode)
- [opencode.ai](https://opencode.ai)
- [github.com/different-ai/openwork](https://github.com/different-ai/openwork)
- [BigGo — OpenCode Name Dispute](https://biggo.com/news/202507070115_OpenCode_Name_Dispute)
- [Linux Foundation — AAIF press release](https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation)
- [github.com/block/goose](https://github.com/block/goose)
- [Aider — repo map with tree-sitter](https://aider.chat/2023/10/22/repomap.html)
- [Pi coding agent overview (allthings.how)](https://allthings.how/pi-coding-agent-the-minimal-terminal-harness-you-extend-yourself/)
- [Kilo CLI (kilo.ai)](https://kilo.ai/cli)
- [OpenAI — Introducing GPT-5.2-Codex](https://openai.com/index/introducing-gpt-5-2-codex/)
- [morphllm.com — Best AI Coding Agent leaderboard](https://www.morphllm.com/ai-coding-agent)
- [TechCrunch — Cognition acquires Windsurf](https://techcrunch.com/2025/07/14/cognition-maker-of-the-ai-coding-agent-devin-acquires-windsurf/)
- [Cognition — Windsurf acquisition blog post](https://cognition.com/blog/windsurf)
- [Digg — Cognition launches Devin Desktop](https://digg.com/ai/11vqsnys)
- [TechEdt — Devin Desktop launch coverage](https://www.techedt.com/cognition-launches-devin-desktop-for-managing-ai-coding-agents-across-engineering-workflows)
- [TechCrunch — Anthropic's Claude Cowork launch](https://www.techcrunch.com/2026/01/12/anthropics-new-cowork-tool-offers-claude-code-without-the-code/)
- [Axios — Claude Cowork](https://axios.com/2026/01/12/ai-anthropic-claude-jobs)
- [The Register — Claude Cowork](https://www.theregister.com/2026/01/13/anthropic_previews_claude_cowork_for/)
- [CNBC — Claude Cowork enterprise update](https://www.cnbc.com/2026/02/24/anthropic-claude-cowork-office-worker.html)
- [VentureBeat — Claude Cowork to mobile/web](https://venturebeat.com/technology/anthropic-brings-claude-cowork-to-mobile-and-web-as-usage-data-shows-most-users-arent-coding)
- [TechCrunch — Claude Cowork mobile/web expansion](https://techcrunch.com/2026/07/07/the-coding-agent-wars-are-spilling-into-the-rest-of-the-office-claude-cowork/)
- [github.com/openai/symphony](https://github.com/openai/symphony)
- [github.com/bytedance/deer-flow](https://github.com/bytedance/deer-flow)
- [therundown.ai — Perplexity Computer](https://www.therundown.ai/p/perplexitys-19-model-ai-computer)
- [sci-tech-today.com — Perplexity Computer](https://www.sci-tech-today.com/news/perplexity-computer-19-model-ai-agent/)
- [blog.elest.io — OpenClaw overview](https://blog.elest.io/openclaw-free-open-source-ai-agent-running-24-7-on-your-server/)
- [github.com/VoltAgent/awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills)
- [github.com/NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)
- [GitHub Contents API — hermes-agent root](https://api.github.com/repos/NousResearch/hermes-agent/contents/)
- [GitHub Contents API — hermes-agent/agent](https://api.github.com/repos/NousResearch/hermes-agent/contents/agent)
- [raw run_agent.py](https://raw.githubusercontent.com/NousResearch/hermes-agent/main/run_agent.py)
- [raw hermes_state.py](https://raw.githubusercontent.com/NousResearch/hermes-agent/main/hermes_state.py)
- [hermes-agent.nousresearch.com/docs/developer-guide/architecture](https://hermes-agent.nousresearch.com/docs/developer-guide/architecture)
- [hermes-agent.nousresearch.com/docs/developer-guide/prompt-assembly](https://hermes-agent.nousresearch.com/docs/developer-guide/prompt-assembly)
- [hermes-agent.nousresearch.com/docs/user-guide/features/skills](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills)
- [github.com/NousResearch/hermes-agent — work-with-skills.md](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/guides/work-with-skills.md)
- [DeepWiki — hermes-agent context/prompt management](https://deepwiki.com/NousResearch/hermes-agent/4.2-context-and-prompt-management)
- [Medium (kisztof) — Hermes Agent review](https://kisztof.medium.com/hermes-agent-review-nous-researchs-self-improving-ai-agent-e72bc244435a)
- [Microsoft — LSP 3.17 specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification)
- [Zed — Agent Client Protocol](https://zed.dev/acp)
- [tessl.io — Zed debuts ACP](https://tessl.io/blog/zed-debuts-agent-client-protocol-to-connect-ai-coding-agents-to-any-editor/)
- [npm — @zed-industries/agent-client-protocol](https://www.npmjs.com/package/@zed-industries/agent-client-protocol)
- [pkg.go.dev — opencode-ai/opencode/internal/llm/provider](https://pkg.go.dev/github.com/opencode-ai/opencode/internal/llm/provider)
- [github.com/sst/opencode — issue #2143 (TypeScript/npm)](https://github.com/sst/opencode/issues/2143)
- [DeepWiki — sst/opencode provider/model config](https://deepwiki.com/sst/opencode/3.3-provider-and-model-configuration)
- [Anthropic — Introducing the Model Context Protocol](https://www.anthropic.com/news/model-context-protocol)
- [modelcontextprotocol.io/introduction](https://modelcontextprotocol.io/introduction)
- [Wikipedia — Model Context Protocol](https://en.wikipedia.org/wiki/Model_Context_Protocol)
- [npm registry API — @modelcontextprotocol/server-openapi (404)](https://registry.npmjs.org/@modelcontextprotocol/server-openapi)
- [npm registry API — @modelcontextprotocol scope package list](https://registry.npmjs.org/-/user/modelcontextprotocol/package)
- [PyPI JSON API — openapi-mcp](https://pypi.org/pypi/openapi-mcp/json)
- [github.com/janwilmake/openapi-mcp-server](https://github.com/janwilmake/openapi-mcp-server)
- [github.com/ivo-toby/mcp-openapi-server](https://github.com/ivo-toby/mcp-openapi-server)
- [graphql-mcp.com](https://graphql-mcp.com)
- [Apollo — How to build AI agents using your GraphQL schema](https://www.apollographql.com/blog/how-to-build-ai-agents-using-your-graphql-schema)
- [InfoQ — Apollo GraphQL launches MCP Server](https://www.infoq.com/news/2025/05/apollo-graphql-mcp/)
- [PyPI JSON API — mcp-graphql](https://pypi.org/pypi/mcp-graphql/json)
- [github.com/blurrah/mcp-graphql](https://github.com/blurrah/mcp-graphql)
- [Redpanda — turn a gRPC API into an MCP server](https://www.redpanda.com/blog/turn-grpc-api-into-mcp-server)
- [github.com/adiom-data/grpcmcp](https://github.com/adiom-data/grpcmcp)
- [kmcd.dev — ConnectRPC: Where is it now?](https://kmcd.dev/posts/connectrpc-where-is-it-now/)
- [Buf — Connect: A better gRPC](https://buf.build/blog/connect-a-better-grpc)
- [github.com/aalobaidi/ggRMCP](https://github.com/aalobaidi/ggRMCP)
- [FastMCP — generate-cli docs](https://gofastmcp.com/cli/generate-cli)
- [github.com/apify/mcpc](https://github.com/apify/mcpc)
- [github.com/cameroncooke/mcpli](https://github.com/cameroncooke/mcpli)
- [mcpservers.org — mcp-cli-adapter](https://mcpservers.org/servers/inercia/mcp-cli-adapter)
- [github.com/inercia/mcp-cli-adapter](https://github.com/inercia/mcp-cli-adapter)
- [LobeHub — any-cli-mcp-server (example of what LobeHub actually hosts)](https://lobehub.com/mcp/eirikb-any-cli-mcp-server)

---

## Summary verdicts (per subtopic)

1. Terminal-first dev agents landscape — **corrected** (Pi/Kilo CLI confirmed as two unrelated products conflated into one bullet; Devin Desktop is now literally the rebranded Windsurf under Cognition, not a footnote to Cursor; Goose/AAIF/70+ extensions/Aider claims strongly corroborated).
2. Server-side orchestrators landscape — **corrected** (Claude Cowork confirmed real and current; Symphony confirmed real but is OpenAI's own product, not an independent challenger, which the chapter fails to attribute; OpenClaw/DeerFlow/Perplexity Computer strongly corroborated with minor number rounding on OpenClaw's platform count).
3. Hermes Agent internal architecture — **corrected** (most filenames/classes real and directly verified, but the flat 6-file tree misplaces 3 of 6 files that actually live under `agent/`; the "vector search" skill-retrieval claim is very likely fabricated — Hermes explicitly uses SQLite+FTS5 keyword search instead; `~/.hermes/skills/` path and markdown-skill-from-trajectory claims confirmed accurate).
4. Language Server Protocol (LSP) & Agent Client Protocol (ACP) — **strongly corroborated** (all method names and origins confirmed against primary specs).
5. Model Connector — OpenCode internals — **corrected** (the Go-based `internal/llm` package is real but belongs to the superseded `opencode-ai/opencode`, not the dominant `sst/opencode` — which is TypeScript/Bun and has no `internal/llm` path).
6. MCP fundamentals — **strongly corroborated** (date, architecture, and primitives confirmed against Anthropic's own announcement and the official spec).
7. REST/OpenAPI MCP translation tooling — **corrected** (`@modelcontextprotocol/server-openapi` does not exist on npm — confirmed 404 against the registry directly; `openapi-mcp` on PyPI is real).
8. GraphQL MCP translation tooling — **weakly corroborated** (graphql-mcp.com and mcp-graphql both real; "Apollo's AI Gateway" is the wrong product name — the real product is "Apollo MCP Server").
9. gRPC MCP translation tooling — **strongly corroborated** (all three named tools confirmed real and accurate; ConnectRPC's former name was "Connect," not literally "Buf Connect" — a minor imprecision).
10. Human-vs-Machine CLI/MCP generation tooling — **weakly corroborated** (FastMCP generate-cli, mcpc, MCPLI, and mcp-cli-adapter all confirmed real, though FastMCP's generate-cli is Python/cyclopts-only with no Node/commander support as implied; "LobeHub's CLI-as-MCP" could not be corroborated and its own source citation contains a literal "yourusername" placeholder in the URL, a strong sign of a fabricated/template citation).
