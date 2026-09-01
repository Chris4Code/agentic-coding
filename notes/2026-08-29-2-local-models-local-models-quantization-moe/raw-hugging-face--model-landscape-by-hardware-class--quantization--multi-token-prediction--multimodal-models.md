# Research pass: local-models "Models" section — Hugging Face, model landscape by hardware class, quantization, multi-token prediction, multimodal models, mixture-of-experts

Date: 2026-08-29 · run 2 · chapter `src/local-models.md`
Skill: deep-book-research (manual pass)

Scope note: this pass covers **weight** quantization, not KV-cache quantization. KV-cache quant and Grouped-Query Attention (GQA) were primary-sourced in an earlier pass (Ainslie et al., *GQA*, [arXiv:2305.13245](https://arxiv.org/abs/2305.13245); <1% quality loss at GQA-8) and are only referenced here, not re-derived.

Important sourcing caveat for the whole pass: the assistant's training knowledge ends January 2026. Every model released after that (GLM-5/5.2/5.3, DeepSeek-V4, Kimi K2.6/K2.7/K3, Qwen3.5/Qwen3.6/Qwen3.8, Gemma 4, MiniMax-M2/M2.7, Nemotron Nano 2/3) was verified by web search in August 2026. Where a first-party page (model card, vendor blog, arXiv report) was reachable it is cited as primary; several 2026 releases could only be corroborated through Hugging Face organization listings, Wikipedia, or vendor-adjacent blogs and are flagged as corroborated-secondary.

---

## 1. Hugging Face

**Role.** Hugging Face (HF) is the de-facto distribution hub for open-weight models. For local agentic coding it matters in four ways: the Hub (model hosting + versioning via git-LFS), model cards (license, architecture, benchmark tables, prompt/chat template), the quant ecosystem (community re-uploads in GGUF and other formats), and the CLI/library tooling for pulling weights.

**`safetensors` vs GGUF.**
- `safetensors` is HF's default tensor container: a flat, zero-copy, mmap-friendly replacement for PyTorch pickle `.bin` files. It stores weights at their trained precision (BF16/FP16, sometimes FP8) plus a JSON header. It is what `transformers`, vLLM, SGLang, TGI and the GPU-quant toolchains (AWQ, GPTQ, compressed-tensors) consume. AWQ/GPTQ/FP8 quantized models are still shipped as `safetensors` repos ([vLLM quantization docs](https://docs.vllm.ai/en/latest/features/quantization/), [InsiderLLM: model formats](https://insiderllm.com/guides/model-formats-explained-gguf-gptq-awq-exl2/)).
- GGUF (GGML Universal Format) is llama.cpp's single-file format: weights + metadata + tokenizer + chat template in one file, designed for mmap load and CPU/GPU-split inference. It is the format llama.cpp, Ollama, LM Studio and KoboldCpp consume. Base-model repos are almost never published in GGUF by the original lab; the community converts and quantizes them.

**Quant uploaders.** A handful of accounts re-publish GGUF (and other) quants shortly after each model release:
- **bartowski**, **unsloth**, **mradermacher**, **lmstudio-community**, **ggml-org**, plus specialists like **ubergarm** (i-quants) and **Jackrong**.
- An independent KL-divergence benchmark of 87 GGUF quants from 7 uploaders (Qwen 3.6 27B, Gemma 4 31B) found the quality-per-byte Pareto frontier is split between **unsloth** (Dynamic 2.0/3.0 quants) and **bartowski**, with `ggml-org` and `lmstudio-community` generic quants never on the frontier except at Q8_0 ([localbench GGUF quality benchmark](https://localbench.substack.com/p/qwen-3-6-27b-gguf-quality-benchmark), [Gemma 4 31B benchmark](https://localbench.substack.com/p/gemma-4-31b-gguf-kl-divergence)). Treat this as a single-source community measurement, not a vendor claim.
- Unsloth's "Dynamic" GGUFs (below, §3) use a per-layer, per-model quant recipe plus their own calibration datasets rather than uniform K-quants ([Unsloth Dynamic v2.0](https://unsloth.ai/blog/dynamic-v2), [Dynamic 3.0 docs](https://unsloth.ai/docs/basics/dynamic-3.0-ggufs)).

**Downloading.** The CLI was renamed from `huggingface-cli download` to `hf download` (the `huggingface_hub` package). Typical usage:
- `hf download Qwen/Qwen3-Coder-30B-A3B-Instruct --include "*.safetensors" --local-dir ./model` — filter by glob to avoid pulling every quant in a large repo.
- `hf download bartowski/SomeModel-GGUF SomeModel-Q4_K_M.gguf --local-dir ./models` — pull one GGUF file.
- Auth: `hf auth login` (formerly `huggingface-cli login`) or `--token`. ([HF hub docs / community writeups on `hf download`](https://note.com/zephel01/n/n1c1c8c4f7dde))

**Gated models.** Llama, Gemma, and some others require accepting a license on the model page before the token can fetch them ("gated"). Mistral, Qwen, DeepSeek, Z.ai/GLM, OpenAI gpt-oss are ungated Apache-2.0/MIT and download without acceptance.

**Open LLM Leaderboard — retired.** HF's Open LLM Leaderboard (the automated ARC/HellaSwag/MMLU/TruthfulQA/Winogrande/GSM8K harness, then the v2 "harder" set) was archived in **March 2025**; the maintainers said static multiple-choice benchmarks had saturated and were pushing the field to overfit ([retirement thread](https://huggingface.co/spaces/open-llm-leaderboard/open_llm_leaderboard/discussions/1135)). No single official successor. What people track now:
- **LMArena** (formerly LMSYS Chatbot Arena) — human pairwise-preference Elo ([lmarena.ai](https://lmarena.ai)).
- **Artificial Analysis** — an aggregate "Intelligence Index" plus measured throughput/latency/price per hosted endpoint ([artificialanalysis.ai](https://artificialanalysis.ai)).
- Task-specific: **SWE-bench Verified** / **SWE-bench Pro** and **Terminal-Bench** for agentic coding; **Aider polyglot** for edit-format reliability; **GPQA Diamond**, **AIME** for reasoning.
- HF still hosts leaderboard Spaces (e.g. the Artificial Analysis performance Space), but no longer runs a flagship one itself.

**Ollama registry vs pulling GGUF from HF.** Ollama has its own registry (`ollama run qwen3-coder:30b`) with curated, pre-templated models. It can also pull any GGUF repo on HF directly: `ollama run hf.co/{user}/{repo}` (or `:{quant}` to pick a specific file; default is Q4_K_M if present, otherwise a "reasonable" quant in the repo) ([HF hub Ollama docs](https://huggingface.co/docs/hub/ollama)). Conversely, HF model pages have a "Use this model → Ollama" widget. Practical differences: the Ollama registry lags new releases by days–weeks and sometimes ships a suboptimal quant or a wrong chat template; pulling `hf.co/unsloth/...` or `hf.co/bartowski/...` gets the fix faster but you manage the `Modelfile`/template yourself.

**Sourcing:** primary-sourced (HF docs, the retirement thread, vLLM/exllama format docs). The uploader quality ranking is weakly-sourced (one community benchmark).

---

## 2. Model landscape by hardware class

All sizes below are the model's own parameter counts; on-disk/VRAM footprint at a given quant is derived in §3. "Active params" = params actually multiplied per token for a Mixture-of-Experts (MoE) model (see §6). SWE-bench Verified ("SWE-V") and Terminal-Bench ("TB") numbers are quoted **only where a first-party or well-corroborated source gives them**; scaffold matters a lot for agentic scores, so treat cross-model comparisons loosely.

### Usage scenarios (why size class matters)
- **Inline autocomplete / fill-in-the-middle (FIM):** needs <1s latency, runs constantly. 1B–14B dense or ~3B-active MoE. Base or `-Coder` models with an FIM token format (Qwen2.5-Coder, Codestral, older DeepSeek-Coder).
- **Chat / "explain & write a block" assistant:** 14B–32B dense or 30B-class MoE is the comfortable floor for reliable multi-file reasoning.
- **Autonomous agent (tool calls, multi-file edits, long loops):** wants a model explicitly post-trained for agentic tool use — Qwen3-Coder, Devstral, GLM-4.5/4.6+, gpt-oss, MiniMax-M2, DeepSeek-V3.x/V4. Below ~30B active-or-dense, agent loops start to drift/stall on real repos.

### ~8–16 GB VRAM (laptop dGPU, RTX 4060/4070, Arc A770, 8–16 GB Macs)
- **Qwen2.5-Coder-7B / 14B-Instruct** — dense, 128K context, Apache 2.0, 92 languages, FIM support. The 14B is ~85–90% of the 32B's coding ability per Qwen's family blog. 32B scores **69.6% SWE-V** matching Claude 3.5 Sonnet at release; 7B/14B lower (Qwen does not headline a 14B SWE-V number) ([Qwen2.5-Coder family blog](https://qwenlm.github.io/blog/qwen2.5-coder-family/), [tech report arXiv:2409.12186](https://arxiv.org/abs/2409.12186)).
- **Qwen3-8B**, **Qwen3.5-9B / 4B** (Qwen3.5 dense small models, Feb–Mar 2026) — general models with strong tool use; corroborated-secondary (Qwen wiki / Alibaba Cloud posts).
- **Gemma 3 12B** — multimodal (vision), 128K context, 140+ languages; Gemma license (permissive but not OSI). **Gemma 4 E4B / 12B** (Apr 2026) are the current-gen equivalents ([Gemma 4 model card](https://ai.google.dev/gemma/docs/core/model_card_4)).
- **Devstral Small 1.1 (`devstral-small-2507`)** — 24B dense, based on Mistral-Small-3.1, 128K context, Apache 2.0, built specifically for coding agents (codebase exploration, multi-file edits under the OpenHands scaffold). **53.6% SWE-V**, beating much larger models on the same scaffold ([Mistral Devstral 2507](https://mistral.ai/news/devstral-2507/)). Fits 16 GB only at ~Q4 with short context; more comfortable at 24 GB.

### 24–32 GB VRAM (RTX 3090 / 4090 24 GB, RTX 5090 32 GB, Radeon 7900 XTX 24 GB, Arc B70 ~24–32 GB)
- **Qwen2.5-Coder-32B-Instruct** — dense, 128K, Apache 2.0, **69.6% SWE-V**. Still a strong local coding baseline; runs at Q4_K_M (~20 GB) on 24 GB with room for ~16–32K context ([Qwen2.5-Coder blog](https://qwenlm.github.io/blog/qwen2.5-coder-family/)).
- **Qwen3-Coder-30B-A3B-Instruct** (released 2025-07-31) — MoE, **30.5B total / ~3.3B active**, 128 experts / 8 active, 262K native context (1M with YaRN), Apache 2.0. **51.6% SWE-V** per the model card's reproduction. Its ~3B active path makes it fast even when partly offloaded ([HF card](https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct)).
- **gpt-oss-20b** (OpenAI, Aug 2025, Apache 2.0) — MoE, **21B total / 3.6B active**, 128K context, ships natively in **MXFP4** so it loads in ~16 GB; configurable reasoning effort, tool use, CoT ([OpenAI: Introducing gpt-oss](https://openai.com/index/introducing-gpt-oss/), [HF card](https://huggingface.co/openai/gpt-oss-20b)).
- **Devstral Small** (24B, see above) at Q5–Q6.
- **GLM-4-9B / GLM-4-32B (0414)** and the vision **GLM-4.1V-9B-Thinking** — older Z.ai dense models, still used for their size; MIT.
- Gemma 4 **26B-A4B** MoE (25.2B total / ~3.8B active, 128 experts/8 active, multimodal, 256K context) — fits this tier at Q4–Q5 and runs like a ~4B model ([Gemma 4 guide](https://ai.google.dev/gemma/docs/core)).

### 64–128 GB unified memory (Mac Studio/Pro, AMD Ryzen AI Max "Strix Halo" 128 GB, NVIDIA DGX Spark 128 GB)
Unified/shared memory trades bandwidth for capacity (e.g. DGX Spark ~273 GB/s vs RTX 5090 ~1.8 TB/s), which is exactly the regime where MoE wins (§6).
- **gpt-oss-120b** — MoE, **116.8B total / 5.1B active**, 128 experts / top-4, 128K context, MXFP4 → fits in ~80 GB (one H100 or a 96–128 GB unified box). **~62.4% SWE-V** (corroborated-secondary; OpenAI headlines "near-o4-mini") ([HF card](https://huggingface.co/openai/gpt-oss-120b), [Artificial Analysis](https://artificialanalysis.ai/models/gpt-oss-120b)).
- **GLM-4.5-Air** — MoE, **106B total / 12B active**, 128K context, MIT, includes MTP layers. The practical "frontier-ish agentic coder that fits a 128 GB Mac" pick ([GLM-4.5 report arXiv:2508.06471](https://arxiv.org/abs/2508.06471), [Together AI GLM-4.5-Air](https://www.together.ai/models/glm-4-5-air)).
- **Qwen3-Coder-30B-A3B** at Q8 / BF16, or **Qwen3-Next-80B-A3B** ("Qwen3-Coder-Next", 80B total / ~3B active, hybrid Gated-DeltaNet + MoE + MTP, 256K context; Sept 2025) — the 80B fits ~64–96 GB at 4-bit and streams fast because only ~3B params move per token ([Qwen3-Next-80B-A3B-Instruct HF](https://huggingface.co/Qwen/Qwen3-Next-80B-A3B-Instruct)).
- **Llama 3.3 70B-Instruct** — dense, 128K, Llama license. Solid generalist; ~40–45 GB at Q4, slower than the MoEs on unified memory because all 70B params move per token.
- **Qwen3.5-122B-A10B** (Feb 2026) — corroborated-secondary.

### 128 GB+ / multi-GPU / datacenter
The current open "frontier" tier. All are large MoE; you pay RAM/VRAM for the full parameter count but compute for the active slice.
- **DeepSeek-V3 / V3.1 / V3.2-Exp** — MoE, **671B total / 37B active**, 1 shared + 256 routed experts (8 active), MLA attention, MTP training objective, MIT. V3.2-Exp (Sept 2025) added DeepSeek Sparse Attention for cheaper long context ([DeepSeek-V3 report arXiv:2412.19437](https://arxiv.org/abs/2412.19437)).
- **DeepSeek-V4 / V4-Pro** (2026-04-24, MIT) — MoE, **~1.6T total / 49B active**, 1M context via hybrid compressed/sparse attention (~27% of V3.2's per-token FLOPs, ~10% of its KV cache at 1M). **V4-Pro: 80.6% SWE-V** (within ~0.2 pt of Claude Opus 4.6 per vendor-adjacent reporting) ([DeepSeek-V4-Pro HF](https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro), [DeepSeek-V4 report arXiv:2606.19348](https://arxiv.org/abs/2606.19348), corroborated-secondary for the 80.6 figure).
- **Qwen3-Coder-480B-A35B-Instruct** (2025-07) — MoE, **480B total / 35B active**, 160 experts / 8 active, 256K native (1M YaRN), Apache 2.0. Qwen positions it "comparable to Claude Sonnet 4" on agentic coding / SWE-bench Verified; model card lists SWE-bench Pro 38.7 ([Qwen3-Coder blog](https://qwenlm.github.io/blog/qwen3-coder/), [HF card](https://huggingface.co/Qwen/Qwen3-Coder-480B-A35B-Instruct)).
- **GLM-4.6** (2025-09-30, MIT) — MoE, **357B total** (active count unpublished), 200K context. LiveCodeBench v6 82.8. **GLM-4.5** was 355B/32B active ([GLM-4.6 HF](https://huggingface.co/zai-org/GLM-4.6), [MarkTechPost GLM-4.6](https://www.marktechpost.com/2025/09/30/zhipu-ai-releases-glm-4-6-...)).
- **GLM-5 / GLM-5.2 / GLM-5.3** (2026: GLM-5 Feb 11, GLM-5.2 Jun 13, GLM-5.3 Aug 14) — MoE, **~753B total / ~40B active** (HF org listing shows GLM-5 754B, GLM-5.2/5.3 753B; GLM-5.3-Flash 321B), DeepSeek-style sparse attention, up to 1M context, **MIT**. GLM-5.2: **Terminal-Bench 2.1 = 81.0**, SWE-bench Pro 62.1; GLM-5 posted SWE-V 77.8 (no first-party GLM-5.2 SWE-V) ([zai-org HF org](https://huggingface.co/zai-org), [GLM-5 report arXiv:2602.15763](https://arxiv.org/abs/2602.15763), [morphllm GLM-5.2](https://www.morphllm.com/glm-5-2) — the last is corroborated-secondary). The prior chapter notes' "GLM-5.2, 744B/40B, 1M context, MIT, 81.0 Terminal-Bench 2.1" is **substantially correct** (total is ~753B not 744B).
- **Kimi K2** (Moonshot, Jul 2025) — MoE, **~1T total / 32B active**, 384 experts / 8 active, 128K context, Modified MIT — the last fully open-weight Kimi. **Kimi K2.6** (Apr 2026, 256K), **K2.7 Code** (Jun 2026), **K3** (Jul 16 2026, ~2.8T params, 896 experts / 16 active, 1M context) are **release-restricted**: K2.5/K2.6/K2.7 listed as proprietary, K3 under a custom license requiring a contract for companies >$20M revenue ([Kimi (AI) — Wikipedia](https://en.wikipedia.org/wiki/Kimi_(AI))). For a *local* chapter, K2 is the anchor; K2.6+ are effectively API-only.
- **MiniMax-M2** (2025-10, MIT) — MoE, **230B total / 10B active**, ~Terminal-Bench 46.3, **SWE-V 69.4%**, runs on 4×H100; **MiniMax-M2.7** (2026) is the newer open-weight iteration ([MiniMax-M2 GitHub](https://github.com/MiniMax-AI/MiniMax-M2), [MarkTechPost](https://www.marktechpost.com/2025/10/28/minimax-open-sources-minimax-m2-...), [MiniMax-M2 series arXiv:2605.26494](https://arxiv.org/abs/2605.26494)).

### Verification of model names from the prior chapter notes
| Prior note name | Status as of 2026-08 |
|---|---|
| GLM-5.2 (744B/40B, 1M ctx, MIT, TB2.1 81.0) | **Real.** ~753B total; TB2.1 81.0 confirmed; MIT + 1M ctx confirmed. |
| GLM-5.3 "OX Alpha" | GLM-5.3 **real** (Aug 14 2026); codename "OX Alpha" **unverified**. |
| Kimi K2.6 / K2.7 Code | **Real** releases but **proprietary / not open-weight**; "71.6% multi-attempt agentic" figure unverified. |
| Kimi K3 | **Real** (Jul 2026, ~2.8T); custom restrictive license. |
| DeepSeek V4 Pro (1.6T MoE, 49B active, 80.6% SWE-V) | **Real** (Apr 24 2026, MIT); all three figures corroborated. |
| MiniMax M3 (1M ctx, image+video) | **Not found.** Real line is MiniMax-M2 (Oct 2025) and M2.7 (2026); no "M3" located. Treat as not-yet-released / mislabeled. |
| Qwen3.6 | **Real** (Apr 2026): Qwen3.6-Plus (API), Qwen3.6-35B-A3B (open). |
| Qwen3-Coder-30B / Qwen3-Coder-30B-A3B | **Real** (Jul 31 2025), Apache 2.0. |
| Qwen3-Coder-Next (3B active / 80B total) | **Real** — Qwen3-Next-80B-A3B architecture (Sept 2025). |
| Gemma 4 26B MoE | **Real** — Gemma 4 26B-A4B (Apr 2 2026), 25.2B/3.8B active. |
| nemotron-3-nano_30b | **Not confirmed.** Real line is NVIDIA Nemotron Nano 2 (`Nemotron-Nano-9B-v2`, hybrid Mamba-Transformer, Aug 2025, [arXiv:2508.14444](https://arxiv.org/abs/2508.14444)); no 30B "Nano 3" located. |
| "Inkling" | **Unverified**, no matching model found. |
| Qwen3.6-27B-MTP (from a Reddit link) | Plausible — Qwen3.5-27B / Qwen3.6-generation dense models with MTP heads exist; specific "27B-MTP" GGUF unverified. |

**Sourcing:** mixed. Primary for Qwen2.5-Coder, Qwen3-Coder, gpt-oss, Devstral, GLM-4.5/4.6, DeepSeek-V3, Kimi K2, MiniMax-M2, Gemma 4 (model cards, vendor blogs, arXiv). Corroborated-secondary for GLM-5.x specifics, DeepSeek-V4 figures, Kimi K2.6+/K3, Qwen3.5/3.6/3.8, MiniMax-M2.7 (HF org listings, Wikipedia, vendor-adjacent blogs; first-party `docs.z.ai` was unreachable at write time).

---

## 3. Quantization

### The idea
Weight quantization stores each parameter in fewer bits than the trained precision (BF16 = 16 bits). Inference reads the compressed weight, dequantizes a small block back to FP16/BF16 on the fly, and does the matmul. It cuts memory roughly linearly with bits, and — because local inference is almost always **memory-bandwidth bound**, not compute bound — it usually *speeds up* token generation too.

### The memory formula
```
weights_bytes ≈ params × bits_per_weight / 8
total ≈ weights_bytes + KV_cache + activation/compute buffers + runtime overhead
```
KV cache scales with context length, layers, KV heads and KV-cache precision (see the GQA/KV-quant pass). Compute buffers are typically a few hundred MB to ~2 GB. Practical rule of thumb from the local community: leave **~10–20% / a few GB** of headroom over the raw weight size for a usable context window; on a 32 GB machine that means capping context around 8K–32K for a ~20 GB model (weakly-sourced — community guidance, e.g. Microcenter/PromptQuorum writeups, not a spec).

**Worked example — Qwen2.5-Coder-32B (32.5B params):**
- Q4_K_M (~4.85 bpw effective): 32.5e9 × 4.85 / 8 ≈ **19.7 GB** (published GGUF ≈ 19.85 GB). Fits a 24 GB GPU with ~3 GB for context.
- Q5_K_M (~5.5 bpw): ≈ **22.3 GB** → needs a 24 GB card bare, or 32 GB comfortably. Prior notes' "23–25 GB" is right for the 32B-class incl. overhead.
- Q8_0 (~8.5 bpw): ≈ **34.5 GB** → two GPUs or a unified-memory box.
- 14B at Q8_0: 14e9 × 8.5 / 8 ≈ **14.9 GB** (prior notes' "~15 GB" ✓); at Q6_K ≈ 11.4 GB.

### GGUF quant families (llama.cpp)
- **Legacy** `Q4_0`, `Q4_1`, `Q5_0`, `Q8_0` — uniform per-block scale (+ optional min). `Q8_0` is still the standard "almost lossless" reference.
- **K-quants** (PR [#1684](https://github.com/ggml-org/llama.cpp/pull/1684), ikawrakow, mid-2023) — `Q2_K … Q6_K` with `_S`/`_M`/`_L` mixes: a super-block structure that spends *more* bits on the tensors that matter (attention `wv`, FFN `w2`, and always 6-bit for the output/embedding). Nominal bpw: Q2_K 2.5625, Q3_K 3.4375, Q4_K 4.5, Q5_K 5.5, Q6_K 6.5625 (the `_M` mixes run a bit higher). The PR's LLaMA-7B perplexity table is the origin of the "6-bit is within ~0.1% of FP16, 4-bit costs a fraction of a percent, 2-bit is a real hit" consensus (Q6_K ≈ +0.07%, Q4_K_M ≈ +0.5–1%, Q2_K ≈ +15% ppl on 7B; the gap shrinks as models get larger).
- **i-quants** `IQ1_* … IQ4_XS` (ikawrakow, 2024) — codebook / lattice quantization for very low bitrates (IQ2_XXS ≈ 2.06 bpw, IQ3_XXS ≈ 3.25 bpw). Better quality-per-byte than K-quants at ≤3 bpw **but only with an importance matrix** (below); shipped blind they degrade badly ([llama.cpp quantize README](https://github.com/ggml-org/llama.cpp/blob/master/tools/quantize/README.md), [kaitchup: K-quants vs i-quants](https://kaitchup.substack.com/p/choosing-a-gguf-model-k-quants-i)).
- **imatrix (importance-matrix) quants** — a calibration pass runs a text corpus through the model and records per-channel activation magnitudes; the quantizer then protects high-impact weights. Now standard for bartowski/unsloth K- and i-quants. Calibration data choice has a small but measurable effect; Wikipedia-only calibration can *overfit* perplexity ([Unsloth Dynamic 2.0 docs](https://unsloth.ai/docs/basics/unsloth-dynamic-2.0-ggufs)).
- **Unsloth "Dynamic" 2.0 / 3.0** — per-layer, per-model quant type selection (the recipe for Gemma differs from Llama differs from a MoE) plus Unsloth's own calibration sets; benchmarked by KL-divergence and 5-shot MMLU against the BF16 model, reported to beat uniform imatrix quants and even some QAT quants at equal size ([Unsloth Dynamic v2.0](https://unsloth.ai/blog/dynamic-v2)). The prior notes' "2-bit GLM retains ~82% accuracy (UD-IQ2_M)" reflects this line of claims but the specific 82% figure is **weakly-sourced** (vendor blog, model-dependent).

### GPU-native formats (safetensors)
- **GPTQ** — layer-by-layer error-minimizing INT4/INT3 using second-order (Hessian) info. Mature, widely supported.
- **AWQ** (Activation-aware Weight Quantization) — protects the ~1% most salient weight channels (chosen by activation scale) and quantizes the rest to INT4. De-facto standard for 4-bit GPU serving; consumed by vLLM, SGLang, TGI ([vLLM quantization docs](https://docs.vllm.ai/en/latest/features/quantization/)).
- **EXL2 / EXL3** (ExLlamaV2/V3, NVIDIA-only) — mixed-bitrate, calibration-based; models are specified by average bpw (e.g. 4.5 bpw). **EXL3** is built on the QTIP trellis-quantization method: near-FP16 at 6–8 bpw, competitive down to ~3 bpw, and keeps the original tensor layout ([exllamav3 EXL3 doc](https://github.com/turboderp-org/exllamav3/blob/master/doc/exl3.md)).
- **bitsandbytes NF4 / FP4** — from the **QLoRA** paper (Dettmers et al., [arXiv:2305.14314](https://arxiv.org/abs/2305.14314)). NF4 = "4-bit NormalFloat", an information-theoretically optimal 4-bit datatype for the (roughly Gaussian) weight distribution, plus double-quantization of the scales. QLoRA showed a 65B model fine-tunes on one 48 GB GPU with NF4 base weights at ~no loss vs 16-bit. Mostly used for QLoRA fine-tuning and quick `transformers` loads, not throughput serving.
- **FP8** (E4M3/E5M2) — native on NVIDIA Hopper/Blackwell; "nearly indistinguishable from BF16" for inference, the default for high-end serving. Some labs (DeepSeek) even *train* in FP8.
- **FP4 / MXFP4** — 4-bit float with a shared micro-scale per block; native tensor-core support on Blackwell. **gpt-oss ships in MXFP4** for the MoE expert weights, which is why 120B fits in 80 GB and 20B in 16 GB out of the box ([OpenAI gpt-oss](https://openai.com/index/introducing-gpt-oss/)).

### Quality impact — the consensus
- perplexity and **KL-divergence vs the FP16 model** are the standard proxies; KL-divergence is now preferred (captures distribution shift, not just top-1).
- **≥4-bit (with a good imatrix / AWQ / decent K-quant mix): near-lossless** for most tasks — sub-1% perplexity increase, small KL divergence.
- **~3-bit: noticeable but often usable**, especially for large models.
- **<3-bit: degrades fast** on dense models; big MoE models tolerate 2–2.5-bit better (more redundancy).
- **Coding is quant-sensitive**: exact-syntax / long-range-consistency tasks lose more than chat. Community guidance is to stay at Q5_K_M / 5+ bpw for a *coding* model if the VRAM allows, and prefer a smaller model at higher precision over a bigger model crushed to 2-bit. (Corroborated-secondary: multiple community quant comparisons, e.g. [arXiv:2601.14277 "Which Quantization Should I Use?"](https://arxiv.org/html/2601.14277v1), localbench, matt-c1/llama-3-quant-comparison.)

### Which engine takes which format
| Engine | Formats |
|---|---|
| llama.cpp / Ollama / LM Studio (llama.cpp backend) / KoboldCpp | **GGUF** only (K-quants, i-quants, legacy, imatrix) |
| vLLM | safetensors BF16/FP16, **AWQ, GPTQ, FP8, INT8/INT4 (compressed-tensors), bitsandbytes**, GGUF (experimental/slow) |
| SGLang | similar to vLLM (AWQ/GPTQ/FP8), + KTransformers CPU kernels for MoE offload |
| ExLlamaV2 / V3 (TabbyAPI) | **EXL2 / EXL3** (NVIDIA only) |
| LM Studio (MLX backend, Apple) | MLX-quantized weights (4/5/6/8-bit) |
| `transformers` | bitsandbytes NF4/INT8, AWQ, GPTQ, native FP8 |

The prior notes' claim that "llama.cpp extreme quantization uses ~35% less VRAM than unquantized" is **misleading** — 4-bit vs FP16 is closer to ~65–70% less; the 35% figure appears to come from a Red-Hat comparison blog and does not match the arithmetic.

**Sourcing:** primary-sourced (k-quants PR #1684, llama.cpp quantize README, QLoRA paper, vLLM docs, exllamav3 doc, OpenAI gpt-oss post). Quality-curve specifics and the "coding is sensitive" claim are corroborated-secondary. Unsloth "82% at 2-bit" and the "35% less VRAM" claim are weakly-sourced / flagged wrong.

---

## 4. Multi-Token Prediction (MTP)

**What it is.** Instead of a single head predicting token *t+1*, the model has extra lightweight prediction modules (a shared embedding + a small transformer block + an output head, one per extra position) that predict *t+2*, *t+3*, … in the same forward pass.

**Two distinct uses:**
1. **Training signal.** Predicting several future tokens densifies the loss and forces longer-range planning in the representations. DeepSeek-V3 used a single-depth MTP objective during pre-training and reports it improves benchmark scores even when the MTP heads are *discarded* at inference ([DeepSeek-V3 report, arXiv:2412.19437](https://arxiv.org/abs/2412.19437), §2.2). Qwen3-Next and GLM-4.5-Air/GLM-5.x also include MTP layers ([Qwen3-Next HF](https://huggingface.co/Qwen/Qwen3-Next-80B-A3B-Instruct)).
2. **Inference-time self-speculative decoding.** Keep the MTP head at inference: it cheaply proposes the next *k* tokens, the main model verifies them in one batched forward pass, and accepted tokens are emitted for free. Unlike classic speculative decoding there is **no separate draft model to load** — the draft path is a few hundred MB of extra heads inside the same model.

**Relationship to other speculative methods.** MTP is one point in the speculative-decoding family:
- **Draft model** (classic): a small separate model drafts, big model verifies. llama.cpp `--model-draft` / vLLM `speculative_config`.
- **Medusa**: multiple decoding heads on a frozen backbone, tree-attention verification.
- **EAGLE / EAGLE-2/3**: draft at the *feature* (hidden-state) level, higher acceptance than token-level drafting.
- **Lookahead decoding**: n-gram Jacobi iteration, no draft model, no extra training.
MTP heads that were trained *with* the base model behave like a built-in EAGLE-style drafter.

**Observed speedups.**
- DeepSeek-V3: **~1.8× tokens/sec** with an **80–90% acceptance rate for the 2nd token** ([arXiv:2412.19437](https://arxiv.org/abs/2412.19437)).
- SGLang implemented DeepSeek-V3 MTP; AMD/ROCm and SGLang tutorials reproduce ~1.8–2× on server GPUs.
- llama.cpp added MTP-head support in **PR [#22673](https://github.com/ggml-org/llama.cpp/pull/22673)** (merged ~May 2026). Community benchmarks report ~75% acceptance with 3 draft tokens and >2× in the best case; a frequently-cited figure is **Qwen3.6-27B on an RTX 3090 going 38 → 65 tok/s (~1.7×)** ([DataCamp MTP + llama.cpp tutorial](https://www.datacamp.com/tutorial/multi-token-prediction-llama-cpp), corroborated-secondary via cloudmagazin/startupfortune writeups).

**Engine support (Aug 2026):** vLLM and SGLang have had DeepSeek-V3-style MTP for months; llama.cpp is newer (PR #22673) and still maturing. Only models that were **pre-trained with MTP heads** benefit: DeepSeek-V3/R1/V3.2/V4, Qwen3-Next / Qwen3.5+ / Qwen3.6 (incl. A3B MoE), GLM-4.5-Air / GLM-5.x, Gemma 4 26B-A4B. Llama 3, Mistral, older Gemma have no MTP head.

**Sourcing:** primary for the DeepSeek-V3 mechanism + numbers and the llama.cpp PR. The llama.cpp real-world speed figures and the per-model support list are **corroborated-secondary** (community tutorials/blogs) — this subtopic is moderately thin on independent primary measurement outside DeepSeek's own report.

---

## 5. Multimodal models

**llama.cpp.** Vision support was rewritten from the old `llava.cpp` / `clip.cpp` path into **`libmtmd`** ("multimodal", covers image *and* audio), exposed through a unified CLI and the server ([llama.cpp multimodal docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal.md), [tools/mtmd README](https://github.com/ggml-org/llama.cpp/blob/master/tools/mtmd/README.md), [Simon Willison: trying llama.cpp vision](https://simonwillison.net/2025/May/10/llama-cpp-vision/)). You load two files: the quantized language model GGUF **plus an `mmproj-*.gguf`** (the vision encoder + projector). Supported architectures include LLaVA, **Qwen2-VL / Qwen2.5-VL / Qwen3-VL**, **Gemma 3 / Gemma 4** vision, **MiniCPM-V**, **SmolVLM**, and audio models (Ultravox). Llama 3.2 Vision support landed later and via the same path.

**Other runners:**
- **LM Studio** — on Apple Silicon uses **`mlx-vlm`** (part of its unified MLX engine) for native VLM support; elsewhere it uses llama.cpp + `mmproj`.
- **Ollama** — multimodal via its own engine/llama.cpp; `ollama run gemma3` etc. accept image paths / base64.
- **vLLM / SGLang** — full VLM serving for Qwen-VL, etc., but heavier.

**VRAM overhead of the vision encoder.** The `mmproj` file itself is small (a few hundred MB to ~1.3 GB at FP16 for a large ViT), but:
- the vision encoder is **quantization-sensitive** — keep it FP16 or 8-bit; 4-bit vision encoders visibly lose comprehension.
- image processing spikes activation memory: llama.cpp allocates ~2 GB of compute buffers for vision, and each image expands into hundreds–thousands of context tokens (Gemma 4 uses a *variable* visual budget of 70–1120 tokens/image).
- Net effect on a 24 GB card: one community measurement showed a 1.3 GB `mmproj` cutting the usable context ceiling from ~36K to ~20K tokens on a 31B model ([@analogalok / llama.cpp stack thread](https://x.com/analogalok/status/2079212804809363681), [InsiderLLM: local vision models](https://insiderllm.com/guides/vision-models-locally/)). Treat the exact numbers as single-source anecdote.

**Relevance to agentic coding.** A VLM lets a coding agent read screenshots of a running UI, design mockups / Figma exports, architecture diagrams, chart/plot output, and rendered error states — closing the loop on "does the frontend actually look right". Qwen2.5-VL and Gemma 3/4 are the common local choices; for pure code work a text-only coder is still preferred (the vision tower costs VRAM and context you'd rather spend on the repo).

**Sourcing:** primary for llama.cpp `libmtmd` scope and the model list (llama.cpp docs, Simon Willison). VRAM-overhead numbers are **weakly-sourced** (single community measurements). Agentic-coding relevance is analysis, not a cited claim.

---

## 6. Mixture-of-Experts (MoE) models

**Architecture.** In an MoE transformer, each FFN block is replaced by *N* parallel expert FFNs plus a small **router** (gating network). Per token, the router picks the **top-k** experts (k ≪ N), runs only those, and combines their outputs weighted by the gate. Attention layers stay dense (shared across all tokens).
- **Mixtral 8×7B** ([arXiv:2401.04088](https://arxiv.org/abs/2401.04088)): 8 experts, top-2 → 47B total params, ~13B active per token. Established the modern sparse-MoE-LLM template.
- **DeepSeekMoE** ([arXiv:2401.06066](https://arxiv.org/abs/2401.06066)): two refinements now used almost everywhere — **fine-grained expert segmentation** (many small experts instead of a few big ones, for more specialization) and **shared-expert isolation** (1–2 always-on experts for common knowledge, so routed experts don't waste capacity duplicating it). DeepSeek-V3 = 1 shared + 256 routed, 8 active.

**The local-inference implication (the key point).**
> You pay memory for **all** parameters, but compute (and, more importantly, memory-bandwidth traffic) for only the **active** ones.

Local decoding is memory-bandwidth bound: each generated token requires streaming the active weights from memory through the compute units. So decode speed scales roughly with **active** parameter bytes, while the model only *fits* if **total** parameter bytes ≤ your RAM/VRAM.

Consequences:
- **MoE shines on large, slow memory** — Apple unified memory, Ryzen AI Max / Strix Halo, DGX Spark, or plain CPU + lots of DDR5. A 235B-total / 22B-active model on a 128 GB Mac streams at roughly the speed of a 22B dense model but has the knowledge of something far bigger.
- **Contrast:** Qwen3-Coder-30B-A3B (~3.3B active) vs a dense 30B — same footprint (~19 GB at Q4), but the MoE decodes several times faster because ~10× fewer weight bytes move per token. The tradeoff is that a 3B-active MoE is not *as* capable as a well-trained 30B dense model at equal total size; MoE trades peak quality-per-parameter for quality-per-FLOP.
- On a **bandwidth-rich single GPU** (RTX 4090/5090) the advantage narrows — a dense model that fits entirely in fast VRAM is already fast; MoE mainly helps there by letting a *bigger* model fit.

**Expert offloading (fit a model bigger than your VRAM).**
- **llama.cpp `--n-cpu-moe N`** — keeps attention, KV cache, router, shared experts and norms on the GPU; pushes the routed-expert FFN weights of the first *N* layers to CPU RAM. Because experts fire rarely and are the bulk of the parameters, this is far better than generic layer offload for MoE ([`--n-cpu-moe` explainer](https://aliteq.com/n-cpu-moe-llama-cpp-what-it-actually-does), [big-MoE offload writeup](https://medium.com/@david.sanftenberg/gpu-poor-...)).
- **llama.cpp `--override-tensor` / `-ot`** — regex → device assignment, e.g. `-ot '\.ffn_.*_exps\.=CPU'` sends all expert FFN tensors to CPU; finer control for multi-GPU + CPU splits.
- **KTransformers** (Tsinghua MADSys, SOSP'25) — a hybrid engine that runs DeepSeek-V3/R1-class 671B MoE on **a single 24 GB GPU + system RAM**: attention/shared experts/KV on GPU, routed experts on CPU with AMX-optimized kernels and async CPU↔GPU scheduling. Reports 4.6–19.7× prefill and 1.25–4.1× decode speedups vs prior offload systems; now also integrated as CPU kernels into SGLang ([KTransformers, SOSP'25](https://dl.acm.org/doi/10.1145/3731569.3764843), [LMSYS: KTransformers in SGLang](https://www.lmsys.org/blog/2025-10-22-KTransformers/)).
- **ik_llama.cpp** — a llama.cpp fork with additional hybrid CPU/GPU MoE optimizations and quant types, popular for running big MoEs on workstation hardware.

**Real throughput contrasts (community, labeled as such).** A prior-notes link reports an Intel Arc B70 running "Qwen3.6-27B-MTP" at ~24–28 tok/s vs "Qwen3.6-35B-A3B" (MoE, ~3B active) at ~60–70 tok/s — same machine, the ~3B-active MoE roughly 2.5× faster than the 27B dense despite more total parameters ([r/LocalLLM thread](https://www.reddit.com/r/LocalLLM/comments/1u35s38/)). Single-source anecdote, but it's the pattern the architecture predicts.

**Sourcing:** primary for the architecture (Mixtral, DeepSeekMoE papers, DeepSeek-V3 report) and KTransformers (SOSP'25 paper). llama.cpp offload flags are corroborated-secondary (llama.cpp discussions + explainer blogs). Throughput contrasts are weakly-sourced community anecdotes, explicitly labeled.

---

## Deduplicated source list

**Primary — papers / reports (arXiv):**
1. Ainslie et al., *GQA: Training Generalized Multi-Query Transformer* — arXiv:2305.13245 (referenced only)
2. Dettmers et al., *QLoRA: Efficient Finetuning of Quantized LLMs* (NF4) — https://arxiv.org/abs/2305.14314
3. Jiang et al., *Mixtral of Experts* — https://arxiv.org/abs/2401.04088
4. Dai et al., *DeepSeekMoE* — https://arxiv.org/abs/2401.06066
5. DeepSeek-AI, *DeepSeek-V3 Technical Report* (MTP, MLA, MoE) — https://arxiv.org/abs/2412.19437
6. Qwen team, *Qwen2.5-Coder Technical Report* — https://arxiv.org/abs/2409.12186
7. Z.ai, *GLM-4.5: Agentic, Reasoning, and Coding (ARC) Foundation Models* — https://arxiv.org/abs/2508.06471
8. Z.ai, *GLM-5: from Vibe Coding to Agentic Engineering* — https://arxiv.org/abs/2602.15763
9. DeepSeek-AI, *DeepSeek-V4: Towards Highly Efficient Million-Token Context Intelligence* — https://arxiv.org/abs/2606.19348
10. MiniMax, *The MiniMax-M2 Series* — https://arxiv.org/abs/2605.26494
11. NVIDIA, *Nemotron Nano 2: Hybrid Mamba-Transformer Reasoning Model* — https://arxiv.org/abs/2508.14444
12. Chen et al., *KTransformers: CPU/GPU Hybrid Inference for MoE* — SOSP'25, https://dl.acm.org/doi/10.1145/3731569.3764843
13. *Which Quantization Should I Use? A Unified Evaluation of llama.cpp Quantization* — https://arxiv.org/html/2601.14277v1

**Primary — official model cards / vendor blogs / repos:**
14. OpenAI, *Introducing gpt-oss* — https://openai.com/index/introducing-gpt-oss/ ; gpt-oss-120b card — https://huggingface.co/openai/gpt-oss-120b ; gpt-oss-20b card — https://huggingface.co/openai/gpt-oss-20b
15. Qwen, *Qwen3-Coder: Agentic Coding in the World* — https://qwenlm.github.io/blog/qwen3-coder/
16. Qwen, *Qwen2.5-Coder Series* — https://qwenlm.github.io/blog/qwen2.5-coder-family/
17. Qwen3-Coder-480B-A35B-Instruct card — https://huggingface.co/Qwen/Qwen3-Coder-480B-A35B-Instruct
18. Qwen3-Coder-30B-A3B-Instruct card — https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct
19. Qwen3-Next-80B-A3B-Instruct card — https://huggingface.co/Qwen/Qwen3-Next-80B-A3B-Instruct
20. Mistral AI, *Upgrading agentic coding with the new Devstral models* — https://mistral.ai/news/devstral-2507/ ; Devstral-Small-2507 card — https://huggingface.co/mistralai/Devstral-Small-2507
21. Z.ai GLM-4.6 card — https://huggingface.co/zai-org/GLM-4.6 ; zai-org HF organization — https://huggingface.co/zai-org
22. DeepSeek-V3 card — https://huggingface.co/deepseek-ai/DeepSeek-V3 ; DeepSeek-V4-Pro card — https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro
23. MiniMax-M2 repo — https://github.com/MiniMax-AI/MiniMax-M2
24. Google, *Gemma 4 model card* — https://ai.google.dev/gemma/docs/core/model_card_4 ; Gemma 4 overview — https://ai.google.dev/gemma/docs/core
25. llama.cpp k-quants PR #1684 — https://github.com/ggml-org/llama.cpp/pull/1684
26. llama.cpp quantize README — https://github.com/ggml-org/llama.cpp/blob/master/tools/quantize/README.md
27. llama.cpp MTP support PR #22673 — https://github.com/ggml-org/llama.cpp/pull/22673
28. llama.cpp speculative decoding docs — https://github.com/ggml-org/llama.cpp/blob/master/docs/speculative.md
29. llama.cpp multimodal docs — https://github.com/ggml-org/llama.cpp/blob/master/docs/multimodal.md ; tools/mtmd README — https://github.com/ggml-org/llama.cpp/blob/master/tools/mtmd/README.md
30. vLLM quantization docs — https://docs.vllm.ai/en/latest/features/quantization/
31. exllamav3 EXL3 doc — https://github.com/turboderp-org/exllamav3/blob/master/doc/exl3.md
32. Unsloth Dynamic v2.0 — https://unsloth.ai/blog/dynamic-v2 ; Dynamic 2.0 docs — https://unsloth.ai/docs/basics/unsloth-dynamic-2.0-ggufs ; Dynamic 3.0 docs — https://unsloth.ai/docs/basics/dynamic-3.0-ggufs
33. Hugging Face Hub — Ollama integration docs — https://huggingface.co/docs/hub/ollama
34. HF Open LLM Leaderboard retirement thread — https://huggingface.co/spaces/open-llm-leaderboard/open_llm_leaderboard/discussions/1135
35. LMSYS, *Accelerating Hybrid Inference in SGLang with KTransformers* — https://www.lmsys.org/blog/2025-10-22-KTransformers/
36. Transformers docs, GLM-4.5/4.6/4.7 MoE — https://huggingface.co/docs/transformers/main/en/model_doc/glm4_moe

**Corroborated-secondary / community (labeled in text):**
37. Kimi (AI) — Wikipedia — https://en.wikipedia.org/wiki/Kimi_(AI)
38. DeepSeek (chatbot) — Wikipedia — https://en.wikipedia.org/wiki/DeepSeek_(chatbot)
39. Qwen — Wikipedia — https://en.wikipedia.org/wiki/Qwen
40. Gemma (language model) — Wikipedia — https://en.wikipedia.org/wiki/Gemma_(language_model)
41. Artificial Analysis — https://artificialanalysis.ai (gpt-oss-120b, GLM-4.5-Air, Qwen3-Coder-30B pages)
42. LMArena — https://lmarena.ai
43. Together AI, GLM-4.5-Air — https://www.together.ai/models/glm-4-5-air
44. MarkTechPost: GLM-4.6 (2025-09-30), MiniMax-M2 (2025-10-28), GLM-5.3 (2026-08-14)
45. morphllm: GLM-5.2 / DeepSeek-V4 overview pages — https://www.morphllm.com/glm-5-2 , https://www.morphllm.com/deepseek-v4
46. localbench GGUF quality benchmarks — https://localbench.substack.com/p/qwen-3-6-27b-gguf-quality-benchmark , https://localbench.substack.com/p/gemma-4-31b-gguf-kl-divergence
47. kaitchup: *Choosing a GGUF Model: K-Quants, I-Quants, Legacy* — https://kaitchup.substack.com/p/choosing-a-gguf-model-k-quants-i
48. DataCamp: *Multi-Token Prediction Tutorial with llama.cpp* — https://www.datacamp.com/tutorial/multi-token-prediction-llama-cpp
49. InsiderLLM: model formats, local vision models — https://insiderllm.com/guides/model-formats-explained-gguf-gptq-awq-exl2/ , https://insiderllm.com/guides/vision-models-locally/
50. Simon Willison: *Trying out llama.cpp's new vision support* — https://simonwillison.net/2025/May/10/llama-cpp-vision/
51. aliteq: *`--n-cpu-moe` explained* — https://aliteq.com/n-cpu-moe-llama-cpp-what-it-actually-does
52. matt-c1/llama-3-quant-comparison — https://github.com/matt-c1/llama-3-quant-comparison
53. r/LocalLLM: Arc B70 Qwen3.6 throughput anecdote — https://www.reddit.com/r/LocalLLM/comments/1u35s38/
54. @analogalok (X): Gemma 4 31B + vision encoder VRAM/context stack — https://x.com/analogalok/status/2079212804809363681
