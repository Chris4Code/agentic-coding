# 2026-08-29 · run 1 · local-inference-engines-and-hardware

**Skill:** deep-book-research
**Chapter:** src/local-models.md
**Scope:** first of a planned 2–3 pass split covering the whole chapter. This pass: local inference engines + all hardware sections.

## Trigger

User asked to run `deep-book-research` for the topics described in `src/local-models.md` — the chapter's section headlines and `CONTENT-KEY-SUBJECTS` HTML comments. Chapter is currently a bare outline (headers + key-subject comments only, no prose). User chose to split the ~19-subtopic chapter into 2–3 sequential research passes; this is pass 1 (hardware-side).

## Input materials

- `src/local-models.md` — chapter outline: headers and `CONTENT-KEY-SUBJECTS` comments used as the subtopic seed.
- `notes/initial-notes/Local Modells - Models, SW and AI-GPUs.md` — prior manual research: inference-engine comparison (vLLM/llama.cpp/Ollama), vendor SW stacks (CUDA/ROCm/SYCL/Vulkan/Metal), consumer/datacenter/workstation GPU lists with VRAM figures, LM Studio backends, OpenRouter/LiteLLM. Contains several possibly-fictional or future product/model names to verify.
- `notes/initial-notes/Local-Models - Best open weights model for coding.md` — prior manual research on open-weights coding models and hardware requirements (mostly relevant to pass 2, noted here for continuity).
- `notes/2026-08-21-1-basics-kv-cache-prompt-caching-fact-check/summary-*.md` — prior art: PagedAttention/vLLM primary-sourced (Kwon et al., SOSP '23), KV-cache memory math, Blackwell FP4/FP8. New pass should extend, not repeat.

## Subtopics targeted (this pass)

1. llama.cpp — architecture, GGUF, hardware ubiquity, concurrency limits
2. Ollama — wrapper over llama.cpp, Go management layer, performance overhead
3. vLLM — PagedAttention, continuous batching, tensor parallelism, VRAM pre-allocation
4. Consumer PC hardware — low cost, availability, performance bottlenecks (memory bandwidth, CPU-only inference)
5. Consumer GPUs & dedicated VRAM — advantage of dedicated VRAM, PSU + workstation-hardware prerequisites
6. NVIDIA + CUDA — advantages/drawbacks, commonly used GPUs and raw prices
7. AMD + ROCm — advantages/drawbacks, commonly used GPUs and raw prices
8. Intel + SYCL — advantages/drawbacks, commonly used GPUs (Arc) and raw prices
9. Vulkan — as a cross-vendor backend vs vendor-specific stacks
10. Apple Metal / MLX — vs vendor-specific stacks
11. AI-Workstations — unified/shared memory machines (DGX Spark, AMD Ryzen AI Max / Strix Halo, Apple Mac Studio), performance vs discrete GPUs
12. Datacenter GPU stacks — advantages/drawbacks vs consumer platforms, commonly used GPUs and raw prices
