# Research pass: C and C++ QA tooling for agentic coding

Date: 2026-08-30 · run 4 · chapter `src/quality.md`
Skill: deep-book-research (manual pass)

Scope: material for a C/C++ row and a C/C++-specific subsection in the `### Per-ecosystem stacks`
part of `src/quality.md`. The organising question, as everywhere in this chapter: **what changes
about C/C++ QA when an agent writes the code?** Short answer — C and C++ have no memory-safety
net, the compiler and a passing test suite certify much less than they do in Rust/Go/Python, and
2026 evidence says agent-written C++ trips runtime memory-safety violations markedly more often
than human code. So the C/C++ agent loop needs verification *tiers* the other rows collapse into
one column, and it needs them fast despite slow builds.

**Training-cutoff caveat:** assistant knowledge ends January 2026; today is August 2026.
Post-cutoff items web-verified August 2026: "The Illusion of Safety" / VULBENCH-CPP
(arXiv 2607.00107), "Broken by Default" (arXiv 2604.05292), the Codex-CLI-for-C++ workflow
write-up (26 Apr 2026), OSS-Fuzz's LLM fuzz-target generation, FuzzingBrain V2. Tool version
details (clang-tidy check count, CBMC C23 support) checked against current project docs.

---

## 1. Compiler warnings as the static-analysis / "type checker" gate

C and C++ have no separate type-checker step the way TS (`tsc`) or Python (`mypy`) do — the
compiler *is* the type checker, and by default it is far too permissive. The agentic baseline is
to turn the compiler into a strict gate:

- `-Wall -Wextra -Wpedantic` and, for a gate, `-Werror` (warnings become build failures).
- `-Wconversion -Wsign-conversion` — catches the signed/unsigned and narrowing-conversion
  mistakes that recur in AI-generated C ([see §8](#8-what-ai-gets-wrong-in-cc-the-2026-evidence)).
- `-Wshadow`, `-Wold-style-cast` (C++), `-Wcast-align`, `-Wformat=2`.
- Hardening that also surfaces bugs at runtime: `-D_FORTIFY_SOURCE=3`, `-D_GLIBCXX_ASSERTIONS`
  (libstdc++) / `-D_LIBCPP_HARDENING_MODE=…` (libc++), `-fstack-protector-strong`.
- MSVC equivalent: `/W4 /WX`, `/analyze` (built-in static analysis), `/sdl`.

For an agent this is the direct analogue of the type-checker feedback loop the chapter's
[static-analysis section](#) describes: a structured, precisely-located, deterministic error the
agent reads and fixes before yielding. It is also cheap — no extra tool, just flags.

Evidence: primary (GCC/Clang/MSVC docs). Well established; the "warnings as errors" discipline
predates agents but matters more now because the agent won't notice a warning it isn't forced to.

## 2. Linters and static analyzers

| Tool | What it is | Agentic notes |
|---|---|---|
| **clang-tidy** | Clang-AST-based linter + static analyzer; hundreds of checks across `bugprone-*`, `modernize-*`, `performance-*`, `readability-*`, `cert-*`, `concurrency-*`, plus partial `misra-*`/`cppcoreguidelines-*` | The workhorse. **Autofix** via `--fix`/`--fix-errors`. `clang-tidy-diff.py` runs only on changed lines (fast, review/CI-friendly); `run-clang-tidy -j$(nproc)` parallelises a full pass. **Needs `compile_commands.json`.** Can also run Clang Static Analyzer checks inline. |
| **Clang Static Analyzer** (`scan-build`, or via clang-tidy `clang-analyzer-*`) | Path-sensitive symbolic execution — null deref, leaks, use-after-free, uninitialised reads | Deeper but slower — nightly / pre-merge, not per-iteration. |
| **cppcheck** | Independent static analyzer, own engine | **No compile database required** — works on a bare Makefile project. Fast enough for per-commit on 1M+ LOC. `--addon=misra` covers MISRA-C:2012 (free, not certified). Good default when clang tooling isn't set up. |
| **include-what-you-use (IWYU)** | Flags missing/unnecessary `#include`s | Keeps agent-added code from silently depending on transitive includes. |
| **PVS-Studio / Coverity / CodeSonar / Klocwork / Parasoft / Helix QAC / LDRA** | Commercial, deep, certified for MISRA/AUTOSAR/CERT and safety standards | Nightly/pre-release. Certified checker sets matter for regulated domains where a free tool's output isn't accepted. |
| **Meta Infer** | Interprocedural analysis (null-deref, resource leaks, some concurrency) | Still used; less active public momentum than clang-tidy. Fast enough for CI on diffs. |
| **Semgrep / CodeQL** | Pattern / dataflow SAST, both support C/C++ | Semgrep MCP server exposes rules to the agent ([chapter's SAST discussion](#)); CodeQL is the deep-dataflow option in GitHub CI. |

Key point for the chapter: **clang-tidy + cppcheck is the free baseline**, clang-tidy needs
`compile_commands.json` (which the agent needs anyway for code intelligence — see §7), and
autofix means the agent can clear most lint findings itself.

Evidence: primary (tool docs); the CI-cadence advice (cppcheck per-commit, analyzer nightly) is
corroborated across multiple 2026 tool-comparison write-ups (secondary but consistent).

## 3. Sanitizers and dynamic analysis — the part the table undersells

Sanitizers are compiler instrumentation that turns latent undefined behaviour into an immediate,
located crash when exercised by a test. They are the single most important addition to a C/C++
agent loop, because they catch exactly the bug classes the compiler and a green test suite miss.

- **AddressSanitizer (ASan)** — heap/stack/global buffer overflows, use-after-free,
  use-after-return, double-free, leaks (via LeakSanitizer). ~2× slowdown, ~2–3× memory.
- **UndefinedBehaviorSanitizer (UBSan)** — signed overflow, invalid shifts, null deref,
  misaligned pointers, bad enum/bool values, `-fsanitize=integer` for unsigned wraparound. Low
  overhead; pairs with ASan (`-fsanitize=address,undefined`).
- **ThreadSanitizer (TSan)** — data races. Separate build (incompatible with ASan). Essential
  the moment agent code touches threads/atomics.
- **MemorySanitizer (MSan)** — reads of uninitialised memory. Needs an MSan-instrumented libc++
  to avoid false positives, so it's higher-friction; Clang-only.
- **Valgrind / Memcheck** — no recompile needed, so it's the fallback for third-party binaries or
  build systems you can't touch; ~10–50× slowdown, so not per-iteration.

**The agentic pattern**: maintain a dedicated build configuration with
`-fsanitize=address,undefined -fno-omit-frame-pointer -g`, and run the test suite under it as a
gate *before the agent yields* — not just "it compiled and tests pass." The
[Codex-CLI-for-C/C++ workflow](https://codex.danielvaughan.com/2026/04/26/codex-cli-cpp-teams-cmake-clangd-mcp-memory-safe-agent-workflows/)
(Daniel Vaughan, 26 Apr 2026) wires this literally: a `PostToolUse` hook runs
`cmake --build build -j4` after every edit ("catching compile errors immediately"), and a second
hook runs the tests under ASan/UBSan after any test command and **blocks the agent from
progressing if a sanitizer trips**. Its stated rule: *"Always run tests under sanitisers before
marking work complete"*, and *"Hooks inject deterministic checks into the agent loop."* The
`AGENTS.md` in that setup also encodes coding-standard constraints — *"smart pointers, RAII, no
raw `new`/`delete`"* — as rules the agent loads every session.

Sanitizers only catch what a test actually executes — which is why fuzzing (§4) and bounded model
checking (§6) are complementary, not redundant.

Evidence: primary (Clang/GCC sanitizer docs) for the tools; the "wire it as a blocking hook"
pattern is primary-sourced to one detailed practitioner write-up and consistent with the
chapter's existing hook material — call it convergent practice, not a study.

## 4. Fuzzing — coverage-guided, and now agent-assisted

- **libFuzzer** — in-process, coverage-guided, links against the library; you write a
  `LLVMFuzzerTestOneInput(const uint8_t*, size_t)` entrypoint. Now in maintenance mode within
  LLVM but still widely used.
- **AFL++** — out-of-process, coverage-guided, the actively-developed community successor to AFL;
  persistent mode approaches libFuzzer speed.
- **Honggfuzz** — third engine, also supported by OSS-Fuzz.
- **OSS-Fuzz + ClusterFuzz** — Google's continuous-fuzzing service for open source; runs
  libFuzzer/AFL++/Honggfuzz **in combination with sanitizers** at scale. As of May 2025,
  credited with **13,000+ vulnerabilities and 50,000+ bugs fixed across 1,000+ projects**
  ([google/oss-fuzz](https://github.com/google/oss-fuzz)).
- **LLM fuzz-target generation** — OSS-Fuzz has a documented pipeline using LLMs to write the
  fuzz harnesses that previously took "several hours of manual work"
  ([google.github.io/oss-fuzz/research/llms/target_generation](https://google.github.io/oss-fuzz/research/llms/target_generation/));
  research systems like **FuzzingBrain V2** ([arXiv 2605.21779](https://arxiv.org/pdf/2605.21779))
  are multi-agent LLM setups for vuln discovery + reproduction on top of that infrastructure.

Agentic angle: writing a fuzz harness for a parser / deserialiser / any untrusted-input boundary
is now something the agent can draft, and a fuzz run (even a short one in CI) catches the
edge-case and untested-path memory bugs that a hand-written test suite structurally won't. This
is the C/C++ analogue of property-based testing — the input space is explored adversarially
rather than by example.

Evidence: primary (LLVM docs, OSS-Fuzz repo/docs). The 13k/50k/1k figures are OSS-Fuzz's own
(self-reported, but a long-running and widely-cited project).

## 5. Test frameworks

- **GoogleTest (gtest/gmock)** — the de-facto default; rich matchers, death tests, parameterised
  and typed tests, built-in mocking.
- **Catch2** — header-heavy (v2) / modular (v3), `BDD`-style `SCENARIO`/`GIVEN`/`WHEN`/`THEN`,
  simple to drop in.
- **doctest** — the fastest to compile (matters for the inner loop, §7); API close to Catch2;
  can live in the same TU as the code.
- **Boost.Test** — full-featured, common in Boost-heavy codebases.
- **CTest** — CMake's test *runner* (not a framework); registers test binaries, does sharding,
  timeouts, `--output-on-failure`, and is the usual "one command" entrypoint (`ctest --test-dir
  build`). Also drives running the suite under different sanitizer builds.

No agent-specific change here except: **doctest / a fast framework helps** because every agent
iteration recompiles test code, and gtest's compile cost is real on large suites.

Evidence: primary (framework docs). Uncontroversial.

## 6. Mutation and property testing

- **Mull** ([mull-project/mull](https://github.com/mull-project/mull)) — "practical mutation
  testing and fault injection for C and C++", operates on **LLVM IR** and uses LLVM JIT, so it
  only recompiles the mutated IR fragment rather than the whole program — much faster than
  source-level mutation. Works for anything that lowers to LLVM IR (C, C++, Rust, Swift, Obj-C).
  Original paper: [arXiv 1908.01540](https://arxiv.org/abs/1908.01540); Clang-front-end
  optimisation follow-up [arXiv 2210.17215](https://arxiv.org/pdf/2210.17215).
- **Dextool mutate** — source-to-source mutation testing for C/C++, LLVM-independent, SQLite
  result DB, good for continuous use on a big codebase.
- **RapidCheck** — QuickCheck-style **property-based testing** for C++; generators + shrinking,
  integrates with GoogleTest/Catch2/Boost.Test. The C/C++ answer to Hypothesis/proptest.
- **rc / trompeloeil** — trompeloeil is a mocking framework, adjacent.

Same argument as the chapter's [mutation-testing section](#): an AI-generated C++ suite can hit
high line coverage while verifying little, and a mutation score (via Mull) is the check that
catches it. RapidCheck properties give the agent an oracle it can't overfit.

Evidence: primary (Mull repo/paper, RapidCheck repo). Mull is the notable one — its IR-level
approach is what makes mutation testing practical on C++ compile times.

## 7. Build system and inner-loop speed — the real bottleneck

For most languages in the table, the inner loop is seconds. For C/C++ a naïve full rebuild is
minutes, which would make the agent loop unusable. The required setup:

- **`compile_commands.json`** — the compilation database. `cmake -B build -G Ninja
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` (or Bear for non-CMake builds). Needed by clang-tidy, by
  clangd, and — per the Codex write-up — *"Without a compilation database … the agent cannot
  resolve includes, macros, or template instantiations accurately."* It is the C/C++ equivalent
  of having a working language server for the agent.
- **clangd (as an MCP server)** — gives the agent go-to-definition, type-on-hover, and
  diagnostics across translation units. The Codex setup registers a **Clangd MCP server**.
- **ccache** (or sccache) — compiler cache; second/warm builds **10–30× faster**; enabled in
  CMake with `-DCMAKE_CXX_COMPILER_LAUNCHER=ccache`.
- **Ninja** over Make; **incremental builds** (`cmake --build build` touches only what changed);
  optionally `-DCMAKE_UNITY_BUILD=ON`, precompiled headers, `mold`/`lld` linker, split debug
  info.
- Net effect: the agent must be *told* (in `AGENTS.md`) to use the incremental build target and
  not `rm -rf build`, or it will trigger a cold rebuild every iteration.

Evidence: primary (CMake/ccache/clangd docs) + the Codex-CLI-for-C++ write-up (practitioner,
detailed, single-source but concrete). The ccache speedup range is widely reported.

## 8. What AI gets wrong in C/C++ — the 2026 evidence

- **"The Illusion of Safety: Multi-Tier Verification of AI vs. Human C++ Code"**
  ([arXiv 2607.00107](https://arxiv.org/abs/2607.00107); benchmark "VULBENCH-CPP"). **8,918 C++
  programs**, three open-weight LLMs (Gemma 3 27B, Llama 3.3 70B, Qwen 2.5 Coder 32B) + human
  authors, **851 competitive-programming tasks**. Four verification tiers: functional testing,
  static analysis (cppcheck, clang-tidy), dynamic analysis (ASan/UBSan), bounded model checking
  (ESBMC). Findings, quoted:
  - AI code is *"roughly twice as likely as human code to trigger a confirmed runtime
    violation, even after adjusting for code length and test pass-rate."*
  - *"under static analysis the two look equally safe, but this is misleading"* — the apparent
    parity reflects code-length differences, not real safety.
  - *"the tiers detect largely different classes of violation, demonstrating that no single tier
    is sufficient"* — sanitizers and bounded model checking caught different bugs (runtime
    overflows vs edge-case bugs on untested paths).
  - *"vulnerability patterns remain consistent across independent generations"* — systematic,
    not random.
  - Caveat: competitive-programming-sized programs, open-weight (not frontier) models — the
    absolute rates may not transfer to production codebases or Claude/GPT-class models, but the
    *direction* and the *"no single tier"* conclusion are the load-bearing parts.
- **"Broken by Default: A Formal Verification Study of Security Vulnerabilities in AI-Generated
  Code"** ([arXiv 2604.05292](https://arxiv.org/pdf/2604.05292); Blain & Noiseux). Uses a Z3-backed
  formal-verification harness. Recurring CWE categories in AI code: **CWE-131 (incorrect
  allocation size)** and **CWE-190 (integer overflow / wraparound)** — i.e. unguarded arithmetic
  in `malloc`/`new[]` size computations and signed/unsigned conversion errors. Dataset:
  `github.com/dom-omg/bbd-dataset`.
- Secondary aggregation (CSA research note, Endor Labs) reports memory-allocation vulnerability
  rates in AI C/C++ output in the "majority of samples" range and ties them to the same
  integer-overflow / signed-unsigned root causes — directionally consistent with the two studies
  above; treat specific percentages from these as secondary.

**Takeaway for the chapter:** the C/C++ row can't just be a list of tools like the other rows —
it has to say *why* the extra tiers are non-optional (compiler + green tests certify much less
here) and *which* tiers catch *what* (warnings → conversions; sanitizers → executed-path memory
bugs; fuzzing → untested-path/edge-case; BMC → bounded proof of pointer/array safety).

Evidence: 2607.00107 and 2604.05292 are primary (arXiv, with public datasets). The exact
multiplier ("~2×") is from one study on one class of programs — flag as such.

## 9. Safety-critical coding standards

- **MISRA C:2012** (with 2023 amendments) and **MISRA C++:2023** (which supersedes MISRA C++:2008
  and AUTOSAR C++14, now merged) — rule sets for critical systems.
- Free enforcement: **cppcheck `--addon=misra`** (MISRA-C:2012, not certified), clang-tidy
  `misra-*` / `cppcoreguidelines-*` (partial), the Wildcop clang-analyzer plugin.
- Certified enforcement: **Coverity, CodeSonar, PVS-Studio, Helix QAC, LDRA, Parasoft C/C++test**
  — required where an auditor won't accept an uncertified tool's output.
- Agentic angle: a rules file (`AGENTS.md`) can tell the agent the standard, but MISRA
  conformance is not something to trust the agent to self-assess — it's a gate a certified
  analyzer owns, and deviations need documented sign-off. This is the C/C++ instance of the
  chapter's general "deterministic checks the agent can't argue with" principle.

Evidence: primary (MISRA, tool docs). MISRA C++:2023 merging AUTOSAR is the notable update.

---

## Sources

1. The Illusion of Safety: Multi-Tier Verification of AI vs. Human C++ Code (VULBENCH-CPP) — https://arxiv.org/abs/2607.00107
2. Broken by Default: A Formal Verification Study of Security Vulnerabilities in AI-Generated Code — https://arxiv.org/pdf/2604.05292
3. Codex CLI for C and C++ Teams: CMake, Clangd MCP, Sanitisers, and Memory-Safe Agent Workflows (Daniel Vaughan, 26 Apr 2026) — https://codex.danielvaughan.com/2026/04/26/codex-cli-cpp-teams-cmake-clangd-mcp-memory-safe-agent-workflows/
4. Clang-Tidy documentation — https://clang.llvm.org/extra/clang-tidy/
5. cppcheck — https://cppcheck.sourceforge.io/
6. Clang sanitizers (AddressSanitizer, UndefinedBehaviorSanitizer, ThreadSanitizer, MemorySanitizer) — https://clang.llvm.org/docs/AddressSanitizer.html
7. libFuzzer — https://llvm.org/docs/LibFuzzer.html
8. AFL++ — https://github.com/AFLplusplus/AFLplusplus
9. OSS-Fuzz (engines, sanitizers, impact figures) — https://github.com/google/oss-fuzz
10. OSS-Fuzz — Fuzz target generation using LLMs — https://google.github.io/oss-fuzz/research/llms/target_generation/
11. FuzzingBrain V2: A Multi-Agent LLM System for Automated Vulnerability Discovery and Reproduction — https://arxiv.org/pdf/2605.21779
12. Mull — practical mutation testing for C and C++ — https://github.com/mull-project/mull ; paper https://arxiv.org/abs/1908.01540
13. RapidCheck — property-based testing for C++ — https://github.com/emil-e/rapidcheck
14. GoogleTest — https://github.com/google/googletest ; Catch2 — https://github.com/catchorg/Catch2 ; doctest — https://github.com/doctest/doctest
15. CBMC — C Bounded Model Checker — https://github.com/diffblue/cbmc ; arXiv 2302.02384
16. ESBMC — https://github.com/esbmc/esbmc
17. ccache — https://ccache.dev/ ; clangd — https://clangd.llvm.org/
18. include-what-you-use — https://include-what-you-use.org/
19. MISRA — https://misra.org.uk/ ; cppcheck MISRA addon — https://github.com/danmar/cppcheck/tree/main/addons
20. Static Analysis Tools for Embedded C and C++ (2026 comparison, secondary) — https://interpretica.io/research/static-analysis-tools-embedded-cpp-2026/
21. CSA research note — AI-Generated Code Vulnerability Surge 2026 (secondary) — https://labs.cloudsecurityalliance.org/research/csa-research-note-ai-generated-code-vulnerability-surge-2026/
