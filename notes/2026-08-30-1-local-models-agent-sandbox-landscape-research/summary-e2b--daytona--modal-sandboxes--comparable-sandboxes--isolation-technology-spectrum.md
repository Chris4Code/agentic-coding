# Summary — Agent sandbox landscape (E2B, Daytona, Modal, comparable, isolation, self-hosting, vs Warp Oz)

**Navigation aid only.** The full record is `raw-e2b--daytona--modal-sandboxes--comparable-sandboxes--isolation-technology-spectrum.md` in this folder. Every exact figure, quote, price, date, and citation link must be pulled from the raw file, not from this summary — the compression here drops nuance on purpose. Extends `notes/2026-08-29-3-local-models-frontends-proxies-terminals-security/` (which established Warp Oz's identity; not re-derived here).

Confidence tags: 🟢 primary / 🟡 corroborated-secondary / 🟠 single-source (treat with caution).

## Per-subtopic

### 1. E2B
- 🟢 Open-source (Apache-2.0) cloud runtime giving agents isolated Linux sandboxes. Company founded 2023, SF. Seed $11.5M (Oct 2024) + Series A $21M (Jul 2025, Insight Partners) ≈ $32M total.
- 🟡 **One Firecracker micro-VM per sandbox**, each booting its own kernel — hardware-virtualization boundary. Orchestration is Nomad + Consul.
- 🟢 Both the SDK repo (`e2b-dev/E2B`) and the infra repo (`e2b-dev/infra`) are Apache-2.0. The infra repo is a real Terraform/Packer/Nomad deployment, not a stub.
- 🟢 **Self-hosting is real but heavy**: GCP fully supported, AWS beta; Azure/bare-metal planned only. Needs Terraform, Packer, Docker, Go, a Postgres metadata DB, and a Cloudflare account for DNS (🟠 the Cloudflare-DNS dependency makes air-gapped awkward). Firecracker needs bare-metal / nested-virt hosts.
- 🟢 Python + JS SDKs, plus Code Interpreter and Desktop SDKs. `e2b-dev/desktop` (Xfce + VNC for computer-use agents) and `e2b-dev/surf` (reference computer-use agent).
- 🟡 Latency: E2B markets ~150 ms start; docs cite 80 ms same-region / <200 ms cross-region (read via secondary this pass).
- 🟠 Pricing (read once 2026-08-30, re-verify): Hobby free ($100 one-time credit, 1 h sessions, 20 concurrent); **Pro $150/mo + usage** (24 h sessions, 100 concurrent); per-second CPU $0.000014–0.000112/s. Ultimate/Enterprise custom.
- 🟢 Users: Perplexity (data analysis), Manus (agent "virtual computers"). 🟠 Manus-self-hosts-E2B claim is single-source.

### 2. Daytona
- 🟢 **Pivoted** from open-source self-hosted dev-environment manager (2023–24) to "secure and elastic infrastructure for running AI-generated code" (agent sandbox runtime). 🟡 pivot dated early 2025.
- 🟡 **NOT gVisor — chapter correction.** Daytona runs **Docker/OCI containers by default**, with **Kata Containers** as opt-in stronger isolation (🟠 Sysbox also mentioned by one source). Corroborated across ≥4 independent sources + Daytona's own "OCI/Docker compatibility" docs. The chapter currently attributes gVisor to Daytona — that's Modal.
- 🟢 Headline claim: sandboxes spin up in **"under 90 ms"** ("fastest in the market"). 🟠 one independent benchmark measured ~197 ms total (71 create + 67 exec + 59 cleanup), calling 90 ms a cached-image best case.
- 🟢 Stateful snapshots + a Declarative Builder for images. Python / TS SDKs (+ Ruby/Go/Java clients).
- 🟢 Repo `daytonaio/daytona` dual-licensed **AGPL-3.0 / Apache-2.0**. 🟢 **As of ~June 2026 the public repo is maintenance-only** — "core development moved to a private codebase." The open-source Daytona is now a frozen artifact.
- 🟢 Self-hosting: "Bring Your Own Compute" is **Enterprise, contact-sales, and undocumented** — no public self-host guide for the agent-runtime (unlike the old dev-env manager).
- 🟢 Pricing (page dated 2026-08-27): $200 signup credit; per-second — vCPU $0.0504/h, mem $0.0162/GiB/h; GPUs H100 $2.27/h etc. Startups up to $50k credit.
- 🟠 Funding: "$24M Series A, Feb 2026" is single-source, unverified against a primary announcement.

### 3. Modal Sandboxes
- 🟢 Modal is a **general serverless compute platform** (Python functions, cron, endpoints, GPU jobs); **Sandboxes are one primitive** — "secure containers for executing untrusted user or agent code," driven via the SDK.
- 🟡 **Isolation is gVisor** (Google's user-space kernel). Stated in Modal's own blog + 3 third parties; *absent* from the user-facing Sandbox docs, which only say "secure containers." So Modal's boundary is a user-space kernel — weaker than Firecracker/Kata, stronger than a plain container.
- 🟢 API: `Sandbox.create()` / `sandbox.exec()` streaming, lifecycle states, readiness probes, tags + `Sandbox.list()`. Default max lifetime **5 min**, configurable to **24 h**.
- 🟢 Takes Modal Images / Volumes / Secrets. Tunnels for inbound; egress filtering.
- 🟢 **Filesystem snapshots** (`snapshot_filesystem()` → Image, stored as diff, 30-day default TTL) + **experimental memory snapshots** (full RAM+FS clone with running processes, 7-day non-extensible TTL).
- 🟢 GPUs available to sandboxes.
- 🟢 Pricing (read 2026-08-30): **Sandboxes & Notebooks CPU is ~3× the base Function rate** ($0.00003942 vs $0.0000131 /core/s); mem similarly ~3×. Billed per-second on max(request, actual). Team plan $250/mo.
- 🟡 **No self-hosting / on-prem at all** — cloud-only multi-tenant serverless (absence-of-feature; consistent across docs + comparisons). Enterprise adds VPC peering / dedicated capacity, still on Modal infra.
- Funding not verified this pass — do not state a number.

### 4. Comparable providers (field map)
- **Vercel Sandbox** 🟢 — "compute primitive to safely run untrusted code," **Firecracker micro-VM** per sandbox (own FS + network; can run Docker/VPN/FUSE). JS+Python SDK. Hosted-only, SDK Apache-2.0. Pricing (page dated 2026-08-21): active-CPU $0.128/vCPU-h, mem $0.0212/GB-h; Hobby 45-min max session, Pro 24-h, 10k concurrent.
- **Cloudflare Sandboxes** 🟢 GA April 2026, SDK over Cloudflare Containers, driven from a Worker/Durable Object; sleeps when idle, wakes on request. 🟠 **Isolation genuinely unresolved** — sources split between shared-kernel container and "micro-VM similar to Firecracker"; no primary statement. June 2026 Cloudflare began moving code-interpreter/terminal/git to optional helpers. Hosted-only.
- **Northflank** 🟡 — general app platform also selling agent sandboxes; **isolation is a per-workload knob: Kata / Firecracker / gVisor**. **Self-serve BYOC** on AWS/GCP/Azure/Oracle/CoreWeave/Civo/**bare-metal/on-prem** (~600 BYOC regions). Strongest BYOC story alongside Coder. Proprietary.
- **Runloop** 🟡 — "Devbox" sandboxes purpose-built for coding agents; Blueprints + snapshots; custom bare-metal hypervisor (VM-level); <1 s start, >20k concurrent. Hosted-only, not OSS. Pro $250/mo.
- **Blaxel** 🟠 — "perpetual sandbox," microVM isolation, zero-cost indefinite standby, <25 ms resume with full FS+memory. Nearly all detail is self-marketing, no independent benchmark. Managed-only.
- **Coder** 🟢 — **fully self-hostable** (AGPL-3.0 core + enterprise), provisions dev environments via Terraform templates on **your** infra (K8s / VMs / cloud / on-prem / air-gapped). **Coder Tasks** runs each AI agent (Claude Code, Aider, Goose, …) in its own governed workspace. April 2026: Agent Firewall, AI Gateway, AI Governance add-on. Coder is control-plane + governance, not an isolation runtime — isolation is whatever the template provisions.
- **Fly.io** 🟡 — Fly Machines are API-driven **Firecracker/KVM VMs** booting any OCI image. **Sprites** (~2026-01-13) are Firecracker VMs purpose-shaped to isolate coding agents: persistent but scale-to-zero, online in 1–12 s. Hosted-only.
- **hopx.ai** 🟠 — managed Firecracker micro-VM sandboxes (by Bunnyshell). **Claims BYOC (AWS/GCP/Azure) + on-premise install** — the one Firecracker-grade product with an explicit on-prem pitch, but claim appears only on its own site + one round-up. Verify directly before relying on it.
- **Arrakis** 🟢 — open-source, self-hosted single-node sandbox; micro-VM via `cloud-hypervisor`; REST + Python SDK + MCP; snapshot/restore ("backtracking") first-class; boots <7 s. Solo-maintainer.
- **microsandbox** 🟡 — open-source (Apache-2.0), local-first micro-VM runtime via **libkrun**; boots ~200 ms; MCP support. "Run it on your own box" is the whole pitch.
- **Also in the field** 🟡 (from `restyler/awesome-sandbox`): Koyeb Sandboxes (bare-metal microVM, hosted), Deno Sandbox (Firecracker, hosted), AWS Bedrock AgentCore (Firecracker, hosted), Docker Sandboxes (local disposable microVMs), Apple Containerization (macOS-only), Cua/`trycua` 🟠 (open-source desktop-VM sandboxes for computer-use agents).
- **Depot** 🟠 — could NOT verify it ships an agent sandbox product; likely a conflation with its build/CI isolation. Treat as unconfirmed.

### 5. Isolation technology spectrum
- **Containers (runc / namespaces + cgroups)** 🟡 — one shared host kernel; near-zero overhead, instant; a single kernel LPE or runtime CVE escapes. Consensus: not sufficient for untrusted / unattended code.
- **gVisor / `runsc`** 🟢 — user-space "application kernel" (the Sentry) reimplements much of the Linux syscall surface; only a small allow-listed set reaches the host kernel. `runsc` **is** gVisor. Default platform is **systrap** (since 2023, replaced the ~350×-slower ptrace). Overhead: **no CPU-op cost** (good for CPU/ML work); structural syscall cost real (~800 ns vs ~70 ns native on KVM, ~10× for tiny syscalls); ~10–30% slower on I/O-heavy work (🟡). No hardware virt required. Trade-off: shrinks host-kernel attack surface but the Sentry itself is a big user-space target. Used by **Modal**, Google Cloud Run / GKE Sandbox.
- **Kata Containers** 🟢 — OCI/CRI-compatible; boots a lightweight VM per pod, own guest kernel, KVM-enforced; VMM backends QEMU / Firecracker / Cloud Hypervisor / Dragonball. 🟡 ~50–100 ms boot, ~100–200 MiB/pod. Used by **Daytona (opt-in)**, available on **Northflank**.
- **Firecracker** 🟢 — AWS Rust KVM VMM (NSDI '20 paper): **<125 ms boot to app code, <5 MiB overhead/microVM, up to 150 microVMs/s/host**; ~5 emulated devices vs QEMU's 40+. Powers Lambda + Fargate. Used by **E2B, Vercel Sandbox, Fly.io (Machines + Sprites), Koyeb, Deno Deploy, AWS Bedrock AgentCore**, hopx.ai (claimed).
- **Cloud Hypervisor** 🟡 — Rust KVM VMM, richer device model than Firecracker (hotplug, live migration); the VMM behind Arrakis. **libkrun** — VMM as an embeddable library; used by microsandbox.
- **Ordering (weakest → strongest):** (1) in-process syscall restriction (seccomp/Landlock/Seatbelt, as in Claude Code) → (2) namespaced container / devcontainer → (3) gVisor → (4) Kata / Firecracker / Cloud Hypervisor micro-VM. For a non-moderated local model driving an unattended agent, the cross-source recommendation is rung 3 or 4, plus egress filtering regardless of rung.

### 6. Self-hosted / BYOC / on-premise
- **Genuine customer-infra options:** **Coder** (full, AGPL-3.0, incl. air-gapped), **Northflank** (self-serve BYOC incl. bare-metal/on-prem), **E2B** (DIY via `e2b-dev/infra`, GCP prod / AWS beta), **Warp Oz** (Enterprise — K8s / Docker / direct execution + BYOLLM), **Arrakis** / **microsandbox** (inherently, single-node/local).
- **Claimed:** **hopx.ai** (BYOC + on-prem, 🟠 unverified).
- **Enterprise-only + undocumented:** **Daytona** (BYOC listed for Enterprise; no guide; OSS frozen).
- **Hosted-only, no self-host:** **Modal, Vercel Sandbox, Cloudflare, Runloop, Blaxel, Fly.io/Sprites, Koyeb, Deno**.
- **Practical team baseline** (chapter's current wording is well corroborated, 🟡): attended/semi-trusted agent → devcontainer or rootless Docker + non-root user + read-only mounts **+ egress allow-list** (the dominant real risk is credential/data exfiltration, not kernel escape, so the egress control matters more than the isolation rung). Unattended agent against a non-moderated local model → **VM boundary per agent** (Firecracker/Kata via `e2b-dev/infra`, Fly Machines, Kata-on-K8s `RuntimeClass`, microsandbox, Arrakis) **or gVisor** as the lighter middle option, same egress list, no ambient cloud credentials in the sandbox.
- Suggested chapter addition: an explicit **middle rung — gVisor via `runsc` + K8s `RuntimeClass`** ("stronger than a container, cheaper than a micro-VM," trivially self-hosted on an existing cluster).

### 7. vs Warp Oz
- **Core distinction: Oz is an orchestration platform; E2B / Daytona / Modal are sandbox primitives.** Oz gives a fleet manager for hundreds of parallel agents, interactive + programmatic + scheduled launches, native **multi-harness** (Claude Code / Codex / Warp Agent) with cross-harness persistent memory, governance / observability / audit, a UI, and (since the 2026-05-19 update) automatic sub-agent orchestration — **you don't build the orchestration**. The primitives give you an SDK + isolated runtime and you build scheduling / fleet view / memory / harness integration / governance yourself.
- **Isolation is inverted from capability:** Oz's per-agent **Docker container is the weakest** boundary in the comparison — weaker than E2B's Firecracker VM or Modal's gVisor. Oz's value is the layer *above* the sandbox. A security-conscious team could run Oz for orchestration on a Kata-backed / self-hosted cluster.
- See the raw file §7 for the full comparison table (category / isolation / who-builds-orchestration / multi-harness / hosted / self-hostable / BYO-model / OSS / snapshots / pricing shape / target user).

## Named-entity corrections for the chapter

1. **Daytona does NOT use gVisor** — it uses Docker/OCI containers by default + Kata opt-in. The chapter's "gVisor … (used by Daytona)" bullet should read **"(used by Modal)"**. High confidence.
2. **Firecracker bullet** — keep "(used by E2B)"; add **Vercel Sandbox** and **Fly.io (Machines/Sprites)**. Optionally note Cloudflare is *described as* "Firecracker-like" but unconfirmed.
3. **Add a middle rung** — gVisor via `runsc` + K8s `RuntimeClass`.
4. **Warp Oz tiers** — 🟠 a single 2026-08-30 read of warp.dev/pricing suggests BYO-provider-key moved from Build/Max to a **new Business tier ($50/user/mo)**, with Enterprise carrying BYOLLM + self-hosted Oz (K8s / Docker / direct execution). High-impact; **re-verify against the live pricing page before editing the chapter.**
5. **Modal** is a general serverless platform (sandboxes are one primitive), not a sandbox-first company.

## What this means for the book (suggestion — user to confirm)

Rework the `## On Premise Agent Sandboxes` section so the E2B / Daytona / Modal sentence becomes a real subsection rather than a one-line aside:

- Keep `### Warp and Oz` mostly as-is; apply correction #4 (pricing tiers) after re-verifying.
- Add `### Sandbox primitives: E2B, Daytona, Modal` — one short paragraph each: what it is, isolation tech (Firecracker / containers+Kata / gVisor), open-source + self-hosting status, one price anchor. Lead with the E2B-vs-Oz framing: **primitive vs orchestration**.
- Add a compact comparison table (Oz | E2B | Daytona | Modal) on: category, per-agent isolation, who builds the orchestration, self-hostable, bring-your-own-model, open source.
- Optionally a `### The wider field` sentence naming Vercel Sandbox, Cloudflare Sandboxes, Northflank (BYOC), Coder (self-hosted, governance), Fly.io Sprites, and the open-source self-host options (microsandbox, Arrakis) — with Northflank + Coder called out as the genuine customer-infra choices.
- Fix `### Agent sandboxing`: corrections #1–#3 (Daytona→containers+Kata, Modal→gVisor, add the gVisor/`RuntimeClass` middle rung, expand the Firecracker examples). Refine the closing "practical baseline" paragraph per subtopic 6.
- Glossary: add **E2B**, **Daytona**, **Modal Sandboxes**, **Firecracker**, **gVisor**, **Kata Containers**, **micro-VM** if not already present, each linking to this section.

Research Note candidates (per CLAUDE.md evidence convention): flag as not-well-corroborated → Daytona's sub-90 ms claim vs the ~197 ms independent benchmark; Cloudflare Sandboxes' isolation technology (unresolved in public sources); hopx.ai's on-premise claim; the Warp Oz pricing-tier change (single read).
