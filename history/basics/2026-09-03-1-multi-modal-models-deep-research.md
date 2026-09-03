# 2026-09-03 · run 1 · multi-modal-models-deep-research

**Skill:** deep-book-research
**Chapter:** src/basics.md
**Scope:** new section "Multi Modal Models" to be added at the back of the chapter

## Trigger

User request: "do a deep-book-research for 'Multi Modal Models', their differences compared to
text only models, available models and their usage+relevance in the agentic coding space. Use
these findings to add a 'Multi Modal Models' section to the `basics.md` chapter - positioned at
the back - which describes these aspects."

## Seed

No source URL and no chapter-file headers given — subtopic list constructed from the request
itself (an explicit subtopic list derived from the four aspects the user named).

## Subtopic list (research order)

1. What multimodal models are (definition, modalities, "any-to-any" vs vision-language)
2. Architecture vs text-only models (vision/audio encoders, projectors/connectors, cross-attention
   vs early-fusion token merging, image → token conversion, resolution tiling)
3. Training differences (image-text pair pretraining, interleaved data, instruction tuning,
   alignment; native-multimodal vs bolted-on)
4. Capabilities and limitations (OCR, chart/diagram/document understanding, spatial reasoning,
   UI grounding, hallucination, resolution limits, context-token cost, prompt-injection via images)
5. Available multimodal models (cloud: Claude, GPT, Gemini families; open weights: Qwen-VL,
   Llama, Gemma, Pixtral, InternVL, etc. — modalities, context, pricing where relevant)
6. Usage in the agentic coding space (screenshots / UI understanding, design-to-code, visual
   debugging, browser automation / computer use, diagrams, PDF & document understanding)
7. Relevance / when a multimodal model matters vs a text-only coder (trade-offs, cost)

## Prior art consulted

- `notes/2026-08-29-2-local-models-local-models-quantization-moe/` (raw + summary) — already
  covers the *local* multimodal story (llama.cpp `libmtmd`, two-file `mmproj` model, keep vision
  encoder high-precision, VRAM/context overhead). This pass is scoped to the broader concept and
  the cloud model landscape; the local mechanics stay in `local-models.md`. Passed to the research
  agent as context so the new note extends rather than repeats it.
- `src/basics.md` current content (KV cache, harnesses, prompt caching, context engineering).
