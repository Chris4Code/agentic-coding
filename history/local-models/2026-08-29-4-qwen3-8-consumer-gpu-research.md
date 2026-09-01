# 2026-08-29 · run 4 · qwen3-8-consumer-gpu-research

**Skill:** deep-book-research
**Chapter:** src/local-models.md
**Scope:** targeted single-model research pass — Qwen3.8, focused on consumer-GPU use for agentic coding. Feeds the `## Models` section and its 2026-model `Research Note:`.

## Trigger

User asked: "do some research regarding qwen3.8 especially for use on consumer GPUs and add relevant findings to the `local-models.md` chapter." Explicit subtopic list supplied by the user (see below); chapter file `src/local-models.md` given as the destination.

## Input materials

- `src/local-models.md` (current) — `## Models` section (hardware-tier table + the 2026-model `Research Note:` flagging GLM-5.x / DeepSeek-V4 / Qwen3.6 / Gemma 4 specifics as secondary-sourced). Destination for the findings.
- `notes/2026-08-29-2-local-models-local-models-quantization-moe/raw-*.md` + `summary-*.md` — prior art. Already touched the Qwen3.x line: notes Qwen3.5 (Feb–Mar 2026, dense 4B/9B + 122B-A10B MoE), Qwen3.6 (Apr 2026: Qwen3.6-Plus API + Qwen3.6-35B-A3B open), and lists "Qwen3.8 (later)" as a real-but-secondary-sourced release. Flags that 2026 Qwen specifics rested on HF org listings / Wikipedia / vendor-adjacent blogs, not first-party pages — this pass should push for first-party Qwen sources.
- `notes/initial-notes/Local Modells - Models, SW and AI-GPUs.md` and `Local-Models - Best open weights model for coding.md` — original manual notes; list Qwen-family coding models and consumer-GPU VRAM tiers.
- Memory note `project-initial-notes-2026-models-look-fake-but-arent` — post-cutoff Qwen names look fabricated from a Jan-2026 vantage but are usually real; verify each against a first-party source and flag secondary-only figures.

## Subtopics targeted (user-supplied, in order)

1. Qwen3.8 release and lineage
2. Qwen3.8 model sizes / variants and architecture (dense vs MoE, active params, context)
3. Qwen3.8 coding / agentic benchmarks
4. Qwen3.8 on consumer GPUs (VRAM fit at common quants, tokens/sec, which variant for 16 / 24 / 32 GB)
5. Qwen3.8 licensing and availability (Hugging Face, GGUF, Ollama, llama.cpp / vLLM support)
