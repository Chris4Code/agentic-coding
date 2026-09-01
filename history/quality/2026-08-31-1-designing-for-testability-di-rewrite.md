# 2026-08-31 · Run 1 · quality · designing-for-testability-di-rewrite

**Type:** developmental/structural edit of the existing `### Designing for testability` subsection
in `src/quality.md`. No new research pass — this run reworks prose against notes already on disk,
so it produces no `notes/` folder of its own.

**Triggering request:** the user asked to read
`notes/2026-08-30-5-quality-di-testability-for-agents` and `notes/initial-notes/Fuzzing.md` and
rewrite the "Designing for testability" section of `quality.md`, with explicit instruction to
"also focus on the importance of Dependency Injection for better testability" — i.e. DI was
under-weighted in the run-5 draft, which treated it as one clause inside a rules-file bullet.

**Sources consulted:**
- `notes/2026-08-30-5-quality-di-testability-for-agents/raw-*.md` and `summary-*.md` (run 5) —
  re-read in full; the raw file's §3 (the seam ladder: pure functions → constructor injection →
  parameter injection → container) and §1's LLM-client sub-case were present in the notes but
  had not made it into the run-5 prose.
- `notes/initial-notes/Fuzzing.md` — property-based testing vs fuzzing; used only for the link
  back to the preceding `#### Fuzzing` and property-testing subsections (a seam is the
  precondition for in-process generative testing).
- `src/quality.md` as it stood after run 6, and `src/glossary.md`.

**Scope of the edit:**
1. Promote DI from a passing mention to the section's spine: new `#### Dependency injection is
   the seam` sub-subsection carrying the seam definition, the four-rung ladder, and a
   before/after mermaid diagram (coupled construction vs. injected boundary with two wirings).
2. Restore from the notes: the fuller 2602.00409 corpus figures (1.2M commits / 2,168 repos /
   48,563 agent commits; 23% vs 13% test-file commits) and the "code under test is itself an
   agent → inject the LLM client" sub-case (SitePoint 2026).
3. Split the enforcement material into `#### Making it stick` (rules file incl. mocking guidance,
   deterministic boundary checks, ship-the-fakes) and the counter-narrative into
   `#### Two ways this backfires` (test-induced design damage; container magic vs explicit wiring).
4. Connect the section back to the oracle-problem subsections above it.

**Follow-on corrections in the same run** (from the user's review questions on the resulting prose;
each expanded a claim the draft had stated but not supported):
- How an agent mocks coupled code at all — named the actual substitution point (module registry /
  class loader: `unittest.mock.patch`, `jest.mock`, Mockito `mockStatic`), and noted the study's
  TS/JS/Python corpus is where that hook is cheapest.
- Why mock-everything tests do not check behaviour — stubs encode unverified assumptions; only the
  interaction is left to assert. Introduced *change-detector test*.
- What "verifies through actual state" means for a fake — state assertion vs call transcript, and
  contract-testing the fake against the real adapter.
- **Section placement fix (different section):** the CodeRabbit 470-PR defect-density figure was
  sitting under "Whether automated review catches real bugs or mostly adds noise is contested" in
  *Code review and walkthroughs for agent output*, where it is a non-sequitur — it measures the
  defect density of AI-*authored* code, not the efficacy of AI review. Verified against
  [The Register, 17 Dec 2025](https://www.theregister.com/2025/12/17/ai_code_bugs/) (confirms
  AI-authored, not AI-reviewed), then moved to `### What the data shows` beside GitClear/DORA, and
  the source's self-acknowledged limitation ("cannot be certain that PRs labeled as human-authored
  actually were exclusively authored by humans") added to the bullet and that section's
  Research Note.

**Glossary (same change):** added *Composition root*, *Seam (testable seam)*, *Testcontainers*,
*Test-induced design damage*, *Change-detector test*; extended the existing
*Dependency injection (DI)* entry with the means-vs-end framing and the ladder.
