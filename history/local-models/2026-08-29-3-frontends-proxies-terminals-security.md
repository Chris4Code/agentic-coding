# 2026-08-29 · run 3 · frontends-proxies-terminals-security

**Skill:** deep-book-research
**Chapter:** src/local-models.md
**Scope:** pass 3 of the chapter split. This pass: UI frontends, proxies/routers, on-prem agent sandbox / terminal tooling, security + key management.

## Trigger

Same triggering request as runs 1 and 2 (`deep-book-research` for the topics described in `src/local-models.md`). Final pass of the chapter split.

## Input materials

- `src/local-models.md` — chapter outline: `## UI Frontends`, `## Proxies and Routers`, `## On Premise Agent Sandbox Cloud Service`, `## Security + Key Management` sections and `CONTENT-KEY-SUBJECTS` comments (the terminal comment lists: Warp (Oz), Ghostty, Alacritty, WezTerm).
- `notes/initial-notes/Local Modells - Models, SW and AI-GPUs.md` — prior manual research: LM Studio backends (llama.cpp + Apple MLX), Open WebUI, OpenRouter vs LiteLLM vs Open WebUI comparison (roles, hosting, fees, data privacy).
- `notes/initial-notes/harnesses.md` and `notes/2026-08-21-1-agentic-coding-harnesses-harness-mcp-fact-check/` — prior art on terminal-first dev agents; check for overlap on terminal emulators / agent sandboxes.

## Subtopics targeted (this pass)

1. LM Studio — local model UI, llama.cpp + MLX engines, OpenAI-compatible server, MCP support
2. Open WebUI — self-hosted chat frontend, backends (Ollama / OpenAI-compatible), RAG, user management
3. OpenRouter — cloud model aggregator, unified API, failover routing, fee structure, data-routing/privacy
4. LiteLLM + Langfuse — self-hosted API gateway (100+ providers, budgets, fallbacks) paired with Langfuse for LLM observability/tracing/eval
5. Bring Your Own LLM / BYO-key — pattern of pointing agentic coding tools at a self-hosted or arbitrary OpenAI-compatible endpoint; anthropic-compatible endpoints
6. On-premise agent sandbox / terminal tooling — Warp (and "Oz" agent mode), Ghostty, Alacritty, WezTerm: GPU-accelerated terminals, agent integration, sandboxing for autonomous agents
7. Security + key management — API key storage/rotation, secrets managers, network isolation for self-hosted inference, data governance for local vs cloud models
