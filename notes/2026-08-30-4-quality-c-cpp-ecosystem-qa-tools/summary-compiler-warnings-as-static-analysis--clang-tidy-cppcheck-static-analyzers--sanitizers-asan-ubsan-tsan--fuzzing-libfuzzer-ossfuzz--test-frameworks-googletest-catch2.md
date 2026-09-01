# Summary: C and C++ QA tooling for agentic coding

Distilled index for [`raw-compiler-warnings-as-static-analysis--clang-tidy-cppcheck-static-analyzers--sanitizers-asan-ubsan-tsan--fuzzing-libfuzzer-ossfuzz--test-frameworks-googletest-catch2.md`](./raw-compiler-warnings-as-static-analysis--clang-tidy-cppcheck-static-analyzers--sanitizers-asan-ubsan-tsan--fuzzing-libfuzzer-ossfuzz--test-frameworks-googletest-catch2.md).

**Map, not source.** Pull exact figures and citations from the raw file. Research pass to add a
C/C++ row + subsection to `### Per-ecosystem stacks` in `src/quality.md`.

Tags: 🟢 primary / well corroborated · 🟡 secondary / mixed · 🟠 single-source or speculative.

## The core reason C/C++ needs its own treatment

C and C++ have **no memory-safety net**. The compiler plus a green test suite certify far less
than they do in Rust/Go/Python/TS, and 2026 evidence says agent-written C++ trips runtime
memory-safety violations markedly more than human code. So the C/C++ agent loop needs several
verification **tiers** that the other table rows fold into one column — and it needs them fast
despite slow builds.

## The 2026 evidence (🟢 primary, one study per claim)

- **VULBENCH-CPP** ([arXiv 2607.00107](https://arxiv.org/abs/2607.00107), "The Illusion of
  Safety"): 8,918 C++ programs, 3 open-weight LLMs + humans, 851 competitive-programming tasks,
  4 verification tiers (functional test / static analysis / ASan+UBSan / ESBMC bounded model
  checking).
  - AI code *"roughly twice as likely as human code to trigger a confirmed runtime violation,
    even after adjusting for code length and test pass-rate."*
  - *"under static analysis the two look equally safe, but this is misleading."*
  - *"the tiers detect largely different classes of violation … no single tier is sufficient."*
  - *"vulnerability patterns remain consistent across independent generations"* (systematic).
  - ⚠️ competitive-programming-sized programs, open-weight models — the ~2× may not transfer to
    production code or frontier models; the *direction* and *"no single tier"* are the durable
    parts.
- **"Broken by Default"** ([arXiv 2604.05292](https://arxiv.org/pdf/2604.05292)): Z3-backed formal
  verification; recurring CWEs in AI C code = **CWE-131 (incorrect allocation size)** and
  **CWE-190 (integer overflow)** — unguarded arithmetic in `malloc`/`new[]` sizes, signed/unsigned
  conversion errors.
- 🟡 CSA / Endor Labs secondary notes report memory-allocation vuln rates in the "majority of
  samples" range with the same root causes — directionally consistent; don't quote their exact %.

## Tool landscape (🟢 primary — tool docs)

| Tier | Tools | Agentic note |
|---|---|---|
| Compiler as gate | `-Wall -Wextra -Wpedantic -Werror`, `-Wconversion -Wsign-conversion`, `-D_FORTIFY_SOURCE=3`, `-D_GLIBCXX_ASSERTIONS`; MSVC `/W4 /WX /analyze` | Free, deterministic, precisely located — the C/C++ "type-checker loop." `-Wconversion` targets the exact integer-overflow class AI gets wrong. |
| Lint / static analysis | **clang-tidy** (hundreds of checks, `--fix` autofix, `clang-tidy-diff.py` on changed lines, needs `compile_commands.json`), **cppcheck** (no compile DB, fast per-commit, `--addon=misra`), Clang Static Analyzer / `scan-build` (nightly), include-what-you-use, Meta Infer; commercial: Coverity, PVS-Studio, CodeSonar, Helix QAC, LDRA | clang-tidy + cppcheck = free baseline. |
| Sanitizers (dynamic) | **ASan** (buffer overflow, UAF, leaks), **UBSan** (signed overflow, bad shifts, null deref; `-fsanitize=integer`), **TSan** (data races, separate build), **MSan** (uninit reads, Clang + instrumented libc++), **Valgrind/Memcheck** (no recompile, slow) | **The most important addition.** Run the suite under `-fsanitize=address,undefined` as a gate *before the agent yields*. |
| Fuzzing (coverage-guided) | **libFuzzer** (in-process, maintenance mode), **AFL++** (actively developed), Honggfuzz; **OSS-Fuzz + ClusterFuzz** (runs all three + sanitizers; 13k+ vulns / 50k+ bugs / 1k projects, May 2025); LLM fuzz-target generation in OSS-Fuzz | Agent can draft the fuzz harness for parsers / untrusted-input boundaries; catches untested-path/edge-case memory bugs. C/C++ analogue of property-based testing. |
| Test frameworks | GoogleTest/gmock (default), Catch2, **doctest** (fastest compile → best for the inner loop), Boost.Test; **CTest** as runner / "one command" | doctest's compile speed matters because every iteration recompiles test code. |
| Mutation / property | **Mull** (LLVM-IR mutation — only recompiles the mutated IR fragment, fast on C++ build times), Dextool mutate; **RapidCheck** (property-based, QuickCheck-style, integrates with gtest/Catch2) | Same "high coverage ≠ verified" argument as the chapter's mutation section. |
| Bounded model checking | **CBMC** (diffblue; C89–C23, used on the Linux kernel; array-bounds, pointer safety, user assertions within a loop bound), **ESBMC** (what VULBENCH-CPP used) | Catches a *different* class than sanitizers — edge cases on untested paths. |
| Build / inner loop | `compile_commands.json` (CMake `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` or Bear), **clangd** (ideally as an MCP server — the agent's code intelligence), **ccache** (10–30× warm), Ninja, incremental builds, unity builds / PCH / `mold` | Without this the loop is minutes, not seconds. Tell the agent (AGENTS.md) to use the incremental target and never `rm -rf build`. |
| Safety-critical | MISRA C:2012 / **MISRA C++:2023** (supersedes MISRA C++:2008 + AUTOSAR C++14, now merged); free: cppcheck misra addon, clang-tidy `misra-*`; certified: Coverity, PVS-Studio, Helix QAC, LDRA | MISRA conformance is a certified-analyzer gate, not something to let the agent self-assess. |

## Named-entity / accuracy notes

- 🟢 **Mull** is real and current (`mull-project/mull`); its LLVM-IR approach is what makes C++ mutation testing practical.
- 🟢 **RapidCheck** real (`emil-e/rapidcheck`).
- 🟢 **CBMC** (diffblue/cbmc) real, C23 support, Linux-kernel track record; **ESBMC** real (what the study used).
- 🟢 The **Codex-CLI-for-C/C++ workflow** write-up (Daniel Vaughan, 26 Apr 2026) is the same author cited elsewhere in the chapter for hooks; single-source but concrete and consistent.
- 🟡 **MISRA C++:2023 merging AUTOSAR C++14** — correct as of 2026; worth stating since older sources still say "MISRA C++:2008 / AUTOSAR."
- libFuzzer is in maintenance mode within LLVM — prefer AFL++ for new work; both still fine.

## What this means for `src/quality.md` (done in this run)

1. Add a **C / C++ row** to the `### Per-ecosystem stacks` table.
2. Add a short subsection **"### C and C++: why one column isn't enough"** (or similar) after the
   table, making three points: (a) compiler + green tests certify much less here; (b) the
   VULBENCH-CPP ~2× finding and the "no single tier is sufficient" conclusion; (c) the tier
   ladder — warnings (`-Wconversion`) → sanitizers on every test run → fuzzing on input
   boundaries → bounded model checking — plus the build-speed prerequisite (`compile_commands.json`,
   ccache) without which the loop is unusable.
3. Research Note: the ~2× multiplier is one study on competitive-programming-sized programs with
   open-weight models; the direction and the multi-tier conclusion are the corroborated parts.

Glossary: add **sanitizer (ASan/UBSan/TSan)**, **coverage-guided fuzzing**, **bounded model
checking**; the existing **Mutation testing** / **Property-based testing** entries already cover
Mull/RapidCheck by extension.
