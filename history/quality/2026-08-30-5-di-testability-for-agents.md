# 2026-08-30 · Run 5 · quality · di-testability-for-agents

**Type:** deep-book-research pass + section addition to `src/quality.md`.

**Triggering request:** the user asked whether Dependency Injection for testability is worth a
section in `quality.md`. Assessment: worth a subsection (not a standalone top-level section),
placed under "Testing: the oracle problem", because the causal chain is
untestable code → over-mocked / tautological agent tests → weak oracle. User approved a research
pass + a `### Designing for testability` subsection.

**Seed:** the existing "Testing: the oracle problem" section of `src/quality.md` (its
"Keeping the oracle out of the agent's hands" subsection in particular), plus the chapter's
recurring "deterministic guardrails + rules file" and "no fast reward signal for maintainability"
threads.

**Prior art consulted:**
- `src/quality.md` after runs 1–4 (oracle problem, mutation/property testing, structural-quality metrics, CI enforcement).
- `notes/2026-08-30-1-quality-agentic-qa-methods-deep-research/` — oracle-problem and test-tampering material.
- Runs 2–4 notes (DbC, CI, C/C++) for the guardrail / rules-file framing.

**Subtopics targeted:**
1. Agents default to untestable coupling — hard-coded construction, direct I/O, static calls, singletons; the maintainability-signal argument applied to testability.
2. Over-mocked agent tests — the empirical evidence that agents mock more than humans and produce more brittle, less meaningful tests.
3. DI as an architectural guardrail — constructor injection, ports & adapters / hexagonal, thin-shell/rich-core; deterministic enforcement (ArchUnit / import-linter / dependency-cruiser).
4. Prefer real fakes / testcontainers over mocks — sociable vs solitary tests; why "add DI" pushed naively worsens the over-mock problem.
5. DI container magic vs explicit wiring — implicit, non-local wiring as a comprehension cost for agents (and humans); "explicit is better than implicit."

**Output:** `notes/2026-08-30-5-quality-di-testability-for-agents/` (`raw-*` + `summary-*`), plus a
new `### Designing for testability` subsection under "Testing: the oracle problem" in
`src/quality.md`, with any matching glossary entries.
