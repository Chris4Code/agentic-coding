# 2026-08-30 · Run 4 · quality · c-cpp-ecosystem-qa-tools

**Type:** deep-book-research pass, scoped to the C and C++ ecosystem for the "Per-ecosystem
stacks" subsection of `src/quality.md`.

**Triggering request:** "Please do some deep-book-research for C++ and C ecosystem tools in the
'Per-ecosystem stacks' section and extend the section with the findings."

**Seed:** the existing `### Per-ecosystem stacks` table in `src/quality.md` (drafted run 1) covers
JS/TS, Python, Rust, Java, Go — but has no C/C++ row. The table columns are Lint/format · Types ·
Test · Mutation/property · Security.

**Prior art consulted:**
- `src/quality.md` as it stands after runs 1–3.
- `notes/2026-08-30-1-quality-agentic-qa-methods-deep-research/` — the oracle-problem, mutation-
  testing, non-functional-testing, and CI material this extends.
- `notes/2026-08-30-3-quality-ci-cd-enforcement-fact-check/` — the pipelines-as-code / inner-loop
  material (ccache, compile_commands.json parallels the C/C++ build-speed finding).

**Subtopics targeted (one research pass each):**
1. C/C++ compilers and warnings-as-errors as the static-analysis / "type checker" gate
2. Linters and static analyzers — clang-tidy, cppcheck, clang static analyzer, PVS-Studio, Coverity, include-what-you-use
3. Sanitizers and dynamic analysis — ASan, UBSan, TSan, MSan, LeakSanitizer, Valgrind/Memcheck
4. Fuzzing — libFuzzer, AFL++, Honggfuzz, OSS-Fuzz/ClusterFuzz, LLM-generated fuzz targets
5. Test frameworks — GoogleTest, Catch2, doctest, Boost.Test, CTest
6. Mutation and property testing — Mull (LLVM-IR), RapidCheck
7. Build system and inner-loop speed — CMake + Ninja, compile_commands.json, ccache, incremental builds, clangd MCP
8. Bounded model checking / formal verification — CBMC, ESBMC — and the "no single tier is sufficient" finding
9. Safety-critical coding standards — MISRA C:2012 / MISRA C++, AUTOSAR — and whether agents can be held to them

**Output:** `notes/2026-08-30-4-quality-c-cpp-ecosystem-qa-tools/`
(`raw-*` + `summary-*` pair), plus an added C/C++ row and a new C/C++-specific subsection in
`src/quality.md`'s "Per-ecosystem stacks", with matching glossary entries.
