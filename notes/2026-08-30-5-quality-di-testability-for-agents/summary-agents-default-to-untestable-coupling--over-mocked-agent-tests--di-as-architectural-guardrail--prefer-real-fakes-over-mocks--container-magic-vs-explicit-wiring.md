# Summary: Dependency Injection and testability for agentic coding

Distilled index for [`raw-agents-default-to-untestable-coupling--over-mocked-agent-tests--di-as-architectural-guardrail--prefer-real-fakes-over-mocks--container-magic-vs-explicit-wiring.md`](./raw-agents-default-to-untestable-coupling--over-mocked-agent-tests--di-as-architectural-guardrail--prefer-real-fakes-over-mocks--container-magic-vs-explicit-wiring.md).

**Map, not source.** Pull exact figures and citations from the raw file. Research pass for a
`### Designing for testability` subsection under "Testing: the oracle problem" in `src/quality.md`.

Tags: 🟢 primary / well corroborated · 🟡 secondary / mixed · 🟠 single-source or speculative.

## The argument in one paragraph

Agents (a) drift toward untestable coupling when unconstrained — inline construction, direct I/O,
static calls — for the same "no fast reward signal for maintainability" reason the chapter already
gives for duplication; and (b) **over-mock by default** when they write tests. The two compound
into a weak oracle. The fix is an architectural guardrail (interface-at-the-boundary +
constructor injection, enforced deterministically) — but "just add DI / mock the dependencies"
makes (b) worse, so it comes with a counter-narrative: prefer real fakes/testcontainers over
mocks, and explicit wiring over DI-container magic.

## Key evidence

- 🟢 **Over-mocked agent tests** — Hora, *Are Coding Agents Generating Over-Mocked Tests?*
  ([arXiv 2602.00409](https://arxiv.org/abs/2602.00409), MSR 2026). **1.2M commits, 2,168 TS/JS/Python
  repos, 48,563 agent commits.** Coding agents add mocks in **36% of commits vs 26% for
  non-agents**; modify test files in 23% vs 13%. Agents "over-mock by default, concentrate on a
  single test double type, and produce tests that are more brittle and less meaningful than
  human-written equivalents." Recommends mocking guidance in agent config files.
- 🟡 **Agents write coupled code** — mechanism (path-of-least-resistance completion, benchmarks
  don't reward seams) + strong 2026 practitioner consensus; not a measured study.
- 🟡 **Hexagonal / ports-and-adapters helps agents specifically** — multiple independent 2026
  posts: "the real win of hexagonal architecture was testability… mattered more than the
  architecture diagram suggested"; "thin shell, rich core"; "pure functions… trivially testable."
- 🟢 **Prefer real fakes / testcontainers / sociable tests** — established SE (Fowler
  solitary-vs-sociable, Google testing guidance, Testcontainers "use real dependencies as much
  as possible"). Mock-everything tests are brittle and couple to call structure = weak oracle.
- 🟢/🟡 **Test-induced design damage** (DHH, 2014 "Is TDD Dead?" debate) — the honest caution that
  DI taken too far is its own maintainability cost; the agentic version is an agent told "make it
  testable" introducing five interfaces and a mock-heavy suite worse than the original.
- 🟡 **DI-container magic vs explicit wiring** — implicit non-local wiring is a comprehension
  cost; worse for agents (reasoning about wiring not in the edited file; config files with big
  blast radius). Agent-friendly default: explicit constructor injection + hand-written
  composition root; container only when the graph demands it, and treat container config as
  review-sensitive.
- Sub-case: 🟡 when the code under test *is* an agent, DI of the LLM client is what makes
  deterministic testing of tool-routing paths possible.

## Recommendation for the chapter (this run implements it)

New `### Designing for testability` subsection under "Testing: the oracle problem", after
"Keeping the oracle out of the agent's hands":

1. Agents erode testability (coupling) **and** over-mock (2602.00409's 36% vs 26%, "more brittle,
   less meaningful") → the two compound into a weak oracle.
2. Guardrail, not hope: interface-at-the-boundary + constructor injection as a rules-file
   constraint, enforced with ArchUnit / import-linter / dependency-cruiser; ship in-memory fakes
   per port so the agent uses them instead of inventing mocks.
3. Counter-narrative: real fakes / testcontainers / sociable tests over mock-everything;
   "testable seam at the boundary," not "inject everything" (test-induced design damage);
   explicit constructor injection over DI-container magic (comprehension cost).

Research Note: over-mocking is well corroborated (large corpus, MSR 2026); "agents write coupled
code" and "container magic hurts agents" are mechanism + convergent practitioner writing.

Glossary: add **Dependency injection** (agentic testability framing), **Test double (mock / stub
/ fake)** and/or **sociable vs solitary tests**, optionally **hexagonal architecture (ports and
adapters)**.
