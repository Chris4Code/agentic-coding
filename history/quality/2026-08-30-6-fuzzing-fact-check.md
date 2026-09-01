# 2026-08-30 · Run 6 · quality · fuzzing-fact-check

**Type:** fact-check + section addition to `src/quality.md`.

**Triggering request:** "Please fact-check my findings contained in `notes/initial-notes/Fuzzing.md`
and add Fuzzing to the 'Testing' section (wherever it might fit)."

**Seed:** `notes/initial-notes/Fuzzing.md` — a single Q&A ("Is property-based testing the same as
fuzzing?") with a PBT-vs-fuzzing comparison table, tooling lists, and a "property-based fuzzing"
convergence note. Plus the existing `## Testing` section of `src/quality.md` (runs 1, 5, and the
run-just-before that restructured it into `### The oracle problem` / `### Designing for
testability`).

**Prior art consulted:**
- `notes/2026-08-30-4-quality-c-cpp-ecosystem-qa-tools/` — already covers libFuzzer, AFL++,
  Honggfuzz, OSS-Fuzz/ClusterFuzz, LLM fuzz-target generation, FuzzingBrain V2, and the
  fuzzing+sanitizers combo for C/C++.
- `notes/2026-08-30-1-quality-agentic-qa-methods-deep-research/` — the oracle-problem and
  mutation/property-testing material this sits next to.
- `src/quality.md` `#### Mutation testing and property-based testing as defenses`.

**Subtopics targeted:**
1. Property-based testing vs fuzzing — the real distinction and where the note's table is right/loose.
2. Property-based fuzzing convergence — Google FuzzTest, HypoFuzz, Atheris, Jazzer.
3. Coverage-guided engines and native-language fuzzing — libFuzzer (maintenance), AFL++, Go `testing.F`, `cargo-fuzz`.
4. LLM-generated fuzz harnesses — OSS-Fuzz-Gen (multi-agent), HarnessAgent, SAFuzz, the coverage feedback loop.
5. Fuzzing as an oracle for agent-written code — why it catches what example tests miss, and the trivial-harness reward-hacking risk.

**Output:** `notes/2026-08-30-6-quality-fuzzing-fact-check/` (`raw-*` + `summary-*`), plus a
`#### Fuzzing` subsection under `## Testing` › `### The oracle problem` in `src/quality.md`, with
a glossary entry.
