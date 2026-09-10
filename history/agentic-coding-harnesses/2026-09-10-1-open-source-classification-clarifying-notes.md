# 2026-09-10 · Run 1 · agentic-coding-harnesses · Open-source classification clarifying notes

**Type:** small targeted content edit to one section, written live during the run. Not a full `edit-chapter` / `fact-check` pass — no `notes/` research pass produced (only lightweight license verification, recorded below).

## Triggering request

User asked whether there are valid reasons Codex is listed under "Commercial / managed" rather than "Open-source" in the "Terminal-First Dev Agents" section. After the discussion, user asked to add clarifying `Research Note:` paragraph(s) for Codex CLI, Gemini CLI, Qwen Code and Aider capturing the explanation given in that discussion.

## Seed / inputs

- The existing section `## Terminal-First Dev Agents` in `src/agentic-coding-harnesses.md` and its "Open-source" / "Commercial / managed" split.
- Prior `fact-check` reasoning that reclassified Symphony from "independent OSS project" to "OpenAI's own tool" (`notes/2026-08-21-1-agentic-coding-harnesses-harness-mcp-fact-check/summary-*.md`, finding 2) — cited as precedent for grouping by vendor-independence rather than license.
- Live license / model-support checks (GitHub repos): `openai/codex` (Apache-2.0), `google-gemini/gemini-cli` (Apache-2.0, Gemini-only auth), `QwenLM/qwen-code` (Apache-2.0, fork of Gemini CLI v0.8.2, now multi-protocol: OpenAI/Anthropic/Gemini/Qwen + local, runtime-switchable), `Aider-AI/aider` (Apache-2.0, model-agnostic incl. local).
- Existing note in `notes/2026-08-29-4-local-models-qwen3-8-consumer-gpu-research/` confirming Qwen Code is "a CLI harness, not a model."

## Scope of this chapter's edit

- Added one `Research Note:` paragraph after the existing Pi/Kilo/Devin research note in `## Terminal-First Dev Agents`, stating that the open-source vs. commercial split groups by model-vendor independence rather than client license, and working through the four named tools (Codex CLI, Gemini CLI, Qwen Code, Aider) as examples.
- No list bullets moved or added; no other sections changed. No glossary change (the section does not glossary individual CLI tool names).
