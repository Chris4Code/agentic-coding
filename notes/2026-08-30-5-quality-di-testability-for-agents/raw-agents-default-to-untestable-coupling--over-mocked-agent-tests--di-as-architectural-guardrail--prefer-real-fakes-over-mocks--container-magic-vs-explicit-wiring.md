# Research pass: Dependency Injection and testability for agentic coding

Date: 2026-08-30 · run 5 · chapter `src/quality.md`
Skill: deep-book-research (manual pass)

Scope: material for a `### Designing for testability` subsection under "Testing: the oracle
problem" in `src/quality.md`. Organising question: **does DI / design-for-testability matter
differently when an agent writes the code?** Short answer — yes, in a specific and evidenced way:
agents both (a) drift toward untestable coupling when unconstrained, and (b) over-mock by default
when they do write tests, and those two failures reinforce each other into a weak oracle. But the
naïve fix ("add more DI, mock the dependencies") makes (b) worse, so the recommendation has a
counter-narrative attached.

**Training-cutoff caveat:** assistant knowledge ends January 2026; today is August 2026.
Post-cutoff items web-verified August 2026: the over-mocked-tests study (arXiv 2602.00409, MSR
2026), the Codex AGENTS.md mock-control write-up (30 Jun 2026), and the 2026 "agent-ready
architecture" / "hexagonal agents" practitioner posts. Classic SE references (Fowler on
sociable/solitary tests, the 2014 "Is TDD Dead?" / test-induced design damage debate, Feathers's
seams) are pre-cutoff and cited from general knowledge.

---

## 1. Agents default to untestable coupling

There is no direct large-scale study measuring "coupling in agent-written code" specifically, but
the mechanism is the same one the chapter already invokes for duplication and complexity
([Structural quality and maintainability metrics](#), and the [Software Factories](#) "no fast
reward signal for maintainability" argument): the path of least resistance for an LLM completing
a function is to construct what it needs inline — `new PaymentClient()`, `open(path)`,
`datetime.now()`, `db.query(...)`, a static/singleton call — because that is the shortest correct
completion and nothing in the training objective rewards a testable seam. SWE-bench-style
benchmarks grade whether tests pass, not whether the code that made them pass is injectable.

Practitioner consensus in 2026 is that this is real and that the fix is architectural
constraint, not hope. The recurring recommendations:

- **Ports & adapters / hexagonal architecture as an agent guardrail.** Multiple 2026 write-ups
  argue hexagonal architecture matters *more* with agents than without, precisely because of
  testability: *"the real win of hexagonal architecture was testability: interfaces and
  dependency injection made mocking trivial, which turned out to matter more than the
  architecture diagram suggested"*
  ([anoliphantneverforgets.com, "Hexagonal Agents", Mar 2026](https://anoliphantneverforgets.com/notes/2026-03-18-hexagonal-agents)).
- **Thin shell, rich core.** *"Keep the interface layer thin and the core layer rich, allowing
  agents to accomplish most tasks by composing core functions without reaching into the service
  layer"*; *"core layers with pure functions that have no side effects and no external
  dependencies are trivially testable and composable"*
  ([marketingagent.blog, "Agent-Ready Architecture", Mar 2026](https://marketingagent.blog/2026/03/24/how-to-design-agent-ready-architecture-for-ai-coding-in-2026/)).
- **Rules-file constraints.** Backend "coding rules for AI agents" posts recommend putting
  DDD + hexagonal + "depend on interfaces at boundaries, constructor injection, no I/O in
  constructors" directly into `CLAUDE.md` / `AGENTS.md`
  ([Khosravi, Medium](https://medium.com/@bardia.khosravi/backend-coding-rules-for-ai-coding-agents-ddd-and-hexagonal-architecture-ecafe91c753f) —
  fetch blocked (403) but corroborated by the search excerpt and by several sibling posts).
- **Deterministic enforcement.** The same tools the chapter's [drift-mitigation ladder](#) names —
  ArchUnit (Java), `import-linter` (Python), `dependency-cruiser` / `eslint-plugin-boundaries`
  (JS/TS), `.NET` `NetArchTest`, `go-arch-lint` — can assert "domain layer must not import
  infrastructure," which is the structural precondition for testability, as a CI check the agent
  can't argue with.

Concrete agentic sub-case worth noting: when the code under test is *itself* an agent (an
LLM-calling function), DI of the LLM client is what makes it testable at all — *"accepting an
optional LLM client parameter through dependency injection is what makes deterministic testing
possible without modifying production code … tests covering every tool-routing path including
edge cases"* ([sitepoint, 2026](https://www.sitepoint.com/ai-agent-testing-automation-developer-workflows-for-2026/)).

Evidence: 🟡 the "agents write coupled code" claim is mechanism + strong practitioner consensus,
not a measured study; the "hexagonal helps agents" framing is multiple independent 2026 posts
(secondary, convergent).

## 2. Over-mocked agent tests — the evidence

This is the well-measured half. **"Are Coding Agents Generating Over-Mocked Tests? An Empirical
Study"** (Andre Hora, [arXiv 2602.00409](https://arxiv.org/abs/2602.00409), MSR 2026):

- Corpus: **1.2 million commits made in 2025 across 2,168 TypeScript / JavaScript / Python
  repositories**, including **48,563 commits by coding agents**. "First investigation of mocks in
  agent-generated tests of real-world software systems."
- **36% of coding-agent commits add mocks to tests, vs 26% for non-agents.** 23% of agent commits
  modify test files vs 13% for non-agents. In repos with agent test activity, 68% also have agent
  mock activity.
- Qualitative finding: coding agents *"over-mock by default, concentrate on a single test double
  type, and produce tests that are more brittle and less meaningful than human-written
  equivalents."*
- Trend: newer repositories show a higher proportion of agent test/mock commits — accelerating.
- Recommendation: *"tests with mocks may be potentially easier to generate automatically (but
  less effective at validating real interactions), and the need to include guidance on mocking
  practices in agent configuration files."*

Follow-up practitioner write-up: [Codex AGENTS.md mock-control guidance (30 Jun
2026)](https://codex.danielvaughan.com/2026/06/30/over-mocked-tests-coding-agents-codex-cli-agents-md-testing-guidance-mock-control/)
— concrete `AGENTS.md` rules to bound mocking ("mock only at architectural boundaries — network,
clock, filesystem, third-party APIs; never mock the type under test or your own value objects").

Why this matters for the chapter: it is the same failure the [oracle-problem section](#) already
describes ("tests that mock everything"), now with a number and a named cause. And it means the
DI recommendation has to be phrased carefully — DI enables both a real fake *and* a mock, and
agents reach for the mock.

Evidence: 🟢 primary, large corpus, peer-reviewed venue (MSR 2026).

## 3. DI as an architectural guardrail — what actually to recommend

The useful, non-obvious framing is that DI is not the goal — a **testable seam** is the goal, and
DI is one way to get one. Options, roughly in order of agent-friendliness:

1. **Pure functions / functional core.** No dependency to inject; the "trivially testable" case.
   Push decisions into pure functions, keep I/O at the edges.
2. **Constructor injection with plain explicit wiring.** The class takes its collaborators as
   constructor parameters; something explicit (a composition root, a `main`, a factory function)
   passes the real ones in production and a fake in tests. No framework.
3. **Parameter / method injection** for a one-off collaborator (a clock, a RNG).
4. **A DI container** (Spring, Guice, `dependency-injector`, .NET's built-in) — only once the
   wiring graph is large enough to be tedious by hand. See §5 for the comprehension cost.

For agents specifically:

- Put the rule in the loaded rules file: *"depend on an interface/protocol at every boundary
  (network, DB, filesystem, clock, third-party SDK); take collaborators as constructor
  parameters; no side-effecting work in constructors."*
- Enforce the layer boundary deterministically (§1) so an agent that reaches through a seam gets
  a failed check, not a passing PR.
- Provide the fakes. If the repo ships an in-memory fake for each port (a fake repository, a
  fake clock, a fake payment gateway), the agent will use them; if it has to invent a test
  double, it invents a mock (§2).

Evidence: 🟢 for the DI/seam concepts (standard SE); 🟡 for the "agents will use a provided fake
but invent a mock" claim (consistent with 2602.00409's "single test double type" finding + the
Codex write-up, but not separately measured).

## 4. Prefer real fakes / testcontainers over mocks — the counter-narrative

If the chapter says "add DI for testability" without this, it pushes readers toward exactly the
over-mocking failure in §2. The balancing points:

- **Sociable over solitary tests** (Fowler / Jay Fields terminology): let the unit use real
  collaborators until a dependency is genuinely slow or non-deterministic; mock only at that
  line, typically the process boundary. Mock-everything ("solitary") tests are brittle and
  couple the test to the implementation's call structure — which is what makes them a weak
  oracle.
- **Fakes over mocks.** A fake has a working in-memory implementation (a `FakeUserRepository`
  backed by a dict); it verifies behaviour through real state, not through "was this method
  called with these arguments." Google's testing guidance and most 2026 practitioner writing
  land here.
- **Testcontainers for the real thing.** For DB / cache / broker dependencies, run the real
  service in a throwaway container: *"integration tests using real services catch issues that
  mocks might miss — SQL syntax errors, connection handling, cache serialization bugs"*;
  *"write tests using real dependencies as much as possible and use mocks only when needed"*
  ([Docker / Testcontainers](https://www.docker.com/blog/testcontainers-testing-with-real-dependencies/),
  and many 2026 write-ups). This is more affordable than it used to be and removes the agent's
  temptation to mock the database.
- **Test-induced design damage** (DHH, the 2014 "Is TDD Dead?" exchange with Beck and Fowler):
  the honest counter-caution — DI taken too far (an interface and an injected collaborator for
  every trivial thing, a mock-driven test for every method) is itself a maintainability cost.
  The agentic version: an agent asked to "make this testable" will happily introduce five
  interfaces and a mock-heavy suite that is *worse* than the coupled original. The instruction
  has to be "testable seam at the boundary," not "inject everything."

Evidence: 🟢 for the concepts (well-established SE debate); the "agents overshoot when told to
make code testable" point is 🟡 synthesis from §2 + §3.

## 5. DI container magic vs explicit wiring — comprehension cost

Container-based DI (Spring's component scanning, Guice modules, decorator-driven registration)
makes the wiring *implicit and non-local*: the source at the call site doesn't name what gets
injected; it's resolved from configuration or annotations elsewhere. For a human this is a known
trade-off ("explicit is better than implicit", PEP 20; the recurring HN/blog complaint about
"magical DI frameworks"). For an agent it is worse in a specific way:

- The agent has to reason about wiring it cannot see in the file it is editing — the same
  non-local-context problem the [comprehension-debt section](#) describes.
- An agent modifying DI configuration (a Spring `@Configuration`, a Guice module) is editing a
  file with outsized blast radius and little local feedback — adjacent to the
  "[always human-review config changes](#)" guidance for CI/lint config.
- Constructor injection with an explicit composition root keeps the dependency graph greppable:
  the agent (and the reviewer) can read one function and see everything that's wired.

So the agent-friendly default is **explicit constructor injection + a hand-written composition
root**, reaching for a container only when the graph size demands it — and treating container
config as review-sensitive when it's present.

Evidence: 🟡 — the "explicit is better for comprehension" principle is well established; the
"and this applies extra to agents" extension is synthesis consistent with the chapter's
comprehension-debt and config-review threads, not a cited study.

---

## What this means for `src/quality.md`

Add a `### Designing for testability` subsection under "Testing: the oracle problem", after
"Keeping the oracle out of the agent's hands" (it's the same theme — what makes a real oracle
possible). Three-to-four paragraphs:

1. Agents drift to untestable coupling (mechanism = the maintainability-signal argument), and
   separately over-mock when they write tests — 2602.00409's 36% vs 26% and "more brittle, less
   meaningful." The two compound into a weak oracle.
2. The fix is an architectural guardrail, not a hope: interface-at-the-boundary + constructor
   injection as a rules-file constraint, enforced deterministically (ArchUnit / import-linter /
   dependency-cruiser), plus shipping in-memory fakes for each port so the agent uses them
   instead of inventing mocks.
3. The counter-narrative: prefer real fakes / testcontainers / sociable tests over mock-
   everything; "testable seam at the boundary," not "inject everything" (test-induced design
   damage). And favour explicit constructor injection over DI-container magic, because implicit
   non-local wiring is a comprehension cost the agent pays.

Research Note: the over-mocking finding is well corroborated (large corpus, MSR 2026); the
"agents write coupled code" and "container magic hurts agents" points are mechanism + convergent
practitioner writing rather than measured results.

Glossary: **Dependency injection** (with the agentic testability framing), **sociable vs solitary
tests** or **test double (mock / stub / fake)**, maybe **hexagonal architecture (ports and
adapters)**.

---

## Sources

1. Hora — Are Coding Agents Generating Over-Mocked Tests? An Empirical Study (MSR 2026) — https://arxiv.org/abs/2602.00409
2. Codex Knowledge Base — Over-Mocked Tests and Coding Agents: configuring AGENTS.md for test quality (30 Jun 2026) — https://codex.danielvaughan.com/2026/06/30/over-mocked-tests-coding-agents-codex-cli-agents-md-testing-guidance-mock-control/
3. "Hexagonal Agents" — anoliphantneverforgets.com (Mar 2026) — https://anoliphantneverforgets.com/notes/2026-03-18-hexagonal-agents
4. "How to Design Agent-Ready Architecture for AI Coding in 2026" — https://marketingagent.blog/2026/03/24/how-to-design-agent-ready-architecture-for-ai-coding-in-2026/
5. Khosravi — Backend Coding Rules for AI Coding Agents: DDD and Hexagonal Architecture (Medium; fetch 403, used via search excerpt) — https://medium.com/@bardia.khosravi/backend-coding-rules-for-ai-coding-agents-ddd-and-hexagonal-architecture-ecafe91c753f
6. SitePoint — AI Agent Testing Automation: Developer Workflows for 2026 (DI of the LLM client) — https://www.sitepoint.com/ai-agent-testing-automation-developer-workflows-for-2026/
7. Docker — Testcontainers: Testing with Real Dependencies — https://www.docker.com/blog/testcontainers-testing-with-real-dependencies/
8. Fowler — solitary vs sociable tests / "Mocks Aren't Stubs" / UnitTest — https://martinfowler.com/bliki/UnitTest.html
9. Thoughtworks — Test-Induced Design Damage: Fallacy or Reality? (the DHH / Beck / Fowler "Is TDD Dead?" debate) — https://www.thoughtworks.com/insights/blog/test-induced-design-damage-fallacy-or-reality
10. Wolt Careers — Introducing magic-di (implicit vs explicit DI wiring trade-off) — https://careers.wolt.com/en/blog/tech/introducing-magic-di
11. HN discussion — "Magical dependency injection frameworks" — https://news.ycombinator.com/item?id=41435791
