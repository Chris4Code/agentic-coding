# 2026-08-29 · run 2 · local-models-quantization-moe

**Skill:** deep-book-research
**Chapter:** src/local-models.md
**Scope:** pass 2 of the chapter split. This pass: the "Models" section — model landscape, quantization, multi-token prediction, multimodal, mixture-of-experts.

## Trigger

Same triggering request as run 1 (`deep-book-research` for the topics described in `src/local-models.md`). User chose to split the chapter into sequential passes; this is pass 2 (model-side).

## Input materials

- `src/local-models.md` — chapter outline: `## Models` section headers and `CONTENT-KEY-SUBJECTS` comments.
- `notes/initial-notes/Local-Models - Best open weights model for coding.md` — prior manual research: open-weights coding model tiers (frontier MoE vs consumer-hardware), quantization memory math (Q4_K_M / Q5_K_M sizing), CPU-only model picks, MoE active-vs-total-parameter behavior, GLM-class local hardware requirements. Contains several possibly-fictional or future model names to verify (e.g. "GLM-5.2", "Kimi K3", "DeepSeek V4 Pro", "Qwen3.6", "MiniMax M3").
- `notes/initial-notes/Local Modells - Models, SW and AI-GPUs.md` — model-per-hardware-class lists.
- `notes/2026-08-21-1-basics-kv-cache-prompt-caching-fact-check/summary-*.md` — prior art on KV-cache quantization and GQA; new pass extends toward weight quantization.

## Subtopics targeted (this pass)

1. Hugging Face — as the model distribution hub; GGUF/safetensors ecosystem
2. Model landscape by hardware class — favourite open-weights models suitable for the chapter's HW system classes (consumer GPU, unified-memory workstation, datacenter) and usage scenarios (autocomplete vs agentic coding)
3. Quantization — GGUF K-quants, AWQ/GPTQ, bits-per-weight, memory math, quality/perplexity tradeoffs, FP8/FP4
4. Multi-token prediction (MTP) — mechanism, relation to speculative decoding, observed speedups
5. Multimodal models — local vision-language model support in llama.cpp/Ollama/LM Studio
6. Mixture-of-Experts models — active vs total parameters, VRAM-vs-speed implications for local serving
