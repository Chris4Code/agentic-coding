# 2026-09-03 · run 1 · security-chapter-deep-research

**Skill:** deep-book-research (+ in-session drafting per skill step 8)
**Chapter:** src/security.md
**Scope:** whole chapter — every existing section header (many are bare stubs) drives one research pass

## Follow-up drafting (same run, later prompts)

After the research + summary were filed, the user asked to draft the chapter from the notes, in
three parts: (1) "start with the Identity/Agent-IDs/RBAC arc", (2) "go on with prompt-injection and
Workspace Containers", (3) "finish those two" (Audit Logs, Privacy Gateways). All of `src/security.md`
was drafted from this run's `raw-*` / `summary-*` / `factcheck-*` notes plus the fact-check
corrections; `src/glossary.md` updated in the same change. Headline changes made: `## Identity` →
`## Agent Identity`; `### Agent IDs` → `### Identity Provisioning and Standards`;
`### Role management and RBAC` → `### Role Management and Access Control`;
`# How to handle Prompt Injections` → `## Handling Prompt Injection` (also fixed a stray H1);
`### Dual-LLM Pattern` → `### The Dual-LLM Pattern and CaMeL`;
`### Heuristic Content Segregation` → `### Spotlighting and Content Delimiters`.

## Trigger

User request: "please do a deep-book-research for the `security.md` chapter".

## Seed

No source URL and no explicit subtopic list given. Subtopic breakdown taken from
`src/security.md`'s own section headers (`##`/`###`) in document order, per the skill's
"chapter-file given" path. The chapter is currently almost entirely stub headers plus
`<!-- CONTENT-KEY-SUBJECTS -->` planning comments — those comments were read to sharpen the
research brief for each subtopic but the header text is what defines the subtopic list.

## Subtopic list (research order)

1. Workspace Containers — sandboxing/isolation for agent workspaces
2. Identity — why agents accessing intranet services need identities; deriving/integrating agent
   IDs into existing enterprise and small-company IAM
3. Agent IDs — SCIM (System for Cross-domain Identity Management), IETF SCIM agent extensions,
   public DLTs as an identity substrate
4. Role management and RBAC — RBAC for agentic factories/workflows; project-level vs company-wide
   RBAC; integrating agent RBAC into existing enterprise / small-company RBAC infrastructure
5. How to handle Prompt Injections — what a prompt injection is; why it cannot easily be
   prevented (no separated control/data processing in LLMs)
6. Dual-LLM Pattern — quarantined vs privileged model split
7. LLM Firewalls — AI Gateway / semantic firewall doing real-time async checks on inputs and
   outputs; jailbreak detection via regex vs lightweight specialized classifier models
8. Zero-Trust for AI Agents — runtime privilege separation, strict tool schemas, least-privilege
   credential scoping, blast-radius containment
9. Heuristic Content Segregation — data spotlighting / delimiters and their limits
10. Audit Logs — logging agent actions/decisions for forensics and compliance
11. Privacy Gateways — local-LLM prompt sanitizing before cloud LLM use; data masking / PII
    redaction

## Prior art consulted

- `notes/initial-notes/security - prompt injection.md` (untracked at run start) — Gemini chat
  covering the architectural why (unified token stream, attention, KV cache is not a security
  boundary), the Dual-LLM pattern, LLM firewalls, zero-trust tool boundaries, heuristic content
  segregation, and an open-source firewall toolkit survey (NeMo Guardrails, LLM Guard, Guardrails
  AI, Llama Firewall / Prompt Guard, Garak, Promptfoo). Passed to the research agent as the
  baseline for subtopics 5–9 to extend and independently corroborate.
- `notes/initial-notes/identity.md` — Gemini chat on SCIM in agentic workflows, the IETF
  "SCIM Agents and Agentic Applications" draft (`/Agents`, `/AgenticApplications` schemas),
  and SCIM-vs-MCP framing. Baseline for subtopics 2–3.
- `notes/2026-08-30-1-local-models-agent-sandbox-landscape-research/` (raw + summary) — full
  agent-sandbox landscape and isolation-technology spectrum (containers → gVisor → Kata /
  Firecracker micro-VM), self-hosting/BYOC options, egress allow-lists. Baseline for subtopic 1
  so this pass frames the security angle rather than re-deriving the vendor map.
- `notes/2026-08-29-3-local-models-frontends-proxies-terminals-security/` (summary) — LiteLLM /
  Langfuse control + observability plane, virtual keys, Enterprise guardrails / data-masking /
  audit-logs / SCIM, OWASP LLM Top 10 framing. Baseline for subtopics 7, 10, 11.
- `src/security.md` current content and its `<!-- CONTENT-KEY-SUBJECTS -->` planning comments.
