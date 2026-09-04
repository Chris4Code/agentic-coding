# Summary — Security chapter deep research (workspace containers, identity, agent IDs, RBAC, prompt injection + firewalls + audit + privacy gateways)

**Navigation aid only.** The unabridged record is
`raw-workspace-containers--identity--agent-ids--role-management-and-rbac--how-to-handle-prompt-injections.md`
in this folder, and the claim-by-claim fact-check of the seed note is
`factcheck-initial-notes-prompt-injection.md`. Every exact figure, quote, date, arXiv ID, license,
and citation link must be pulled from those files, not from this summary — the compression here
drops nuance on purpose.

This pass covers all 11 section headers of `src/security.md` (most were bare stubs). It extends the
prior-art notes `notes/initial-notes/security - prompt injection.md`, `notes/initial-notes/identity.md`,
`notes/2026-08-30-1-local-models-agent-sandbox-landscape-research/`, and
`notes/2026-08-29-3-local-models-frontends-proxies-terminals-security/`.

Confidence tags: 🟢 primary-sourced / 🟡 corroborated-secondary / 🟠 single-source or speculative.

---

## Per-subtopic

### 1. Workspace Containers — 🟢 (harnesses) / 🟡 (Devin, Jules)
- The threat model for a *coding* agent's sandbox is **not kernel escape** — it is **data / credential
  exfiltration** and unwanted outward actions. Anthropic's own rule: effective sandboxing needs *both*
  filesystem and network isolation.
- What a sandbox must restrict: filesystem **write** scope (repo dir only), network **egress**
  (default-deny + small allow-list), **secrets in env** (`~/.aws`, `~/.ssh`, `.env`, cloud metadata),
  **git push / PR creation**, **package-registry publish**.
- Harness defaults (🟢, all first-party docs):
  - **Claude Code** — permission model (allow/ask/deny) + sandboxed Bash tool with two independent
    layers: filesystem isolation (writes scoped to CWD) and network isolation (traffic only via a
    Unix-socket proxy *outside* the sandbox enforcing an allowed-domain list). OS primitives: Linux
    **bubblewrap**, macOS **Seatbelt**. Anthropic reports sandboxing cuts permission prompts by **84%**.
    `--dangerously-skip-permissions` ("YOLO") only inside a credential-less container. Reference
    devcontainer ships `init-firewall.sh` (iptables + ipset default-deny egress allow-list).
  - **OpenAI Codex CLI** — sandboxed **by default** (per Willison's investigation, the only major agent
    that is). Linux: **Landlock + seccomp + bubblewrap**; macOS: **Seatbelt**; Windows: AppContainer +
    restricted token. Modes: read-only / workspace-write (no network) / danger-full-access.
  - **GitHub Copilot coding agent** — ephemeral Actions VM + built-in **agent firewall** (default-on).
    Recommended allow-list (OS repos + container registries); admins can lock down. **Documented hole:
    the firewall does not cover MCP servers or configured setup steps.**
  - **Devin** — full sandboxed cloud VM is the boundary (🟡, vendor-level). **Jules** — Google Cloud VM
    but *keeps* network for dependency installs → weaker egress posture (🟡).
- In-process filter (Landlock/seccomp/bubblewrap) vs container vs micro-VM: for a coding agent the
  incremental security value of climbing that ladder is **smaller than a strict egress allow-list at
  every rung** (matches the 2026-08-30 sandbox note).
- Where sandboxing breaks: the agent needs real credentials to do its job; supply-chain install scripts
  run *inside* the sandbox with its egress; **egress allow-lists are themselves exfil channels**
  (🟠 Penligent write-up — directional, not a rigorous CVE); MCP/setup steps run outside; the lethal
  trifecta persists (sandboxing limits damage, doesn't stop subversion); approval fatigue.

### 2. Identity — 🟢 (Entra Agent ID, Okta XAA, SPIFFE) / 🟡 (NHI ratios)
- Reusing a human's creds / shared service account / static key fails on attribution, least privilege,
  revocation, lifecycle. The shift is to **managed non-human identities (NHIs)**.
- NHI scale: ratios are **vendor-published and inconsistent** — Rubrik ~45:1, CyberArk >80:1, Entro
  144:1. 🟡 **direction** (NHIs vastly outnumber humans, growing with agents) is solid; **any single
  number is weak** → Research Note candidate.
- **On-behalf-of / delegated authority**: agent principal ≠ triggering human; both belong in the token
  and audit record; authorization should be the **intersection** of agent grants and user grants
  (no confused-deputy escalation).
- Enterprise: **Microsoft Entra Agent ID** (announced Build, May 2025, GA; agents are first-class Entra
  directory objects with no creds of their own — acquire tokens via an "agent identity blueprint";
  works with non-MS platforms via workload identity federation). **Okta Cross-App Access** (below).
  Ping and Google also shipping agent-identity features.
- Small company: **GitHub org is the identity layer** — GitHub Apps, fine-grained PATs scoped per-repo
  with expiry, Actions OIDC for keyless cloud auth; Google Workspace service accounts (domain-wide
  delegation is broad/risky). Give each agent its own scoped, short-expiry token, never a shared org PAT.
- Standards: **Okta Cross-App Access** = the **"Identity Assertion Authorization Grant"** OAuth
  extension, announced **June 23 2025**; flow mints an **ID-JAG** token the resource server exchanges
  for a short-lived scoped access token, giving the IdP central visibility/policy/audit. Built on two
  in-progress IETF drafts. **Workload identity federation** (exchange platform token for cloud cred, no
  stored secret). **SPIFFE/SPIRE** (CNCF graduated) — node + workload attestation → short-lived SVID
  (X.509/JWT), no pre-shared secret; HashiCorp argues SPIFFE is the right foundation for agent identity.
- Uniform direction: **attested, scoped, short-lived tokens over static long-lived keys.**

### 3. Agent IDs — 🟢 (SCIM RFCs + the IETF draft itself) / 🟠 (DLT/DID-for-agents)
- **SCIM 2.0** = RFC 7643 (schema) + RFC 7644 (protocol), 2015; IdP-driven provision/deprovision.
- **The IETF agent draft**: **"SCIM Agents and Agentic Applications Extension"**,
  `draft-abbey-scim-agent-extension`, author **Macy Abbey**, `-00` published **October 2025**. Adds an
  **`Agent`** resource and an **`AgenticApplication`** resource plus `User`/`Group` extensions. Status:
  **individual Internet-Draft, explicitly "no formal standing"**; competing drafts at IETF 124 are being
  **merged by the SCIM WG** ("Consolidation Progress" deck at IETF 125, March 2026). Engaged: WorkOS,
  Microsoft Entra, SSOJet, NHIMG — commentary, **not shipped conformant implementations** yet.
- 🟠 **Correction to prior art**: `identity.md` calls this "the new IETF SCIM standard" — **overstated**;
  it is a single-author draft under consolidation, not an adopted WG doc or a standard.
- **Public DLTs / DIDs**: real research strand (arXiv **2511.02841**, Nov 2025, verified — ledger-anchored
  W3C DIDs + Verifiable Credentials for cross-org agent-to-agent trust; survey arXiv 2604.23280). But
  **no production adoption**. 🟠 "TRAIL / `did:trail`" and "MCP-I donated to DIF March 2026" are each
  **single secondary sources, unconfirmed against a primary spec**. KILT / cheqd / "agent passport" —
  **could not corroborate any as a real agent-identity product**. Also: serious proposals use **DIDs,
  which do not require a blockchain** — the stub's "public DLT" framing is the weakest thing in the pass.
- Honest statement for the book: **SCIM + OAuth + workload identity is where real deployments are; DIDs/VCs
  are an emerging possibility for cross-org agent trust, flagged as not-yet-practice.**

### 4. Role management and RBAC — 🟢 (policy engines, GitHub primitives) / 🟡 (agent-specific application)
- Models: **RBAC** (coarse, "agent = CI role"), **ABAC/PBAC** (AWS **Cedar**, **OPA/Rego**), **ReBAC**
  (Zanzibar-style graph; **OpenFGA** / Auth0 FGA, marketed explicitly for agents / RAG least-privilege).
- Pattern: **PDP/PEP split** — the runtime (PEP) intercepts every tool call, the PDP (OpenFGA/Cedar/OPA)
  evaluates `Agent→Tool`, `Agent→Repo`, `Agent→Agent`, `User→Agent` + conditions. Core rule (arXiv
  **2606.03518**): an agent's effective permissions = **intersection** of its grants and the delegating
  user's grants, never a superset.
- **Project/repo-scoped roles preferred**; company-wide agent roles are the anti-pattern.
- Enterprise integration: Entra roles / Entra Agent ID; **AWS IAM `AssumeRole`** with session policies +
  permission boundaries (hard cap); K8s RBAC bound to a SPIFFE identity; OPA/Cedar/OpenFGA as PDP.
- **Small company — GitHub *is* the RBAC layer**: repo/team permission levels, **branch protection**
  (no direct push to `main`, require PR), **CODEOWNERS**, **environment protection rules** (required
  reviewers + wait timer), fine-grained PAT / App perms. "Agent may write, but every change goes through
  a protected-branch PR reviewed by a human" = practical zero-infrastructure least privilege.
- **JIT elevation** (minimal baseline, request scoped time-boxed grant on demand) complements static RBAC.
- **Software-factory problem**: many parallel agents = large aggregate footprint → distinct identity per
  agent, ephemeral per-run creds, per-task scoping, **human approval gates** on merge/deploy/publish/spend.
  OWASP cheat sheet says the same.

### 5. How to handle Prompt Injections — 🟢 (definitions, key papers, OWASP)
- **Definition**: untrusted input causing the LLM to follow instructions it shouldn't, because
  instructions and data share one token stream. Willison coined the term (vs **jailbreaking** =
  subverting the model's own safety training). **Direct** (attacker is the user) vs **indirect** (via
  ingested content).
- **Coding-agent indirect channels**: dependency README / package description, GitHub issue/PR comments,
  code comments & docstrings, CI/build logs, browsed web pages, **MCP tool descriptions** (tool
  poisoning), agent-config files (`AGENTS.md`, `.cursorrules`, skill/rule files). Systematic study:
  arXiv **2601.17548** (🟡 — surfaced in search, not opened; treat title as approximate).
- **Why unpreventable**: one self-attention pass, one token sequence, no control channel; embeddings
  encode meaning not provenance; KV cache is an optimisation not a boundary. RLHF/instruction-tuning
  makes naive overrides *less likely*, not impossible.
- **Willison's lethal trifecta**: (1) access to private data + (2) exposure to untrusted content +
  (3) ability to communicate externally → exploitable for data theft. Remove one leg. Coding agents
  routinely have all three.
- **2025 consensus** (Willison; Design Patterns paper arXiv 2506.08837): general-purpose agents can't give
  reliable guarantees; the productive question is which *constrained* designs stay useful. "Once an LLM
  has ingested untrusted input, it must be constrained so that input cannot trigger consequential actions."
- **Training-time mitigations (partial)**: Instruction Hierarchy (OpenAI, arXiv **2404.13208**); **StruQ**
  (<2% ASR vs optimization-free attacks); **SecAlign** (preference optimization, <10% ASR; arXiv
  2410.05451; `facebookresearch/SecAlign`); **Meta SecAlign** open model (arXiv 2507.02735). Caveat:
  fine-tuning defenses are breakable (arXiv 2507.07417, 2510.03705).
- **Benchmark reality**: **AgentDojo** (arXiv **2406.13352**, NeurIPS 2024 — 97 tasks / 629 security
  tests, extensible; SOTA models fail many tasks even without attacks). **LlamaFirewall** on AgentDojo:
  baseline **17.6% ASR → 1.75% combined**. **CommandSans** (arXiv 2510.08829): 34.67%→3.48% (GPT-4o).
  **Detector evasion is easy** — Controlled-Release Prompting (arXiv **2510.01529**) defeats lightweight
  guards with encoded payloads the target model still decodes → "shift defenses from blocking inputs to
  preventing malicious outputs". Neutral yardstick: **Lakera PINT** (3,007 inputs incl. false-positive
  probes).
- **Helps (measurable)**: remove a trifecta leg; plan-then-execute / constrain post-ingestion actions;
  typed tool schemas + deterministic policy checks; human approval on outward/irreversible actions;
  CaMeL-style data-flow control; layered classifiers (~2–10× ASR reduction, never zero).
  **Doesn't reliably help**: prompt-only pleading; a single regex/classifier gate; model RLHF alone;
  delimiters vs an adaptive attacker.

### 6. Dual-LLM Pattern — 🟢 (Willison's posts, CaMeL paper + repo)
- Origin: Simon Willison, **"The Dual LLM pattern…"**, **25 April 2023**. **Privileged LLM** (trusted
  input only, all tools, runs the loop) + **Quarantined LLM** (untrusted content, **no tools**) +
  **Controller** (plain code) that stores quarantined outputs in **symbolic variables** (`$VAR1`) the
  privileged LLM never sees expanded.
- 🟠 **"gold standard" is the seed note's editorialisation** — Willison calls the design "pretty bad"
  and a pragmatic compromise (residual social-engineering risk, complex, degrades UX). Reframe as
  "a widely-cited reference pattern."
- Evolution → **CaMeL** ("Defeating Prompt Injections by **Design**", arXiv **2503.18813**, March 2025;
  **Google DeepMind + ETH Zürich** — Debenedetti, Tramèr et al.; `google-research/camel-prompt-injection`).
  Privileged LLM emits code in a **custom restricted Python interpreter**; quarantined LLM only parses
  untrusted data into typed values; every value carries **capabilities** (provenance/trust metadata);
  a **policy engine** checks data flows before any side-effecting call. Paper claims **security
  *guarantees***, not a probabilistic score — the reason it's treated as genuinely different. ~67%
  secure task completion on AgentDojo.
- Costs: no free-form reasoning over untrusted text in the privileged flow; **policies must be written &
  maintained** → approval fatigue if over-broad; restricted interpreter limits expressiveness;
  quarantined extraction can still be wrong. Authors: "prompt injection attacks are not fully solved."
- **Six Design Patterns** (arXiv 2506.08837): Action-Selector, Plan-Then-Execute, LLM Map-Reduce,
  Dual LLM, Code-Then-Execute (= CaMeL), Context-Minimization.
- Production adoption of full Dual-LLM/CaMeL is **thin**; the sub-ideas (plan-then-execute, context
  minimization, typed tools) show up piecemeal.

### 7. LLM Firewalls — 🟢 (product/model mechanisms) / 🟡–🟠 (cross-tool efficacy numbers)
- "AI gateway" / "semantic firewall" — inline (blocking) or alongside (monitoring), inspects inputs +
  outputs.
- **NeMo Guardrails** (Apache-2.0) — **Colang** DSL; five rails: **input, dialog, retrieval, execution,
  output**; intent → state-machine trajectories; wraps Llama Guard. Canonical repo now
  **`github.com/NVIDIA-NeMo/Guardrails`** (old `NVIDIA/NeMo-Guardrails` redirects).
- **Protect AI LLM Guard** (MIT) — "scanners" stack (regex/heuristics, entropy-based secret detection,
  a fine-tuned **ONNX/DeBERTa** `PromptInjection` classifier) + `Anonymize` (Presidio PII), toxicity,
  ban-topics, output scanners. 🟠 **Repo archived (~July 2026); Protect AI acquired by Palo Alto Networks,
  completed 22 July 2025**, folded into Prisma AIRS — flag if recommending. "Base64 detection" is
  overstated (Secrets scanner, different purpose).
- **Guardrails AI** (Apache-2.0) — schema/type validation + **validate-and-reask** (`on_fail="reask"`);
  **Guardrails Hub** hosts validators.
- **Meta LlamaFirewall** (arXiv **2505.03574**, open source, license capped at 700M MAU) — **four
  components**: **Prompt Guard 2** (BERT-style classifier, **86M** mDeBERTa + **22M** DeBERTa-xsmall;
  card: ~**97.5% jailbreak recall @ 3.9% FPR** for 86M; **binary benign/malicious — NOT the old
  3-class benign/injection/jailbreak, which was Prompt Guard 1**); **AlignmentCheck** (experimental
  few-shot CoT auditor of the agent's *reasoning trace*, runs on a large Llama model); **CodeShield**
  (online static analysis of generated code, Semgrep + regex); + custom scanners. AgentDojo: 17.6%→7.5%
  (PG2) → ~2.9% (AlignmentCheck) → **1.75% combined**.
- **Cloudflare Firewall for AI** — WAF-edge, score-based **"LLM Injection score" 1–99**, + PII / unsafe-
  topic / **outbound** secret & financial-data scanning.
- **AWS Bedrock Guardrails** — content filters, denied topics, prompt-attack filter, contextual grounding,
  PII, + **Automated Reasoning checks** (formal verification vs a policy model; **GA August 2025**;
  AWS claims "up to 99% accuracy").
- **Azure AI Content Safety / Prompt Shields** — direct + indirect injection detection in input *and*
  grounding docs; uses **Spotlighting** in production.
- **LiteLLM guardrails hooks** — `pre_call` / `during_call` / `post_call` middleware; built-in Presidio
  PII masking; pluggable (Lakera, Aporia…). Commercial: Lakera Guard, Prompt Security, Robust
  Intelligence (acquired by Cisco 2024 — 🟡 from general knowledge, not re-verified this pass).
- **Regex vs classifier**: regex = sub-ms, no false negatives on *exact* known strings, evaded by
  paraphrase/translation/typos/multi-turn, false-positive-prone on quoted attack text. Classifiers =
  catch novel phrasings, ms–tens-of-ms latency, measurable FPR (~3.9%), weak on low-resource languages,
  **out-computable** by a bigger target model.
- 🟠 **Cross-tool efficacy numbers are each single-evaluation**: NeMo "0% bypass @ 16.2% FPR" vs Prompt
  Guard "38.5% bypass @ 3.6% FPR"; "Prompt Guard flags ~96% of benign *agentic* content" — **Research
  Note candidates**, do not present as settled. If that 96% is representative, inline classifier
  firewalls are near-unusable for agent traffic without heavy tuning — which is why the layered
  PromptGuard-2 + AlignmentCheck design exists.
- **OWASP** (cheat sheet + LLM01): least privilege, LLM gets its own scoped API tokens, instruction/data
  separation, human-in-the-loop for privileged ops, output DLP — and guardrails are **defense-in-depth,
  not a solution**.

### 8. Zero-Trust for AI Agents — 🟢 (MCP spec, RFC 8707) / 🟡 (CISA/NIST via CSA) / 🟠 (framework naming)
- Principles per **agent** and per **tool call**, not per session: never trust / always verify, least
  privilege, assume breach, per-request authz, microsegmentation.
- **"The agent proposes, the runtime disposes"**: LLM only proposes → deterministic code validates vs a
  **typed JSON schema** (no free-form bash/SQL) → **policy check** on every call → **per-call scoped
  short-lived credential** → **egress allow-list** → blast-radius cap → **human approval gate** on
  irreversible/outward actions.
- Guidance docs: **CISA + Five Eyes agentic-AI guidance, released 1 May 2026** (five risk categories:
  privilege escalation, design/config flaws, behavioral misalignment, structural cascading failures,
  accountability opacity) — 🟡 sourced via CSA Labs, not the primary PDF. **NIST AI Agent Standards
  Initiative, 17 Feb 2026** (pillars: security, interoperability, identity) — 🟡 **an initiative
  announcement, not a finished framework → Research Note**. **OWASP Top 10 for Agentic Applications
  (2026)**. "Agentic Zero Trust" (Cequence, May 2026) is a **vendor paper**, not a standard.
- **MCP-specific**: tool poisoning (poisoned tool *description*; a Nov 2025 incident redirected data to
  attacker infra), confused deputy (proxy servers + dynamic client registration), token passthrough
  (spec anti-pattern), rug-pull (definition changes post-approval), hidden Unicode in metadata. **MCP
  auth (2025 revisions)**: MCP server is an **OAuth 2.1 Resource Server**, **PKCE required**, **Resource
  Indicators (RFC 8707)** bind tokens to an audience. **NSA/CISA "MCP Security" CSI, June 2026.**
  Community "Vulnerable MCP Project" tracks 50+ issues.

### 9. Heuristic Content Segregation — 🟢 (Spotlighting paper, on 2023-era models) / 🟡 (consensus)
- **Spotlighting** (Microsoft, Hines et al., arXiv **2403.14720**, March 2024) — three forms:
  **delimiting** (randomised marker around untrusted text), **datamarking** (special token interleaved
  between every word), **encoding** (Base64/ROT13 the untrusted text).
- Paper's own numbers: datamarking ASR ~**50%→<3%** (GPT-3.5-Turbo); encoding **→~0%**; "negligible"
  task-quality impact. Deployed in **Azure AI Foundry Prompt Shields**.
- 🟡 **Honest caveats**: numbers are on **2023-era models** (GPT-3.5-Turbo, text-davinci-003), **no
  frontier-model validation in the paper**. Encoding is **self-undermining** — a model strong enough to
  decode Base64 is strong enough to follow instructions hidden inside it. Delimiting is weakest (delimiter
  injection, context-switching, multi-turn, translation). 2025 consensus: **prompt-level segregation is a
  speed bump, not a boundary.**
- Still worth doing: near-zero cost, stacks with other layers, stops low-effort injections, and **makes
  the untrusted span explicit in logs** (attribution / forensics).

### 10. Audit Logs — 🟢 (EU AI Act text, OTel conventions, tooling docs)
- **Log**: full prompt (system + user + **every injected tool/RAG/web output**); every tool call
  (name, args, result, allow/deny/approve); model + params + version; each plan/decision step; tokens +
  cost; **identity (agent principal + on-behalf-of human + credential/scope)**; policy decisions + human
  approvals; correlating trace/span IDs.
- **Why**: forensics after an injection incident; **compliance** — **EU AI Act Article 12** (automatic
  event logging over system lifetime for high-risk AI) + **Article 19** (retain those logs); *automatic*
  means the system generates them, manual docs don't satisfy it. Also SOC 2, **ISO/IEC 42001**.
- **Tamper-evidence**: append-only + **WORM**; **hash-chaining** (each entry stores prev-entry SHA-256 +
  own hash → Merkle chain); **ship logs off-host** to a separate trust domain. Append-only and chaining
  are complementary (casual tampering vs privileged insider).
- **Tooling**: Langfuse (MIT; EE adds project RBAC / data masking / audit log / SCIM), LangSmith, Arize
  Phoenix, Helicone, Datadog LLM Obs. **Standard: OpenTelemetry GenAI semantic conventions** — typed
  spans (agent / LLM generation / tool / guardrail / handoff); **content capture is separate, opt-in,
  emitted as log events** correlated by trace_id/span_id → can be dropped at the Collector. Cloud-native
  action audit (CloudTrail-style) captures agent API calls when the agent acts through scoped IAM roles.
- **Observability ≠ security audit log**: tracing data is sampled / mutable / short-retention / truncated;
  a security audit log must be complete / immutable / tamper-evident / access-controlled / longer-
  retention and cover identity + every authz decision + every approval. **Need both — don't let a
  dashboard stand in for the audit log.**
- **PII in logs**: the audit log now holds everything the agent saw (secrets, source, customer PII) →
  redact/tokenize at ingestion (Presidio, LLM Guard), field-level encryption, its own access audit,
  retention limits vs GDPR minimisation. Direct tie to §11.

### 11. Privacy Gateways — 🟢 (Presidio, LiteLLM, Skyflow, Anthropic ZDR docs) / 🟡 (ZDR contrast)
- A proxy that **detects and strips/masks sensitive data before it leaves the perimeter**, optionally
  **re-hydrates** the response. Local-model / NER-based: small local model or classifier (spaCy, Stanza,
  DeBERTa, ONNX, small LLM) finds secrets/PII/source identifiers → placeholders → frontier model →
  map back.
- **Tools**: **Microsoft Presidio** (MIT — analyzer [regex + NLP + context recognizers] + anonymizer
  [replace/redact/mask/hash/encrypt]; reversible if you keep the mapping; used as a **LiteLLM guardrail**
  in `pre_call`). Microsoft **"PII Shield"** privacy-proxy sample (`/anonymize_unique` → session ID,
  `/deanonymize` restores). **LLM Guard `Anonymize`/`Deanonymize`** (session-keyed vault). **Skyflow LLM
  Privacy Vault** — **deterministic tokenization** (tokens with "no mathematical connection" to the
  original; detokenization gated by vault RBAC; claims negligible quality impact). Commercial: Private AI,
  Nightfall, Protecto, **Cloudflare AI Gateway**, Portkey / Kong AI gateways, Prompt Security.
  **Secret scanning at the gateway** (gitleaks/trufflehog-style regex + entropy on the outbound prompt).
- **Trade-offs**: reversible tokenization (keeps utility, but the vault/mapping is a high-value target)
  vs irreversible masking (safer, breaks tasks needing the real value, no re-hydration); **broken
  context** (redacting names/hostnames/code identifiers degrades reasoning); **latency** (extra passes);
  **the sanitiser is imperfect** (NER recall <100%, can itself be prompt-injected; code identifiers need
  custom recognizers). Homomorphic / TEE approaches exist but aren't mainstream for frontier access.
- **Zero Data Retention as the complementary *contractual* control** — arguably more load-bearing for
  enterprises than any technical gateway. **OpenAI ZDR** and **Anthropic ZDR** both require a negotiated
  enterprise agreement (**not** on pay-as-you-go); Anthropic still retains user-safety classifier results.
  🟡 **Research Note**: the Axios Aug 2026 "OpenAI previews zero-retention as Anthropic requires data
  logs" framing is a narrow safety-logging context — **do not generalise to "Anthropic has no ZDR"**
  (its own ZDR page contradicts that).
- A privacy gateway is the natural place to emit the **redacted** audit record; its de-tokenization map
  must live in the same tamper-evident, access-controlled store as the audit log (§10).

---

## Named-entity corrections / misattributions flagged by the research

1. **`identity.md` overstates the SCIM agent draft as "the new IETF SCIM standard"** — it is
   `draft-abbey-scim-agent-extension-00`, a single-author individual Internet-Draft under WG
   consolidation, no formal standing. Existence / author / schema shape / WG activity all verified;
   "standard" is not.
2. **CaMeL is Google DeepMind + ETH Zürich** (Debenedetti, Tramèr et al.), not DeepMind alone.
3. **Prompt Guard 2 is a binary classifier (benign / malicious).** The "Benign / Injection / Jailbreak"
   three-class scheme in the seed note was **Prompt Guard 1**; Meta explicitly dropped the "injection"
   label in v2. Sizes: **86M** and **22M**.
4. **LlamaFirewall = four components** (Prompt Guard 2, AlignmentCheck, CodeShield, custom scanners), not
   just Prompt Guard.
5. **"Attention is bi-directional"** (seed note) is **wrong for decoder-only LLMs** — they use causal
   (unidirectional) attention. Correct point: each newly generated token attends back over both the
   system prompt and the untrusted data; attention does not run forward.
6. **"Dual-LLM is the gold standard"** — overstated; its author calls the design "pretty bad."
7. **NeMo Guardrails canonical repo** → `github.com/NVIDIA-NeMo/Guardrails` (old path redirects).
   **Garak canonical repo** → `github.com/NVIDIA/garak` (moved from `leondz/garak`).
8. **LLM Guard is archived (~July 2026); Protect AI acquired by Palo Alto Networks (completed 22 July
   2025)**, folded into Prisma AIRS. License stays MIT; project unmaintained.
9. **Promptfoo is now part of OpenAI** (still MIT / open-source).
10. **Not re-verified this pass** (cited from general knowledge): Instruction Hierarchy arXiv 2404.13208
    exists ✓ but not re-fetched; "Robust Intelligence acquired by Cisco 2024"; arXiv IDs with 2026
    month-codes (2601.17548, 2604.23280, 2606.03518) — cited as further reading, **titles approximate,
    not opened**. MCP auth spec exact revision dates generalised to "2025 revisions".
11. **NHI-to-human ratios** (45:1 / 80:1 / 144:1) are mutually inconsistent vendor figures — direction
    only.
12. **CISA Five Eyes guidance (1 May 2026)** and **NIST AI Agent Standards Initiative (17 Feb 2026)** are
    real but sourced via **CSA Labs summaries**, not the primary government documents; NIST's is an
    initiative, not a finished framework.

The full claim-by-claim verdicts on the seed note (`notes/initial-notes/security - prompt injection.md`)
are in `factcheck-initial-notes-prompt-injection.md` — including the note's own citation list
(~10 of 31 refs are YouTube, most of the rest SEO listicles: only the two OWASP pages, the Red Hat blog,
and Sysdig are citable). **Treat the seed note as a lead index, not evidence — re-ground every fact on
the primary sources.**

---

## What this means for the book (suggestion — user to confirm)

The current `src/security.md` header order is a reasonable spine. Suggested shape:

- **`## Workspace Containers`** → rename mentally to "the sandbox as a *containment* layer, not a
  prevention layer". Lead with the threat model (exfiltration + outward actions, not kernel escape),
  then the "restrict: fs-write / egress / secrets / push / publish" checklist, then a compact table of
  harness defaults (Claude Code / Codex / Copilot / Devin / Jules — sandbox tech, egress posture,
  on-by-default?), then "where it breaks". Cross-reference the 2026-08-30 sandbox note for the isolation
  spectrum rather than repeating it. A **mermaid diagram** of the Claude Code proxy-egress architecture
  (sandboxed Bash → Unix socket → out-of-sandbox proxy → allow-list) would earn its place.
- **`## Identity` / `### Agent IDs` / `### Role management and RBAC`** — this is a strong three-part
  arc: *why an agent needs its own identity* → *how that identity is issued and standardised* (SCIM +
  the IETF draft; OAuth ID-JAG; SPIFFE; DIDs as emerging-not-practice) → *what that identity is allowed
  to do* (RBAC/ReBAC, PDP/PEP, intersection rule, GitHub-as-RBAC for small teams, JIT, the software-
  factory problem). Give the enterprise-vs-small-company split explicitly in each — it's a recurring
  reader question and the research supports a clean answer for both. `Research Note:` on the NHI ratios
  and on the DLT/DID material.
- **`# How to handle Prompt Injections`** — restructure into: (1) what it is + why architecturally
  unpreventable (fix the "bidirectional" error) + the lethal trifecta; (2) the 2025 "constrain, don't
  prevent" consensus; (3) design patterns — **Dual-LLM → CaMeL** as the throughline, then the six-pattern
  taxonomy; (4) **LLM firewalls** as defense-in-depth — regex vs classifier, the product landscape,
  and honestly that detectors are evadable and noisy (`Research Note:` on the cross-tool efficacy
  numbers); (5) **heuristic content segregation** as the explicit speed-bump-not-boundary section;
  (6) **zero-trust runtime** (agent proposes / runtime disposes, typed tools, per-call creds, MCP
  auth + MCP-specific attacks, human approval gates). A **mermaid** "LLM proposes → schema validation →
  policy check → scoped credential → tool exec" flow fits section 6.
- **`## Audit Logs`** — lead with the observability-vs-security-audit-log distinction (it's the
  non-obvious point), then what-to-log, then tamper-evidence (hash-chain + WORM + off-host), then
  EU AI Act Art. 12/19 + ISO 42001, then tooling + OTel GenAI conventions, then PII-in-logs → hands off
  to Privacy Gateways.
- **`## Privacy Gateways`** — the redact/tokenize/re-hydrate pipeline, the tool list (Presidio, LLM Guard,
  Skyflow, Cloudflare), the trade-offs (reversible vs irreversible, broken context, imperfect sanitiser),
  and **ZDR as the contractual complement** (`Research Note:` on the Axios framing).
- **Glossary additions**: prompt injection, indirect prompt injection, jailbreaking, lethal trifecta,
  Dual-LLM pattern, CaMeL, LLM firewall / AI gateway, guardrails, spotlighting, instruction hierarchy,
  zero-trust for agents, non-human identity (NHI), SCIM, ID-JAG / Cross-App Access, SPIFFE/SPIRE,
  workload identity federation, ReBAC / OpenFGA, PDP/PEP, JIT elevation, tool poisoning, confused deputy,
  RFC 8707 / Resource Indicators, WORM, hash-chained audit log, OpenTelemetry GenAI conventions,
  privacy gateway, deterministic tokenization, Zero Data Retention (ZDR), Presidio. (Several may already
  exist from other chapters — check before adding.)
- **Research Note candidates** (per CLAUDE.md evidence convention — flag as *not* well-corroborated):
  NHI-to-human ratios; DLT/DID-for-agents adoption; cross-tool firewall efficacy numbers (NeMo 16.2% FPR,
  Prompt Guard 38.5% bypass, ~96% benign-flagging); the NIST initiative being pre-framework; the Axios
  ZDR framing; the Penligent egress-bypass write-up; Spotlighting's frontier-model applicability.
