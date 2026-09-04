# Glossary

#### Accessibility tree (a11y tree)
the semantic tree of a UI (element roles, names, states — ARIA on the web) that a browser exposes for assistive technology; browser-automation agents drive and assert against it instead of screenshots or CSS selectors because it is deterministic, cheap (~200–400 tokens per snapshot), and survives visual refactors. Contrast pixel-based [computer use](#computer-use--browser-use). See [Quality § Integration and end-to-end testing with a browser in the loop](./quality.md#integration-and-end-to-end-testing-with-a-browser-in-the-loop).

#### Accumulative linear caching
how agentic harnesses extend their prompt cache: since conversation history is append-only, the server simply grows the existing KV cache with each new turn instead of recomputing it. See [Basics § Prompt caching](./basics.md#prompt-caching---efficient-cloud-model-integration).

#### Agentic Business Workflows
the general, single-project pattern for a software factory's human stakeholders — owners who want a financial/throughput view, contractors who need a task queue of exactly what's paused waiting on them, and the customer who wants a roadmap — tied together by a financial ledger separating compute from contractor cost and durable human-in-the-loop gates. See [SW Factories § Agentic Business Workflows](./sw-factories.md#agentic-business-workflows).

#### Agentic RAG
a retrieval architecture where the LLM acts as an agent that loops over retrieval calls itself (search, inspect results, rewrite the query, search again) instead of retrieval happening once before generation. See [RAGs § Context management](./rags.md#context-management).

#### Agentic Software Factory
an organizational architecture in which AI agents autonomously execute the actual SDLC work (planning, coding, testing, reviewing) rather than a pipeline merely automating steps humans still perform by hand; per Addy Osmani, "not a bigger agent; it is an org chart made of loops." See [SW Factories § Agentic SW Factories](./sw-factories.md#agentic-sw-factories).

#### Agent sandbox
an isolated boundary (in-process syscall restriction, a container, or a Firecracker-style micro-VM) that an autonomous agent's shell, network and file-write actions run inside, so a bad tool call or a prompt-injected instruction cannot reach the host. See [Local Models § Agent sandboxing](./local-models.md#agent-sandboxing).

#### Agent scaffold
the harness (system prompt, tool set, control loop, step budget) wrapped around a model to run a benchmark like SWE-bench, which only grades the resulting patch. The same model scores very differently across scaffolds (mini-SWE-agent, OpenHands, Claude Code), so a benchmark number is a property of *(model × scaffold × settings)*, not the model alone. See [Local Models § Benchmarks](./local-models.md#benchmarks).

#### Aider polyglot
a benchmark of the 225 hardest Exercism exercises across six languages that scores both whether the model solves the problem (after one retry) and whether it emits a diff the harness can apply — i.e. it tests editing existing code, not just writing it. See [Local Models § Benchmarks](./local-models.md#benchmarks).

#### Artificial Analysis
an independent benchmarking firm (artificialanalysis.ai) that runs its own evaluations into a composite Intelligence Index and, separately, independently measures output speed, latency and price for each hosted model endpoint across providers. See [Local Models § Benchmarks](./local-models.md#benchmarks).

#### Attention heads (Multi-Head Attention)
parallel Query/Key/Value projections within a layer, each able to learn a different kind of relationship between tokens; their outputs are concatenated back together. See [Basics § Attention heads](./basics.md#attention-heads).

#### AWQ (Activation-aware Weight Quantization)
a GPU-native 4-bit weight-quantization format that protects the ~1% most salient weight channels (chosen by activation scale) and quantizes the rest, the de-facto standard for 4-bit serving on vLLM/SGLang. See [Local Models § Quantization](./local-models.md#quantization).

#### Benchmark contamination
inflation of a benchmark score because the test items (issues, gold patches, even problem-statement wording) were present in the model's training data. Countered by contamination-resistant benchmarks that draw from material published after the training cutoff (LiveCodeBench date windows, SWE-rebench / SWE-bench-Live monthly refreshes) and by human-preference arenas. See [Local Models § Benchmarks](./local-models.md#benchmarks).

#### Block table
the map vLLM's PagedAttention uses to translate a request's logical token positions to the physical, non-contiguous memory blocks holding its KV cache. See [Basics § PagedAttention (vLLM)](./basics.md#pagedattention-vllm).

#### Bounded model checking (BMC)
a formal-verification technique that unrolls a program's loops to a fixed bound, translates it plus its assertions into a logical formula, and uses an SMT solver to either find an input that violates an assertion or prove none exists within the bound (tools: CBMC, ESBMC for C/C++). Catches array-bounds and pointer-safety bugs on paths no test or fuzz input reached — a different class than sanitizers detect. See [Quality § C and C++](./quality.md#c-and-c-why-the-row-isnt-the-whole-story).

#### BPMN (Business Process Model and Notation)
the standard diagramming language for enterprise workflow engines (pools, swimlanes, gateways, service/user tasks); its primitives map onto agent-loop concepts closely enough that engines like Camunda and Flowable have extended themselves toward native agent orchestration, and a factory's macro-lifecycle built on one can be collapsed into an equivalent LangGraph topology instead. See [SW Factories § BPMN as a Visual Governance Layer](./sw-factories.md#bpmn-as-a-visual-governance-layer).

#### Bridge Pattern (CLI → MCP)
wrapping an existing human-facing CLI in an MCP server whose tools shell out to it under the hood, keeping the CLI as the source of truth; fast to stand up but brittle if the CLI's output format changes. See [Agentic Coding Harnesses § Human-vs-Machine Developer Experience](./agentic-coding-harnesses.md#human-vs-machine-developer-experience).

#### Buy vs. own your control flow
the recurring design question at every layer of a software factory: whether a general framework's abstractions help assemble a pipeline of agent loops faster, or hide the control-flow details (retries, tool selection, state handoff between stages) a factory builder needs to own directly. See [SW Factories § LangChain](./sw-factories.md#langchain).

#### Bring Your Own LLM (BYO-key)
pointing an agentic coding tool at an arbitrary OpenAI- or Anthropic-compatible endpoint (a self-hosted engine, a gateway, or a provider where you registered your own upstream key) instead of the tool's default provider, typically via `ANTHROPIC_BASE_URL` / `OPENAI_BASE_URL` environment variables. See [Local Models § Bring Your Own LLM](./local-models.md#bring-your-own-llm).

#### Burst-to-cloud (overflow routing)
in a hybrid setup, letting a local model serve the baseline request load and spilling the excess to a cloud API (or rented GPU) when the local machine saturates under concurrency. See [Hybrid Setups § Cloud primary, local fallback](./hybrid-setups.md#cloud-primary-local-fallback).

#### Cache-Augmented Generation (CAG)
placing an entire static reference document permanently at the top of the prompt instead of chunking and searching it, so every query hits a warm prompt cache for that block. See [RAGs § Context management](./rags.md#context-management).

#### Cache thrashing / cache miss
the loss of a prompt cache hit caused by a single changed character anywhere in the cached prefix, forcing the provider to recompute the KV cache from scratch. See [Basics § Prompt caching](./basics.md#prompt-caching---efficient-cloud-model-integration).

#### CaMeL (Capabilities for Machine Learning)
a design-level prompt-injection defence (Google DeepMind and ETH Zürich, 2025) that extends the [Dual-LLM pattern](#dual-llm-pattern): a privileged LLM emits code in a restricted interpreter, a quarantined LLM only parses untrusted data into typed values, every value carries a provenance *capability*, and a policy engine checks each data flow before a side-effecting call. Claims security *guarantees* rather than a detection score, at the cost of hand-maintained policies. See [Security § The Dual-LLM Pattern and CaMeL](./security.md#the-dual-llm-pattern-and-camel).

#### Capability cascade
a hybrid routing pattern that sends a request to the local model first and escalates it to a cloud frontier model only on a failure signal (repeated failing tests, a low-confidence response, a stuck tool loop, or an explicit escalate). See [Hybrid Setups § Capability cascade](./hybrid-setups.md#capability-cascade).

#### Change-detector test
a test that fails whenever the implementation changes rather than whenever the behaviour breaks (Google's term), the characteristic product of mocking every collaborator: the stubs encode the author's assumptions about the dependencies, so the only thing left to assert is which calls were made in which order — an implementation choice, not an observable result. A behaviour-preserving refactor turns it red; a real regression can leave it green. See [Quality § Designing for testability](./quality.md#designing-for-testability).

#### Communication tax
the token cost of agents passing large code blocks back and forth (e.g. during review or testing), which can account for up to ~60% of an unoptimized agentic run's total token spend if left unmanaged. See [Basics § multi-turn loops and Loop engineering](./basics.md#multi-turn-loops-and-loop-engineering).

#### Confused deputy
a privilege-escalation pattern where a trusted intermediary is tricked into misusing its authority on behalf of a less-privileged caller. For agents it appears twice: an agent acting with more authority than the human who invoked it (mitigated by authorising the *intersection* of the two), and MCP proxy flows that obtain authorization codes without proper user consent. See [Security § The agent and its principal are two subjects](./security.md#the-agent-and-its-principal-are-two-subjects).

#### Composition root
the single explicit place (typically `main` or a factory function) where an application's object graph is wired: real adapters are constructed and passed into the components that need them, while tests pass fakes into the same parameters. Preferred over a DI container's annotation-driven wiring in agentic work, because it keeps the whole dependency graph greppable in one function instead of resolved somewhere the agent cannot see. See [Quality § Designing for testability](./quality.md#designing-for-testability).

#### Comprehension debt
the growing gap between how much code a system contains and how much of it any human genuinely understands, widened when agents generate diffs faster than anyone can audit them; per Addy Osmani, more dangerous than technical debt because it "breeds false confidence" rather than announcing itself through friction. See [Quality § More code, less understanding](./quality.md#more-code-less-understanding).

#### Computer use / browser use
two styles of GUI automation for agents. *Computer use* (Anthropic, OpenAI) is pixel-based — the model sees a screenshot and issues mouse/keyboard actions; general but token-heavy and imprecise on coordinates. *Browser use* (a separate Anthropic tool) drives a browser through its [accessibility tree](#accessibility-tree-a11y-tree) plus a rendered view, targeting elements semantically. See [Basics § Multi Modal Models](./basics.md#relevance-in-agentic-coding) and [Quality § Multi Modal Models](./quality.md#multi-modal-models).

#### Consumer-driven contract testing
an integration-testing style (canonically Pact) where the consumer of a service declares what it needs and that contract is verified against the provider independently, so services need not be deployed together to check compatibility; in agentic workflows the contract artifacts are increasingly agent-authored (PactFlow AI). See [Quality § Automated contract testing](./quality.md#automated-contract-testing).

#### Context engineering
deliberately managing what occupies an LLM's context window at each turn — what's included, left out, summarized, or repositioned — instead of letting a conversation's context grow unmanaged. See [Basics § Context engineering](./basics.md#context-engineering).

#### Context window explosion
the failure mode where dumping a large, self-describing schema (a full GraphQL schema or an OpenAPI spec with 50+ endpoints) directly into an LLM's context exhausts the context window and inflates token cost; mitigated by exposing only curated operations or a filtered/searchable subset of endpoints. See [Agentic Coding Harnesses § GraphQL](./agentic-coding-harnesses.md#graphql).

#### Copy-on-write (memory sharing)
requests sharing an identical prompt prefix (e.g. the same system prompt) point at the same physical KV cache blocks until one of them diverges, only then cloning the block. See [Basics § PagedAttention (vLLM)](./basics.md#pagedattention-vllm).

#### Coverage-guided fuzzing
automated testing that feeds mutated inputs to a target and keeps the ones that reach new code paths, driving toward maximum coverage (libFuzzer, AFL++; OSS-Fuzz runs it continuously for open source). In an agentic workflow the agent can draft the fuzz harness for a parser or untrusted-input boundary, and the run finds the edge-case and untested-path bugs a hand-written suite misses. See [Quality § Fuzzing](./quality.md#fuzzing) and [§ C and C++](./quality.md#c-and-c-why-the-row-isnt-the-whole-story).

#### Cross-App Access (ID-JAG)
an OAuth extension (Okta, 2025; formally the *Identity Assertion Authorization Grant*) for the case where an agent in one application calls a second application on a user's behalf: the client swaps a user-identity assertion at the identity provider for an intermediate **ID-JAG** token that the target app validates before issuing a short-lived, scoped access token, keeping every hop visible to the central IdP. See [Security § Identity Provisioning and Standards](./security.md#identity-provisioning-and-standards).

#### Cross-encoder / reranker
a local model that re-scores a broad, cheaply-retrieved pool of candidate chunks against the query so only the most relevant few are kept before sending them onward. See [RAGs § Dual-Embedding / Hybrid-Embedding architectures](./rags.md#dual-embedding--hybrid-embedding-architectures).

#### Dark Factory (Lights-Off Factory)
a software factory model that removes human code review entirely, relying on automated testing, sandboxing, monitoring, and rollback instead; borrows its name and bet from 1980s "lights-out" manufacturing (GM/FANUC), where robots ran fully unattended. See [SW Factories § Dark Factory](./sw-factories.md#dark-factory).

#### Data-classification routing
a hybrid routing rule that maps each request to a sensitivity tier from the files or repository it touches (path globs, a `CODEOWNERS`-style manifest, a git-remote allow-list) and lets that tier, not the task's difficulty, decide local-only versus cloud-eligible. Governance expressed as routing. See [Hybrid Setups § Data-classification routing](./hybrid-setups.md#data-classification-routing).

#### Daytona
a hosted agent-sandbox runtime ("infrastructure for running AI-generated code"), marketed on sub-90 ms sandbox creation, with stateful snapshots and a declarative image builder; container isolation by default, Kata micro-VMs opt-in. Began as an open-source self-hosted dev-environment manager; that repo is now maintenance-only. See [Local Models § Sandbox primitives: E2B, Daytona, Modal](./local-models.md#sandbox-primitives-e2b-daytona-modal).

#### Decentralized identifier (DID)
a W3C identifier scheme (paired with Verifiable Credentials) proposed as a substrate for agent-to-agent trust across organisations where no shared identity provider spans both parties; each agent controls its own DID and presents third-party credentials. Active research, no production adoption as of late 2026, and — despite the "distributed ledger" association — the common methods (`did:web`, `did:key`) need no blockchain. See [Security § Identity Provisioning and Standards](./security.md#identity-provisioning-and-standards).

#### DeepAgents
LangChain's third-generation, more autonomous agent layer, built on top of LangGraph's explicit graph substrate rather than reverting to chain-style implicit control flow. See [SW Factories § LangChain](./sw-factories.md#from-chains-to-graphs-to-deepagents).

#### Dependency injection (DI)
passing a component its collaborators (via constructor parameters or a composition root) instead of letting it construct them, so a test can substitute a fake. It matters more under agents because agents default to tightly-coupled inline construction and, when testing coupled code, over-mock; enforced as an interface-at-the-boundary rule it restores the seam a real test oracle needs. DI is the means, not the end: the ladder runs from pure functions (nothing to inject) through constructor injection and one-off parameter injection to a DI container last — and the agent-friendly form is explicit constructor injection with a composition root, not a container's implicit annotation-driven wiring. See [Quality § Designing for testability](./quality.md#designing-for-testability).

#### Design by Contract (DbC)
specifying a function's pre-conditions, post-conditions, and invariants as machine-checkable assertions (Bertrand Meyer, for Eiffel; native in Eiffel/Ada/D/Clojure, a library elsewhere — `icontract`, `deal`, JML/OpenJML, Metalama); for an agent this supplies explicit intent it cannot silently drift from and an oracle stronger than tests it wrote itself, and — unlike a spec-driven-development spec — it does not drift, because it *is* code checked on every call. See [Quality § Design by Contract](./quality.md#design-by-contract).

#### Design-to-code
generating frontend code from a visual design. Handing the agent structured design context (the Figma Dev Mode MCP server's component tree, design tokens, and code-component mapping) is materially more reliable than a bare screenshot, which drifts on spacing, colour, and component reuse. See [Basics § Multi Modal Models](./basics.md#relevance-in-agentic-coding).

#### Deterministic tokenization
a data-masking scheme (e.g. Skyflow's LLM Privacy Vault) where each sensitive value is replaced by a format-preserving token with no mathematical relation to the original; the same input always yields the same token, so relationships in the data survive, but the plaintext lives only in the vault and detokenization is access-controlled. Contrast irreversible masking, which cannot be undone at all. See [Security § Privacy Gateways](./security.md#privacy-gateways).

#### Dual-Embedding / Hybrid-Embedding architectures
indexing a knowledge base cheaply up front with a local embedding model, then progressively adding higher-fidelity cloud embeddings over time as content is actually used, keeping the two in separate vector-database partitions and routing each query to the right one. Not an established, industry-recognized term (see the chapter's own Research Note) — "hybrid embedding" more commonly refers to fusing sparse and dense retrieval instead. See [RAGs § Dual-Embedding / Hybrid-Embedding architectures](./rags.md#dual-embedding--hybrid-embedding-architectures).

#### Dual-LLM pattern
a prompt-injection defence (Simon Willison, 2023): a *privileged* LLM that sees only trusted input and holds all tools, a *quarantined* LLM that processes untrusted content and has none, and plain controller code that passes data between them by opaque reference so the privileged model never sees the untrusted text. Constrained and awkward by its author's own account; [CaMeL](#camel-capabilities-for-machine-learning) is its refinement. See [Security § The Dual-LLM Pattern and CaMeL](./security.md#the-dual-llm-pattern-and-camel).

#### Dynamic memory (skills)
a harness component that abstracts a successfully completed task's trajectory into a reusable "skill" file, then retrieves and injects relevant past skills into the system prompt on later runs instead of re-solving the same problem from scratch. See [Agentic Coding Harnesses § Main Components of a Harness](./agentic-coding-harnesses.md#main-components-of-a-harness).

#### E2B ("Environment to Business")
an open-source (Apache-2.0) agent-sandbox runtime that boots one Firecracker micro-VM per sandbox, with Python/JavaScript SDKs (plus Code Interpreter and Desktop variants) and a documented — if substantial — self-hosting path via the `e2b-dev/infra` repo. See [Local Models § Sandbox primitives: E2B, Daytona, Modal](./local-models.md#sandbox-primitives-e2b-daytona-modal).

#### Early fusion / cross-attention fusion
the two dominant ways a [vision encoder](#vision-encoder-vit)'s output is combined with a language model. *Early fusion* splices the projected image vectors into the same token sequence as the text, as [visual tokens](#visual-token) handled by ordinary self-attention (LLaVA, Qwen-VL, Llama 4 — the mainstream 2026 design); *cross-attention fusion* keeps image features outside the sequence and interleaves gated cross-attention layers into an otherwise frozen text model (Flamingo, Llama 3.2 Vision). See [Basics § How they differ from text-only models](./basics.md#how-they-differ-from-text-only-models).

#### Egress allow-list
a default-deny network policy on an agent's workspace that permits outbound connections only to a short list of hosts (the model API, the package registries the build needs, the Git host). The highest-value workspace control because credential and data exfiltration, not kernel escape, is the dominant risk — though a subverted agent can still exfiltrate through the allowed hosts themselves. See [Security § Workspace Containers](./security.md#workspace-containers).

#### Embedding
a fixed-length, learned vector representation of a token (or a chunk of text) that positions it in a high-dimensional space so that semantically similar items end up with similar vectors. See [Basics § Key-Value store](./basics.md#key-value-store).

#### Excessive agency
OWASP LLM06: giving an agent more permissions, autonomy, or tools than its task needs, widening the damage a prompt injection or model error can cause. See [Local Models § Prompt injection and excessive agency](./local-models.md#prompt-injection-and-excessive-agency).

#### Expert offloading
running a Mixture-of-Experts model larger than VRAM by keeping attention, the KV cache, the router and the shared experts on the GPU while pushing the routed-expert FFN weights to CPU RAM (e.g. llama.cpp's `--n-cpu-moe`, KTransformers); effective because routed experts fire rarely but are the bulk of the parameters. See [Local Models § Mixture of Experts Modells](./local-models.md#mixture-of-experts-modells).

#### Feature flag (progressive delivery)
a runtime switch that decouples deploy from release, so agent-generated code can be merged continuously while exposure is ramped 1% → 5% → 25% → 100% with automatic rollback on regression; bounds the blast radius of an under-reviewed change to the rollout percentage. See [Quality § Feature flags and progressive delivery as a throughput safety net](./quality.md#feature-flags-and-progressive-delivery-as-a-throughput-safety-net).

#### Fill-in-the-middle (FIM)
a code-completion prompt format that gives the model the text before *and* after the cursor and asks it to fill the gap, as opposed to left-to-right continuation; the format inline autocomplete assistants use. See [Local Models § Models](./local-models.md#models).

#### Firecracker
AWS's minimalist Rust KVM virtual-machine monitor (NSDI '20), which boots a micro-VM to application code in under 125 ms with under 5 MiB of overhead by emulating only ~5 devices and skipping the BIOS/firmware handshake. Powers AWS Lambda and Fargate; the isolation boundary behind E2B, Vercel Sandbox and Fly.io. See [Local Models § Agent sandboxing](./local-models.md#agent-sandboxing).

#### Full Human Review
a software factory model where an AI agent replaces the human builder but every line of generated code is still read by a human before merge; a bounded productivity gain because review remains the bottleneck. See [SW Factories § Full Human Review](./sw-factories.md#full-human-review).

#### Fuzzing (fuzz testing)
generating a large, mutated, coverage-guided stream of inputs and checking an implicit oracle (the program must not crash, hang, or trip a sanitizer); the same "generate inputs, check an oracle nobody hand-wrote" idea as property-based testing, differing in degree (byte-stream mutation and an implicit oracle vs typed generators and an explicit invariant) — the two have largely converged (Google FuzzTest, HypoFuzz, native Go/Rust fuzzing). Belongs wherever code parses untrusted input; in an agentic workflow the agent drafts the harness, and the risk is a harness that exercises nothing. See [Quality § Fuzzing](./quality.md#fuzzing).

#### Generation Pattern (MCP → CLI)
building the MCP server first and auto-generating a human-facing CLI from its typed tool schemas (e.g. via `fastmcp generate-cli`), so `--help`, validation, and autocomplete all derive from one source of truth instead of drifting between a hand-written CLI and a hand-written MCP server. See [Agentic Coding Harnesses § Human-vs-Machine Developer Experience](./agentic-coding-harnesses.md#human-vs-machine-developer-experience).

#### GGUF (GGML Universal Format)
llama.cpp's single-file model container holding weights, tokenizer, chat template and quantization metadata in one memory-mappable blob; the format llama.cpp, Ollama and LM Studio consume. Contrast `safetensors`, which the original model labs publish and GPU engines consume. See [Local Models § Local inference engines](./local-models.md#local-inference-engines).

#### Grouped-Query Attention (GQA)
an attention variant where several Query heads share one Key/Value pair instead of each head having its own, shrinking the KV cache 4–8x for a small quality cost. See [Basics § Key-Value store](./basics.md#key-value-store).

#### gVisor
Google's application kernel: a user-space process that intercepts a sandboxed workload's syscalls and services most of them itself, so only a small allow-listed set reaches the host kernel. No hardware virtualization required and no CPU-operation cost, but a structural per-syscall overhead; the common "stronger than a container, cheaper than a micro-VM" middle rung (`runsc` + a Kubernetes `RuntimeClass`). Used by Modal Sandboxes and Google Cloud Run. See [Local Models § Agent sandboxing](./local-models.md#agent-sandboxing).

#### Harness
the orchestration layer around an LLM (system prompt, tool definitions, and the loop deciding when to call the model and what to do with its output) that turns a raw model into an agent capable of taking actions. See [Basics § Harnesses](./basics.md#harnesses).

#### Hugging Face
the dominant hosting platform for open-weight models ("GitHub for models"): each model is a versioned repository with a model card (license, architecture, benchmarks, chat template), and a community ecosystem re-publishes quantized conversions of each release. Local inference engines download weights from it directly or through a wrapper. See [Local Models § Local inference engines](./local-models.md#local-inference-engines) and [§ Models](./local-models.md#models).

#### Human-in-the-loop approval gate
a required human decision inserted before an agent action that is irreversible or leaves the perimeter — merge, deploy, publish, send, spend. Complements role-based limits: the agent may propose such an action but cannot commit it alone. See [Security § Zero-Trust for AI Agents](./security.md#zero-trust-for-ai-agents).

#### Hybrid attention
a transformer that mixes cheap linear-attention layers (a fixed-size recurrent state, e.g. Gated DeltaNet) with a minority of full-attention layers, so only that minority grows a [KV cache](./basics.md#key-value-store) with context. Cuts KV-cache growth several-fold, which makes long-context local agent loops affordable on a consumer GPU. Used by Qwen3-Next and the Qwen3.5/3.8 series. See [Local Models § Models](./local-models.md#models).

#### Hybrid setup
an agentic-coding configuration that uses a local model for the high-volume, latency-sensitive, or confidential work and a cloud frontier model for the work that genuinely needs it, with a routing layer deciding which requests go where and a governance layer deciding which are allowed to leave the machine. See [Hybrid Setups](./hybrid-setups.md).

#### Image tiling (AnyRes / pan-and-scan)
feeding a high-resolution image to a fixed-input [vision encoder](#vision-encoder-vit) by splitting it into a grid of native-resolution tiles (plus a downscaled overview), or adaptively cropping it into windows. Each tile adds [visual tokens](#visual-token), so resolution trades directly against context cost. See [Basics § How they differ from text-only models](./basics.md#how-they-differ-from-text-only-models).

#### Image-based prompt injection
[prompt injection](#prompt-injection) carried through the visual channel — instructions hidden in a screenshot, rendered web page, or PDF that the model's vision pathway recovers and then treats as prompt text. Harder to sanitize than text because what the model will read is not easily previewed. See [Basics § Capabilities and limitations](./basics.md#capabilities-and-limitations).

#### Indirect prompt injection
[prompt injection](#prompt-injection) where the malicious instruction is not typed by the user but arrives inside content the agent ingests while working — a dependency README, a GitHub issue or PR comment, a docstring, CI logs, a fetched web page, a rules file in a cloned repo, or an MCP tool's description. The dominant attack surface for autonomous coding agents. See [Security § Handling Prompt Injection](./security.md#handling-prompt-injection).

#### Inference engine
the software that loads model weights, manages the KV cache and runs the token-generation loop, exposing an API (usually OpenAI-compatible) for a harness to call; llama.cpp, Ollama and vLLM are the main choices for local use. See [Local Models § Local inference engines](./local-models.md#local-inference-engines).

#### Inner harness
the core runtime loop built directly into an agent tool and shipped by its AI vendor (tool execution, sandboxing, the ReAct loop); low to no modifiability for the end user. See [Agentic Coding Harnesses § Inner harness vs. outer harness](./agentic-coding-harnesses.md#inner-harness-vs-outer-harness).

#### Intent Thinking
the human competency BCG Platinion pairs with harness engineering in an agentic software factory: translating business needs into precise, testable descriptions of desired outcomes, since humans no longer write or review the code itself. See [SW Factories § Agentic SW Factories](./sw-factories.md#agentic-sw-factories).

#### Jailbreaking
getting a model to violate its own safety training. Distinct from [prompt injection](#prompt-injection), which is getting a model to disregard the *developer's* instructions in favour of instructions in untrusted data — a coding agent can be perfectly aligned and still be prompt-injected. See [Security § Handling Prompt Injection](./security.md#handling-prompt-injection).

#### Just-in-time (JIT) context sourcing
keeping only lightweight references (file paths, symbol structures) in context and reading or greping specific files/lines only when a step actually needs them, instead of loading an entire codebase up front. See [Basics § multi-turn loops and Loop engineering](./basics.md#multi-turn-loops-and-loop-engineering).

#### Just-in-time (JIT) privilege elevation
running an agent on a minimal standing permission set and granting a scoped, time-boxed elevation only when a specific task needs it, approved by a human or a policy; keeps the baseline blast radius small without blocking legitimate work. See [Security § Role Management and Access Control](./security.md#role-management-and-access-control).

#### Kata Containers
an OCI-compatible container runtime that transparently boots a lightweight KVM virtual machine (with its own guest kernel) per pod, at roughly 50–100 ms boot and 100–200 MiB overhead; VMM backends include QEMU, Firecracker and Cloud Hypervisor. Daytona's opt-in stronger-isolation mode. See [Local Models § Agent sandboxing](./local-models.md#agent-sandboxing).

#### K-quant / i-quant
llama.cpp's two families of GGUF weight quantization: K-quants (`Q2_K`–`Q6_K`, with `_S`/`_M`/`_L` mixes) spend more bits on the tensors that matter most; i-quants (`IQ1`–`IQ4`) use codebook quantization for very low bit rates but need an importance matrix to hold quality. `Q4_K_M` and `Q5_K_M` are the common sweet spots. See [Local Models § Quantization](./local-models.md#quantization).

#### KV cache (Key-Value cache / token cache)
the store of previously computed Key and Value vectors for already-processed tokens, kept in GPU memory to avoid recomputing them on every new token. See [Basics § Key-Value store](./basics.md#key-value-store).

#### KV cache quantization
compressing cached Key/Value values from FP16 down to lower-precision integer (INT8/INT4) or floating-point (FP8/FP4) formats to cut KV cache memory use. See [Basics § Memory: the practical limit on context length](./basics.md#memory-the-practical-limit-on-context-length).

#### Langfuse
an open-source LLM tracing and telemetry platform; connected to a gateway like LiteLLM, it ingests prompt and token metadata per call, tagging each trace with a cost and a client/thread identifier for a queryable financial ledger. Moved all product features to MIT in June 2025; acquired by ClickHouse, Inc. in January 2026. See [SW Factories § Agentic Business Workflows](./sw-factories.md#agentic-business-workflows) and [Local Models § LiteLLM + Langfuse](./local-models.md#litellm--langfuse).

#### LangGraph
LangChain's lower-level orchestration library that models an agent's control flow as an explicit graph of nodes and edges over shared state, supporting cycles, conditional routing, and durable checkpointing. See [SW Factories § LangChain](./sw-factories.md#from-chains-to-graphs-to-deepagents).

#### Language Server Protocol (LSP)
a protocol (originally for editor autocomplete/navigation) that a harness's tool registry can query for deterministic, semantic code intelligence — exact symbol definitions, references, safe renames, and diagnostics — instead of guessing from grepped text. See [Agentic Coding Harnesses § Main Components of a Harness](./agentic-coding-harnesses.md#main-components-of-a-harness).

#### Lethal trifecta
Simon Willison's name for the three capabilities that together make an agent exploitable for data theft: access to private data, exposure to untrusted content, and a way to communicate outward. Removing any one leg breaks the exfiltration path; coding agents routinely hold all three at once. See [Security § Why it cannot simply be prevented](./security.md#why-it-cannot-simply-be-prevented).

#### Leverage-Point Model
a software factory model that retains full human review but compresses and front-loads it via a staged pre-planning process (e.g. product → architecture → program design → vertical slices, each gated by explicit human sign-off), so review becomes fast confirmation of already-agreed decisions rather than open-ended discovery. See [SW Factories § Leverage-Point Model](./sw-factories.md#leverage-point-model).

#### LiteLLM
an open-source LLM gateway that sits between agents and model providers, issuing per-tenant virtual API keys with hard budget caps and rate limits and routing each call onward to a self-hosted or cloud model; ships as both a Python SDK and a standalone proxy server, with a native Langfuse tracing callback. MIT core, paid Enterprise tier. See [SW Factories § Agentic Business Workflows](./sw-factories.md#agentic-business-workflows) and [Local Models § LiteLLM + Langfuse](./local-models.md#litellm--langfuse).

#### llama.cpp
a C/C++ inference engine built on the `ggml` tensor library; the reference engine for local, resource-constrained inference, using the GGUF format, wide hardware backend support, and CPU+GPU hybrid layer offload. See [Local Models § llama.cpp](./local-models.md#llamacpp).

#### LLM firewall (AI gateway / semantic firewall)
a layer that inspects model inputs and outputs for prompt injection, jailbreaks, PII, and unsafe content — inline and blocking, or alongside and monitoring. Detection is deterministic (regex/signatures, fast but evadable) or a small classifier model (catches novel phrasings, but has a false-positive rate and can be out-computed by the target model). Defense-in-depth, not a solution. Examples: NeMo Guardrails, LLM Guard, LlamaFirewall, Cloudflare Firewall for AI. See [Security § LLM Firewalls](./security.md#llm-firewalls).

#### LLM pipeline
a structured, repeatable sequence of operations (input processing, retrieval, model calls, validation, etc.) that turns raw input into a production-ready output, as opposed to a single isolated prompt. See [RAGs § LLM pipelines](./rags.md#llm-pipelines).

#### LM Studio
a proprietary, closed-source desktop application for running open-weight models locally, bundling llama.cpp and Apple MLX engines behind a GUI plus a local server that speaks both the OpenAI and Anthropic wire formats; an MCP host since v0.3.17. Free for personal and (since July 2025) commercial use. See [Local Models § LM-Studio](./local-models.md#lm-studio).

#### LMArena (Chatbot Arena)
a crowdsourced human-preference leaderboard (lmarena.ai, now redirecting to arena.ai; formerly LMSYS Chatbot Arena) where users vote between two anonymous model responses; models are ranked by a Bradley-Terry model with optional style control. Sub-arenas include WebDev Arena and Copilot Arena. Strong signal for real-world helpfulness, weak for code correctness. See [Local Models § Benchmarks](./local-models.md#benchmarks).

#### Local preprocessing, cloud generation
a hybrid pattern that runs the cheap, high-volume grunt work of an agent loop (embedding a codebase, summarizing files, compacting state, subagent passes that return condensed results) on a local model, and calls the cloud only for the final generation step, keeping the communication tax off the metered API. See [Hybrid Setups § Local preprocessing, cloud generation](./hybrid-setups.md#local-preprocessing-cloud-generation).

#### Maintainability sensors
deterministic checks (type-checking, linting with custom messages, Semgrep, layered-architecture rules, coverage, mutation testing) plus inferential LLM reviews, packaged into a sidecar an agent queries before yielding and a human reads as a dashboard; Birgitta Böckeler's framing for wiring structural-quality feedback into the agent loop. See [Quality § Static analysis and linters as the agent's first gate](./quality.md#static-analysis-and-linters-as-the-agents-first-gate).

#### MCP translation layer (bridge / gateway)
a proxy that discovers an existing service's own interface definition (a `.proto` file, a GraphQL schema, an OpenAPI spec) and dynamically exposes it as MCP tools, so the backend doesn't need to be rewritten to become agent-accessible; often served over both stdio (local) and HTTP/SSE (cloud) from the same code. See [Agentic Coding Harnesses § MCP Translation Layers for Webservices](./agentic-coding-harnesses.md#mcp-translation-layers-for-webservices).

#### Memory-bandwidth bound
the property that makes LLM token generation limited by how fast weights can be streamed from memory rather than by processor speed; token throughput ≈ (usable memory bandwidth) ÷ (active-weight bytes per token). Explains why VRAM bandwidth beats FLOPS, why CPU inference is slow, and why quantization speeds generation up. See [Local Models § Hardware](./local-models.md#hardware).

#### Merge queue
a CI mechanism (GitHub's built-in one, Graphite, Mergify, Trunk) that serializes merges and tests each change against an up-to-date base before fast-forwarding; matters more under agents because many agent PRs on the same base produce semantic conflicts that each pass in isolation. See [Quality § CI/CD as the enforcement layer](./quality.md#cicd-as-the-enforcement-layer).

#### micro-VM
a lightweight virtual machine with a minimal emulated-device model and fast boot (tens to ~125 ms), giving each workload its own guest kernel behind a hardware (KVM/VT-x) boundary; the strongest per-agent sandbox rung. Implementations: Firecracker, Cloud Hypervisor, libkrun, and the Kata Containers runtime. See [Local Models § Agent sandboxing](./local-models.md#agent-sandboxing).

#### Mixture-of-Experts (MoE)
a transformer where each feed-forward block is replaced by many parallel expert FFNs plus a router that activates only the top-k per token; the model occupies memory for *all* parameters but spends bandwidth and compute on only the *active* ones, which makes it ideal for large, slow memory (unified-memory machines, CPU+RAM). See [Local Models § Mixture of Experts Modells](./local-models.md#mixture-of-experts-modells).

#### MLX
Apple's array/ML framework with a unified-memory model; its `mlx-lm` and `mlx-vlm` libraries run LLMs and vision-language models faster than llama.cpp's Metal backend on Apple Silicon, and are bundled as an engine in Ollama and LM Studio. See [Local Models § Apple Metal](./local-models.md#apple-metal).

#### `mmproj` / libmtmd
llama.cpp's multimodal path: `libmtmd` handles image and audio input, and an `mmproj-*.gguf` file (the vision encoder plus projector, loaded alongside the language-model GGUF) is what gives a local model vision. The vision encoder is quantization-sensitive and should stay at FP16 or 8-bit. See [Local Models § Multi Modal Modells](./local-models.md#multi-modal-modells).

#### Modal Sandboxes
the sandbox primitive inside Modal's general-purpose serverless platform: gVisor-isolated "secure containers for executing untrusted user or agent code," driven by `Sandbox.create()` / `exec()`, with filesystem snapshots (30-day TTL) and experimental full-memory snapshots (7-day TTL), GPU support, and no self-hosted option. See [Local Models § Sandbox primitives: E2B, Daytona, Modal](./local-models.md#sandbox-primitives-e2b-daytona-modal).

#### Model Connector (Gateway Layer)
the harness building block that translates the harness's internal state into a specific LLM provider's API format, enabling API translation, fallback to a secondary provider, and prompt/tool-call format normalization; distinct from the LLM provider itself, which sits outside the harness. See [Agentic Coding Harnesses § Main Components of a Harness](./agentic-coding-harnesses.md#main-components-of-a-harness).

#### Model Context Protocol (MCP)
an open standard, client-server protocol (JSON-RPC 2.0) for connecting an LLM host application to external tools, resources, and prompts through one uniform interface instead of bespoke per-harness integration code. See [Agentic Coding Harnesses § What is MCP](./agentic-coding-harnesses.md#what-is-mcp).

#### Model routing / model cascades
sending each agent call to the cheapest model capable of handling it, escalating to a frontier model only when a cheaper one fails or the task demands it, rather than routing every call to the same model regardless of difficulty. See [SW Factories § Make it fast/cheap](./sw-factories.md#make-it-fastcheap) and [Hybrid Setups § Routing patterns](./hybrid-setups.md#routing-patterns).

#### Multi-Token Prediction (MTP)
a model architecture with extra lightweight heads that predict several future tokens per forward pass, used both as a training signal (densifies the loss) and, at inference, as self-speculative decoding with no separate draft model to load. Only models pre-trained with MTP heads (DeepSeek-V3/V4, Qwen3-Next+, GLM-4.5-Air) benefit. See [Local Models § Multi Token Prediction](./local-models.md#multi-token-prediction).

#### Multimodal model (MLLM)
a transformer-based model that accepts input in more than one modality (usually text plus images) and/or produces more than one; the [vision-language model](#vision-language-model-vlm) is the dominant sub-type, and "omni" / "any-to-any" models additionally take audio and video and can emit images or speech. See [Basics § Multi Modal Models](./basics.md#multi-modal-models).

#### Mutation testing
introducing small deliberate faults ("mutants") into source code; a test suite that stays green under a mutant is not actually verifying that behaviour. Tools: Stryker (JS/TS), PIT (Java), `mutmut` (Python), `cargo-mutants` (Rust). The historical bottleneck — interpreting the report — is work an agent can now do, making it the practical defense against high-coverage/weak-assertion agent-written tests. See [Quality § Mutation testing and property-based testing as defenses](./quality.md#mutation-testing-and-property-based-testing-as-defenses).

#### Non-human identity (NHI)
the category term for a login that is not a person — service accounts, CI runners, workload identities, bots, and AI agents. NHIs outnumber human identities in most organisations (vendor estimates vary from ~45:1 to >80:1), and an agent given its own NHI gets attributable actions, independently scoped permissions, independent revocation, and a managed lifecycle. See [Security § Agent Identity](./security.md#agent-identity).

#### NVLink / NVSwitch
NVIDIA's GPU-to-GPU interconnect (900 GB/s on Hopper, 1.8 TB/s per GPU on Blackwell, far above PCIe) and the switch fabric that connects many GPUs all-to-all; what makes tensor-parallel serving of a model too large for one GPU practical. See [Local Models § Datacenter GPU Stacks](./local-models.md#datacenter-gpu-stacks).

#### Ollama
an MIT-licensed local-model runner wrapping a `ggml`-based engine behind a Docker-like CLI, a container-style model registry, an OpenAI-compatible API, and automatic GPU/CPU split and idle-model unloading. See [Local Models § Ollama](./local-models.md#ollama).

#### On-behalf-of token (delegated authority)
a request credential that names both the agent (a stable non-human identity) and the human principal who invoked it, so the resource server can authorise the action as the **intersection** of the two parties' permissions rather than their union — closing the confused-deputy path where an agent acts with more authority than its user. See [Security § Agent Identity](./security.md#agent-identity).

#### Open WebUI
a self-hosted, ChatGPT-style web frontend that ships no models of its own and connects to Ollama or any OpenAI-compatible backend; a chat and admin surface, not a coding agent. Licensed BSD-3-Clause plus a branding-protection clause (removable only for deployments of ≤50 users). See [Local Models § Open-WebUI](./local-models.md#open-webui).

#### OpenRouter
a cloud aggregation API exposing 500+ models behind one OpenAI-compatible (and Anthropic-compatible) endpoint with automatic provider routing and failover; no markup on inference, a percentage fee on credit purchases, and per-request privacy controls including `zdr: true`. See [Local Models § Open Router](./local-models.md#open-router).

#### OpenTelemetry GenAI semantic conventions
the OpenTelemetry standard for agent/LLM telemetry: typed spans for agent invocations, model generations, tool calls, and guardrail checks, with prompt and response **content capture as a separate opt-in mechanism** (structured log events correlated to the span) so it can be filtered or dropped at the collector without changing application code. See [Security § Audit Logs](./security.md#audit-logs).

#### Oracle (test oracle)
the mechanism that decides whether a test's observed result is correct: a hard-coded expected value, a stated invariant (property-based testing), an implicit "must not crash" (fuzzing), a machine-checkable contract, or a reference implementation (differential testing). In agentic coding a strong oracle is one the agent cannot make pass by editing it to match the code (contrast the *test oracle problem* entry below). See [Quality § The oracle problem](./quality.md#the-oracle-problem).

#### Outer harness
the architectural layer of guardrails and context an engineering team builds on top of an inner harness (guides like `CLAUDE.md`, quality gates, infrastructure ops) to make it follow the organization's standards; highly customizable. See [Agentic Coding Harnesses § Inner harness vs. outer harness](./agentic-coding-harnesses.md#inner-harness-vs-outer-harness).

#### PagedAttention
vLLM's technique for storing a request's KV cache in small, non-contiguous, fixed-size blocks (like OS virtual memory pages) instead of one large pre-allocated block, cutting GPU memory waste. See [Basics § PagedAttention (vLLM)](./basics.md#pagedattention-vllm).

#### pass@1 / resolved rate
benchmark scoring where the model gets one attempt per task and the score is the fraction that pass (for code-completion benchmarks: the generated code passes the tests; for SWE-bench-style benchmarks: the patch makes the failing tests pass without regressing the others). See [Local Models § Benchmarks](./local-models.md#benchmarks).

#### PII redaction (data masking)
detecting personal data, secrets, and internal identifiers in a prompt and replacing them with placeholders before the prompt reaches a cloud model — reversibly (keep a placeholder-to-value map for rehydration) or irreversibly. Tools: Microsoft Presidio, LLM Guard's Anonymize scanner. The detector's sub-100% recall and the reasoning damage from over-redaction are the main limits. See [Security § Privacy Gateways](./security.md#privacy-gateways).

#### Pipeline as code
writing a CI/CD pipeline as a real program (a typed SDK such as Dagger, or a statically-typed DSL such as TeamCity's Kotlin DSL) instead of YAML. For an agent this means the pipeline runs identically in its local sandbox and in CI (so a CI failure can be reproduced and fixed without a push), and pipeline edits get compile-time type feedback in the same inner loop as application code. See [Quality § Pipelines as code, not YAML](./quality.md#pipelines-as-code-not-yaml).

#### Policy Decision Point / Policy Enforcement Point (PDP/PEP)
the split that keeps authorization out of agent-written code: the runtime (PEP) intercepts every proposed tool call and asks a separate policy engine (PDP — Cedar, OPA, or OpenFGA) for an allow/deny, passing the agent, the action, and the resource. See [Security § Role Management and Access Control](./security.md#role-management-and-access-control).

#### Prefix matching
the requirement that a cloud provider's prompt cache only hits if the request text is 100% identical, character-for-character, from the very start. See [Basics § Prompt caching](./basics.md#prompt-caching---efficient-cloud-model-integration).

#### Privacy gateway
a proxy between an agent (or developer) and a cloud model that detects and strips sensitive data from a request before it leaves the perimeter — via [PII redaction](#pii-redaction-data-masking), [deterministic tokenization](#deterministic-tokenization), or secret scanning — and optionally rehydrates the response. Its complement is the contractual control, [Zero Data Retention](#zero-data-retention-zdr). See [Security § Privacy Gateways](./security.md#privacy-gateways).

#### Projector (multimodal connector)
the small trained module — a linear layer, a two-layer MLP, or a cross-attention resampler — that maps a [vision encoder](#vision-encoder-vit)'s output vectors into the language model's embedding space. In llama.cpp the `mmproj` file is the vision encoder plus this projector. See [Basics § How they differ from text-only models](./basics.md#how-they-differ-from-text-only-models).

#### Property-based testing
stating invariants a function must satisfy (e.g. in Hypothesis, fast-check, jqwik, proptest) and letting the framework generate adversarial inputs, rather than writing example-based cases; gives an agent an oracle it cannot overfit to one implementation because the property is defined independently of the code. See [Quality § Mutation testing and property-based testing as defenses](./quality.md#mutation-testing-and-property-based-testing-as-defenses).

#### Prompt caching (context / prefix caching)
reusing a cloud provider's already-computed KV cache for a repeated text prefix instead of recomputing it, without ever transmitting the raw KV cache itself. See [Basics § Prompt caching](./basics.md#prompt-caching---efficient-cloud-model-integration).

#### Prompt injection
OWASP LLM01: because an LLM processes instructions and data in the same channel, untrusted content (a web page, a file, an issue comment, a dependency README) can carry instructions the model obeys. Sharper with a local model, which has no provider-side safety filter between the injected instruction and the agent's shell. See [Local Models § Prompt injection and excessive agency](./local-models.md#prompt-injection-and-excessive-agency).

#### Quality gate
a pass/fail set of conditions applied to a change (no new vulnerabilities, coverage on new code above a threshold, duplication below one); SonarQube's "AI Code Assurance" adds a stricter gate ("Sonar way for AI Code") applied specifically to PRs labelled as containing AI-generated code. See [Quality § Quality gates for AI code](./quality.md#quality-gates-for-ai-code).

#### Quantization (weight quantization)
storing each model parameter in fewer bits than its trained precision (BF16 = 16 bits), dequantizing per-block on the fly; roughly linear memory savings that also speed up generation. At ≥4 bits quality loss is near-negligible for most tasks; below 3 bits dense models degrade fast. Formats include GGUF K-quants, AWQ, GPTQ, NF4, FP8 and MXFP4. See [Local Models § Quantization](./local-models.md#quantization).

#### ReAct loop (Reason, Act, Observe)
the iterative pattern a harness's control loop drives: the agent reasons about its current state and plans, acts by invoking a tool, then observes the result and updates its strategy before repeating. See [Agentic Coding Harnesses § Main Components of a Harness](./agentic-coding-harnesses.md#main-components-of-a-harness).

#### Reciprocal Rank Fusion (RRF)
an algorithm that merges two separately ranked retrieval result lists (e.g. from a local and a cloud embedding search) into one combined ranking based on rank position rather than raw similarity scores. See [RAGs § Dual-Embedding / Hybrid-Embedding architectures](./rags.md#dual-embedding--hybrid-embedding-architectures).

#### Relationship-based access control (ReBAC)
the Google Zanzibar authorization model (implemented by OpenFGA) in which access is derived from a graph of relationships — `user → agent`, `agent → repo`, `agent → tool` — rather than from static roles; used for agents to constrain, for example, a retrieval agent to exactly the documents authorised for the current session. See [Security § Role Management and Access Control](./security.md#role-management-and-access-control).

#### Retrieval-Augmented Generation (RAG)
fetching relevant text chunks from an external knowledge base and injecting them into the prompt as context, instead of relying only on what the model learned during training. See [RAGs § Context management](./rags.md#context-management).

#### Reward hacking (benchmark gaming)
when a model exploits weaknesses in a benchmark's test oracle (e.g. a weak test suite, or retrievable reference solutions in git history) to score well without actually solving the underlying task; measurably more prevalent after RL post-training. See [SW Factories § Why Not Just a Bigger Agent?](./sw-factories.md#why-not-just-a-bigger-agent) and [Local Models § Benchmarks](./local-models.md#benchmarks).

#### ROCm (Radeon Open Compute)
AMD's GPU-compute stack, the CUDA equivalent; Linux-first, with an officially supported consumer-GPU list shorter than NVIDIA's and new model architectures landing on CUDA first. See [Local Models § AMD + ROCm](./local-models.md#amd--rocm).

#### Router (Mixture-of-Experts)
the small gating network in a Mixture-of-Experts layer that, per token, selects which top-k experts to run and how to weight their outputs. See [Local Models § Mixture of Experts Modells](./local-models.md#mixture-of-experts-modells).

#### Sanitizer (ASan / UBSan / TSan / MSan)
compiler instrumentation that turns latent undefined behaviour in C/C++ into an immediate, located crash when a test exercises it: AddressSanitizer (buffer overflow, use-after-free, leaks), UndefinedBehaviorSanitizer (signed overflow, bad shifts, null deref), ThreadSanitizer (data races), MemorySanitizer (uninitialised reads). The agentic pattern is to run the test suite under `-fsanitize=address,undefined` as a gate before the agent yields, since a plain compile and green tests certify little in a language with no memory-safety net. See [Quality § C and C++](./quality.md#c-and-c-why-the-row-isnt-the-whole-story).

#### SAST / DAST / SCA
the three automated security-testing families: static analysis of source (SAST, e.g. Semgrep, CodeQL), dynamic testing of the running app (DAST, e.g. OWASP ZAP), and software-composition analysis of dependencies (SCA, e.g. Snyk, `pip-audit`, `cargo audit`). In agentic workflows these move from periodic scans to in-loop gates, because agents pull in more dependencies and re-introduce known vulnerability patterns. See [Quality § Non-functional testing](./quality.md#non-functional-testing).

#### SCIM (System for Cross-domain Identity Management)
the REST protocol (RFC 7643/7644) an identity provider uses to create, update, and delete accounts in downstream applications automatically as people join, move, and leave. An IETF Internet-Draft (`draft-abbey-scim-agent-extension`, 2025) would add `Agent` and `AgenticApplication` resource types — under working-group consolidation, not yet a standard. See [Security § Identity Provisioning and Standards](./security.md#identity-provisioning-and-standards).

#### SDLC (Software Development Life Cycle)
the sequence of stages a piece of software moves through from conception to retirement — typically planning, coding, testing, review, deployment, and monitoring; the axis this chapter's "agentic" vs. "pre-agentic" distinction turns on (whether agents or humans execute these stages). See [SW Factories § Agentic SW Factories](./sw-factories.md#agentic-sw-factories).

#### Seam (testable seam)
a place in the code where a collaborator can be substituted without editing the code under test (Feathers's term). Without one, a test can only observe the real world — or patch the module, which produces assertions about call structure rather than behaviour. Creating seams at the process boundaries (network, database, filesystem, clock, third-party SDK) is the structural precondition for every stronger oracle: mutation testing, property-based testing, and in-process fuzzing all need something they can drive deterministically. See [Quality § Designing for testability](./quality.md#designing-for-testability).

#### Self-attention
the mechanism by which a model computes, for each token, how strongly it relates to every other token in the sequence via Query/Key/Value vectors, producing a context-aware representation. See [Basics § Key-Value store](./basics.md#key-value-store).

#### Self-healing tests
end-to-end tests that, on failure, have an agent replay the failing steps, inspect the current UI for equivalent elements, and propose locator or timing patches, re-running until green (e.g. Playwright's Healer agent). Reduces flaky-locator maintenance, but an over-eager healer can "heal" a test into passing against a genuine regression, so its edits belong under human review. See [Quality § Integration and end-to-end testing with a browser in the loop](./quality.md#integration-and-end-to-end-testing-with-a-browser-in-the-loop).

#### Silent leakage
the defining risk of a hybrid setup: a fallback rule, a misconfigured router, or an unexamined default that sends confidential code to a cloud provider without anyone intending it. Countered with cloud-eligibility allow-lists, disabled blind fallbacks on sensitive routes, enforced ZDR/in-region routing, network egress filtering, and per-call audit. See [Hybrid Setups § Governance in hybrid setups](./hybrid-setups.md#governance-in-hybrid-setups).

#### Sliding-window (streaming) attention
only keeping a moving window of the most recent N tokens in the KV cache, permanently capping cache size regardless of how long a conversation runs. See [Basics § Memory: the practical limit on context length](./basics.md#memory-the-practical-limit-on-context-length).

#### Spec-driven development (SDD)
an agentic workflow in which a written, versioned specification (requirements, design, task breakdown — as in GitHub Spec Kit, AWS Kiro, or OpenSpec) is the source of truth the agent generates and is checked against, rather than requirements living only in chat history. Operates at feature/change granularity, complementary to the function-level Design by Contract; its characteristic failure mode is specification drift (next entry). See [Quality § Spec-driven generation](./quality.md#spec-driven-generation).

#### Specification drift (spec-code drift)
the silent divergence of a written spec from the code generated against it, as bug fixes and iterative prompts update the code but not the prose spec; its acute form is the "two specs" problem, where an agent reading a stale spec next to live code "averages across competing sources of truth." Countered by executable specs, a CI "drift gate" that blocks merges on divergence, and shrinking the spec once interfaces and tests are real. See [Quality § Specification drift: the daily-use problem](./quality.md#specification-drift-the-daily-use-problem).

#### Speculative decoding
generating tokens faster by having a cheap drafter (a small separate model, or built-in MTP/Medusa/EAGLE heads) propose several next tokens that the full model then verifies in one batched forward pass, emitting the accepted ones for free. See [Local Models § llama.cpp](./local-models.md#llamacpp) and [§ Multi Token Prediction](./local-models.md#multi-token-prediction).

#### SPIFFE / SPIRE
a CNCF-graduated standard (SPIFFE) and reference implementation (SPIRE) that give each workload a short-lived cryptographic identity (an **SVID**, X.509 or JWT) issued only after *attestation* of properties like the Kubernetes namespace, service account, and container image — binding identity to what the workload is and where it runs instead of to a shared secret. Proposed as a foundation for secret-less agent-to-agent authentication. See [Security § Identity Provisioning and Standards](./security.md#identity-provisioning-and-standards).

#### Spotlighting (delimiting / datamarking / encoding)
Microsoft's family of prompt-level techniques (2024) for keeping a model aware of which span of a prompt is untrusted data: wrapping it in a randomised marker, interleaving a marker token between every word, or encoding it (Base64/ROT13). Strong reported numbers, but only on 2023-era models, and encoding is self-undermining. A cheap speed bump, not a boundary. See [Security § Spotlighting and Content Delimiters](./security.md#spotlighting-and-content-delimiters).

#### Standardized Retrieval Plugin Architecture
a pattern (pioneered by OpenAI's now-deprecated ChatGPT Retrieval Plugin) that wraps a local vector database in fixed `/query`, `/upsert`, and `/delete` HTTP endpoints, letting any cloud LLM treat it as a native memory bank without custom per-project integration code. See [RAGs § Standardized Retrieval Plugin Architecture](./rags.md#standardized-retrieval-plugin-architecture).

#### Style control
a regression extension to LMArena's Bradley-Terry ranking that adds response-style covariates (length, markdown density) so a model cannot climb the leaderboard by writing longer, more heavily formatted answers rather than better ones. See [Local Models § Benchmarks](./local-models.md#benchmarks).

#### Subagent delegation
a high-level orchestrator narrows scope and spawns focused subagents that each see only a narrow slice of code, reporting back a compressed result instead of their full working context to cap the communication tax. See [Basics § multi-turn loops and Loop engineering](./basics.md#multi-turn-loops-and-loop-engineering).

#### SWE-bench / SWE-bench Verified / SWE-bench Pro
the standard "resolve a real GitHub issue" benchmark: given a repo state and an issue, produce a patch that makes the hidden failing tests pass. *Verified* is a 500-task human-filtered Python subset (OpenAI, 2024) and the de-facto headline agentic-coding number; *Pro* (Scale AI) adds longer-horizon tasks and held-out/commercial repos to resist contamination. See [Local Models § Benchmarks](./local-models.md#benchmarks).

#### SYCL / oneAPI
Intel's open, Khronos-standard GPU-compute programming model (SYCL) and its surrounding toolkit (oneAPI); the backend llama.cpp uses for Intel Arc GPUs and integrated graphics. The smallest and least mature of the four vendor stacks. See [Local Models § Intel + SYCL](./local-models.md#intel--sycl).

#### Task-tier routing
a hybrid routing pattern that splits requests by *kind* rather than difficulty: high-volume, low-stakes calls (inline completion, commit messages, chat titles, one-line edits, the `ANTHROPIC_SMALL_FAST_MODEL` calls) go to a small local model, while planning, cross-file reasoning, and hard debugging go to a cloud frontier model. See [Hybrid Setups § Task-tier routing](./hybrid-setups.md#task-tier-routing).

#### Tamper-evident audit log
an agent action log engineered so modification is detectable and hard: append-only / WORM storage against casual overwriting, hash-chaining (each entry commits to the previous one's hash) against a privileged insider, and real-time shipping off-host so a copy exists beyond the agent's reach. Distinct from observability tracing, which is sampled, mutable, and short-retention. See [Security § Audit Logs](./security.md#audit-logs).

#### Terminal-Bench
a benchmark (Stanford / Laude Institute; version 2.x co-authored with Snorkel) where an agent is given a shell in a Docker container and must complete an end-to-end task (fix a build, set up a server, recover data), graded pass/fail on the outcome. Hand-authored rather than scraped, so the solution is not in a public git history. See [Local Models § Benchmarks](./local-models.md#benchmarks).

#### Testcontainers
a library that starts a real dependency (database, cache, message broker) in a throwaway Docker container for the duration of a test, instead of standing in a mock. Catches the class of bug a mock cannot — SQL syntax, connection handling, serialization — and removes the agent's temptation to mock the database. See [Quality § Designing for testability](./quality.md#designing-for-testability).

#### Test double (mock / stub / fake)
a stand-in for a real dependency in a test: a *stub* returns canned values, a *mock* also asserts it was called in a particular way, a *fake* has a working lightweight implementation (e.g. an in-memory repository). Coding agents over-mock by default — one 2026 study found them adding mocks in 36% of test commits versus 26% for non-agents — producing brittle tests that verify call structure rather than behaviour; the mitigation is to prefer fakes and real dependencies (Testcontainers) and mock only at the process boundary. See [Quality § Designing for testability](./quality.md#designing-for-testability).

#### Test-driven development (TDD)
writing a failing test before the code that makes it pass, then refactoring. In agentic coding its value shifts: a test written (or human-approved) *before* the agent implements is a fixed target the agent did not author, which is one defense against the [test oracle problem](./quality.md#the-oracle-problem). Complementary to Design by Contract — "you can derive tests from a specification, not the other way around." See [Quality § Keeping the oracle out of the agent's hands](./quality.md#keeping-the-oracle-out-of-the-agents-hands).

#### Test-induced design damage
the objection (DHH, in the 2014 *Is TDD Dead?* exchange with Beck and Fowler) that pursuing testability past a certain point degrades the design: an interface and an injected collaborator for every trivial thing, plus a mock-heavy suite, costs more maintainability than it buys. The agentic form is an agent told to "make this testable" introducing five interfaces and a mock per collaborator; the corrective instruction is *a testable seam at the process boundary*, not *inject everything*. See [Quality § Designing for testability](./quality.md#designing-for-testability).

#### Test oracle problem
the difficulty of deciding what a test's correct expected output should be. It sharpens in agentic coding: when one agent writes both the implementation and its tests, the assertions tend to encode what the code *does* rather than what it *should* do — and on buggy code the model follows the implementation. See [Quality § The oracle problem](./quality.md#the-oracle-problem).

#### Three-Tier Multi-Agent Software Factory
a multi-tenant software factory architecture that runs many customers' projects in parallel via isolated LangGraph threads, extending the single-project Agentic Business Workflows pattern with per-tenant state isolation and per-thread cost tracking. See [SW Factories § Three-Tier Multi-Agent Software Factory](./sw-factories.md#three-tier-multi-agent-software-factory).

#### Tool poisoning
an [indirect prompt injection](#indirect-prompt-injection) carried in the *description* of a tool an agent loads (most often an MCP tool), so attacker instructions reach the model before the tool is ever called. Related: *rug-pull*, where a tool's definition changes after the user approved it. See [Security § Zero-Trust for AI Agents](./security.md#zero-trust-for-ai-agents).

#### Unified memory
a single pool of RAM shared by CPU and GPU with no PCIe copy and no separate VRAM to size, as on Apple Silicon and AMD "Strix Halo" / NVIDIA DGX Spark machines; trades a large model capacity for memory bandwidth well below a discrete GPU's. See [Local Models § AI-Workstations](./local-models.md#ai-workstations).

#### Vector database
a database specialized for storing embeddings and performing similarity search over them, used to retrieve relevant chunks in a RAG pipeline. See [RAGs § Context management](./rags.md#context-management).

#### Virtual key
a revocable, budgeted, model-scoped API token issued by a gateway (LiteLLM, OpenRouter) that clients use instead of a real provider key; the real upstream keys stay server-side, so a leaked virtual key is contained and cheaply rotated. See [Local Models § API key hygiene](./local-models.md#api-key-hygiene).

#### Vision encoder (ViT)
the separate network — almost always a Vision Transformer, often CLIP- or SigLIP-pretrained — that splits an image into fixed patches and turns each into a feature vector, before a [projector](#projector-multimodal-connector) maps it into the language model's embedding space. Quantization-sensitive, so kept at FP16/8-bit when run locally. See [Basics § How they differ from text-only models](./basics.md#how-they-differ-from-text-only-models) and [Local Models § Multi Modal Modells](./local-models.md#multi-modal-modells).

#### Vision-language model (VLM)
the common [multimodal](#multimodal-model-mllm) sub-type — one or more images plus text in, text out; what "this coding model is multimodal" usually means in practice. See [Basics § Multi Modal Models](./basics.md#multi-modal-models).

#### Visual grounding (pointing)
a VLM capability: returning pixel coordinates or a bounding box for a described element rather than only describing it — what makes screenshot-driven GUI agents possible (Molmo, the Qwen-VL line). Outputs are approximate. See [Basics § Capabilities and limitations](./basics.md#capabilities-and-limitations).

#### Visual instruction tuning
the VLM training stage that fine-tunes on (image, instruction, response) triples; LLaVA's contribution was to synthesize that data with a text-only model instead of human annotators, now standard practice. See [Basics § How they differ from text-only models](./basics.md#how-they-differ-from-text-only-models).

#### Visual regression testing
detecting unintended UI changes by comparing a screenshot against a committed baseline image within a pixel tolerance (Playwright's screenshot comparison, hosted services). Kept deterministic because agents change layout without noticing; contrast [VLM-as-judge](#vlm-as-judge). See [Quality § Multi Modal Models](./quality.md#multi-modal-models).

#### Visual token
one entry in the model's token sequence produced from an image patch (after any pooling or tiling). In an early-fusion model it occupies a [KV-cache](./basics.md#key-value-store) slot exactly like a text token, which is why a single screenshot costs hundreds to thousands of tokens (Claude bills one token per 28×28 px patch). See [Basics § The context-token cost of an image](./basics.md#the-context-token-cost-of-an-image).

#### vLLM
an open-source LLM serving library whose core contribution, PagedAttention, minimizes KV cache memory waste and increases serving throughput; the production-serving choice when many concurrent requests hit a model that fits entirely in datacenter- or workstation-class VRAM. See [Basics § PagedAttention (vLLM)](./basics.md#pagedattention-vllm) and [Local Models § vLLM](./local-models.md#vllm).

#### VLM-as-judge
using a vision-language model to grade a rendered result ("does this look right?"). Useful as a triage signal inside the agent's loop, but non-deterministic, hallucination-prone, and blind to sub-pixel error — so not a merge gate; deterministic [visual regression testing](#visual-regression-testing) stays the gate. The visual analogue of LLM-as-judge and of the [test oracle problem](#test-oracle-problem). See [Quality § Multi Modal Models](./quality.md#multi-modal-models).

#### Vulkan backend
llama.cpp's vendor-neutral GPU compute backend, running on any GPU with a conformant Vulkan driver and no vendor SDK; slower than CUDA on NVIDIA but now close to ROCm/SYCL and far easier to set up, especially for AMD on Windows or Intel integrated graphics. See [Local Models § Vulkan](./local-models.md#vulkan).

#### Warp Oz
Warp's cloud agent-orchestration platform (launched February 2026): runs many coding agents in parallel, each in its own container, across multiple harnesses (Claude Code, Codex, Warp Agent), cloud-hosted or self-hosted for enterprise. See [Local Models § Warp and Oz](./local-models.md#warp-and-oz).

#### Workload identity federation
exchanging a platform-native identity token (a GitHub Actions OIDC token, a Kubernetes service-account token, a cloud instance identity document) for a cloud credential with no long-lived secret stored anywhere; standard practice for CI and directly applicable to agents running in those environments. See [Security § Agent Identity](./security.md#agent-identity).

#### Workspace container
the isolation boundary an agent's shell, file writes, and network run inside, scoped in a coding-agent setting against credential/data exfiltration and unwanted outward actions rather than kernel escape: writes limited to the working tree, a default-deny [egress allow-list](#egress-allow-list), and secrets kept out of the environment. The isolation-technology spectrum (container → gVisor → micro-VM) is in [Local Models § Agent sandboxing](./local-models.md#agent-sandboxing). See [Security § Workspace Containers](./security.md#workspace-containers).

#### Zero Data Retention (ZDR)
a provider guarantee that prompts and completions are not stored after a request completes; exposed by OpenRouter as a per-request `zdr: true` routing constraint and offered as an enforced contract term by Warp and others. See [Local Models § Open Router](./local-models.md#open-router).
