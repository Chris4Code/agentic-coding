---
run: fact-check
chapter: agentic-coding-harnesses
date: 2026-08-21
inc-num: 1
topic-slug: harness-mcp-fact-check
---

## Triggering request

User: "Please do fact check for agentic-coding-harnesses.md now" — a continuation of the ongoing chapter-by-chapter fact-check pass (after `basics.md` and `rags.md`), applying the `fact-check` skill to the third and last of the originally-identified chapters with zero `Research Note:` paragraphs.

## Scope

Whole chapter (no `scope` argument given). User was asked to confirm scope given the chapter's size (~10 distinct checkable subtopic clusters, well past the skill's "confirm if >8" threshold) and chose "whole chapter, one pass" over splitting into two runs.

## Subtopics identified (step 2)

Grouped in document order, tracking the chapter's own section structure:

1. Terminal-first dev agents landscape — OpenCode/OpenWork, Goose, Aider, Pi/Kilo CLI, OpenAI Codex, Cursor & Windsurf (Devin Desktop) claims (## Terminal-First Dev Agents)
2. Server-side orchestrators landscape — OpenClaw, DeerFlow, Symphony, Perplexity Computer, Claude Cowork/Manus claims (## Existing Agent Coding solutions)
3. Hermes Agent internal architecture — the `hermes-agent/` file-layout diagram and per-block claims (`run_agent.py`, `model_tools.py`, `toolsets.py`, `context_engine.py`, `context_compressor.py`, `hermes_state.py`, `~/.hermes/skills/`, `prompt_builder.py`) across Central Control Loop, Tool Registry & Dispatcher, Context & Token Manager, Session Persistence, Guardrails & Token Budgeting, and Dynamic Memory (## Main Components of a Harness)
4. Language Server Protocol (LSP) & Agent Client Protocol (ACP) — origin, JSON-RPC methods, ACP distinction (### Language Server Protocol (LSP))
5. Model Connector — OpenCode's Go-based `internal/llm` abstraction, Claude Code's hardcoded Anthropic connector (### Model Connector)
6. MCP fundamentals — introduction date/vendor, JSON-RPC 2.0, host/client/server architecture, three primitives (### What is MCP)
7. REST/OpenAPI MCP translation tooling — `@modelcontextprotocol/server-openapi`, `openapi-mcp` (#### REST + OpenAPI)
8. GraphQL MCP translation tooling — `graphql-mcp`, Apollo AI Gateway, `mcp-graphql` (#### GraphQL)
9. gRPC MCP translation tooling — Redpanda's `protoc-gen-go-mcp`, `grpcmcp` (adiom-data), ggRMCP Gateway, ConnectRPC (#### gRPC)
10. Human-vs-Machine CLI/MCP generation tooling — LobeHub CLI-as-MCP, `mcp-cli-adapter`, FastMCP `generate-cli`, MCPLI, Apify `mcpc` (### Human-vs-Machine Developer Experience)

## Prior art consulted (step 3)

The entire chapter traces back to a single source with no independent verification since: `notes/initial-notes/harnesses.md`, `notes/initial-notes/Hermes.md`, `notes/initial-notes/MCP.md`, and `notes/initial-notes/MCP vs CLI.md` — four ungrounded Gemini "deep research" chats whose own citation trails are almost entirely secondary blogs (mindstudio.ai, aembit.io, composio.dev, lobehub.com, etc.), not primary vendor docs, specs, or repos. No later `deep-book-research`/`edit-chapter`/`fact-check` pass had previously touched this chapter (confirmed via repo-wide grep — no `Research Note:` paragraphs existed in `src/agentic-coding-harnesses.md` before this run).
