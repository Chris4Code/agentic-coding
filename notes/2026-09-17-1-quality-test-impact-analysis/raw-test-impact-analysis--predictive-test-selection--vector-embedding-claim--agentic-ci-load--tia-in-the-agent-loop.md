# Fact-check record: `notes/initial-notes/AI-Driven Test Impact Analysis.md`

Run date: 2026-09-17. Target chapter: `src/quality.md` (§ Testing).
Method: each checkable claim of the initial note was taken to a primary source (paper abstract/PDF, vendor documentation, engineering blog) rather than to the secondary Medium/LinkedIn links the note itself cites.

---

## 1. Claim-by-claim verdicts on the initial note

### 1.1 "Predictive Test Selection (PTS) / AI-Driven Test Impact Analysis (TIA) exists as an industrial and academic practice"

**CONFIRMED.** Both terms are in real industrial use with the meaning the note gives them. `Predictive Test Selection` is the product name used by both CloudBees/Launchable and Gradle Develocity; `Test Impact Analysis` is Microsoft's term in Azure Pipelines and Anthropic's term for its internal service.

### 1.2 "Meta pioneered this … cut CI testing infrastructure costs in half while still catching over 95% of test failures"

**CONFIRMED, with two figures the note omits.**

Source: Machalica, Samylkin, Porth, Chandra, *Predictive Test Selection*, [arXiv:1810.05286](https://arxiv.org/abs/1810.05286); companion engineering post [engineering.fb.com, 2018-11-21](https://engineering.fb.com/2018/11/21/developer-tools/predictive-test-selection/).

Verified wording and numbers:
* "reduces the total infrastructure cost of testing code changes by a factor of two"
* "over 95% of individual test failures" still identified
* **"over 99.9% of faulty changes are still reported back to developers"** — the note omits this, and it is the more important number: per-*change* recall is what makes the technique safe to deploy, per-*test* recall is not.
* The engineering post adds: the system runs "just a third of all tests that transitively depend on modified code".

Mechanism: "a variant of a standard machine learning algorithm — a gradient-boosted decision-tree model", chosen because GBDTs are "explainable, easy to train, and already part of Facebook's ML infrastructure". The model consumes "a feature-based abstraction of the code change". The paper explicitly models test **flakiness** as part of the training signal.

**No embeddings and no vector database anywhere in this system.** This directly contradicts the note's framing (see §1.5).

### 1.3 "CloudBees offers native Predictive Test Selection … Launchable similarly trains ML models"

**CONFIRMED as products; the note's description of the mechanism is wrong in detail.**

* CloudBees acquired Launchable in **August 2024** ([CloudBees newsroom](https://www.cloudbees.com/newsroom/cloudbees-acquires-launchable-to-boost-genai-efforts-across-devsecops); Launchable founded 2019). Launchable's PTS is now shipped as **CloudBees Smart Tests**. The note treats CloudBees and Launchable as two separate vendors — outdated since 2024.
* [CloudBees Smart Tests PTS docs](https://docs.cloudbees.com/docs/cloudbees-smart-tests/latest/features/predictive-test-selection) describe three inputs: changed source files, test files, and commit information, and say the product "calculates the similarity between changed files and test files". The marketing line "uses large language models (LLMs) to understand your code changes" is present but unelaborated — no architecture is disclosed.
* [Launchable's own engineering docs](https://help.launchableinc.com/features/predictive-test-selection/how-launchable-selects-tests/) are more specific and are the better citation. Training signals: test execution history; **historical correlation between changed files and failed tests**; change characteristics (change size, filetypes changed); **test name/path and file name/path similarity**; test characteristics; flavors (environments). The docs note "a model is not just a simple mapping of files to tests". No mention of embeddings, vector search, or semantic code similarity.

**Correction to the note:** the note's phrase "semantic code similarities" (attributed to CloudBees) overstates what the vendor documents. Launchable's documented similarity signal is **lexical name/path similarity**, not semantic embedding distance.

Reported effect sizes (vendor-published, not independently verified):
* [Launchable FAQ / optimization-target docs](https://help.launchableinc.com/features/predictive-test-selection/requesting-and-running-a-subset-of-tests/choosing-a-subset-optimization-target/): a typical project without Launchable needs ~75% of its tests to reach 90% confidence of catching a failing run; with the model, ~20% of tests reaches the same 90% confidence.
* [BMW case study](https://www.launchableinc.com/customers/bmw-uses-launchable-to-optimize-testing-and-reduce-costs/): failing run identified with 90% confidence from a few minutes of tests; double-digit-percentage hardware reduction.
* CloudBees marketing aggregates early-customer figures (BMW, GoCardless) as "50% reduction in machine hours, 90% reduction in test execution times, 40% reduction in build times" — no methodology published; treat as vendor claims.

### 1.4 Vendor the note missed entirely: Gradle Develocity

**Not in the note; belongs in the chapter.** [Develocity Predictive Test Selection](https://docs.develocity.ai/2026.2/using-develocity/predictive-test-selection/) is the JVM-ecosystem equivalent.

* Model trained on Build Scan data: "millions of test executions and dozens of projects from Gradle's data partners", across JVM libraries, API services, Android apps, server apps.
* Per-build flow: the agent **fingerprints what the change touched**, scores every candidate test, runs the selected subset, and records in the Build Scan *why each test was selected or skipped* — i.e. the selection is auditable.
* Documented variables: which code changes affect tests in the module, how sensitive a test is to change, nature of recent changes, **test flakiness**.
* Documented always-run rule: tests are always selected if they are **recently new, recently changed, recently failed, or recently flaky**. Tests that already passed against the same sources and dependencies are less likely to be selected.
* Vendor claim: "cuts testing time up to 70%".

This matters for the chapter because it is a second, independent industrial confirmation that the production feature set is *history + change fingerprint + flakiness*, not embeddings.

### 1.5 The note's central architectural claim: a vector DB of test embeddings queried with a changeset embedding

> "modern AI-native testing systems map both the codebase and the test suites into vector spaces. When a code change (changeset) occurs, its semantic embedding is used to query a vector database containing embeddings of the existing tests"

**NOT CORROBORATED as a description of any production system.** This is the weakest part of the note and the part the chapter must not repeat uncritically.

What the sources actually show:
* Meta: GBDT over change features (§1.2). No vectors.
* Launchable/CloudBees: historical file→test failure correlation + change characteristics + name/path similarity (§1.3). No vectors.
* Develocity: ML over Build Scan history + change fingerprint (§1.4). No vectors.
* Anthropic: explicitly **deterministic** (§1.7). No vectors.

The note's own citations for the vector architecture do not support it. They are:
* [7] a Qdrant tutorial on **code search**, [11] a HuggingFace cookbook on **code search**, [8][10][12][16] generic explainers on embeddings/vector DBs — all real, but all about semantic code *search*, not test *selection*. The note generalises from "you can embed code" to "this is how test selection is done", which the sources do not license.
* [5] a single Medium post, [9] a LinkedIn post, [2] a learning-hub page, [13] a YouTube video.
* [6] an Aalto University thesis — **could not be verified**, the bitstream URL returns HTTP 403.

**Closest real academic precedent** (not cited by the note): *Neural Network Embeddings for Test Case Prioritization* (NNE-TCP), [arXiv:2012.10154](https://arxiv.org/abs/2012.10154). This does embed files and tests into a shared vector space — but the embedding is learned from **which files were modified when a test changed status historically**, i.e. from co-change history, *not* from the semantic content of the code or the test. The abstract claims the file↔test connection is "relevant and competitive relative to other traditional methods"; no headline numbers in the abstract. Related: *Test2Vec* ([arXiv:2206.15428](https://arxiv.org/pdf/2206.15428)) embeds **execution traces**, again not source text.

So the honest statement is: embedding-based test selection exists in the research literature, learns from execution/co-change signals rather than code semantics, and has not displaced the feature-based ML or deterministic approaches in production.

### 1.6 Miscitations in the note

* **[15] = [arXiv:2510.10824](https://arxiv.org/abs/2510.10824)**, cited to support "Agentic RAG workflows … an AI agent intercepts the changeset, retrieves candidate tests via vector search, and then filters them using strict metadata". The paper is real — *Agentic RAG for Software Testing with Hybrid Vector-Graph and Multi-Agent Orchestration* (Hariharan, Arvapalli, Barma, Sheela; submitted 2025-10-12) — but it is about **generating** QE artifacts (test plans, test cases, QE metrics) with Gemini/Mistral, **not about selecting which tests to run**. Miscited.
* **[4] = arXiv 1810.05286** (the Meta PTS paper) is cited in the note to support the "Always-Run Tier" bullet. The paper does not describe an always-run tier. Miscited. (Develocity's docs *do* document an always-run rule — §1.4 — so the underlying advice survives with a correct source.)
* The "Three-Tier Architecture" (deterministic floor / vector-learned layer / always-run tier) is sourced to a single Medium post [5]. It is **not** an industry-recognised architecture name. The *shape* it describes is defensible and matches real deployments, but it should be presented as a design pattern, not as something "modern AI test selection engines deploy".
* "Semantic blurring" (unrelated files looking mathematically similar because they share generic syntax) — sourced only to Medium/LinkedIn. The underlying phenomenon is a real and well-known property of code embeddings, but the term and the claim are not backed by a primary source.

### 1.7 Material the note predates: the agentic-CI angle

The initial note frames TIA as a CI cost-optimisation. The 2026 development is that **agentic coding is what makes TIA load-bearing**, and that the agent itself becomes a consumer of the test map.

**Anthropic, *Agentic coding is straining CI. Here's how we scaled test impact analysis at Anthropic*, Sachin Malhotra, 2026-09-14** ([claude.com/blog](https://claude.com/blog/agentic-coding-is-straining-ci-heres-how-we-scaled-test-impact-analysis-at-anthropic)):
* Anthropic engineers ship **8x more code per quarter**, with **Claude authoring 80% of it**.
* Test volume grew **10x**; engineer headcount flat.
* Result: **25x increase in CI jobs over six months**.
* Their answer is a **deterministic** test impact analysis / test selection service, not an ML model. Two components: a **listener** that records test results from every CI run, and a **selector** that reads that history to decide which tests run on a given PR. Selection is based on "past performance and package relevance".
* Scaling story: v0 was a single-process singleton that became a bottleneck; three successive stopgaps (bigger machines, package-level sharding, daily restarts) bought 70 days, then 29 days, then <1 day; it was then redesigned as a stateless horizontally-scalable system over an in-memory store, listeners appending to a journal without holding state. The redesign took three weeks.
* On agents as consumers: "when they get a specific set of valid tests, they can self-verify and iterate more effectively".
* Not disclosed: skip percentages, recall/safety figures, cost savings. Do not invent them.

**TDAD: *Test-Driven Agentic Development — Reducing Code Regressions in AI Coding Agents via Graph-Based Impact Analysis*, Alonso, Yovine, Braberman (Universidad ORT Uruguay / UBA), [arXiv:2603.17973v2](https://arxiv.org/pdf/2603.17973), 2026-03-19.**

Verbatim from the paper:
* Problem framing: "An agent can either run all tests (too slow for large codebases) or run only tests near the changed files (missing indirect dependencies). This problem parallels classical regression test selection (RTS), but the agentic context introduces novel requirements: changes are generated programmatically, the agent has a limited context window, and test verification must happen **before submission** rather than in a CI pipeline afterward."
* Baseline damage: "a vanilla agent caused 562 pass-to-pass (P2P) test failures across 100 instances—an average of **6.5 broken tests per generated patch**."
* Mechanism: TDAD builds a dependency map between source code and tests, "delivered as a lightweight agent skill—a static text file the agent queries at runtime". "At runtime the agent needs only `grep` and `pytest`—no graph database, MCP server, or API calls." `pip install tdad`, MIT licence.
* Key insight, verbatim: "agents do not need to be told **how** to do TDD; they need to be told **which tests to check**."
* Result 1 — **70% regression reduction**: test-level regression rate 6.08% → 1.82% (562 → 155 P2P failures), Phase 1, 100 SWE-bench Verified instances, Qwen3-Coder 30B, single-agent setup.
* Result 2 — **TDD Prompting Paradox**: an ablation adding TDD *procedural* instructions ("write tests first, then implement") without telling the agent which tests to check **increased** regressions to **9.94%** — worse than the vanilla baseline.
* Result 3 — generalisation: Phase 2 (25 instances, Qwen3.5-35B-A3B + OpenCode) improved resolution 24% → 32%, generation 40% → 68%.
* Result 4 — an auto-improvement loop on a 10-instance subset raised resolution 12% → 60% with 0% regression.
* Supporting context the paper cites: METR found roughly half of SWE-bench-passing patches would not be merged by real maintainers; Ehsani et al. show CI/CD failures are a leading cause of rejected agent-authored PRs.

**Scale caveat for TDAD:** 100 + 25 + 10 instances, open-weight models on consumer hardware, single research group, arXiv preprint. The direction is well-motivated and the paradox result is striking, but these are small-n numbers.

### 1.8 The deterministic baseline the note dismisses too quickly

The note says "traditional test selection relies on hard-coded dependency graphs (e.g., finding which tests import a modified file)". That undersells a mature field:

* **Regression Test Selection (RTS)** has *safe* variants with formal guarantees. **Ekstazi** ([Gligoric et al.](https://users.ece.utexas.edu/~gligoric/papers/GligoricETAL15Ekstazi.pdf)) tracks dynamic file-level dependencies via checksums, with no version-control integration required; **STARTS** derives the same file-level dependencies statically. Comparative work puts STARTS' safety violation at ~3.19% relative to Ekstazi as baseline.
* **Build-graph selection** in monorepos: Bazel's `rdeps()` reverse-dependency query answers "what else depends on this target", Nx has `affected` (`nx graph --affected`), Jest has `--changedSince`. An affected-build calculation is correct only if both *what changed since a trusted base* and *which targets can observe those inputs* are correct.
* **Microsoft Test Impact Analysis** in Azure Pipelines (Visual Studio Test task v2), still documented as active (docs updated Oct 2025); scoped to managed code and single-machine topology. No deprecation notice found.
* Recent research keeps finding cheap deterministic signals sufficient: *Names Are All You Need: Effective and Safe Regression Test Selection for Python* (You Wang, Michael Pradel, Zhongxin Liu, [arXiv:2605.25356](https://arxiv.org/pdf/2605.25356), 2026-05-26) does safe Python RTS from identifier names alone, avoiding heavyweight program analysis.

---

## 2. Claims in the note that are fine as-is

* Syntax-aware chunking via AST parsers (Tree-sitter) beats fixed-character chunking for code — well established.
* One chunk = one test function is the right granularity **if** you are building such an index, because the selector's output must be an executable test identifier.
* Metadata enrichment of a chunk before embedding (filepath, module, target component) improves retrieval — standard RAG practice, consistent with the chapter's existing RAG material.
* `langchain-text-splitters` `RecursiveCharacterTextSplitter.from_language(Language.PYTHON, …)` exists and splits on language syntax. Minor correction: LangChain's `RecursiveCharacterTextSplitter.from_language` uses **language-specific separator lists**, not Tree-sitter, in the code path shown; LangChain does have separate AST-based splitters. The note's claim that it "utilizes Tree-sitter under the hood" is inaccurate for that class.
* Qdrant, Chroma, Pinecone are real vector databases; `unixcoder`, `codebert` are real code embedding models.

## 3. What went into the chapter, and what did not

Went in: the taxonomy (deterministic RTS → learned PTS → always-run), Meta's numbers with the per-change figure restored, Launchable/Develocity documented signals, the Anthropic agentic-CI numbers and deterministic design, TDAD's regression numbers and the TDD-prompting paradox, the shift of TIA from CI cost control to agent inner-loop context.

Kept out: the vector-DB-of-test-embeddings architecture as a description of production practice (demoted to "research direction, not how shipped systems work"); the "Three-Tier Architecture" as a named industry pattern (kept as a design shape, unnamed); arXiv 2510.10824 as a test-selection citation; the Aalto thesis (unverifiable); the chunking/`langchain` implementation detail (belongs to RAG mechanics already covered elsewhere in the book, and rests on an architecture that isn't the production one).
