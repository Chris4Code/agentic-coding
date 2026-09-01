# Summary: CI/CD as the enforcement layer — fact-check + findings

Distilled index for [`raw-platform-agnostic-ci-cd-tools--pipelines-as-code-vs-yaml-dsl--dagger-and-agentic-ci--merge-queues-as-enforcement-gate--ci-cost-under-agent-loops.md`](./raw-platform-agnostic-ci-cd-tools--pipelines-as-code-vs-yaml-dsl--dagger-and-agentic-ci--merge-queues-as-enforcement-gate--ci-cost-under-agent-loops.md).

**Map, not source.** Pull exact figures and citations from the raw file. This run fact-checked
`notes/initial-notes/CI-CD.md` and gathered current material to rewrite the
`## CI/CD as the enforcement layer` section of `src/quality.md`.

Tags: 🟢 primary / well corroborated · 🟡 secondary / mixed · 🟠 single-source or speculative.

## Fact-check verdict on `notes/initial-notes/CI-CD.md`

The note is **tooling-oriented** (platform-agnostic alternatives to GitHub Actions; non-YAML
pipeline DSLs; Dagger-vs-Jenkins code samples), not about CI as a quality gate. **No fabricated
tools** (unlike the run-2 DbC note). Corrections:

| Claim | Verdict |
|---|---|
| CircleCI / Buildkite / Jenkins / TeamCity descriptions | 🟢 accurate |
| **Travis CI** "one of the earliest… supports everything" | 🟡 true but **legacy** now — relevance collapsed after the 2019 Idera acquisition + 2020/21 OSS free-tier cuts pushed projects to GitHub Actions. Still operational, no longer a default pick. |
| **"Woodpecker CI / Drone CI"** paired as equals | 🟡 **Woodpecker is a community fork of Drone** (2019, after Harness acquired Drone); Apache-2.0, actively developed. **Drone** is Harness-owned, Polyform license, maintenance mode. Recommend Woodpecker. |
| **Dagger** "pipelines in real languages, not YAML, runs locally, provider-agnostic" | 🟢 correct but **scope out of date** — since 2025 Dagger pivoted hard toward AI agents (see below). |
| **Fluent CI** (TypeScript/Deno on Dagger) | 🟢 **real** ([fluentci-io/fluentci](https://github.com/fluentci-io/fluentci)); now TS(Deno)/Rust + Wasm plugins; can export to GitHub Actions / GitLab CI / CircleCI YAML. |
| TeamCity Kotlin DSL / Pulumi automation API / Jenkins Groovy DSL / GDSL IDE support | 🟢 all accurate |
| Dagger TypeScript code samples | 🟡 **stylistically dated** — use the old `connect(async (client) => …)` callback style; current Dagger favours Functions/Modules with a `dag` global invoked via `dagger call`. Directionally right; don't quote as current API. Chapter includes no Dagger code anyway. |
| "write the pipeline in Rust itself" (`dagger-sdk` crate) | 🟡 exists but community-maintained, less polished than Go/Python/TS — slightly oversold. |
| Conceptual Dagger-vs-Jenkins contrasts (runs anywhere vs Jenkins-only; locally debuggable; type-checked before run; multi-stage in code) | 🟢 accurate — **this is the useful payload for the chapter.** |

GitHub Actions itself goes unmentioned as the incumbent — the note is answering "what if you're
*not* all-in on GitHub."

## New findings for the rewrite

### Pipelines-as-code vs YAML, through the agentic lens (🟡 — architectural facts, synthesis framing)
1. **Agent can run the whole pipeline locally, identically to CI** (Dagger / Fluent CI / Earthly) — reproduce a CI failure in its own sandbox and iterate, instead of push-wait-read cycles. Collapses the "works locally, fails in CI" gap.
2. **Typed pipeline → compile-time feedback on pipeline edits** — a Kotlin DSL or TS-SDK pipeline gives an agent type errors in the same inner loop as app code; a renamed step fails to compile rather than failing 5 min into a run.
3. **Content-addressed caching shortens the loop** — Dagger claims 5–6× build-time cuts in named cases (OpenMeter 25→5 min, Civo 30→5 min — vendor-reported).
4. **Provider portability** — the merge-queue/required-checks machinery is GitHub-centric; non-GitHub teams get the same *enforcement concept* via their platform's equivalent or a provider-agnostic engine (Woodpecker, Buildkite, Dagger + any runner).
5. **Counter-point:** YAML is still the default, and an agent editing `.github/workflows/*.yml` is exactly where the CI-weakening failure mode lives. Typed pipelines make some silent weakening harder, not impossible.

### Dagger and agentic CI (🟢 existence, 🟠 adoption scale)
- **`LLM()` core primitive** — an agent call is "just another pipeline function," typed and introspectable.
- **Container Use** — CLI giving each coding agent its own code-defined isolated container so multiple agents run in parallel safely (Solomon Hykes / Dagger).
- **OpenTelemetry tracing** of agent prompt/tool/state, same observability the chapter wants.
- **Self-healing CI** — Dagger markets an agent that reproduces a failed pipeline locally and proposes a fix (CI analogue of the Playwright Healer; same "don't heal by weakening" caveat).
- Takeaway: the CI engine and the agent sandbox are converging. One or two sentences, not a subsection.

### Merge queues / CI as enforcement gate (🟢 — extends run 1)
- **Stripe "Minions"** (🟢 architecture, 🟡 exact figure): Feb 2026, **1,300+ merged PRs/week**, "humans review, write none of it." Fork of Block's open-source **Goose**; agents run on the **same `devbox` (pre-warmed AWS EC2) as human engineers**; internal MCP server "Toolshed" (~500 tools); code backs >$1T/yr payments. The cleanest "CI gate + human review, agents at volume, same env as humans" case.
- **CI-weakening, sharper** (arXiv 2605.01471): "superficial convergence through **assertion weakening**"; agents "**silently removing problematic test cases** … inflating success through **scope reduction**." Assertion/scope changes "should require human-in-the-loop validation."
- **arXiv 2605.07062** *From Assistance to Agency* — argues for graduated autonomy levels / explicit control points in CI. Cite as "there's a research conversation," not for a number.
- **GitHub merge-queue reliability caveat**: April 2026, two incidents in 5 days (incorrect squash-merge commits that could revert work on default branches) surfaced under heavy agentic load — 🟡 blog-sourced, illustrative that the gate itself is under new strain.
- **Change-aware test selection** is the standard inner-loop cost fix and is increasingly agent-driven — also the vector for "agent decides a failure is flaky and skips it."

### CI cost under agent loops (🟢 mechanism, 🟡 dollar figures)
- Compute multiplies faster than expected (every iteration = a run); agents amplify flaky-test cost.
- Token cost is now its own budget line: "~$13/dev/active day, heavy automation $500–$2,000/engineer/month"; **Uber reportedly burned its whole 2026 AI coding budget in 4 months** (🟡 secondary/illustrative).
- Mitigations unchanged: affected-tests-only inner loop (<5 min), full suite on merge/deploy, sharding, content-addressed caching, scoped preview envs.

## What this means for `src/quality.md` (done in this run)

The `## CI/CD as the enforcement layer` section is rewritten and given four `###` subsections
(it previously had none):
1. **The gate** — required checks + merge queue; `merge_group` gotcha; Mergify counter-narrative; Stripe Minions as the scale example; provider-agnostic note.
2. **Pipelines as code, not YAML** (NEW) — the local-reproduction + typed-pipeline + caching benefits; Dagger's agent pivot in one sentence; the YAML-is-still-default counter-point.
3. **Iterate-until-green, and the incentive to cheat** — iterate-until-green agents; assertion weakening / test-scope reduction (arXiv 2605.01471); always-human-review for CI/test/lint config.
4. **Cost** — compute multiplication, flaky amplification, token budget line, mitigations.

Research Note flags: Stripe's exact weekly figure and the CI-cost dollar figures are secondary;
the GitHub April-2026 incident is blog-sourced; "pipelines-as-code helps agents specifically" is
synthesis, not a study.

Glossary: consider **pipeline as code** (vs YAML CI config) and/or **change-aware test
selection**; **merge queue** already exists (added run 1).
