# 2026-08-29 · run 5 · agentic-coding-benchmarks-research

**Skill:** deep-book-research
**Chapter:** src/local-models.md
**Scope:** research to seed a new `## Benchmarks` section — the important benchmarks, how to run them, and the two aggregator sites (artificialanalysis.ai, lmarena.ai).

## Trigger

User asked: "add a 'Benchmarks' section to the chapter briefly describing the most important benchmarks and how to run them. Also describe artificialanalysis.ai and arena.ai." ("arena.ai" understood as lmarena.ai, the former LMSYS Chatbot Arena.)

## Input materials

- `src/local-models.md` (current) — `## Models` section already names, without describing: SWE-bench Verified, SWE-bench Pro, Terminal-Bench, Aider polyglot, LMArena, Artificial Analysis; and the "Open LLM Leaderboard retired March 2025" fact.
- `notes/2026-08-29-2-local-models-local-models-quantization-moe/` — established the leaderboard-retirement → LMArena / Artificial Analysis / task-benchmarks framing; per-model SWE-bench Verified numbers.
- `notes/2026-08-29-4-local-models-qwen3-8-consumer-gpu-research/` — surfaced the 2026 agentic-coding benchmark spread (SWE-bench Pro, in-house QwenSWEBench, DeepSWE 1.1, Terminal-Bench 2.1 "Terminus", NL2Repo-Bench, LiveCodeBench v6, OSWorld-Verified) and the "run under the Claude Code harness at 256K ctx" methodology point.
- `notes/2026-08-17-1-sw-factories-dex-horthy-deep-research/` and `notes/2026-08-18-2-sw-factories-software-factory-models-corroboration/` — the benchmark reward-hacking / weak-test-oracle literature (arXiv 2606.16062; Poolside, Cursor studies; SWE-Marathon), already written into `src/sw-factories.md`. The new section should cross-reference, not duplicate.

## Subtopics targeted (in order)

1. The most important LLM / agentic-coding benchmarks in 2026 — what each measures, saturation status, contamination-resistance (SWE-bench + Verified/Pro/Multimodal, SWE-rebench / SWE-bench-Live, Terminal-Bench 1.0 / 2.1, Aider polyglot, LiveCodeBench, BigCodeBench, HumanEval/MBPP legacy, OSWorld; reasoning-adjacent GPQA Diamond / AIME).
2. Running benchmarks yourself — the official harnesses and how they work (SWE-bench Docker harness + `sb-cli` + an agent scaffold; `terminal-bench` / `tb run`; the Aider polyglot benchmark harness; `lcb_runner` for LiveCodeBench), and pointing a harness at a local OpenAI-compatible endpoint (llama.cpp / vLLM) to score a local model.
3. artificialanalysis.ai — what it is, the Intelligence Index, the independently-measured throughput/latency/price-per-endpoint data, coding-specific indices, methodology and limitations.
4. lmarena.ai (formerly LMSYS Chatbot Arena / "arena.ai") — crowdsourced pairwise human-preference voting, Bradley-Terry/Elo ranking, style control, the sub-arenas (WebDev Arena, Copilot Arena, text/vision/search), strengths and known biases.
5. Benchmark contamination and reward hacking (brief) — why local/self-hosters should read benchmark numbers skeptically; cross-reference `src/sw-factories.md`'s existing treatment rather than repeating it.
