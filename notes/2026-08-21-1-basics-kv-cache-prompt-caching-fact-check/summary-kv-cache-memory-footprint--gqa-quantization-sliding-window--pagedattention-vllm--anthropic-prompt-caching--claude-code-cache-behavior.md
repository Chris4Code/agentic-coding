# Summary: Fact-check of `src/basics.md`

Distilled index for [`raw-kv-cache-memory-footprint--gqa-quantization-sliding-window--pagedattention-vllm--anthropic-prompt-caching--claude-code-cache-behavior.md`](./raw-kv-cache-memory-footprint--gqa-quantization-sliding-window--pagedattention-vllm--anthropic-prompt-caching--claude-code-cache-behavior.md) — a corroboration pass for `src/basics.md` (KV cache, prompt caching, context/loop engineering), which was originally drafted purely from one ungrounded Gemini "deep research" chat (`notes/initial-notes/Token Cache ⁄ KV-Cache and Prompt-Caching.md`, `notes/initial-notes/Context engineering.md`) with no independent verification at the time.

**This file is a map, not the source.** Exact figures, quotes, and citation links live only in `raw.md`. Confidence tags: 🟢 primary / 🟡 corroborated-secondary / 🟠 single-source / ⚪ could not be corroborated.

## Per-subtopic findings — compressed

- 🟢 **KV cache formula & Llama 3 8B example numbers** (131 KB/token, 1.05 GB @ 8k, 16.8 GB @ 128k) — arithmetic independently re-derived and confirmed exactly. Llama 3 8B's architecture parameters (32 layers, 8 KV heads, head dim 128) are consistent across multiple independent secondary sources; Meta's own gated config file wasn't directly fetchable (HTTP 401), but nothing contradicts the figures.
- 🟢 **GQA / KV-cache quantization / Blackwell FP4-FP8** — the GQA paper itself ([Ainslie et al.](https://arxiv.org/abs/2305.13245)) confirms <1% quality loss under GQA-8, directly backing "quality drops only slightly." NVIDIA's own docs confirm Blackwell's 5th-gen Tensor Cores are the first to natively support FP4, directly backing that specific claim.
- 🟢 **PagedAttention / vLLM — went from the chapter's weakest link to its best.** The original note cited only a milvus.io blog; the primary paper ([Kwon et al., SOSP '23](https://arxiv.org/abs/2309.06180)) was fetched directly and its own Figure 2 gives near-exact matches for "60–80% waste" (paper: 61.8–79.6%), "under 4% waste" (paper: 3.7%), and "2–4× throughput" (a direct quote from the abstract).
- 🟢 **Anthropic prompt caching mechanics & the "10%"/90%-discount pricing figure** — confirmed exactly against Anthropic's current official docs. Not an approximation; it's Anthropic's own stated rate.
- 🟢🟡 **Claude Code cache behavior — mostly confirmed, two corrections applied to the chapter:**
  - The layered payload, `<system-reminder>` file-edit handling, and delayed `/config`/CLAUDE.md application are confirmed almost verbatim against Anthropic's current docs and engineering blog.
  - **Correction made**: the chapter's blanket claim that connecting/disconnecting an MCP server "forces a full cache miss" is now outdated — current docs say this only happens when a server's tools aren't deferred via tool search, which is the default on supported models. Chapter text updated to reflect the conditional behavior.
  - **Correction made**: "extended-thinking budget" is not current terminology; current docs use **effort level** (`/effort`) for the setting that busts the cache on change. Chapter text updated.
  - A `/compact` nuance was tightened: the compaction *request itself* is a cache hit, but the *resulting* shorter history starts a fresh cache going forward — the chapter's original wording could be read as implying full cache-neutrality.
- 🟠/⚪ **Context/loop-engineering savings percentages — the chapter's weakest subtopic, several corrections applied:**
  - **"~60% communication tax"** matched unusually well against an academic source ([arXiv:2601.14470](https://arxiv.org/html/2601.14470v1): Code Review phase = 59.4% of tokens). 🟠 single academic source, but a close, direct numeric match — kept in the chapter with a Research Note.
  - **"Prompt caching 60–90%"** and **"JIT context 50–70%"** table rows have genuine (if single-source) supporting data points (a TrueFoundry case study found 57% JIT savings). Kept, flagged as single-source in a Research Note.
  - **"State compaction 40–60%" — not corroborated.** Independent figures cluster lower (20–30%, per production write-ups and one academic pattern reporting 29.68%). **Chapter table corrected to reflect this lower, better-supported range.**
  - **"Subagent splitting → up to 15x savings" — found to be a likely inversion of a real number.** Anthropic's own well-known figure is that multi-agent systems use **~15× more tokens** than single-agent chat (a *cost*, per [Anthropic's multi-agent engineering post](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them)) — not a savings multiplier from delegation. **Chapter table corrected** to drop the misattributed "15x" figure and describe the real, separately-confirmed mechanism (subagents return condensed ~1,000–2,000-token summaries instead of full context) without inventing a replacement multiplier.

## Open-Claw / Hermes Agent verdict

**Both are real products, not hallucinations** — a partial correction to this task's own starting hypothesis. OpenClaw (Peter Steinberger's project, formerly Warelay/Clawdbot/Moltbot) and Hermes Agent (Nous Research, Feb 2026) both exist with real docs and large adoption. However, **neither is actually a coding harness** — both are general-purpose, messaging-platform-first personal AI assistants — and the specific numeric architectural claims the original note attached to them (a fixed "25 sections," "9-layer prompt composition," "progressive 3-tier skill disclosure," "up to 75% cost reduction") could **not** be found in either product's own primary documentation; they appear to be invented specifics layered onto real product names by the original ungrounded chat.

`src/basics.md` never names either product and only generalizes the qualitative pattern (cache boundaries, progressive disclosure, mid-session freezing, append-only history) — so the chapter's own text was never directly contaminated by the fabricated numbers. That said, the generalization is better understood as corroborated by **Claude Code's own primary documentation** (which matches almost exactly) than by Open-Claw/Hermes, whose real docs only loosely support the same shape.

## What this means for `src/basics.md`

Applied directly to the chapter in this pass:
1. Corrected the MCP-server and "extended-thinking budget" claims in **Claude Code specifics** to match current documented behavior (conditional MCP cache impact; "effort level" terminology).
2. Tightened the `/compact` bullet to note that compaction resets the cache going forward even though the compaction request itself is a cache hit.
3. Corrected the **loop engineering** cost-impact table: lowered "state compaction" to the better-supported ~20–30% range, and replaced the misattributed "up to 15x" subagent-splitting figure with an accurate, non-quantified description of the real mechanism.
4. Added `Research Note:` paragraphs (per `CLAUDE.md` convention — only where corroboration is partial/single-source, not for the strongly-corroborated majority of the chapter) after the loop-engineering intro and table, and a brief one on the Open-Claw/Hermes-Agent generalization in the harness-patterns section.
