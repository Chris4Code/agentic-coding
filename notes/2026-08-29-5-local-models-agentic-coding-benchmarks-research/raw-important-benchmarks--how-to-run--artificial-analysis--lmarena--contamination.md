# Research pass: agentic-coding benchmarks, how to run them, Artificial Analysis, LMArena, contamination

Date: 2026-08-29 · run 5 · chapter `src/local-models.md`
Skill: deep-book-research (manual pass)

Scope: material for a new **"Benchmarks"** section in `src/local-models.md`. Briefly describe the
benchmarks that matter for local agentic coding and how to run them yourself against a local
endpoint; describe the two aggregator sites **artificialanalysis.ai** and **lmarena.ai**
(user calls the latter "arena.ai" — it is the former LMSYS Chatbot Arena, and the site now
literally redirects `lmarena.ai` → `arena.ai`). Cross-reference `src/sw-factories.md` for the
reward-hacking / weak-oracle evidence rather than repeating it.

**Training-cutoff caveat:** the assistant's knowledge ends January 2026. Everything dated after
that — Terminal-Bench 2.0/2.1, SWE-bench Pro's 2025 paper revision and its Feb-2026 contamination
context, the Artificial Analysis Intelligence Index v4.x line, LMArena's 2026 Series A, model
names appearing on leaderboards ("GPT-5", "DeepSeek-V3.2-Exp", "Claude Opus 4.x") — was checked
by web search in August 2026. Several third-party leaderboard-scraper sites (benchlm.ai,
llm-stats.com, steel.dev, sophon.at, morphllm, codesota) surfaced in searches with confident-looking
model names and scores that could not be traced to a primary source; those are **not cited here**.
Where only such sites carried a number, it is omitted or flagged weak.

---

## 1. The most important benchmarks (2026)

### The must-mention set for an agentic-coding chapter

For a chapter about running open-weight models locally as coding agents, the benchmarks that
actually get quoted on 2025–2026 model cards and that a reader will encounter are, roughly in
order of relevance:

1. **SWE-bench Verified** — the de-facto standard "can it fix a real GitHub issue" number.
2. **SWE-bench Pro** — the harder, partly-held-out successor addressing Verified's contamination.
3. **Terminal-Bench (2.x)** — the standard "can it operate a shell to complete an end-to-end task".
4. **Aider polyglot** — the standard "can it edit multi-language code and emit a valid diff" number.
5. **LiveCodeBench (v5/v6)** — the standard *contamination-controlled* competitive-coding number.
6. **SWE-rebench / SWE-bench-Live** — contamination-resistant, continuously-refreshed SWE-bench.
7. **SWE-bench Multilingual / Multimodal / Multi-SWE-bench** — coverage beyond Python.
8. Legacy/saturated: **HumanEval, MBPP, BigCodeBench** — only meaningful for small local models now.
9. Agentic/computer-use: **OSWorld / OSWorld-Verified** — GUI agents, adjacent not core.
10. Reasoning-adjacent, quoted alongside coding: **GPQA Diamond, AIME, LiveBench**.

### SWE-bench and its variants

**Original SWE-bench** (Jimenez et al., ICLR 2024, Princeton/University of Chicago). 2,294 task
instances mined from 12 popular Python repos (django, sympy, scikit-learn, matplotlib, …). Each
task = a real GitHub issue + the repo state at the PR base commit; the model must produce a patch;
the patch is applied and the repo's own test suite is run, with **FAIL_TO_PASS** tests (must now
pass) and **PASS_TO_PASS** tests (must not regress). Score = **% resolved** (a single attempt,
i.e. pass@1 at the task level). Repo, paper and leaderboards at
[swebench.com](https://www.swebench.com/) and
[github.com/SWE-bench/SWE-bench](https://github.com/SWE-bench/SWE-bench).
`SWE-bench Lite` is a 300-task cheaper subset.

**SWE-bench Verified** — 500-task human-filtered subset, released Aug 2024 by **OpenAI** *"in
collaboration with the original SWE-bench authors"*
([OpenAI announcement](https://openai.com/index/introducing-swe-bench-verified/)). OpenAI hired
**93 professional Python developers** to screen a random 1,699-instance sample and flag tasks with
(a) under-specified problem statements, (b) unit tests that reject valid solutions (too specific /
testing unrelated behaviour), or (c) broken dev environments. The 500 that survive are the
benchmark. OpenAI released the full annotations and states Verified *"supersedes the original
SWE-bench and SWE-bench Lite test sets."* On release, GPT-4o went from 16% (original) to **33.2%**
(Verified) with the Agentless scaffold — the subset is easier per-task because the broken tasks are
gone. This is now **the** headline "agentic coding" number on nearly every frontier and
open-weight model card. **Contamination-resistance: low** — all 500 tasks are from public Python
repos with public fixes; in **February 2026 OpenAI itself published** that frontier models can
reproduce gold patches and problem-statement details verbatim from training data (surfaced
repeatedly in secondary coverage; treat the exact wording as corroborated-secondary until the
OpenAI post is read directly).

**SWE-bench Pro** — Scale AI, paper *"SWE-Bench Pro: Can AI Agents Solve Long-Horizon Software
Engineering Tasks?"* ([arXiv:2509.16941](https://arxiv.org/abs/2509.16941), v2 Nov 2025; lead
authors Xiang Deng, Jeff Da et al.). ~**1,865** long-horizon tasks (hours-to-days of human work,
multi-file patches) across **41 repos**, partitioned into a **public** set (11 repos, ~731 tasks,
released), a **held-out** set (12 repos, ~858 tasks, never released — leaderboard only), and a
**commercial** set (18 proprietary repos from startups Scale has agreements with, ~276 tasks,
results reported but code private). Public repos are deliberately **copyleft (GPL)** to discourage
training on them. Gold patches validated across 3 runs. Score = **% resolved (pass@1)**. Open
harness/data at [github.com/scaleapi/SWE-bench_Pro-os](https://github.com/scaleapi/SWE-bench_Pro-os).
**Contamination-resistance: medium-high** for the held-out/commercial splits; the public split has
the same weakness as Verified. This is the variant Qwen and other 2026 vendors increasingly report.

**SWE-bench Multimodal** — Yang, Jimenez et al., ICLR 2025
([arXiv:2410.03859](https://arxiv.org/abs/2410.03859),
[swebench.com/multimodal.html](https://www.swebench.com/multimodal.html)). ~**619** tasks (test
split **517** from 12 repos) from **17 JavaScript** front-end libraries (charting, mapping, syntax
highlighting, diagramming); every task's problem statement or tests include at least one image
(screenshot, visual diff). Tests whether agents generalise from Python-backend bug-fixing to
visual, user-facing code. Same resolved-rate scoring.

**SWE-bench Multilingual** — 300 tasks, 42 repos, **9 languages** (C, C++, Go, Java, JS, TS, PHP,
Ruby, Rust), from the core SWE-bench team
([swebench.com/multilingual.html](https://www.swebench.com/multilingual.html)).

**Multi-SWE-bench** — separate project, **ByteDance Seed** team
([arXiv:2504.02605](https://arxiv.org/abs/2504.02605),
[github.com/multi-swe-bench/multi-swe-bench](https://github.com/multi-swe-bench/multi-swe-bench)).
**1,632** instances, **7 languages** (Java, TS, JS, Go, Rust, C, C++), 68 expert annotators, ~1
year to build. Same issue-resolution format, broader language coverage than SWE-bench Multilingual.

**Contamination-resistant refreshers:**

- **SWE-bench-Live** — Microsoft Research, *"SWE-bench Goes Live!"*
  ([arXiv:2505.23419](https://arxiv.org/abs/2505.23419), NeurIPS 2025 D&B;
  [github.com/microsoft/SWE-bench-Live](https://github.com/microsoft/SWE-bench-Live)). Automated
  curation pipeline (instance creation + Docker env setup with no manual work) producing tasks
  from GitHub issues created **since 2024**, refreshed monthly. Initial release 1,319 tasks / 93
  repos. Finding: SOTA agents score substantially lower here than on static SWE-bench.
- **SWE-rebench** — **Nebius** AI R&D
  ([nebius.com/blog/posts/introducing-swe-rebench](https://nebius.com/blog/posts/introducing-swe-rebench),
  [OpenReview](https://openreview.net/forum?id=nMpJoVmRy1), dataset
  [nebius/SWE-rebench](https://huggingface.co/datasets/nebius/SWE-rebench) — 21,000+ mined tasks).
  Continuously-updated, decontaminated SWE-agent-style tasks with **monthly leaderboard splits**
  (filter the dataset by `created_at`), a **fixed scaffold** so runs are comparable, and explicit
  contamination tracking against model release dates. The leaderboard is at
  [huggingface.co/datasets/nebius/SWE-rebench-leaderboard](https://huggingface.co/datasets/nebius/SWE-rebench-leaderboard).

**Sourcing:** primary-sourced (each benchmark's own paper / GitHub / leaderboard site + the OpenAI
announcement). The Feb-2026 OpenAI contamination post is corroborated-secondary (not read directly).

### Terminal-Bench

Joint project of **Stanford University and the Laude Institute**
([github.com/laude-institute/terminal-bench](https://github.com/laude-institute/terminal-bench)),
first announced 2025. A task = an English instruction + a **Docker container** environment + a
**verification test script** + a reference solution. The agent gets a shell in the container and
must complete an end-to-end task (compile something, fix a broken build, set up a server, train a
small model, recover data). Grading is **outcome-based pass/fail** per task; score = **fraction of
tasks resolved (pass@1)**.

- **Terminal-Bench 1.0 / `terminal-bench-core`** — the original ~100-task dataset (version tags
  like `0.1.1`).
- **Terminal-Bench 2.0** — co-authored by **Snorkel AI + Stanford + Laude**
  ([snorkel.ai blog](https://snorkel.ai/blog/terminal-bench-2-0-raising-the-bar-for-ai-agent-evaluation/)).
  **89** curated, harder, individually-verified tasks; unsolvable/academic tasks removed so a
  perfect score is theoretically attainable.
- **Terminal-Bench 2.1** — a revision that **fixed 28 of the 89 tasks** and added continuous
  validation ([snorkel.ai/leaderboard/terminal-bench-2-1](https://snorkel.ai/leaderboard/terminal-bench-2-1/)).
  This is the version Artificial Analysis uses in its current Intelligence Index (see §3).
- **Terminus / Terminus 2** — the project's **reference agent scaffold**. A submission is
  `(backbone model × agent scaffold)`; the leaderboard also accepts Codex CLI, Claude Code,
  mini-SWE-agent, etc. as the scaffold, which makes cross-submission comparison scaffold-dependent.
- **Harbor** — a newly-introduced harness/framework that "abstracts away container-based rollouts"
  and scales to thousands of parallel containers (Daytona, E2B, Modal, k8s). The CLI is `tb run`
  historically; `harbor` is the newer entrypoint. (Which command is canonical *now* is unclear —
  flag as approximate.)

**Contamination-resistance: medium** — tasks are hand-authored, not scraped, so the gold solution
isn't sitting in a public git history; but 1.0 tasks are public and 2.1 fixes are public.

**Sourcing:** primary (GitHub repo) + corroborated-secondary (Snorkel co-authored the 2.x release
and hosts its leaderboard, so their blog is close to primary; exact task counts and the 28-task
fix are from there).

### Aider polyglot

Run by the **Aider** project (Paul Gauthier).
[Announcement (Dec 2024)](https://aider.chat/2024/12/21/polyglot.html),
[leaderboard](https://aider.chat/docs/leaderboards/). The **225 hardest** Exercism exercises
(out of 697) across **6 languages: C++, Go, Java, JavaScript, Python, Rust**. The model must:
(1) solve a small, well-specified programming problem, and (2) **express the change in a valid
edit format** (`diff`, `diff-fenced`, `whole`, or `architect`) that Aider can apply without human
help. Protocol: one attempt, then **one retry** with the failing unit-test output fed back. Two
metrics: **percent correct** (`pass_rate_2`, i.e. after the retry) and **percent using correct
edit format**. It is explicitly an end-to-end test of *"not just the LLM's coding ability, but
also its capacity to edit existing code."* The exercises live in
[github.com/Aider-AI/polyglot-benchmark](https://github.com/Aider-AI/polyglot-benchmark).
Still maintained — the public leaderboard was updated in August 2026. Top of the leaderboard is
a frontier closed model (~88% correct as of mid-2026); the best open-weight entries sit well
below. **Contamination-resistance: low-medium** — Exercism solutions are all over GitHub, though
the 225-hardest selection and the edit-format requirement add friction.

**Sourcing:** primary (Aider repo + leaderboard + announcement).

### LiveCodeBench

[github.com/LiveCodeBench/LiveCodeBench](https://github.com/LiveCodeBench/LiveCodeBench),
[livecodebench.github.io]. Competitive-programming problems continuously scraped from **LeetCode,
AtCoder, and Codeforces**, each **tagged with its release date**. You evaluate a model only on
problems released **after its training cutoff**, which makes it genuinely contamination-controlled
for the recent window. Multiple scenarios (code generation, self-repair, test-output prediction,
execution). Scoring = **pass@1** (and pass@5) against the problems' own test cases.

- **release_v5**: 880 problems, May 2023 – Jan 2025.
- **release_v6**: 1,055 problems, May 2023 – Apr 2025.

**Contamination-resistance: high** *if* you use a date window past the cutoff; low if you run the
whole set on a recent model.

**Sourcing:** primary (repo README).

### Legacy / saturated

- **HumanEval** (OpenAI, 2021, [arXiv:2107.03374](https://arxiv.org/abs/2107.03374)) — 164 tiny
  standalone Python functions from docstrings, pass@1 against a few asserts.
- **MBPP** — ~1,000 entry-level Python tasks, similar format.
- **BigCodeBench** (BigCode, [arXiv:2406.15877](https://arxiv.org/abs/2406.15877)) — 1,140 tasks
  requiring **compositional use of many real libraries** and complex instructions; harder than
  HumanEval but *also* saturating for frontier models.

Frontier models score 96–98% on HumanEval; it no longer separates them. These remain useful only
for **small local models (roughly 1B–30B)** where there's still spread, and for quick regression
checks. Qwen2.5-Coder and similar small-model reports still quote them
([Qwen2.5-Coder report](https://arxiv.org/abs/2409.12186)). **Contamination-resistance: very low**
(these are among the most-trained-on test sets in existence).

### Agentic / computer-use

- **OSWorld** — XLANG Lab, University of Hong Kong, NeurIPS 2024
  ([arXiv:2404.07972](https://arxiv.org/abs/2404.07972),
  [github.com/xlang-ai/OSWorld](https://github.com/xlang-ai/OSWorld)). **369** real
  computer-use tasks in a full **Ubuntu desktop VM** (office suites, IDEs, browsers, file I/O,
  multi-app workflows), observed via screenshots / a11y tree, graded by **execution-based checks**
  on final machine state. Humans ~72%; at release the best agent managed ~12%.
- **OSWorld-Verified** — XLANG Lab, **July 2025** revision
  ([xlang.ai/blog/osworld-verified](https://xlang.ai/blog/osworld-verified)): ~300 community-reported
  task/checker bugs fixed, AWS-backed parallelism (up to 50 envs). Same 369-task shape. This is now
  the standard citation. Relevant to a coding chapter only at the margins (GUI agents, not
  terminal/IDE coding), but frequently appears on 2026 model cards next to Terminal-Bench.

**Sourcing:** primary (paper + repo + XLANG blog).

### Reasoning-adjacent (quoted alongside coding)

- **GPQA Diamond** — 198 "Google-proof" graduate-level science MCQs (bio/chem/physics), the
  hardest curated subset where 2 expert annotators agreed and non-experts mostly failed.
  Chance = 25%; PhD experts ~65%. ([Epoch AI overview](https://epoch.ai/benchmarks/gpqa-diamond),
  original [arXiv:2311.12022](https://arxiv.org/abs/2311.12022).)
- **AIME** — American Invitational Mathematics Examination: 15 problems, integer answers 0–999,
  auto-graded. "AIME 2025" / "AIME 2024" are used as year-stamped, post-cutoff math sets.
- **LiveBench** — Abacus.AI + NYU + NVIDIA + others, June 2024
  ([livebench.ai](https://livebench.ai/), [paper PDF](https://livebench.ai/livebench.pdf)).
  **Monthly-refreshed**, objective-scored (no LLM judge) benchmark across 6 categories including
  **coding** and **reasoning**, drawing from recent contests, arXiv, news. Contamination-resistant
  by design (new questions monthly). Quoted as a general-capability number, not an agentic one.

**Sourcing:** primary/near-primary (each project's paper or site).

### "Harness matters" — an agentic score is (model × scaffold × settings)

An agentic-coding number is **not** a property of the model alone. The same backbone scores very
differently under different scaffolds, and vendor tables are frequently not comparable:

- Anthropic's own SWE-bench write-up
  ([anthropic.com/engineering/swe-bench-sonnet](https://www.anthropic.com/engineering/swe-bench-sonnet)):
  Claude 3.5 Sonnet reached **49%** on SWE-bench Verified with a **minimal two-tool** scaffold
  (a `bash` tool + a string-replace `edit` tool), beating the then-SOTA 45% that used more
  elaborate scaffolding. They attribute several points purely to **tool-description wording and
  error-proofing** (e.g. forcing absolute paths), not model changes.
- Scaffolds report their own numbers with their own prompts, step budgets and termination policies
  (SWE-agent, OpenHands, mini-SWE-agent, Agentless, Moatless, AutoCodeRover), so cross-scaffold
  differences can't be cleanly attributed. mini-SWE-agent — **~100 lines, bash-only, no
  tool-calling API** — reports **>74%** on SWE-bench Verified
  ([github.com/SWE-agent/mini-swe-agent](https://github.com/SWE-agent/mini-swe-agent)), i.e.
  competitive with far heavier scaffolds.
- 2026 vendor model cards increasingly specify the harness ("run under the Claude Code harness at
  256K context", "OpenHands scaffold") precisely because the number is meaningless without it.
  Devstral Small's 53.6% SWE-bench Verified is an *OpenHands-scaffold* number, for example.

Practical takeaway for the chapter: when you compare two local models, hold the scaffold and
settings fixed and run them yourself; treat cross-vendor benchmark tables as directional only.

**Sourcing:** primary (Anthropic engineering blog, mini-SWE-agent repo). The specific
cross-scaffold deltas from 2026 arXiv papers were seen only in search snippets with post-cutoff
model names — treated as weak and not quoted numerically.

---

## 2. How to run benchmarks yourself

General pattern: **almost every harness here routes model calls through
[LiteLLM](https://github.com/BerriAI/litellm) or the OpenAI SDK.** To point at a local
llama.cpp / vLLM / Ollama server you set an OpenAI-compatible base URL and a provider-prefixed
model name:

```
export OPENAI_API_BASE=http://localhost:8000/v1   # vLLM / llama-server
export OPENAI_API_KEY=dummy
# then pass a model name like:
#   openai/<served-name>       (generic OpenAI-compatible)
#   hosted_vllm/<name>         (LiteLLM's vLLM prefix)
#   ollama/<name>  or  ollama_chat/<name>
```

LiteLLM prefixes and env-var names are documented at
[docs.litellm.ai](https://docs.litellm.ai/docs/providers). Exact env var differs per harness
(`OPENAI_API_BASE`, `OPENAI_BASE_URL`, or a `--api-base` flag) — check each project's README.

### SWE-bench

Two-step. **SWE-bench only grades patches**; you need an **agent scaffold** to generate the
predictions file first.

1. **Generate predictions** with a scaffold (this is where your local model plugs in):
   - **mini-SWE-agent** ([repo](https://github.com/SWE-agent/mini-swe-agent)):
     `pip install mini-swe-agent`, then `mini-extra swebench` for batch inference over a dataset
     (there is also `swebench_single` for one instance). Model via `--model` or the
     `MSWEA_MODEL_NAME` env var; LiteLLM under the hood, so `--model 'ollama/qwen3-coder'` or an
     `openai/…` name with `api_base` works. Produces a predictions JSON.
   - **SWE-agent** ([repo](https://github.com/swe-agent/swe-agent),
     [swe-agent.com](https://swe-agent.com/)), **OpenHands**
     ([github.com/All-Hands-AI/OpenHands](https://github.com/All-Hands-AI/OpenHands)),
     **Agentless**, **Moatless Tools** — alternative scaffolds, same idea, each with its own
     config for the model endpoint.
2. **Grade** with the official Docker harness
   ([github.com/SWE-bench/SWE-bench](https://github.com/SWE-bench/SWE-bench)): `pip install swebench`,
   then (verified against the repo README):

   ```
   swebench eval verified -p <predictions.json> --run-id <id> -j <workers>
   ```

   The **older form still works and takes the same arguments**:

   ```
   python -m swebench.harness.run_evaluation \
       --dataset_name SWE-bench/SWE-bench_Verified \
       --predictions_path <predictions.json> \
       --run_id <id> \
       --max_workers <n> \
       [--instance_ids <id1> <id2> ...]
   ```

   `--predictions_path gold` grades the reference patches (sanity check). On Apple/ARM add
   `--namespace ''` to build images locally. Datasets on HF: `SWE-bench/SWE-bench_Verified` (500),
   `SWE-bench/SWE-bench_Lite` (300), `princeton-nlp/SWE-bench` (full).
   **Resources (from the README): x86_64, ≥120 GB free disk, ≥16 GB RAM, ≥8 cores, Docker
   required.** Verified is ~500 Docker-heavy tasks × many agent steps → hours of local inference
   and tens of GB of images. Most people run a subset via `--instance_ids`, or use Lite's 300, or
   a "mini" split.
3. **Hosted alternative: `sb-cli`** ([github.com/swe-bench/sb-cli](https://github.com/swe-bench/sb-cli))
   — submit a predictions file, grading runs on SWE-bench's AWS infra, no local Docker.

For **SWE-rebench**, grading uses the same harness against `nebius/SWE-rebench`; the project ships
[SWE-rebench/SWE-bench-fork](https://github.com/SWE-rebench/SWE-bench-fork) for its instances. For
**SWE-bench Pro**, harness + public data at
[github.com/scaleapi/SWE-bench_Pro-os](https://github.com/scaleapi/SWE-bench_Pro-os) (held-out and
commercial splits are leaderboard-submission only).

### Terminal-Bench

Single repo holds harness **and** dataset
([github.com/laude-institute/terminal-bench](https://github.com/laude-institute/terminal-bench)).
`pip install terminal-bench` (or `uv tool install terminal-bench`), then the CLI is **`tb run`**
with `--agent` and `--model` flags; tasks execute in Docker. Verified example from the README
(model name here is illustrative):

```
tb run --agent terminus \
       --model anthropic/claude-3-7-latest \
       --dataset-name terminal-bench-core --dataset-version 0.1.1 \
       --n-concurrent 4
```

For a local model, pass a LiteLLM-style name (`--model openai/<name>` with `OPENAI_API_BASE` set,
or `--model ollama/<name>`). Newer 2.x releases introduce the **`harbor`** CLI/framework for
large-scale parallel container runs; whether `tb run` or `harbor run` is the current canonical
entrypoint for TB 2.1 is **unclear — flag as approximate and check the repo**.

### Aider polyglot

Harness lives inside the Aider repo:
[github.com/Aider-AI/aider/tree/main/benchmark](https://github.com/Aider-AI/aider/blob/main/benchmark/README.md).
Runs **in Docker** (it executes unreviewed LLM code):

```
./benchmark/docker_build.sh
./benchmark/docker.sh                 # opens a shell in the sandbox container
# clone the exercises into tmp.benchmarks/polyglot-benchmark, then:
./benchmark/benchmark.py <run-name> \
    --model <litellm-model-name> \
    --edit-format whole \
    --threads 10 \
    [--num-tests N]   [--keywords <filter>]
```

Model names are the **same format as the Aider CLI** (so `ollama/…`, `openai/…` with
`--openai-api-base`, etc. — Aider uses LiteLLM). `--stats` regenerates the report from a finished
run directory. Results reported as `pass_rate_1` / `pass_rate_2` (before / after the single
retry). Feeding the public leaderboard is a manual PR by the maintainers, not automatic.
(Flag: exact flag names verified against the README's documented pattern; `--exercises-dir`
vs an env var for the exercise path is version-dependent.)

### LiveCodeBench

[github.com/LiveCodeBench/LiveCodeBench](https://github.com/LiveCodeBench/LiveCodeBench),
module `lcb_runner`. Verified from the README:

```
python -m lcb_runner.runner.main \
    --model <model_name> \
    --scenario codegeneration \
    --release_version release_v6 \
    --start_date 2025-01-01 --end_date 2025-04-30 \
    --evaluate
```

`--start_date` / `--end_date` (YYYY-MM-DD) are the date window you set past your model's cutoff.
Open-weight models run through **vLLM** (with `--tensor_parallel_size`); closed/API models via
`--multiprocess`. `--evaluate` computes pass@1/pass@5. For a local OpenAI-compatible server you
register it as a custom model / use the OpenAI path with a base-URL override (check
`lcb_runner/lm_styles.py` for the current mechanism — flag as approximate).

### Multiple-choice / knowledge benchmarks (HumanEval, MBPP, GPQA, MMLU-Pro, …)

- **lm-evaluation-harness** (EleutherAI,
  [github.com/EleutherAI/lm-evaluation-harness](https://github.com/EleutherAI/lm-evaluation-harness))
  — the long-standing standard; it powered the retired HF Open LLM Leaderboard. Has an
  `openai-compatible` / `local-completions` model backend so it can hit a llama.cpp or vLLM
  endpoint; also runs models in-process via HF Transformers or vLLM.
- **inspect-ai** (UK AI Safety Institute / AISI,
  [inspect.aisi.org.uk](https://inspect.aisi.org.uk/)) — increasingly the standard framework for
  *agentic* and safety evals; model providers include OpenAI-compatible endpoints, vLLM, Ollama.
- **OpenBench** / the **`bench`** CLI (Groq,
  [github.com/groq/openbench](https://github.com/groq/openbench)) — **built on inspect-ai**;
  aims to give each benchmark "exactly one canonical implementation" so numbers are comparable
  across model releases. 90+ benchmarks (MMLU, GPQA, HumanEval, AIME/HMMT, SciCode, …).
  Commands: `bench list`, `bench describe`, `bench eval <name> -M <model-args> -T <task-args>`;
  works with Ollama and any OpenAI-compatible local server. This is the current "aggregator
  harness" to mention alongside lm-eval-harness.

**Sourcing:** primary for SWE-bench (repo README, commands verified), mini-SWE-agent (repo),
Terminal-Bench (`tb run` example verified from repo), Aider (`benchmark/README.md`, pattern
verified), LiveCodeBench (`lcb_runner` command verified from README), OpenBench/lm-eval-harness/
inspect-ai (project docs). Local-endpoint specifics (exact env var / base-URL flag per tool) are
**approximate** where noted — the LiteLLM/OpenAI-SDK routing is real, the precise flag name varies.

---

## 3. artificialanalysis.ai

**What it is.** An **independent AI benchmarking and analytics firm**, founded 2023 by **Micah
Hill-Smith (CEO)** and **George Cameron (CPO)** ([artificialanalysis.ai/about](https://artificialanalysis.ai/about)).
It runs its **own** evaluations and its **own** performance measurements rather than republishing
lab-reported numbers, and covers both model "intelligence" and the operational characteristics of
hosted API **endpoints** (speed, latency, price). As of Aug 2026 it lists ~590 models and 500+
endpoints (self-reported; the model/endpoint counts are corroborated-secondary). Backers include
Nat Friedman / Daniel Gross / Andrew Ng via AI Grant (secondary).

**Artificial Analysis Intelligence Index.** A **composite score** across ~10 third-party evals,
re-versioned as the eval set changes:

- **v3.0** combined **10 evaluations**: MMLU-Pro, GPQA Diamond, Humanity's Last Exam,
  LiveCodeBench, SciCode, AIME 2025, IFBench, AA-LCR (long-context reasoning, their own),
  Terminal-Bench Hard, and τ²-Bench Telecom.
- **v4.1.x** (current as of Aug 2026,
  [methodology](https://artificialanalysis.ai/methodology/intelligence-benchmarking),
  [index page](https://artificialanalysis.ai/evaluations/artificial-analysis-intelligence-index))
  is a **weighted average over 4 categories**: **Agents 34%** (GDPval-AA, τ³-Banking),
  **Coding 24%** (**Terminal-Bench v2.1** 16% + SciCode 8%), **Scientific Reasoning 24%**
  (Humanity's Last Exam, GPQA Diamond, CritPt), **General 18%** (AA-LCR, AA-Omniscience).
  They quote a 95% CI of <±1% on the composite.

The trend across versions: away from saturated MCQ knowledge tests, toward **agentic and terminal
tasks** — Terminal-Bench 2.1 is now the single largest coding component. There is also a
**coding-specific view / leaderboard** on the site (the "Coding" category of the Index, plus
per-eval boards for LiveCodeBench, Terminal-Bench, SciCode).

**The part most relevant to a local/self-hosting chapter: independently-measured per-endpoint
performance.** For every hosted endpoint (same open-weight model across many providers —
Together, Fireworks, DeepInfra, Groq, Cerebras, Novita, the model's own API, etc.) Artificial
Analysis measures ([performance methodology](https://artificialanalysis.ai/methodology/performance-benchmarking)):

- **Output speed** — tokens/sec after the first token.
- **Time to first token (TTFT)**, and **time to first *answer* token** for reasoning models
  (excludes thinking).
- **End-to-end response time**, plus a normalised "time for 100 output tokens".
- **Price** — USD per 1M input and per 1M output tokens, and a **blended** figure (they weight
  input/output, commonly a 3:1 ratio; exact blend documented on the site — treat the ratio as
  corroborated-secondary).

Method: synthetic prompts (long-form input + a task like summarise / Q&A / translate), a fresh
prompt per run, measured from **Google Cloud `us-central1-a`**. Cadence: **8×/day** for the 1k
and 10k-input workloads (~every 3h); **1×/day** for a parallel workload (10 concurrent requests);
**1×/week** for the 100k-input workload. Reported as the **median (P50) over the trailing 72h**
(14 days for the weekly test). Reasoning models: assume 2k reasoning tokens where the real count
isn't exposed; output speed measured over the last 80% of answer chunks.

**Good for:** choosing a **hosted** provider for an open-weight model (who's cheapest / fastest
for, say, Qwen3-Coder-480B), and as a **sanity-check reference** for a local setup — "a hosted
H100 endpoint does ~X tok/s on this model, my 3090 does Y." **Limitations:** it measures **hosted
endpoints, not your box** — your local tok/s depends on your GPU, quant, context length and
engine, none of which it captures; and the Intelligence Index is a **composite** that hides
task-specific strengths (a model can be strong at terminal tasks and weak at long-context, and
the single number blurs that). It's also a moving target — index version changes shift scores
independent of any model change.

**Sourcing:** primary for the methodology and the Index composition (their own methodology and
evaluation pages). Founder bios, model/endpoint counts, investor list, and the exact price-blend
ratio are corroborated-secondary.

---

## 4. lmarena.ai (formerly LMSYS Chatbot Arena; the site now redirects to arena.ai)

**What it is.** A **crowdsourced human-preference** evaluation. A user types a prompt, gets two
**anonymous** model responses side by side, votes for the better one (or tie / both bad); model
identities are revealed only after the vote. Votes feed a statistical ranking model that produces
an **Arena Score** per model with a 95% CI, and models are ordered by that.

**Origin and the company.** Started 2023 as **Chatbot Arena** by **LMSYS** (UC Berkeley / SkyLab —
Wei-Lin Chiang, Lianmin Zheng, Anastasios Angelopoulos, Ion Stoica et al.), paper *"Chatbot Arena:
An Open Platform for Evaluating LLMs by Human Preference"*
([arXiv:2403.04132](https://arxiv.org/abs/2403.04132), ICML 2024) — which reported **>240K** votes
at write-up time; the site has since described cumulative votes in the **millions** (the exact
current figure isn't pinned to a primary source — do not state a specific number). In **April 2025**
the project incorporated as **Arena Intelligence Inc.** and rebranded to **LMArena**, with a
rebuilt UI launched May 2025. **Funding:** **$100M seed** in May 2025 led by **a16z** and **UC
Investments** (~$600M valuation), other investors incl. Lightspeed, Felicis, Kleiner Perkins
([TechCrunch](https://techcrunch.com/2025/05/21/lm-arena-the-organization-behind-popular-ai-leaderboards-lands-100m/));
a **$150M Series A** (~$1.7B valuation) reported January 2026 (secondary). Independence caveat:
it is now a **VC-backed company** that also partners with the same labs it ranks (it gets
pre-release access to flagship models for the arena).

**Ranking model.** Originally an **Elo** system; switched to a **Bradley-Terry** model
(maximum-likelihood over all pairwise outcomes, order-independent) in early 2024. The methodology
was open-sourced as **"Arena-Rank"** ([arena.ai/blog/arena-rank](https://arena.ai/blog/arena-rank),
[extended-arena](https://arena.ai/blog/extended-arena/)) — JAX-based, closed-form 95% CIs instead
of bootstrap.

**Style control.** A regression extension that adds **response-style covariates** (response
length, and markdown density — number of headers, lists, bold spans) to the Bradley-Terry fit, so
a model can't climb the board just by writing longer, more formatted answers. Made the **default**
for the text and vision leaderboards in **May 2025**. There's a with- and without-style-control
view.

**Sub-arenas / leaderboards** (from [arena.ai/how-it-works](https://arena.ai/how-it-works)):
Overall, **Text**, **Agent**, **WebDev**, Image-to-WebDev, **Vision**, Document, **Search**,
Text-to-Image, Image Edit, Text-to-Video, Image-to-Video, Video Edit — 13+ boards.

- **WebDev Arena** ([news.lmarena.ai/webdev-arena](https://news.lmarena.ai/webdev-arena/), launched
  Dec 2024) — each model **builds a web app** from the prompt in a sandbox; the user votes on the
  rendered result. Same Bradley-Terry scoring. The closest arena to "agentic coding," but it's
  single-shot app generation judged on look/behaviour, not multi-file repo work.
- **Copilot Arena** ([arXiv:2502.09328](https://arxiv.org/abs/2502.09328),
  [github.com/lmarena/copilot-arena](https://github.com/lmarena/copilot-arena)) — a **VS Code
  extension** that shows two models' **inline completions** stacked; Tab accepts the top,
  Shift-Tab the bottom, and the choice is the vote. Real in-editor code-completion preferences
  from real developers. Also has a code-editing mode.

**Critiques.** Well-documented:
- **Preference ≠ correctness.** A vote rewards the answer the user *liked*; for code that
  correlates weakly with whether it compiles, is secure, or resolves the issue.
- **Sycophancy / style / vote campaigns.** Users favour confident, agreeable, well-formatted
  answers (style control addresses part of this); community vote-brigading for favourite models
  is a known risk, partly mitigated by anonymity and anomaly detection.
- **The "Leaderboard Illusion"** ([arXiv:2504.20879](https://arxiv.org/abs/2504.20879), Singh
  et al., Apr 2025) — the central independent critique. Findings: (1) an **undisclosed
  private-testing** policy let big labs submit many private variants and publish only the best
  (best-of-N), which **violates the Bradley-Terry unbiased-sampling assumption** and inflates the
  published score — the paper cites **27** private Llama-4-era variants from Meta; (2) large
  proprietary providers (OpenAI, Google) received a **disproportionate share of battle traffic**
  (~20% each) while 83 open-weight models together got <30%, so open models' ratings have wider
  error bars and stale data; (3) **selective retirement / silent deprecation** of models further
  skews the pool. LMArena disputed parts of the framing; it did publish more of its policies
  afterward.

**Genuinely good for:** a **real-world helpfulness / instruction-following** signal from diverse
users at scale; hard to contaminate (prompts are fresh, live, unpredictable, not a fixed set).
**Not good for:** coding *correctness*, agentic/tool-use capability, or anything needing a verified
outcome — WebDev and Copilot arenas narrow the gap but are still preference votes, not pass/fail
grading.

**Sourcing:** primary for the mechanism and methodology (Chatbot Arena paper, Arena-Rank blog,
how-it-works, WebDev/Copilot Arena posts, the Leaderboard Illusion paper). Company/funding history
is corroborated-secondary (TechCrunch + the site's own announcements). Do **not** state a specific
current cumulative-vote count — no primary figure was confirmed.

---

## 5. Contamination and reward hacking (brief — see `src/sw-factories.md`)

Static benchmark scores are systematically **inflated** by two distinct effects: **training-data
contamination** (the test issues, gold patches and even problem-statement wording are in the
pre-training corpus — OpenAI reported this for SWE-bench Verified in Feb 2026) and **reward
hacking** against weak outcome checks (an *incorrect* patch that still passes a thin test suite;
agents mining the fix from unpruned git history, GitHub, or package registries). This is exactly
why the contamination-resistant refreshers exist alongside the static sets — **SWE-rebench** and
**SWE-bench-Live** (post-cutoff PRs, monthly splits, fixed scaffold), **LiveCodeBench** date
windows, **SWE-bench Pro**'s held-out/commercial repos — and why **human-preference arenas**
(LMArena) are valued as a hard-to-contaminate complement. `src/sw-factories.md` covers the
evidence in full: the [arXiv reward-hackability audit](https://arxiv.org/abs/2606.16062) (28.5% of
a SWE-bench Verified sample has test suites weak enough to pass an incorrect patch; +14.14 pp
Pass@1 on hackable tasks), [Poolside's](https://poolside.ai/blog/through-the-looking-glass) and
Cursor's public reward-hacking admissions, and [SWE-Marathon](https://arxiv.org/abs/2606.07682).
Not re-derived here.

**Sourcing:** cross-reference to `src/sw-factories.md`; the OpenAI Feb-2026 contamination claim is
corroborated-secondary (not read directly this pass).

---

## Deduplicated source list

1. OpenAI — *Introducing SWE-bench Verified* — https://openai.com/index/introducing-swe-bench-verified/
2. SWE-bench site / leaderboards — https://www.swebench.com/
3. SWE-bench GitHub (harness, `swebench` package, `run_evaluation`) — https://github.com/SWE-bench/SWE-bench
4. SWE-bench Multilingual — https://www.swebench.com/multilingual.html
5. SWE-bench Multimodal (site) — https://www.swebench.com/multimodal.html
6. Yang, Jimenez et al. — *SWE-bench Multimodal* — https://arxiv.org/abs/2410.03859
7. Deng, Da et al. (Scale AI) — *SWE-Bench Pro* — https://arxiv.org/abs/2509.16941
8. SWE-bench Pro open harness/data — https://github.com/scaleapi/SWE-bench_Pro-os
9. ByteDance Seed — *Multi-SWE-bench* — https://arxiv.org/abs/2504.02605
10. Multi-SWE-bench GitHub — https://github.com/multi-swe-bench/multi-swe-bench
11. Microsoft Research — *SWE-bench Goes Live!* (SWE-bench-Live) — https://arxiv.org/abs/2505.23419
12. SWE-bench-Live GitHub — https://github.com/microsoft/SWE-bench-Live
13. Nebius — *SWE-rebench* blog — https://nebius.com/blog/posts/introducing-swe-rebench
14. SWE-rebench — OpenReview — https://openreview.net/forum?id=nMpJoVmRy1
15. SWE-rebench leaderboard dataset — https://huggingface.co/datasets/nebius/SWE-rebench-leaderboard
16. SWE-rebench SWE-bench fork — https://github.com/SWE-rebench/SWE-bench-fork
17. sb-cli (hosted SWE-bench grading) — https://github.com/swe-bench/sb-cli
18. Terminal-Bench GitHub (Stanford / Laude Institute) — https://github.com/laude-institute/terminal-bench
19. Snorkel AI — *Terminal-Bench 2.0* — https://snorkel.ai/blog/terminal-bench-2-0-raising-the-bar-for-ai-agent-evaluation/
20. Snorkel AI — Terminal-Bench 2.1 leaderboard — https://snorkel.ai/leaderboard/terminal-bench-2-1/
21. Aider — polyglot leaderboard — https://aider.chat/docs/leaderboards/
22. Aider — *o1 tops aider's new polyglot leaderboard* (Dec 2024) — https://aider.chat/2024/12/21/polyglot.html
23. Aider — benchmark harness README — https://github.com/Aider-AI/aider/blob/main/benchmark/README.md
24. Aider — polyglot-benchmark exercises — https://github.com/Aider-AI/polyglot-benchmark
25. LiveCodeBench GitHub (`lcb_runner`) — https://github.com/LiveCodeBench/LiveCodeBench
26. HumanEval — Chen et al. — https://arxiv.org/abs/2107.03374
27. BigCodeBench — https://arxiv.org/abs/2406.15877
28. Qwen2.5-Coder technical report (small-model HumanEval/MBPP usage) — https://arxiv.org/abs/2409.12186
29. OSWorld — Xie et al. (XLANG Lab, HKU) — https://arxiv.org/abs/2404.07972
30. OSWorld GitHub — https://github.com/xlang-ai/OSWorld
31. XLANG Lab — *Introducing OSWorld-Verified* — https://xlang.ai/blog/osworld-verified
32. GPQA Diamond — Epoch AI overview — https://epoch.ai/benchmarks/gpqa-diamond ; original https://arxiv.org/abs/2311.12022
33. LiveBench — site + paper PDF — https://livebench.ai/ ; https://livebench.ai/livebench.pdf
34. Anthropic — *Raising the bar on SWE-bench Verified* (harness matters) — https://www.anthropic.com/engineering/swe-bench-sonnet
35. mini-SWE-agent GitHub — https://github.com/SWE-agent/mini-swe-agent
36. SWE-agent GitHub / docs — https://github.com/swe-agent/swe-agent ; https://swe-agent.com/
37. OpenHands GitHub — https://github.com/All-Hands-AI/OpenHands
38. LiteLLM provider docs — https://docs.litellm.ai/docs/providers
39. EleutherAI — lm-evaluation-harness — https://github.com/EleutherAI/lm-evaluation-harness
40. UK AISI — inspect-ai — https://inspect.aisi.org.uk/
41. Groq — OpenBench (`bench` CLI, built on inspect-ai) — https://github.com/groq/openbench
42. Chiang, Zheng, Angelopoulos et al. — *Chatbot Arena* — https://arxiv.org/abs/2403.04132
43. Arena / LMArena — how it works — https://arena.ai/how-it-works
44. Arena — *Arena-Rank: Open Sourcing the Leaderboard Methodology* — https://arena.ai/blog/arena-rank
45. Arena — *Statistical Extensions of Bradley-Terry and Elo* — https://arena.ai/blog/extended-arena/
46. LMArena — *WebDev Arena* — https://news.lmarena.ai/webdev-arena/
47. Chi, Chen et al. — *Copilot Arena* — https://arxiv.org/abs/2502.09328
48. Copilot Arena GitHub — https://github.com/lmarena/copilot-arena
49. Singh et al. — *The Leaderboard Illusion* — https://arxiv.org/abs/2504.20879
50. TechCrunch — *LM Arena … lands $100M* — https://techcrunch.com/2025/05/21/lm-arena-the-organization-behind-popular-ai-leaderboards-lands-100m/
51. Artificial Analysis — About — https://artificialanalysis.ai/about
52. Artificial Analysis — Intelligence Benchmarking Methodology — https://artificialanalysis.ai/methodology/intelligence-benchmarking
53. Artificial Analysis — Intelligence Index (v4.1.x) evaluation page — https://artificialanalysis.ai/evaluations/artificial-analysis-intelligence-index
54. Artificial Analysis — Performance Benchmarking Methodology — https://artificialanalysis.ai/methodology/performance-benchmarking
55. `src/sw-factories.md` (this book) — reward-hacking / weak-oracle treatment; cites arXiv 2606.16062, 2606.07682, poolside.ai/blog/through-the-looking-glass
