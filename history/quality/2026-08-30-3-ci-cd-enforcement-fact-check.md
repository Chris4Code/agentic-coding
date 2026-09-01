# 2026-08-30 · Run 3 · quality · ci-cd-enforcement-fact-check

**Type:** fact-check + `edit-chapter`-style rewrite, scoped to the "CI/CD as the enforcement layer"
section of `src/quality.md`.

**Triggering request:** "Please fact-check the notes contained in `notes/initial-notes/CI-CD.md`
and rewrite the 'CI/CD as the enforcement layer' section using new findings."

**Seed / sources consulted:**
- `notes/initial-notes/CI-CD.md` — the ungrounded AI research chat being fact-checked (covers:
  platform-agnostic alternatives to GitHub Actions — CircleCI, Travis CI, Buildkite, Woodpecker/
  Drone, Jenkins, TeamCity, Dagger; non-YAML DSL CI/CD — TeamCity Kotlin DSL, Pulumi automation
  API, Jenkins Groovy, Fluent CI; Dagger-TS-vs-Jenkins-Groovy code comparisons; IDE support for
  custom pipeline functions).
- The "CI/CD as the enforcement layer" section already drafted in `src/quality.md` by run 1
  (`2026-08-30-1-quality-agentic-qa-methods-deep-research`) — merge queues, iterate-until-green
  agents, CI-weakening failure mode, cost.
- Live web research (August 2026) — see the raw note for the full source list.

**Subtopics targeted:**
1. Platform-agnostic CI/CD tools — verify each named tool and its current state.
2. Pipelines-as-code vs YAML DSL — TeamCity Kotlin DSL, Jenkins Groovy, Pulumi, Fluent CI; the IDE/type-check benefit.
3. Dagger and agentic CI — Dagger's 2025-2026 pivot toward AI agents (`LLM()` primitive, Container Use), caching speedups.
4. Merge queues and CI as the enforcement gate for agent output — GitHub merge queue in 2026, `merge_group`, required checks, real-world scale (Stripe Minions), the CI-weakening failure mode.
5. CI cost under agent loops — compute multiplication, flaky-test amplification, mitigation.

**Output:** `notes/2026-08-30-3-quality-ci-cd-enforcement-fact-check/`
(`raw-*` + `summary-*` pair), plus the rewritten `## CI/CD as the enforcement layer` section of
`src/quality.md` and any matching glossary entries.
