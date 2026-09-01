
https://www.truefoundry.com/blog/llm-inferencing


* LLM Inference Techniques
  * Quantization
  * KV Cache (Key-Value Caching)
  * FlashAttention and PagedAttention (vLLM)
  * Speculative Decoding
  * Model Compilation and Graph Optimization
  * Efficient Batching and Token Streaming



-----------------------------------------------------------------------------------------------------

````
For which purpose are the values, stored in the token cash, used with an LLM?
````

-----------------------------------------------------------------------------------------------------


In a token cache (often referred to as a KV cache for Key-Value cache), the previously calculated mathematical intermediate states of past tokens are stored.
When using a Large Language Model (LLM), these values primarily serve to drastically increase generation speed and save computing power.

## How It Works in Detail

* Avoiding Redundant Work: LLMs generate text word by word (token by token). Without a cache, the model would have to re-read and process the entire preceding text from scratch for every single new token.
* Reusing Context: The cache stores the so-called Key and Value vectors of the self-attention layers for all tokens that have already been processed.
* Efficient Computation: For the next token to be generated, the model only needs to perform calculations for that single new token and then link it with the stored values from the cache.

## Concrete Benefits in Practice

* Higher Throughput (Tokens per Second): The response time per token remains consistently fast, even with very long texts.
* Lower Lateness (Latency): The delay before the response starts (Time to First Token) and the time between individual words drop noticeably.
* Cost Reduction: Since fewer floating-point operations (FLOPs) are required on the graphics card (GPU), infrastructure costs for live operations decrease.

------------------------------
If you want to dive deeper into LLM optimization, we can look into how techniques like vLLM (PagedAttention) optimize the memory footprint of this cache, or how the cache impacts the maximum context window. Let me know which topic you would like to explore next!




-----------------------------------------------------------------------------------------------------

````
Which calculations are performed in the Self-Attention layer?

````

-----------------------------------------------------------------------------------------------------

In the self-attention layers, the model calculates how strongly individual words (tokens) in a text relate to one another mathematically. It determines which word is important for another word within the current context.
The calculation follows a fixed mathematical process in four main steps:

## 1. Generation of Query, Key, and Value
Each token in the input text is first converted into a vector. This vector is multiplied by three different, trained weight matrices. This creates three new vectors for each token:

* Query (Q): "What is this token looking for?" (The question)
* Key (K): "What content does this token offer?" (The label)
* Value (V): "What knowledge is actually inside this token?" (The content)

## 2. Calculation of Similarity (Attention Scores)
To find out how well the "question" of one token matches the "offers" of all other tokens, the dot product is calculated between the Query vector of the current token and the Key vectors of all tokens:
$$\text{Score} = Q \times K^T$$
A high result means that the two tokens have a strong connection in the current context (e.g., the pronoun "she" and the previously mentioned name "Anna").
## 3. Scaling and Normalization (Softmax)

* Scaling: The scores are divided by the square root of the dimension of the Key vectors ($\sqrt{d_k}$). This prevents the numbers from becoming too large when dealing with long vectors.
* Softmax: The values are transformed into probabilities between 0 and 1 (percentages) using the Softmax function. The sum of all weights for a token now equals 1. The model now knows exactly what percentage of its attention to direct toward which word.

## 4. Weighted Summation
In the final step, the normalized attention weights are multiplied by the actual content vectors (Values, V) and summed up:
$$\text{Output} = \text{Softmax}\left(\frac{Q \times K^T}{\sqrt{d_k}}\right) \times V$$
The resulting vector no longer just contains the meaning of the single word, but has absorbed the entire context of the sentence.
------------------------------
Connection to the Token Cache: Since the K and V vectors for already processed words do not change during text generation, these exact values are stored in the cache. This eliminates the need to repeat steps 1 and 2 for old tokens over and over again.
If you would like to explore this further, I can show you a concrete text example of how attention shifts, or explain how Multi-Head Attention builds upon this process. Let me know which direction you prefer!


-----------------------------------------------------------------------------------------------------



````
Please explain how vLLM (PagedAttention) works

````

-----------------------------------------------------------------------------------------------------

vLLM is an open-source library designed for fast and cheap LLM serving. Its core breakthrough is PagedAttention, a technique that solves the biggest bottleneck in LLM deployment: KV Cache memory waste. [1]
Here is exactly how PagedAttention works, explained step-by-step.
------------------------------
## The Problem: Fragmented and Wasted Memory
In traditional LLM serving, the KV Cache for a request must be stored in contiguous memory (one continuous, unbroken block on the GPU). Because text length is unpredictable, systems had to pre-allocate a huge chunk of memory equal to the maximum possible context length (e.g., 2048 or 8192 tokens) for every single request.
This created three types of massive memory waste:

* Internal Fragmentation: Allocating space for 2048 tokens when the user only generates a 50-token response.
* External Fragmentation: Small, unusable gaps of free memory scattered across the GPU.
* Reservation Waste: Reserving memory ahead of time for tokens that haven't been generated yet.

In practice, up to 60% to 80% of GPU memory was wasted, drastically limiting how many requests a server could handle simultaneously.
------------------------------
## The Solution: PagedAttention (Inspired by Operating Systems)
PagedAttention solves this the exact same way operating systems solve computer RAM management: through Virtual Memory and Paging.
Instead of forcing the KV Cache of a single request to live in one continuous block, PagedAttention breaks the KV Cache down into small, fixed-size chunks called blocks. Each block contains the Key and Value vectors for a fixed number of tokens (typically 16 tokens).

Traditional KV Cache:  [================= CONTINUOUS BLOCK =================] (Wastes 80% space)

PagedAttention:        [Block 1 (16 tkn)] -> [Block 7 (16 tkn)] -> [Block 3 (12/16 tkns)] (Scattered but tightly packed)

## 1. Non-Contiguous Storage
The GPU allocates a massive pool of these small blocks. When a request comes in, PagedAttention stores its KV Cache tokens in whatever blocks are free, even if they are scattered all over the GPU memory. They do not need to be next to each other.
## 2. The Block Table (The Map)
To keep track of everything, vLLM maintains a Block Table. This table maps the logical sequence of the text (e.g., Tokens 0–15, 16–31, 32–47) to the physical addresses of the blocks on the GPU.
## 3. Modified Attention Mechanism
During the calculation phase (which we discussed earlier), when the Query vector looks for the past Key and Value vectors, the PagedAttention kernel fetches them on the fly from their scattered physical block addresses using the Block Table.
------------------------------
## Why This is a Game-Changer
By treating GPU memory like pages in an OS, vLLM achieves near-perfect efficiency:

* Zero Memory Waste: Memory is only allocated as tokens are generated. The very last block of a request might have some empty slots, but the waste is reduced from ~80% down to less than 4%.
* Massive Batching (High Throughput): Because no memory is wasted, you can fit way more requests onto a single GPU at the exact same time. vLLM often increases throughput by 2x to 4x compared to traditional engines like Hugging Face Transformers.
* Efficient Memory Sharing: If multiple users make requests using the exact same system prompt, vLLM can point their individual Block Tables to the same physical memory blocks for that prompt. It only clones the block if one user changes the text (Copy-on-Write), saving massive amounts of memory.

------------------------------
Would you like to explore how Copy-on-Write works for multi-turn chat conversations, or should we look at how PagedAttention enables speculative decoding?

[1] [https://milvus.io](https://milvus.io/docs/de/milvus_rag_with_vllm.md)


-----------------------------------------------------------------------------------------------------

````
how does the cache impact the maximum context window?
````

-----------------------------------------------------------------------------------------------------

The KV cache impacts the maximum context window because its memory footprint scales linearly with context length, creating a hard physical limit on how many tokens a GPU can process before running out of memory (OOM).
While the maximum context window of a model architecture is mathematically defined by its positional embeddings (e.g., 128k or 1M tokens), the practical context window you can actually achieve on hardware is strictly bounded by the size of the KV cache.

------------------------------
## The Scaling Problem: Linear Growth
As a conversation grows longer, every single token added requires its own Key and Value vectors to be stored in the cache. Because these vectors must be retained for every layer and every attention head in the model, the KV cache size grows rapidly.
If the KV cache consumes too much GPU memory (VRAM), there is no room left for the model weights or the active calculations, causing the system to crash with an Out-of-Memory error.
## Estimating Cache Size: A Concrete Example
To understand why it limits the context window, look at how much memory the KV cache actually consumes. The formula to calculate the size of a KV cache for a single request is:
$$\text{KV Cache Size (Bytes)} = 2 \times \text{Layers} \times \text{Heads} \times \text{Head Dimension} \times \text{Precision (Bytes)} \times \text{Tokens}$$
Let’s apply this to a standard Llama 3 8B model operating at FP16 precision (2 bytes per number), which has 32 layers, 8 KV heads (using Grouped-Query Attention), and a head dimension of 128:

* Per Token: 2 × 32 × 8 × 128 × 2 = 131,072 bytes ≈ 131 KB per token
* At 8,000 tokens: ≈ 1.05 GB
* At 128,000 tokens (Max Context): ≈ 16.8 GB

This means at a 128k context window, a single user requires 16.8 GB of VRAM just for their history cache. Since the model weights themselves take up about 16 GB, a standard 32 GB or 40 GB GPU can barely serve one single user at full context without running out of memory.
------------------------------
## Techniques to Bypass the Cache Limit
Because the KV cache is the primary roadblock to long-context LLMs, AI engineers use several architectural modifications to shrink it:

* Grouped-Query Attention (GQA): Instead of creating a unique Key and Value vector for every single Attention Head (Multi-Head Attention), models like Llama 3 share a single pair of KV vectors across a group of 4 or 8 heads. This immediately shrinks the cache size by 4x to 8x.
* Quantization (INT8 / INT4 KV Cache): Compressing the cache values from 16-bit floating points (FP16) down to 8-bit or 4-bit integers. This cuts the memory footprint by 2x to 4x with minimal loss in model accuracy.
* Streaming / Sliding Window Attention: Instead of caching everything from the very beginning, the model only keeps a moving window of the last N tokens (e.g., Mistral's 4k window) in the cache. Older tokens are dropped, keeping the cache size permanently capped.

------------------------------
## ✅ Summary
The KV cache acts as a strict physical ceiling for the context window. An architecture might be capable of reading 1,000,000 tokens, but if the GPU lacks the VRAM to hold the resulting multi-gigabyte KV cache, that context window cannot be fully utilized in production.
If you are interested, we can look into how vLLM evicts or offloads blocks when the cache fills up completely, or discuss the trade-offs of KV cache quantization. Which approach would you like to explore?



-----------------------------------------------------------------------------------------------------

````
how do Open-Claw, Hermes or other Agentic Harnesses communicate the KV-Cache to cloud LLMs?

````

-----------------------------------------------------------------------------------------------------

Agentic harnesses like Open-Claw and Hermes do not transmit the actual physical KV-cache (the multi-gigabyte mathematical matrices stored in GPU VRAM) over the internet to cloud LLM providers. Bandwidth constraints make moving raw GPU memory across a network practically impossible. [1, 2]
Instead, they achieve the exact same effect by triggering Prompt Caching (also known as Context Caching or Prefix Caching) via the provider's API. They structurally design their text prompts so the cloud provider's server recognizes an identical text prefix, allowing the cloud GPU to retrieve the pre-computed KV-cache right where it sits. [3, 4, 5]
The mechanics of how these modern 2026 agentic frameworks manage and communicate context to maximize cache retention vary by design philosophy.
------------------------------
## 1. Open-Claw: Explicit Cache Boundaries & Structuring
[Open-Claw](https://docs.openclaw.ai/de/vps) approaches the cloud API by strictly forcing a deterministic layout of text so the provider's server (like [Anthropic's Prompt Caching](https://docs.openclaw.ai/de/reference/prompt-caching) or OpenAI's internal cache) immediately hits a match. [3]

* The Explicit Cache Boundary Line: Open-Claw divides its prompt into roughly 25 sections. It injects a literal, fixed structural boundary. Anything above the line (like core system guidelines, tool schemas, and invariant workspace instructions) is kept completely stable across turns. Anything volatile (like the immediate tool output or changing clock time) is placed strictly at the bottom. [5]
* Strict Section Ordering: Since cloud prompt caching relies on prefix matching (the text must match exactly from character 0 onwards), Open-Claw carefully aggregates and alphabetizes tool definitions. If a single character changes early in the prompt, the entire cloud KV-cache is invalidated ("cache thrashing"). [3, 5, 6, 7]
* Token Normalization: Open-Claw's code hooks into provider metadata to map API responses into standardized cacheRead and cacheWrite fields. This lets the agent dynamically track whether the cloud host is successfully reusing the KV-cache or if a prompt adjustment broke it. [3]

## 2. Hermes: Progressive Disclosures & Memory Freezing
Developed by Nous Research, [Hermes Agent](https://hermes-agent.nousresearch.com/) tackles the problem using a 9-layer prompt composition architecture specifically optimized for reducing token costs by up to 75%. [5, 8]

* Mid-Session Memory Freezing: When an agent acts, it writes new memories or alters its plan. If an agent updates its system prompt during a session, it completely destroys the cloud KV-cache prefix. To prevent this, Hermes freezes its memory state at the start of a multi-turn task. Any new data written mid-session is queued up locally and not sent to the cloud until the overarching task completes. [5, 9]
* Progressive 3-Tier Skill Disclosure: To keep the baseline prompt small and cache-friendly, Hermes doesn't send full tool/skill instruction manuals at once. It sends a lightweight list of skill names (~300 tokens) in the main cached system prompt. Only when the model requests a tool does Hermes inject the full multi-kilobyte documentation on-demand. [5]
* Active Context Compression Pipelines: Hermes runs a 5-phase compression loop locally before hitting the cloud API. It aggressively prunes bloated log outputs and uses local summarization to keep the conversation history tightly compacted. [5, 8]

## 3. Advanced Cloud Co-Orchestration (CacheBlend & vLLM)
For architectures utilizing local models or deeply integrated hybrid cloud environments, specialized proxy frameworks bridge the gap between agent harnesses and the underlying inference engines.

* Local vLLM Integration: When frameworks like Hermes connect to a local or private server running [vLLM](https://hermes-agent.org/de/), they rely on PagedAttention. The agent framework passes a specific session_id or unique token sequence. vLLM uses a Block Table map to instantly wake up the specific physical GPU memory pages allocated to that agent's history without recomputing a single word. [8, 10]
* CacheBlend Over Networks: In cutting-edge agent routing (often deployed alongside Open-Claw), tools like CacheBlend are utilized. Unlike basic prefix caching which requires an exact 1-to-1 match from the beginning, CacheBlend allows agentic frameworks to reuse scattered, non-contiguous historical blocks. It selectively streams only the altered segments of an agent's context over the network, allowing the model server to dynamically splice and update the remote KV-cache blocks on the fly. [4, 11]

------------------------------
Would you like to see how Open-Claw handles prompt optimization in its configuration files to avoid cache thrashing, or should we look at how Hermes utilizes the open agentskills.io standard to compress tool calls? [5, 6, 12]

[1] [https://www.zylon.ai](https://www.zylon.ai/resources/blog/what-is-openclaw-a-practical-guide-to-the-agent-harness-behind-the-hype)
[2] [https://medium.com](https://medium.com/@milesk_33/hermes-agent-vs-openclaw-two-philosophies-for-the-personal-ai-agent-551aabf66cf8)
[3] [https://docs.openclaw.ai](https://docs.openclaw.ai/reference/prompt-caching)
[4] [https://blog.lmcache.ai](https://blog.lmcache.ai/en/accelerating-openclaw-agents-with-cacheblend/)
[5] [https://fp8.co](https://fp8.co/articles/OpenClaw-vs-Hermes-Agent-Prompt-Context-Compression)
[6] [https://www.getopenclaw.ai](https://www.getopenclaw.ai/blog/openclaw-prompt-caching)
[7] [https://docs.openclaw.ai](https://docs.openclaw.ai/de/reference/prompt-caching)
[8] [https://hermes-agent.org](https://hermes-agent.org/de/)
[9] [https://www.langchain.com](https://www.langchain.com/blog/the-anatomy-of-an-agent-harness)
[10] [https://docs.openclaw.ai](https://docs.openclaw.ai/plugins/sdk-agent-harness)
[11] [https://blog.lmcache.ai](https://blog.lmcache.ai/en/accelerating-openclaw-agents-with-cacheblend/)
[12] [https://hackernoon.com](https://hackernoon.com/hermes-agent-vs-openclaw-which-ai-agent-framework-wins-in-2026)

-----------------------------------------------------------------------------------------------------

````
Does Claude Code use the Anthropic Prompt Caching API and does it use client side optimizations to reduce the cost for Prompt Caching - I'm asking because the Anthropic API is way more expensive compared to Claude Code subscriptions?
````

-----------------------------------------------------------------------------------------------------

Yes, Claude Code heavily relies on the Anthropic Prompt Caching API, and it employs highly advanced client-side architectural optimizations specifically to maximize your cache hit rate. [1, 2]
Your observation about the pricing disconnect is completely spot-on. In heavy "agentic" developer workflows (where a tool repeatedly reads massive codebases, lists files, and runs terminal commands), paying raw, pay-as-you-go API prices can easily exceed $1,000 a month. Anthropic can afford to offer flat-rate Claude Code subscriptions (like the $200/month tier) precisely because the Claude Code client is architected to ensure that up to 90% of your input tokens result in cheap server-side cache hits, which only cost Anthropic 10% of the standard input rate to compute. [3, 4, 5, 6]
Here is how the Claude Code client systematically handles prompt caching behind the scenes to keep costs manageable:
## 1. Strict Prefix Discipline & Layered Architecture
Anthropic’s prompt caching works via prefix matching; the prompt must be 100% identical from character 0 onward to trigger a cache hit. If even one character changes early in the prompt, the entire downstream cache is invalidated (a cache miss). [7, 8]
To protect the prefix, the Claude Code client strictly modularizes how it builds the payload sent to the API: [9]

* Layer 1: The System Prompt & MCP Tools (Base): Core instructions, output formatting, and tool schemas (e.g., file system access, terminal execution) are locked at the very top of the prompt.
* Layer 2: CLAUDE.md / Project Rules: Project-specific memory files are attached right after the tools.
* Layer 3: Conversation History: Appended chronologically at the bottom. [2, 9]

## 2. File Invalidation via Append-Only System Reminders
The most brilliant client-side optimization in Claude Code is how it handles file modifications. Normally, if Claude reads a file at turn 2, and you edit that file locally at turn 5, updating the file inside the conversation history would break the prefix match for everything after turn 2—nuking the entire cache. [2]
Instead of retroactively changing old history, Claude Code treats the conversation as immutable. When a file changes, the client leaves the old, cached read exactly as it was. It simply appends a <system-reminder> block to the very end of the message history, stating that the file was modified. This allows the server to reuse the massive existing KV-cache, and Claude only re-reads the file if necessary. [2]
## 3. Cache-Safe Context Compacting
As your terminal session grows, your token count balloons, risking hitting the model's hard context limit or degrading response quality. Claude Code includes a /compact command to trim the conversation tail. [5, 8, 9]
When executing a compaction, the client doesn't just slice the text randomly. It uses a cache-safe forking design pattern: it maintains the exact same base prefix (system prompt, tools, parent messages), appends a compaction request as a new user message at the very end, and extracts the summary. This ensures the summary extraction itself uses 100% cached tokens and costs virtually nothing. [10, 11]
## 4. Delayed Application of Settings
If you modify configuration files, output styles, or settings mid-session via /config, a naive client would instantly update the system prompt, causing an expensive cache miss. The Claude Code client handles this by freezing the system layout; it queues up your config changes locally, allowing the current active session to maintain its cache hits. The changes are only applied when you explicitly restart the tool or call /clear. [8, 9]
## Summary of What Triggers Cache Misses
Anthropic passes the cost savings of these optimizations on to the subscription model. However, certain client-side actions force a complete cache "nuke", creating an expensive turn for Anthropic's servers: [8, 9, 11]

* Switching models mid-session using the /model command.
* Connecting/disconnecting an MCP server mid-session (changes the top-level tool layer).
* Changing the extended thinking budget mid-session. [8, 9, 12]

Would you like to know more about how to track your specific session's cache performance using internal client telemetry, or how Model Context Protocol (MCP) servers impact cache budgeting?

[1] [https://github.com](https://github.com/flightlesstux/prompt-caching)
[2] [https://code.claude.com](https://code.claude.com/docs/en/prompt-caching)
[3] [https://news.ycombinator.com](https://news.ycombinator.com/item?id=46549823)
[4] [https://www.mindstudio.ai](https://www.mindstudio.ai/blog/prompt-caching-claude-code-token-savings)
[5] [https://www.claudecodecamp.com](https://www.claudecodecamp.com/p/how-prompt-caching-actually-works-in-claude-code)
[6] [https://pasqualepillitteri.it](https://pasqualepillitteri.it/de/news/223/claude-code-nicht-interaktiver-modus-hosting-begrenzt)
[7] [https://www.mager.co](https://www.mager.co/blog/2026-04-29-claude-prompt-caching/)
[8] [https://www.reddit.com](https://www.reddit.com/r/ClaudeAI/comments/1tlzqpl/cache_miss_in_claude_code_costs_125_more_than_a/)
[9] [https://code.claude.com](https://code.claude.com/docs/en/prompt-caching)
[10] [https://x.com](https://x.com/trq212/status/2024638793719177291)
[11] [https://www.mindstudio.ai](https://www.mindstudio.ai/blog/anthropic-prompt-caching-claude-subscription-limits)
[12] [https://platform.claude.com](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)


-----------------------------------------------------------------------------------------------------

````
How do RAG systems manage Prompt Caching compared to usual Agentic Harnesses?
````

-----------------------------------------------------------------------------------------------------

While both standard Retrieval-Augmented Generation (RAG) pipelines and Agentic Harnesses use Prompt Caching to reduce costs and latency, they manage it in fundamentally opposing ways due to how their text streams behave. [1, 2, 3, 4]
The core difference is that Agentic Harnesses build a single, ever-growing chronological history across multiple turns, while standard RAG systems handle thousands of isolated, stateless queries containing wildly different retrieved document snippets. [5, 6, 7]

------------------------------
## Comparison Matrix

| Feature | Standard RAG Systems | Agentic Harnesses (e.g., Claude Code, Open-Claw) |
|---|---|---|
| State Nature | Stateless (Each query is independent) | Stateful (Long multi-turn sessions) |
| Main Cache Risk | Context Thrashing (Retrieved chunks change every query) | Prefix Nuking (A mid-history edit invalidates everything downstream) |
| Structuring Rule | Core Documents -> System Rules -> Query | System Rules -> Static Context -> Dynamic History |
| Cache Hit Targets | Shared global knowledge base across all users | Session-specific context for a single continuous developer |

------------------------------
## How RAG Systems Manage Prompt Caching
Because RAG injects documents based on vector search similarity, a user asking Question A will pull entirely different text snippets than a user asking Question B. If these dynamic chunks are placed early in the prompt, they break prefix matching for everything that follows. RAG systems use specific architectural patterns to combat this: [2, 7, 8, 9]
## 1. The Global "Mega-Context" Shift (CAG)
Instead of fetching 5 unique text chunks per query, modern production RAG setups frequently pivot to Cache-Augmented Generation (CAG). If a company has a 20,000-token employee handbook, the RAG system stuffs the entire document permanently at the top of the prompt. [8, 10]

* The Cache Effect: For thousands of different employee questions, the top 20,000 tokens remain identical. Every single user query hits a 100% warm prompt cache prefix, dropping input costs by ~90%. [2, 9, 10]

## 2. Deterministic Chunk Sorting
When standard chunk retrieval is unavoidable, a RAG system cannot allow its vector database to return chunks in random similarity order. If Query A retrieves Chunks [X, Y, Z] and Query B retrieves Chunks [Y, X, Z], the cache breaks due to the shuffle. RAG pipelines enforce deterministic sorting (e.g., sorting retrieved chunks alphabetically by their unique ID or by timestamp) before appending them to the prompt. [2, 5, 11]
## 3. Moving the Query to the Absolute Bottom [12]
In a RAG setup, the user's specific query is highly volatile. Therefore, the RAG harness forces an unconventional prompt structure:
[Static System Prompt] -> [Deterministic Cached RAG Documents] -> [Volatile User Query]
This isolates the volatility to the last few tokens, preserving the massive cache of the retrieved documents. [6, 8, 9]
------------------------------
## How Agentic Harnesses Manage It Differently
An agentic harness isn't answering isolated questions from a large database; it is executing a multi-step loop (Read file -> Run terminal -> Run tests -> Edit file). [7, 13, 14]
## 1. Accumulative Linear Caching [12]
Agents rely on the fact that the previous turns of the conversation are immutable. As the agent runs a terminal command, the output is appended to the bottom. The server simply appends the new mathematical KV-states to the existing cache. The agent's battle is maintaining this single continuous stream without a tool breaking the chain early on. [2, 6, 15]
## 2. Dealing with the "Tool Tax"
In an agentic system, tool schemas (the code definitions explaining to Claude how to use the terminal or filesystem) live at the very top of the system prompt. If an agent decides to dynamically load a new tool mid-session, it modifies the prefix. This completely destroys ("nukes") the entire accumulated session cache. Agents must use tactics like Logits Masking to hide/reveal tools rather than modifying the text prefix. [6, 15]
## 3. Ephemeral Cache Boundaries [12]
Unlike RAG, which wants a cache to stay warm for hours across multiple users, an agent uses explicit cache breakpoints (like those in the Anthropic API). It instructs the server: "Cache up to this specific tool execution loop, because I will likely be back in 4 seconds with a command output." [6, 7, 16]
------------------------------
## Summary of the Structural Friction
If you design a prompt like a traditional RAG system but run it in an Agent, or vice-versa, your costs will skyrocket. [2, 11, 13]

* RAG prioritizes keeping the injected database documents matching across different user sessions.
* Agents prioritize keeping the chronological conversation timeline unbroken so it can execute loops over a single long workspace session. [2, 6, 7, 13]

If you are building a custom pipeline, I can show you how to structure your JSON API payloads to explicitly position these cache boundaries, or we can look at Semantic Caching as an alternative layer. Which would you prefer? [2, 16, 17]

[1] [https://www.ibm.com](https://www.ibm.com/think/topics/prompt-caching)
[2] [https://unscriptedcoding.medium.com](https://unscriptedcoding.medium.com/prompt-caching-in-agentic-ai-systems-1f4b78c65ea5)
[3] [https://redis.io](https://redis.io/blog/what-is-prompt-caching/)
[4] [https://www.mindstudio.ai](https://www.mindstudio.ai/blog/what-is-agent-harness-matters-more-than-model)
[5] [https://towardsdatascience.com](https://towardsdatascience.com/beyond-prompt-caching-5-more-things-you-should-cache-in-rag-pipelines/)
[6] [https://www.reddit.com](https://www.reddit.com/r/SillyTavernAI/comments/1uwzjd4/am_i_the_only_one_who_has_thought_of_using/)
[7] [https://aws.amazon.com](https://aws.amazon.com/blogs/database/optimize-llm-response-costs-and-latency-with-effective-caching/)
[8] [https://goclaw.sh](https://goclaw.sh/blog/prompt-caching)
[9] [https://gleecus.com](https://gleecus.com/blogs/how-prompt-caching-optimizes-llm-latency-and-reduces-token-usage/)
[10] [https://medium.com](https://medium.com/@mehrcodeland/prompt-caching-in-large-language-models-a-technical-deep-dive-for-production-ai-systems-ce0289437d54)
[11] [https://www.openhelm.ai](https://www.openhelm.ai/blog/prompt-caching-cost-optimisation-ai-agents)
[12] [https://unscriptedcoding.medium.com](https://unscriptedcoding.medium.com/prompt-caching-in-agentic-ai-systems-1f4b78c65ea5)
[13] [https://x.com](https://x.com/akshay_pachaar/status/2056714042455343160)
[14] [https://www.kore.ai](https://www.kore.ai/blog/what-is-agentic-rag)
[15] [https://engineeratheart.medium.com](https://engineeratheart.medium.com/the-definitive-guide-to-agent-harness-engineering-5f5edf25fd73)
[16] [https://arxiv.org](https://arxiv.org/html/2601.06007v2)
[17] [https://redis.io](https://redis.io/blog/prompt-caching-vs-semantic-caching/)


-----------------------------------------------------------------------------------------------------



