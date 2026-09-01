# Summary: Fuzzing for the Testing section — fact-check + findings

Distilled index for [`raw-pbt-vs-fuzzing--property-based-fuzzing-convergence--coverage-guided-engines-native-fuzzing--llm-generated-fuzz-harnesses--fuzzing-as-oracle-for-agent-code.md`](./raw-pbt-vs-fuzzing--property-based-fuzzing-convergence--coverage-guided-engines-native-fuzzing--llm-generated-fuzz-harnesses--fuzzing-as-oracle-for-agent-code.md).

**Map, not source.** Pull exact figures and citations from the raw file. Fact-check of
`notes/initial-notes/Fuzzing.md` + material for a `#### Fuzzing` subsection under `## Testing` ›
`### The oracle problem`.

Tags: 🟢 primary / well corroborated · 🟡 secondary / mixed · 🟠 single-source or speculative.

## Fact-check verdict on `notes/initial-notes/Fuzzing.md`

One Q&A ("Is property-based testing the same as fuzzing?"). **No fabricated tools; conceptual
content broadly correct.** Corrections are of emphasis, not fact:

| Claim | Verdict |
|---|---|
| "Conceptually, PBT is a type of fuzzing" | 🟡 one framing among several — better: both auto-generate inputs and check an oracle the developer didn't enumerate; they differ in generator (typed vs byte-mutation), oracle (explicit invariant vs implicit "no crash"), and target (function vs trust boundary). |
| Table: goals, what's asserted, scope | 🟢 correct as *typical emphasis*, not a hard line |
| Table: "PBT input = generative from types; fuzzing = mutational/coverage-guided byte streams" | ⚠️ incomplete — fuzzing also has grammar-based modes, PBT can be stateful and (HypoFuzz) coverage-guided |
| Table: "PBT fast in CI; fuzzing slow, days, dedicated servers" | ⚠️ dated — short **CI fuzzing** (1–10 min per PR, seeded) is now standard (CIFuzz, `go test -fuzz`, `cargo fuzz`); the continuous-server model still exists but isn't the only one |
| PBT tools: QuickCheck / Hypothesis / fast-check | 🟢 correct; missing jqwik, proptest, RapidCheck (book names them elsewhere) |
| Shrinking | 🟢 correct, and the signature PBT-UX feature |
| Fuzzing tools: AFL++, libFuzzer, OSS-Fuzz | 🟢 correct; libFuzzer is in maintenance mode; OSS-Fuzz is a *service*, not an engine (minor category slip) |
| "Property-Based Fuzzing" blur | 🟢 correct, if anything understated (see below) |

## Key findings

### Convergence is now mainstream (🟢 primary)
- **Google FuzzTest** — "property-based tests executed using coverage-guided fuzzing under the hood"; `FUZZ_TEST` macro beside `TEST`; "has replaced the old style of writing fuzz targets" at Google, "successor of libFuzzer." The clearest single "the two have merged" example.
- **HypoFuzz** (Hypothesis suite run as a coverage-guided fuzzer), **Atheris** (Python, Google, interops with Hypothesis), **Jazzer** (JVM, JUnit 5 `@FuzzTest`).
- **Native fuzzing** made it ambient: **Go** built-in since 1.18 (`func FuzzXxx(f *testing.F)`), **Rust** `cargo-fuzz` + `arbitrary`, **.NET** SharpFuzz — fuzz test lives beside unit tests, runs in the same command.
- Framing for the chapter: PBT and fuzzing are **two points on one spectrum** ("generate inputs, check an oracle you didn't hand-write"); cross-reference the existing property-based-testing paragraph, don't repeat.

### LLM-generated fuzz harnesses — the agentic unlock (🟢 technique; 🟡 figures self-reported/single-paper)
The expensive part of fuzzing is writing the harness; LLMs now do it at scale.
- **OSS-Fuzz-Gen** (Google) — multi-agent LLM pipeline; across **272 C/C++ projects**, LLM harnesses added **370,000+ newly-covered lines**, **up to +29% line coverage over human-written harnesses**; advanced mode **closes the loop** (run fuzzer → feed coverage back → ask for a better harness / seeds).
- **HarnessAgent** (arXiv 2512.03420) — ~87% (C) / 81% (C++) three-shot success; >75% of generated harnesses raise target coverage >10%.
- **SAFuzz** (arXiv 2602.11209) — fuzzing aimed at LLM-generated code. **FuzzingBrain V2** (arXiv 2605.21779) — multi-agent vuln discovery on OSS-Fuzz infra.

### Why fuzzing belongs under "The oracle problem" (🟡 synthesis, consistent with chapter)
1. Oracle defined independently of the implementation — crash / hang / sanitizer trip / violated property is a failure the agent can't edit away.
2. Explores the paths example-based suites miss — directly attacks the chapter's "100% coverage, 13 surviving mutants" failure; decisive for parsers/decoders/deserializers/protocol handlers.
3. Pairs with sanitizers (ASan/UBSan) → precise located bug (cross-ref C/C++ section).
4. Differential fuzzing (new impl vs reference on the same inputs) — a cheap oracle for a refactor/reimplementation an agent can set up.
- **Reward-hacking risk:** an agent told to "add a fuzz target" can write a harness that decodes the input and does nothing — the fuzzing analogue of an assertion-free test. Check: does the harness actually drive new coverage? (OSS-Fuzz-Gen's loop measures this.)

## What this means for `src/quality.md` (done in this run)

New `#### Fuzzing` subsection under `## Testing` › `### The oracle problem`, after "Mutation
testing and property-based testing as defenses", ~2 paragraphs:
1. Fuzzing and PBT as one spectrum; the difference; the convergence (FuzzTest, HypoFuzz, Go/Rust
   native); where it fits (untrusted-input boundaries).
2. Agentic angle: the harness is now agent-drafted (OSS-Fuzz-Gen +29% / 272 projects / coverage
   feedback loop); short seeded run in CI, continuous out-of-band for critical parsers; pairs
   with sanitizers; the trivial-harness reward-hacking risk + its check.

Research Note: LLM harness generation at scale is Google-reported + a couple of arXiv papers —
real, not broadly independently replicated; coverage figures self-reported.

Glossary: add **Fuzzing (fuzz testing)**; **Coverage-guided fuzzing** and **Property-based
testing** entries already exist — cross-link.
