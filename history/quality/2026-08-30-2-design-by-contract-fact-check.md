# 2026-08-30 · Run 2 · quality · design-by-contract-fact-check

**Type:** fact-check + `edit-chapter`-style rewrite, scoped to the Design by Contract section of `src/quality.md`.

**Triggering request:** "Please fact-check the notes contained in `sw-qa-and-dbc.md` and rewrite the
Design by Contract sections using new findings. Also explain (1) the differences to Spec Driven
Development and the traditional Design by Contract method and (2) the challenges (i.e. drift
between current code and specs) in daily use."

**Seed / sources consulted:**
- `notes/initial-notes/sw-qa-and-dbc.md` — the ungrounded AI research chat being fact-checked
  (covers: common SQA methods, DbC as a QA method, DbC language tooling by tier, using agents to
  substitute for missing DbC tooling, and SDD spec-drift).
- The DbC section already drafted in `src/quality.md` by run 1
  (`2026-08-30-1-quality-agentic-qa-methods-deep-research`).
- Live web research (August 2026) — see the raw note for the full source list.

**Subtopics targeted:**
1. DbC language-tooling landscape (Eiffel/Ada/D/Clojure native; Java/C#/Python/TS library) — verify each named tool's real name and maintenance state.
2. DbC and LLM code generation — the evidence that contracts help, and the benchmarks.
3. DbC vs Spec-Driven Development vs traditional (Eiffel-era) DbC — how the three differ.
4. Spec-code drift in agentic SDD — causes, "two specs" problem, spec-first vs spec-anchored, behavioral/agent drift.
5. Drift mitigations — drift gates, executable contracts in CI, deterministic guardrails (ArchUnit-style), durable memory.

**Output:** `notes/2026-08-30-2-quality-design-by-contract-fact-check/`
(`raw-*` + `summary-*` pair), plus the rewritten `## Design by Contract` section of `src/quality.md`
and matching glossary entries.
