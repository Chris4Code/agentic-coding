# 2026-08-30 · Run 1 · quality · agentic-qa-methods-deep-research

**Type:** `deep-book-research` skill run against `src/quality.md`.

**Triggering request:** "Please do a deep book research for the `quality.md` chapter."

**Seed:** The `quality.md` chapter is a stub — no section headers, only a `CONTENT-KEY-SUBJECTS`
planning comment listing intended quality aspects, methods, tools, and challenges. The subtopic
list below was derived from that comment and confirmed with the user ("Proceed as listed").

**Prior art consulted:**
- `notes/initial-notes/CI-CD.md` — platform-agnostic CI/CD tooling, Dagger vs Jenkins DSL comparison.
- `notes/2026-08-17-1-sw-factories-dex-horthy-deep-research/` — code-review-failure story (lights-off
  experiment), Faros AI telemetry on review-skipping, leverage-point model, model training
  limitations (no reward signal for maintainability).
- `notes/initial-notes/Software Factory.md`, `notes/initial-notes/Agent Factory loops.md` — factory loop context.

**Subtopics targeted (one research pass each, in order):**
1. "More code, less understanding" — review/comprehension debt when agents outproduce human review capacity
2. Code review & walkthroughs, adapted for agent output — AI-assisted review, diff triage, review-gating in the loop
3. Static analysis & linters as agent guardrails — feeding linter/type-checker output back into the agent loop; SAST
4. Automated test generation & the oracle problem — agents writing their own tests, over-fitting, assertion-free tests, coverage gaming
5. Integration / system / E2E testing with agent harnesses — browser automation (Playwright/computer-use), self-healing tests
6. Acceptance testing & A/B comparison via feature flags — evaluating agent-generated features in production
7. Non-functional testing — performance, load, security testing in agentic workflows
8. Design by Contract for agents — contract injection, spec-driven generation, automated contract/property-based testing
9. CI/CD as the enforcement layer — quality gates, merge queues, pre-merge agent verification
10. Structural quality & maintainability metrics — complexity, code smells, duplication, churn; measuring codebase erosion over time
11. Quality frameworks & language-specific QA tooling — SonarQube-style platforms, ecosystem tools wired into agent workflows

**Output:** `notes/2026-08-30-1-quality-agentic-qa-methods-deep-research/`
(`raw-*` + `summary-*` pair, subtopics-slug built from subtopics 1–5).
