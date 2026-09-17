# 2026-09-17 — run 1 — test-impact-analysis

Live log, written during the run.

## Triggering request

> Please fact-check the intial notes `notes/initial-notes/AI-Driven Test Impact Analysis.md` and add a new section "Test Impact Analysis (TIA)" in the "Testing" section of the "quality.md" chapter.

## Scope targeted

`src/quality.md`, § Testing — one new subsection added after `### Designing for testability`, plus the matching glossary entries.

## Seeded from

* `notes/initial-notes/AI-Driven Test Impact Analysis.md` — the sole seed note. Two-prompt Gemini chat covering: vector/RAG test selection architecture, code-chunking strategy for a test embedding index, enterprise tooling (CloudBees, Launchable), Meta's predictive test selection, and a "three-tier architecture" (deterministic floor / vector layer / always-run tier). 16 citations, predominantly Medium and LinkedIn secondary sources.

## Subtopics carried into verification

1. Test Impact Analysis / Predictive Test Selection as an industrial practice — terminology and who ships it.
2. Meta's predictive test selection — mechanism and reported figures.
3. Vendor mechanisms — CloudBees Smart Tests / Launchable, Gradle Develocity.
4. The note's central claim — changeset embedding queried against a vector database of test embeddings.
5. Deterministic regression test selection as the baseline — Ekstazi, STARTS, Bazel, Nx, Azure Pipelines TIA.
6. TIA under agentic throughput — CI load, and the agent as a consumer of the test map.

## Sources consulted

Primary:
* arXiv:1810.05286 (Machalica et al., *Predictive Test Selection*) and the engineering.fb.com companion post.
* CloudBees Smart Tests PTS documentation; Launchable "How Launchable selects tests", subset-optimization-target and FAQ docs; Launchable BMW case study; CloudBees Launchable-acquisition newsroom post.
* Gradle Develocity Predictive Test Selection user manual (2026.2).
* claude.com/blog — "Agentic coding is straining CI. Here's how we scaled test impact analysis at Anthropic" (Sachin Malhotra, 2026-09-14).
* arXiv:2603.17973v2 (TDAD) — full PDF text.
* arXiv:2510.10824 (Agentic RAG for Software Testing) — checked to confirm the note's citation of it.
* arXiv:2012.10154 (NNE-TCP), arXiv:2206.15428 (Test2Vec), arXiv:2605.25356 (*Names Are All You Need*), Gligoric et al. Ekstazi paper.
* Microsoft Learn — Azure Pipelines Test Impact Analysis.

Attempted and unavailable: the Aalto University thesis cited as [6] in the seed note (bitstream URL returns HTTP 403).

## Output locations

* Research record: `notes/2026-09-17-1-quality-test-impact-analysis/` (raw + summary pair).
* Chapter: `src/quality.md`, `src/glossary.md`.
