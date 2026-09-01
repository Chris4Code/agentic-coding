# Research pass: local inference engines and hardware

Target chapter: `src/local-models.md` — "Agentic Coding with local models".
Pass scope: **local inference engines and hardware** (12 subtopics below).
Date of research: 2026-08-29. Prices and product availability in this space are moving fast — see the recurring **2026 memory-supply crunch** note, which affects almost every hardware price here.

Confidence tags used per section:
- **primary** — the project's / vendor's own repo, docs, spec sheet, paper, or newsroom post.
- **corroborated-secondary** — consistent across several independent write-ups; not the primary actor's own words.
- **weak** — single source, or a figure that could not be independently confirmed / looks like it may be AI-generated filler.

> Methodology caveat: web search in 2026 for this topic returns a large amount of low-quality, likely AI-generated "2026 guide" content, some of it citing model and product names that do not appear on any vendor page. Where a figure only showed up in that kind of source it is tagged **weak** and called out. Vendor spec pages, GitHub repos, official docs, Phoronix benchmarks and established tech-press outlets (Tom's Hardware, TechSpot, Digital Trends, MacRumors, Phoronix) were preferred.

---

## llama.cpp

**What it is.** A C/C++ implementation for LLM and VLM inference, "minimal setup and state-of-the-art performance on a wide range of hardware - locally and in the cloud", built on top of the **ggml** tensor library. Maintained by the **ggml-org** organisation, founded by **Georgi Gerganov**; ggml itself was started by Gerganov in September 2022. The repo is one of the most-starred ML projects on GitHub (~120k+ stars, 450+ contributors as of mid-2026). ([llama.cpp repo](https://github.com/ggml-org/llama.cpp), [ggml.ai](https://ggml.ai))

**GGML / GGUF.** ggml is a low-level tensor-algebra library in C. **GGUF** ("GGML Universal File") is llama.cpp's single-file model container: it holds weights plus all metadata (tokenizer, prompt template, architecture hyper-parameters, quantization type) so a model is one self-describing file. GGUF supersedes the older GGML file format. GGUF files are **memory-mapped** (`mmap`) at load: pages are demand-loaded by the OS, so start-up is fast and multiple processes can share the same read-only weight pages. ([llama.cpp repo](https://github.com/ggml-org/llama.cpp), [GGUF spec in ggml repo](https://github.com/ggml-org/ggml/blob/master/docs/gguf.md))

**Quantization.** llama.cpp popularised aggressive weight quantization for local use: k-quants and i-quants from ~1.5 bits/weight up to 8 bits, plus full F16/BF16/F32. The common "sweet spot" builds referenced throughout the ecosystem are `Q4_K_M` and `Q5_K_M`. ([llama.cpp repo README](https://github.com/ggml-org/llama.cpp))

**Backends.** The build docs list a very wide backend set:

> "BLAS, BLIS, CANN, CUDA, HIP, Hexagon, IBM zDNN, MUSA, Metal, OpenCL, OpenVINO, RPC, SYCL, VirtGPU, Vulkan, WebGPU, ZenDNN"

Mapping to hardware: **CUDA** (NVIDIA, custom kernels), **HIP/ROCm** (AMD), **Metal** (Apple Silicon), **SYCL** (Intel GPU/iGPU via oneAPI), **Vulkan** (vendor-neutral), **CANN** (Huawei Ascend), **MUSA** (Moore Threads), **OpenCL** (older/embedded GPUs, Adreno), plus optimised CPU paths (AVX2/AVX-512/AMX on x86, NEON/SVE on ARM). ([llama.cpp build.md](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md))

**CPU + GPU hybrid ("layer offload").** The README explicitly advertises "CPU+GPU hybrid inference to partially accelerate models larger than the total VRAM capacity" — `-ngl N` puts the first N transformer layers on the GPU and runs the rest on CPU/RAM. This is the mechanism that lets a 24 GB card run a 70B model slowly instead of not at all. ([llama.cpp repo README](https://github.com/ggml-org/llama.cpp))

**Server mode.** `llama-server` is a single-binary HTTP server with an OpenAI-compatible `/v1/chat/completions` and `/v1/completions` API, a built-in web UI, embeddings and reranking endpoints, and a `/props` / `/slots` introspection API. ([llama.cpp server README](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md))

**Concurrency model and its limits.** `llama-server` handles multiple simultaneous requests by splitting the KV-cache context memory into `--parallel N` fixed "slots"; it also does **continuous batching** (`--cont-batching`, on by default in recent builds) so decode steps for active requests are batched together. But there is **no PagedAttention**: each slot reserves `context_size / N` tokens up front, so raising N shrinks the per-request context, and the engine is tuned for latency at low concurrency rather than aggregate throughput at high concurrency. Independent "N concurrent users" tests consistently show llama.cpp / Ollama latency degrading much faster under load than vLLM. ([llama.cpp server README](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md); [Red Hat Developers, "vLLM or llama.cpp: Choosing the right LLM inference engine"](https://developers.redhat.com/articles/2025/09/30/vllm-or-llamacpp-choosing-right-llm-inference-engine-your-use-case))

**Speculative decoding.** Supported: `llama-server` and `llama-speculative` accept a small **draft model** (`--model-draft`, `--draft-max`, `--draft-min`) that proposes tokens the main model verifies in one batch; the repo also ships draft-free variants (prompt-lookup / n-gram). Community forks add adaptive drafting. Speedups are workload-dependent (largest on predictable/structured output). ([llama.cpp speculative example](https://github.com/ggml-org/llama.cpp/tree/master/examples/speculative), [DeepWiki: Speculative Decoding in llama.cpp](https://deepwiki.com/ggml-org/llama.cpp/8.3-speculative-decoding))

**Sourcing: primary** (repo + official docs), with one corroborated-secondary source for the concurrency-under-load comparison.

---

## Ollama

**What it is / company / licence.** A local-model runner that wraps a low-level engine behind a Docker-like CLI (`ollama pull`, `ollama run`), a local daemon, and a REST API. Written mainly in Go. Developed by **Ollama Inc.**, a Delaware C-corp based in Palo Alto, co-founded by **Jeffrey Morgan** and **Michael Chiang**, Y Combinator–backed; the code is **MIT-licensed**. ([Ollama GitHub + LICENSE](https://github.com/ollama/ollama/blob/main/LICENSE), [Wikipedia: Ollama](https://en.wikipedia.org/wiki/Ollama))

**Relationship to llama.cpp / its own engine.** Ollama started as a thin wrapper that vendored **llama.cpp** and drove it as a subprocess. Since 2025 Ollama ships its **own inference engine** (still built on the **ggml** tensor library, i.e. a partial fork of the lower layer rather than of `llama-server`), which it now uses for newer model architectures (especially multimodal), while continuing to use the llama.cpp-derived path for others. So the accurate 2026 statement is "Ollama runs on ggml, historically via llama.cpp, increasingly via its own ggml-based engine." ([Ollama blog: "A new engine for multimodal models" / "New model scheduling"](https://ollama.com/blog), corroborated-secondary: [Wikipedia: Ollama](https://en.wikipedia.org/wiki/Ollama))

**MLX support.** Ollama added an **MLX** path for Apple Silicon (initial preview mid-2025; promoted in an "Ollama is now powered by MLX on Apple Silicon" blog post in 2026), motivated by MLX being materially faster than the llama.cpp/Metal path on M-series chips. As of this research MLX in Ollama is still described as preview/opt-in and requires larger-memory Macs. ([Ollama blog: MLX](https://ollama.com/blog/mlx)) — note: the fetched post's exact tokens/sec figures could not be verified and some appeared model-specific; treat only the *fact* of MLX adoption as solid. **weak** on the numbers.

**Model registry / Modelfile.** Ollama hosts a model registry (`ollama.com/library`) addressed like a container registry (`ollama pull llama3.1:8b`). A **Modelfile** is a small declarative file (`FROM`, `PARAMETER`, `SYSTEM`, `TEMPLATE`, `ADAPTER` for LoRA) used to derive a customised model. It can also import raw GGUF or safetensors. ([Ollama Modelfile docs](https://github.com/ollama/ollama/blob/main/docs/modelfile.md))

**Memory management.** The daemon estimates VRAM/RAM need, decides GPU/CPU split automatically, and **auto-unloads** an idle model after a timeout (`OLLAMA_KEEP_ALIVE`, default 5 minutes); newer versions do more accurate layer-by-layer VRAM accounting and can hot-load/evict multiple models (`OLLAMA_MAX_LOADED_MODELS`). ([Ollama FAQ / docs](https://github.com/ollama/ollama/blob/main/docs/faq.md))

**API.** Native `/api/generate`, `/api/chat`, `/api/embeddings`, plus an **OpenAI-compatible** `/v1/chat/completions` surface. ([Ollama OpenAI-compatibility docs](https://github.com/ollama/ollama/blob/main/docs/openai.md))

**Performance overhead vs raw llama.cpp.** For a single request the overhead is small (Go orchestration, HTTP hop, model-load bookkeeping); the practical differences are that Ollama picks conservative defaults (context length, GPU-layer count, quant) that a hand-tuned `llama-server` invocation can beat, and Ollama historically lagged upstream llama.cpp on brand-new model support and on some optimisations. **corroborated-secondary** ([Red Hat Developers](https://developers.redhat.com/articles/2026/06/15/llamacpp-vs-vllm-choosing-right-local-llm-inference-engine), [bswen: llama.cpp vs Ollama for local coding](https://docs.bswen.com/blog/2026-03-27-llama-cpp-vs-ollama-local-coding/)).

**Sourcing: primary** for engine/registry/licence/API; **corroborated-secondary** for the overhead framing; **weak** for MLX speed figures.

---

## vLLM

**Origin & PagedAttention.** vLLM came out of UC Berkeley (Sky Computing Lab). Its core idea, **PagedAttention**, stores the KV cache in fixed-size blocks allocated on demand — like OS virtual-memory paging — instead of one contiguous per-request reservation. The primary paper is **Kwon et al., "Efficient Memory Management for Large Language Model Serving with PagedAttention," SOSP '23 ([arXiv:2309.06180](https://arxiv.org/abs/2309.06180))**: existing systems used only ~20–38 % of KV memory for real token state (60–80 % wasted); vLLM raises utilisation to ~96 % (<4 % waste) and improves throughput **2–4×** at matched latency. (This was already primary-sourced elsewhere in the book — `notes/2026-08-21-1-basics-kv-cache-prompt-caching-fact-check/` — so it is not re-derived here.)

**Continuous batching.** vLLM adds/removes requests from the running batch every decode step ("continuous"/"in-flight" batching) rather than waiting for a whole batch to finish, keeping the GPU busy under bursty load. ([vLLM docs](https://docs.vllm.ai/en/latest/))

**Parallelism.** vLLM docs list "**Tensor, pipeline, data, expert, and context parallelism** for distributed inference." Tensor parallelism (`-tp`) shards each layer across GPUs on one node (needs fast interconnect, ideally NVLink); pipeline parallelism (`-pp`) splits layers across GPUs / nodes. Expert parallelism shards MoE experts. ([vLLM docs](https://docs.vllm.ai/en/latest/))

**Prefix caching.** **Automatic prefix caching (APC)** hashes KV blocks so a shared prompt prefix (system prompt, few-shot examples, a long document reused across requests) is computed once and reused. ([vLLM docs: Automatic Prefix Caching](https://docs.vllm.ai/en/latest/features/automatic_prefix_caching.html))

**Quantization support.** Per the docs: "FP8, MXFP8/MXFP4, NVFP4, INT8, INT4, GPTQ/AWQ, GGUF, compressed-tensors, ModelOpt, TorchAO, and more." GGUF loading exists but is explicitly experimental/for convenience, not the fast path — vLLM's fast path is safetensors + AWQ/GPTQ/FP8. ([vLLM docs: Quantization](https://docs.vllm.ai/en/latest/features/quantization/))

**Hardware support.** Docs: "NVIDIA GPUs, AMD GPUs, and x86/ARM/PowerPC CPUs," plus Google TPU, Intel Gaudi, and Apple Silicon (the non-NVIDIA targets vary in maturity; NVIDIA is the reference platform). ([vLLM docs](https://docs.vllm.ai/en/latest/))

**Why it is VRAM-hungry.** vLLM pre-allocates a large KV-cache pool at start-up sized by `--gpu-memory-utilization` (**default 0.9** — 90 % of the card). This is deliberate (bigger pool = more concurrent sequences) but means vLLM will grab almost the whole GPU and OOM easily on 8–16 GB cards, and it does not memory-map or offload to system RAM the way llama.cpp does. ([vLLM docs: conserving memory / engine args](https://docs.vllm.ai/en/latest/configuration/conserving_memory.html))

**When vLLM beats llama.cpp / when it can't be used.**
- **Beats it:** many concurrent requests on a datacenter/workstation NVIDIA (or supported AMD) GPU with the whole model in VRAM — aggregate tokens/sec, tail latency under load, prefix-cache reuse for agents/RAG. Independent load tests put vLLM several times ahead of Ollama/llama.cpp at ~10+ concurrent users. ([Red Hat Developers](https://developers.redhat.com/articles/2025/09/30/vllm-or-llamacpp-choosing-right-llm-inference-engine-your-use-case))
- **Can't / shouldn't be used:** model doesn't fit in VRAM (no CPU-offload story like llama.cpp), Apple Silicon as a daily driver, single-user laptop/desktop where the 90 % pre-allocation and Python/CUDA toolchain are pure overhead, Windows without WSL, exotic quant formats only shipped as GGUF.

**Alternatives (brief).**
- **SGLang** — production engine with **RadixAttention** (prefix-tree KV reuse); benchmarks show it ahead of vLLM on shared-prefix workloads (agents, multi-turn, RAG). Actively developed, NVIDIA + ROCm support. ([SGLang docs](https://docs.sglang.ai/), corroborated-secondary: [Spheron benchmark write-up](https://www.spheron.network/blog/vllm-vs-tensorrt-llm-vs-sglang-benchmarks/))
- **Hugging Face TGI (Text Generation Inference)** — the earlier reference server; reporting in late 2025 says HF put TGI into **maintenance mode** and now points users to vLLM or SGLang for new deployments. **weak** (single-source-ish; verify before quoting a date). ([HF TGI repo](https://github.com/huggingface/text-generation-inference))
- **NVIDIA TensorRT-LLM** — fastest on NVIDIA when you invest in per-model engine compilation; NVIDIA-only, heavier ops burden.

**Sourcing: primary** for vLLM mechanics/config; **primary** (paper) for PagedAttention; **corroborated-secondary** for the head-to-head load claims; **weak** for the TGI-maintenance-mode claim.

---

## Consumer PC hardware (non-GPU angle: CPU + system RAM)

**The bottleneck is memory bandwidth, not FLOPS.** Autoregressive decoding is memory-bound: every generated token requires streaming the entire set of active weights from memory through the compute units once. So tokens/sec ≈ (usable memory bandwidth) ÷ (bytes of active weights per token), until you become compute-bound (rare on CPU) or the batch is large. ([Finbarr Timbers, "How is llama.cpp possible?"](https://finbarr.ca/how-is-llama-cpp-possible/); [dev.to: "The real cost of LLM inference — memory bandwidth, not FLOPs"](https://dev.to/avik12345678/the-real-cost-of-llm-inference-memory-bandwidth-not-flops-3855))

**Concrete bandwidth numbers:**
- Dual-channel DDR5 desktop: DDR5-5600 ≈ 89 GB/s theoretical, DDR5-6000 ≈ 96 GB/s; realistically **~50–90 GB/s** usable. Adding more DIMMs usually *lowers* achievable speed (DDR5 often drops to ~3600–4800 MT/s with 4 sticks). ([dev.to: "DDR5 Speed and LLM Inference"](https://dev.to/maximsaplin/ddr5-speed-and-llm-inference-3cdn))
- Quad-/8-channel workstation/server (Threadripper PRO, Xeon, EPYC): ~200–500+ GB/s — this is why HEDT platforms are the interesting CPU option, not mainstream desktops.
- Contrast: a discrete GPU is ~450 GB/s (entry) to ~1 TB/s (RTX 4090 GDDR6X, ~1008 GB/s) to ~1.8 TB/s (RTX 5090 GDDR7); datacenter HBM is 3–8 TB/s. So a desktop CPU has roughly **10–30× less** memory bandwidth than a good GPU. ([NVIDIA RTX 4090 spec](https://www.nvidia.com/en-us/geforce/graphics-cards/40-series/rtx-4090/), [NVIDIA RTX 5090 spec](https://www.nvidia.com/en-us/geforce/graphics-cards/50-series/rtx-5090/))

**Realistic CPU tokens/sec (Q4_K_M, llama.cpp, mainstream dual-channel DDR5 desktop):**
- 7–8B: roughly **3–10 tok/s** (theoretical ceiling ~15–22 tok/s at 100–150 GB/s; real is lower due to overheads).
- 13–14B: ~2–5 tok/s.
- 30–34B dense: ~1–3 tok/s — generally too slow for interactive agentic use.
- 70B dense: ~1–2 tok/s on the fastest consumer CPUs.
These are **corroborated-secondary** ranges (several independent write-ups converge on them; exact numbers vary with CPU, RAM speed, quant). ([Medium: "llama.cpp: CPU Inference for LLMs on Consumer Hardware"](https://medium.com/@shriomtripathi33/llama-cpp-cpu-inference-for-llms-on-consumer-hardware-3bca99b11d4b); [devinfo.dev: "The Memory Wall"](https://devinfo.dev/d/2026.0049))

**MoE changes the picture for CPU.** A Mixture-of-Experts model only activates a small fraction of its parameters per token (e.g. an "A3B" model activates ~3B of ~30B). Since decode speed tracks *active* bytes, a 30B-A3B MoE at Q4 can run at genuinely interactive speeds (tens of tok/s) on a CPU or an APU that could never run a 30B *dense* model usefully — at the cost of needing enough RAM to hold *all* experts. This is the main reason CPU/APU inference became practical for coding-sized models in 2025–2026. **corroborated-secondary** ([localaimaster: Strix Halo guide](https://localaimaster.com/blog/strix-halo-ai-max-395-guide); mechanism follows directly from the memory-bound analysis above).

**Cost/availability of RAM vs VRAM.** Historically RAM was far cheaper per GB and available in huge capacities (128–512 GB desktop/workstation) vs 8–32 GB VRAM on consumer GPUs. In **2026 a severe DRAM/HBM supply crunch** (driven by AI datacenter demand) pushed DDR5 and GDDR7 prices up sharply and caused visible product changes (see AI-workstation section: DGX Spark MSRP raised, Apple dropped its 512 GB Mac Studio option). RAM is still cheaper per GB than VRAM, but the gap narrowed and both are volatile. **corroborated-secondary** ([Tom's Hardware on RTX PRO 6000 price](https://www.tomshardware.com/pc-components/gpus/nvidia-doubles-rtx-pro-6000-blackwells-msrp-to-a-staggering-usd16-000-96gb-card-started-pre-orders-below-usd8-000-last-year); [Digital Trends: RTX 4090 shortage](https://www.digitaltrends.com/computing/nvidia-rtx-4090-shortage-prices-skyrocket/)).

**Sourcing: corroborated-secondary**, with the underlying bandwidth physics well-established and vendor bandwidth figures primary.

---

## Consumer GPUs & the case for dedicated VRAM

**Why dedicated VRAM matters.** A discrete GPU has its own high-bandwidth memory (GDDR6/6X/7) wired directly to the GPU on a wide bus, not shared with the CPU/OS. Bandwidth is 5–20× a desktop's system RAM (see numbers above), and it isn't contended by other processes. Because decode is memory-bound, **VRAM bandwidth sets the token rate and VRAM capacity sets the maximum model/context that runs at full speed**. Once a model spills out of VRAM into system RAM (llama.cpp layer offload), the offloaded layers run at CPU-RAM speed and overall tok/s collapses toward the CPU numbers above.

**The capacity threshold for coding models.** Rough Q4_K_M working-set (weights + KV + overhead) guidance that recurs across sources:
- 8 GB → ~7–8B models, short context.
- 12 GB → ~13–14B.
- 16 GB → ~14B comfortably, ~30B-class MoE (e.g. 30B-A3B) tightly, 32B dense only with small context.
- **20–24 GB → ~32B dense at usable context; comfortable headroom for 30B-class MoE and long context.** This is the practical "useful local coding model" line.
- 32 GB (RTX 5090) → 32B dense with long context, or a 70B at low quant partly offloaded.
- 48 GB+ → 70B-class at Q4 in VRAM.
**corroborated-secondary** ([Spheron: LLM VRAM requirements](https://www.spheron.network/blog/gpu-memory-requirements-llm/); [promptquorum: local LLM hardware guide](https://www.promptquorum.com/local-llms/local-llm-hardware-guide-2026)). The specific GB-per-model-size numbers are approximate and quant-dependent.

**Practical prerequisites for a desktop GPU build:**
- **Power supply.** A single RTX 4090/5090 draws 450–575 W under load and NVIDIA recommends ~850–1000 W PSUs for a 5090 system; the card uses the **12V-2×6 / 12VHPWR** connector (the one with documented melting incidents when not fully seated). Two big cards → 1300–1600 W PSU and often a 240 V circuit. ([NVIDIA RTX 5090 spec page](https://www.nvidia.com/en-us/geforce/graphics-cards/50-series/rtx-5090/))
- **Physical space & cooling.** Triple-slot, ~304–360 mm cards; two of them need a motherboard with sufficient slot spacing and strong case airflow (or blower / water-cooled variants). Consumer boards rarely fit 3+ air-cooled cards.
- **PCIe lanes.** Mainstream desktop CPUs expose ~20–28 usable PCIe lanes → typically one x16 card plus one x4. Running 2+ GPUs at x8/x8 or better, or 4+ GPUs, needs **HEDT/workstation** platforms (Threadripper/PRO, Xeon-W, EPYC) for the lanes. For llama.cpp/Ollama tensor-split, x4 links are tolerable (little inter-GPU traffic per token); for vLLM tensor parallelism you want x8+ and ideally NVLink.
- **Board/chassis.** Multi-GPU at scale usually means an open-frame/mining-style rig or a 4U server chassis, plus riser cables.
**corroborated-secondary / general hardware knowledge**, PSU and connector facts primary from NVIDIA.

**Sourcing: corroborated-secondary**, with power/connector specs primary.

---

## NVIDIA + CUDA

**Why CUDA dominates for local LLM inference:**
- **Ecosystem maturity.** cuBLAS / cuDNN / CUTLASS, and every inference engine (llama.cpp, Ollama, vLLM, SGLang, TensorRT-LLM, ExLlama, MLC) targets CUDA **first** and supports new models on CUDA on day one. PyTorch's default GPU build is CUDA.
- **TensorRT-LLM** gives NVIDIA a compiled, kernel-fused fast path with FP8/FP4 support on Hopper/Blackwell.
- **Blackwell (RTX 50-series, RTX PRO Blackwell, B200)** adds native **FP4** (5th-gen Tensor Cores / 2nd-gen Transformer Engine), roughly doubling low-precision throughput vs FP8 — relevant as FP4/NVFP4 quantization matures. (Primary-sourced in `notes/2026-08-21-1-basics-...`.)

**Drawbacks:**
- **Price and VRAM stinginess on consumer cards.** NVIDIA segments aggressively: the 24 GB tier is capped at the (now old) RTX 3090/4090, the RTX 5090 gives 32 GB, and to get past that on a single card you must jump to workstation/datacenter parts at multiples of the price.
- **Datacenter driver licensing.** Datacenter GPUs (A100/H100/…) require the enterprise vGPU / AI Enterprise licensing regime and specific datacenter drivers; the consumer driver EULA restricts datacenter deployment of GeForce cards.
- **Vendor lock-in.** Code, quant formats, and tooling assume CUDA; moving to AMD/Intel later is real work.
- **2026 memory crunch** hit NVIDIA hardest (GDDR7): see prices below.

**Cards commonly used for local LLM / coding, with 2026 pricing (all USD; all heavily inflated by the memory crunch — treat as volatile snapshots, not MSRP):**

| Card | VRAM | Bandwidth | Notes | Price signal (Aug 2026) |
|---|---|---|---|---|
| RTX 3090 (used) | 24 GB GDDR6X | ~936 GB/s | Still the value pick for 24 GB; Ampere, no FP8. | ~$700–1,000 used; some new/premium listings $1,400–1,900. **weak/volatile** ([bestvaluegpu RTX 3090](https://bestvaluegpu.com/history/new-and-used-rtx-3090-price-history-and-specs/), [XDA: used 3090 still best value](https://www.xda-developers.com/used-rtx-3090-still-best-for-local-ai-in-value/)) |
| RTX 4090 | 24 GB GDDR6X | ~1,008 GB/s | Ada, FP8. Discontinued; supply-constrained. | ~$2,500–3,775, "most units above $3,400" (was $1,599 MSRP). **corroborated-secondary/volatile** ([Digital Trends](https://www.digitaltrends.com/computing/nvidia-rtx-4090-shortage-prices-skyrocket/)) |
| RTX 5090 | 32 GB GDDR7 | ~1,792 GB/s | Blackwell, FP4. | ~$4,000–4,500 street (was $1,999 MSRP). **corroborated-secondary/volatile** ([TechSpot](https://www.techspot.com/news/113460-nvidia-raises-rtx-pro-6000-blackwell-price-staggering.html)) |
| RTX 4000 SFF Ada | 20 GB GDDR6 (ECC) | ~280 GB/s | 70 W, single-slot, no ext. power — for SFF/quiet builds. | ~$1,300–1,500 (pre-crunch MSRP ~$1,250). **weak** |
| RTX 2000 Ada | 16 GB GDDR6 (ECC) | ~224 GB/s | 70 W, low-profile. Real product. | ~$625 MSRP / ~$560–900 street. **corroborated-secondary** ([NVIDIA marketplace](https://marketplace.nvidia.com/en-us/enterprise/laptops-workstations/nvidia-rtx-2000-ada-generation/), [Phoronix review](https://www.phoronix.com/review/nvidia-rtx-2000-4000-ada)) |
| RTX 4000 Ada | 20 GB GDDR6 (ECC) | ~360 GB/s | 130 W, single-slot. | ~$1,250 MSRP / ~$865–1,400 street. **corroborated-secondary** ([NVIDIA marketplace](https://marketplace.nvidia.com/en-us/enterprise/laptops-workstations/nvidia-rtx-4000-ada-generation/)) |
| RTX PRO 2000 Blackwell | 16 GB GDDR7 | ~288 GB/s | **Real** — announced Aug 2025; 70 W, entry pro Blackwell. | ~$700–900 **weak** ([CG Channel](https://www.cgchannel.com/2025/08/nvidia-unveils-two-compact-new-rtx-pro-blackwell-gpus/), [Micro Center listing](https://www.microcenter.com/product/700588/pny-nvidia-rtx-pro-2000-blackwell-single-fan-ai-workstation-graphics-card)) |
| RTX PRO 6000 Blackwell | 96 GB GDDR7 (ECC) | ~1,790 GB/s | The single-card "run 70B in VRAM" option. Max-Q 300 W variant exists. | Pre-orders <$7,600 in early 2025 → **MSRP raised to ~$16,000** in 2026; street ~$8,300 (Max-Q) to ~$14,000–15,500. **corroborated-secondary/volatile** ([Tom's Hardware](https://www.tomshardware.com/pc-components/gpus/nvidia-doubles-rtx-pro-6000-blackwells-msrp-to-a-staggering-usd16-000-96gb-card-started-pre-orders-below-usd8-000-last-year), [wccftech](https://wccftech.com/nvidia-96-gb-rtx-pro-6000-blackwell-now-costs-16000-usd-double-its-original-price/)) |

Also real but less common for pure inference: RTX 4500 Ada (24 GB), RTX 5000 Ada (32 GB), and the rest of the RTX PRO Blackwell desktop line (4000 / 4500 / 5000, 24–48 GB).

**Verification of prior-notes names:** "RTX Pro 2000 Blackwell 16G" — **confirmed real**. "RTX 2000 Ada 16G" — **confirmed real**. "RTX 4000 SFF Ada 20G" — **confirmed real**. "RTX 5070 Ti 16G / RTX 5080 16G / RTX 4090 24G / RTX 5090 32G" — all real. Prior notes listing V100 as "80GB" is **wrong** (V100 was 16 or 32 GB).

**Sourcing: primary** for product existence and specs; **corroborated-secondary and explicitly volatile** for all 2026 prices (memory-crunch story corroborated across Tom's Hardware, TechSpot, Digital Trends, wccftech).

---

## AMD + ROCm

**ROCm status 2025–2026.**
- **Linux** is the first-class platform. ROCm moved from the 6.x line to **ROCm 7** in 2025 (7.0 released mid-2025; 7.x point releases through 2026). PyTorch has official ROCm wheels. ([AMD ROCm docs](https://rocm.docs.amd.com/), [ROCm blog](https://rocm.blogs.amd.com/))
- **Windows.** AMD ships a **HIP SDK for Windows** and, in 2025–2026, brought llama.cpp and Ollama ROCm builds to Windows; but serious ML (PyTorch-ROCm, vLLM, SGLang serving) is still effectively **Linux-only**. **corroborated-secondary** ([kunalganglani: ROCm vs CUDA 2026](https://www.kunalganglani.com/blog/rocm-consumer-gpu-cuda-alternative-2026), [canitrun.dev AMD guide](https://canitrun.dev/guides/amd-radeon-llm-guide/))
- **Officially supported GPUs** are a shorter list than NVIDIA's "every card." The consumer cards with official ROCm support are the RDNA3 Radeon **RX 7900 XTX / XT / GRE** (gfx1100) and the Radeon PRO **W7900 / W7800**; RDNA4 (RX 9070 series) support was added later in the ROCm 6.4/7 timeframe. Older/other cards often work **unofficially** via `HSA_OVERRIDE_GFX_VERSION`. ([AMD ROCm compatibility matrix](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html))

**Engine support.**
- **llama.cpp** — HIP/ROCm backend works well on supported RDNA3; there are also community "fresh ROCm builds" (e.g. lemonade-sdk/llamacpp-rocm). On Windows/AMD the **Vulkan** backend is often the pragmatic choice. ([llama.cpp build.md](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md), [lemonade-sdk/llamacpp-rocm](https://github.com/lemonade-sdk/llamacpp-rocm))
- **Ollama** — detects supported Radeon cards and uses ROCm automatically on Linux and Windows; unsupported cards fall back to CPU or need overrides.
- **vLLM** — official ROCm support, targeted primarily at **Instinct MI300X/MI325X**; Radeon consumer support is more experimental. SGLang similarly supports ROCm on Instinct.

**Drawbacks:** narrower supported-GPU matrix; historically buggy / churny (kernel + ROCm version coupling); fewer prebuilt wheels; new model architectures land on CUDA first; Windows story still limited. **corroborated-secondary.**

**Benchmark data point (primary-ish):** Phoronix, Oct 2025, Radeon AI PRO R9700 — with the updated RADV Vulkan driver, prefill ~624 vs ROCm ~753 tok/s (ROCm ahead on prompt processing), decode ~49.4 (Vulkan) vs ~47.0 (ROCm) — i.e. the two are close, with ROCm better at prefill and Vulkan competitive at decode. ([Phoronix: ROCm 7.1 vs RADV Vulkan for llama.cpp](https://www.phoronix.com/review/rocm-71-llama-cpp-vulkan))

**Cards commonly used + 2026 price signals (USD, volatile):**

| Card | VRAM | Bandwidth | Price signal (Aug 2026) |
|---|---|---|---|
| RX 7900 XTX | 24 GB GDDR6 | ~960 GB/s | ~$900–930 new, ~$800 used (was $999 MSRP). **corroborated-secondary** ([bestvaluegpu 7900 XTX](https://bestvaluegpu.com/history/new-and-used-rx-7900-xtx-price-history-and-specs/)) |
| RX 7900 XT | 20 GB GDDR6 | ~800 GB/s | ~$700–970 (wide spread; was $899 MSRP). **weak/volatile** ([bestvaluegpu 7900 XT](https://bestvaluegpu.com/history/new-and-used-rx-7900-xt-price-history-and-specs/)) |
| RX 9070 XT | 16 GB GDDR6 | ~640 GB/s | ~$730 (was $599 MSRP). **corroborated-secondary** ([videocardprices RX 9070 XT](https://videocardprices.com/card/amd-rx-9070-xt/)) |
| Radeon PRO W7900 | 48 GB GDDR6 (ECC) | ~864 GB/s | ~$3,500–4,000 (launch MSRP $3,999). **weak** ([AMD W7900 product page](https://www.amd.com/en/products/graphics/workstations/radeon-pro/w7900.html)) |
| Radeon AI PRO R9700 | 32 GB GDDR6 | — | RDNA4 workstation AI card, 2025. **weak** on price ([Phoronix](https://www.phoronix.com/review/rocm-71-llama-cpp-vulkan)) |

**Ryzen AI Max APUs** ("Strix Halo") — covered in the AI-workstation section.

**Sourcing: corroborated-secondary** (AMD docs primary for support matrix; Phoronix primary for benchmarks; prices volatile).

---

## Intel + SYCL

**Software stack.** Intel's GPU-compute stack is **oneAPI** with **SYCL** (open, Khronos standard) as the programming model. For LLMs Intel also ships **IPEX-LLM** (formerly BigDL-LLM), a PyTorch/llama.cpp/Ollama acceleration layer for Intel CPUs, iGPUs and Arc GPUs. ([Intel: "Run LLMs on Intel GPUs Using llama.cpp"](https://www.intel.com/content/www/us/en/developer/articles/technical/run-llms-on-gpus-using-llama-cpp.html), [IPEX-LLM repo](https://github.com/intel/ipex-llm))

**Engine support.**
- **llama.cpp** has a **SYCL backend** contributed largely by Intel; it targets "Intel Data Center Max Series, Flex Series and Arc Series, built-in Arc iGPU, and Intel iGPU in 11th-gen Core and newer." Intel maintains build docs for it. ([llama.cpp SYCL backend docs](https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/SYCL.md))
- **Ollama** runs on Intel GPUs via the IPEX-LLM portable build / community SYCL builds; official upstream Intel-GPU support has lagged the llama.cpp SYCL backend.
- **Vulkan** is an alternative path for Arc in llama.cpp and is sometimes faster/easier than SYCL depending on driver version.
- **vLLM** supports Intel Gaudi accelerators and has an experimental XPU (Arc/Max) path.

**Drawbacks:** smallest of the four ecosystems; SYCL/oneAPI toolchain install is heavy; driver maturity varies by OS and kernel; fewer people testing → more sharp edges; new models validated on Arc last. **corroborated-secondary** ([llama.cpp discussion #12570 "Current status of Intel Arc GPUs"](https://github.com/ggml-org/llama.cpp/discussions/12570)).

**Arc GPUs — real products and specs:**

| Card | VRAM | Bandwidth | Notes | Price signal |
|---|---|---|---|---|
| Arc A770 | 16 GB GDDR6 | ~560 GB/s | Alchemist, 2022. Budget 16 GB option. | ~$250–350 **weak/volatile** |
| Arc B580 | 12 GB GDDR6 | ~456 GB/s | Battlemage gaming card, late 2024. | ~$250–330 (was $249 MSRP) **weak** |
| Arc Pro B50 | 16 GB GDDR6 | ~224 GB/s | Battlemage pro, 70 W, SFF workstation. | **$349 launch MSRP** (some sources $299). **corroborated-secondary** ([TechPowerUp](https://www.techpowerup.com/340632/intel-arc-pro-b50-gpu-arrives-at-usd-349-for-small-form-factor-workstations)) |
| Arc Pro B60 | 24 GB GDDR6 | ~456 GB/s | Battlemage pro; a **dual-B60 (48 GB)** board also exists from partners. | ~$500–600 **corroborated-secondary** ([wccftech](https://wccftech.com/intel-arc-pro-b60-24-gb-b50-16-gb-battlemage-gpus-pro-ai-3x-faster-dual-gpu-variant/), [Notebookcheck](https://www.notebookcheck.net/Intel-Arc-Pro-B50-and-B60-launch-as-affordable-workstation-GPUs-with-up-to-24-GB-VRAM.1019453.0.html)) |

**Verification of prior-notes names:** "Arc Pro B50 16G" — **confirmed real**. **"Arc B70 32G" — could NOT be verified as an official Intel product.** Intel's announced Battlemage pro line is B50 (16 GB) and B60 (24 GB), plus partner dual-B60 (48 GB); reporting explicitly noted "no sign of an Arc B770 for gamers." References to an "Arc Pro B70" appear only in low-quality/AI-generated posts and in the German Reddit link in the prior notes — **treat "Arc B70 / Arc Pro B70" as unverified / likely fictional.** ([tweaktown: B50/B60 announced, no B770](https://www.tweaktown.com/news/105334/intel-arc-pro-b50-16gb-and-b60-24gb-gpus-announced-no-sign-of-b770-for-gamers/index.html))

**Sourcing: corroborated-secondary** (Intel dev docs + llama.cpp SYCL docs primary; Arc Pro pricing from tech press; "B70" is a negative finding).

---

## Vulkan

**What it is here.** llama.cpp ships a **Vulkan** compute backend (compute shaders, SPIR-V) that runs on any GPU with a conformant Vulkan 1.2+ driver — NVIDIA, AMD, Intel Arc/iGPU, and even some mobile/embedded GPUs — with **no vendor SDK install**, just an up-to-date graphics driver. ([llama.cpp build.md](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md), [FOSDEM 2026 talk: "Vulkan API for Machine Learning? Competing with CUDA and ROCm in llama.cpp"](https://fosdem.org/2026/schedule/event/CZSPSC-llama-cpp-vulkan/))

**Performance vs the vendor stacks.**
- vs **CUDA**: Vulkan is slower on NVIDIA — CUDA has hand-tuned kernels and is the optimisation target. Use CUDA on NVIDIA.
- vs **ROCm**: close. Phoronix (Oct 2025) shows ROCm ahead on prefill, Vulkan competitive or ahead on decode on RDNA; the community consensus is "Vulkan is now within a small margin of ROCm for llama.cpp and much easier to set up, especially on Windows." ([Phoronix](https://www.phoronix.com/review/rocm-71-llama-cpp-vulkan))
- vs **SYCL**: comparable on Arc; which wins depends on model and driver version.
- Historically Vulkan lagged badly; by 2025–2026 the gap to ROCm/SYCL narrowed to roughly single-digit-to-low-tens-of-percent for token generation on many models. **corroborated-secondary** ([llama.cpp discussion #10879 "Performance of llama.cpp with Vulkan"](https://github.com/ggml-org/llama.cpp/discussions/10879)).

**When to choose Vulkan:**
- AMD GPU **on Windows** (ROCm/HIP for llama.cpp is effectively Linux-only).
- Intel **Arc or iGPU** without wanting the oneAPI toolchain.
- **Mixed-vendor** multi-GPU boxes (one backend across an NVIDIA + AMD rig).
- Any GPU that isn't on its vendor's official support list but has a working Vulkan driver.
- Quick setup / no root / no multi-GB SDK.

**Maturity.** Actively developed, a first-class llama.cpp backend, used as the default GPU path by some downstream tools (e.g. certain LM Studio / Ollama configs on AMD Windows). Not available in vLLM/SGLang (those are CUDA/ROCm/TPU). **corroborated-secondary.**

**Sourcing: corroborated-secondary** (llama.cpp docs primary; Phoronix primary for the benchmark; performance-gap framing is community consensus).

---

## Apple Metal / MLX

**Two stacks on Apple Silicon:**
1. **llama.cpp Metal backend** — GGUF models, Metal compute shaders, ships in Ollama / LM Studio / llama.cpp itself. Mature, broad model coverage.
2. **MLX** — Apple's own array/ML framework ("brought to you by Apple machine learning research"), NumPy-like, with a **unified-memory model**: "arrays in MLX live in shared memory … operations … can be performed on any of the supported device types without transferring data." Companion libraries **mlx-lm** (text) and **mlx-vlm** (vision-language) provide generation, quantization and LoRA. MLX is generally **faster than llama.cpp/Metal on M-series** for LLM inference, which is why Ollama and LM Studio added MLX engines. ([MLX repo](https://github.com/ml-explore/mlx), [mlx-lm repo](https://github.com/ml-explore/mlx-lm), [Ollama blog: MLX](https://ollama.com/blog/mlx))

**Unified memory advantage.** On Apple Silicon the CPU and GPU share one pool of LPDDR5X; there is no PCIe copy and no separate "VRAM" to size. A 128 GB Mac can put ~an order of magnitude more model into GPU-accessible memory than a same-price discrete GPU. The cost is bandwidth (see below) and no CUDA ecosystem.

**Memory bandwidth by chip tier (Apple's own figures):**
- **M4 Pro** — up to 64 GB unified, **273 GB/s**. ([Apple newsroom: M4 Pro/Max](https://www.apple.com/newsroom/2024/10/apple-introduces-m4-pro-and-m4-max/))
- **M4 Max** — up to 128 GB unified, **410 GB/s** (binned) or **546 GB/s** (full). ([Apple newsroom](https://www.apple.com/newsroom/2024/10/apple-introduces-m4-pro-and-m4-max/))
- **M3 Ultra** — up to **512 GB** unified, **"over 800 GB/s"** (commonly cited as ~819 GB/s); Apple markets it for running "LLMs with over 600 billion parameters … on device." ([Apple newsroom: M3 Ultra](https://www.apple.com/newsroom/2025/03/apple-reveals-m3-ultra-taking-apple-silicon-to-a-new-extreme/))
- (M2 Ultra, still sold in some Mac Studios during this period: 800 GB/s, up to 192 GB.)
- Contrast with a discrete GPU: RTX 4090 ~1,008 GB/s, RTX 5090 ~1,792 GB/s — so even an M3 Ultra has roughly half a 4090's bandwidth, and a 5090 is ~2× the M3 Ultra and ~3× an M4 Max.

**The `recommendedMaxWorkingSetSize` cap.** Metal reports a per-process recommended GPU allocation limit; by default macOS lets the GPU use roughly **65–75 % of total RAM** (higher on very-large-RAM machines, and adjustable via the `iogpu.wired_limit_mb` sysctl). So a 128 GB Mac exposes ~96 GB to the model by default, not the full 128 GB. **corroborated-secondary** (Apple Metal API docs primary for the property; the percentage and the sysctl workaround are widely reported by practitioners — [Apple: MTLDevice.recommendedMaxWorkingSetSize](https://developer.apple.com/documentation/metal/mtldevice/recommendedmaxworkingsetsize)).

**Mac vs discrete GPU for local coding models, tokens/sec expectations (Q4, corroborated-secondary, workload-dependent):**
- M4 Pro (Mac Mini): ~30B-A3B MoE at a few tens of tok/s; 32B dense noticeably slower.
- M4 Max: comfortably runs 30B-class MoE and 32B dense at usable speeds; the popular "coding on a laptop" tier.
- M3 Ultra 512 GB: can *hold* very large MoE models (e.g. DeepSeek-R1 671B at 4-bit) but generates them at only ~**15–18 tok/s** — impressive that it runs at all, but slower than a small model on a fast GPU. ([MacRumors: M3 Ultra runs DeepSeek R1](https://www.macrumors.com/2025/03/17/apples-m3-ultra-runs-deepseek-r1-efficiently/); [Medium: "Apple's M3 Ultra Mac Studio Misses the Mark for LLM Inference"](https://medium.com/@billynewport/apples-m3-ultra-mac-studio-misses-the-mark-for-llm-inference-f57f1f10a56f))

**2026 pricing note.** Mac Studio M3 Ultra with 512 GB started at ~$9,500–10,000. During the **2026 DRAM crunch Apple reportedly pulled the 512 GB option** and raised prices on remaining configs — verify current Apple Store config before quoting. **weak/volatile** ([tech.yahoo/AppleInsider reporting](https://tech.yahoo.com/computing/articles/mac-studios-ability-boot-512gb-205700095.html)).

**Sourcing: primary** for MLX, unified memory, and Apple bandwidth figures; **corroborated-secondary** for the working-set cap and tokens/sec; **weak** for current Mac Studio pricing.

---

## AI-Workstations (unified / shared-memory machines)

The category: a single box with a large pool of LPDDR5X (or HBM on the high end) shared by CPU and an integrated GPU/accelerator, sold specifically for local AI. Core tradeoff vs a discrete GPU: **huge model capacity, but memory bandwidth an order of magnitude below discrete VRAM**, so big *dense* models load but generate slowly; MoE models are the sweet spot.

**NVIDIA DGX Spark (GB10 "Grace Blackwell").**
- **128 GB LPDDR5X unified**, Grace 20-core Arm CPU + Blackwell GPU (~6,144 CUDA cores), NVLink-C2C between CPU and GPU, ConnectX-7 (200 Gb/s) to pair two units, ~240 W external PSU. Advertised "up to 1 petaFLOP" sparse FP4.
- **Memory bandwidth ~273 GB/s** — the widely-criticised spec: similar to an M4 Pro, far below a discrete GPU, and the main reason token-gen on large dense models is slow.
- **Price:** launched **15 Oct 2025 at $3,999**; NVIDIA **raised MSRP to ~$4,699 in Feb 2026** citing LPDDR5X supply constraints; third-party boxes (ASUS, etc.) and retail vary ($4,400–5,400). **corroborated-secondary** ([Notebookcheck: DGX Spark $700 price hike](https://www.notebookcheck.net/Nvidia-GB10-powered-DGX-Spark-with-128-GB-LPDDR5X-memory-gets-700-price-hike.1236870.0.html), [IntuitionLabs review](https://intuitionlabs.ai/articles/nvidia-dgx-spark-review)) — the 273 GB/s figure and the price hike are consistently reported; specific tokens/sec vary by source and are **weak**.

**AMD Ryzen AI Max+ 395 "Strix Halo" mini-PCs.**
- **Up to 128 GB LPDDR5X-8000, 256-bit bus, ~256 GB/s theoretical** (~215–256 GB/s measured). 16-core Zen 5 CPU + **Radeon 8060S** iGPU (40 CU RDNA 3.5) + XDNA2 NPU. Runs via ROCm / Vulkan / llama.cpp; AMD publishes GPT-OSS-on-Ryzen-AI guides.
- **Vendors:** Framework Desktop, plus mini-PCs from GMKtec, Beelink, HP (Z2 Mini), etc.
- **Price:** Framework Desktop 128 GB configured around **$1,999** (64 GB ~$1,599); other 128 GB mini-PCs ~$1,700–2,300. Cheaper than a DGX Spark for the same 128 GB, slightly lower bandwidth. **corroborated-secondary** ([Framework Desktop page](https://frame.work/desktop), [localaimaster: Strix Halo guide](https://localaimaster.com/blog/strix-halo-ai-max-395-guide)) — bandwidth spec corroborated; exact tokens/sec **weak**.

**Apple Mac Studio M3 Ultra.** Up to **512 GB** unified at **~800+ GB/s** — the highest bandwidth *and* highest capacity of the unified-memory boxes, and roughly 3× the bandwidth of a DGX Spark / Strix Halo, at a much higher price (~$10k for 512 GB, and see the 2026 availability caveat above). Covered in the Apple section.

**Framing for the chapter:** these machines are for **running big models at all** (large-context, 70B–200B+ MoE, multi-model workflows) on a quiet, low-power desktop — not for maximum tokens/sec. A $2,000 used RTX 3090 or a 5090 will beat any of them on a model that fits in 24–32 GB. A 128 GB unified box wins the moment the model doesn't.

**Sourcing: corroborated-secondary**, with core specs (bandwidth, capacity, launch price) primary from vendors and the DGX Spark price hike corroborated across tech press; tokens/sec figures **weak**.

---

## Datacenter GPU stacks

**NVIDIA data-center GPUs (specs primary from NVIDIA):**

| GPU | Memory | Bandwidth | Interconnect | Notes |
|---|---|---|---|---|
| A100 | 40 or 80 GB HBM2e | ~1.6 / ~2.0 TB/s | NVLink 3 (600 GB/s) | Ampere, 2020; still heavily rented. |
| H100 (SXM) | 80 GB HBM3 | ~3.35 TB/s | NVLink 4 (900 GB/s) | Hopper; FP8 Transformer Engine. Also 94 GB "NVL". |
| H200 | 141 GB HBM3e | ~4.8 TB/s | NVLink 4 (900 GB/s) | Hopper refresh — same compute as H100, more/faster memory. |
| B200 | ~180–192 GB HBM3e | ~7.7–8 TB/s | NVLink 5 (1.8 TB/s) | Blackwell; native FP4. |
| GB200 (Grace+2×B200) | 2× ~192 GB HBM3e + 480 GB LPDDR5X | — | NVLink 5 | Superchip; building block of NVL72 racks. |

([NVIDIA H100](https://www.nvidia.com/en-us/data-center/h100/), [NVIDIA H200](https://www.nvidia.com/en-us/data-center/h200/), [NVIDIA GB200 NVL72](https://www.nvidia.com/en-us/data-center/gb200-nvl72/)) — B200 memory is quoted as both 180 GB and 192 GB depending on config; note the range.

**NVLink / NVSwitch.** NVLink is NVIDIA's GPU-to-GPU fabric (much faster than PCIe: 900 GB/s on Hopper, 1.8 TB/s per GPU on Blackwell); **NVSwitch** connects many GPUs all-to-all (e.g. GB200 NVL72 = 72 Blackwell GPUs as one NVLink domain). This is what makes tensor-parallel serving of a model too big for one GPU practical.

**AMD Instinct (main alternative):**
- **MI300X** — **192 GB HBM3, ~5.3 TB/s**, 750 W, CDNA3. The "more memory per GPU than H100/H200" pitch. ([AMD MI300X](https://www.amd.com/en/products/accelerators/instinct/mi300/mi300x.html))
- **MI325X** — **256 GB HBM3e, ~6 TB/s**, 1000 W (originally announced as 288 GB; shipped configs commonly cited at 256 GB — note the discrepancy). ([AMD Instinct press release](https://ir.amd.com/news-events/press-releases/detail/1220/amd-delivers-leadership-ai-performance-with-amd-instinct))
- Newer MI350-series (CDNA4, HBM3e, FP4/FP6) referenced in 2025–2026 sources — **weak**, verify specifics.
- Supported by vLLM and SGLang on ROCm; the software gap to CUDA is the main friction.

**Why you'd need datacenter GPUs for local/self-hosted:**
- **Large MoE models** (DeepSeek-V3/R1-class ~670B, and larger) need aggregate HBM in the hundreds of GB → multiple H100/H200/B200 or MI300X with tensor/pipeline/expert parallelism over NVLink.
- **Many concurrent users** — vLLM/SGLang on datacenter GPUs is the only way to serve a team/product at low latency.
- HBM bandwidth (3–8 TB/s) is 2–4× the best consumer card → higher single-stream tok/s too.

**Drawbacks vs consumer:**
- **Cost.** H100 ~$25k–30k+ to buy; B200 more; 8-GPU HGX/DGX nodes $250k–400k+. Plus a rack, 10–15 kW power, liquid or high-CFM cooling, 208/415 V circuits.
- **Availability** — allocation-limited; the 2026 memory crunch made this worse.
- **Datacenter driver / licensing** regime (NVIDIA AI Enterprise / vGPU) and no consumer-driver fallback.
- Not a desk machine.

**Cloud rental economics (2026, corroborated-secondary, highly provider-dependent):**
- **H100:** ~$1.5–3.5/GPU-hr on neoclouds/marketplaces (Vast.ai/RunPod from ~$1.5–2), up to ~$7/hr on hyperscalers. Down from ~$8/hr in 2023.
- **H200:** ~$2.3–4.5/GPU-hr typical; up to ~$10–14 on Azure.
- **B200:** ~$4.5–7/GPU-hr.
- **MI300X:** ~$1.7–3/GPU-hr on neoclouds — usually 10–30 % under H100 and more memory per dollar.
([IntuitionLabs: H100 rental comparison](https://intuitionlabs.ai/articles/h100-rental-prices-cloud-comparison), [Thunder Compute: MI300X pricing Aug 2026](https://www.thundercompute.com/blog/amd-mi300x-pricing), [getdeploying GPU price index](https://getdeploying.com/gpu-price-index))
- **Rule of thumb:** owning an 8×H100 node only pencils out vs renting at very high sustained utilisation (often cited break-even ~50–70 % 24/7 for 1–2 years); for bursty or experimental use, renting wins. For a single developer doing agentic coding, an API (OpenRouter / provider) or a local consumer GPU both beat renting a datacenter GPU. **corroborated-secondary** ([CloudZero: H100 cost — buy vs rent](https://www.cloudzero.com/blog/h100-gpu-cost/)).

**On the prior notes' claim** — "the entire model can barely fit in a single NVIDIA DGX B300 and requires a minimum of 16 B200/GB200 GPUs to serve": this is plausible in shape for a frontier-scale (~1–2T-param) MoE at low quant, but it referenced fictional model names and no source; **treat as illustrative, not a citable fact.**

**Sourcing: primary** for GPU specs and interconnect; **corroborated-secondary** for cloud pricing and buy-vs-rent (volatile).

---

## Cross-cutting: the 2026 memory-supply crunch

Nearly every price in this note is elevated by a 2025–2026 shortage of DRAM / GDDR7 / HBM, driven by AI datacenter demand crowding out consumer supply. Well-corroborated concrete effects:
- RTX PRO 6000 Blackwell MSRP roughly **doubled** (pre-order <$7,600 → ~$16,000). ([Tom's Hardware](https://www.tomshardware.com/pc-components/gpus/nvidia-doubles-rtx-pro-6000-blackwells-msrp-to-a-staggering-usd16-000-96gb-card-started-pre-orders-below-usd8-000-last-year), [TechSpot](https://www.techspot.com/news/113460-nvidia-raises-rtx-pro-6000-blackwell-price-staggering.html))
- RTX 5090 street ~2–2.3× its $1,999 MSRP; RTX 4090 (discontinued) ~$2,500–3,800 vs $1,599. ([Digital Trends](https://www.digitaltrends.com/computing/nvidia-rtx-4090-shortage-prices-skyrocket/))
- DGX Spark MSRP raised $3,999 → ~$4,699, explicitly blamed on LPDDR5X supply. ([Notebookcheck](https://www.notebookcheck.net/Nvidia-GB10-powered-DGX-Spark-with-128-GB-LPDDR5X-memory-gets-700-price-hike.1236870.0.html))
- Apple reportedly dropped the 512 GB Mac Studio option. **weak** ([tech.yahoo](https://tech.yahoo.com/computing/articles/mac-studios-ability-boot-512gb-205700095.html))

For the chapter: state prices as ranges with "as of 2026, inflated by the DRAM shortage" and avoid hard MSRPs.

---

## Sources

1. llama.cpp repository — https://github.com/ggml-org/llama.cpp
2. llama.cpp build docs (backend list) — https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md
3. llama.cpp server README — https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md
4. llama.cpp SYCL backend docs — https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/SYCL.md
5. llama.cpp speculative decoding example — https://github.com/ggml-org/llama.cpp/tree/master/examples/speculative
6. DeepWiki: Speculative Decoding in llama.cpp — https://deepwiki.com/ggml-org/llama.cpp/8.3-speculative-decoding
7. llama.cpp discussion #10879 — Vulkan performance — https://github.com/ggml-org/llama.cpp/discussions/10879
8. llama.cpp discussion #12570 — Intel Arc status — https://github.com/ggml-org/llama.cpp/discussions/12570
9. ggml.ai — https://ggml.ai
10. GGUF spec (ggml repo) — https://github.com/ggml-org/ggml/blob/master/docs/gguf.md
11. Ollama repo + LICENSE (MIT) — https://github.com/ollama/ollama/blob/main/LICENSE
12. Ollama Modelfile docs — https://github.com/ollama/ollama/blob/main/docs/modelfile.md
13. Ollama OpenAI-compatibility docs — https://github.com/ollama/ollama/blob/main/docs/openai.md
14. Ollama FAQ / docs — https://github.com/ollama/ollama/blob/main/docs/faq.md
15. Ollama blog (index; "new engine", "MLX", scheduling) — https://ollama.com/blog
16. Ollama blog: MLX on Apple Silicon — https://ollama.com/blog/mlx
17. Wikipedia: Ollama — https://en.wikipedia.org/wiki/Ollama
18. vLLM documentation — https://docs.vllm.ai/en/latest/
19. vLLM docs: Automatic Prefix Caching — https://docs.vllm.ai/en/latest/features/automatic_prefix_caching.html
20. vLLM docs: Quantization — https://docs.vllm.ai/en/latest/features/quantization/
21. vLLM docs: Conserving Memory (gpu_memory_utilization) — https://docs.vllm.ai/en/latest/configuration/conserving_memory.html
22. Kwon et al., PagedAttention, SOSP '23 — https://arxiv.org/abs/2309.06180
23. SGLang docs — https://docs.sglang.ai/
24. Hugging Face TGI repo — https://github.com/huggingface/text-generation-inference
25. Red Hat Developers: vLLM or llama.cpp (2025-09-30) — https://developers.redhat.com/articles/2025/09/30/vllm-or-llamacpp-choosing-right-llm-inference-engine-your-use-case
26. Red Hat Developers: llama.cpp vs vLLM (2026-06-15) — https://developers.redhat.com/articles/2026/06/15/llamacpp-vs-vllm-choosing-right-local-llm-inference-engine
27. bswen: llama.cpp vs Ollama for local coding — https://docs.bswen.com/blog/2026-03-27-llama-cpp-vs-ollama-local-coding/
28. Spheron: vLLM vs TensorRT-LLM vs SGLang benchmarks — https://www.spheron.network/blog/vllm-vs-tensorrt-llm-vs-sglang-benchmarks/
29. Finbarr Timbers: How is llama.cpp possible? — https://finbarr.ca/how-is-llama-cpp-possible/
30. dev.to: The real cost of LLM inference — memory bandwidth not FLOPs — https://dev.to/avik12345678/the-real-cost-of-llm-inference-memory-bandwidth-not-flops-3855
31. dev.to: DDR5 Speed and LLM Inference — https://dev.to/maximsaplin/ddr5-speed-and-llm-inference-3cdn
32. Medium (Shriom Tripathi): llama.cpp CPU Inference on Consumer Hardware — https://medium.com/@shriomtripathi33/llama-cpp-cpu-inference-for-llms-on-consumer-hardware-3bca99b11d4b
33. devinfo.dev: The Memory Wall — https://devinfo.dev/d/2026.0049
34. Spheron: LLM VRAM requirements — https://www.spheron.network/blog/gpu-memory-requirements-llm/
35. promptquorum: local LLM hardware guide 2026 — https://www.promptquorum.com/local-llms/local-llm-hardware-guide-2026
36. NVIDIA GeForce RTX 4090 — https://www.nvidia.com/en-us/geforce/graphics-cards/40-series/rtx-4090/
37. NVIDIA GeForce RTX 5090 — https://www.nvidia.com/en-us/geforce/graphics-cards/50-series/rtx-5090/
38. NVIDIA RTX 2000 Ada (marketplace) — https://marketplace.nvidia.com/en-us/enterprise/laptops-workstations/nvidia-rtx-2000-ada-generation/
39. NVIDIA RTX 4000 Ada (marketplace) — https://marketplace.nvidia.com/en-us/enterprise/laptops-workstations/nvidia-rtx-4000-ada-generation/
40. Phoronix: NVIDIA RTX 2000 / 4000 Ada Linux review — https://www.phoronix.com/review/nvidia-rtx-2000-4000-ada
41. CG Channel: NVIDIA unveils two compact RTX PRO Blackwell GPUs (RTX PRO 2000/4000 SFF) — https://www.cgchannel.com/2025/08/nvidia-unveils-two-compact-new-rtx-pro-blackwell-gpus/
42. Micro Center: PNY RTX PRO 2000 Blackwell listing — https://www.microcenter.com/product/700588/pny-nvidia-rtx-pro-2000-blackwell-single-fan-ai-workstation-graphics-card
43. Tom's Hardware: RTX PRO 6000 Blackwell MSRP doubled to $16,000 — https://www.tomshardware.com/pc-components/gpus/nvidia-doubles-rtx-pro-6000-blackwells-msrp-to-a-staggering-usd16-000-96gb-card-started-pre-orders-below-usd8-000-last-year
44. wccftech: RTX PRO 6000 Blackwell now $16,000 — https://wccftech.com/nvidia-96-gb-rtx-pro-6000-blackwell-now-costs-16000-usd-double-its-original-price/
45. TechSpot: NVIDIA raises RTX PRO 6000 Blackwell price — https://www.techspot.com/news/113460-nvidia-raises-rtx-pro-6000-blackwell-price-staggering.html
46. Digital Trends: RTX 4090 shortage, prices skyrocket — https://www.digitaltrends.com/computing/nvidia-rtx-4090-shortage-prices-skyrocket/
47. bestvaluegpu: RX 7900 XTX price history — https://bestvaluegpu.com/history/new-and-used-rx-7900-xtx-price-history-and-specs/
48. bestvaluegpu: RX 7900 XT price history — https://bestvaluegpu.com/history/new-and-used-rx-7900-xt-price-history-and-specs/
49. bestvaluegpu: RTX 3090 price history — https://bestvaluegpu.com/history/new-and-used-rtx-3090-price-history-and-specs/
50. videocardprices: RX 9070 XT tracker — https://videocardprices.com/card/amd-rx-9070-xt/
51. XDA: used RTX 3090 still best for local AI value — https://www.xda-developers.com/used-rtx-3090-still-best-for-local-ai-in-value/
52. AMD ROCm documentation — https://rocm.docs.amd.com/
53. AMD ROCm system requirements / compatibility matrix — https://rocm.docs.amd.com/projects/install-on-linux/en/latest/reference/system-requirements.html
54. AMD ROCm blog — https://rocm.blogs.amd.com/
55. Phoronix: ROCm 7.1 vs RADV Vulkan for llama.cpp (Radeon AI PRO R9700) — https://www.phoronix.com/review/rocm-71-llama-cpp-vulkan
56. lemonade-sdk/llamacpp-rocm — https://github.com/lemonade-sdk/llamacpp-rocm
57. kunalganglani: ROCm vs CUDA in 2026 — https://www.kunalganglani.com/blog/rocm-consumer-gpu-cuda-alternative-2026
58. canitrun.dev: AMD Radeon for LLMs (ROCm & Vulkan) — https://canitrun.dev/guides/amd-radeon-llm-guide/
59. AMD Radeon PRO W7900 product page — https://www.amd.com/en/products/graphics/workstations/radeon-pro/w7900.html
60. Intel: Run LLMs on Intel GPUs Using llama.cpp — https://www.intel.com/content/www/us/en/developer/articles/technical/run-llms-on-gpus-using-llama-cpp.html
61. Intel IPEX-LLM repo — https://github.com/intel/ipex-llm
62. TechPowerUp: Intel Arc Pro B50 at $349 — https://www.techpowerup.com/340632/intel-arc-pro-b50-gpu-arrives-at-usd-349-for-small-form-factor-workstations
63. tweaktown: Intel Arc Pro B50 16GB and B60 24GB announced, no Arc B770 — https://www.tweaktown.com/news/105334/intel-arc-pro-b50-16gb-and-b60-24gb-gpus-announced-no-sign-of-b770-for-gamers/index.html
64. wccftech: Intel Arc Pro B60 24GB & B50 16GB Battlemage — https://wccftech.com/intel-arc-pro-b60-24-gb-b50-16-gb-battlemage-gpus-pro-ai-3x-faster-dual-gpu-variant/
65. Notebookcheck: Intel Arc Pro B50 and B60 launch — https://www.notebookcheck.net/Intel-Arc-Pro-B50-and-B60-launch-as-affordable-workstation-GPUs-with-up-to-24-GB-VRAM.1019453.0.html
66. FOSDEM 2026: Vulkan API for Machine Learning? Competing with CUDA and ROCm in llama.cpp — https://fosdem.org/2026/schedule/event/CZSPSC-llama-cpp-vulkan/
67. Apple MLX repo — https://github.com/ml-explore/mlx
68. Apple mlx-lm repo — https://github.com/ml-explore/mlx-lm
69. Apple newsroom: M4 Pro and M4 Max — https://www.apple.com/newsroom/2024/10/apple-introduces-m4-pro-and-m4-max/
70. Apple newsroom: M3 Ultra — https://www.apple.com/newsroom/2025/03/apple-reveals-m3-ultra-taking-apple-silicon-to-a-new-extreme/
71. Apple developer docs: MTLDevice.recommendedMaxWorkingSetSize — https://developer.apple.com/documentation/metal/mtldevice/recommendedmaxworkingsetsize
72. MacRumors: Mac Studio M3 Ultra runs DeepSeek R1 — https://www.macrumors.com/2025/03/17/apples-m3-ultra-runs-deepseek-r1-efficiently/
73. Medium (Billy Newport): M3 Ultra Mac Studio misses the mark for LLM inference — https://medium.com/@billynewport/apples-m3-ultra-mac-studio-misses-the-mark-for-llm-inference-f57f1f10a56f
74. tech.yahoo: Mac Studio 512GB availability — https://tech.yahoo.com/computing/articles/mac-studios-ability-boot-512gb-205700095.html
75. Notebookcheck: DGX Spark 128GB LPDDR5X gets $700 price hike — https://www.notebookcheck.net/Nvidia-GB10-powered-DGX-Spark-with-128-GB-LPDDR5X-memory-gets-700-price-hike.1236870.0.html
76. IntuitionLabs: NVIDIA DGX Spark review ($4,699) — https://intuitionlabs.ai/articles/nvidia-dgx-spark-review
77. Best Buy: DGX Spark listing — https://www.bestbuy.com/product/dgx-spark-nvidia-gb10-grace-blackwell-superchip-128-gb-lpddr5x-4-tb-nvme-m2-ssd-gold/JXF2C4R2TS
78. Framework Desktop — https://frame.work/desktop
79. localaimaster: AMD Ryzen AI Max+ 395 (Strix Halo) guide — https://localaimaster.com/blog/strix-halo-ai-max-395-guide
80. AMD blog: run GPT-OSS 20B/120B on Ryzen AI + Radeon — https://www.amd.com/en/blogs/2025/how-to-run-openai-gpt-oss-20b-120b-models-on-amd-ryzen-ai-radeon.html
81. NVIDIA H100 — https://www.nvidia.com/en-us/data-center/h100/
82. NVIDIA H200 — https://www.nvidia.com/en-us/data-center/h200/
83. NVIDIA GB200 NVL72 — https://www.nvidia.com/en-us/data-center/gb200-nvl72/
84. AMD Instinct MI300X — https://www.amd.com/en/products/accelerators/instinct/mi300/mi300x.html
85. AMD press release: Instinct MI325X — https://ir.amd.com/news-events/press-releases/detail/1220/amd-delivers-leadership-ai-performance-with-amd-instinct
86. tweaktown: AMD Instinct MI300X 192GB / MI325X 288GB details — https://www.tweaktown.com/news/100187/amd-details-instinct-mi300x-mcm-gpu-192gb-of-hbm3-out-now-mi325x-with-288gb-hbm3e-in-october/index.html
87. IntuitionLabs: H100 rental prices across 15+ clouds — https://intuitionlabs.ai/articles/h100-rental-prices-cloud-comparison
88. Thunder Compute: AMD MI300X pricing (Aug 2026) — https://www.thundercompute.com/blog/amd-mi300x-pricing
89. getdeploying: GPU price index — https://getdeploying.com/gpu-price-index
90. CloudZero: H100 GPU cost — buy vs rent — https://www.cloudzero.com/blog/h100-gpu-cost/
91. buttondown: Weekly GitHub Report for llama.cpp (activity/stars) — https://buttondown.com/weekly-project-news/archive/weekly-github-report-for-llamacpp-august-25-2025-2309/
