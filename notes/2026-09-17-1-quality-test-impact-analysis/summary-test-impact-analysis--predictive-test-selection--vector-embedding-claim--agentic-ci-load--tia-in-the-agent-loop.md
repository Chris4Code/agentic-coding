# Summary — Test Impact Analysis fact-check (2026-09-17)

Navigation aid for the raw record in this folder. Exact figures, quotes and full citation lists live in `raw-…md`, not here.

## Headline finding

The initial note's central architecture — embed every test into a vector database, embed the changeset, run a similarity search to pick tests — **is not how any production test-selection system documented by its vendor works**. Four independent industrial systems were checked (Meta, Launchable/CloudBees, Gradle Develocity, Anthropic) and none uses embeddings or a vector store for selection. The chapter section was written around what the primary sources actually support.

## What production systems actually use

| System | Approach | Documented signals |
|---|---|---|
| Meta PTS (2018) | Gradient-boosted decision trees | feature abstraction of the change; test flakiness modelled explicitly |
| Launchable / CloudBees Smart Tests | Correlation-based ML | test execution history; historical changed-file→failed-test correlation; change size/filetypes; **name/path lexical similarity**; flavors |
| Gradle Develocity PTS | ML over Build Scan history | change fingerprint; test change-sensitivity; recency of change; flakiness; always-runs new/changed/failed/flaky tests |
| Anthropic internal TIA (2026) | **Deterministic**, no ML | past test performance + package relevance; listener records every CI run, selector reads that history |

## Key numbers (all verified against primary sources)

* **Meta**: infrastructure cost of testing halved; >95% of individual test failures caught; **>99.9% of faulty changes still reported** (the note omitted this, and it is the number that makes the technique safe); runs ~1/3 of transitively-dependent tests.
* **Launchable**: ~75% of tests needed for 90% confidence without a model, ~20% with one. Vendor figure.
* **Develocity**: "up to 70%" test-time reduction. Vendor figure.
* **Anthropic**: 8x more code shipped per quarter, 80% of it Claude-authored, 10x test volume, flat headcount → **25x CI jobs in six months**. No skip-rate or savings figures disclosed.
* **TDAD** (arXiv 2603.17973): vanilla agent breaks **6.5 previously-passing tests per patch**; a static source→test dependency map handed to the agent as a skill file cuts test-level regression **6.08% → 1.82% (70%)**. Ablation: TDD *procedural* prompting without naming the tests made it **worse than baseline (9.94%)** — the "TDD Prompting Paradox". Small-n (100/25/10 instances, open-weight models).

## Corrections applied to the note's claims

* CloudBees and Launchable are not two vendors — CloudBees **acquired Launchable in August 2024**; the product is CloudBees Smart Tests.
* "Semantic code similarities" overstates CloudBees; Launchable's own docs say **name/path similarity**.
* [arXiv 2510.10824] is about **generating** QE artifacts, not selecting tests. Miscited by the note.
* [arXiv 1810.05286] (Meta) was cited for an "Always-Run Tier" it never describes. Develocity's docs are the correct source for that idea.
* The "Three-Tier Architecture" is one Medium post's coinage, not an industry pattern name. Shape kept, name dropped.
* The Aalto thesis link returns HTTP 403 — unverifiable, dropped.
* `RecursiveCharacterTextSplitter.from_language` uses language-specific separator lists, **not** Tree-sitter as the note states.

## Genuine research precedent for the vector idea

Exists, but learns from execution history rather than code semantics: **NNE-TCP** (arXiv 2012.10154) embeds files and tests from *co-change with test status transitions*; **Test2Vec** (arXiv 2206.15428) embeds *execution traces*. Neither embeds source text, and neither has displaced feature-based ML in production.

## Deterministic baseline the note undersold

Safe RTS is mature: **Ekstazi** (dynamic file-level checksums), **STARTS** (static, ~3.19% safety violation vs Ekstazi), Bazel `rdeps()`, Nx `affected`, Jest `--changedSince`, Microsoft TIA in Azure Pipelines (still active, managed code only). 2026 research (*Names Are All You Need*, arXiv 2605.25356) gets safe Python RTS from identifier names alone.

## The angle the note predates

TIA changed role in 2026. It was a CI cost optimisation; agentic throughput made it a correctness mechanism, and the agent — not just the pipeline — became its consumer. An agent that knows which tests its change endangers can verify **before** it submits, which is the Anthropic and TDAD finding independently.
