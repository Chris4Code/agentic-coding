# Deep research — Security chapter (`src/security.md`)

Research pass: 2026-09-03, run 1. Covers 11 subtopics for the Security chapter. Extends the prior-art
notes `notes/initial-notes/security - prompt injection.md`, `notes/initial-notes/identity.md`, and the
sandbox-landscape / proxy notes from 2026-08-29 and 2026-08-30. This file is the unabridged raw note;
a distilled summary will be written separately.

Conventions: each `##` section opens with a **Sourcing:** line. Inline links point to the specific
source for each claim. A single deduplicated numbered `## Sources` list closes the file.

---

## 1. Workspace Containers

**Sourcing: primary-sourced** for the coding-agent harnesses (Anthropic, OpenAI, GitHub own docs and
engineering posts; Simon Willison's hands-on Codex investigation). **corroborated-secondary** for Devin
and Jules internals (vendor statements + third-party write-ups, no first-party security spec).
**weak / single-source** for the specific "egress-is-the-exfil-path" bypass write-up.

### Threat model

A workspace container for a coding agent is not primarily about kernel-escape. The prior-art note
(2026-08-30 sandbox landscape) already establishes the isolation spectrum — in-process syscall filter
(seccomp/Landlock) → namespaced container → gVisor → Kata/Firecracker micro-VM — and concludes that for
a *coding* agent the dominant real risk is **credential and data exfiltration**, so an egress allow-list
matters more than the hypervisor boundary. The security-specific threats a workspace sandbox must
address:

- **Data / credential exfiltration.** A prompt-injected or confused agent reads source, secrets, SSH
  keys, `~/.aws`, `.env`, tokens, then sends them out — via `curl`, a git push to an attacker remote, a
  package it publishes, a crafted URL, or even DNS lookups. Anthropic's own engineering post states the
  design rule plainly: "effective sandboxing requires *both* filesystem and network isolation. Without
  network isolation, a compromised agent could exfiltrate sensitive files like SSH keys; without
  filesystem isolation, a compromised agent could easily escape the sandbox" ([Anthropic — Claude Code
  sandboxing](https://anthropic.com/engineering/claude-code-sandboxing)).
- **Destructive / unintended filesystem writes** outside the repo (`rm -rf`, overwriting dotfiles,
  touching other repos).
- **Unwanted outward actions**: `git push`, opening PRs, publishing to npm/PyPI, calling internal APIs,
  spending money on cloud resources.
- **Supply-chain execution**: `npm install` / `pip install` run arbitrary post-install scripts *inside*
  the workspace, with whatever the sandbox grants.

### What a coding-agent sandbox must restrict

Filesystem **write** scope (ideally repo working directory only; read scope is usually wider); network
**egress** (default-deny with a small allow-list for package registries and the model API); **secrets in
the environment** (do not mount `~/.aws`, `~/.ssh`, cloud metadata endpoints, `.env` unless needed);
**git remote push / PR creation**; **package-registry publish**.

### How current harnesses sandbox by default

- **Claude Code.** Permission model with allow / ask / deny rules per tool and command
  ([Claude Code security — DataCamp write-up](https://www.datacamp.com/tutorial/claude-code-security)).
  The sandboxed Bash tool has two independent layers: **filesystem isolation** (writes scoped to the
  current working directory and subdirectories, enforced on subprocesses too) and **network isolation**
  (sandboxed commands reach the network only through a Unix domain socket connected to a proxy running
  *outside* the sandbox, which enforces an allowed-domain list) ([Claude Code docs —
  sandboxing](https://code.claude.com/docs/en/sandboxing);
  [Anthropic engineering](https://anthropic.com/engineering/claude-code-sandboxing)). OS primitives:
  **Linux bubblewrap**, **macOS Seatbelt** ([Anthropic
  engineering](https://anthropic.com/engineering/claude-code-sandboxing)). Anthropic reports internal
  testing where sandboxing "safely reduces permission prompts by 84%", explicitly framed as an
  antidote to approval fatigue. `--dangerously-skip-permissions` (aka "YOLO mode") disables all
  permission prompts and is recommended only inside a container without credentials or network
  ([DataCamp](https://www.datacamp.com/tutorial/claude-code-security)).
  - **Reference devcontainer.** `anthropics/claude-code/.devcontainer/init-firewall.sh` sets up a
    **default-deny egress** firewall with `iptables` + `ipset`, building a `hash:net` allow-list from
    GitHub's published ranges (`api.github.com/meta`) plus resolved IPs for `registry.npmjs.org`,
    `api.anthropic.com`, `sentry.io`, `statsig.com` and the VS Code marketplace endpoints
    ([init-firewall.sh](https://github.com/anthropics/claude-code/blob/main/.devcontainer/init-firewall.sh);
    [Claude Code devcontainer docs](https://code.claude.com/docs/en/devcontainer)).
- **OpenAI Codex CLI.** Sandboxed **by default** — per Simon Willison's investigation, "the only major
  agent with sandboxing enabled by default" ([Simon Willison — Codex sandbox
  investigation](https://simonwillison.net/2025/Nov/9/codex-sandbox-investigation/)). On Linux it
  combines **Landlock** (filesystem access control) + **seccomp** (blocking network syscalls) with
  **bubblewrap** for filesystem-namespace isolation; on macOS it uses **Apple Seatbelt** with dynamic
  policies ([Codex sandboxing — DeepWiki](https://deepwiki.com/openai/codex/5.6-sandboxing-implementation)).
  Modes: read-only, workspace-write (write to the working dir, no network), and danger-full-access. On
  Windows there is no Landlock/seccomp equivalent, so Codex uses an AppContainer with a restricted
  token and synthetic SIDs ([OpenAI — building the Codex Windows
  sandbox](https://openai.com/index/building-codex-windows-sandbox/)).
- **GitHub Copilot coding agent.** Runs in an ephemeral GitHub Actions VM. Ships a built-in **agent
  firewall**, default-on, "to control Copilot's internet access and help protect against prompt
  injection and data exfiltration" ([GitHub Docs — customize the agent
  firewall](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/customize-the-agent-firewall)).
  A **recommended allow-list** covers OS package repos (Debian, Ubuntu, Red Hat) and common container
  registries (Docker Hub, ACR, ECR); admins can add custom hosts or opt out of the recommended list for
  a locked-down config ([GitHub Changelog — configure internet
  access](https://github.blog/changelog/2025-07-15-configure-internet-access-for-copilot-coding-agent/);
  [Copilot allowlist reference](https://docs.github.com/en/copilot/reference/copilot-allowlist-reference)).
  **Important limitation:** "the firewall only applies to processes started by the agent via its Bash
  tool and does not apply to Model Context Protocol (MCP) servers or processes started in configured
  Copilot setup steps" ([GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/customize-the-agent-firewall)).
- **Devin (Cognition).** Full sandboxed cloud VM (typically Ubuntu) with its own IDE, browser and
  terminal; inside the VM the agent has full filesystem, package-manager and compiler access — the VM
  is the blast-radius boundary, not the process ([Fastio write-up on Devin
  architecture](https://fast.io/resources/devin-software-engineer/); [Modal — sandboxes for
  Devin](https://modal.com/resources/best-sandboxes-devin)). Vendor-level detail; no first-party
  security spec found.
- **Google Jules.** Runs in a Google Cloud VM ("Cloud Execution Environment"); notably keeps network
  access so it can install dependencies and run builds — i.e. a *weaker* egress posture than Codex or
  the Claude Code devcontainer ([Morphllm — Jules
  overview](https://www.morphllm.com/comparisons/jules-google-coding-agent)). Secondary source.
- **Cursor / other IDE agents.** Cursor's background/agent modes run in cloud VMs; local agent mode
  executes on the developer machine subject to Cursor's own allow/deny command list. (Could not locate
  a first-party Cursor sandbox architecture doc at research time — treat as weak.)
- **Docker.** Docker has been shipping "agent sandbox" tooling (containerised dev environments +
  MCP gateway) aimed at exactly this use case; general-purpose containerisation (devcontainers, rootless
  Docker) plus an egress proxy is the common self-host pattern
  ([mfyz — sandboxing AI coding agents](https://mfyz.com/ai-coding-agent-sandbox-container/)).

### In-process sandboxing vs full container/VM

Landlock + seccomp + bubblewrap (Codex, Claude Code Bash tool) restrict a *process tree* on the host
without a separate kernel or image — cheap, fast, no VM boot, but the blast radius is still the host
user account and any credentials it can see. A full container adds namespace + cgroup isolation and a
clean filesystem; a micro-VM (Firecracker/Kata, used by E2B/Fly/Vercel per the 2026-08-30 note) adds a
separate kernel. For a coding agent the incremental security value of moving up this ladder is smaller
than the value of a strict **egress allow-list** at every level.

### Where sandboxing breaks

- **The agent needs real credentials to do its job.** To push a branch, open a PR, deploy, or call an
  internal API the agent must hold a working token — a prompt-injected agent then holds it too. Scoping
  (fine-grained, short-lived, repo-limited) reduces but does not remove this.
- **Supply-chain code runs inside the sandbox.** `npm`/`pip`/`cargo` install scripts execute with the
  agent's privileges and the agent's allowed egress. An allow-list that permits `registry.npmjs.org`
  still lets a malicious package phone home through the registry or exfiltrate via package names / cache
  requests.
- **Egress allow-lists are themselves channels.** A write-up demonstrates using Claude Code's permitted
  outbound paths (package registries, telemetry endpoints, git remotes) as the exfiltration route once
  the agent is subverted — "when agent egress becomes the exfil path" ([Penligent — Claude Code sandbox
  bypass](https://www.penligent.ai/hackinglabs/claude-code-sandbox-bypass/)). Single source; directional,
  not a rigorous CVE.
- **MCP servers and setup steps often run outside the sandbox** (explicit for GitHub Copilot; commonly
  true elsewhere), reintroducing unrestricted network and filesystem.
- **The lethal trifecta persists.** Sandboxing constrains *how much damage* a subverted agent can do; it
  does not stop the agent from being subverted. If the sandboxed agent still has private data + untrusted
  input + any outbound path, it is still exploitable (see §5).
- **Approval fatigue.** The 84 % prompt reduction is a security win only if the remaining 16 % of prompts
  get real scrutiny.

---

## 2. Identity

**Sourcing: primary-sourced** for Microsoft Entra Agent ID, Okta Cross-App Access, SPIFFE/SPIRE (vendor
and project docs / spec drafts). **corroborated-secondary** for the "non-human identity outnumbers human"
ratios (multiple vendor research reports, figures vary widely). **weak / single-source** for some
small-company guidance (synthesised from general practice).

### Why an agent needs its own identity

Reusing a human's credentials, a shared service account, or a static API key fails on attribution
(you cannot tell which agent — or which human-behind-the-agent — did what), least privilege (shared
accounts accrete permissions), revocation (you cannot kill one agent without breaking others), and
lifecycle (no automatic deprovisioning). The prior-art `identity.md` note already frames the shift from
"informal automation with hardcoded keys" to **managed non-human identities (NHIs)** with automated
provisioning, instant central revocation, "mover"-style permission updates, and audit trails.

### NHI as a category and its scale problem

Non-human identities (service accounts, workload identities, bots, and now agents) already vastly
outnumber human identities. The reported ratios are all from security-vendor research and disagree by a
lot — cite them as *directional*, not precise:

- Rubrik Zero Labs / Cloud Security Alliance: median **~45:1** NHI-to-human, up from ~17:1 in 2023
  ([Rubrik Zero Labs](https://zerolabs.rubrik.com/blog/identity-is-a-major-risk-and-its-going-to-get-worse-if-we-dont-do-anything-about-it);
  [Security Boulevard summary](https://securityboulevard.com/2026/07/the-agent-identity-problem-non-human-identities-outnumber-humans-45-to-1-and-ai-agents-are-making-it-worse/)).
- CyberArk: machine identities outnumber humans **by more than 80:1**
  ([CyberArk press release](https://www.cyberark.com/press/machine-identities-outnumber-humans-by-more-than-80-to-1-new-report-exposes-the-exponential-threats-of-fragmented-identity-security/)).
- Entro Labs: **144:1** in cloud/DevOps-heavy environments (secondary).
- Non-Human Identity Management Group 2025 report (cited secondhand): ~73 % of NHI-held secrets carry
  excessive permissions; >5.5 % of AWS machine identities have full admin; 53 % of CISOs cannot
  enumerate half of their machine identities with confidence
  ([Security Boulevard](https://securityboulevard.com/2026/07/the-agent-identity-problem-non-human-identities-outnumber-humans-45-to-1-and-ai-agents-are-making-it-worse/)).

**Research Note:** the specific NHI-ratio numbers above are vendor-published and inconsistent across
sources; treat the *direction* (NHIs greatly outnumber humans and are growing fast with agents) as
well-supported and any single figure as weak.

### On-behalf-of / delegated authority

The agent principal and the human who triggered it are different subjects and both belong in the token
and the audit record. Enterprise designs converge on: the agent has a stable identity of its own, and a
request also carries a delegation / actor claim naming the initiating user, so authorization can be the
*intersection* of what the agent may do and what that user may do (prevents the agent becoming a
privilege-escalation path). This is the model behind Entra Agent ID's "agent identity blueprint" and
Okta's ID-JAG token (below).

### Plugging agent identity into existing IAM

**Enterprise:**

- **Microsoft Entra Agent ID.** Announced at Build, **May 2025**, now GA. Agent identities are
  first-class accounts in Entra ID with a directory object ID; "agent identities don't have credentials
  of their own and rely on the agent identity blueprint to acquire tokens on their behalf"
  ([Microsoft Learn — what are agent identities](https://learn.microsoft.com/en-us/entra/agent-id/what-are-agent-identities);
  [Microsoft — announcing Entra Agent ID](https://techcommunity.microsoft.com/blog/microsoft-entra-blog/announcing-microsoft-entra-agent-id-secure-and-manage-your-ai-agents/3827392)).
  Works with agents built on non-Microsoft platforms (AWS Bedrock, n8n) via the Entra ID Auth SDK or
  **workload identity federation** ([Microsoft Learn — what is Entra Agent
  ID](https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id)).
- **Okta.** "Cross-App Access" (XAA) and "Agent SSO" position agents as first-class identities governed
  by the IdP (below). Okta, Microsoft, Ping and Google are all shipping agent-identity features in the
  2025–2026 window; Okta's and Microsoft's are the ones with public specs/docs.

**Small company:** usually no formal NHI governance. The practical substrate is the tooling already in
use — **GitHub organisation** (GitHub Apps, fine-grained PATs scoped per-repo with expiry, Actions OIDC
for keyless cloud auth), **Google Workspace** service accounts (domain-wide delegation exists but is
broad and risky), and a handful of SaaS with per-integration API keys. Guidance: give each agent its own
GitHub App installation or fine-grained token, scoped to the minimum repos and permissions, with a short
expiry, rather than a shared org-wide PAT.

### Standards and mechanisms

- **OAuth 2.x for agents / Cross-App Access.** Okta's Cross-App Access, formally the **"Identity
  Assertion Authorization Grant"**, is an OAuth extension announced **June 23, 2025**
  ([Okta newsroom](https://www.okta.com/newsroom/press-releases/okta-introduces-cross-app-access-to-help-secure-ai-agents-in-the/);
  [oauth.net — Cross-App Access](https://oauth.net/cross-app-access/)). Flow: the client exchanges a
  user-identity assertion at the IdP authorization server for an **ID-JAG** (Identity Assertion JWT
  Authorization Grant) token; the resource server validates the ID-JAG and issues a short-lived, scoped
  access token — giving the IdP central visibility, policy and audit over agent→app and app→app calls
  ([Okta Developer — enterprise AI](https://developer.okta.com/blog/2025/06/23/enterprise-ai);
  [Okta Developer — XAA with OIDC](https://developer.okta.com/blog/2025/09/03/cross-app-access)). Built
  on the in-progress IETF drafts "Identity and Authorization Chaining Across Domains" and "Identity
  Assertion Authorization Grant".
- **Workload identity federation** — exchange a platform-native token (GitHub Actions OIDC, Kubernetes
  service-account token, cloud instance identity) for a cloud credential with no stored secret. Standard
  practice for CI; directly applicable to agents.
- **SPIFFE / SPIRE** (CNCF graduated projects). Each workload gets a **SPIFFE ID** delivered as an
  **SVID** (X.509 cert or JWT). SPIRE performs **node attestation** and **workload attestation**
  (inspecting Kubernetes namespace / service account / container image) before issuing a **short-lived**
  SVID via a local Workload API socket — no pre-shared secret, enabling zero-trust mTLS between
  components ([SPIFFE docs — SPIRE concepts](https://spiffe.io/docs/latest/spire-about/spire-concepts/);
  [Red Hat — SPIFFE and SPIRE](https://www.redhat.com/en/topics/security/spiffe-and-spire)). HashiCorp
  argues SPIFFE is "the right foundation for AI-agent identity" because agents are NHIs that call other
  agents (A2A), tools (MCP servers) and model providers, binding identity to *what the workload is and
  where it runs* rather than to a static key
  ([HashiCorp blog](https://www.hashicorp.com/en/blog/spiffe-securing-the-identity-of-agentic-ai-and-non-human-actors)).
  Stacklok and others describe combining SPIFFE identity with relationship-based authorization for
  agents ([Stacklok](https://stacklok.com/blog/agentic-identity-explained-how-to-apply-spiffe-and-relationship-based-authorization-to-ai-agents-in-2026/)).
- **Short-lived vs long-lived.** Uniform vendor and standards direction: attested, scoped,
  short-lived tokens over static long-lived API keys.

---

## 3. Agent IDs

**Sourcing: primary-sourced** for SCIM (RFC 7643/7644) and the IETF draft itself (datatracker + the
author's own repo). **corroborated-secondary** for who-is-implementing and the draft-consolidation
status. **weak / single-source / speculative** for the DLT / DID-for-agents material — it is active
research and early standards positioning, not production adoption.

### (a) SCIM

**SCIM 2.0** = **RFC 7643** (Core Schema — the `User` and `Group` resource models) + **RFC 7644**
(Protocol — a REST API for CRUD, PATCH, filtering, bulk), published 2015. An identity provider (Okta,
Entra ID, …) uses SCIM to **provision** and **deprovision** accounts in downstream SaaS automatically as
people join, move and leave. The prior-art `identity.md` note already covers how this extends to NHIs:
automated agent lifecycle, instant central revocation, "mover" permission updates, delegated authority,
audit trails.

**The IETF draft extending SCIM to agents:**

- Name: **"SCIM Agents and Agentic Applications Extension"**, `draft-abbey-scim-agent-extension`
  ([IETF datatracker](https://datatracker.ietf.org/doc/draft-abbey-scim-agent-extension/);
  [`-00` full text](https://www.ietf.org/archive/id/draft-abbey-scim-agent-extension-00.html)).
- Author: **Macy Abbey**. The `-00` was published **October 2025**. It is an individual Internet-Draft:
  "not endorsed by the IETF and has no formal standing in the IETF standards process" (standard I-D
  boilerplate — quote from the draft).
- What it adds: extensions to the core `User` and `Group` objects, plus **new resource types / schemas**
  for agentic constructs — an **`Agent`** resource (the non-human workload: identifier, AI capabilities,
  operational boundaries) and an **`AgenticApplication`** resource (the platform that hosts / orchestrates
  / deploys agents) ([WorkOS analysis](https://workos.com/blog/scim-agents-agentic-applications)). The
  draft's stated goal: "greater interoperability between Identity providers, agentic applications, agents
  and their clients while reducing the responsibilities assumed by the ever growing list of new protocols
  for agents."
- Status: at **IETF 124** (Montreal) two competing drafts were proposed to represent agents as a SCIM
  resource type; the **IETF 125** (March 2026) SCIM WG session has a slide deck titled "SCIM Agentic
  Schema Draft — Consolidation Progress", i.e. the working group is merging the proposals
  ([IETF 125 materials](https://datatracker.ietf.org/meeting/125/materials/slides-125-scim-scim-agentic-draft-progress-00)).
  Source repo: [`macyabbey/draft-abbey-scim-agent-extension`](https://github.com/macyabbey/draft-abbey-scim-agent-extension).
- Who is engaging: **WorkOS** ([blog](https://workos.com/blog/scim-agents-agentic-applications)),
  **Microsoft Entra** (blog "Beyond OAuth: why SCIM must evolve for the AI agent revolution"
  [link](https://techcommunity.microsoft.com/blog/microsoft-entra-blog/beyond-oauth-why-scim-must-evolve-for-the-ai-agent-revolution/4433036)),
  SSOJet, and the Non-Human Identity Management Group
  ([NHIMG](https://nhimg.org/community/agentic-ai-and-nhis/scim-for-ai-and-agent-identities-what-changes-for-iam-teams/)).
  These are engagement / commentary, not shipped conformant implementations at research time.

**Research Note:** the earlier `identity.md` note calls this "the new IETF SCIM standard". That
overstates it — it is a single-author individual Internet-Draft under active consolidation in the SCIM
working group, not an adopted WG document and not a standard. The existence, author, schema shape and WG
consolidation are all corroborated; "standard" is not.

### (b) Public DLTs / decentralized identifiers

There is a real research and early-standards strand proposing **W3C Decentralized Identifiers (DIDs)**
and **Verifiable Credentials (VCs)** as an agent-identity substrate — mostly for **agent-to-agent**
trust across organisational boundaries, where a central IdP does not span both parties.

- **"AI Agents with Decentralized Identifiers and Verifiable Credentials"**, arXiv **2511.02841**
  (Nov 2025), also in SCITEPRESS. A conceptual framework plus prototype multi-agent system: each agent
  has a ledger-anchored W3C DID it controls, plus third-party-issued VCs that "travel with the agent"
  and can be presented at the start of a dialogue to establish cross-domain trust
  ([arXiv abstract](https://arxiv.org/abs/2511.02841)).
- Survey / gap analysis: "AI Identity: Standards, Gaps, and Research Directions for AI Agents"
  (arXiv 2604.23280) and NeuralTrust's write-up on W3C identifiers for agents
  ([NeuralTrust](https://neuraltrust.ai/blog/w3c-identifier-agent)).
- **TRAIL** ("Trust Registry for AI Identity Layer") — a draft `did:trail` DID method specifically for
  AI agents, defining identifier types for organisations, agents, and self-signed identities; a W3C DID
  registry submission is described as *pending*. **Single secondary source; could not confirm against a
  primary spec repo.**
- **MCP-I** (an identity extension for MCP) reportedly donated to the **Decentralized Identity
  Foundation (DIF)** in March 2026. **Single secondary source; not confirmed against DIF's own records.**
- Named blockchain-identity networks (KILT, cheqd) and "agent passport" schemes: **could not corroborate**
  any of these as having a concrete, adopted agent-identity product. Treat as not established.

**Honest assessment:** DID/VC-for-agents is genuine, active work (papers, draft methods, standards-body
positioning) but **not production adoption**. "Public DLT / blockchain" specifically is the weakest
framing — the serious proposals use DIDs, which do **not** require a blockchain (`did:web`, `did:key`
are ledgerless). For an enterprise book, the honest statement is: SCIM + OAuth + workload identity is
where real deployments are; DIDs/VCs are a plausible future for cross-org agent-to-agent trust and
should be flagged as emerging, not recommended practice.

---

## 4. Role management and RBAC

**Sourcing: primary-sourced** for the policy engines (OpenFGA, Cedar, OPA) and for GitHub's repo
permission primitives. **corroborated-secondary** for how these are being applied to agents specifically
(vendor blogs + one arXiv framework paper).

### Access-control models applied to agents

- **RBAC** — the agent is a principal that holds roles. Simple, coarse; fine for "this agent = CI role".
- **ABAC / PBAC** (policy-as-code) — decisions from attributes + rules. **AWS Cedar** and **OPA/Rego**
  are the common engines; good when rules depend on data classification, environment, time
  ([Auth0 — ReBAC/ABAC with OpenFGA and Cedar](https://auth0.com/blog/rebac-abac-openfga-cedar/)).
- **ReBAC** (Zanzibar-style) — decisions from a graph of relationships (user→agent, agent→repo,
  agent→tool). **OpenFGA** / **Auth0 FGA** implement this and combine it with ABAC conditions
  ([OpenFGA — authorization concepts](https://openfga.dev/docs/authorization-concepts)). Auth0 markets
  FGA explicitly for agents: "enforcing least-privilege access at the resource level, ensuring an AI
  agent can access only specific documents or tools authorized for that session, mitigating risks like
  prompt injection and unauthorized data leakage in RAG pipelines"
  ([Auth0 — Fine-Grained Authorization](https://auth0.com/fine-grained-authorization)).

### Expressing "agent may do X on repo Y, read Z only"

The pattern is a **Policy Decision Point / Policy Enforcement Point** split: the runtime (PEP) intercepts
every tool call and asks the PDP (OpenFGA / Cedar / OPA), which evaluates `Agent→Tool`, `Agent→Repo`,
`Agent→Agent` and `User→Agent` relationships plus conditions (data classification, risk tier,
environment). An arXiv framework paper, "Overlaying Governance: A Compositional Authorization Framework
for Delegation and Scope in Agentic AI" (arXiv 2606.03518), formalises delegation + scope composition
for exactly this. A core rule: an agent's effective permissions should be the **intersection** of its
own grants and the delegating user's grants — never a superset (no confused-deputy escalation).

### Project-level vs company-wide scoping

Prefer **project / repo-scoped** roles. Company-wide roles for an agent are the anti-pattern (a
prompt-injected agent then reaches everything). Least privilege + short TTL + per-task scoping.

### Integrating with existing RBAC

- **Enterprise:** Entra roles / Entra Agent ID; **AWS IAM roles** (`AssumeRole` with session policies
  and permission boundaries to hard-cap what an agent session can ever do); **Kubernetes RBAC** bound to
  a SPIFFE identity; policy engines (OPA, Cedar, OpenFGA) as the PDP.
- **Small company — GitHub is the RBAC layer.** Repo/team permission levels (read / triage / write /
  maintain / admin), **branch protection** (block direct pushes to `main`, require PR), **CODEOWNERS**
  (force review by the right people), **environment protection rules** (required reviewers + wait timer
  before a deploy job runs), and **fine-grained PAT / GitHub App permissions** scoped per repo. An agent
  restricted to "write, but every change goes through a protected-branch PR reviewed by a human" is a
  practical, no-new-infrastructure least-privilege setup.

### Least privilege, JIT elevation, and the "software factory" problem

- **Just-in-time elevation:** the agent runs with a minimal baseline and requests a scoped, time-boxed
  grant when a task genuinely needs more — approved by a human or a policy. Complements static RBAC.
- **Software factory:** many agents running in parallel have a large *aggregate* footprint. Mitigations:
  a distinct identity per agent (not a shared factory account), ephemeral per-run credentials, per-task
  scoping, and **human-in-the-loop approval gates** on irreversible / outward-facing actions (merge,
  deploy, publish, spend). OWASP's cheat sheet lists the same: least privilege, the LLM getting its own
  scoped API tokens, and "have the application require the user approve the action first" for privileged
  operations ([OWASP — LLM Prompt Injection Prevention Cheat
  Sheet](https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html)).

---

## 5. How to handle Prompt Injections

**Sourcing: primary-sourced** for the definitions and the key papers (Willison's own posts; arXiv
papers; OWASP). **corroborated-secondary** for aggregated benchmark numbers (multiple papers report
consistent ranges).

### Definition

**Prompt injection** = untrusted input causing an LLM to follow instructions it was not supposed to
follow, because instructions and data share one token stream. Willison coined the term (after SQL
injection) for "mixing together trusted and untrusted content in the same context" and explicitly
distinguishes it from **jailbreaking** (getting a model to violate its own safety training)
([Simon Willison — lethal trifecta](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/)).

- **Direct** — the attacker is the user, typing the injection.
- **Indirect** — the injection arrives via content the agent ingests: a tool result, a retrieved
  document, a web page, a file, a repo.

**For coding agents specifically**, the indirect channels are: a dependency's README / package
description, a GitHub issue or PR comment, a code comment or docstring, CI / build logs the agent reads,
a web page the agent browses, and **MCP tool descriptions** (tool poisoning), plus agent-config files
(`AGENTS.md`, `.cursorrules`, skill / rule files). A systematic study, "Prompt Injection Attacks on
Agentic Coding Assistants" (arXiv **2601.17548**), analyses vulnerabilities across skills, tools and
protocol ecosystems for coding assistants.

### Why it is not easily preventable

The architecture argument is in the prior-art note: one self-attention pass over one token sequence, no
separate control channel, embeddings encode meaning not provenance, the KV cache is an optimisation not
a boundary, attention is bidirectional so untrusted tokens still pull on generation. RLHF / instruction
tuning makes naive delimiter overrides *less likely* but not impossible.

Willison's **lethal trifecta**: an agent is exploitable for data theft when it has **(1) access to
private data**, **(2) exposure to untrusted content**, and **(3) the ability to communicate externally**
(exfiltration vector). "The only way to stay safe is to avoid that lethal trifecta combination
entirely" — remove one leg
([Simon Willison](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/)). Coding agents routinely
have all three (source code + browsing/deps + git push / network).

The 2025 consensus position (Willison; the Design Patterns paper): general-purpose agents cannot
currently give reliable safety guarantees against prompt injection; the productive question is which
*constrained* agent designs give useful work while resisting it — "once an LLM agent has ingested
untrusted input, it must be constrained so that it is *impossible* for that input to trigger any
consequential actions"
([Simon Willison — Design Patterns](https://simonwillison.net/2025/Jun/13/prompt-injection-design-patterns/)).

### Training-time / model-level mitigations (partial)

- **Instruction hierarchy** (OpenAI, Wallace et al., 2024, arXiv 2404.13208): train the model to rank
  `system > user > tool/data`; when instructions conflict the higher priority wins. Reduces attack
  success, does not eliminate it.
- **StruQ** (Chen et al.): base model + reserved delimiter tokens + adversarial instruction tuning to
  ignore instructions in the data segment; **<2 % attack success** against optimization-free attacks
  (per SecAlign's comparison).
- **SecAlign** (Chen et al., ACM CCS 2025; [`facebookresearch/SecAlign`](https://github.com/facebookresearch/SecAlign);
  arXiv 2410.05451): preference optimisation (DPO-style) on (injected input, secure output, insecure
  output) triples; reduces success rates of various prompt injections to **<10 %**, "even against attacks
  more sophisticated than ones seen during training". **Meta SecAlign** (arXiv 2507.02735) is an open
  foundation model with this built in.
- **Caveat:** fine-tuning-based defences can be broken. "May I have your Attention? Breaking Fine-Tuning
  based Prompt Injection Defenses using Architecture-Aware Attacks" (arXiv 2507.07417) and
  backdoor-powered attacks (arXiv 2510.03705) show these are not settled.

### Design-level mitigations

CaMeL and the six Design Patterns — see §6 and §8.

### Benchmark reality

- **AgentDojo** (Debenedetti et al., NeurIPS 2024 Datasets & Benchmarks; arXiv **2406.13352**): "97
  realistic tasks … 629 security test cases"; an *extensible* environment, not a static suite. Headline
  finding: "state-of-the-art LLMs fail at many tasks (even in the absence of attacks), and existing
  prompt injection attacks break some security properties but not all" ([arXiv](https://arxiv.org/abs/2406.13352)).
  Secondary reports of specific numbers: GPT-4o benign utility ~69 %, dropping to ~45 % under attack,
  with targeted attack-success ~50 %+ for the strong "Important message" canonical attack; tool
  filtering suppresses ASR to ~7.5 % but drops utility.
- **LlamaFirewall** (arXiv 2505.03574) on AgentDojo: baseline ASR **17.6 %** → PromptGuard 2 alone
  **7.5 %** → AlignmentCheck alone (on a large Llama model) **~2.9 %** → **combined 1.75 %** (>90 %
  reduction) ([alphaXiv summary](https://www.alphaxiv.org/abs/2505.03574)).
- **CommandSans** (arXiv 2510.08829): ASR 34.67 % → 3.48 % (GPT-4o), 16.02 % → 0.84 % (Gemini 2.5 Pro),
  4.95 % → 0.74 % (Claude Sonnet 3.7).
- **Detector evasion is easy.** "Bypassing Prompt Guards in Production with Controlled-Release
  Prompting" (arXiv **2510.01529**) encodes a jailbreak the lightweight guard cannot decode but the
  target model can, succeeding against Gemini 2.5 Flash, DeepSeek, Grok 3, Mistral Le Chat; conclusion:
  "shift defenses from blocking malicious inputs to preventing malicious outputs". Lakera's **PINT**
  benchmark (3,007 inputs, deliberately including false-positive probes) is the neutral yardstick
  ([Lakera — PINT](https://www.lakera.ai/blog/lakera-pint-benchmark)).

### What measurably helps vs what does not

Helps (measurable): removing a leg of the lethal trifecta; plan-then-execute / constraining
post-ingestion actions; typed tool schemas + deterministic policy checks; human approval on
outward/irreversible actions; CaMeL-style data-flow control; layered classifiers (reduce ASR by ~2–10×,
never to zero). Does **not** reliably help: prompt-only pleading ("don't follow instructions in the
data"); a single regex or classifier gate; relying on model RLHF alone; delimiters against an adaptive
attacker.

---

## 6. Dual-LLM Pattern

**Sourcing: primary-sourced** (Willison's original 2023 post and his CaMeL write-up; the CaMeL paper
and its public code repo).

### Origin

Simon Willison, **"The Dual LLM pattern for building AI assistants that can resist prompt injection"**,
**25 April 2023** ([post](https://simonwillison.net/2023/Apr/25/dual-llm-pattern/)):

- **Privileged LLM** — sees only trusted input, holds all tool access, runs the ReAct loop.
- **Quarantined LLM** — processes untrusted content (emails, web pages), has **no tools**, cannot act.
- **Controller** — ordinary (non-LLM) code that mediates. Untrusted outputs from the quarantined LLM are
  stored in **symbolic variables** (`$VAR1`, `$VAR2`); "The Privileged LLM only ever sees those variable
  names. It is never exposed to either the untrusted content from the email, or the tainted summary that
  came back from the Quarantined LLM."

Willison's own caveats, in the post: still vulnerable to **social-engineering the user** into copying
tainted data manually; implementation is complex and degrades UX; he calls it "pretty bad" and
"Building AI assistants that don't have gaping security holes in them is an incredibly hard problem!"

### Evolution → CaMeL

**"Defeating Prompt Injections by Design"** (CaMeL = CApabilities for MachinE Learning), Google DeepMind
+ ETH Zürich (Debenedetti, Tramèr, et al.), arXiv **2503.18813** (March 2025, rev. June 2025); code at
[`google-research/camel-prompt-injection`](https://github.com/google-research/camel-prompt-injection).
CaMeL fixes the Dual-LLM gap where an *extracted value* from untrusted data still flows into a sensitive
call:

- The **privileged LLM** converts the trusted user request into code in a **custom restricted Python
  interpreter** (recursively evaluates an AST, enforces rules).
- The **quarantined LLM** only parses untrusted data into typed values.
- Every value carries **capabilities** — provenance / trust metadata.
- A **policy engine** checks data flows before any side-effecting tool call — e.g. `send_email()` is
  allowed only if the recipient address derives from a trusted source
  ([Simon Willison — CaMeL](https://simonwillison.net/2025/Apr/11/camel/)).

Result claimed in the paper: CaMeL "effectively solves the AgentDojo benchmark while providing strong
guarantees against unintended actions and data exfiltration" — note: *guarantees*, not a probabilistic
score.

### Costs and limitations

- No free-form LLM reasoning over untrusted text in the privileged flow.
- Security **policies must be written and maintained** by developers; over-broad policies trigger
  constant approval prompts → **approval fatigue** (the authors flag this).
- The restricted interpreter limits expressiveness.
- Garbage-in: the quarantined LLM's extraction can still be wrong.
- The authors state directly: "prompt injection attacks are not fully solved."

### Where this sits among patterns

The Design Patterns paper (arXiv 2506.08837) generalises this into six patterns
([Willison's summary](https://simonwillison.net/2025/Jun/13/prompt-injection-design-patterns/)):
**Action-Selector** (agent triggers tools, can't read their responses), **Plan-Then-Execute** (tool
plan fixed before untrusted content is seen), **LLM Map-Reduce** (isolated sub-agents over untrusted
chunks, aggregated safely), **Dual LLM**, **Code-Then-Execute** (privileged LLM emits code in a
sandboxed DSL enabling taint tracking — this is CaMeL), **Context-Minimization** (strip content,
including the user prompt, once a structured query is derived).

### Real implementations

CaMeL's reference implementation is research code. Willison notes the pattern is rarely deployed in
production because of the UX cost. Production adoption of full Dual-LLM / CaMeL is thin; the *ideas*
(plan-then-execute, context minimisation, typed tools) show up piecemeal in real agent frameworks.

---

## 7. LLM Firewalls

**Sourcing: primary-sourced** for the model/product mechanisms (Meta's LlamaFirewall paper + Prompt
Guard 2 model card; NVIDIA / Protect AI / Guardrails AI repos; Cloudflare, AWS, Azure, LiteLLM docs;
OWASP cheat sheet). **corroborated-secondary / weak** for cross-tool efficacy comparisons — the
independent numbers come from a small number of evaluations and vary a lot.

### Concept

An "AI gateway" / "semantic firewall" sits inline (synchronous, blocking) or alongside (asynchronous,
monitoring) the model call and inspects **inputs** and **outputs**.

### Products and mechanisms

- **NVIDIA NeMo Guardrails** (Apache-2.0, [repo](https://github.com/NVIDIA/NeMo-Guardrails)): a
  programmable layer using the **Colang** DSL; five rail types — input, dialog, retrieval, execution,
  output. Maps user intent onto allowed state-machine trajectories; can wrap Llama Guard. Mechanism =
  intent modelling + programmable flows + optional classifiers.
- **Protect AI LLM Guard** (MIT, [repo](https://github.com/protectai/llm-guard)): a stack of "scanners"
  — regex / heuristic signatures, Base64 and obfuscation detection, and a fine-tuned ONNX classifier for
  the `PromptInjection` scanner — plus `Anonymize` (Presidio-backed PII redaction), toxicity, ban-topics,
  and output scanners.
- **Guardrails AI** (Apache-2.0, [repo](https://github.com/guardrails-ai/guardrails)): schema/type
  validation with a **validate-and-reask** loop; the Guardrails Hub hosts individual validators.
- **Meta LlamaFirewall** (arXiv **2505.03574**; open source, license capped at 700 M MAU;
  [Meta publication page](https://ai.meta.com/research/publications/llamafirewall-an-open-source-guardrail-system-for-building-secure-ai-agents/)).
  Targets three attack lines: jailbreaking, goal hijacking, insecure generated code. Components:
  - **Prompt Guard 2** — a BERT-style classifier, **86M** (trained on English + non-English attacks)
    and **22M** (English-only, lower prevention rate, for resource-constrained / latency-sensitive use)
    ([Llama Prompt Guard 2 model card](https://www.llama.com/docs/model-cards-and-prompt-formats/prompt-guard/)).
    Meta's card reports the 86M model at ~**97.5 % recall of jailbreak prompts at a 3.9 % false-positive
    rate** at the chosen threshold.
  - **AlignmentCheck** — an **experimental** few-shot chain-of-thought auditor that inspects the agent's
    *reasoning trace* in real time for goal hijacking / injection-induced misalignment; runs on a large
    Llama model (Llama 4 Maverick in the paper's eval). "the first open source guardrail … to audit an
    LLM chain-of-thought in real time" for injection defence.
  - **CodeShield** — online static analysis of LLM-generated code, supporting **Semgrep and regex**
    rules across multiple languages.
  - AgentDojo results: PromptGuard 2 alone 17.6 %→7.5 % ASR; AlignmentCheck alone →~2.9 %; combined
    **1.75 %**.
- **Lakera Guard** (commercial; authors of the PINT benchmark). **Prompt Security**, **Robust
  Intelligence** (acquired by Cisco, 2024) — commercial AI firewalls; mechanisms not fully public.
- **Cloudflare Firewall for AI** / "AI Security for Apps": runs at the WAF edge in front of any LLM
  endpoint. Prompt-injection detection is **score-based**, an "LLM Injection score" from **1 (very
  likely injection) to 99 (very likely safe)**, combinable with bot/attack scores; also PII detection,
  unsafe-topic detection, and **outbound** scanning of model responses for secrets / financial data
  ([Cloudflare blog](https://blog.cloudflare.com/block-unsafe-llm-prompts-with-firewall-for-ai/);
  [Cloudflare docs — prompt injection detection](https://developers.cloudflare.com/waf/detections/ai-security-for-apps/prompt-injection/)).
- **AWS Bedrock Guardrails**: content filters, denied topics, word filters, contextual-grounding checks,
  PII, a prompt-attack filter, and **Automated Reasoning checks** (formal verification of an output
  against a policy model; GA August 2025; AWS claims "up to 99 % accuracy at detecting correct
  responses") ([AWS — Automated Reasoning checks GA](https://aws.amazon.com/about-aws/whats-new/2025/08/automated-reasoning-checks-amazon-bedrock-guardrails);
  [Bedrock Guardrails](https://aws.amazon.com/bedrock/guardrails/)).
- **Azure AI Content Safety / Prompt Shields**: detects direct and indirect prompt injection / jailbreak
  in both user input and grounding documents; uses **Spotlighting** (§9) in production; part of Azure AI
  Foundry.
- **LiteLLM guardrails hooks**: middleware in the proxy request lifecycle — `pre_call`, `during_call`
  (streaming), `post_call` — with built-in Presidio PII masking and pluggable third-party guardrails
  (Lakera, Aporia, etc.) ([LiteLLM — guardrails quick
  start](https://docs.litellm.ai/docs/proxy/guardrails/quick_start)).

### Regex/deterministic vs classifier-model detection

- **Deterministic (regex / signatures / decoders):** sub-millisecond, no false negatives on *exact*
  known strings, catches trivial obfuscation (Base64). Evaded by paraphrase, translation, typos,
  novel phrasings, multi-turn build-up. Prone to **false positives** on legitimate text that quotes an
  attack string ("our docs warn against 'ignore previous instructions'…").
- **Classifier models (BERT/DeBERTa-scale, e.g. Prompt Guard, LLM Guard's ONNX model):** catch novel
  phrasings via learned features; latency in the millisecond-to-tens-of-milliseconds range; but a
  measurable FPR (Prompt Guard ~3.9 %), degraded on low-resource languages and distribution shift, and
  **out-computable** — a guard much smaller than the target model can be defeated by an encoded payload
  the big model still decodes (Controlled-Release Prompting, arXiv 2510.01529).
- **Independent efficacy data is thin and inconsistent.** One comparison (secondary, single source):
  NeMo reaches 0 % bypass at a **16.2 % FPR**, while Prompt Guard shows **38.5 % bypass at 3.6 % FPR**.
  Another report: Prompt Guard flags a very large fraction (cited as ~96 %) of *benign agentic* content
  as harmful. **Research Note:** these cross-tool numbers each come from a single evaluation with its own
  dataset and threshold choices; do not treat them as settled. Lakera's PINT benchmark exists precisely
  because tools over-fit public datasets.

### OWASP guidance

The **OWASP LLM Prompt Injection Prevention Cheat Sheet** and **LLM01: Prompt Injection** (OWASP GenAI /
LLM Top 10 2025) recommend: least privilege, the LLM getting its **own scoped API tokens** with
function-level permissions, structured prompts with clear instruction/data separation, instruction
hierarchy, **human-in-the-loop approval for privileged operations**, output DLP/sanitisation, and
periodic manual monitoring — and are explicit that guardrails are **defense-in-depth, not a solution**
([OWASP cheat sheet](https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html);
[OWASP LLM01](https://genai.owasp.org/llmrisk2023-24/llm01-24-prompt-injection/)).

---

## 8. Zero-Trust for AI Agents

**Sourcing: primary-sourced** for the MCP spec / MCP security best-practices page and RFC 8707;
**corroborated-secondary** for the CISA/NIST agentic-AI guidance (government publications summarised by
CSA); **weak / very new** for the "Agentic Zero Trust" framework naming.

### Principles applied to agents

Never trust / always verify; least privilege; assume breach; per-request authorization;
microsegmentation — enforced **per agent** and **per tool call**, not per session.

### "The agent proposes, the runtime disposes"

The prior-art note already states the core: the LLM only *proposes* a tool call; deterministic runtime
code validates it against a **strictly typed JSON schema** (no free-form bash / SQL), runs a **policy
check** (PDP, §4) on every call, **mints a per-call scoped short-lived credential**, enforces the
**egress allow-list** (§1), and caps blast radius. Irreversible or outward-facing actions (merge,
deploy, publish, send, pay) go through a **human approval gate**.

### Guidance documents (2025–2026)

- **CISA + Five Eyes agentic-AI guidance**, released **1 May 2026**: five risk categories for agentic
  deployments — privilege escalation, design/configuration flaws, behavioral misalignment, structural
  cascading failures, accountability opacity
  ([CSA Labs summary](https://labs.cloudsecurityalliance.org/research/csa-research-note-cisa-agentic-ai-guide-enterprise-implement/)).
- **NIST** Center for AI Standards and Innovation launched an **AI Agent Standards Initiative** on
  **17 February 2026** with three pillars: security, interoperability, identity
  ([CSA Labs summary](https://labs.cloudsecurityalliance.org/research/csa-research-note-nist-ai-agent-standards-federal-framework/)).
  **Research Note:** at research time this is an initiative announcement plus supplementary notes, not a
  finished framework — do not cite it as a normative standard.
- **OWASP Top 10 for Agentic Applications (2026)** enumerates application-layer agentic risks.
- "Agentic Zero Trust" mapping the five ZT pillars (Identity, Device, Network, Application/Workload,
  Data) onto agents is a **vendor research paper** (Cequence, May 2026) — useful framing, not a standard.

### MCP-specific concerns

- **Tool poisoning** — a malicious or mutated tool *description* carries attacker instructions to the
  model. A November 2025 incident involved a malicious MCP server whose poisoned tool descriptions
  redirected data to attacker infrastructure
  ([SOC Prime](https://socprime.com/blog/mcp-security-risks-and-mitigations/)).
- **Confused deputy** — MCP proxy servers with static client IDs + dynamic client registration can be
  abused to obtain authorization codes without proper user consent
  ([Red Hat — MCP security](https://www.redhat.com/en/blog/model-context-protocol-mcp-understanding-security-risks-and-controls)).
- **Token passthrough** — passing a client's token straight through to an upstream API is explicitly
  forbidden by the MCP spec as an anti-pattern.
- **Rug-pull** — a tool's definition changes after the user approved it.
- **Hidden-text / Unicode concealment** in tool metadata that the approval UI does not render.
- **MCP authorization spec (2025 revisions):** the MCP server is an **OAuth 2.1 Resource Server**;
  **PKCE** is required; **Resource Indicators (RFC 8707)** bind tokens to a specific audience so a token
  minted for one server cannot be replayed at another
  ([MCP — Security Best Practices](https://modelcontextprotocol.io/docs/tutorials/security/security_best_practices);
  [RFC 8707](https://www.rfc-editor.org/rfc/rfc8707)). NSA/CISA published an "MCP Security" CSI in June
  2026 ([PDF](https://media.defense.gov/2026/Jun/02/2003943289/-1/-1/0/CSI_MCP_SECURITY.PDF)). The
  community "Vulnerable MCP Project" tracks 50+ disclosed MCP issues.

### Human approval for irreversible / outward-facing actions

Zero-trust for agents ends at a human gate for anything the agent cannot undo or that leaves the
perimeter. This is where §4 (RBAC + JIT) and §8 meet.

---

## 9. Heuristic Content Segregation

**Sourcing: primary-sourced** (Microsoft's Spotlighting paper and MSRC blog; the numbers below are the
paper's own, on 2023-era models). **corroborated-secondary** for the "speed bump, not a boundary"
consensus.

### Spotlighting

Microsoft, **"Defending Against Indirect Prompt Injection Attacks With Spotlighting"** (Hines et al.,
arXiv **2403.14720**, March 2024). Three instantiations:

- **Delimiting** — wrap untrusted text in a randomised marker (`<< {{text}} >>`) and instruct the model
  to treat everything inside as data only.
- **Datamarking** — interleave a special token (e.g. `ˆ`) between every word of the untrusted text, so
  the model has a continuous signal of "this is data".
- **Encoding** — transform the untrusted text with an algorithm (Base64, ROT13) the model can decode but
  that visually breaks any embedded instruction.

### Reported effectiveness (paper's own evaluation)

- Datamarking: ASR ~**50 % → <3 %** on GPT-3.5-Turbo; ~**40 % → 0 %** on `text-davinci-003`.
- Encoding: brings ASR to **~0 %** across summarisation and Q&A, outperforming datamarking.
- "negligible detrimental impacts on task performance" for datamarking and encoding.
- Deployed in production as part of **Azure AI Foundry Prompt Shields**
  ([MSRC blog](https://www.microsoft.com/en-us/msrc/blog/2025/07/how-microsoft-defends-against-indirect-prompt-injection-attacks)).

### Honest assessment

- Those numbers are on **2023-era models** and the paper's own attack set. **Encoding** only works if
  the model is strong enough to operate on Base64 — weaker models lose utility — and a model strong
  enough to decode is also strong enough to be induced to follow instructions hidden in the decoded
  blob. **Delimiting** is the weakest form: adaptive attackers defeat it with delimiter injection
  (closing the tag early), context-switching, multi-turn setup, or translation.
- The broad 2025 consensus (Willison; Design Patterns paper; OWASP cheat sheet): **prompt-level
  segregation is a speed bump, not a security boundary** — "once untrusted input is in context, you
  cannot reliably constrain it by asking the model nicely". Frontier models are *more* robust to naive
  overrides (RLHF, instruction hierarchy) but not robust.
- **Where it still has value:** near-zero cost; stacks cleanly with other layers; raises attacker effort
  and stops low-effort/opportunistic injections; and it makes the untrusted span explicit in logs,
  improving attribution and post-incident analysis. Use it as defense-in-depth, never as the control you
  rely on.

---

## 10. Audit Logs

**Sourcing: primary-sourced** for the EU AI Act text (Articles 12 and 19), OpenTelemetry GenAI
conventions, and the tooling docs. **corroborated-secondary** for tamper-evidence patterns (multiple
consistent engineering write-ups) and for ISO 42001 / SOC 2 applicability.

### What to log for an agent

- The **full prompt**: system + developer + user messages **and every injected tool / RAG / web
  output** that entered context.
- **Every tool call**: name, arguments, result, and whether it was allowed / denied / approved.
- **Model + parameters + version**; each **plan / decision step** and reasoning trace where available.
- **Token counts and cost**.
- **Identity**: the agent principal *and* the on-behalf-of human, plus the credential / scope used.
- **Policy decisions and human approvals**: who approved, when, what.
- Correlating **session / trace / span IDs**.

### Why

- **Forensics** after a prompt-injection incident: reconstruct exactly what untrusted content entered
  context and what the agent then did.
- **Compliance.** **EU AI Act Article 12** (Record-keeping): "high-risk AI systems shall technically
  allow for the automatic recording of events (logs) over the lifetime of the system", covering events
  relevant to risk identification, post-market monitoring, and operation monitoring
  ([EU AI Act Art. 12](https://artificialintelligenceact.eu/article/12/)). **Article 19** requires
  providers to keep those automatically generated logs to the extent they are under their control
  ([EU AI Act Art. 19](https://artificialintelligenceact.eu/article/19/)). Commentary reads the
  requirement as: every input that influenced a decision, the reasoning process, every active policy,
  and human-oversight events — and *automatic* means the system generates them itself, manual
  documentation does not satisfy it
  ([Help Net Security](https://www.helpnetsecurity.com/2026/04/16/eu-ai-act-logging-requirements/)).
  Also: **SOC 2** (audit trail / monitoring criteria) and **ISO/IEC 42001** (AI management system).
- **Reproducibility and debugging / evaluation.**

### Tamper-evidence

- **Append-only + WORM storage** (Write-Once-Read-Many) raises the bar for an attacker.
- **Hash-chaining**: each entry stores a monotonic sequence number, the SHA-256 of the previous entry,
  and its own hash over a canonical encoding of its fields — any later modification breaks the chain and
  is detectable (Merkle hash-chain audit trail, e.g. the "OpenFang" agent OS)
  ([C# Corner — tamper-evident audit logs for AI agent actions](https://www.c-sharpcorner.com/article/building-tamper-evident-audit-logs-for-ai-agent-actions/);
  [Praesidia — cryptographic proofs](https://praesidia.ai/blog/tamper-evident-audit-logs-cryptographic-proofs)).
  Append-only storage and cryptographic chaining are **complementary**: the first stops casual tampering,
  the second detects a privileged insider who bypasses it.
- **Ship logs off-host** to a separate trust domain so a compromised agent cannot rewrite its own trail.

### Tooling

- **Observability / tracing:** Langfuse (MIT; enterprise tier adds project RBAC, data masking, audit
  log, SCIM), LangSmith, Arize Phoenix (OSS), Helicone, Datadog LLM Observability, Braintrust.
- **Standard:** **OpenTelemetry GenAI semantic conventions** — typed spans (agent span, LLM
  generation, tool/function, guardrail, handoff) parented under a workflow trace; **content capture is a
  separate, opt-in mechanism** emitted as structured **log events** correlated to the span by
  `trace_id` / `span_id`, so prompt/response content can be filtered or dropped at the Collector
  without touching application code
  ([OpenTelemetry — GenAI observability](https://opentelemetry.io/blog/2026/genai-observability/);
  [semconv registry](https://opentelemetry.io/docs/specs/semconv/registry/attributes/gen-ai/)). The SIG
  scope expanded from LLM-call tracing (April 2024) to agent orchestration + MCP tool calls + content
  capture + quality evaluation.
- **Cloud-native action audit:** because well-designed agents act through scoped IAM roles / short-lived
  tokens, their API calls already land in **CloudTrail**-style cloud audit logs; Entra and Okta emit
  agent sign-in and cross-app-access request logs.

### Observability vs security audit log — not the same thing

Observability data is typically **sampled, mutable, performance-oriented, short-retention**, and content
is often truncated. A **security audit log** must be **complete, immutable, tamper-evident,
access-controlled, longer-retention**, and must cover identity, every authorization decision, and every
human approval. You need both; do not let a tracing dashboard stand in for the audit log.

### PII in logs

An agent audit log now contains everything the agent saw — secrets, source code, customer PII. Controls:
redact / tokenize at ingestion (Presidio, LLM Guard — §11), field-level encryption, strict access
control **and its own audit** on the log store, retention limits balanced against GDPR data-minimisation,
and legal-hold carve-outs. This is the direct tie to §11.

### Retention

EU AI Act: keep logs "under your control" over the system lifetime; sector rules impose minimums
(finance often ≥ 6 months, frequently longer). Balance against data-protection minimisation.

---

## 11. Privacy Gateways

**Sourcing: primary-sourced** for the tools (Presidio repo + Microsoft's PII-Shield sample; LiteLLM
docs; Skyflow's own docs; Anthropic's ZDR page). **corroborated-secondary** for the OpenAI/Anthropic
ZDR contrast (news reporting) and for the general trade-off analysis.

### Concept

A proxy between the developer / agent and a cloud LLM that **detects and strips or masks sensitive data
before it leaves the perimeter**, and optionally **re-hydrates** the response on the way back.

### Local-model / NER-based sanitising

Run a small local model or NER/classifier (spaCy, Stanza, a DeBERTa classifier, an ONNX model, or a
small local LLM) to find secrets / PII / source identifiers; replace them with placeholders; send the
redacted prompt to the frontier model; map placeholders back to real values in the returned text.

### Tools

- **Microsoft Presidio** (MIT, [repo](https://github.com/microsoft/presidio)): an **analyzer**
  (recognizers = regex + NLP + context) plus an **anonymizer** (operators: replace / redact / mask /
  hash / encrypt / custom). Reversible when you keep the entity→placeholder mapping. Pluggable NLP
  backend (spaCy / Stanza / HuggingFace / ONNX). Used as a **guardrail in LiteLLM** in `pre_call` mode
  with configurable entity types (CREDIT_CARD, EMAIL_ADDRESS, PHONE_NUMBER, PERSON, US_SSN…) set to
  MASK or BLOCK ([LiteLLM — Presidio PII masking](https://docs.litellm.ai/docs/proxy/guardrails/pii_masking_v2)).
  Microsoft also published a **"PII Shield"** privacy-proxy sample: `/anonymize_unique` returns a
  session ID, `/deanonymize` restores using it; per-entity strategies replace / hash (SHA-256) /
  encrypt / fake
  ([Microsoft — PII Shield](https://techcommunity.microsoft.com/blog/azuredevcommunityblog/introducing-pii-shield-a-privacy-proxy-for-every-llm-call/4514726)).
- **LLM Guard `Anonymize` / `Deanonymize` scanners** (Presidio-backed): store real values in a
  session-keyed vault, rehydrate on output.
- **Skyflow LLM Privacy Vault**: **deterministic tokenization** — sensitive values are replaced with
  tokens that "have no mathematical connection with the original data, so it can't be reverse
  engineered"; plaintext stays in the vault; detokenization on the response path is gated by the vault's
  fine-grained access control; Skyflow claims negligible impact on output quality because "the patterns
  and relationships remain the same"
  ([Skyflow — GenAI data privacy](https://www.skyflow.com/post/generative-ai-data-privacy-skyflow-llm-privacy-vault)).
- **Commercial:** Private AI, Nightfall AI, Protecto, **Cloudflare AI Gateway / Firewall for AI** (PII
  detection on input, secret / financial-data scanning on output), Portkey and Kong AI gateways,
  Prompt Security.
- **Secret scanning at the gateway:** gitleaks / trufflehog-style regex + entropy checks for API keys,
  tokens, and private keys, applied to the outbound prompt — block or redact before egress. (Standard
  practice; the gateway is a natural enforcement point.)

### Trade-offs

- **Reversible tokenization vs irreversible masking.** Reversible preserves utility and lets you
  re-hydrate answers, but the mapping / vault becomes a high-value target and a new piece of
  infrastructure to secure and audit. Irreversible masking is safer but breaks any task that needs the
  real value and makes response re-hydration impossible.
- **Broken context.** Redacting names, hostnames, or code identifiers degrades model reasoning
  (coreference resolution, code that references the redacted symbol). Over-redaction kills utility;
  under-redaction leaks.
- **Latency.** An extra NER / model pass on every request, plus a second pass on the output.
- **The sanitiser itself is imperfect.** NER recall is < 100 % — it misses novel PII formats, obfuscated
  secrets, and domain-specific identifiers; a local LLM sanitiser can itself be prompt-injected or
  hallucinate. For **code**, "source identifiers" (internal hostnames, proprietary package or algorithm
  names) are not standard PII entities and need custom recognizers.
- **Homomorphic / confidential-computing** approaches (compute on encrypted prompts, TEE-hosted
  inference) exist but are not mainstream for frontier-model access at research time.

### Enterprise reality — Zero Data Retention as the complementary control

The contractual control that pairs with a technical gateway:

- **OpenAI ZDR** — for eligible API customers on a negotiated enterprise agreement; prompts and
  responses are not stored after the request is processed, and data is not used for training unless the
  customer opts in ([reported by Axios](https://www.axios.com/2026/08/19/openai-previews-zero-retention-safety-system-as-anthropic-requires-data-logs)).
- **Anthropic ZDR** — available under enterprise / Claude Code Enterprise agreements; inputs and outputs
  are not retained beyond the API-call lifecycle and are not used to train models, though Anthropic
  still retains **user-safety classifier results** to enforce its usage policy
  ([Anthropic Privacy Center — ZDR](https://privacy.claude.com/en/articles/8956058-i-have-a-zero-data-retention-agreement-with-anthropic-what-products-does-it-apply-to)).
- In both cases ZDR requires a negotiated enterprise contract; it is **not** available on standard
  pay-as-you-go API plans.

**Research Note:** the Axios framing that "OpenAI previews zero-retention … as Anthropic requires data
logs" is news reporting from August 2026 and concerns a specific safety-logging context; do not
generalise it to "Anthropic has no ZDR" — Anthropic's own ZDR page contradicts that. Treat the
comparison as reported-secondary.

### Connection to Audit Logs (§10)

A privacy gateway is the natural place to also emit the **redacted** audit record, and its
de-tokenization map is itself sensitive: it must live in the same tamper-evident, access-controlled,
retention-limited store as the audit log, with its own access audit.

---

## Sources

[1] Claude Code sandboxing — Engineering at Anthropic — https://anthropic.com/engineering/claude-code-sandboxing
[2] Configure the sandboxed Bash tool — Claude Code Docs — https://code.claude.com/docs/en/sandboxing
[3] Development containers — Claude Code Docs — https://code.claude.com/docs/en/devcontainer
[4] anthropics/claude-code — .devcontainer/init-firewall.sh — https://github.com/anthropics/claude-code/blob/main/.devcontainer/init-firewall.sh
[5] Claude Code Security Guide (permissions, MCP, sandboxing) — DataCamp — https://www.datacamp.com/tutorial/claude-code-security
[6] Research: OpenAI Codex CLI Sandbox Implementation Analysis — Simon Willison — https://simonwillison.net/2025/Nov/9/codex-sandbox-investigation/
[7] Building a safe, effective sandbox to enable Codex on Windows — OpenAI — https://openai.com/index/building-codex-windows-sandbox/
[8] Sandboxing Implementation — openai/codex — DeepWiki — https://deepwiki.com/openai/codex/5.6-sandboxing-implementation
[9] Customizing or disabling the firewall for GitHub Copilot cloud agent — GitHub Docs — https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/customize-the-agent-firewall
[10] Configure internet access for Copilot coding agent — GitHub Changelog — https://github.blog/changelog/2025-07-15-configure-internet-access-for-copilot-coding-agent/
[11] Copilot allowlist reference — GitHub Docs — https://docs.github.com/en/copilot/reference/copilot-allowlist-reference
[12] Claude Code Sandbox Bypass, When Agent Egress Becomes the Exfil Path — Penligent — https://www.penligent.ai/hackinglabs/claude-code-sandbox-bypass/
[13] Devin AI Software Engineer Architecture, Sandboxes & CLI — Fastio — https://fast.io/resources/devin-software-engineer/
[14] Best Code Execution Sandboxes for Devin — Modal — https://modal.com/resources/best-sandboxes-devin
[15] Jules: Google's Coding Agent Explained — Morphllm — https://www.morphllm.com/comparisons/jules-google-coding-agent
[16] Sandboxing AI Coding Agents: Network Firewall + Restricted Shell — mfyz — https://mfyz.com/ai-coding-agent-sandbox-container/
[17] Identity Is a Major Risk (45:1 NHI:human) — Rubrik Zero Labs — https://zerolabs.rubrik.com/blog/identity-is-a-major-risk-and-its-going-to-get-worse-if-we-dont-do-anything-about-it
[18] Machine Identities Outnumber Humans by More Than 80 to 1 — CyberArk — https://www.cyberark.com/press/machine-identities-outnumber-humans-by-more-than-80-to-1-new-report-exposes-the-exponential-threats-of-fragmented-identity-security/
[19] The Agent Identity Problem: NHIs Outnumber Humans 45 to 1 — Security Boulevard — https://securityboulevard.com/2026/07/the-agent-identity-problem-non-human-identities-outnumber-humans-45-to-1-and-ai-agents-are-making-it-worse/
[20] Announcing Microsoft Entra Agent ID — Microsoft Community Hub — https://techcommunity.microsoft.com/blog/microsoft-entra-blog/announcing-microsoft-entra-agent-id-secure-and-manage-your-ai-agents/3827392
[21] What is Microsoft Entra Agent ID? — Microsoft Learn — https://learn.microsoft.com/en-us/entra/agent-id/what-is-microsoft-entra-agent-id
[22] What are agent identities? — Microsoft Learn — https://learn.microsoft.com/en-us/entra/agent-id/what-are-agent-identities
[23] Integrate Your Enterprise AI Tools with Cross-App Access — Okta Developer — https://developer.okta.com/blog/2025/06/23/enterprise-ai
[24] Okta introduces Cross App Access to help secure AI agents — Okta Newsroom — https://www.okta.com/newsroom/press-releases/okta-introduces-cross-app-access-to-help-secure-ai-agents-in-the/
[25] Cross-App Access — OAuth 2.0 — https://oauth.net/cross-app-access/
[26] Build Secure Agent-to-App Connections with Cross App Access Using OIDC — Okta Developer — https://developer.okta.com/blog/2025/09/03/cross-app-access
[27] SPIFFE: Securing the identity of agentic AI and non-human actors — HashiCorp — https://www.hashicorp.com/en/blog/spiffe-securing-the-identity-of-agentic-ai-and-non-human-actors
[28] What are SPIFFE and SPIRE? — Red Hat — https://www.redhat.com/en/topics/security/spiffe-and-spire
[29] SPIRE Concepts — SPIFFE — https://spiffe.io/docs/latest/spire-about/spire-concepts/
[30] Agentic Identity Explained: SPIFFE and Relationship-Based Authorization — Stacklok — https://stacklok.com/blog/agentic-identity-explained-how-to-apply-spiffe-and-relationship-based-authorization-to-ai-agents-in-2026/
[31] draft-abbey-scim-agent-extension — IETF Datatracker — https://datatracker.ietf.org/doc/draft-abbey-scim-agent-extension/
[32] SCIM Agents and Agentic Applications Extension (draft-abbey-scim-agent-extension-00) — IETF — https://www.ietf.org/archive/id/draft-abbey-scim-agent-extension-00.html
[33] macyabbey/draft-abbey-scim-agent-extension — GitHub — https://github.com/macyabbey/draft-abbey-scim-agent-extension
[34] SCIM Agentic Schema Draft Consolidation Progress, IETF 125 — IETF Datatracker — https://datatracker.ietf.org/meeting/125/materials/slides-125-scim-scim-agentic-draft-progress-00
[35] SCIM for AI: Inside the new IETF draft — WorkOS — https://workos.com/blog/scim-agents-agentic-applications
[36] Beyond OAuth: Why SCIM Must Evolve for the AI Agent Revolution — Microsoft Entra Blog — https://techcommunity.microsoft.com/blog/microsoft-entra-blog/beyond-oauth-why-scim-must-evolve-for-the-ai-agent-revolution/4433036
[37] SCIM for AI and Agent Identities — Non-Human Identity Management Group — https://nhimg.org/community/agentic-ai-and-nhis/scim-for-ai-and-agent-identities-what-changes-for-iam-teams/
[38] AI Agents with Decentralized Identifiers and Verifiable Credentials — arXiv 2511.02841 — https://arxiv.org/abs/2511.02841
[39] Why Two AI Agents Need Cryptographic Identity Before They Say Hello — NeuralTrust — https://neuraltrust.ai/blog/w3c-identifier-agent
[40] Understanding ReBAC and ABAC Through OpenFGA and Cedar — Auth0 — https://auth0.com/blog/rebac-abac-openfga-cedar/
[41] Fine-Grained Authorization, ReBAC, ABAC & Zanzibar Explained — OpenFGA — https://openfga.dev/docs/authorization-concepts
[42] Fine-Grained Authorization (FGA) for AI Agents — Auth0 — https://auth0.com/fine-grained-authorization
[43] Overlaying Governance: A Compositional Authorization Framework for Delegation and Scope in Agentic AI — arXiv 2606.03518 — https://arxiv.org/pdf/2606.03518
[44] The lethal trifecta for AI agents — Simon Willison — https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/
[45] CaMeL offers a promising new direction for mitigating prompt injection attacks — Simon Willison — https://simonwillison.net/2025/Apr/11/camel/
[46] Defeating Prompt Injections by Design (CaMeL) — arXiv 2503.18813 — https://arxiv.org/pdf/2503.18813
[47] google-research/camel-prompt-injection — GitHub — https://github.com/google-research/camel-prompt-injection
[48] Design Patterns for Securing LLM Agents against Prompt Injections — Simon Willison — https://simonwillison.net/2025/Jun/13/prompt-injection-design-patterns/
[49] Design Patterns for Securing LLM Agents against Prompt Injections — arXiv 2506.08837 — https://arxiv.org/abs/2506.08837
[50] The Dual LLM pattern for building AI assistants that can resist prompt injection — Simon Willison — https://simonwillison.net/2023/Apr/25/dual-llm-pattern/
[51] AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents — arXiv 2406.13352 — https://arxiv.org/abs/2406.13352
[52] LlamaFirewall: An open source guardrail system for building secure AI agents — arXiv 2505.03574 — https://arxiv.org/pdf/2505.03574
[53] LlamaFirewall (publication page) — Meta AI — https://ai.meta.com/research/publications/llamafirewall-an-open-source-guardrail-system-for-building-secure-ai-agents/
[54] Llama Prompt Guard 2 — Model Cards and Prompt formats — Meta — https://www.llama.com/docs/model-cards-and-prompt-formats/prompt-guard/
[55] Bypassing Prompt Guards in Production with Controlled-Release Prompting — arXiv 2510.01529 — https://arxiv.org/abs/2510.01529
[56] Lakera's Prompt Injection Test (PINT) Benchmark — Lakera — https://www.lakera.ai/blog/lakera-pint-benchmark
[57] lakeraai/pint-benchmark — GitHub — https://github.com/lakeraai/pint-benchmark
[58] SecAlign: Defending Against Prompt Injection with Preference Optimization — arXiv 2410.05451 — https://arxiv.org/pdf/2410.05451
[59] facebookresearch/SecAlign — GitHub — https://github.com/facebookresearch/SecAlign
[60] Meta SecAlign: A Secure Foundation LLM Against Prompt Injection Attacks — arXiv 2507.02735 — https://arxiv.org/pdf/2507.02735
[61] The Instruction Hierarchy: Training LLMs to Prioritize Privileged Instructions — arXiv 2404.13208 — https://arxiv.org/abs/2404.13208
[62] Defending Against Indirect Prompt Injection Attacks With Spotlighting — arXiv 2403.14720 — https://arxiv.org/pdf/2403.14720
[63] How Microsoft defends against indirect prompt injection attacks — MSRC — https://www.microsoft.com/en-us/msrc/blog/2025/07/how-microsoft-defends-against-indirect-prompt-injection-attacks
[64] NVIDIA/NeMo-Guardrails — GitHub — https://github.com/NVIDIA/NeMo-Guardrails
[65] protectai/llm-guard — GitHub — https://github.com/protectai/llm-guard
[66] guardrails-ai/guardrails — GitHub — https://github.com/guardrails-ai/guardrails
[67] Block unsafe prompts targeting your LLM endpoints with Firewall for AI — Cloudflare Blog — https://blog.cloudflare.com/block-unsafe-llm-prompts-with-firewall-for-ai/
[68] Prompt injection detection — Cloudflare WAF docs — https://developers.cloudflare.com/waf/detections/ai-security-for-apps/prompt-injection/
[69] Automated Reasoning checks now available in Amazon Bedrock Guardrails — AWS — https://aws.amazon.com/about-aws/whats-new/2025/08/automated-reasoning-checks-amazon-bedrock-guardrails
[70] Amazon Bedrock Guardrails — AWS — https://aws.amazon.com/bedrock/guardrails/
[71] Guardrails - Quick Start — LiteLLM Docs — https://docs.litellm.ai/docs/proxy/guardrails/quick_start
[72] PII, PHI Masking - Presidio — LiteLLM Docs — https://docs.litellm.ai/docs/proxy/guardrails/pii_masking_v2
[73] LLM Prompt Injection Prevention Cheat Sheet — OWASP Cheat Sheet Series — https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html
[74] LLM01: Prompt Injection — OWASP Gen AI Security Project — https://genai.owasp.org/llmrisk2023-24/llm01-24-prompt-injection/
[75] Security Best Practices — Model Context Protocol — https://modelcontextprotocol.io/docs/tutorials/security/security_best_practices
[76] Model Context Protocol (MCP): Understanding security risks and controls — Red Hat — https://www.redhat.com/en/blog/model-context-protocol-mcp-understanding-security-risks-and-controls
[77] Model Context Protocol: Security Risks & Mitigations — SOC Prime — https://socprime.com/blog/mcp-security-risks-and-mitigations/
[78] CSI: MCP Security Design — NSA/CISA — https://media.defense.gov/2026/Jun/02/2003943289/-1/-1/0/CSI_MCP_SECURITY.PDF
[79] RFC 8707: Resource Indicators for OAuth 2.0 — IETF — https://www.rfc-editor.org/rfc/rfc8707
[80] CISA Agentic AI Guide: Enterprise Implementation and Gaps — CSA Labs — https://labs.cloudsecurityalliance.org/research/csa-research-note-cisa-agentic-ai-guide-enterprise-implement/
[81] Federal Agentic AI Security: NIST's Emerging Standards Initiative — CSA Labs — https://labs.cloudsecurityalliance.org/research/csa-research-note-nist-ai-agent-standards-federal-framework/
[82] Article 12: Record-Keeping — EU Artificial Intelligence Act — https://artificialintelligenceact.eu/article/12/
[83] Article 19: Automatically Generated Logs — EU Artificial Intelligence Act — https://artificialintelligenceact.eu/article/19/
[84] What the EU AI Act requires for AI agent logging — Help Net Security — https://www.helpnetsecurity.com/2026/04/16/eu-ai-act-logging-requirements/
[85] Inside the LLM Call: GenAI Observability with OpenTelemetry — OpenTelemetry Blog — https://opentelemetry.io/blog/2026/genai-observability/
[86] Gen AI — OpenTelemetry Semantic Conventions Registry — https://opentelemetry.io/docs/specs/semconv/registry/attributes/gen-ai/
[87] Building Tamper-Evident Audit Logs for AI Agent Actions — C# Corner — https://www.c-sharpcorner.com/article/building-tamper-evident-audit-logs-for-ai-agent-actions/
[88] Tamper-Evident Audit Logs with Cryptographic Proofs — Praesidia — https://praesidia.ai/blog/tamper-evident-audit-logs-cryptographic-proofs
[89] microsoft/presidio — GitHub — https://github.com/microsoft/presidio
[90] Introducing PII Shield: A Privacy Proxy for Every LLM Call — Microsoft Community Hub — https://techcommunity.microsoft.com/blog/azuredevcommunityblog/introducing-pii-shield-a-privacy-proxy-for-every-llm-call/4514726
[91] Generative AI Data Privacy with Skyflow LLM Privacy Vault — Skyflow — https://www.skyflow.com/post/generative-ai-data-privacy-skyflow-llm-privacy-vault
[92] I have a zero data retention agreement with Anthropic. What products does it apply to? — Anthropic Privacy Center — https://privacy.claude.com/en/articles/8956058-i-have-a-zero-data-retention-agreement-with-anthropic-what-products-does-it-apply-to
[93] OpenAI previews zero-retention safety system as Anthropic requires data logs — Axios — https://www.axios.com/2026/08/19/openai-previews-zero-retention-safety-system-as-anthropic-requires-data-logs
[94] Prompt Injection Attacks on Agentic Coding Assistants: A Systematic Analysis — arXiv 2601.17548 — https://arxiv.org/abs/2601.17548
[95] CommandSans: Securing AI Agents with Surgical Precision Prompt Sanitization — arXiv 2510.08829 — https://arxiv.org/pdf/2510.08829
[96] May I have your Attention? Breaking Fine-Tuning based Prompt Injection Defenses using Architecture-Aware Attacks — arXiv 2507.07417 — https://arxiv.org/pdf/2507.07417
[97] LlamaFirewall (alphaXiv, with AgentDojo result breakdown) — https://www.alphaxiv.org/abs/2505.03574
[98] AI Identity: Standards, Gaps, and Research Directions for AI Agents — arXiv 2604.23280 — https://arxiv.org/pdf/2604.23280
[99] Development containers — Claude Docs (mirror) — https://code.claude.com/docs/en/devcontainer
[100] Cloudflare — AI Security for Apps / Firewall for AI (product) — https://www.cloudflare.com/application-services/products/firewall-for-ai/
