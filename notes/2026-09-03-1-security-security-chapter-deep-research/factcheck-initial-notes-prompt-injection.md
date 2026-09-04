# Fact-check: `notes/initial-notes/security - prompt injection.md`

Scope: claim-by-claim verification of the specific checkable facts (licenses, repo ownership, attributions, named mechanisms, version/class names, citation validity) in the Gemini-chat export on prompt injection. Broad topic research is out of scope and handled separately.

---

## 1. Dual-LLM pattern — named, coined by, described correctly

**Verdict: CONFIRMED**

- Coined by Simon Willison, "The Dual LLM of Guaranteed Safety", 25 April 2023. It is a recognised, frequently-cited pattern. [1]
- Roles as Willison defines them: a **Privileged LLM** that only sees trusted input (the user) and holds all tool access, and a **Quarantined LLM** that handles untrusted content and has "no ability to execute additional actions". A **Controller** (normal code) brokers between them using opaque variable tokens (e.g. `$VAR1`) so the untrusted text and the "tainted" summary from the Quarantined LLM are *never* seen by the Privileged LLM. [1]
- The note's description ("quarantined model extracts structured data, has no tools; privileged model never sees raw untrusted input, holds tool execution") matches the source accurately.
- The OWASP LLM Prompt Injection Prevention Cheat Sheet independently describes the same pattern in the same terms. [2]

## 2. "Considered the gold standard" / CaMeL as the evolution

**Verdict: PARTLY CONFIRMED (overstated)**

- Willison himself does *not* frame it as a gold standard. In the originating post he writes: "You may have noticed something about this proposed solution: it's pretty bad!" — noting heavy implementation complexity and residual social-engineering risk. [1]
- It is *a* prominent reference architecture (OWASP cheat sheet lists it under model-based guardrails [2]), but "gold standard" is the note's editorialisation, not a sourced characterisation. Recommend softening to "a widely-cited reference pattern".
- The evolution is real and worth citing: **CaMeL** ("Defeating Prompt Injections by Design", Debenedetti et al., Google DeepMind, arXiv:2503.18813, March 2025), which generalises the split into capability-based access control and explicit data-flow tracking over a generated pseudo-Python plan; ~67% secure task completion on AgentDojo. Code at `github.com/google-research/camel-prompt-injection`. [3][4]

## 3. NVIDIA NeMo Guardrails — license, Colang, 5 rails, LlamaGuard, canonical repo

**Verdict: CONFIRMED (with a repo-URL correction)**

- License: **Apache 2.0** — confirmed in the repo README. [5]
- **Colang**: confirmed — a Python-like DSL for modelling dialogue flows; versions 1.0 (default) and 2.0. [5]
- Five rail types: **input, dialog, retrieval, execution, output** — confirmed verbatim in the README. [5]
- "Natively wraps open-source safety models like LlamaGuard": confirmed — there is a first-party Llama Guard integration (`examples/configs/llama_guard/`, plus the Content Safety catalog entry) that adds `llama guard check input`/`output` flows. [6][7]
- **Canonical repo URL**: the project moved to the `NVIDIA-NeMo` org. Current canonical is **`github.com/NVIDIA-NeMo/Guardrails`** (note citation [7]); the older `github.com/NVIDIA/NeMo-Guardrails` (used in the toolkit-section heading link) still resolves via GitHub's automatic redirect but is the stale path. Docs now live at `docs.nvidia.com/nemo/guardrails`. [5][8]

## 4. LLM Guard by Protect AI — license, repo, scanners, ONNX, PII, toxicity, acquisition

**Verdict: PARTLY CONFIRMED — repo is now ARCHIVED; ownership changed**

- License: **MIT** — confirmed. [9]
- Repo `github.com/protectai/llm-guard` — correct path, **but the repository was archived** (banner: "THIS PROJECT HAS BEEN ARCHIVED … no longer under active development or maintained"; associated Hugging Face models likewise). Community reporting dates the archive to July 2026. [9][10]
- "Scanners" architecture: confirmed — ~15 input scanners and ~20 output scanners, run via `scan_prompt()` / `scan_output()`. Input+output stages: confirmed. [9][11]
- `PromptInjection` scanner backed by fine-tuned DeBERTa-class models, with optional **ONNX** runtime (`use_onnx=True`, `llm-guard[onnxruntime]`): confirmed. [11]
- Built-in PII redaction via `Anonymize` / `Deanonymize`, and `Toxicity` scanners: confirmed. [9]
- **Base64 / obfuscation detection**: only weakly supported. There is no dedicated anti-injection deobfuscation scanner; the `Secrets` scanner flags high-entropy Base64/hex strings, which is a different purpose. The note's phrasing overstates this.
- **Acquisition**: Protect AI was acquired by **Palo Alto Networks** — announced April/May 2025, **completed 22 July 2025**; products folded into Prisma AIRS. This does not retroactively change the published MIT license or the repo path, but it explains the project's stall and archival, and matters for whether the book should recommend it. [12][13]

## 5. Guardrails AI — license, repo, validate-and-reask, Guardrails Hub

**Verdict: CONFIRMED**

- License: **Apache 2.0** — confirmed. [14]
- Repo `github.com/guardrails-ai/guardrails` — confirmed. [14]
- **Guardrails Hub**: confirmed — a catalog of pre-built "validators" installed individually (`guardrails hub install …`) and composed into Input/Output Guards. [14]
- "Validate-and-reask" loop: **CONFIRMED as a real mechanism** though not phrased that way in the current top-level README. Guardrails AI's documented behaviour on validation failure includes `on_fail="reask"`, which re-prompts the model with the validation error to obtain a compliant output. The note's description is accurate; cite the reask docs rather than the README. [14][15]

## 6. Meta LlamaFirewall / Prompt Guard 2 — paper, components, class labels

**Verdict: PARTLY CONFIRMED — the "three classes" claim is OUTDATED**

- **LlamaFirewall paper exists**: "LlamaFirewall: An Open Source Guardrail System for Building Secure AI Agents", arXiv:2505.03574, submitted 6 May 2025, ~19 Meta authors. Self-described as "an open-source … guardrail framework designed to serve as a final layer of defense against security risks associated with AI Agents." [16]
- Components (from the paper): **PromptGuard 2** (jailbreak/injection detection), **Agent Alignment Checks / AlignmentCheck** (chain-of-thought auditor for goal hijacking), **CodeShield** (online static analysis of generated code), plus **customizable regex / LLM-prompt scanners**. The note only mentions Prompt Guard; the other three components should be added. [16]
- **Prompt Guard 2 model sizes**: **86M** (base mDeBERTa-v3-base) and **22M** (base DeBERTa-v3-xsmall). Confirmed. [17][18]
- **"Exactly three classes: Benign, Injection, Jailbreak"**: **OUTDATED / REFUTED for Prompt Guard 2.** The v2 model card states: "Simplified binary classification: Both Prompt Guard 2 models … label[] prompts as 'benign' or 'malicious'" and explicitly "Unlike with Prompt Guard 1, we don't include a specific 'injection' label." The three-label scheme (benign / injection / jailbreak) was **Prompt Guard 1**. [17]

## 7. Garak — ownership / canonical repo, what it is

**Verdict: CONFIRMED — repo moved to NVIDIA**

- The note cites `github.com/leondz/garak`. That path still resolves but **redirects**; the current canonical repo is **`github.com/NVIDIA/garak`** (garak joined NVIDIA; still maintained by Leon Derczynski et al.). [19]
- It is a "Generative AI Red-teaming & Assessment Kit" — a vulnerability scanner that probes LLMs for prompt injection, jailbreaks, data leakage, toxicity, encoding attacks, hallucination, etc. License **Apache 2.0**. Confirmed. [19]

## 8. Promptfoo — repo, purpose

**Verdict: CONFIRMED**

- Repo `github.com/promptfoo/promptfoo` — confirmed. License **MIT**. [20]
- Does eval, red-teaming / vulnerability scanning, and CI/CD regression testing for LLM apps — confirmed. [20]
- Bonus (not in note, may be relevant): promptfoo announced it is "now part of OpenAI" while remaining open-source / MIT. [20]

## 9. Core architectural argument (one token stream, no control/data separation, KV cache not a boundary, "attention is bi-directional")

**Verdict: PARTLY CONFIRMED — mainstream in substance, one phrasing is wrong**

- "LLMs can't separate control from data because instructions and untrusted input are concatenated into one token sequence and the model has no notion of provenance" — this is the mainstream explanation, stated in essentially these terms by Simon Willison [21], the OWASP community page [22], and the OWASP cheat sheet [2]. CONFIRMED.
- "Embeddings encode meaning, not source" and "the KV cache is a memory optimisation, not a security boundary" — accurate and uncontroversial framing; the KV cache just stores already-computed keys/values for prior tokens and carries no trust metadata.
- **"Attention is Bi-Directional"** — **imprecise/incorrect for a decoder-only causal LLM.** These models use *causal (masked, unidirectional)* self-attention: a token attends only to itself and earlier tokens, never forward. The note's underlying point is still valid — when generating, each new token attends back over *both* the system prompt and the untrusted data in context — but the correct term is "causal / left-to-right attention", not "bi-directional". Bidirectional attention is a property of encoder models (BERT-style), not GPT-style decoders. Recommend rewording.
- Supporting context to cite: OpenAI's "The Instruction Hierarchy" (Wallace et al., arXiv:2404.13208, 2024) frames the same problem as the motivation for training a privileged-instruction hierarchy. [23]

## 10. Data Spotlighting / delimiters — attribution and the three techniques

**Verdict: CONFIRMED (attribution + techniques); the "modern models prioritise instructions outside tags" claim is optimistic**

- Attribution: "Defending Against Indirect Prompt Injection Attacks With Spotlighting", Hines et al., **Microsoft**, arXiv:2403.14720, March 2024. Confirmed. [24]
- Three techniques: **delimiting**, **datamarking** (interleaving a marker token throughout the untrusted text), **encoding** (e.g. base64 the untrusted text). Confirmed verbatim. The paper reports attack success rate dropping from >50% to <2% on GPT-family models with minimal task-quality loss. [24]
- "Modern RLHF'd frontier models prioritize instructions outside structural tags, making simple overrides much less likely" — **only partly supported and phrased too confidently.** The measured reductions come from *applying spotlighting/instruction-hierarchy training*, not from plain XML tags on an untrained model, and even then the residual attack rate is non-zero and degrades under adaptive attacks. Willison repeatedly cautions that delimiters are not a reliable boundary. Recommend: "instruction-hierarchy training (OpenAI 2024) and spotlighting (Microsoft 2024) measurably reduce — but do not eliminate — success of tag-delimited overrides."

## 11. "Sub-10ms regex scanners"

**Verdict: UNVERIFIABLE (loose figure, YouTube-only in the note)**

- The note's only source is a YouTube video ([9] in the first reference list). No primary/benchmarked source found.
- Plausibility: a compiled regex match over a short prompt is typically sub-millisecond; a full guardrail-service call (regex layer only, no ML) landing in single-digit milliseconds is believable but implementation- and payload-dependent. Treat "sub-10ms" as illustrative, not a cited benchmark. If the chapter uses a latency number it should come from a named tool's own docs/benchmark (e.g. LLM Guard's optimization page) rather than this note.

## 12. "Modern frontier models undergo extensive RLHF specifically to resist tag-delimited injection"

**Verdict: PARTLY CONFIRMED — needs softening**

- Frontier models *are* post-trained (RLHF and related) for an instruction/priority hierarchy — OpenAI's "The Instruction Hierarchy" (2024) is the canonical public description, and Microsoft's spotlighting work fine-tunes/steers similarly. [23][24]
- But "specifically to resist tag-delimited injection" overstates the target: the training goal is general privileged-instruction prioritisation across many conflict types, and vendors do not claim it defeats delimiter-based injection. The note's own citation [16] is a YouTube video. Recommend attributing to arXiv:2404.13208 and rewording to "general instruction-hierarchy post-training", noting it reduces rather than removes the risk.

## 13. Citation quality

**Verdict: PARTLY CONFIRMED — the authoritative citations resolve; a large fraction are low-value**

Checked / resolves to real, relevant primary or reputable pages:
- **OWASP LLM Prompt Injection Prevention Cheat Sheet** ([3] in list 1) — real, official OWASP Cheat Sheet Series page. Good to cite. [2]
- **OWASP community PromptInjection page** ([15] in list 1) — real official OWASP page. Usable, though lighter-weight than the cheat sheet. [22]
- **Red Hat blog** ([13] in list 1), "AI security: Defending against prompt injection and unsafe actions" — real, reputable vendor engineering blog; covers input/output/runtime guardrails, dual-LLM, CaMeL. Acceptable secondary source. [25]
- **Sysdig** ([14] in list 1) "prompt injection" learn page — reputable security vendor explainer; acceptable as secondary/background.
- **MintMCP blog** ([11] in both lists) — vendor marketing blog ("prompt injection detection tools"). Low authority; do not cite for facts.

Low-quality / SEO-listicle domains that should NOT be cited in the book (they exist but are content-farm "Top 5 … 2025/2026" pages or thin vendor blogs):
`futureagi.com`, `getmaxim.ai`, `safeguard.sh`, `obot.ai`, `aimultiple.com`, `appsecsanta.com`, `morphllm.com`, `aithinkerlab.com`, `infosec.qa`, `aisecurityandsafety.org`, `towardsdatascience.com` (Medium-hosted), `dev.to`, `obsidiansecurity.com` blog.

YouTube weight: of the note's ~31 numbered references across the two lists, roughly 10 are YouTube videos and several more are vendor/SEO blogs. The **substantive** claims (dual-LLM, spotlighting, the toolkit licenses/mechanisms, Prompt Guard classes) can all be re-grounded in primary sources (done above), so the note is usable as a *lead list* — but almost none of its own citations should survive into the chapter. Treat the note as a starting index, not evidence.

---

## Corrections for the chapter

- **Dual-LLM is not a "gold standard".** Its own author calls the design "pretty bad" and a pragmatic compromise. Describe it as a widely-cited reference pattern, and pair it with its successor **CaMeL** (Google DeepMind, arXiv:2503.18813, 2025).
- **NeMo Guardrails canonical repo is `github.com/NVIDIA-NeMo/Guardrails`**, not `github.com/NVIDIA/NeMo-Guardrails` (old path, redirects). Docs: `docs.nvidia.com/nemo/guardrails`.
- **LLM Guard is archived** (July 2026) and its **publisher Protect AI was acquired by Palo Alto Networks** (completed 22 July 2025), with the tech folded into Prisma AIRS. License stays MIT, but the project is no longer maintained — flag this if recommending it.
- **LLM Guard Base64 claim is overstated.** No dedicated anti-injection deobfuscation scanner; the Secrets scanner detects high-entropy Base64/hex strings for a different purpose.
- **Prompt Guard 2 is a BINARY classifier (benign / malicious), not three classes.** "Benign / Injection / Jailbreak" was Prompt Guard 1. Meta explicitly dropped the "injection" label in v2. Model sizes: 86M and 22M.
- **LlamaFirewall has four components**, not one: PromptGuard 2, AlignmentCheck (agent alignment / CoT auditing), CodeShield (static analysis of generated code), and custom regex/LLM scanners. Paper: arXiv:2505.03574 (May 2025).
- **Garak's canonical repo is `github.com/NVIDIA/garak`** (moved from `leondz/garak`).
- **Promptfoo** is now part of OpenAI (still MIT / open-source) — worth a parenthetical if the book names it.
- **"Attention is bi-directional" is wrong for GPT-style models.** Decoder-only LLMs use causal (unidirectional) attention. Reword: each newly generated token attends back over both the system prompt and the untrusted data, but attention does not run forward.
- **Spotlighting attribution:** Microsoft, "Defending Against Indirect Prompt Injection Attacks With Spotlighting", arXiv:2403.14720 (March 2024). Three techniques: delimiting, datamarking, encoding.
- **Soften the RLHF claims (both places).** Frontier models get general instruction-hierarchy post-training (OpenAI, arXiv:2404.13208, 2024) and spotlighting-style steering (Microsoft 2024); this *reduces but does not eliminate* tag-delimited injection. It is not training "specifically" against delimiter attacks, and no vendor claims it defeats them.
- **"Sub-10ms regex" is an uncited, loose figure** (YouTube-only). Drop it or replace with a benchmarked number from a named tool's docs.
- **Do not carry over the note's own citations.** Re-ground every fact on the primary sources listed below. In particular avoid: futureagi.com, getmaxim.ai, safeguard.sh, obot.ai, aimultiple.com, appsecsanta.com, morphllm.com, aithinkerlab.com, infosec.qa, aisecurityandsafety.org, mintmcp.com, and Medium/dev.to reposts.
- **Guardrails AI** "validate-and-reask" is accurate but cite the `on_fail="reask"` docs, not the README.

## Sources

1. The Dual LLM of Guaranteed Safety — https://simonwillison.net/2023/Apr/25/dual-llm-pattern/
2. OWASP LLM Prompt Injection Prevention Cheat Sheet — https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html
3. Defeating Prompt Injections by Design (CaMeL), arXiv:2503.18813 — https://arxiv.org/abs/2503.18813
4. CaMeL code repository — https://github.com/google-research/camel-prompt-injection
5. NeMo Guardrails README (current org) — https://github.com/NVIDIA-NeMo/Guardrails
6. NeMo Guardrails Llama Guard example config — https://github.com/NVIDIA-NeMo/Guardrails/blob/develop/examples/configs/llama_guard/README.md
7. NeMo Guardrails Content Safety catalog (docs) — https://docs.nvidia.com/nemo/guardrails/configure-guardrails/guardrail-catalog/content-safety
8. Old NeMo Guardrails repo path (redirects) — https://github.com/NVIDIA/NeMo-Guardrails
9. LLM Guard README (archived) — https://github.com/protectai/llm-guard
10. LLM Guard optimization / ONNX tutorial — https://github.com/protectai/llm-guard/blob/main/docs/tutorials/optimization.md
11. LLM Guard optimization docs (ONNX `use_onnx`) — https://protectai.github.io/llm-guard/tutorials/optimization/
12. Palo Alto Networks — intent to acquire Protect AI — https://www.paloaltonetworks.com/company/press/2025/palo-alto-networks-announces-intent-to-acquire-protect-ai--a-game-changing-security-for-ai-company
13. Palo Alto Networks — completes acquisition of Protect AI — https://www.paloaltonetworks.com/company/press/2025/palo-alto-networks-completes-acquisition-of-protect-ai
14. Guardrails AI README — https://github.com/guardrails-ai/guardrails
15. Guardrails AI documentation — https://guardrailsai.com/docs
16. LlamaFirewall: An Open Source Guardrail System for Building Secure AI Agents, arXiv:2505.03574 — https://arxiv.org/abs/2505.03574
17. Llama Prompt Guard 2 model card (86M) — https://github.com/meta-llama/PurpleLlama/blob/main/Llama-Prompt-Guard-2/86M/MODEL_CARD.md
18. meta-llama/Llama-Prompt-Guard-2-86M (Hugging Face) — https://huggingface.co/meta-llama/Llama-Prompt-Guard-2-86M
19. garak repository (NVIDIA) — https://github.com/NVIDIA/garak
20. promptfoo repository — https://github.com/promptfoo/promptfoo
21. Prompt injection explained (Simon Willison) — https://simonwillison.net/2023/May/2/prompt-injection-explained/
22. OWASP community — Prompt Injection — https://owasp.org/www-community/attacks/PromptInjection
23. The Instruction Hierarchy: Training LLMs to Prioritize Privileged Instructions, arXiv:2404.13208 — https://arxiv.org/abs/2404.13208
24. Defending Against Indirect Prompt Injection Attacks With Spotlighting, arXiv:2403.14720 — https://arxiv.org/abs/2403.14720
25. Red Hat — AI security: Defending against prompt injection and unsafe actions — https://www.redhat.com/en/blog/ai-security-defending-against-prompt-injection-and-unsafe-actions
