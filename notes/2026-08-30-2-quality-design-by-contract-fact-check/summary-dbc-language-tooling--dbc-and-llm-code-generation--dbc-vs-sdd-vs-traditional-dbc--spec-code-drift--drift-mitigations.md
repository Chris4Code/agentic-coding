# Summary: Design by Contract for agentic coding — fact-check + findings

Distilled index for [`raw-dbc-language-tooling--dbc-and-llm-code-generation--dbc-vs-sdd-vs-traditional-dbc--spec-code-drift--drift-mitigations.md`](./raw-dbc-language-tooling--dbc-and-llm-code-generation--dbc-vs-sdd-vs-traditional-dbc--spec-code-drift--drift-mitigations.md).

**Map, not source.** Pull exact figures, tool names, and citations from the raw file. This run
fact-checked `notes/initial-notes/sw-qa-and-dbc.md` and gathered current material to rewrite the
`## Design by Contract` section of `src/quality.md`.

Tags: 🟢 primary / well corroborated · 🟡 secondary / mixed · 🟠 single-source or speculative.

## Fact-check verdict on `sw-qa-and-dbc.md`

| Section of the note | Verdict |
|---|---|
| Common SQA methods list | 🟢 accurate, no corrections |
| "Is DbC a QA method?" (Meyer, pre/post/invariant, benefits) | 🟢 accurate; add nuance that DbC is a *specification* mechanism first, runtime checking is only one enforcement |
| DbC language tooling by tier | 🟡 structure sound, **specific tools need fixing** (see below) |
| "Agents circumvent missing DbC tooling" | 🟡 pattern is real; labels "PIV loop" and "Dijkstra's Method" are wrong/invented; limitations table is accurate and the best part |
| "SDD drifting from specs" | 🟢 phenomenon real & multiply-sourced; 🟠 the "SDD 2.0 / Objective-Validation Development" branding is one Medium author |

### Named-entity corrections (important)

- 🟢 **Microsoft Code Contracts is discontinued** — "not supported in .NET 5+" (Microsoft Learn). The living .NET contract library is **Metalama Contracts** (successor to PostSharp). Idiomatic modern .NET = nullable reference types + guard clauses.
- ❌ **"icontract-ts" and "garbage-contracts" appear to be fabricated.** Real TS/JS DbC libraries: `@final-hill/decorator-contracts` (decorator-based, LSP-aware, updated 2025), SpecJS (early-stage), babel-plugin-contracts, Contractual. In practice TS teams do boundary **schema validation** (`zod`, `valibot`, `io-ts`) instead.
- 🟡 **Clojure**: the note conflates two things. `:pre`/`:post` condition maps are **native since Clojure 1.1**; `clojure.spec` is a **separate library**. Both real, different.
- 🟡 **Java**: Cofoja works but has little recent release activity (last ~2016); the serious Java contract stack is **JML + OpenJML**. Note omits both, plus Python's **`deal`** and **CrossHair**.
- 🟠 **"PIV (Plan-Implement-Validate) loop"** — not a real term; the recognised one is **RPI (Research→Plan→Implement)**, Dex Horthy. Don't propagate.
- 🟠 **"Spec-Driven Generation = Dijkstra's Method"** — wrong. Dijkstra = weakest-precondition calculus (*A Discipline of Programming*, 1976), not markdown-spec-then-generate. Don't attribute.
- 🟠 **"SDD 2.0 / Objective-Validation Development"** — single author (Jarek Wasowski, one Medium post). Useful framing, not an industry standard.
- 🟡 **CrossHair ships an `AGENTS.md`** — true, but that's its maintainers using agents on their own repo, **not** "CrossHair is designed for agent use." Run 1's chapter draft overstated this — corrected in the rewrite.

## New findings for the rewrite

### DbC and LLM code generation (🟡 — one controlled study + support)
- 🟢 **IEEE Xplore 11218044** (Embry-Riddle): explicit pre/postconditions in the prompt "significantly boost initial generation accuracy (pass@k)"; smaller/weaker models benefit most. One real controlled experiment across 6 models.
- 🟡 **ContractEval** (arXiv 2510.12047) — benchmark showing models often *don't* satisfy stated contracts. "The problem is measurable."
- 🟡 **arXiv 2411.15898** — LLMs inferring JML contracts from existing code (brownfield: agent proposes contracts for code that has none).
- 🟡 **SLICE** (arXiv 2608.21483) — keeping contract checks out of production hot paths (addresses the runtime-overhead limitation).
- 🟠 **VibeContract** (arXiv 2603.15691) — 5-page position paper, no experiments.
- Link to the oracle problem (from run 1): a human-authored contract is the external spec that stops an agent's self-written test oracle from just following the (possibly buggy) implementation.

### DbC vs traditional DbC vs SDD (🟢 concepts; 🟡 the comparison tables are this note's synthesis)
- **Traditional DbC (Eiffel/Ada/SPARK)** vs **agentic "contract injection"**: the agentic pattern recovers the *discipline* (state obligations/guarantees, fail fast) but not the *tooling guarantees* — separability, inheritance, static proof, zero production overhead, determinism. Guard clauses in a function body are not extractable, inheritable contracts and they ship in the binary.
- **DbC vs SDD**: different granularity and lifecycle. DbC = one function (executable boolean assertions, checked every call, co-located with code). SDD = one feature/change (prose + structured markdown, checked at generation and ideally at merge, lives in a separate spec file). **Complementary**: DbC is a spec fragment that can't drift because it *is* code; SDD carries the higher-level intent but its prose specs are exactly what drifts. 2026 SDD tooling moving toward "executable specs" is SDD reaching for DbC's drift-resistance.
- **DbC vs TDD**: complementary — "you can derive tests from a specification, but not the other way around." Meyer's later "Contract-Driven Development" fuses both.

### Spec-code drift in daily use (🟢 phenomenon; 🟡 mitigations proposed, thin adoption data)
- 🟢 **"Silent spec-code drift"** — code evolves, spec doesn't, divergence invisible until costly (arXiv 2606.27045; Augment Code).
- 🟢 **"Two specs" problem** — stale spec next to live code → the model "averages across competing sources of truth" (O'Reilly/Stack Overflow dispatch, 21 Aug 2026). Its fix: shrink the spec as code solidifies; don't keep a construction plan around to rot.
- 🟢 **Spec-first vs spec-anchored** — spec-first never enforces; spec-anchored keeps spec/code coupled with active enforcement (arXiv 2606.27045).
- 🟠 **"Agent Drift"** (arXiv 2601.04170) — semantic/coordination/behavioral drift compounding across multi-agent hops; one paper, one author.
- **Causes** (for the chapter): asymmetric update cost, no enforcement by default, agents paper over the gap, compounding across agents/sessions, over-large specs.
- **Mitigations**: drift gate (spec-code divergence = blocking merge condition — needs a machine-checkable spec); shrink the spec; executable specs (contracts/schemas/Gherkin instead of prose); deterministic architecture guardrails (ArchUnit / Spring Modulith / dependency-cruiser / import-linter); constraints in a loaded rules file not chat; one human-owned source of truth per fact.

## What this means for `src/quality.md` (done in this run)

The existing `## Design by Contract` section (three short subsections + one Research Note) is
replaced with an expanded version that:
1. Keeps the three planning-comment sub-items (contract injection / spec-driven generation /
   automated contract testing) but corrects the tool list and the CrossHair overstatement.
2. Adds a subsection **"How this differs from traditional DbC and from spec-driven development"**
   with the two comparison tables (condensed).
3. Adds a subsection **"Specification drift: the daily-use problem"** covering the two-specs
   problem, why specs drift, and the mitigation ladder (drift gate, shrink-the-spec, executable
   specs, deterministic guardrails).
4. Keeps a Research Note flagging: one controlled study for "contracts help generation"; "Agent
   Drift" is a single paper; "SDD 2.0" branding is single-source; drift-gate adoption data is thin.

Glossary: add **specification drift (spec-code drift)**; extend **Design by Contract** if needed;
cross-link from the existing **test oracle problem** entry.
