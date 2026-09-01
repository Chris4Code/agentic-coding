# Research: Agent sandbox landscape — E2B, Daytona, Modal, comparable providers, isolation spectrum, self-hosting, vs Warp Oz

Pass covering the `src/local-models.md` chapter's **"On Premise Agent Sandboxes"** section. Extends `notes/2026-08-29-3-local-models-frontends-proxies-terminals-security/` (which established Warp Oz's identity in depth — not re-derived here; subtopic 7 compares Oz to the raw sandbox providers, and Oz facts that changed since Feb 2026 are flagged).
Research date: **2026-08-30**. Vendor pricing and "latest release" facts drift fast — every dated figure below is as-of this date unless noted.

Sourcing tags per finding: **[PRIMARY]** = vendor's own docs/repo/pricing/blog; **[CORROBORATED-SECONDARY]** = multiple independent third parties agree; **[SINGLE-SOURCE]** = one secondary source, treat with caution.

---

## 1. E2B

**What it is.** E2B ("Environment to Business") is an open-source cloud runtime that gives AI agents isolated sandboxes to execute code, run tools, and process data. Each sandbox is described in E2B's own docs as "a fast, secure Linux VM created on demand for your agent"; a **Template** defines the environment a sandbox boots from ([E2B docs](https://docs.e2b.dev/)) **[PRIMARY]**. The company is E2B (dba of the founding entity), founded 2023 by Václav Mlejnský and Tomáš Valenta, headquartered in San Francisco ([ain.ua on the Series A](https://en.ain.ua/2025/07/28/e2b-raises-21m/)) **[CORROBORATED-SECONDARY]**.

**Architecture — Firecracker micro-VMs.** E2B sandboxes run as **Firecracker micro-VMs**, one per sandbox, each booting its own kernel — a hardware-virtualization boundary, not a shared-kernel container ([e2b-dev/infra repo](https://github.com/e2b-dev/infra); [Beam: self-hosting a code sandbox](https://www.beam.cloud/blog/how-to-self-host-code-sandbox); [Spheron guide](https://www.spheron.network/blog/ai-agent-code-execution-sandbox-e2b-daytona-firecracker/)) **[CORROBORATED-SECONDARY]** (the repo is primary but the "one micro-VM per sandbox, own kernel" phrasing is corroborated across third parties). E2B's orchestration layer historically used a fork of the AWS `firecracker-task-driver` for Nomad; the current infra repo drives Firecracker directly under Nomad + Consul ([e2b-dev/infra](https://github.com/e2b-dev/infra)) **[PRIMARY]** for Nomad/Consul; the `firecracker-task-driver` lineage is **[SINGLE-SOURCE]** / historical and should not be stated as current without checking the repo.

**Open source and license.** The SDK repo [`e2b-dev/E2B`](https://github.com/e2b-dev/E2B) is **Apache-2.0**, described as "Open-source, secure environment with real-world tools for enterprise-grade agents." The infrastructure repo [`e2b-dev/infra`](https://github.com/e2b-dev/infra) ("the infrastructure that powers the E2B platform") is also **Apache-2.0** and is a genuine Terraform deployment, not a stub ([both repos](https://github.com/e2b-dev)) **[PRIMARY]**.

**Self-hosting / bring-your-own-cloud.** Real and documented, but a substantial infra project. Per [`infra/self-host.md`](https://github.com/e2b-dev/infra/blob/main/self-host.md) **[PRIMARY]** and the [DeepWiki self-hosting guide](https://deepwiki.com/e2b-dev/infra/9-self-hosting-guide) **[CORROBORATED-SECONDARY]**:
- Supported clouds: **GCP (fully supported)**, **AWS (Beta)**; Azure and bare-metal Linux are listed as planned, not shipped.
- Prerequisites: Terraform (pinned to v1.7.5 in the guide), Packer, Docker + Buildx, Go, npm, the cloud CLI, a **Cloudflare account + domain** (for DNS), and a **PostgreSQL** database for metadata; optional Grafana/PostHog for observability.
- Orchestration is **Nomad + Consul** — "you are standing up and operating a scheduling cluster, not just a service"; secondary write-ups summarize it as "not a `helm install`" ([Beam](https://www.beam.cloud/blog/how-to-self-host-code-sandbox)).
- Firecracker needs **bare metal or nested-virtualization-capable** instances.
- The Cloudflare-for-DNS dependency makes a fully **air-gapped** deployment awkward without substituting your own DNS. Not called out by E2B; inference from the prerequisites — **[SINGLE-SOURCE]** as a stated limitation.

**SDKs and runtimes.** Python (`pip install e2b`) and JavaScript/TypeScript (`npm i e2b`), plus specialized **Code Interpreter** and **Desktop** SDKs in both languages ([E2B docs](https://docs.e2b.dev/); [e2b PyPI](https://pypi.org/project/e2b/)) **[PRIMARY]**. Templates are Dockerfile-derived; sandboxes are Linux (Debian/Ubuntu base).

**Startup latency.** E2B markets sandbox start at **~150 ms**; its docs state same-region sandboxes "start in 80 ms" and cross-region "in less than 200 ms" ([E2B site/docs, quoted via secondary](https://www.softwareseni.com/e2b-daytona-modal-and-sprites-dev-choosing-the-right-ai-agent-sandbox-platform/); [Dwarves memo breakdown](https://memo.d.foundation/breakdown/e2b)) **[CORROBORATED-SECONDARY]** (the numbers are E2B's own, but I read them through third-party pages, not a live primary page in this pass — treat the exact 80/150/200 ms split as corroborated-secondary). The mechanism is VM snapshot/restore (filesystem + running processes serialized and resumed).

**Persistence / filesystem.** Sandboxes support **pause/resume persistence** ([E2B "Sandbox persistence" docs](https://e2b.dev/docs/sandbox/persistence)) **[PRIMARY]** (page exists; details read via search). Default session length is **up to 1 hour** on the free tier and **up to 24 hours** on Pro ([E2B pricing](https://e2b.dev/pricing)) **[PRIMARY]**. Each sandbox has an ephemeral filesystem; persistence is via pause/resume or by writing out.

**Pricing** (from [e2b.dev/pricing](https://e2b.dev/pricing), read 2026-08-30 — **may drift**) **[PRIMARY]**:
- **Hobby (Free):** one-time **$100** in usage credits; sandbox sessions up to **1 hour**; max **20 concurrent** sandboxes; 10 GiB free storage.
- **Pro: $150/mo + usage;** customizable CPU/RAM; sessions up to **24 hours**; up to **100 concurrent** (additional concurrency purchasable up to **1,100**); 20 GiB free storage.
- **Ultimate / Enterprise:** custom, contact sales.
- **Per-second compute:** CPU from **$0.000014/s** (1 vCPU) to **$0.000112/s** (8 vCPU); RAM **$0.0000045/GiB/s**.
- Caveat: these figures came from a single automated read of the pricing page; the tier names ("Hobby/Pro/Ultimate") and the $150/mo Pro price should be re-verified before print — one secondary source ([agenticwire](https://www.agenticwire.news/article/e2b-self-hosted-guide)) also cites "$150/mo Pro", which is weak corroboration.

**Funding / company status.** Seed **$11.5M** (Oct 2024, led by Decibel Partners); **Series A $21M** (July 2025, led by Insight Partners; Decibel, Sunflower Capital, KAYA VC also in) — roughly **$32M** total ([Insight Partners announcement](https://www.insightpartners.com/ideas/e2b-raises-a-21m-series-a-to-offer-cloud-for-ai-agents-to-fortune-100/); [E2B blog "Series A"](https://e2b.dev/blog/series-a); [Crunchbase seed round](https://www.crunchbase.com/funding_round/e2b-1c91-seed--6b20b90e)) **[PRIMARY]** + **[CORROBORATED-SECONDARY]**.

**Who uses it.** **Perplexity** built "advanced data analysis for Pro users in ~1 week" on E2B ([E2B blog: Perplexity](https://e2b.dev/blog/how-perplexity-implemented-advanced-data-analysis-for-pro-users-in-1-week)); **Manus** uses E2B to give its agents "virtual computers" ([E2B blog: Manus](https://e2b.dev/blog/how-manus-uses-e2b-to-provide-agents-with-virtual-computers)) **[PRIMARY]**. Secondary claim that Manus runs E2B *self-hosted* on its own machines is **[SINGLE-SOURCE]**.

**Desktop / computer-use / "Surf".** [`e2b-dev/desktop`](https://github.com/e2b-dev/desktop) — "E2B Desktop Sandbox": a sandbox with a full Linux + **Xfce** graphical desktop, VNC streaming, and mouse/keyboard/screenshot APIs, for computer-use agents; Python and JS SDKs ([repo README](https://github.com/e2b-dev/desktop/blob/main/README.md)) **[PRIMARY]**. [`e2b-dev/surf`](https://github.com/e2b-dev/surf) — "Surf": a reference computer-use agent (OpenAI-powered, Next.js app) driving the Desktop Sandbox by natural language, live at [surf.e2b.dev](https://surf.e2b.dev/) **[PRIMARY]**.

**Sourcing:** primary for repos/licenses/SDKs/desktop/Surf/funding; corroborated-secondary for the Firecracker "own kernel per sandbox" framing and the 80/150/200 ms latency numbers; single-source for the `firecracker-task-driver` lineage, air-gap limitation, and Manus-self-hosts claim.

---

## 2. Daytona

**What it is now.** Daytona has **pivoted**. It began (2023–2024) as an open-source, self-hosted **development-environment manager** ("The Open Source Dev Environment Manager"). It now positions as **"secure and elastic infrastructure for running AI-generated code"** — a sandbox runtime for AI agents ([daytona.io](https://www.daytona.io/); [daytona.io/docs](https://www.daytona.io/docs/)) **[PRIMARY]**. Secondary sources date the pivot to early 2025 ([Northflank: Daytona vs E2B](https://northflank.com/blog/daytona-vs-e2b-ai-code-execution-sandboxes)) **[CORROBORATED-SECONDARY]**.

**Isolation technology — NOT gVisor.** This is a **named-entity correction for the book.** The current chapter's isolation-spectrum bullet says "gVisor — a user-space kernel intercepting syscalls (used by Daytona)." That is wrong on the parenthetical. Daytona's docs describe sandboxes as **"Built on OCI/Docker compatibility"** with "complete isolation, a dedicated kernel, filesystem, network stack" ([daytona.io/docs](https://www.daytona.io/docs/)) **[PRIMARY]** — note the docs' "dedicated kernel" phrasing is marketing-flavored and sits awkwardly next to "OCI/Docker". Multiple independent third parties state Daytona uses **Docker/OCI containers by default**, with **Kata Containers** (and, per some sources, **Sysbox**) as an **opt-in** stronger-isolation runtime — *not* gVisor:
- [Northflank: Daytona vs E2B](https://northflank.com/blog/daytona-vs-e2b-ai-code-execution-sandboxes): "Daytona uses Docker containers by default with optional Kata Containers for stronger isolation... the default Docker isolation is the weakest of the three."
- [morphllm: Daytona alternatives](https://www.morphllm.com/comparisons/daytona-alternative), [Spheron guide](https://www.spheron.network/blog/ai-agent-code-execution-sandbox-e2b-daytona-firecracker/), [MintMCP: agent sandbox](https://www.mintmcp.com/blog/agent-sandbox): all describe container-based isolation, not gVisor.
- **[CORROBORATED-SECONDARY]** that it is containers-by-default + optional Kata; **[SINGLE-SOURCE]** on Sysbox specifically.
- gVisor is used by **Modal** (subtopic 3) and Google Cloud Run / GKE Sandbox — the book likely swapped the two. **Recommended chapter fix:** move the "(used by Daytona)" to "(used by Modal)", and change the Firecracker line to keep "(used by E2B)" plus add Vercel Sandbox / Fly.io.

**Startup latency.** Daytona's headline claim: sandboxes **"spinning up in under 90 ms from code to execution"** / "sub-90ms cold starts, the fastest sandbox creation in the market" ([daytona.io](https://www.daytona.io/)) **[PRIMARY]**. An independent benchmark reports **71 ms create + 67 ms exec + 59 ms cleanup ≈ 197 ms total**, concluding 90 ms is a best-case number when the container image is already cached ([Medium: "Sub-90ms Cloud Code Execution"](https://medium.com/@kacperwlodarczyk/sub-90ms-cloud-code-execution-how-daytona-replaced-docker-in-our-ai-agent-stack-b6f343e4e547)) **[SINGLE-SOURCE]**.

**Snapshots and declarative images.** Stateful **snapshots** persist sandbox state across sessions "for persistent agent operations"; a **Declarative Builder** defines images in code ([daytona.io/docs](https://www.daytona.io/docs/)) **[PRIMARY]**.

**SDK.** Python (`pip install daytona`), TypeScript (`npm install @daytona/sdk`), plus Ruby, Go, and Java clients in the repo's `/libs` ([daytonaio/daytona](https://github.com/daytonaio/daytona)) **[PRIMARY]**. Note: secondary docs mention only Python/TS/JS execution runtimes inside sandboxes.

**Open-source status and license.** The repo [`daytonaio/daytona`](https://github.com/daytonaio/daytona) is **dual-licensed AGPL-3.0 / Apache-2.0** — core source under **AGPL-3.0**, contributions accepted under AGPL-3.0 or Apache-2.0, and the separate docs repo under Apache-2.0 ([daytona CONTRIBUTING.md](https://github.com/daytonaio/daytona/blob/main/CONTRIBUTING.md); [.licenserc.yaml](https://github.com/daytonaio/daytona/blob/main/.licenserc.yaml)) **[PRIMARY]** (read via search snippets — **[CORROBORATED-SECONDARY]** on the exact dual-license wording). **As of ~June 2026 the public repo is described as no longer actively maintained** — "core development has moved to a private codebase," repo stays public under its existing license ([daytonaio/daytona README](https://github.com/daytonaio/daytona)) **[PRIMARY]**. So the open-source Daytona is now effectively a frozen artifact; the live product is the hosted service.

**Self-hosting / on-prem / BYOC.** Daytona lists **"Bring Your Own Compute"** among deployment options and reserves **BYOC** (plus SSO, audit logs, larger limits) for **Enterprise, contact-sales** ([daytona.io/pricing](https://www.daytona.io/pricing)) **[PRIMARY]**. There is **no public self-hosting guide** for the current agent-sandbox product (unlike the old dev-env manager, and unlike E2B's `infra` repo). Practical read: self-hosting Daytona-the-agent-runtime is an enterprise conversation, not a documented DIY path — **[CORROBORATED-SECONDARY]** (absence of a guide across E2B-alternative round-ups, e.g. [Northflank: self-hostable alternatives to E2B](https://northflank.com/blog/self-hostable-alternatives-to-e2b-for-ai-agents)).

**Pricing** (from [daytona.io/pricing](https://www.daytona.io/pricing), page dated 2026-08-27 — **may drift**) **[PRIMARY]**:
- **$200** free compute credits on signup, no credit card.
- Pay-as-you-go, **per-second** billing: **vCPU $0.0504/h**, **memory $0.0162/GiB/h**, **storage $0.000108/GiB/h** (first 5 GiB free); **Windows +$0.0858/vCPU/h**.
- GPU on-demand: **H200 $2.61/h**, **H100 $2.27/h**, **RTX PRO 6000 $1.74/h**, **RTX 5090 $0.74/h**, **RTX 4090 $0.57/h**.
- **Startups:** up to **$50k** credits. **Enterprise:** custom (SSO, audit logs, BYOC).

**Funding.** Secondary reporting: a **$24M Series A in February 2026** "to expand the platform" ([search-surfaced summary, e.g. Ry Walker research / TechCrunch-tier coverage](https://rywalker.com/research/ai-agent-sandboxes)) **[SINGLE-SOURCE]** — I could not confirm the amount or lead investor against a primary announcement in this pass. Daytona earlier raised a seed round (amount unverified here). **Treat the $24M/Series A figure as weakly corroborated.**

**Sourcing:** primary for positioning, isolation phrasing, latency claim, snapshots, SDK, license, maintenance status, pricing. The key correction (containers + optional Kata, **not gVisor**) is corroborated-secondary and high-confidence. The 197 ms benchmark and the $24M Series A are single-source.

---

## 3. Modal Sandboxes

**What it is.** Modal is a **general serverless compute platform** (Python-first: functions, cron jobs, web endpoints, GPU batch/training/inference). **Sandboxes** are one primitive within it: "secure containers for executing untrusted user or agent code on Modal," created and driven programmatically via the Modal SDK ([Modal Sandboxes guide](https://modal.com/docs/guide/sandboxes)) **[PRIMARY]**.

**Isolation — gVisor.** Modal Sandboxes run inside **gVisor**, Google's user-space kernel that intercepts syscalls to isolate the workload from the host kernel. Modal's user-facing Sandbox docs only say "secure containers"; the gVisor detail is stated in Modal's own resource/blog content and corroborated by multiple third parties ([Modal blog: microVM sandboxes](https://modal.com/resources/best-microvm-sandboxes-ai-code-execution); [Blaxel vs Modal](https://blaxel.ai/blog/blaxel-vs-modal); [Northflank: Modal vs Vercel Sandbox](https://northflank.com/blog/modal-vs-vercel-sandbox); [LogRocket comparison](https://blog.logrocket.com/comparing-ai-agent-sandbox-platforms-e2b-modal-daytona-and-more/)) **[CORROBORATED-SECONDARY]**. So Modal's security boundary is a user-space kernel, **not** a hardware-VM boundary — weaker than Firecracker/Kata, stronger than a plain namespaced container.

**API.** `Sandbox.create()` provisions the container; `sandbox.exec(...)` runs commands with streaming stdout/stderr; lifecycle states Created → Scheduled → Started → (Ready) → Finished; `detach()` to close client connections. Readiness probes (TCP and exec, max 5 min). Named sandboxes are unique within an App; arbitrary key-value **tags** enable `Sandbox.list()` filtering ([Modal Sandboxes guide](https://modal.com/docs/guide/sandboxes)) **[PRIMARY]**.

**Lifetime.** Default max lifetime **5 minutes**, configurable up to **24 hours**; `idle_timeout` kills inactive sandboxes ([Modal Sandboxes guide](https://modal.com/docs/guide/sandboxes)) **[PRIMARY]**.

**Images.** Sandboxes take Modal **Images** (defined in code, layered), **Volumes**, **Secrets**, env vars — identical to Modal Functions ([Modal Sandboxes guide](https://modal.com/docs/guide/sandboxes)) **[PRIMARY]**.

**Networking / tunnels.** Sandboxes support **tunnels** for direct inbound connectivity to a port, and fine-grained networking controls (egress filtering / blocking) ([Modal Sandboxes guide](https://modal.com/docs/guide/sandboxes)) **[PRIMARY]** (feature list read via search).

**Snapshots** ([Modal Snapshots guide](https://modal.com/docs/guide/sandbox-snapshots)) **[PRIMARY]**:
- **Filesystem snapshots:** `image = sb.snapshot_filesystem()` returns an Image (stored as a diff from the base image — only modified files). New sandboxes fork from it: `Sandbox.create(image=image, ...)`. **Default TTL 30 days**, `ttl=` configurable, `ttl=None` = keep indefinitely.
- **Memory snapshots (experimental):** capture full RAM + filesystem — "an exact clone" with running processes preserved. `Sandbox.create(_experimental_enable_snapshot=True)` → `sb._experimental_snapshot()` → `Sandbox._experimental_from_snapshot(...)`. **TTL 7 days, non-extensible.**
- Agent-state pattern: store snapshot `object_id` in a DB or Modal Dict keyed by session; restore instead of cold-starting.

**GPU support.** Sandboxes can request GPUs (same GPU types as Modal Functions) ([Modal Sandboxes guide](https://modal.com/docs/guide/sandboxes)) **[PRIMARY]**.

**Pricing** (from [modal.com/pricing](https://modal.com/pricing), read 2026-08-30 — **may drift**) **[PRIMARY]**:
- **CPU:** $0.0000131 / core / s (standard Functions) vs **$0.00003942 / core / s for Sandboxes & Notebooks** (~3× the Function rate).
- **Memory:** $0.00000222 / GiB / s standard vs **$0.00000667 / GiB / s for Sandboxes & Notebooks**.
- **GPU / s:** B300 $0.001972, B200 $0.001736, H200 SXM $0.001261, H100 SXM5 $0.001097, A100 80GB $0.000694, L4 $0.000222, T4 $0.000164.
- **Volumes:** $0.09 / GiB / mo (1 TiB/mo free).
- **Billing:** by the second, on **whichever is higher — your resource request or actual usage**.
- **Plans:** Starter $0 ($30/mo included credit, 100 containers, 10 GPU concurrency); **Team $250/mo** ($100/mo credit, 5,000 containers, 50 GPU concurrency); Enterprise custom.
- The elevated Sandbox/Notebook CPU+memory rate is notable — running agents on Modal Sandboxes costs ~3× the base compute rate.

**Self-hosted / on-prem.** **Modal does not offer self-hosted or on-premise deployment.** It is exclusively a hosted, multi-tenant serverless cloud ([modal.com/pricing + docs, read 2026-08-30](https://modal.com/pricing)) **[CORROBORATED-SECONDARY]** (this is an absence-of-feature claim — no primary page says "we don't self-host"; it's the consistent read across Modal's docs and third-party comparisons, e.g. [Northflank: self-hostable alternatives to E2B](https://northflank.com/blog/self-hostable-alternatives-to-e2b-for-ai-agents), which excludes Modal). Enterprise contracts add SOC2, VPC peering, dedicated capacity — but still on Modal's infrastructure.

**Company.** Modal Labs, San Francisco. I did **not** verify funding figures in this pass — do not state a number without checking.

**Sourcing:** primary for the SDK, isolation-purpose statement, lifecycle, snapshots (incl. TTLs), pricing. gVisor is corroborated-secondary (Modal's own blog + 3 third parties; not in the user-facing Sandbox docs). "No self-hosting" is corroborated-secondary by absence.

---

## 4. Comparable sandbox providers (field map)

Brief, one primary source each where possible. Isolation / hosted-vs-self-hostable / open-source / one-line positioning.

### Cloudflare Sandboxes / Cloudflare Containers
- **What:** Sandbox SDK ([`@cloudflare/sandbox-sdk`](https://github.com/cloudflare/sandbox-sdk), TypeScript) over **Cloudflare Containers**, driven from a Worker / Durable Object. A sandbox "starts on demand when requested by name, sleeps when idle, wakes on request," addressable by a stable ID from anywhere. Persistent **code interpreters** (Python/JS/TS, Jupyter-style state), plus exec / git / file / process APIs ([Cloudflare Agents: Sandbox docs](https://developers.cloudflare.com/agents/tools/sandbox/); [Sandbox SDK getting started](https://developers.cloudflare.com/sandbox/get-started/)) **[PRIMARY]**.
- **GA:** Containers + Sandboxes reached **general availability April 2026** ([Cloudflare changelog 2026-04-13](https://developers.cloudflare.com/changelog/post/2026-04-13-containers-sandbox-ga/)) **[PRIMARY]**. June 2026: Cloudflare signaled moving code-interpreter/terminal/git into optional helpers ([changelog 2026-06-09](https://developers.cloudflare.com/changelog/post/2026-06-09-deprecating-sandbox-sdk-features/)) **[PRIMARY]**.
- **Isolation:** **conflicting reports.** Some third parties say plain shared-kernel containers; others say "each container instance runs in an isolated micro-VM using technology similar to Firecracker" ([InfoQ: Cloudflare Sandboxes GA](https://www.infoq.com/news/2026/04/cloudflare-sandboxes-ga/); [Blaxel: Cloudflare Containers alternatives](https://blaxel.ai/blog/cloudflare-containers-alternatives)) **[SINGLE-SOURCE]** each way — **do not state the isolation tech definitively**; Cloudflare has not published a Firecracker claim I could verify. Cold starts ~180–320 ms (secondary).
- **Hosted-only**, not self-hostable. SDK is open source; the platform is not. Egress control via **Outbound Workers**. One-line: *edge-native sandboxes glued to the Workers/Durable Objects programming model.*

### Vercel Sandbox
- **What:** "a compute primitive to safely run untrusted or user-generated code," for AI agents / codegen / experimentation. JS SDK (`@vercel/sandbox`), Python SDK (`vercel.sandbox`), CLI. Repo [`vercel/sandbox`](https://github.com/vercel/sandbox) (SDK + CLI). Default image `vercel/sandbox/universal` (Node LTS, Python 3.14, coding agents). Multi-agent isolation via per-agent Linux users; **persistent sandboxes** (auto-save on stop, default), snapshots, **drives (beta)**, S3/FUSE mounts ([Vercel Sandbox docs](https://vercel.com/docs/sandbox)) **[PRIMARY]**.
- **Isolation:** **"Each sandbox runs in a secure Firecracker microVM with its own filesystem and network"** — can even run Docker, VPN clients, FUSE drivers (system-privileged) ([Vercel Sandbox docs](https://vercel.com/docs/sandbox)) **[PRIMARY]**. Runs on Amazon Linux 2023 ([Northflank](https://northflank.com/blog/modal-vs-vercel-sandbox)).
- **Pricing** ([vercel.com/docs/sandbox/pricing](https://vercel.com/docs/sandbox/pricing), page `last_updated: 2026-08-21`) **[PRIMARY]**: Active CPU **$0.128/vCPU-hour** (iad1; only counts CPU actually executing, not I/O wait); Provisioned Memory **$0.0212/GB-hour** (each vCPU carries 2 GB); Sandbox Creations $0.60/1M; egress $0.15/GB (downloads free); snapshot storage $0.08/GB-month. **Hobby:** 5 CPU-hours + 420 GB-hours/mo free, 10 concurrent, **45-min max session**, max 4 vCPU/8 GB. **Pro:** billed against the $20/mo plan credit, **10,000 concurrent**, **24-hour** max session, max 8 vCPU/16 GB. **Enterprise:** max 32 vCPU/64 GB. Default per-sandbox: 2 vCPU, 32 GB ephemeral NVMe, 5-min default timeout. Regions: iad1/sfo1/cle1/cdg1.
- **Hosted-only** (Vercel infra), not self-hostable. SDK Apache-2.0. One-line: *Firecracker sandboxes as a first-class Vercel primitive, priced on active-CPU.*

### Northflank
- **What:** general application platform (services, jobs, databases, pipelines) that also sells **sandboxes for AI agents**. Isolation is **per-workload selectable — Kata Containers, Firecracker, or gVisor** depending on the isolation requirement ([Northflank: Modal vs Vercel Sandbox](https://northflank.com/blog/modal-vs-vercel-sandbox)) **[CORROBORATED-SECONDARY]** (Northflank's own blog; consistent across their material).
- **Self-hostable / BYOC:** self-serve **bring-your-own-cloud** on AWS, GCP, Azure, Oracle, CoreWeave, Civo, **bare-metal, and on-premises** — "~600 BYOC regions" ([Northflank](https://northflank.com/blog/modal-vs-vercel-sandbox)) **[CORROBORATED-SECONDARY]**. This is the strongest BYOC story in the field alongside Coder.
- Managed compute ~ **$0.01667/vCPU-hr, $0.00833/GB-hr** (secondary, from Northflank's own pricing content). Per-second, no platform session limit. Not open source. One-line: *BYOC-first platform where the sandbox isolation tech is a knob you turn.*

### Runloop
- **What:** "**Devbox**" sandboxes purpose-built for AI **coding** agents. **Blueprints** (pre-baked env + tools), **snapshots** (instant state capture/restore), SOC2. Runs on a **custom bare-metal hypervisor** ("2× faster vCPUs than standard cloud VMs"), i.e. VM-level isolation. Devboxes start **<1 s**, scale to **>20,000 concurrent** ([Runloop docs: Devbox overview](https://docs.runloop.ai/docs/devboxes/overview); [Runloop pricing](https://runloop.ai/pricing)) **[CORROBORATED-SECONDARY]** (Runloop's own docs + [Ry Walker research](https://rywalker.com/research/runloop)).
- **Pricing:** Basic $0 + usage, **Pro $250/mo**, Enterprise custom; compute **$0.108/CPU-hr**, **$0.0252/GB-hr** memory; $50 trial credit.
- **Hosted-only.** Not open source. One-line: *managed VM sandboxes tuned specifically for coding-agent workloads and benchmarking.*

### Blaxel
- **What:** "**perpetual sandbox**" platform for AI agents in production. **microVM isolation** (Lambda-style, own kernel per workload). Sandboxes sit in **standby indefinitely at zero compute cost** and **resume in <25 ms** with full filesystem + memory state. Co-located agent hosting (deploy agent logic next to the sandbox to kill network round-trips) ([Blaxel blog: code execution sandboxes](https://blaxel.ai/blog/code-execution-sandboxes-for-ai-agents); [Blaxel pricing](https://blaxel.ai/pricing)) **[SINGLE-SOURCE]** (nearly all detail comes from Blaxel's own marketing; the <25 ms resume and "perpetual" model are not independently benchmarked in what I found).
- **Pricing:** contact-sales; $200 free credits; idle standby billed only for snapshot storage (~$0.00000007716/GB/s). **Managed-only**, not BYOC, not open source. One-line: *microVM sandboxes that hibernate for free and wake instantly.*

### Coder (coder.com)
- **What:** open-source (**AGPL-3.0** core + enterprise) platform that provisions standardized dev environments via **Terraform templates** on infrastructure **you** control — Kubernetes, VMs, cloud, or **on-premises** ([Coder docs](https://coder.com/docs/ai-coder/tasks)) **[PRIMARY]**. **Coder Tasks** (launched 2025) = run AI coding agents (Claude Code, Aider, Goose, Amazon Q, …) each **in its own isolated, governed workspace** on your infra. April 2026 renames: "Agent Boundaries" → **Agent Firewall**, "AI Bridge" → **AI Gateway**; an **AI Governance** add-on centralizes model access, policy, and audit ([Coder blog: enterprise platform for self-hosted AI dev](https://coder.com/blog/coder-enterprise-grade-platform-for-self-hosted-ai-development)) **[PRIMARY]**.
- **Isolation:** whatever the workspace template provisions — a K8s pod, a VM, a container. Coder is the control plane + governance, not an isolation runtime.
- **Fully self-hostable** — that is the entire product; there is a Coder-hosted option but the norm is customer infra, including air-gapped. One-line: *the self-hosted, Terraform-templated way to give humans and agents governed workspaces on your own metal.*

### Fly.io Machines / Sprites
- **Fly Machines:** API-driven **Firecracker / KVM hardware-isolated VMs** that boot any OCI image — a general substrate for agent workloads ([fly.io/learn: Firecracker VM](https://fly.io/learn/firecracker-vm/)) **[PRIMARY]**.
- **Sprites** (introduced ~**2026-01-13**): Firecracker VMs **purpose-built to isolate coding agents** — persistent but scale-to-zero, online in **1–12 s**, each with its own CPU/memory/filesystem/network namespace, unable to see the host or other VMs ([devclass: Fly.io introduces Sprites](https://www.devclass.com/ai-ml/2026/01/13/flyio-introduces-sprites-lightweight-persistent-vms-to-isolate-agentic-ai/4079557); [techzine](https://www.techzine.eu/news/devops/137884/fly-io-puts-ai-agents-in-vms-not-containers/); [fly.io/learn: agent sandbox](https://fly.io/learn/agent-sandbox/)) **[CORROBORATED-SECONDARY]**.
- **Hosted-only** (Fly infra). One-line: *Firecracker VMs with a serverless DX; Sprites is the agent-shaped packaging.*

### hopx.ai
- **What:** managed **Firecracker micro-VM** sandboxes (by Bunnyshell) for AI agents, code execution, CI/CD isolation, and MCP-server hosting; "spin up in milliseconds"; MCP server for Cursor/Windsurf/Claude Desktop ([hopx.ai](https://hopx.ai/); [Northflank: HopX alternatives](https://northflank.com/blog/hopx-ai-alternatives)) **[SINGLE-SOURCE]** / lightly corroborated.
- **BYOC + on-premise:** claims **bring-your-own-cloud on AWS/GCP/Azure** *and* **on-premises installation** — "your agent code and data never leave your infrastructure" ([hopx.ai](https://hopx.ai/); [Northflank](https://northflank.com/blog/hopx-ai-alternatives)) **[SINGLE-SOURCE]** (claim appears on hopx's own site and one third-party round-up; not independently verified). If accurate, hopx is one of the few Firecracker-grade sandboxes with an explicit on-prem story. One-line: *Firecracker sandboxes with a BYOC/on-prem pitch — verify the on-prem claim before relying on it.*

### Arrakis
- [`abshkbh/arrakis`](https://github.com/abshkbh/arrakis) — **open-source** (check LICENSE), **self-hosted** sandbox for agent code execution + computer use. **micro-VM isolation via `cloud-hypervisor`** (Rust VMM). REST API + Python SDK (`py-arrakis`) + MCP server. **Snapshot/restore ("backtracking")** as a first-class feature. Boots a micro-VM in **<7 s** ([arrakis detailed README](https://github.com/abshkbh/arrakis/blob/main/docs/detailed-README.md)) **[PRIMARY]**. Single-maintainer project. One-line: *self-hostable Cloud-Hypervisor sandbox with agent backtracking built in.*

### microsandbox
- [`superradcompany/microsandbox`](https://github.com/superradcompany/microsandbox) — **open-source (Apache-2.0)**, **self-hosted, local-first micro-VM runtime** using **libkrun**; boots in ~**200 ms**; MCP support; run untrusted code with "hardware-level isolation" on your own machine ([microsandbox repo](https://github.com/superradcompany/microsandbox); [Bright Coding write-up](https://www.blog.brightcoding.dev/2026/06/30/microsandbox-self-hosted-sandboxes-that-boot-in-200ms)) **[CORROBORATED-SECONDARY]**. One-line: *the "just run it on my laptop / my server" open-source micro-VM sandbox.*

### Cua / computer-use agents
- [`trycua/cua`](https://github.com/trycua) — open-source framework for **computer-use agents** with sandboxed desktop VMs (macOS/Linux), using Lume/Lumier VM tooling on Apple Silicon; local or cloud ([trycua GitHub](https://github.com/trycua)) **[SINGLE-SOURCE]** (not fetched directly this pass). One-line: *open-source desktop-VM sandboxes for GUI/computer-use agents, Mac-friendly.*

### Depot
- Depot is a **remote container-build accelerator** and managed GitHub Actions runner service. I could **not verify** that Depot ships a general-purpose agent **sandbox** product ([depot.dev](https://depot.dev/)) — **UNVERIFIED**; treat "Depot has a sandbox" as unconfirmed and likely a conflation with their build/runner isolation.

### Also seen in the field (from [restyler/awesome-sandbox](https://github.com/restyler/awesome-sandbox), **[CORROBORATED-SECONDARY]** as a catalog):
- **Koyeb Sandboxes** — managed **bare-metal micro-VM** sandboxes for agents. Hosted-only.
- **Deno Sandbox** — managed **Firecracker** micro-VMs on Deno Deploy. Hosted-only; SDK MIT.
- **AWS Bedrock AgentCore** — managed agent platform, **Firecracker**-isolated. Hosted-only.
- **Apple Containerization** — Apache-2.0, VM-backed OCI containers, **macOS-only**.
- **Docker Sandboxes** — Docker's own "disposable micro-VMs for AI coding agents on the developer's machine" ([Docker blog: why microVMs](https://www.docker.com/blog/why-microvms-the-architecture-behind-docker-sandboxes/)) **[PRIMARY]**; local.
- **Kata Containers**, **Gitpod** (AGPL-3.0), **llm-sandbox** (MIT), **nono**, **iron-proxy**, **Infisical Agent Vault** — supporting pieces (isolation runtimes, egress proxies, credential brokers) rather than hosted sandbox products.

**Sourcing:** primary for Cloudflare/Vercel/Coder/Fly/Arrakis/microsandbox/Docker core facts; corroborated-secondary for Northflank BYOC breadth and Runloop; **single-source (weak)** for Blaxel's numbers, hopx's on-prem claim, and Cua. Cloudflare's isolation tech is **genuinely unresolved** in public sources. Depot-has-a-sandbox is **unverified**.

---

## 5. Isolation technology spectrum

Weakest → strongest security boundary; each rung trades startup cost / density / compatibility for isolation.

### Namespaces + cgroups containers (runc)
Standard Linux containers: PID/mount/network/user namespaces + cgroup resource limits, all processes sharing **one host kernel**. Near-zero overhead, instant start, full compatibility. A single Linux kernel local-privilege-escalation bug (or a container-runtime CVE) escapes to the host. Industry consensus: **not a sufficient boundary for untrusted / unattended code** ([Docker blog: why microVMs](https://www.docker.com/blog/why-microvms-the-architecture-behind-docker-sandboxes/); ["Your Container Is Not a Sandbox"](https://emirb.github.io/blog/microvm-2026/)) **[CORROBORATED-SECONDARY]**.

### gVisor / runsc
Google's **application kernel**: a user-space process (the **Sentry**) reimplements a large subset of the Linux syscall surface. The sandboxed workload's syscalls are **intercepted and serviced in user space**; only a small allow-listed set reaches the host kernel, behind a seccomp filter. `runsc` is the OCI runtime binary — **`runsc` *is* gVisor**, not a separate technology.
- **Platforms** (interception mechanism): `ptrace` (original, extremely slow — a "blank" syscall goes from ~20 ns native to ~7 ms, ~350×); `KVM`; and **`systrap`**, the default since 2023, which replaced ptrace ([gVisor blog: Systrap release](https://gvisor.dev/blog/2023/04/28/systrap-release/)) **[PRIMARY]**.
- **Overhead** ([gVisor performance guide](https://gvisor.dev/docs/architecture_guide/performance/)) **[PRIMARY]**: **no CPU emulation → "no runtime cost imposed for CPU operations"** (good for CPU-bound / ML work). "Structural" syscall cost is real — on the KVM platform a syscall round-trip is ~**800 ns vs ~70 ns** native (~10× for tiny syscalls), shrinking in relative terms for larger operations. Network and file I/O are "bound by implementation costs" (the user-space netstack and VFS). Memory overhead = fixed component + component that scales with OS-resource usage. Third-party summaries: **~10–30% slower on I/O-heavy workloads**, CPU-bound barely affected; a 2019 USENIX study measured syscalls **2–11×** native ([Northflank: what is gVisor](https://northflank.com/blog/what-is-gvisor)) **[CORROBORATED-SECONDARY]**.
- **No hardware virtualization required** in systrap mode. The trade-off vs a micro-VM: gVisor **shrinks the host-kernel attack surface** (fewer syscalls reachable) but the **Sentry itself is a large user-space attack target**; a micro-VM instead gives a **true hypervisor/VT-x boundary** but exposes a full guest kernel.
- **Used by:** **Modal** Sandboxes, Google Cloud Run / GKE Sandbox, historically Ant Group at scale. **NOT Daytona** (chapter correction).

### Kata Containers
OCI/CRI-compatible runtime that boots a **lightweight VM per pod/container**, each with **its own guest kernel**, hardware-enforced via **KVM**. Slots into container tooling (containerd/CRI) transparently. VMM backends: **QEMU, Firecracker, Cloud Hypervisor, Dragonball** ([Kata: virtualization design](https://kata-containers.github.io/kata-containers/design/virtualization/)) **[PRIMARY]**. Overhead ~**50–100 ms boot, ~100–200 MiB/pod** for guest kernel + agent ([systemshardening: gVisor vs Kata](https://www.systemshardening.com/articles/cross-cutting/gvisor-kata-shared-kernel-defense/)) **[CORROBORATED-SECONDARY]**. Used by **Daytona (opt-in)** and available on **Northflank**.

### Firecracker
AWS's minimalist **KVM-based VMM**, written in Rust, from the NSDI '20 paper **"Firecracker: Lightweight Virtualization for Serverless Applications"** (Agache, Brooker, Iordache, Liguori, Neugebauer, Piwonka, Popa) ([USENIX NSDI '20](https://www.usenix.org/conference/nsdi20/presentation/agache); [firecracker-microvm/firecracker](https://github.com/firecracker-microvm/firecracker)) **[PRIMARY]**:
- **Boot to application code in <125 ms**; **<5 MiB memory overhead per micro-VM**; **up to 150 micro-VMs/s per host**.
- **Minimal device model:** ~5 emulated devices (a few VirtIO + a couple legacy) vs QEMU's 40+; loads an uncompressed kernel directly and skips the BIOS/firmware handshake — this is what buys the fast boot and small attack surface.
- Powers **AWS Lambda and Fargate**.
- **Used by:** **E2B**, **Vercel Sandbox**, **Fly.io** (Machines + Sprites), **Koyeb**, **Deno Deploy**, **hopx.ai** (claimed), **AWS Bedrock AgentCore**; Cloudflare Containers described by some third parties as "similar to Firecracker" (unconfirmed).

### Cloud Hypervisor
Rust **KVM-based VMM** (originated at Intel, now under the Linux Foundation). More capable device model than Firecracker — device hotplug, live migration, larger guests, better general-purpose VM support — at some cost to minimalism ([opencomputer.dev: Firecracker vs Cloud Hypervisor vs Kata](https://opencomputer.dev/guides/firecracker-vs-cloud-hypervisor-vs-kata/)) **[CORROBORATED-SECONDARY]**. A Kata backend; the VMM behind **Arrakis**.

### libkrun
Library-form VMM (KVM) you embed in a process rather than run as a daemon; used by **microsandbox** and Podman machine. Enables "micro-VM as a library call."

### Summary ordering (weakest → strongest boundary)
1. In-process syscall restriction — seccomp / Landlock / macOS Seatbelt (as in Claude Code's default). No process/kernel isolation, just a smaller syscall menu.
2. Namespaces + cgroups container (runc) / devcontainer — shared host kernel.
3. **gVisor** — user-space kernel; smaller host-kernel surface, no VT boundary; Sentry is the new target.
4. **Kata / Firecracker / Cloud Hypervisor micro-VM** — real per-agent hypervisor boundary; largest isolation, ~50–125 ms boot + tens-to-hundreds of MiB overhead.

For a non-moderated **local** model driving an **unattended** agent, the practical recommendation across sources is rung 3 or 4, plus egress filtering regardless of rung ([manveerc: AI agent sandboxing guide](https://manveerc.substack.com/p/ai-agent-sandboxing-guide); ["Your Container Is Not a Sandbox"](https://emirb.github.io/blog/microvm-2026/)) **[CORROBORATED-SECONDARY]**.

**Sourcing:** primary for the Firecracker paper metrics, gVisor performance guide, Kata design, Systrap. Overhead percentages and the Kata 50–100 ms / 100–200 MiB figures are corroborated-secondary.

---

## 6. Self-hosted / BYOC / on-premise / air-gapped deployment

Which of these can actually run inside the **customer's own infrastructure** (not just "Enterprise, contact us")?

| Product | Customer-infra deployment | Evidence | Notes |
|---|---|---|---|
| **Coder** | **Yes — full.** K8s / VMs / cloud / on-prem / air-gapped. It *is* the product. | [Coder docs](https://coder.com/docs/ai-coder/tasks) **[PRIMARY]** | AGPL-3.0 core + enterprise add-ons; governance (Agent Firewall, AI Gateway) built for this. |
| **Northflank** | **Yes — self-serve BYOC.** AWS/GCP/Azure/Oracle/CoreWeave/Civo/**bare-metal/on-prem**. | [Northflank](https://northflank.com/blog/modal-vs-vercel-sandbox) **[CORROBORATED-SECONDARY]** | Proprietary control plane, runs in your account. Per-workload Kata/Firecracker/gVisor. |
| **E2B** | **Yes — DIY.** `e2b-dev/infra`, Apache-2.0. GCP (prod), AWS (beta). | [infra/self-host.md](https://github.com/e2b-dev/infra/blob/main/self-host.md) **[PRIMARY]** | Real Nomad+Consul+Postgres+Terraform+Packer project; needs Cloudflare for DNS (awkward for air-gap); Firecracker needs bare-metal / nested virt. |
| **Warp Oz** | **Yes — Enterprise.** "Oz runs self-hosted in Kubernetes, with Docker, or via direct execution"; run agent workloads on your own infra, control compute/network. **BYOLLM** = route inference through your own cloud. | [Warp: Oz page](https://www.warp.dev/oz), [Warp pricing](https://www.warp.dev/pricing) **[PRIMARY]** | Gated to Enterprise. On-prem Oz + enforced ZDR per the 2026-08-29-3 pass. |
| **hopx.ai** | **Claimed** — BYOC (AWS/GCP/Azure) + on-premises install. | [hopx.ai](https://hopx.ai/) **[SINGLE-SOURCE]** | Firecracker-grade; on-prem claim **not independently verified**. |
| **Arrakis** | **Yes — inherently.** Open-source, single-node self-host, Cloud-Hypervisor. | [repo](https://github.com/abshkbh/arrakis) **[PRIMARY]** | Solo-maintainer; good for a small team / lab, not a fleet. |
| **microsandbox** | **Yes — inherently.** Apache-2.0, local-first, libkrun. | [repo](https://github.com/superradcompany/microsandbox) **[PRIMARY]** | "Run it on your own box" is the whole pitch. |
| **Daytona** | **Enterprise-only, undocumented.** "Bring Your Own Compute" / BYOC listed for Enterprise; no public self-host guide; OSS repo frozen (~June 2026). | [daytona.io/pricing](https://www.daytona.io/pricing) **[PRIMARY]** | Was fully self-hostable as the old dev-env manager; the *agent-runtime* is not. |
| **Modal** | **No.** Cloud-only serverless; Enterprise adds VPC peering / dedicated capacity but still on Modal infra. | absence across [Modal docs](https://modal.com/docs/guide/sandboxes) + comparisons **[CORROBORATED-SECONDARY]** | |
| **Vercel Sandbox** | **No.** Vercel infra only. | [Vercel docs](https://vercel.com/docs/sandbox) **[PRIMARY]** | |
| **Cloudflare Sandboxes** | **No.** Cloudflare edge only. | [Cloudflare docs](https://developers.cloudflare.com/sandbox/get-started/) **[PRIMARY]** | |
| **Runloop / Blaxel / Fly.io Sprites / Koyeb / Deno** | **No.** Hosted-only. | vendor docs **[PRIMARY]/[SINGLE-SOURCE]** | |

**Practical minimum self-hosted setup for a team.** The chapter currently says: *"a devcontainer or Docker sandbox with an egress allow-list; a micro-VM per agent when agents run fully unattended."* This is **well corroborated** and only needs light refinement:
- **Attended / semi-trusted** agent (human reviews actions, model is at least somewhat aligned): a **devcontainer or rootless Docker container**, non-root user, read-only mounts where possible, **and an egress allow-list** (proxy or firewall) is a reasonable floor. The dominant real-world risk here is **credential / data exfiltration and unwanted external calls**, not kernel escape — so the egress control matters more than the isolation rung ([manveerc guide](https://manveerc.substack.com/p/ai-agent-sandboxing-guide); [Docker blog](https://www.docker.com/blog/why-microvms-the-architecture-behind-docker-sandboxes/)) **[CORROBORATED-SECONDARY]**.
- **Unattended / autonomous** agent, especially against a **non-moderated local model**: a **VM boundary per agent** — Firecracker or Kata micro-VM (via `e2b-dev/infra`, Fly Machines, Kata-on-K8s with `RuntimeClass`, `microsandbox`, or Arrakis), **or gVisor** as a lighter middle option — plus the same egress allow-list, plus no ambient cloud credentials in the sandbox.
- Add a **middle rung** the chapter omits: **gVisor via `runsc` + Kubernetes `RuntimeClass`** is the common "stronger than a container, cheaper than a VM" choice and is trivially self-hosted on an existing cluster.

**Sourcing:** primary for each product's own deployment story; corroborated-secondary for Northflank breadth and the "container + egress list, micro-VM when unattended" recommendation; single-source for hopx's on-prem claim.

---

## 7. Comparison with Warp Oz

**The core distinction.** Warp Oz is an **orchestration platform**; E2B / Daytona / Modal are **sandbox primitives**.

- **Oz** gives you: a fleet manager for hundreds of parallel agents, interactive + programmatic + **scheduled/recurring** launches, **multi-harness** execution (Claude Code, OpenAI Codex, Warp's own agent) with **cross-harness persistent memory**, governance / observability / audit, a UI ("single pane of glass"), and — since the **2026-05-19 multi-harness update** — **automatic sub-agent orchestration** for long-horizon tasks ([Warp blog: Oz](https://www.warp.dev/blog/oz-orchestration-platform-cloud-agents); [SD Times: Warp updates Oz](https://sdtimes.com/ai/warp-updates-oz-to-help-enterprises-orchestrate-coding-agents-across-any-model-or-harness/)) **[PRIMARY]** + **[CORROBORATED-SECONDARY]**. Each agent happens to run in its **own Docker container** (a cloud environment bundling the container + git repos + startup commands; multi-repo environments allow cross-repo changes). **You do not build the orchestration — Warp did.**
- **E2B / Daytona / Modal** give you: an **SDK + an isolated runtime**. You call `create()` / `exec()` / snapshot, and **you build** the scheduling, the fleet view, the memory, the harness integration, the governance. Modal additionally is a **general serverless platform** (sandboxes are one primitive beside GPU functions); Daytona is **sandbox-first for agents** (fastest cold start); E2B is **sandbox-first for agents and code-interpreters** (Firecracker, self-hostable).

**Isolation strength is inverted from capability.** On raw per-agent isolation, **Oz's Docker container is the weakest** option in this table — weaker than E2B's Firecracker micro-VM or Modal's gVisor. Oz's value is the layer *above* the sandbox, not the sandbox itself. A security-conscious team could run Oz for orchestration and still want a stronger isolation runtime underneath, or self-host Oz on a Kata-backed cluster.

### Comparison table

| Dimension | **Warp Oz** | **E2B** | **Daytona** | **Modal (Sandboxes)** |
|---|---|---|---|---|
| **Category** | Agent **orchestration platform** (fleet mgmt, scheduling, multi-harness, memory, governance, UI) | **Sandbox primitive** (SDK + runtime) for agents / code interpreters | **Sandbox primitive**, sandbox-first for agents | **General serverless platform**; Sandbox is one primitive |
| **Per-agent isolation** | **Docker container** (shared kernel) | **Firecracker micro-VM** (own kernel) | **Docker/OCI container** default; **Kata** micro-VM opt-in | **gVisor** (user-space kernel) |
| **Isolation strength** | Weakest of the four | Strongest | Weak default / strong opt-in | Middle |
| **You build the orchestration?** | **No** — provided | **Yes** | **Yes** | **Yes** |
| **Multi-harness (Claude Code / Codex / others)** | **Yes**, native, + cross-harness memory | Harness-agnostic (runs any code; you wire the harness) | Harness-agnostic | Harness-agnostic |
| **Hosted** | Default | Default | Default | Only |
| **Self-hostable / BYOC** | **Yes (Enterprise)** — K8s / Docker / direct exec; BYOLLM | **Yes (DIY)** — `e2b-dev/infra`, Apache-2.0, GCP/AWS-beta | **Enterprise BYOC only, undocumented**; OSS repo frozen | **No** |
| **Bring your own model** | BYOK on **Business** tier; **BYOLLM** (own-cloud inference) on Enterprise | Model-agnostic (E2B runs code, not the model) | Model-agnostic | Model-agnostic; can also *host* the model (GPU) |
| **Open source** | No (client/terminal partly OSS) | **Yes** (SDK + infra, Apache-2.0) | Partial (AGPL-3.0 core, now maintenance-only) | No |
| **Snapshots / persistence** | Cloud env persistence; cross-harness memory | Pause/resume; VM snapshot | Stateful snapshots; declarative images | Filesystem snapshots (30d TTL) + experimental memory snapshots (7d) |
| **Pricing shape** (as-of 2026-08-30) | Subscription + cloud-agent credits: Free / **Build $20** / **Max $200** / **Business $50/user** / Enterprise | Subscription + per-second usage: Free / **Pro $150/mo** / Enterprise | $200 credit + per-second usage; Enterprise | Per-second usage (Sandbox CPU/mem ~3× base rate) + plan: Starter $0 / **Team $250/mo** / Enterprise |
| **Target user** | Enterprise / eng-org running an **agent fleet** | **Platform builders / product teams** embedding code execution | **Agent builders** wanting fastest cold start | Teams **already on Modal** / ML-adjacent workloads |

### Warp Oz facts that appear to have changed since Feb 2026 (chapter correction)

The chapter currently states: *"Build ($20/mo) and Max ($200/mo) tiers support bring-your-own provider API key."* Per [warp.dev/pricing](https://www.warp.dev/pricing) read **2026-08-30** **[PRIMARY]** (read via automated fetch — **re-verify before print**):
- **Build ($20/mo)** and **Max ($200/mo)** now include a fixed credit allowance (1,500 / 18,000 credits) and **do NOT allow bring-your-own API keys**.
- A **new Business tier ($50/user/mo, up to 25 seats)** is where **"bring your own API keys and custom inference endpoints"** now lives.
- **Enterprise** adds **"route inference through your own cloud (BYOLLM)"** + **self-hosted cloud agents on your infrastructure**.
- Also seen: new users get **1,000 cloud-agent credits** in the first month ([Warp materials](https://www.warp.dev/oz)) **[CORROBORATED-SECONDARY]**.

**Recommended chapter edit:** change "Build ($20/mo) and Max ($200/mo) tiers support bring-your-own provider API key" → "the Business tier ($50/user/mo) supports bring-your-own provider API key and custom inference endpoints; Enterprise adds bring-your-own-LLM managed inference routed through your own cloud, enforced zero data retention, and on-premise / self-hosted Oz (Kubernetes, Docker, or direct execution)." Keep the ZDR / on-prem Oz facts from the 2026-08-29-3 pass.

**Sourcing:** primary for Oz capabilities, the multi-harness update date, Warp pricing tiers; the pricing-tier *change* since Feb 2026 is primary-but-single-read — flag for re-verification.

---

## Sources

1. E2B docs — https://docs.e2b.dev/
2. E2B pricing — https://e2b.dev/pricing
3. E2B GitHub org / `e2b-dev/E2B` — https://github.com/e2b-dev/E2B
4. `e2b-dev/infra` repo — https://github.com/e2b-dev/infra
5. `e2b-dev/infra` self-host.md — https://github.com/e2b-dev/infra/blob/main/self-host.md
6. DeepWiki: e2b-dev/infra self-hosting guide — https://deepwiki.com/e2b-dev/infra/9-self-hosting-guide
7. Beam: How to self-host a code execution sandbox (2026) — https://www.beam.cloud/blog/how-to-self-host-code-sandbox
8. Spheron: E2B, Daytona, Firecracker setup guide (2026) — https://www.spheron.network/blog/ai-agent-code-execution-sandbox-e2b-daytona-firecracker/
9. E2B blog: Perplexity advanced data analysis — https://e2b.dev/blog/how-perplexity-implemented-advanced-data-analysis-for-pro-users-in-1-week
10. E2B blog: How Manus uses E2B — https://e2b.dev/blog/how-manus-uses-e2b-to-provide-agents-with-virtual-computers
11. E2B blog: Series A — https://e2b.dev/blog/series-a
12. Insight Partners: E2B $21M Series A — https://www.insightpartners.com/ideas/e2b-raises-a-21m-series-a-to-offer-cloud-for-ai-agents-to-fortune-100/
13. ain.ua: E2B raises $21M — https://en.ain.ua/2025/07/28/e2b-raises-21m/
14. Crunchbase: E2B seed round — https://www.crunchbase.com/funding_round/e2b-1c91-seed--6b20b90e
15. `e2b-dev/desktop` — https://github.com/e2b-dev/desktop
16. `e2b-dev/surf` — https://github.com/e2b-dev/surf ; https://surf.e2b.dev/
17. SoftwareSeni: E2B, Daytona, Modal, Sprites.dev comparison — https://www.softwareseni.com/e2b-daytona-modal-and-sprites-dev-choosing-the-right-ai-agent-sandbox-platform/
18. Dwarves memo: E2B breakdown — https://memo.d.foundation/breakdown/e2b
19. Daytona — https://www.daytona.io/
20. Daytona docs — https://www.daytona.io/docs/
21. Daytona pricing — https://www.daytona.io/pricing
22. `daytonaio/daytona` — https://github.com/daytonaio/daytona (+ CONTRIBUTING.md, .licenserc.yaml)
23. Northflank: Daytona vs E2B (2026) — https://northflank.com/blog/daytona-vs-e2b-ai-code-execution-sandboxes
24. morphllm: Daytona alternatives — https://www.morphllm.com/comparisons/daytona-alternative
25. MintMCP: agent sandbox / 11 options (2026) — https://www.mintmcp.com/blog/agent-sandbox
26. Medium (kacperwlodarczyk): Sub-90ms cloud code execution with Daytona — https://medium.com/@kacperwlodarczyk/sub-90ms-cloud-code-execution-how-daytona-replaced-docker-in-our-ai-agent-stack-b6f343e4e547
27. Ry Walker research: AI agent sandboxes compared — https://rywalker.com/research/ai-agent-sandboxes
28. Modal Sandboxes guide — https://modal.com/docs/guide/sandboxes
29. Modal Sandbox resources and pricing — https://modal.com/docs/guide/sandbox-resources
30. Modal Snapshots guide — https://modal.com/docs/guide/sandbox-snapshots
31. Modal pricing — https://modal.com/pricing
32. Modal blog: best microVM sandboxes for AI code execution — https://modal.com/resources/best-microvm-sandboxes-ai-code-execution
33. Blaxel vs Modal — https://blaxel.ai/blog/blaxel-vs-modal
34. Northflank: Modal vs Vercel Sandbox — https://northflank.com/blog/modal-vs-vercel-sandbox
35. LogRocket: comparing AI agent sandbox platforms — https://blog.logrocket.com/comparing-ai-agent-sandbox-platforms-e2b-modal-daytona-and-more/
36. Northflank: self-hostable alternatives to E2B (2026) — https://northflank.com/blog/self-hostable-alternatives-to-e2b-for-ai-agents
37. Cloudflare Agents: Sandbox docs — https://developers.cloudflare.com/agents/tools/sandbox/
38. Cloudflare Sandbox SDK getting started — https://developers.cloudflare.com/sandbox/get-started/
39. `cloudflare/sandbox-sdk` — https://github.com/cloudflare/sandbox-sdk
40. Cloudflare changelog: Containers + Sandboxes GA (2026-04-13) — https://developers.cloudflare.com/changelog/post/2026-04-13-containers-sandbox-ga/
41. Cloudflare changelog: deprecating Sandbox SDK features (2026-06-09) — https://developers.cloudflare.com/changelog/post/2026-06-09-deprecating-sandbox-sdk-features/
42. InfoQ: Cloudflare Sandboxes reach GA — https://www.infoq.com/news/2026/04/cloudflare-sandboxes-ga/
43. Blaxel: Cloudflare Containers alternatives — https://blaxel.ai/blog/cloudflare-containers-alternatives
44. Vercel Sandbox docs — https://vercel.com/docs/sandbox
45. Vercel Sandbox pricing and quotas — https://vercel.com/docs/sandbox/pricing
46. `vercel/sandbox` — https://github.com/vercel/sandbox
47. Runloop Devbox overview — https://docs.runloop.ai/docs/devboxes/overview
48. Runloop pricing — https://runloop.ai/pricing
49. Ry Walker research: Runloop — https://rywalker.com/research/runloop
50. Blaxel blog: best code execution sandboxes for AI agents (2026) — https://blaxel.ai/blog/code-execution-sandboxes-for-ai-agents
51. Blaxel pricing — https://blaxel.ai/pricing
52. Coder docs: Coder Tasks / AI coder — https://coder.com/docs/ai-coder/tasks
53. Coder blog: enterprise-grade platform for self-hosted AI development — https://coder.com/blog/coder-enterprise-grade-platform-for-self-hosted-ai-development
54. Coder blog: AI development infrastructure for hybrid human and agent teams — https://coder.com/blog/ai-development-infrastructure-for-hybrid-human-and-agent-teams
55. devclass: Fly.io introduces Sprites (2026-01-13) — https://www.devclass.com/ai-ml/2026/01/13/flyio-introduces-sprites-lightweight-persistent-vms-to-isolate-agentic-ai/4079557
56. techzine: Fly.io puts AI agents in VMs, not containers — https://www.techzine.eu/news/devops/137884/fly-io-puts-ai-agents-in-vms-not-containers/
57. fly.io/learn: What is a Firecracker VM — https://fly.io/learn/firecracker-vm/
58. fly.io/learn: Agent sandboxes — https://fly.io/learn/agent-sandbox/
59. hopx.ai — https://hopx.ai/
60. Northflank: HopX.ai alternatives — https://northflank.com/blog/hopx-ai-alternatives
61. `abshkbh/arrakis` (+ docs/detailed-README.md) — https://github.com/abshkbh/arrakis
62. `superradcompany/microsandbox` — https://github.com/superradcompany/microsandbox
63. Bright Coding: microsandbox self-hosted sandboxes that boot in 200ms — https://www.blog.brightcoding.dev/2026/06/30/microsandbox-self-hosted-sandboxes-that-boot-in-200ms
64. `trycua/cua` — https://github.com/trycua
65. `restyler/awesome-sandbox` — https://github.com/restyler/awesome-sandbox
66. Docker blog: Why microVMs — the architecture behind Docker Sandboxes — https://www.docker.com/blog/why-microvms-the-architecture-behind-docker-sandboxes/
67. "Your Container Is Not a Sandbox: The State of MicroVM Isolation in 2026" — https://emirb.github.io/blog/microvm-2026/
68. manveerc: How to sandbox AI agents in 2026 — https://manveerc.substack.com/p/ai-agent-sandboxing-guide
69. USENIX NSDI '20: Firecracker: Lightweight Virtualization for Serverless Applications — https://www.usenix.org/conference/nsdi20/presentation/agache
70. `firecracker-microvm/firecracker` — https://github.com/firecracker-microvm/firecracker
71. gVisor performance guide — https://gvisor.dev/docs/architecture_guide/performance/
72. gVisor blog: Systrap release (2023) — https://gvisor.dev/blog/2023/04/28/systrap-release/
73. Northflank: What is gVisor — https://northflank.com/blog/what-is-gvisor
74. Northflank: Kata Containers vs gVisor — https://northflank.com/blog/kata-containers-vs-gvisor
75. Kata Containers: virtualization design — https://kata-containers.github.io/kata-containers/design/virtualization/
76. systemshardening: gVisor and Kata — the shared-kernel defense — https://www.systemshardening.com/articles/cross-cutting/gvisor-kata-shared-kernel-defense/
77. opencomputer.dev: Firecracker vs Cloud Hypervisor vs Kata — https://opencomputer.dev/guides/firecracker-vs-cloud-hypervisor-vs-kata/
78. Warp blog: Introducing Oz — https://www.warp.dev/blog/oz-orchestration-platform-cloud-agents
79. Warp newsroom: Warp launches Oz (2026-02-10) — https://www.warp.dev/newsroom/2026/2/10/warp-launches-oz-the-orchestration-platform-for-cloud-coding-agents
80. Warp blog: A single pane of glass for managing all your cloud agents — https://www.warp.dev/blog/multi-harness-cloud-agent-orchestration
81. SD Times: Warp updates Oz for any model or harness — https://sdtimes.com/ai/warp-updates-oz-to-help-enterprises-orchestrate-coding-agents-across-any-model-or-harness/
82. Warp: Oz page — https://www.warp.dev/oz
83. Warp: pricing — https://www.warp.dev/pricing
84. agenticwire: E2B pricing and limits — https://www.agenticwire.news/article/e2b-self-hosted-guide

---

## Corroboration report

**Strongly corroborated:**
- **E2B** architecture (Firecracker micro-VM per sandbox), Apache-2.0 licensing of both SDK and infra repos, DIY self-hosting on GCP/AWS-beta, funding ($11.5M seed / $21M Series A), Perplexity + Manus as users, Desktop/Surf offerings. Multiple primary + secondary sources.
- **Modal Sandboxes** API surface, lifecycle limits (5 min default / 24 h max), snapshot mechanics and TTLs (30 d filesystem, 7 d memory), pricing structure (elevated Sandbox rate ~3× base), and "no self-hosting." gVisor isolation is corroborated across Modal's own blog + 3 third parties (though absent from the user-facing Sandbox docs).
- **Vercel Sandbox** — Firecracker isolation, full pricing/quota table, 45-min Hobby / 24-h Pro session limits. All primary, page dated 2026-08-21.
- **Isolation spectrum** — Firecracker NSDI '20 metrics (<125 ms boot, <5 MiB overhead, 150/s), gVisor's own performance statements, Kata's VMM backends. Primary.
- **Coder** and **Northflank** as the two genuine self-serve customer-infra options; **Modal / Vercel / Cloudflare** as hosted-only.

**Weakly corroborated (flagged in text):**
- **Daytona funding** — "$24M Series A, February 2026" is single-source; amount and lead unverified against a primary announcement.
- **Daytona startup benchmark** — the 71/67/59 ms (197 ms total) breakdown is one Medium post.
- **E2B latency split** (80 ms same-region / 150 ms / <200 ms cross-region) — E2B's own numbers but read through secondary pages this pass, not a live primary page.
- **E2B / Modal exact current pricing** — each read once via automated fetch; tier names and headline monthly prices ($150/mo E2B Pro, $250/mo Modal Team) should be re-verified before print.
- **Blaxel** — nearly all specifics (<25 ms resume, "perpetual" zero-cost standby, snapshot-storage rate) come from Blaxel's own marketing; no independent benchmark found.
- **hopx.ai on-premise / BYOC claim** — appears on hopx's site and one Northflank round-up only; not independently verified. This is the one product claiming Firecracker-grade isolation *with* an explicit on-prem story, so it matters — but verify directly.
- **Cloudflare Sandboxes isolation technology** — genuinely unresolved: third parties split between "shared-kernel container" and "micro-VM similar to Firecracker." Cloudflare has not published a definitive statement I could find. **Do not state Cloudflare's isolation tech in the book without a primary source.**
- **Depot sandbox** — could not verify Depot ships an agent sandbox product; likely a conflation with their build/CI isolation. Treat as unconfirmed.
- **Warp Oz pricing-tier change** — the finding that BYO-API-key moved from Build/Max to a new Business tier ($50/user/mo), and that Enterprise carries BYOLLM + self-hosted Oz, is from a single automated read of warp.dev/pricing on 2026-08-30. High-impact correction to the chapter — **re-verify against the live pricing page before editing.**

**Named-entity corrections for the chapter:**
1. **Daytona does NOT use gVisor.** It uses **Docker/OCI containers by default**, with **Kata Containers** as an opt-in stronger-isolation runtime. The chapter's isolation-spectrum bullet "gVisor ... (used by Daytona)" should read "(used by Modal)". Corroborated across ≥4 independent secondary sources plus Daytona's own "OCI/Docker compatibility" docs.
2. **Firecracker line** — keep "(used by E2B)" and add Vercel Sandbox and Fly.io (Machines/Sprites) as further examples; optionally note Cloudflare is *described as* "Firecracker-like" but unconfirmed.
3. **Add a middle rung** to the isolation list: **gVisor via `runsc` + Kubernetes `RuntimeClass`** as the common "stronger than a container, cheaper than a micro-VM" self-hosted option.
4. **Warp Oz tiers** — BYO-provider-key is now on the **Business** tier ($50/user/mo), not Build/Max; Enterprise adds BYOLLM + self-hosted Oz (K8s / Docker / direct execution). Re-verify before applying.
5. **Modal** is a **general serverless platform** (sandboxes are one primitive), not a sandbox-first company — relevant to how subtopic 7 frames it.
