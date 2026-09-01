# Research pass: Qwen3.8 for local agentic coding on consumer GPUs

Date: 2026-08-29 · run 4 · chapter `src/local-models.md`
Skill: deep-book-research (manual pass)

Scope: Qwen3.8 — release/lineage, variants/architecture, coding & agentic benchmarks, consumer-GPU
feasibility, licensing & availability. Extends the Aug 2026 pass that had flagged the whole
Qwen3.5/3.6/3.8 line as "real but weakly sourced."

**Bottom line up front:** unlike the earlier pass's experience, Qwen3.8 *is* well-attested by
first-party material as of 2026-08-29. The `QwenLM/Qwen3.8` GitHub repo, the two Hugging Face model
cards (`Qwen/Qwen3.8-27B`, `Qwen/Qwen3.8-2.4T-A95B`), their `config.json` and `LICENSE` files, and
the official FP8 repos are all reachable and internally consistent. The Qwen blog
(`qwen.ai/blog?id=qwen3.8`) is a JavaScript-rendered SPA that could not be scraped directly; every
claim below that would normally cite the blog is instead cited to the GitHub repo or the model cards,
which reproduce the same figures. The one genuinely soft area is real-world consumer-GPU
tokens/sec, which rests on community posts.

Training-cutoff caveat: the assistant's knowledge ends January 2026; everything here (Qwen3.5, 3.6,
3.7 tier, 3.8, the "Qwen3.7-Max/Plus" API tiers, competitor names like "Opus 4.6/4.8", "Fable 5",
"Muse Glimmer-30B" that appear in Qwen's own comparison tables) was verified by web search in
August 2026.

---

## Qwen3.8 release and lineage

**Publisher / what it is.** Qwen3.8 is the Aug 2026 generation of Alibaba's Qwen open-model family,
published by the Qwen Team. The GitHub repo `QwenLM/Qwen3.8` frames the whole post-Qwen3 line as one
series: *"Welcome to the GitHub repository of the Qwen3.5 open model series, including Qwen3.5,
Qwen3.6, and the latest Qwen3.8"* ([1]). So Qwen3.8 is a **point release within the Qwen3.5 series
lineage**, not a fresh generation — it is *"Built on the architectural foundation of Qwen3.5"* and
described as *"the most capable generation in the Qwen open-model family to date"* ([2]).

**Release dates** (from the repo's News section, [1]):
- **2026-08-12** — `Qwen3.8-2.4T-A95B` (the open-weight base of "Qwen3.8-Max") on Hugging Face Hub and ModelScope.
- **2026-08-14** — `Qwen3.8-27B` on Hugging Face Hub and ModelScope. (Some secondary write-ups say Aug 13; the repo says Aug 14, [1].)
- Blog: `https://qwen.ai/blog?id=qwen3.8`, titled *"Qwen3.8-Max: A New Bar for Coding and Cowork"*, Qwen Team, August 2026 (BibTeX in [1], [2], [3]).

**Lineage / how the numbering works:**
- **Qwen3.5** — first release 2026-02-16 (397B-A17B MoE); mid-sizes 2026-02-24 (122B-A10B, 35B-A3B, 27B); small dense 2026-03-02 (9B, 4B, 2B, 0.8B). Hybrid Gated-DeltaNet + sparse-MoE architecture, unified vision-language, 201 languages ([1]).
- **Qwen3.6** — 2026-04-16 `Qwen3.6-35B-A3B` (MoE, *"Agentic Coding Power, Now Open to All"*); 2026-04-22 `Qwen3.6-27B` (dense, *"Flagship-Level Coding in a 27B Dense Model"*). Positioned as a stability / real-world-utility update over 3.5, adding "thinking preservation" across turns ([1]).
- **Qwen3.7** — **no open weights.** There is no `Qwen3.7` entry in the repo's News or model list. "Qwen3.7-Plus" and "Qwen3.7-Max" appear only as **API-tier baselines inside Qwen3.8's own comparison tables** ([2], [3]). This matches the earlier pass's finding that the `.x-Plus`/`.x-Max` names are hosted-API-only tiers. So the open-weight line goes 3.5 → 3.6 → 3.8, skipping 3.7.
- **Qwen3.8** — 2026-08. Brings *"a Qwen-Max-class model to open release"* for the first time (the 2.4T-A95B) plus a compact 27B dense VL model ([2], [3]).

**Is there a dedicated `-Coder` variant?** **No.** Neither the repo nor the model cards mention a
`Qwen3.8-Coder`. The repo's README lists only `Qwen3.8-27B` and `Qwen3.8-2.4T-A95B` ([1]); the HF
`Qwen/qwen38` collection contains only those two plus their FP8 quants ([9]). Coding is pitched as a
first-class capability of the general models instead — the blog title is literally about "Coding and
Cowork" ([2]). The separate `QwenLM/Qwen3-Coder` line (Qwen3-Coder-30B-A3B, -480B-A35B) has not been
refreshed to a 3.8 number as of this date. For terminal agentic use Qwen ships **Qwen Code**, an
open-source CLI agent "optimized for Qwen models" ([1]) — a harness, not a model.

**Technical report.** None found. The repo explicitly has no arXiv/tech-report link; the only
citable artifact is the blog post ([1], and the `@misc{qwen38 ...}` BibTeX in [2]/[3] points at the
blog URL). Qwen3.5 had a blog but (as of search) also no arXiv report.

**Sourcing:** primary-sourced (GitHub repo + HF model cards + their config/LICENSE files);
the blog itself is first-party but was not directly scrapeable (JS SPA), so its contents are cited
via the repo/cards that mirror them.

---

## Qwen3.8 model sizes / variants and architecture

Two open-weight checkpoints, both **native vision-language, both "thinking by default"** with a
toggle, both MTP-equipped, both 262,144-token native context extensible to ~1M via YaRN.

### Qwen3.8-27B (the consumer-relevant one)

From the HF model card "Model Overview" and `config.json` ([3], [4]):
- **Dense** (no MoE), 27B parameters. Secondary sources put the exact checkpoint at ~27.78 B ([12]).
- Hidden dim 5120; **64 layers**; FFN intermediate 17,408; vocab 248,320 (padded).
- **Hybrid attention**, same family as Qwen3-Next / Qwen3.5. Layer layout: `16 × (3 × (Gated DeltaNet → FFN) → 1 × (Gated Attention → FFN))` — i.e. **48 Gated-DeltaNet linear-attention layers + 16 full-attention layers** (`full_attention_interval: 4` in config, [4]).
  - Gated DeltaNet: 48 value heads / 16 QK heads, head dim 128, conv kernel dim 4, SSM state in fp32.
  - Gated Attention: **24 query heads / 4 KV heads (GQA)**, head dim 256, partial RoPE (`partial_rotary_factor: 0.25`), `rope_theta` 1e7, output gate (`attn_output_gate: true`).
- **MTP:** *"trained with multiple steps"*; `config.json` has `mtp_num_hidden_layers: 1`, `mtp_use_dedicated_embeddings: false` ([3], [4]). MTP head is bundled in the checkpoint → self-speculative decoding with no separate draft model.
- **Vision encoder:** ~27-layer ViT, hidden 1152, patch 16, spatial merge 2, out dim 5120 ([4]). Understands images, STEM diagrams, documents, hour-scale video.
- **Context:** 262,144 native, "extensible up to 1,000,000" via static YaRN (`factor 4.0` over `original_max_position_embeddings 262144`); Qwen warns static YaRN hurts short-context quality so only enable when needed ([3]).
- **Model class in config:** `Qwen3_5ForConditionalGeneration` / `model_type: qwen3_5` — Qwen3.8-27B reuses the Qwen3.5 architecture class verbatim ([4]).
- **Modes / variants:** one post-trained checkpoint that runs in **Thinking mode (default)** or **Instruct / non-thinking mode** (`enable_thinking: False`). `reasoning_effort` ∈ {`xhigh` (default), `medium`, `low`} (the card text also mentions `low/medium/xhigh`; note the GitHub README lists `xhigh/medium/low` while an older wording says "high" — treat `xhigh` as canonical per the card, [3]). `preserve_thinking` on by default (keeps prior-turn reasoning traces in context; helps KV-cache reuse and agent decision consistency). **No separate `-Instruct`, `-Thinking`, or `-Base` repos** are published — HF `Qwen/qwen38` has only `Qwen3.8-27B` and `Qwen3.8-27B-FP8` ([9]).

### Qwen3.8-2.4T-A95B ("Qwen3.8-Max" open base)

From its HF card ([5], and repo [1]):
- **MoE**, **2.4 T total / 95 B activated** parameters. Hidden dim 8192; **92 layers**; layout `23 × (3 × (Gated DeltaNet → MoE) → 1 × (Gated Attention → MoE))`.
- MoE: **512 experts, 10 routed + 1 shared active**, expert intermediate dim 2048.
- Gated DeltaNet: 128 V / 16 QK heads, head dim 128. Gated Attention: 64 Q / 4 KV heads (GQA), head dim 256.
- MTP trained with multiple steps. Context 262,144 native, extensible to ~1,010,000.
- **Text-only in the open checkpoint.** Vision input, non-thinking support, 1M default context and built-in tools are only in the hosted **Qwen3.8-Max** on Qwen Cloud ([5]).
- Ships with an official **FP8** repo (`Qwen/Qwen3.8-2.4T-A95B-FP8`, [9]). At 95 B active params this is a datacenter model (FP8 weights alone ≈ 2.4 TB); **not a consumer target** and out of scope for the consumer tiers below.

### API-only tiers

`Qwen3.8-Max` (hosted, vision + 1M context + tools, on Qwen Cloud / Qwen Studio) is the productized
form of 2.4T-A95B ([5]). `Qwen3.8-27B` will also get a hosted version with "1M context by default,
official built-in tools" ([3]). `Qwen3.7-Plus` / `Qwen3.7-Max` are prior-gen hosted tiers, no
weights ([2], [3]).

**Sourcing:** primary-sourced (HF model cards + `config.json` + HF collection API listing).

---

## Qwen3.8 coding / agentic benchmarks

**Important:** Qwen's first-party tables for Qwen3.8-27B **do not report SWE-bench Verified, Aider
polyglot, or the classic Terminal-Bench**. They use SWE-bench **Pro**, an in-house "QwenSWEBench", a
"DeepSWE 1.1", "NL2Repo-Bench", and "Terminal Bench 2.1 (Terminus)". All are run under the **Claude
Code harness** at temp 1.0 / top_p 0.95 / 256K context, with Qwen re-running baselines on their
"refined" version of the benchmark ([3]). So cross-model comparison to the anchors in the chapter
(Qwen2.5-Coder-32B 69.6% SWE-bench Verified; Qwen3-Coder-30B-A3B 51.6%) is **not
apples-to-apples** — different benchmark, different harness, different year.

### Qwen3.8-27B — first-party text table ([3])

Columns: Qwen3.8-27B | Qwen3.6-27B | Qwen3.7-Plus | Muse Glimmer-30B | Opus4.6 Max

| Benchmark (scaffold) | Qwen3.8-27B | Qwen3.6-27B | Qwen3.7-Plus | Opus4.6 Max |
|---|---|---|---|---|
| Terminal Bench 2.1 / Terminus | **73.0** | 63.4 | 64.0 | 78.2 |
| SWE-bench Pro (Claude Code harness) | **61.7** | 53.5 | 57.6 | 53.4 |
| NL2Repo-Bench (Claude Code harness) | 42.3 | 36.2 | 41.1 | 47.6 |
| DeepSWE 1.1 (Claude Code harness) | **42.2** | 13.3 | 14.2 | -- |
| QwenSWEBench (in-house, avg@3, Claude Code) | **79.0** | 49.3 | 59.2 | 63.8 |
| CoWorkBench (long-horizon office work) | **70.7** | 61.0 | 65.1 | 68.2 |
| JobBench | **33.4** | 21.8 | 27.6 | -- |
| Agents' Last Exam (Pass@1 / Score) | **20.4 / 42.9** | 10.6 / 27.3 | 13.2 / 33.6 | -- |
| IFBench (instruction following) | **79.5** | 69.1 | 79.1 | 62.5 |
| GPQA Diamond | 89.2 | 87.8 | 90.3 | 91.3 |
| LiveCodeBench v6 | **90.3** | 83.9 | 89.6 | 88.8 |
| HLE (GPT-4o judge) | 30.8 | 24.0 | 34.7 | 40.0 |

VL / agentic-multimodal table ([3]): OSWorld-Verified **84.3** (vs Qwen3.6-27B 63.9, Qwen3.7-Plus
73.3), WebArena-Verified **64.8**, AndroidWorld **81.9**, SWE-MM 38.6 (public dev split of SWE-bench
Multimodal), Vision2Web 62.9.

Reading of these: Qwen3.8-27B is a **large generational jump over Qwen3.6-27B on agentic coding** on
Qwen's own numbers (SWE-bench Pro +8.2, DeepSWE 1.1 +29, QwenSWEBench +30, OSWorld +20), and
Qwen positions it at/near frontier-hosted level on several rows. Treat the magnitude of the
Qwen3.6→3.8 gap with mild caution — some of it is a stronger post-training / harness-tuning story on
a benchmark Qwen curates itself (QwenSWEBench, "refined" SWE-bench Pro).

### Qwen3.8-2.4T-A95B / Qwen3.8-Max ([5], secondary [10][12])

First-party table columns include Opus 4.8, Fable 5, GPT 5.6 "Sol", Qwen3.7-Max, Qwen3.8-Max:
Terminal Bench 2.1 **86.6**, SWE-bench Pro **67.7**, DeepSWE 1.1 **56.6**, NL2Repo-Bench 55.9,
FrontierSWE 73.5 ([5]). Secondary write-ups additionally cite a **SWE-bench Verified ≈ 85.6** and
**OSWorld-Verified 86.1 / PaperBench 93.0** for Qwen3.8-Max, and note it *loses* SWE-bench Pro to
"Fable 5" by ~12 pts — those specific numbers are **corroborated-secondary only** ([10], [12], [13]),
not something I could pull from the first-party card, which does not headline SWE-bench Verified.

### vs the chapter's Qwen anchors

- No first-party figure lets you place Qwen3.8-27B on the **SWE-bench Verified** axis used for Qwen2.5-Coder-32B (69.6) and Qwen3-Coder-30B-A3B (51.6).
- The defensible statement: on Qwen's own agentic-coding suite under the Claude Code harness, **Qwen3.8-27B clearly exceeds Qwen3.6-27B**, which in turn was pitched as "flagship-level coding in a 27B dense model" ([1]). Any comparison to Qwen3-Coder-30B-A3B is **inferential**, not sourced.
- Third-party leaderboard placement (LMArena, Artificial Analysis) for Qwen3.8-27B specifically: not found in this pass; several aggregator blogs (BenchLM, Yotta Labs, NxCode) discuss it but are not primary and partly recycle the model-card table.

**Sourcing:** first-party for the Qwen3.8-27B and Qwen3.8-Max tables (HF model cards). SWE-bench
Verified ≈85.6 for Max and all "loses to Fable 5" framing: corroborated-secondary. Any
Qwen3.8-27B-vs-Qwen3-Coder-30B comparison: weak / inferential.

---

## Qwen3.8 on consumer GPUs

This is the practical core. Only **Qwen3.8-27B** is remotely a consumer target; the 2.4T-A95B is
datacenter-only.

### Weight-size arithmetic (27B dense, ~27.5–27.8 B params)

BF16 safetensors ≈ 55 GB. Common quants (bits-per-weight × params / 8, K-quant bpw approximate):

| Quant | ~bpw | Weights only | Notes |
|---|---|---|---|
| Q3_K_M | ~3.9 | ~13.5 GB | quality drop, GDN state sensitive (see below) |
| **Q4_K_M** | ~4.8 | **~16.5 GB** | matches measured "Q4_K Small ≈ 16.68 GiB" ([11]); Ollama default build ≈ 17.8 GB ([8]) |
| AWQ / INT4 (`cyankiwi/Qwen3.8-27B-AWQ-INT4`, [9]) | ~4.3 | ~14–15 GB | for vLLM/SGLang on GPU |
| Q5_K_M | ~5.5 | ~19 GB | |
| Q6_K | ~6.6 | ~22.7 GB | |
| Q8_0 | ~8.5 | ~29 GB | |
| FP8 (`Qwen/Qwen3.8-27B-FP8`, [9]) | 8 | ~27.5 GB | official; needs FP8-capable GPU (Ada/Hopper/Blackwell) |
| NVFP4 (`unsloth/Qwen3.8-27B-NVFP4`, [9]) | ~4.5 | ~15–16 GB | Blackwell (RTX 50xx) native 4-bit |

### KV cache — small, because of the hybrid architecture

Only **16 of 64 layers** carry a conventional KV cache (GQA, 4 KV heads × 256 head-dim). Per-token
KV ≈ 16 layers × 2 (K+V) × 4 × 256 × 2 bytes ≈ **64 KiB/token** at fp16:
- 32K ctx ≈ **2 GiB**, 64K ≈ 4 GiB, 128K ≈ 8 GiB, 262K ≈ 16 GiB.
- Community note corroborates *"KV cache of roughly 2 GB at 32K context — about a quarter of what a conventional 27B would need"* ([7]).
- The 48 Gated-DeltaNet layers keep only a small fixed-size recurrent state (no growth with context). This is the architecture's headline advantage for local long-context agent loops.

### Measured VRAM vs context (Q4_K_M, [11] Hardware Corner)

| Context | Total VRAM (weights + KV + overhead) |
|---|---|
| 4K–8K | ~18 GB |
| 16K | ~19 GB |
| 32K | ~20 GB |
| 64K | ~22 GB |
| 128K | ~26 GB |
| 256K | ~34 GB |

### Fit by tier

- **16 GB (RTX 4060 Ti 16G, 4070 Ti Super, Arc A770 16G):** Q4_K_M weights alone (~16.5 GB) already overflow. Only viable with **CPU offload of some layers** (slow) or an aggressive ~Q3 quant with tiny context. **Not a practical agent-loop target.** Run **Qwen3.6-35B-A3B** (MoE, ~3B active — see below) or **Qwen3-Coder-30B-A3B** instead here.
- **24 GB (RTX 3090 / 4090, RX 7900 XTX):** the sweet spot. Q4_K_M + **up to ~64K context** fits in ~22 GB ([11]). Q5_K_M fits with ~16–32K context. Enough headroom for real multi-file agent loops at 32–64K. This is the tier Qwen3.8-27B is *for*.
- **32 GB (RTX 5090):** Q4_K_M to **~128K context** (~26 GB, [11]); or Q6_K / FP8 / NVFP4 at moderate context. FP8 and NVFP4 are RTX-50xx-native. Comfortable agent use.
- **64–128 GB unified (Apple Silicon, DGX Spark):** Q6_K/Q8 or BF16-ish with full 262K context; `mlx-community/Qwen3.8-27B-4bit` and a `qwen3.8:27b-mlx` Ollama tag exist ([8], [9]). DGX Spark runs documented in secondary posts ([13]).

### Realistic tokens/sec (community / secondary — label as such)

All figures below are community reports, not vendor benchmarks:
- **RTX 3090**, Q4_K_M, llama.cpp: ~40 t/s @ 4K, ~34 t/s @ 64K ([11]); an independent bring-up post landed at **~42.9 t/s** with CUDA + FlashAttention + MTP after fixing a stale build ([7]).
- **RTX 4090**, Q4_K_M, llama.cpp: ~46 t/s @ 4K, ~38 t/s @ 64K ([11]); with **MTP self-speculative decoding** community reports **~65 t/s** decode ([6], [10]), and a heavily-tuned 4-bit-KV / MTP3 fork claims up to ~149 t/s on code ([6]).
- **RTX 5090**, Q4_K_M: ~75 t/s @ 4K, dropping to ~22–26 t/s at 128K ([11]); NVFP4 builds tuned for the 5090 exist (`gittensor-model-hub/Qwen3.8-27B-NVFP4-RTX5090`, [9]).
- **Dual RTX 5060 Ti (~32 GB combined):** ~22 t/s @ 4K ([11]).
- No solid RX 7900 XTX or Arc number found this pass; a `cafonez/Qwen3.8-27B-ROCmI4-MTP-GGUF` ROCm quant exists ([9]).

### MTP / self-speculative decoding

The MTP head is in the checkpoint, so both **vLLM** (`--speculative-config '{"method":"mtp","num_speculative_tokens":3}'`) and llama.cpp (MTP speculative decoding merged ~2026-05-16 for the qwen3_5 family) can use it with **no draft model** ([6], [14]). Community and vendor material cite **≈2× throughput / ≈1.88× lower latency** from MTP ([6]). Many community GGUF repos ship `-MTP` variants; there are also `MTP-ONLY` GGUFs (draft head only) meant to pair with a base quant ([7], [9]).

### Quantization caveat specific to this architecture

Gated-DeltaNet **SSM state (`ssm_alpha` / `ssm_beta`) is disproportionately sensitive to low-bit
quantization**; generic IQ2/UD-IQ2 recipes that don't treat the GDN mixers as first-class degrade
output badly ([7]). Stick to **Q4_K_M or higher** and to uploaders who special-case the hybrid
layers (unsloth Dynamic, and the `-MTP`-aware community quants). Below Q4 the model gets unreliable
for tool-calling.

### Is it usable in an agent loop at consumer tiers?

- **24 GB / Q4_K_M / ≤64K context:** yes — tool-calling reliability is a headline design goal ("Agent Execution", "Downstream Compatibility" with popular harnesses, [2][3]), the hybrid KV cache makes 32–64K context affordable, and Qwen ships **Qwen Code** as a matched CLI harness. Decode ~35–46 t/s (3090/4090) is workable for interactive agent turns, faster with MTP.
- **32 GB:** same, up to ~128K context.
- **16 GB:** not really — you're weight-bound before context. Use a ~3B-active MoE instead.

### If Qwen3.8's smallest open variant is too large: what to run instead

On 8–16 GB, the current Qwen recommendation for agentic coding is the **MoE** route:
- **Qwen3.6-35B-A3B** (2026-04-16, MoE, ~3B active, open weights, *"Agentic Coding Power, Now Open to All"*, [1]) — MoE streams only active experts, tolerates CPU offload of idle experts far better than a 27B dense model. Prior pass's Reddit anecdote: ~60–70 t/s on an Arc GPU for the A3B MoE vs ~24–28 t/s for a dense 27B-class model.
- **Qwen3-Coder-30B-A3B-Instruct** (chapter anchor: 30.5B/3.3B active, 262K context, Apache 2.0, 51.6% SWE-bench Verified) — still the reference "fits a 24 GB card comfortably, degrades gracefully to 16 GB + offload" agentic-coding local model.
- **Qwen3.6-27B** (dense) if you specifically want the 3.6 dense line at ~the same footprint as 3.8-27B but slightly lower agentic scores.

**Sourcing:** weight arithmetic and architecture-driven KV math derived from primary config ([4]);
measured VRAM/context table and all tokens/sec: **corroborated-secondary** (Hardware Corner, GitHub
bring-up discussion, X/Twitter posts, community forks). GDN quant-sensitivity: weak-to-secondary
(one detailed community discussion, [7]). Fallback-model recommendation: primary for model
existence/labels ([1]), inferential for the "run this instead" conclusion.

---

## Qwen3.8 licensing and availability

### License

- **Qwen3.8-27B: Apache 2.0** — confirmed in the model card YAML front-matter (`license: apache-2.0`) and card body ([3]). Consistent with the Qwen open-weight norm. Ungated on HF (no click-through).
- **Qwen3.8-2.4T-A95B: NOT Apache 2.0.** Card front-matter is `license: other`, `license_name: qwen3.8-max`, with a bundled `LICENSE` file ([5], [15]). The "Qwen3.8-Max License" is MIT-style permissive text (use/copy/modify/host/fine-tune/sell allowed) **with two commercial carve-outs**: (1) products with >100 M MAU or >US$20 M monthly revenue must prominently display the model name; (2) a "Model as a Service" or "AI Work Assistant" business with >US$50 M revenue over any 12 months must obtain a separate license from Qwen before commercial use ([15]). Not OSI-approved, but unrestrictive for essentially all local/self-hosted developer use.
- No first-party evidence of any Qwen3.8 open variant being fully closed / weights-withheld. The API-only tiers (Qwen3.8-Max hosted, Qwen3.7-Plus/Max) simply have no weight release.

### Hugging Face repos (first-party, collection `Qwen/qwen38`, [9])

`Qwen/Qwen3.8-27B`, `Qwen/Qwen3.8-27B-FP8`, `Qwen/Qwen3.8-2.4T-A95B`, `Qwen/Qwen3.8-2.4T-A95B-FP8`.
No first-party GGUF, AWQ, or Base repo. Model class `Qwen3_5ForConditionalGeneration`,
`transformers >= 5.8.0.dev0` ([4]).

### Community quant uploaders (secondary, via HF model-search API, [9])

Active within ~2 weeks of release:
- **unsloth** — `unsloth/Qwen3.8-27B-GGUF` (very high downloads), `unsloth/Qwen3.8-27B-NVFP4`. Unsloth also has an official "Qwen3.8 guide" page ([1]).
- **GGUF:** `Jackrong/Qwen3.8-27B-MTP-GGUF`, `AtomicChat/…`, `empero-ai/…-Ridge-GGUF`, `mradermacher/…-GGUF`, `vcruz305/…`, many `-MTP` / `MTP-ONLY` builds, plus a large crop of "uncensored/abliterated" derivatives (orcarouter, huihui-ai, JonathanColetti, etc.).
- **AWQ:** `cyankiwi/Qwen3.8-27B-AWQ-INT4`. **NVFP4:** `RadixArk/…`, `gittensor-model-hub/…-RTX5090`, `QUASAR-QAT/…`. **exllamav3:** `turboderp/Qwen3.8-27B-exl3`. **MLX:** `mlx-community/Qwen3.8-27B-4bit`, `orcarouter/…-MLX`. **ROCm:** `cafonez/Qwen3.8-27B-ROCmI4-MTP-GGUF`.
- bartowski: not seen in the top-50 search slice this pass (does not mean absent).

### Ollama

Official library entry **`ollama.com/library/qwen3.8`** is live: tags `qwen3.8:27b`, `qwen3.8:latest`
(~17.8 GB Q4 build with vision), and `qwen3.8:27b-mlx` for Apple Silicon ([8]). `ollama run
qwen3.8:27b` works. (Secondary source; not verified against the Ollama registry API in this pass.)

### ModelScope

First-party: `modelscope.cn/collections/Qwen/Qwen38` for both checkpoints ([1]). SGLang/vLLM can
pull from ModelScope via `SGLANG_USE_MODELSCOPE=true` / `VLLM_USE_MODELSCOPE=true` ([1]).

### Engine / loader support (does it need a new loader, like Qwen3-Next did?)

The architecture is **`qwen3_5`** (hybrid Gated-DeltaNet + Gated-Attention + MTP), so it needs the
same loader support Qwen3.5/Qwen3-Next required — **not a brand-new one for 3.8 specifically**, but
newer than pre-2026 builds:
- **vLLM** — supported; first-party "Qwen3.8 Recipe" at recipes.vllm.ai; MTP speculative decoding via `--speculative-config` ([1], [3], [6]).
- **SGLang** — supported; first-party "Qwen3.8 Cookbook"; launch flags include `--reasoning-parser qwen3 --tool-call-parser qwen3_coder` ([1], [3]).
- **TokenSpeed** — first-party recipe ([1], [3]).
- **llama.cpp** — supports the Qwen3.5 open series "text & vision" per the repo ([1]). **Date-sensitive:** a community bring-up (GitHub Discussion #27164, [7]) shows Qwen3.8-27B produced garbage output on a llama.cpp build from before ~build 10450 due to a broken CUDA Gated-DeltaNet path; updating to a current master fixed it (clean output, ~42.9 t/s on a 3090). Use an August-2026-or-later build.
- **MLX** — `mlx-lm` (text) and `mlx-vlm` (vision) support the Qwen3.5 series ([1]); community 4-bit MLX repos exist.
- **transformers** — `transformers serve Qwen/Qwen3.8-27B` documented; requires `transformers >= 5.8.0.dev0` ([1], [4]).
- **exllamav3** — community `turboderp/Qwen3.8-27B-exl3` exists ([9]).

**Sourcing:** primary-sourced for licenses (card front-matter + `LICENSE` files), first-party HF
repos, engine support (repo + first-party recipe/cookbook links), ModelScope. Community uploader
list and Ollama tags: corroborated-secondary. llama.cpp version caveat: corroborated-secondary (one
detailed discussion thread).

---

## Sources

1. Qwen3.8 GitHub repository README — `https://github.com/QwenLM/Qwen3.8` (raw: `https://raw.githubusercontent.com/QwenLM/Qwen3.8/main/README.md`). News/dates, model list, blog BibTeX, deployment sections, license pointer.
2. Qwen blog, *"Qwen3.8-Max: A New Bar for Coding and Cowork"* — `https://qwen.ai/blog?id=qwen3.8` (JS SPA; contents accessed via [1], [3], [5] which mirror them).
3. Hugging Face model card — `https://huggingface.co/Qwen/Qwen3.8-27B` (raw: `/raw/main/README.md`). Architecture overview, benchmark tables + footnotes, YaRN config, sampling params, thinking/instruct modes.
4. `Qwen/Qwen3.8-27B/config.json` — `https://huggingface.co/Qwen/Qwen3.8-27B/raw/main/config.json`. Layer types, head counts, MTP fields, vision config, `Qwen3_5ForConditionalGeneration`.
5. Hugging Face model card — `https://huggingface.co/Qwen/Qwen3.8-2.4T-A95B` (raw: `/raw/main/README.md`). MoE spec (2.4T/95B, 512 experts, 10+1 active), Max-tier framing, benchmark table.
6. vLLM Qwen3.8-27B recipe / SGLang docs / MTP speculative-decoding notes — `https://recipes.vllm.ai/Qwen/Qwen3.8-27B`, `https://docs.sglang.io/cookbook/autoregressive/Qwen/Qwen3.8-27B`, `https://docs.vllm.ai/en/latest/features/speculative_decoding/`; MTP throughput/latency claims (~2× / ~1.88×). Also `https://github.com/sergiuszm/ninfer-4090` (tuned 4090 fork).
7. llama.cpp GitHub Discussion #27164, *"My issues … to get Qwen3.8-27B … to work with Llama.cpp"* — `https://github.com/ggml-org/llama.cpp/discussions/27164`. Stale-build CUDA/Gated-DeltaNet bug, fix commit range, ~42.9 t/s on RTX 3090, MTP-ONLY GGUFs, GDN state quant sensitivity.
8. Ollama library — `https://ollama.com/library/qwen3.8` (tags `27b`, `latest`, `27b-mlx`; ~17.8 GB Q4 build). Via secondary write-ups (yottalabs, sitepoint, mindstudio).
9. Hugging Face model-search API for `Qwen3.8-27B` — `https://huggingface.co/api/models?search=Qwen3.8-27B` and collection `https://huggingface.co/collections/Qwen/qwen38`. First-party repos (27B, 27B-FP8, 2.4T-A95B, 2.4T-A95B-FP8) + community quants (unsloth GGUF/NVFP4, cyankiwi AWQ-INT4, turboderp exl3, mlx-community 4bit, Jackrong/AtomicChat/mradermacher GGUF, ROCm, RTX5090 NVFP4, etc.).
10. Latent Space / AINews, *"Qwen 3.8 Max(2.4T) and 27B, new open weights models for Coding and Cowork"* — `https://www.latent.space/p/ainews-qwen-38-max24t-and-27b-new`. Secondary summary.
11. Hardware Corner, *"We Tested Qwen3.8 27B: How Much GPU and VRAM Do You Really Need?"* — `https://www.hardware-corner.net/qwen3-8-27b-hardware-tests/`. Q4_K_M VRAM-vs-context table; 3090/4090/5090 tokens/sec.
12. Yotta Labs, *"Qwen 3.8 27B: Specs, Hardware Requirements…"* and *"…Benchmarks: What's Actually Verified So Far"* — `https://www.yottalabs.ai/post/qwen-3-8-27b-specs-hardware-requirements-how-to-run-2026`, `https://www.yottalabs.ai/post/qwen-3-8-benchmarks-what-is-verified-2026`. Secondary; ~27.78 B checkpoint, SWE-bench Verified ≈85.6 for Max.
13. DataCamp, *"Qwen3.8-Max: Features, Benchmarks, and Pricing"* — `https://www.datacamp.com/blog/qwen3-8-max`; Kubesimplify DGX Spark post — `https://blog.kubesimplify.com/qwen3-8-27b-on-dgx-spark`; Codersera *"Qwen 3.8 Max … Why the Benchmarks Reverse"* — `https://codersera.com/blog/qwen-3-8-max-complete-guide-2026/`. Secondary; Max license/benchmark framing.
14. llama.cpp Qwen3.5 architecture / MTP speculative-decoding merge history — via `https://buttondown.com/insiderllm/archive/this-week-in-local-ai-llamacpp-gets-mcp-qwen3/` and `https://github.com/abetlen/llama-cpp-python/issues/2137`. Secondary; "qwen35" architecture support, MTP merged ~2026-05-16.
15. `Qwen/Qwen3.8-2.4T-A95B/LICENSE` — `https://huggingface.co/Qwen/Qwen3.8-2.4T-A95B/raw/main/LICENSE`. "Qwen3.8-Max License" full text; MAU/revenue carve-outs.
