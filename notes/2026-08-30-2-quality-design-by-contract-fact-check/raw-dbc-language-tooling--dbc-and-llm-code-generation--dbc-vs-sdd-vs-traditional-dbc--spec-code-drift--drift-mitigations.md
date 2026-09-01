# Fact-check + research pass: Design by Contract for agentic coding

Date: 2026-08-30 · run 2 · chapter `src/quality.md`
Skill: deep-book-research (manual pass), triggered as a fact-check of `notes/initial-notes/sw-qa-and-dbc.md`

Scope: verify the claims in `notes/initial-notes/sw-qa-and-dbc.md` (an ungrounded AI research chat),
and gather current findings to rewrite the `## Design by Contract` section of `src/quality.md`.
Five subtopics: (1) DbC language-tooling landscape; (2) DbC and LLM code generation;
(3) DbC vs Spec-Driven Development vs traditional DbC; (4) spec-code drift in agentic SDD;
(5) drift mitigations.

**Training-cutoff caveat:** assistant knowledge ends January 2026; today is August 2026.
Post-cutoff items web-verified in August 2026: the IEEE Xplore precondition/postcondition study,
ContractEval (arXiv 2510.12047), SLICE (arXiv 2608.21483), the "Agent Drift" paper
(arXiv 2601.04170), the Spec Growth Engine (arXiv 2606.27045), the O'Reilly/Stack Overflow
"right amount of spec" dispatch (21 Aug 2026), Metalama 2025.0. Several low-authority Medium
posts and YouTube links from the source chat are noted where used but not treated as primary.

---

## Part A — fact-check of `notes/initial-notes/sw-qa-and-dbc.md`

### A1. "Common SW QA methods" list (first answer)

Accurate and uncontroversial: process-oriented (ISO 9001, CMMI, audits, formal technical reviews,
inspections/walkthroughs) vs product-oriented (unit/integration/system/acceptance testing, static
analysis, CI/CD). No corrections. This maps cleanly onto the rest of `src/quality.md`.

### A2. "Is Design by Contract a SW QA method?" (second answer)

Correct. DbC (Bertrand Meyer, coined for **Eiffel** in the mid-1980s; *Object-Oriented Software
Construction*, 1988/1997) is a defect-**prevention** technique built on **preconditions**
(caller's obligation), **postconditions** (callee's guarantee), and **class invariants**
(always-true properties). The note's four "how DbC contributes to quality" rows (fail-fast,
self-documenting, assisted testing, root-cause localisation) are the standard textbook benefits
and are fine. Evidence: primary (Meyer is uncontested); [Design by Contract — ScienceDirect
overview](https://www.sciencedirect.com/topics/computer-science/design-by-contract).

One nuance the note omits: DbC's original framing is **not** "runtime assertions." Meyer's point
was that contracts are a *specification* mechanism first; runtime checking is one of several
possible enforcements (others: static proof, documentation generation, test generation). This
matters for subtopic 3 below.

### A3. "Which languages offer comprehensive DbC tooling?" (third answer) — several corrections

| Claim in the note | Verdict | Correction / detail |
|---|---|---|
| Eiffel — native `require`/`ensure`/`invariant` | ✅ correct | The reference implementation of DbC. |
| Ada 2012+ — `Pre`/`Post` aspects | ✅ correct | Contract aspects on subprograms; `Type_Invariant`, `Predicate`. |
| D — `in`/`out` blocks, `invariant()` | ✅ correct | Native contract programming. |
| Clojure — "native specification system (Clojure spec) … pre- and post-conditions natively" | ⚠️ conflated | Two different things. Clojure has **native `:pre`/`:post` condition maps** on `defn`, since **Clojure 1.1** ([clojure.org special forms](https://clojure.org/reference/special_forms); [Fogus, 2009](https://blog.fogus.me/2009/12/21/clojures-pre-and-post.html)). `clojure.spec` is a **separate library** (richer data/function specs + generative testing), not the `:pre`/`:post` feature. The note treats them as one. |
| SPARK (Ada subset) — static proof via SPARK toolset | ✅ correct | Proves contracts hold for all inputs rather than checking at runtime. |
| C via ACSL / Frama-C | ✅ correct | ANSI/ISO C Specification Language in comments; Frama-C's WP plugin does deductive verification. |
| Java — "Cofoja (Contracts for Java) or Valid4J" | ⚠️ stale | Both exist. **Cofoja** ([github.com/nhatminhle/cofoja](https://github.com/nhatminhle/cofoja)) originated as a Google 20% project (~2010), open-sourced 2011, "maintained … with the help of a small community" but with **little recent release activity** (last tagged release 1.3, 2016-era). **Valid4j** exists (hamcrest-style). Also unmentioned: **JML** + **OpenJML** (the serious Java contract ecosystem), **Contract4J**, **C4J**. |
| C#/.NET — "Microsoft Code Contracts … modern .NET uses PostSharp (AOP)" | ⚠️ needs updating | **Microsoft Code Contracts is dead**: "Code contracts aren't supported in .NET 5+" per [Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/framework/debug-trace-profile/code-contracts); the runtime/rewriter was never ported past .NET Framework, repo archived. The living successor to PostSharp is **Metalama** (compiler-based; PostSharp is the older post-compiler). [Metalama Contracts](https://doc.postsharp.net/metalama/conceptual/aspects/simple-aspects/contracts) is an open-source aspect library doing pre/post/invariant checks; Metalama 2025.0 supports C# 13 / .NET 9 ([PostSharp blog](https://blog.postsharp.net/metalama-2025-0-ga)). Modern idiomatic .NET mostly uses **nullable reference types + guard clauses + `System.Diagnostics.Contracts` stubs / `ArgumentNullException.ThrowIfNull`** rather than a DbC framework. |
| Python — "icontract" | ✅ correct, incomplete | [`icontract`](https://github.com/Parquery/icontract) is real and maintained (decorator-based, informative violation messages, `icontract-hypothesis` derives property tests). Missing: **`deal`** ([github.com/life4/deal](https://github.com/life4/deal) — contracts + static analysis + test generation), and **CrossHair** ([github.com/pschanely/CrossHair](https://github.com/pschanely/CrossHair) — Z3-backed symbolic execution that finds counterexamples to `icontract`/`deal`/plain-assert contracts). |
| JS/TS — "icontract-ts or garbage-contracts" | ❌ **likely fabricated names** | No notable package called `icontract-ts` or `garbage-contracts` could be found. The real TS/JS DbC libraries are **`@final-hill/decorator-contracts`** ([github.com/final-hill/decorator-contracts](https://github.com/final-hill/decorator-contracts) — decorator-based, enforces LSP, updated 2025), **SpecJS** (tiny, early-stage, "not recommended for production"), **babel-plugin-contracts** (Babel-plugin, older), **Contractual** (older). None is a mature, widely-adopted first choice — TS's practical "contract" story is **runtime schema validation** (`zod`, `valibot`, `io-ts`) at boundaries, which is precondition-checking by another name. |

Overall for A3: the *tiered structure* (native / formal-proof / library) is sound and worth
keeping. The specific tool list needs the corrections above: Code Contracts is dead, the TS names
are wrong, Clojure's two mechanisms are conflated, and the Python/Java lists are missing the
tools that actually matter for the agentic angle (`deal`, CrossHair, OpenJML).

Evidence: primary (tool repos, Microsoft Learn, clojure.org) — well corroborated.

### A4. "Can agentic coding circumvent missing DbC tooling?" (fourth answer)

Directionally correct, with caveats:

- **"Contract injection"** — prompting the agent to emit explicit guard-clause preconditions and
  postcondition assertion blocks in plain language — is a real, sensible pattern. The note's
  TypeScript `withdrawFunds` example is reasonable vanilla code. ✅ But calling this "the
  Eiffel/Ada experience" oversells it: guard clauses scattered in function bodies are *not*
  separable, inheritable, tool-extractable contracts, and they *do* ship in the production binary
  (see the note's own limitations table, which is accurate).
- **"Plan-Implement-Validate (PIV) loop"** — not a standard term. The recognised framing is
  **Research → Plan → Implement (RPI)** (Dex Horthy / HumanLayer, covered in
  `notes/2026-08-17-1-sw-factories-dex-horthy-deep-research/`). Treat "PIV" as the chat's own
  coinage, don't propagate it.
- **"Spec-Driven Generation (Dijkstra's Method)"** — mislabelled. Dijkstra's contribution is
  **predicate transformers / weakest-precondition calculus** (*A Discipline of Programming*,
  1976) — deriving a program from a formal postcondition by calculation. Modern spec-driven
  development (write a markdown/YAML spec, agent generates code) is *inspired by* the "spec before
  code" idea but is nothing like weakest-precondition calculus. Don't attribute it to Dijkstra.
- **The limitations table (mathematical proof vs empirical testing; zero vs runtime overhead;
  deterministic vs probabilistic)** is accurate and is the single most useful part of this
  answer — keep its substance.
- **"Automated Contract Testing (Property-Based Testing)"** — the note equates the two. They
  overlap but aren't identical: property-based testing (Hypothesis, fast-check, jqwik, proptest)
  is one way to *check* contracts; **consumer-driven contract testing** (Pact) is a different,
  service-integration sense of "contract testing." Both are relevant; the chapter should keep
  them distinct.

Evidence: mixed. The pattern is corroborated by practitioner writing
([bitbytebit](https://bitbytebit.substack.com/p/enforcing-invariants-in-ai-generated),
[dipankar.name](https://www.dipankar.name/writings/invariants-ai-generated-code/)); the specific
labels ("PIV", "Dijkstra's Method") are wrong or invented.

### A5. "Is SDD drifting away from specs over time?" (fifth answer)

The **core claim is well corroborated** (see Part D below), but the note's specifics lean on
low-authority sources:

- **"SDD 2.0 / Objective-Validation Development" with its three pillars** — traces to **one
  author**, Jarek Wasowski, in [one Medium post](https://medium.com/@wasowski.jarek/5-ai-agent-failure-modes-that-sdd-2-0-blocks-architecturally-87ec8ff40319).
  It is a useful framing but **not an established industry term** — do not present it as "the
  industry is shifting toward SDD 2.0."
- **"Plausible Bullshit"** — informal term, appears in a few blog posts; the underlying idea
  (agents produce clean-looking code that passes shallow tests while violating deeper invariants)
  is real and better-sourced elsewhere.
- **"Self-Inflicted Instruction Drift" / "averaging across competing sources of truth"** —
  this specific framing is from the [Stack Overflow / O'Reilly dispatch (21 Aug
  2026)](https://stackoverflow.blog/2026/08/21/dispatches-from-o-reilly-the-right-amount-of-spec-for-agentic-development/),
  which is a solid secondary source: *"the model is not reading one spec, it's averaging across
  competing sources of truth."* ✅
- **"Progressive Behavioral Drift" / arXiv 2601.04170** — the paper is real:
  **"Agent Drift: Quantifying Behavioral Degradation in Multi-Agent LLM Systems Over Extended
  Interactions"** (Abhishek Rath, 7 Jan 2026, [arXiv 2601.04170](https://arxiv.org/abs/2601.04170)).
  It proposes semantic / coordination / behavioral drift and an "Agent Stability Index" over 12
  dimensions. **Single paper, one author, no independent replication found** — cite as an
  early formalisation, not settled science.
- **"Spec-First vs Spec-Anchored"** — real and better-sourced than the note implies:
  [The Spec Growth Engine, arXiv 2606.27045](https://arxiv.org/pdf/2606.27045) makes exactly this
  distinction and proposes a "drift gate" (below). The note cites arXiv 2602.00180 for it, which
  also exists.
- **"Executable Contracts / OpenSpec as CI gatekeeper"** — [OpenSpec](https://github.com/Fission-AI/OpenSpec)
  is real (Fission-AI; lightweight markdown-spec layer, WHEN/THEN BDD syntax, ~20 assistants).
  Whether it acts as a hard CI gate is more aspirational than the note suggests — it is primarily
  a "agree before you build" spec-organisation tool.
- **"ArchUnit / Spring Modulith as deterministic guardrails"** — both real and well-established
  ([archunit.org](https://www.archunit.org/), [Spring Modulith](https://spring.io/projects/spring-modulith)).
  Fits the chapter's "deterministic checks the agent can't argue with" theme. ✅
- **"Durable Memory Nodes"** — vague; the concrete version is "put architectural constraints in a
  file/rules the agent always loads, not in chat history" — same point as the `CLAUDE.md` /
  linter-rules discussion elsewhere in the chapter.

Evidence: the *phenomenon* is well corroborated (Part D); the *named frameworks* in this answer
are mostly single-source or aspirational.

---

## Part B — DbC language-tooling landscape (current, corrected)

**Native / built-in:** Eiffel (`require`/`ensure`/`invariant` — the origin), Ada 2012+
(`Pre`/`Post`/`Type_Invariant` aspects), D (`in`/`out`/`invariant()`), Clojure (`:pre`/`:post`
maps on `defn`, native since 1.1 — distinct from the `clojure.spec` library),
Racket (contract system), Kotlin (`require`/`check`/`assert` stdlib helpers — lightweight),
Rust (`debug_assert!` + the `contracts` crate; no native DbC).

**Formal-proof tooling (contracts proven, not just checked):** SPARK (Ada subset + SPARK
toolset), C with ACSL + Frama-C/WP, Dafny (contracts + Boogie/Z3 — contract-first by design),
Java with JML + OpenJML, Kotlin/Java via [Viper], Whiley.

**Library / framework, mainstream languages:**
- Python — `icontract` (maintained; `icontract-hypothesis`), `deal` (contracts + linter + test
  gen), CrossHair (Z3 counterexample search over contracts).
- Java — JML/OpenJML (serious), Cofoja (works, low activity), Valid4j.
- C#/.NET — Metalama Contracts (open-source aspect lib; successor to PostSharp). Microsoft Code
  Contracts is **discontinued** (not supported on .NET 5+). Idiomatic modern .NET uses nullable
  reference types + guard clauses.
- TypeScript/JavaScript — `@final-hill/decorator-contracts` (decorator-based, LSP-aware),
  SpecJS (early), babel-plugin-contracts, Contractual. In practice, **runtime schema validation
  at boundaries** (`zod`, `valibot`, `io-ts`, `ajv`) is how most TS teams get precondition
  checking.

**Takeaway for the chapter:** "comprehensive, first-class DbC is rare outside Eiffel/Ada/D and
the proof-oriented languages; everywhere else it is a library, and often a lightly-used one" —
which is exactly the gap the agentic pattern tries to fill.

Evidence: primary (tool docs/repos). Well corroborated.

---

## Part C — DbC and LLM code generation (the evidence)

- **Preconditions/postconditions as prompt constraints improve generation.**
  *A Study of Preconditions and Postconditions as Design Constraints for LLM Code Generation*
  (Embry-Riddle; [IEEE Xplore 11218044](https://ieeexplore.ieee.org/document/11218044/);
  thesis at [commons.erau.edu/edt/927](https://commons.erau.edu/edt/927/)). Six SOTA LLMs,
  class-level generation. Adding explicit pre/postconditions to the prompt "significantly boosts
  initial generation accuracy (pass@k)," strongest in Python, also C++/Java; **smaller/weaker
  models benefit most**. Single study, but a real controlled experiment.
- **ContractEval** ([arXiv 2510.12047](https://arxiv.org/html/2510.12047)) — a benchmark for
  "contract-satisfying assertions in code generation": does generated code actually satisfy
  stated contracts? Establishes that current models frequently do not. Useful as "the problem is
  measurable."
- **Contract inference from code** — a line of work generates JML pre/postconditions from
  existing Java methods, or turns NL intent into assertion-style postconditions
  ([arXiv 2411.15898](https://arxiv.org/pdf/2411.15898), "Towards the LLM-Based Generation of
  Formal Specifications"). Relevant to brownfield: the agent can propose contracts for code that
  has none.
- **SLICE** ([arXiv 2608.21483](https://arxiv.org/html/2608.21483)) — "Specification-Level
  Isolation of Contract Enforcement," a 2026 approach to keeping contract checks from bloating
  production paths — addresses the note's "runtime overhead" limitation.
- **Oracle problem link.** From `notes/2026-08-30-1-...`: LLM-generated test oracles "capture the
  actual program behaviour rather than the expected one" ([Konstantinou et al., arXiv
  2410.21136](https://arxiv.org/abs/2410.21136)); accuracy from requirements alone is <50%
  ([Molina et al.](https://arxiv.org/pdf/2405.12766)). A human-authored contract is precisely the
  external specification that breaks this loop.
- **CrossHair** ships an `AGENTS.md` in its repo — but that is the CrossHair maintainers using
  coding agents on their own project, **not** evidence that CrossHair is "designed for agent
  use." Correct the overstatement from run 1's draft. What *is* true: CrossHair is a natural
  verification backend for agent-written contracts because it produces concrete counterexamples
  an agent can act on.
- **VibeContract** ([arXiv 2603.15691](https://arxiv.org/pdf/2603.15691)) — position paper, ~5
  pages, no experiments. "DbC is the missing QA piece in vibe coding." Cite as a position, not a
  result.

Evidence: the "contracts help generation" claim rests on **one** controlled study plus
several supporting/adjacent papers and the indirect oracle-problem argument. Honest status:
promising and plausible, not yet strongly corroborated.

---

## Part D — DbC vs Spec-Driven Development vs traditional DbC

### D1. Traditional (Eiffel-era) DbC vs the agentic "contract injection" pattern

| | Traditional DbC (Eiffel/Ada/SPARK) | Agentic "contract injection" |
|---|---|---|
| Where the contract lives | A separate, first-class language construct on the routine signature; inheritable; tool-extractable | Guard clauses / assertion blocks inside the function body, in ordinary language syntax |
| Enforcement | Compiler-checked; can be statically proven (SPARK); compiled out of production builds | Ordinary `if`/`throw` code that runs in production unless the agent is told to gate it behind a debug flag |
| Who writes it | The developer, once, as design | The agent, per function, prompted by a rules file — and it may forget or drift |
| Guarantee | Deterministic (SPARK: mathematical proof) | Probabilistic — depends on the agent following instructions; verified empirically by tests |
| Documentation | Contracts auto-extract into API docs / IDE tooling | No standard extraction; the "contract" is just code |

So the agentic pattern **recovers the discipline** (state obligations and guarantees explicitly,
fail fast) **without recovering the tooling guarantees** (separability, proof, zero-overhead,
determinism). The note's limitations table says this correctly.

### D2. DbC vs Spec-Driven Development

Both put a specification before the code, but they operate at different granularity and lifecycle:

| | Design by Contract | Spec-Driven Development |
|---|---|---|
| Unit of specification | A single function / class: preconditions, postconditions, invariants | A feature / change / system: requirements, acceptance criteria, architecture, task breakdown (e.g. Kiro's `requirements.md` / `design.md` / `tasks.md`, GitHub Spec Kit's Specify→Plan→Tasks→Implement, OpenSpec's markdown WHEN/THEN) |
| Form | Executable boolean assertions in (or alongside) code | Prose + structured markdown/YAML, sometimes with executable acceptance tests attached |
| When checked | Every call, at runtime (or statically proven once) | At generation time (agent reads spec → code) and, in better setups, at merge time (a "drift gate") |
| Lives where | In the code, next to the thing it constrains | In a separate spec file/graph, versioned alongside but not inside the code |
| Primary failure mode | Contract too weak (misses a case) or too strong (rejects valid input) | Spec and code drift apart over time (Part E) |
| Relationship | **Complementary.** A contract is a spec fragment that never drifts because it *is* code and is checked on every run. SDD produces the higher-level intent; DbC is one way to make a slice of that intent machine-checkable and drift-proof. |

Key sentence for the chapter: **DbC is drift-resistant precisely because the specification is
executable and co-located with the code; SDD's larger, prose-heavier specs are more expressive
but are exactly the artifacts that drift.** This is why 2026 SDD tooling is moving toward
"executable" specs (schemas, contracts, acceptance tests as gates) — it is SDD reaching for
DbC's drift-resistance property.

### D3. DbC vs TDD (worth one line)

Complementary, not competing: "you can derive tests from a specification, but not the other way
around" ([York U., Agile Specification-Driven Development](https://www.eecs.yorku.ca/~jonathan/publications/2004/xp2004.pdf)).
Meyer's later "Contract-Driven Development" ([Springer](https://link.springer.com/chapter/10.1007/978-3-540-71289-3_2))
explicitly fuses DbC + TDD + auto-testing: contracts become the oracle, tests become contract
exercisers.

Evidence: primary/well-established for the concepts; the DbC-vs-SDD table is this note's own
synthesis from the tool docs (Spec Kit, Kiro, OpenSpec) + the drift literature — reasonable but
not lifted from a single source.

---

## Part E — Spec-code drift in agentic SDD (the daily-use challenge)

### E1. The phenomenon is real and multiply-sourced

- **"Silent spec-code drift"** — "code evolves, the specification does not, and the divergence
  becomes invisible until it is costly to repair" ([Augment Code, What Is SDD](https://www.augmentcode.com/guides/what-is-spec-driven-development);
  [The Spec Growth Engine, arXiv 2606.27045](https://arxiv.org/pdf/2606.27045)).
- **The "two specs" problem** — once an outdated spec sits next to updated code, "the model is
  not reading one spec, it's averaging across competing sources of truth"
  ([Stack Overflow / O'Reilly, 21 Aug 2026](https://stackoverflow.blog/2026/08/21/dispatches-from-o-reilly-the-right-amount-of-spec-for-agentic-development/)).
  Same piece's advice: **once interfaces, tests, and invariants are real, the detailed build
  plan should start disappearing** — don't keep a construction spec around to rot.
- **Spec-first vs spec-anchored** — spec-first writes the spec then never enforces it ("no
  enforcement mechanism prevents later drift"); spec-anchored keeps spec and code "coupled …
  with active monitoring and enforcement" ([arXiv 2606.27045](https://arxiv.org/pdf/2606.27045)).
- **Interpretive / behavioral drift in multi-agent chains** — "once one agent's output becomes
  another agent's input, interpretive drift starts to compound"; formalised as "Agent Drift"
  (semantic / coordination / behavioral) in [arXiv 2601.04170](https://arxiv.org/abs/2601.04170)
  (single paper).
- **Adjacent governance literature**: *The Productivity-Reliability Paradox* ([arXiv
  2605.01160](https://arxiv.org/pdf/2605.01160)), *Protocol-Driven Development: Governing
  Generated Software Through Invariants and Continuous Evidence* ([arXiv
  2605.12981](https://arxiv.org/pdf/2605.12981)) — both argue that without a continuously-checked
  invariant/spec layer, AI throughput gains come with reliability regressions (echoes DORA 2025
  in the chapter's opening).

### E2. Why it drifts (causes, for the chapter)

1. **Asymmetric update cost.** Changing code to fix a bug is one prompt; updating the prose spec,
   the acceptance criteria, and the task list to match is extra work with no immediate payoff, so
   it gets skipped.
2. **No enforcement by default.** A stale unit test fails loudly; a stale spec file just sits
   there. Nothing in the toolchain rejects a merge because the spec no longer matches.
3. **Agents paper over the gap.** Given spec + divergent code, an agent produces plausible code
   that splits the difference or silently follows the code, and shallow tests pass ("plausible
   bullshit").
4. **Compounding across agents/sessions.** Each hop (router → implementer → reviewer, or session
   to session) re-interprets intent slightly; small deviations accumulate.
5. **Over-large specs.** A big upfront construction spec has more surface to go stale than a
   small set of "boundaries that constrain the work."

### E3. Mitigations (what teams actually do)

| Mitigation | Mechanism | Notes / sourcing |
|---|---|---|
| **Drift gate** | Make spec-code divergence a **blocking merge condition** — CI fails if code changes contradict the machine-readable spec/schema | [arXiv 2606.27045](https://arxiv.org/pdf/2606.27045); the strongest structural fix. Requires the spec to be machine-checkable (schema, contract, acceptance test) — prose specs can't gate. |
| **Shrink the spec as code solidifies** | Delete the construction plan once interfaces + tests + invariants exist; keep only intent + acceptance criteria | [O'Reilly/SO dispatch](https://stackoverflow.blog/2026/08/21/dispatches-from-o-reilly-the-right-amount-of-spec-for-agentic-development/). Avoids the "two specs" problem by not keeping the second one. |
| **Executable specs** | Write the checkable part of the spec as contracts (DbC), schemas (`zod`/JSON Schema/OpenSpec WHEN-THEN), or acceptance tests (Gherkin) rather than prose | The DbC connection: an executable contract is a spec fragment that can't drift. |
| **Deterministic architecture guardrails** | ArchUnit / Spring Modulith / `dependency-cruiser` / import-linter assert structural rules the agent can't argue with | [archunit.org](https://www.archunit.org/); catches semantic/structural violations unit tests miss. Same "deterministic checks" theme as the chapter's linter section. |
| **Constraints in a loaded rules file, not chat** | Architectural decisions and past "gotchas" live in `CLAUDE.md`/`AGENTS.md`/a memory store the agent always reads, not in ephemeral context | The note's "durable memory nodes," de-jargoned. |
| **One human-owned source of truth per fact** | Decide whether the spec or the code is authoritative for a given property, and generate/check the other from it | spec-anchored philosophy; "spec as source" (Tessl) is the maximal version. |
| **Single-agent for the spec-sensitive step** | Reduce multi-agent interpretive drift by not fanning the spec-critical decision out across a hierarchy | [arXiv 2601.04170](https://arxiv.org/abs/2601.04170) implication; weakly sourced. |

Evidence: the phenomenon is **well corroborated** (arXiv 2606.27045, the O'Reilly/SO dispatch,
Augment Code, adjacent governance papers). The specific "SDD 2.0" branding is single-source
(Wasowski). "Agent Drift" as a formal construct is one paper. Drift gates are proposed in the
literature; real-world adoption data is thin.

---

## Sources

1. Design by Contract — ScienceDirect overview — https://www.sciencedirect.com/topics/computer-science/design-by-contract
2. Clojure — Special Forms (`:pre`/`:post`) — https://clojure.org/reference/special_forms
3. Fogus — Clojure's :pre and :post (2009) — https://blog.fogus.me/2009/12/21/clojures-pre-and-post.html
4. Cofoja (Contracts for Java) — https://github.com/nhatminhle/cofoja
5. Microsoft Learn — Code Contracts (not supported on .NET 5+) — https://learn.microsoft.com/en-us/dotnet/framework/debug-trace-profile/code-contracts
6. dotnet/runtime issue #23869 — Code Contracts status in .NET Core — https://github.com/dotnet/runtime/issues/23869
7. Metalama Contracts — https://doc.postsharp.net/metalama/conceptual/aspects/simple-aspects/contracts
8. PostSharp blog — Metalama 2025.0 GA — https://blog.postsharp.net/metalama-2025-0-ga
9. icontract — https://github.com/Parquery/icontract
10. deal — https://github.com/life4/deal
11. CrossHair — https://github.com/pschanely/CrossHair ; AGENTS.md — https://github.com/pschanely/CrossHair/blob/main/AGENTS.md
12. final-hill/decorator-contracts (TS/JS) — https://github.com/final-hill/decorator-contracts
13. SpecJS — https://alfonsofilho.github.io/SpecJS/
14. Preconditions and Postconditions as Design Constraints for LLM Code Generation — https://ieeexplore.ieee.org/document/11218044/ ; thesis https://commons.erau.edu/edt/927/
15. ContractEval: A Benchmark for Evaluating Contract-Satisfying Assertions in Code Generation — https://arxiv.org/html/2510.12047
16. Towards the LLM-Based Generation of Formal Specifications — https://arxiv.org/pdf/2411.15898
17. SLICE: Specification-Level Isolation of Contract Enforcement — https://arxiv.org/html/2608.21483
18. VibeContract: The Missing Quality Assurance Piece in Vibe Coding — https://arxiv.org/pdf/2603.15691
19. Konstantinou et al. — Do LLMs generate test oracles that capture the actual or the expected program behaviour? — https://arxiv.org/abs/2410.21136
20. The Spec Growth Engine: Spec-Anchored, Code-Coupled, Drift-Enforced Architecture — https://arxiv.org/pdf/2606.27045
21. Stack Overflow / O'Reilly — The right amount of spec for agentic development (21 Aug 2026) — https://stackoverflow.blog/2026/08/21/dispatches-from-o-reilly-the-right-amount-of-spec-for-agentic-development/
22. Augment Code — What Is Spec-Driven Development? — https://www.augmentcode.com/guides/what-is-spec-driven-development
23. Rath — Agent Drift: Quantifying Behavioral Degradation in Multi-Agent LLM Systems — https://arxiv.org/abs/2601.04170
24. The Productivity-Reliability Paradox: Specification-Driven Governance for AI-Augmented Software Development — https://arxiv.org/pdf/2605.01160
25. Protocol-Driven Development: Governing Generated Software Through Invariants and Continuous Evidence — https://arxiv.org/pdf/2605.12981
26. Wasowski — SDD 2.0 Objective-Validation Development (Medium, single-source) — https://medium.com/@wasowski.jarek/5-ai-agent-failure-modes-that-sdd-2-0-blocks-architecturally-87ec8ff40319
27. OpenSpec — https://github.com/Fission-AI/OpenSpec ; https://openspec.dev/
28. ArchUnit — https://www.archunit.org/
29. Spring Modulith — https://spring.io/projects/spring-modulith
30. Meyer — Contract-Driven Development (Springer) — https://link.springer.com/chapter/10.1007/978-3-540-71289-3_2
31. York U. — Agile Specification-Driven Development (2004) — https://www.eecs.yorku.ca/~jonathan/publications/2004/xp2004.pdf
32. GitHub Spec Kit — https://github.com/github/spec-kit
