# Research: Dex Horthy / HumanLayer — Context Engineering, Loop Engineering, and Software Factories

Raw backing research for the "Software Factories" book chapter, gathered by following up on The Pragmatic Engineer podcast episode ["Context Engineering with Dex Horthy"](https://newsletter.pragmaticengineer.com/p/context-engineering-with-dex-horthy) (Gergely Orosz interviewing Dex Horthy, CEO/founder of [HumanLayer](https://www.humanlayer.dev/)). Structured around the 12 subtopics extracted from that episode. Cross-referenced against `notes/initial-notes/Software Factory.md` (existing Harness → Loop → Factory layering notes) — this file extends rather than repeats that material.

Two primary-source anchors did almost all of the heavy lifting for corroboration:
- The [12-factor-agents GitHub repo](https://github.com/humanlayer/12-factor-agents) — Dex's original written framework.
- The [advanced-context-engineering-for-coding-agents GitHub repo](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents), specifically [`ace-fca.md`](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md) ("Advanced Context Engineering for Coding Agents") and [`wsff.md`](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/wsff.md) ("Why Software Factories Fail") — these are Dex's own written essays, not secondhand summaries, and they map almost exactly onto the podcast's talking points. Where the podcast/newsletter added detail not present in these written docs (e.g. specific dates, the "primary key" bug, "dumb zone" terminology), that's flagged explicitly below.

---

## 1. Context Engineering Fundamentals

Dex Horthy is widely credited with coining/popularizing the term "context engineering" in April 2025, distinguishing it from "prompt engineering" — [multiple secondary sources](https://tao-hpu.medium.com/context-engineering-is-replacing-prompt-engineering-for-production-ai-02205fad2a7f) and his own [12-factor-agents](https://github.com/humanlayer/12-factor-agents) repo (Factor 3: "Own your context window") converge on this attribution.

In his own essay `ace-fca.md`, Horthy frames the core insight plainly: LLMs are stateless — the context window is **"the ONLY lever you have to affect the quality of your output."** Context engineering, in his framing, isn't about clever wording of a single instruction (that's prompt engineering); it's about deliberately architecting *everything* that enters the context window across an entire multi-step, multi-session workflow — what information, in what order, compressed how, carrying which history.

This reframes prompt engineering as a subset of a bigger discipline. A [LangChain blog post from the same period](https://blog.langchain.com/the-rise-of-context-engineering/) makes the same distinction independently, suggesting the term had multiple simultaneous originators/popularizers in the field, not just Horthy — worth noting so the book doesn't over-attribute the coinage.

**Software factory implication:** If context is the only lever on output quality, then a software factory's core engineering problem is not "which model" or "which agent framework" but *what pipeline feeds the model at each stage of the assembly line*. This is the conceptual bridge from "context engineering" (single-agent discipline) to "loop/harness engineering" (system discipline) to "software factory" (organizational discipline) — the factory is, at bottom, a context-engineering problem multiplied across many parallel/sequential agent invocations.

## 2. The "Dumb Zone"

This is real and central to Horthy's public talks, but it's important to note a sourcing nuance: the *term* "dumb zone" and specific numeric thresholds appear consistently across **secondary sources reporting on his talks** (newsletter, conference talk summaries, derivative blog posts) more than in the written `ace-fca.md` essay itself, which discusses the same underlying phenomenon using the terms "correctness," "completeness," "size," and "trajectory" and a target **utilization range of 40%–60%** without using the words "dumb zone." This suggests "dumb zone" is coined/used primarily in his live talks (conference keynotes, podcast) rather than the written repo — both are Dex's own words, just different media.

Numbers reported across multiple secondary write-ups ([LinearB/Dev Interrupted](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-piloop), [dev.to summary](https://dev.to/ashwani_arya_291e758bf74d/agentic-development-in-a-nutshell-context-engineering-the-dumb-zone-and-why-your-ai-agents-are-2516), the [pragmatic engineer newsletter](https://newsletter.pragmaticengineer.com/p/context-engineering-with-dex-horthy)):
- For frontier models with ~1M-token windows, the "smart zone" holds up to roughly **300,000–400,000 tokens**; beyond that, quality degrades non-linearly.
- For smaller-context models, the ceiling is closer to **~100,000 tokens**.
- One summary frames the dumb zone specifically as **"the middle 40–60% of a large context window"** — i.e., not simply "past X tokens" but a proportional degradation zone, consistent with the 40–60% utilization figure in `ace-fca.md`.
- A claim repeated in several derivative posts is that this framework is based on Horthy having **analyzed ~100,000 developer sessions** — this specific number could not be independently verified against a primary Horthy source in this research pass; treat as attributed-to-Horthy-via-secondary-reporting only.
- The underlying mechanism cited: attention is quadratic, so a longer context forces attention to spread thinner — a generic, well-established transformer property, not a Horthy-specific finding, that he uses to explain the effect.

**Software factory implication:** A factory that runs many long-lived agent sessions (nightly loops, multi-hour brownfield tasks) needs to treat context-window utilization as a first-class operational metric — analogous to a build server watching memory/CPU. The practical prescription (see #8 below) is to design the whole workflow so no single session ever needs to cross into the dumb zone: compact and hand off instead of letting a session run long.

## 3. 12-Factor Agents

Primary source: [github.com/humanlayer/12-factor-agents](https://github.com/humanlayer/12-factor-agents). The 12 factors, as extracted from the README:

1. **Natural Language to Tool Calls** — converting LLM outputs into structured tool invocations.
2. **Own your prompts** — don't outsource prompt construction to a framework's black box; write and control them directly.
3. **Own your context window** — the context-engineering factor; explicit control over what enters the window.
4. **Tools are just structured outputs** — tool calls are just JSON the LLM emits; the "tool execution" is your own deterministic code.
5. **Unify execution state and business state** — the agent's execution state (what step it's on) and the application's business state (the actual data/objects) should not be two divergent representations.
6. **Launch/Pause/Resume with simple APIs** — agents should be controllable like any long-running process, not opaque chat loops.
7. **Contact humans with tool calls** — human-in-the-loop steps (approvals, questions) are modeled as tool calls, not a special side-channel.
8. **Own your control flow** — the branching/looping logic of the agent should be explicit code you control, not implicit in a framework's agent loop.
9. **Compact Errors into Context Window** — errors should be summarized/compacted before being fed back in, not dumped raw.
10. **Small, Focused Agents** — bounded scope per agent rather than one giant do-everything agent.
11. **Trigger from anywhere, meet users where they are** — agents should be invocable from Slack, email, CLI, webhook, etc., not locked to one UI.
12. **Make your agent a stateless reducer** — agent-step = `f(context) -> next_action`, a pure function, enabling replay/resume/testing.

Methodology: According to the README and corroborating secondary sources ([DEV Community summary](https://dev.to/bredmond1019/the-12-factor-agent-a-practical-framework-for-building-production-ai-systems-3oo8), [codesignal course description](https://codesignal.com/learn/courses/understanding-the-12-factor-agents-methodology/lessons/building-reliable-ai-agents)), Horthy built this from **interviews with roughly 100 AI engineers/founders/CTOs** building production agents — specifically people shipping agents into enterprise contexts generating real (hundreds-of-thousands-to-millions-of-dollars) revenue, not hobbyists. He has also presented this as a talk, "12-Factor Agents: Patterns of reliable LLM applications," at AI Engineer conferences (e.g. [Agents in Production 2025](https://home.mlops.community/public/videos/12-factor-agents-patterns-of-reliable-llm-applications-dexter-horthy-agents-in-production-2025-2025-08-06)), with the YouTube recording reportedly drawing over a million views combined across his talks.

**Software factory implication:** The 12 factors are essentially "what a single well-engineered agent (the smallest unit in a factory) must look like" — the harness-level building block. A software factory is a system of many such factors-compliant agents wired into loops (Factor 6, 8, 11 in particular govern how agents plug into a larger pipeline) with human checkpoints (Factor 7) placed deliberately rather than everywhere or nowhere.

## 4. Code Review Failures

This is the best-corroborated and most concrete subtopic — it's Horthy's own headline anecdote, told consistently (with escalating specificity) across his written essay, podcast appearances, and press coverage.

**Primary source (`wsff.md`, Horthy's own essay):** "In July 2025 we went full lights-off. Just read the specs and the tickets, background agents for all the small/medium stuff, the whole thing." The failure pattern: agents would eventually hit "at least one issue gnarly enough that the agent can't solve," forcing a human to "dig into the codebase you stopped reading three months ago, trying to figure out what's broken." By the third major incident, in **November 2025**, the team decided a rewrite was faster than continuing to patch: Horthy's cofounder **"spent two whole weeks in VS Code (not even Cursor) plumbing out all the patterns by hand."**

**Additional specifics from the [Pragmatic Engineer newsletter](https://newsletter.pragmaticengineer.com/p/context-engineering-with-dex-horthy) (not present in `wsff.md`, so attributed to the podcast specifically):** the system ran roughly **four months** before the breaking point; the specific bug was described as **a primary key incorrectly routed through the codebase**; even prompting Claude Opus 4.1 extensively could not get the model to find the root cause; once found and fixed, the team spent **three weeks re-onboarding to code no human had reviewed during its creation**. Horthy's own summary line: **"Shipping unread code spells disaster within months."**

A near-identical account (with the "three months" framing in its headline rather than "four") also appears in [BigGo's writeup](https://finance.biggo.com/news/15099f5634f5ab9a) and is referenced independently in the [Mastra podcast page](https://mastra.ai/podcasts/the-software-factory-dex-horthy-on-shipping-fast-without-ai-slop) ("the 'lights-off' version where humans stop reading code entirely quietly rots a codebase after three to six months") and the [Heavybit "High Leverage" podcast](https://www.heavybit.com/library/podcasts/high-leverage/ep-12-the-limits-of-lights-out-coding-with-dexter-horthy). The "three to six months" degradation window recurs so consistently across independent write-ups of separate talks that it should be treated as Horthy's stable talking point, even though the exact bug description ("primary key") only surfaced clearly in the newsletter piece.

**Independent corroboration of the general pattern (not Horthy's own incident, but supporting data):** Faros AI's 2026 "AI Engineering Report" (aka "Acceleration Whiplash"), based on telemetry from **22,000 developers over two years**, found (as cited in `wsff.md` itself, and independently summarized by [ADTmag](https://adtmag.com/articles/2026/04/22/more-code-more-bugs.aspx) and [Vibe Graveyard](https://vibegraveyard.ai/story/faros-ai-acceleration-whiplash-study/)):
- +25% more PR review comments, +22.7% longer comments (reviewers working harder, not less)
- **+31.3% of PRs now skip review entirely**
- **incidents per PR: +242.7%**
- monthly incidents: +57.9%
- **bugs per developer: +54%**
- task completion per developer: +34%; epics completed per developer: +66% (the productivity gains that make the tradeoff tempting in the first place)
- fewer than 1% of PRs in the dataset were opened fully autonomously by agents — i.e., even at the industry level, "lights-off" is rare, consistent with Horthy's argument that it doesn't actually work at scale.

**Software factory implication:** This is the empirical foundation for the entire "leverage-focused" software factory model (#6 below) — it's the negative case study that rules out full automation as a viable factory design, and it's why Horthy's recommended factory keeps a human-reviewed gate specifically at the architecture/design layer rather than removing review altogether.

## 5. Loop Engineering

The existing note (`Software Factory.md`) already defines Loop Engineering via Addy Osmani's Harness → Loop → Factory framing (design a system that repeatedly triggers Reason → Act → Observe → Verify). Horthy's material extends this concretely with a working example: the **"Ralph loop."**

According to [LinearB's writeup](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop), the Ralph loop originated with developer **Geoff Huntley in June 2025** as a deliberately unsophisticated bash loop — no orchestration framework, just a repeating shell script — that could run overnight accomplishing tasks like cloning/porting a codebase. At a Y Combinator hackathon, running concurrent Ralph loops cost **roughly $10–12/hour to run Claude Sonnet in a loop indefinitely**, which the source frames as evidence the economics of "just let it run overnight" are viable.

Horthy's own refinement layered on top of the bare loop is **RPI (Research → Plan → Implement)**, described in his `ace-fca.md` essay: research the relevant files/data flow first, produce an explicit plan with exact steps and test procedures, then implement phase-by-phase, **compacting status between phases** (tying directly into "Intentional Compaction," #8 below). He notes RPI is specifically suited to **brownfield codebases with existing architecture** — for greenfield work, he says the methodology "falls flat" and a spec-first approach is better suited instead.

**Software factory implication (extends, doesn't restate, the existing note):** the existing note frames Loop Engineering fairly abstractly ("Reason → Act → Observe → Verify"). Horthy's material adds a concrete operational shape: loops should be *simple* rather than clever ("simpler loops fail in simpler, more diagnosable ways"), should be *bounded in scope* (small, digestible tasks with frequent resets rather than one long-running session), and — critically, per the Code Review Failures findings above — a loop run overnight without human review of its outputs is exactly the failure mode that broke Horthy's own production system. So "nightly automation where agents open PRs" (as the book's working description has it) is validated as a real practice (Ralph loop, background agents), but Horthy's own experience argues strongly that the PRs from that automation still need a human review gate before merge — the loop should produce reviewable artifacts, not autonomously merge.

## 6. Software Factory Models

Horthy's own `wsff.md` essay lays out an evolving sequence of factory diagrams rather than exactly three static "models," but it collapses cleanly into the three the book's stub describes, and the numbers below flesh those out:

1. **Pre-AI factory (his 2022 baseline)**: people decide → tracker → someone builds → PR review → ship → monitor → user feedback loop. Human review here, per his numbers, could take review time from ~6 hours down to ~20 minutes when planning was done well upfront (this specific figure appears in the [Heavybit podcast summary](https://www.heavybit.com/library/podcasts/high-leverage/ep-12-the-limits-of-lights-out-coding-with-dexter-horthy) — treat as reported/approximate, not a verified statistic).
2. **"Full human review" factory** — an agent replaces the human *builder*, but every line is still read by a human before merge. Per the podcast/newsletter framing (not independently found verbatim in `wsff.md`), this yields roughly **30–50% productivity gain** — bounded because review remains the bottleneck.
3. **"Lights-off" / dark factory** — human code review removed entirely; investment shifted into automated testing, sandboxing, monitoring, and rollback instead. This is the model Horthy tried and abandoned (see #4 above) — theoretically maximal automation, but it failed in practice because "maintainability has no fast oracle" (his phrase, `wsff.md`): tests give feedback in seconds, but "the cost function of bad architecture is measured in weeks, months, maybe even years," so nothing catches the degradation in time.
4. **Horthy's recommended "leverage-point" model** — full human review is *retained*, but compressed and front-loaded via his four-phase pre-planning process (Product Review → System/Architecture → Program Design → Vertical Slices; detailed in #8 below) so that review becomes fast confirmation of already-agreed decisions rather than open-ended discovery. Reported result across several write-ups: **~2–3x faster** than the baseline, while still reading every line. Direct quote (Heavybit): "30 minutes over here in pre-planning and alignment can save you hours in review and so it's actually feasible to still read every line of code." He explicitly rejects the "drowning in PRs" framing: **"If you're drowning in PRs, you actually have too many bad PRs"** — i.e., the fix for review bottleneck is fewer/better PRs via upfront alignment, not less review.

No specific named companies (beyond HumanLayer itself) were found using these exact labeled models in production at the scale the book might want to cite — this part of the framework remains Horthy's own experience report plus the industry-wide Faros telemetry (#4 above), not a multi-company case study.

**Software factory implication:** this is arguably the single most load-bearing finding for the chapter: it directly falsifies "full automation" as a viable factory design based on a real, named failure, and gives the book a concrete alternative (the four-gate leverage model, #8) with a claimed multiplier (2-3x) to cite, clearly labeled as self-reported by Horthy rather than externally audited.

## 7. Trajectory Poisoning

Real concept, consistently reported, but — like "dumb zone" — the specific term does not appear in the written `ace-fca.md` essay (which discusses "trajectory" as one of four context-quality dimensions but doesn't use the compound term "trajectory poisoning" or reference the "you're completely/absolutely right" tell). It appears to be a term Horthy uses in talks/interviews rather than in his written essays; treat the specific phrase as attributable to his spoken commentary (podcast, conference talks) via secondary reporting, while the underlying concept (conversation history shaping/degrading future outputs) is corroborated in the written essay's "trajectory" quality factor.

Reported description (consistent across [LinearB](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop) and [WebSearch summaries of the "dumb zone" reporting](https://linearb.io/dev-interrupted/podcast/dex-horthy-humanlayer-rpi-methodology-ralph-loop)): once a session drifts into the dumb zone, models become **sycophantic** — replying "you're absolutely right" or "you're completely right" — right before repeating the same mistake, or in more severe cases exhibiting destructive behavior (one summary mentions an agent attempting to delete environment files). Because these models are autoregressive, a bad turn in the conversation history conditions all subsequent turns, compounding the error rather than self-correcting — hence "poisoning" the trajectory. The practical signal Horthy gives practitioners: treat that sycophantic phrasing as a tripwire to **abandon the session and restart fresh** rather than trying to argue the model out of the loop.

**Software factory implication:** for a factory running many autonomous/semi-autonomous loops overnight, this argues for an automated circuit-breaker: loops should be instrumented to detect these linguistic tells (or simpler proxies like repeated failed test runs / repeated identical diffs) and force a session restart with compaction rather than letting a poisoned trajectory continue consuming budget and potentially producing destructive edits unsupervised.

## 8. Intentional Compaction

Well corroborated directly from the primary source. `ace-fca.md` (Horthy's own essay) states the goal explicitly: design the **entire workflow** around context management, "keeping utilization in the 40%-60% range (depends on complexity of the problem)." The mechanism: before a session's context leaves the "smart" range, pause and distill the essential state into a structured markdown artifact — a research document or design brief — verify it's correct, then start a **new** conversation seeded with that artifact instead of the raw history.

This directly implements the multi-session workflow described in the task: **research document → design document → implementation plan**, corresponding to his RPI methodology (#5) and, at the factory-process level, his four-gate model:

1. **Product Review** — pins down *what* is being built and *why*: problem statement, success metric, plain-HTML mockups. No technical/architecture language allowed at this gate.
2. **System/Architecture** — grounded in actual codebase inspection: endpoints, data schemas + query patterns, call flow, third-party integrations.
3. **Program Design** — the gate Horthy calls "frequently omitted": file locations + rationale, type/method signatures (bodies omitted), call-stack ordering, named test cases with assertions, and an explicit list of the *least confident* design decisions worth challenging while changes are still cheap.
4. **Vertical Slices** — implementation proceeds as thin end-to-end "tracer bullets" (slice 1 mocks everything and runs; slice 2 adds happy-path logic; subsequent slices add capability incrementally), with the user reviewing working output and steering after each slice rather than after one giant diff.

Per the [gist writeup of this workflow as an installable Claude Code skill](https://gist.github.com/Maciejdziuba/88890d7e0eeefa5a8738bbe9fd5e20b8) (sourced from a David Ondrej podcast episode with Horthy — a different appearance than the Pragmatic Engineer one, so independent corroboration of the same framework), each gate requires an explicit human approval step: the agent summarizes 5-10 key decisions (never the full doc) and asks **"Approve Gate N, or what should change?"** — only affirmative human sign-off advances the process, and a status file (`00-status.md`) lets a fresh session resume from the last approved gate without re-litigating prior decisions. This is compaction operating at the *process* level, not just the token level: the human review at each gate is itself what gets compacted forward as durable state (plus optional Architecture Decision Records for anything meant to outlive the feature).

Crucially, Horthy's own essay frames *where* human attention should concentrate given this structure: **"A bad line of a plan could lead to hundreds of bad lines of code,"** and a bad line of research "could land you with thousands of bad lines of code" — so review effort is proportionally higher-leverage the earlier in the pipeline it happens, which is the explicit argument for reviewing architecture/design decisions rather than only code diffs.

**Software factory implication:** this is the concrete factory-level answer to "how do you keep humans in the loop without becoming the bottleneck" — push review upstream to the highest-leverage, lowest-volume artifacts (a one-page design doc) rather than downstream to the highest-volume, lowest-leverage artifact (a large code diff).

## 9. Token Harder vs. Token Smarter

Corroborated via search-result synthesis rather than a direct primary-source quote found in this pass (could not locate this exact framing verbatim inside `ace-fca.md` or `wsff.md` — it may be from a talk/interview not covered by the two repo essays). As reported: **"token harder"** means maximizing raw token burn — running agents continuously, removing humans from the loop, throwing more context/compute at the problem. **"Token smarter"** means using fewer tokens per unit of delivered value: investing in upfront planning, keeping humans at architectural decision points, and treating context budget as a scarce resource to be spent deliberately rather than exhausted. The framing explicitly acknowledges "smarter is harder to pull off" than simply scaling up token usage.

This maps directly onto the "lights-off vs. leverage-point" software factory comparison (#6): the lights-off factory is the "token harder" bet (maximal automation, maximal token spend, minimal human friction) and it's the one that failed; the leverage-point factory is "token smarter" (deliberate, front-loaded human judgment; smaller, well-scoped agent invocations).

**Software factory implication:** gives the book a crisp two-word framing for the core design tension in factory architecture — worth using as a heading/contrast pair, but flagged here as less independently verified than the other subtopics, so it should be attributed loosely ("Horthy has described this as...") rather than quoted directly without a located primary source.

## 10. Context Window Quality Factors

Best and most precisely corroborated subtopic — directly quotable from the primary source. `ace-fca.md` states the context window should be optimized, in priority order, across:

1. **Correctness** — the most critical factor; incorrect information in context is worse than anything else.
2. **Completeness** — missing information forces the model to guess/hallucinate to fill gaps.
3. **Size** — raw token count; bigger isn't better past the point of diminishing/negative returns (ties to the "dumb zone," #2).
4. **Trajectory** — the accumulated conversation/action history shapes what the model produces next (ties to "trajectory poisoning," #7).

The essay's own summary of failure severity, in order: **"the worst things that can happen to your context window, in order, are: 1. Incorrect Information 2. Missing Information 3. Too much Noise."** Sources of "noise" specifically named: file-search results, code-flow exploration output, applied-edit diffs, test/build logs, and large raw JSON blobs returned by tools — i.e., the byproducts of an agent's own tool use are themselves the primary pollutant, which is the direct motivation for intentional compaction (#8): periodically strip that noise back out into a clean, curated artifact.

Note the task description's phrasing ("four factors: size, information quality, missing information, and trajectory") is a close paraphrase of this — the primary source's actual four are correctness / completeness / size / trajectory, with "information quality" and "missing information" corresponding to correctness and completeness respectively. Minor terminology difference worth reconciling in the summary write-up.

**Software factory implication:** gives a factory designer a concrete checklist for auditing any pipeline stage that feeds an LLM — not just "is the context big enough" but "is everything in it true, is anything necessary missing, is it the smallest sufficient set, and does the history it carries point the model toward the right next action."

## 11. Model Training Limitations

Strongly corroborated directly from `wsff.md`, and this is arguably Horthy's most original/distinctive argument (as opposed to being a synthesis of known ideas) — worth featuring prominently.

His core claim: coding models are trained (via RL) against benchmarks like **SWE-bench Multilingual**, which score a patch purely on whether old tests still pass and new tests succeed. There is, in his words, **"no penalty for eroding codebase maintainability."** A model that fixes a bug by wrapping it in a try/catch, or with a lazy type cast, scores identically to one that fixes it with a clean, maintainable change — the benchmark can't tell the difference, so RL training can't select against the bad pattern.

The deeper structural reason he gives: **"Tests give you feedback in seconds, but the cost function of bad architecture is measured in weeks, months, maybe even years"** — training needs a *fast oracle* (a quick, reliable reward signal) to do reinforcement learning at scale, and maintainability simply doesn't have one. The consequence doesn't show up in the benchmark's ~15-minute task window; it shows up three to six months later in a real codebase, which is exactly the timeframe of his own production failure (#4). He explicitly separates this from "vibe coding" on throwaway side projects, where none of this matters because there's no long-term maintenance cost to erode: "a side project a dozen people will ever run and a team keeping a 10-year-old enterprise system alive for another quarter share almost no constraints worth naming" (per the [BigGo podcast summary](https://finance.biggo.com/podcast/2a49159603eadab6), closely paraphrasing his talk).

He also names the frontier of proposed fixes on the model-training side — better verifiers, judge-model-based rewards, and longer-horizon benchmarks such as **SWE-Marathon** and **Frontier Code** (contrasted with SWE-bench's ~15-minute tasks; SWE-Marathon tasks reportedly run up to ~400 hours) — while noting these remain unsolved as of the research date.

**Software factory implication:** this is the argument that most directly justifies *why* a software factory can't just be "a really good agent" — it's a structural claim that no amount of model improvement alone (absent new training objectives) will fix the maintainability blind spot, so the factory's process (human review at the design layer, #8) has to compensate for a gap that model providers haven't yet closed. This gives the chapter a principled, non-hand-wavy reason for keeping humans in the loop rather than an appeal to caution alone.

## 12. Optimization Timing

Reasonably corroborated as a three-phase sequence, sourced mainly to search-result synthesis of Horthy's commentary (not directly located verbatim in either repo essay in this pass):

1. **"Make it run"** — use the smartest available model with the simplest possible (single-call) approach, purely to validate the problem is real and solvable at all.
2. **"Make it right"** — once usage/scale justifies the investment, put in the context-engineering work: decompose the task into multiple, smaller, cheaper calls with well-curated context per call.
3. **"Make it fast/cheap"** — only after that, swap in cheaper models for the specific subtasks that don't require frontier-level intelligence.

The specific example named for step 3 is **GPT-OSS-120B**, described (per the newsletter/podcast) as roughly **1/1,000th the cost** of a frontier model for simpler subtasks — this specific figure and model name were found sourced to the Pragmatic Engineer newsletter coverage specifically; independent verification of "1/1,000th the cost" as an exact multiplier was not found elsewhere in this pass (GPT-OSS-120B's own published pricing — e.g. [OpenRouter's listing](https://openrouter.ai/openai/gpt-oss-120b), around $0.03-0.04/1M input tokens — is indeed roughly two orders of magnitude cheaper than frontier-model pricing, which is directionally consistent, though "1/1,000th" specifically wasn't independently confirmed).

The underlying rationale, consistent with his general worldview: engineering time, not inference cost, is the real bottleneck early on — premature optimization toward cheaper models costs more in lost iteration speed and added complexity than it saves in token spend, until you actually hit meaningful scale/cost pressure.

**Software factory implication:** argues against a factory design that tries to be cost-optimal from day one by routing every task to the cheapest sufficient model — that's an optimization to defer until the factory's throughput is high enough that inference cost, not human/engineering iteration speed, is the binding constraint.

## Named Entities — Sourcing Notes

- **HumanLayer**: Horthy's company, YC Fall 2024. Provides human-in-the-loop infrastructure/tooling for AI agents; more recently described (per [YC's company page](https://www.ycombinator.com/companies/humanlayer)) as helping teams "ship 2-3x faster without AI slopping up your codebase" — directly tying the company's pitch to the leverage-point factory model (#6). See also the [Launch YC post](https://www.ycombinator.com/launches/M8e-humanlayer-human-in-the-loop-for-ai-agents-and-beyond).
- **LangChain / CrewAI**: The newsletter/podcast coverage states Horthy and the AI engineers he interviewed for 12-factor-agents **initially used LangChain and CrewAI (around August 2024) but abandoned/rejected them** in favor of custom-built pipelines, informing the 12-factor-agents principles (e.g. "own your prompts," "own your control flow" are near-direct rebuttals of framework-owned prompt/control-flow abstractions). This claim is sourced to the podcast/newsletter coverage specifically; broader web results about LangChain/CrewAI "failing in production" are generic industry commentary (e.g. [this Medium piece](https://ai.gopubby.com/the-hidden-costs-of-langchain-crewai-pydanticai-and-others-why-popular-ai-frameworks-are-failing-77b9a40c16cf)) rather than corroboration specifically tied to Horthy's interviews. Treat the "rejected by surveyed engineers" claim as plausible and consistent with the 12-factor-agents framework's design philosophy, but not independently verified beyond the podcast summary itself.
- **Sentry, Datadog**: mentioned in the podcast as examples of the monitoring/observability tooling a "lights-off" factory leans on to substitute for human code review (part of the "invest in testing, monitoring, rollout" strategy in `wsff.md`'s lights-off model). No independent, detailed sourcing on Horthy's specific usage of these tools was found beyond the podcast mention — treat as podcast-summary-sourced only.
- **Docker / HashiCorp / Replicated**: Horthy's professional background, per his [Sessionize speaker profile](https://sessionize.com/dexhorthy/) and a [community bio page](https://github.com/raphaelmansuy/digital_palace/blob/main/people/dex-horthy.md): he began coding at NASA JPL at 17, graduated University of Chicago, then spent **seven years at Replicated** (a Series C dev-tools startup building on-prem Kubernetes delivery tooling), progressing from engineer through SE, PM, to executive roles, working with enterprise clients including **HashiCorp, DataStax, and H2O.ai** to help them ship on-prem k8s products. He also did earlier infrastructure/developer-productivity work at Sprout Social. Note: Docker and HashiCorp appear to be **clients/companies he worked with via Replicated**, not direct former employers — worth getting this distinction right in the summary rather than implying he worked *at* Docker or HashiCorp directly.

---

## Sources

1. [12-factor-agents (GitHub, humanlayer)](https://github.com/humanlayer/12-factor-agents)
2. [Context engineering with Dex Horthy — The Pragmatic Engineer newsletter](https://newsletter.pragmaticengineer.com/p/context-engineering-with-dex-horthy)
3. [Dex Horthy: A Fully Automated 'Dark Factory' Corrupted a Codebase — BigGo Finance](https://finance.biggo.com/news/15099f5634f5ab9a)
4. [Ralph loops make agentic coding reliable with ruthless context resets — LinearB Blog](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop)
5. [Dex Horthy on Ralph, RPI, and escaping the "Dumb Zone" — Dev Interrupted / LinearB](https://devinterrupted.substack.com/p/dex-horthy-on-ralph-rpi-and-escaping)
6. [The Software Factory Playbook — Dex Horthy's 4-gate workflow (gist, from David Ondrej podcast)](https://gist.github.com/Maciejdziuba/88890d7e0eeefa5a8738bbe9fd5e20b8)
7. [The Software Factory Playbook — 4-Gate Skill (David Ondrej's site)](https://www.davidondrej.com/dex-podcast)
8. [High Leverage Ep. #12: The Limits of Lights-Out Coding with Dexter Horthy — Heavybit](https://www.heavybit.com/library/podcasts/high-leverage/ep-12-the-limits-of-lights-out-coding-with-dexter-horthy)
9. [Harness Engineering is not Enough: Why Software Factories Fail — Dex Horthy, AI Engineer podcast (BigGo)](https://finance.biggo.com/podcast/2a49159603eadab6)
10. [AI Coding Agents Are Writing 75% of New Code. Dex Horthy Says That's the Problem — BigGo Finance](https://finance.biggo.com/news/2a49159603eadab6)
11. [The Software Factory: Dex Horthy on Shipping Fast Without AI Slop — Mastra Podcast](https://mastra.ai/podcasts/the-software-factory-dex-horthy-on-shipping-fast-without-ai-slop)
12. [No Vibes Allowed: Solving Hard Problems in Complex Codebases — Dex Horthy, HumanLayer (YouTube, via summarizeyoutubevideo.com)](https://summarizeyoutubevideo.com/video/no-vibes-allowed-solving-hard-problems-in-complex-codebases-dex-horthy-humanlayer-rmvDxxNubIg)
13. [No Vibes Allowed — original YouTube video](https://www.youtube.com/watch?v=rmvDxxNubIg)
14. [advanced-context-engineering-for-coding-agents (GitHub repo, humanlayer)](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents)
15. [wsff.md — "Why Software Factories Fail" (raw essay, humanlayer repo)](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/wsff.md)
16. [ace-fca.md — "Advanced Context Engineering for Coding Agents" (raw essay, humanlayer repo)](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md)
17. [Faros AI Engineering Report 2026: The Acceleration Whiplash (PDF)](https://pages.faros.ai/hubfs/AI_Engineering_Report_2026_The_Acceleration_Whiplash_Faros.pdf)
18. [Faros study finds AI coding throughput rose while bugs and incidents rose faster — Vibe Graveyard](https://vibegraveyard.ai/story/faros-ai-acceleration-whiplash-study/)
19. [More Code, More Bugs: Faros Report Finds Tradeoffs In AI-Driven Software Development — ADTmag](https://adtmag.com/articles/2026/04/22/more-code-more-bugs.aspx)
20. [AI Coding Tools Tripled Production Incidents in Faros's Largest Study Yet — Matthew Aberham](https://www.matthewaberham.com/blog/faros-acceleration-whiplash)
21. [Faros AI Research](https://www.faros.ai/research)
22. [HumanLayer — Y Combinator company page](https://www.ycombinator.com/companies/humanlayer)
23. [Launch YC: HumanLayer — Human-in-the-loop for AI Agents and beyond](https://www.ycombinator.com/launches/M8e-humanlayer-human-in-the-loop-for-ai-agents-and-beyond)
24. [Dexter Horthy's Speaker Profile — Sessionize](https://sessionize.com/dexhorthy/)
25. [Dex Horthy bio — digital_palace (GitHub, community-maintained)](https://github.com/raphaelmansuy/digital_palace/blob/main/people/dex-horthy.md)
26. [12 Factor Agents: Principles for AI That Actually Work — paddo.dev](https://paddo.dev/blog/12-factor-agents/)
27. [humanlayer/12-factor-agents — DeepWiki](https://deepwiki.com/humanlayer/12-factor-agents)
28. [The 12-Factor Agent: A Practical Framework — DEV Community](https://dev.to/bredmond1019/the-12-factor-agent-a-practical-framework-for-building-production-ai-systems-3oo8)
29. [12-factor Agents talk — Dexter Horthy, Agents in Production 2025 (video)](https://home.mlops.community/public/videos/12-factor-agents-patterns-of-reliable-llm-applications-dexter-horthy-agents-in-production-2025-2025-08-06)
30. [GitHub - arpagon/pi-context-zone (secondary tool referencing "dumb zone" terminology)](https://github.com/arpagon/pi-context-zone)
31. [The rise of "context engineering" — LangChain blog (independent/parallel coinage)](https://blog.langchain.com/the-rise-of-context-engineering/)
32. [gpt-oss-120b pricing — OpenRouter](https://openrouter.ai/openai/gpt-oss-120b)
33. [The Hidden Costs of LangChain, CrewAI, PydanticAI and Others — AI Advances / Medium](https://ai.gopubby.com/the-hidden-costs-of-langchain-crewai-pydanticai-and-others-why-popular-ai-frameworks-are-failing-77b9a40c16cf)
