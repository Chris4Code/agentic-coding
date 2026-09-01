# 2026-08-21 · run 1 · kv-cache-prompt-caching-fact-check

**Skill:** fact-check
**Chapter:** src/basics.md
**Scope:** whole chapter

## Trigger

User asked for deep-research-style fact-checking on book chapters that were originally written purely from `notes/initial-notes/` (a single, ungrounded Gemini "deep research" chat export) with no independent corroboration pass done afterward — as opposed to `sw-factories.md`, which already went through `deep-book-research` + `edit-chapter`. Asked to (a) identify subtopics needing corroboration, (b) sum up section/paragraph-specific findings as `Research Note:` paragraphs, and (c) log raw findings to a new dated `notes/` folder where needed. Candidate chapters with zero existing `Research Note:` paragraphs were identified as `basics.md`, `agentic-coding-harnesses.md`, and `rags.md`; user chose to start with `basics.md` only.

## Input materials

- `notes/initial-notes/Token Cache ⁄ KV-Cache and Prompt-Caching.md` — original source for the KV-cache/PagedAttention/prompt-caching content; flagged going in as citing two possibly-fictional products ("Open-Claw", "Hermes Agent").
- `notes/initial-notes/Context engineering.md` — original source for the loop-engineering token-savings percentages and cost-impact table.
- `notes/2026-08-18-1-sw-factories-langchain-loop-engineering-deep-research/summary-langchain--loop-engineering.md` — checked as prior art; confirmed `basics.md`'s "loop engineering" (per-agent context window) is a deliberately distinct sense from `sw-factories.md`'s "loop engineering" (factory-level), not a conflict to resolve.
- Six subtopics identified from reading the chapter: (1) KV cache memory-footprint formula and Llama 3 8B example numbers, (2) GQA / KV-cache quantization / sliding-window shrink factors, (3) PagedAttention/vLLM claims, (4) Anthropic prompt-caching mechanics and pricing, (5) Claude Code-specific cache behavior claims, (6) context/loop-engineering savings percentages — plus an explicit existence check on "Open-Claw" and "Hermes Agent".
