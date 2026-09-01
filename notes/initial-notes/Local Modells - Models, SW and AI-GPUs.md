# Local Modells and AI-Graphic-Cards

## Overview

Manufacturerer specific SW-Tooling / SW-Stack / Higher level programming models:
* NVidea: CUDA
* AMD: ROCm
* Intel: SYCL

Generic low level programming model: Vulkan

Manufacturer specific low level:
* Apple: Metal Framework


Inference engines:
* llama.cpp - resource efficiency, consumer hardware
* Ollama - uses llama.cpp under the hood, easy to use - performance issues
* vLLM - high-throughput, Python-based - high-end enterprise GPUs - multi-user production servers

Cross Inference engine management apps / GUIs:
* LM Studio (llama.cpp, Apple MLX)
* Open WebUI (vLLM, ollama, openAI-API)

Multi-model marketplaces & API gateways:
* OpenRouter: SaaS - cloud aggregator - unified access and billing to commercial and open models - single API endpoint
* LiteLLM: Self-hosted - open-source - standardizes LLM API calls - track costs - enforce team budgets - handle routing or fallbacks

Consumer GPUs below 20G DRAM (not recommended):
* NVidea:
  * RTX 5070 Ti: 16G
  * RTX 5080: 16G
  * RTX Pro 2000 Blackw: 16G
  * RTX 2000 Ada: 16G
* Intel
  * Arc Pro B50: 16G
* AMD
  * Radeon RX 9070 XT: 16G

Consumer GPUs above 20G DRAM (recommended):

* NVidea:
  * RTX 4000 SFF Ada: 20G
  * RTX 4090: 24G
  * RTX 5090: 32G
* Intel
  * ARC B70: 32G
* AMD
  * RX 7900 XT: 20GB GDDR6
  * RX 7900 XTX: 24GB GDDR6
  
Modells suitable for Consumer GPUs (> 20G) - [More Details Here](./Local-Models - Best open weights model for coding.md)
* Qwen3.6
* qwen2.5-coder
* Qwen3-Coder-30B
* Qwen3-Coder-Next 
* gemma4
* nemotron-3-nano_30b

Datacenter / Professional GPUs:
* NVidea:
  * V100: 80GB
  * A100: 80GB
  * B100
  * H100/H200

AI Workstation:
* Nvidea:
  * DGX Spark: 128G unified - 273 GB/s vs 1.8 TB/s RTX 5090
  * DGX B300: 8 SXM-GPUs - 2,1 TB HBM3e + 2× Intel Xeon 6776P - 2 TB RAM + 
* AMD
  * AMD Ryzen AI Max - 128 GB unified RAM (more or less compareable to Apple M4)

Modells suitable for Datacenter / Professional GPUs) - [More Details Here](../Gemini: best open weights model for coding.md)
* Kimi K3
* GLM-5.2
* MiniMax M3
* DeepSeek V4 Pro
* Inkling
* GLM-5.3 a.k.a "OX Alpha"

-----------------------------------------------------------------------------------------------------

````
vLLM vs llama.cpp
````

-----------------------------------------------------------------------------------------------------

vLLM and llama.cpp are both open-source Large Language Model (LLM) inference engines, but they are built for entirely different hardware setups and workloads. vLLM is a high-throughput, Python-based engine optimized for multi-user production serving on high-end enterprise GPUs. In contrast, llama.cpp is a lightweight, pure C/C++ engine optimized for resource efficiency, consumer hardware, and edge deployment. [1, 2, 3, 4]

## Summary Comparison

| Feature | vLLM[](https://developers.redhat.com/articles/2025/09/30/vllm-or-llamacpp-choosing-right-llm-inference-engine-your-use-case) | llama.cpp |
|---|---|---|
| Primary Goal | Maximize server-wide throughput | Maximize efficiency per device |
| Best Used For | Multi-user APIs & web applications | Local development & offline usage |
| Ideal Hardware | High-end Data Center GPUs (NVIDIA/AMD) | Mac Silicon, CPUs, & Consumer GPUs |
| Core Architecture | Python backend with PagedAttention | Lightweight, pure C/C++ execution |
| Model Formats | HF Safetensors, GPTQ, AWQ | GGUF |
| VRAM Consumption | High (pre-allocates KV cache) | Low (optimized memory mapping) |
| Multi-GPU Scaling | Native Tensor & Pipeline Parallelism | Basic layer splitting across GPUs |

------------------------------
## vLLM: The Production Workhorse
The core innovation of [vLLM](https://gigagpu.com/vllm-vs-llama-cpp-gpu-servers/) is its PagedAttention technology. It treats the LLM's Key-Value (KV) cache like virtual memory, eliminating fragmentation and allowing multiple generation requests to share memory dynamically. [2, 4, 5]

* High Concurrency: It achieves 2-3x higher throughput than other engines under heavy parallel load. It continuously batches incoming requests seamlessly. [1, 2]
* Enterprise Scaling: It supports advanced multi-GPU clustering out of the box using Tensor Parallelism to split models across multiple cards smoothly. [6]
* Dynamic LoRA: It can swap multiple LoRA adapters on the fly, allowing a single base model to serve different tasks simultaneously without downtime. [7]
* VRAM Hungry: It aggressively pre-allocates up to 90%+ of your VRAM for the KV cache, which can cause out-of-memory errors on smaller consumer hardware. [2]

## llama.cpp: The Portability Champion
[llama.cpp](https://pub.towardsai.net/i-tested-ollama-vs-vllm-vs-llama-cpp-the-easiest-one-collapses-at-5-concurrent-users-d4f8e0e84886) was built to run inference with zero external dependencies. It focuses heavily on the GGUF file format, which enables rapid loading and allows the system to execute the model directly from disk storage via memory-mapping. [1, 3, 4]

* Hardware Ubiquity: It runs perfectly on Apple Silicon, commodity Intel/AMD CPUs, single consumer GPUs, and edge platforms. [1, 4]
* Extreme Quantization: It excels at running models at lower bitrates (e.g., 2-bit to 8-bit quantization), preserving high quality while using roughly 35% less VRAM than unquantized versions. [1, 2]
* RAM Offloading: If your GPU doesn't have enough VRAM to hold a model, llama.cpp can split the layers, running some on the GPU and the rest on your standard system RAM. [4]
* Concurrency Bottleneck: It uses a standard request queue. If multiple users hit the server at once, response times will skyrocket. [1, 3]

------------------------------
## Which One Should You Choose?

* Choose vLLM if you are building a commercial SaaS application, deploying to a cloud server (like an A100 or H200 cluster), and need to serve dozens of concurrent API users simultaneously. [1, 6]
* Choose llama.cpp if you are running models locally on your laptop, utilizing an Apple Mac mini/Studio, offloading layers to a CPU, or building an offline single-user application. [1, 3, 4]

If you would like to choose the perfect engine for your system, tell me:

* What hardware (GPU, CPU, VRAM size) will you be using?
* How many concurrent users or requests do you need to support?
* What model size (e.g., 8B, 70B parameters) are you looking to host?


[1] [https://developers.redhat.com](https://developers.redhat.com/articles/2025/09/30/vllm-or-llamacpp-choosing-right-llm-inference-engine-your-use-case)
[2] [https://gigagpu.com](https://gigagpu.com/vllm-vs-llama-cpp-gpu-servers/)
[3] [https://pub.towardsai.net](https://pub.towardsai.net/i-tested-ollama-vs-vllm-vs-llama-cpp-the-easiest-one-collapses-at-5-concurrent-users-d4f8e0e84886)
[4] [https://xhinker.medium.com](https://xhinker.medium.com/llama-cpp-vllm-and-sglang-which-one-to-use-cc0b01b2b55c)
[5] [https://www.glukhov.org](https://www.glukhov.org/de/llm-hosting/vllm/vllm-quickstart/)
[6] [https://www.reddit.com](https://www.reddit.com/r/LocalLLaMA/comments/1m1au28/vllm_vs_llamacpp/?tl=de)
[7] [https://www.ertas.ai](https://www.ertas.ai/compare/llama-cpp-vs-vllm)


-----------------------------------------------------------------------------------------------------

````
Is Ollama also an inference engine?
````

-----------------------------------------------------------------------------------------------------

Ollama acts as an inference engine for end-users, but technically, it is a user-friendly application wrapper and orchestration layer built on top of other execution backends. [1, 2]
By default, Ollama handles model management, while delegating the complex, low-level mathematical tensor operations to llama.cpp running silently in the background. [1, 3]
## How the Architecture Works
Ollama is written primarily in Go. When you perform a task in Ollama, the architecture handles the workload through structured layers: [1, 3]

* The Management Layer (Go): When you type a command like ollama run llama3, the Go application acts like Docker. It pulls the model from its registry, manages your local system memory, estimates VRAM usage, and maps the prompt template. [1, 4, 5]
* The Inference Engine Backend (C++): Once the model is ready, Ollama spins up a hidden llama.cpp subprocess. This backend unpackages the GGUF model files and executes the token generation using hardware acceleration (such as CUDA, Apple Metal, or Vulkan). [1, 3]
* The API Translation: Ollama wraps everything in a clean, local web server, exposing OpenAI-compatible REST API endpoints. [1, 6]

(Note: While llama.cpp is Ollama's main backbone, Ollama has expanded its ecosystem to natively integrate other specialized backends—such as Apple's MLX library for optimized performance on Apple Silicon). [7, 8]
## Ollama vs. Pure llama.cpp

| Feature | Ollama | llama.cpp (Direct)[](https://docs.bswen.com/blog/2026-03-27-llama-cpp-vs-ollama-local-coding/) |
|---|---|---|
| Interface | Simple, polished CLI and automatic APIs | Raw command-line, complex arguments |
| Model Downloads | Automated via ollama pull [name] | Manual downloading from Hugging Face repositories |
| Memory Control | Automatically unloads models when idle | You must manually kill the process to free RAM |
| Performance Overhead | Slight delay as requests pass through Go | Maximum speed; absolute zero language overhead |
| Tuning Capabilities | Hidden settings; uses sensible defaults | Exposes every variable (threads, GPU layers, etc.) |

## The Takeaway
Think of llama.cpp as a high-performance car engine, and Ollama as the dashboard, steering wheel, and automated transmission wrapped around it. Ollama is the preferred choice if you want local AI to "just work". You should use pure llama.cpp if you need absolute control to squeeze every drop of performance out of your hardware. [2, 9, 10, 11]
Are you considering setting up Ollama for a project, or are you looking to write custom code directly against an inference API?

[1] [https://www.snackonai.com](https://www.snackonai.com/p/ollama-the-easiest-way-to-run-powerful-ai-models-locally-10ee)
[2] [https://docs.bswen.com](https://docs.bswen.com/blog/2026-03-27-llama-cpp-vs-ollama-local-coding/)
[3] [https://read.theaimerge.com](https://read.theaimerge.com/p/the-complete-guide-to-ollama-local)
[4] [https://pexon-consulting.de](https://pexon-consulting.de/blog/ollama-vllm-tgi-vergleich-inference-engines/)
[5] [https://picovoice.ai](https://picovoice.ai/blog/local-llms-llamacpp-ollama/)
[6] [https://www.rushis.com](https://www.rushis.com/ollama-vs-llama-cpp-a-technical-deep-dive-for-developers/)
[7] [https://ollama.com](https://ollama.com/blog/mlx)
[8] [https://neuralnet.solutions](https://neuralnet.solutions/ollama-vs-llama-cpp-which-framework-is-better-for-inference)
[9] [https://www.reddit.com](https://www.reddit.com/r/LocalLLaMA/comments/1mdma9a/help_choosing_between_ollama_llamacpp_or/)
[10] [https://neuralnet.solutions](https://neuralnet.solutions/ollama-vs-llama-cpp-which-framework-is-better-for-inference)
[11] [https://www.xda-developers.com](https://www.xda-developers.com/i-ditched-ollama-after-using-llama-cpp-webui-and-im-not-going-back/)

-----------------------------------------------------------------------------------------------------


````
Which inference engines does LM-Studio use?
````

-----------------------------------------------------------------------------------------------------

LM Studio primarily uses two distinct, heavily optimized inference engine backends under the hood: llama.cpp and Apple's MLX. [1, 2]
Similar to Ollama, LM Studio is a feature-rich graphical application (built on Electron) that does not execute the machine learning models itself; it acts as an orchestration layer and user interface that manages these underlying engines. [1, 3, 4, 5, 6]
LM Studio dynamically switches between or combines its backends based on your operating system and the type of model you load:
## 1. The llama.cpp Engine Backend
This is the default engine used on Windows, Linux, and Apple Intel Macs. It is also utilized on Apple Silicon when running standard GGUF files. [2, 7]

* Supported Formats: GGUF (and legacy GGML).
* Purpose: It provides robust cross-platform compatibility, hardware acceleration across varying hardware (NVIDIA CUDA, AMD ROCm, Intel CPUs), and manages advanced optimizations like [speculative decoding](https://lmstudio.ai/blog/lmstudio-v0.3.10) and [concurrent request handling](https://lmstudio.ai/blog/0.4.0). [2, 8, 9, 10]

## 2. The Apple MLX Engine Backend
LM Studio includes a dedicated [unified MLX engine](https://lmstudio.ai/blog/unified-mlx-engine) tailored exclusively for Apple Silicon (M1/M2/M3/M4 chips). [2, 11]

* Supported Formats: MLX-native model weights. [12]
* Purpose: Built on Apple’s open-source machine learning framework, it bypasses llama.cpp constraints on Mac to achieve incredibly high token generation speeds. It weaves together two specific Python libraries:
* mlx-lm: Handles highly efficient text generation.
   * mlx-vlm: Acts as a modular "add-on" that generates image embeddings, giving LM Studio native support for multi-modal Vision LLMs on Apple devices. [2, 11, 12]

------------------------------
## What LM Studio Does NOT Use
Unlike other heavy server stacks (like [vLLM](https://developers.redhat.com/articles/2026/06/15/llamacpp-vs-vllm-choosing-right-local-llm-inference-engine), TensorRT-LLM, or Hugging Face TGI), LM Studio does not natively support running raw HF Safetensors, AWQ, or GPTQ files directly through Python web-servers. It is strictly built to route local desktop workloads through its custom llama.cpp and MLX wrappers. [1, 2, 8, 13]
Are you hoping to run a specific model format that you can't get to load, or are you trying to choose the best backend for your operating system?

[1] [https://contracollective.com](https://contracollective.com/blog/ollama-vs-lm-studio-vs-mlx-lm-local-inference-ux-2026)
[2] [https://medium.com](https://medium.com/@kapustinomm/how-to-run-llms-locally-with-lm-studio-complete-guide-2026-c941843e000e)
[3] [https://webscraft.org](https://webscraft.org/blog/lm-studio--scho-tse-take-i-navischo-zapuskati-ai-na-mac?lang=en)
[4] [https://discuss.4d.com](https://discuss.4d.com/t/list-of-local-inference-engines/37115)
[5] [https://pyimagesearch.com](https://pyimagesearch.com/2024/06/24/integrating-local-llm-frameworks-a-deep-dive-into-lm-studio-and-anythingllm/)
[6] [https://www.thundercompute.com](https://www.thundercompute.com/blog/lm-studio-local-llm)
[7] [https://arxiv.org](https://arxiv.org/html/2603.23996v1)
[8] [https://medium.com](https://medium.com/@kapustinomm/how-to-run-llms-locally-with-lm-studio-complete-guide-2026-c941843e000e)
[9] [https://lmstudio.ai](https://lmstudio.ai/blog/lmstudio-v0.3.10)
[10] [https://lmstudio.ai](https://lmstudio.ai/blog/0.4.0)
[11] [https://lmstudio.ai](https://lmstudio.ai/blog/unified-mlx-engine)
[12] [https://asiai.dev](https://asiai.dev/engines/lmstudio/)
[13] [https://developers.redhat.com](https://developers.redhat.com/articles/2026/06/15/llamacpp-vs-vllm-choosing-right-local-llm-inference-engine)

-----------------------------------------------------------------------------------------------------


````
24gb ai benchmark rtx 5080 vs rtx 4090
````

-----------------------------------------------------------------------------------------------------

Für lokale KI-Workloads gilt: Die NVIDIA GeForce RTX 4090 schlägt die neuere Geforce RTX 5080 im Gesamtergebnis, weil sie über 24 GB VRAM statt nur 16 GB verfügt. Während die RTX 5080 dank der neueren Blackwell-Architektur eine höhere Effizienz pro Watt sowie exklusive FP4-Unterstützung bietet, limitiert die geringere VRAM-Kapazität drastisch die maximal ladbare Modellgröße für Large Language Models (LLMs). [1, 2]
## Technische Spezifikationen im Überblick

| Kriterium | NVIDIA GeForce RTX 5080[](https://www.compute-market.com/compare/rtx-5080-vs-rtx-4090) | NVIDIA GeForce RTX 4090 |
|---|---|---|
| VRAM-Kapazität | 16 GB GDDR7 | 24 GB GDDR6X |
| Speicherbus | 256-bit | 384-bit |
| Bandbreite | 960 GB/s | 1.008 GB/s |
| Tensor Cores | 5. Generation (mit FP4) | 4. Generation (max. FP8) |
| AI Leistung (INT8) | ~1.801 TOPS (mit Sparsity) | ~1.321 TOPS |
| Stromverbrauch (TDP) | 360 W | 450 W |

## KI-Leistungsvergleich im Detail## 1. LLM-Inferenz (Lokale Chatbots)

* Modellgrößen: Mit der RTX 4090 (24 GB VRAM) lassen sich 14B- und 32B-Modelle (z. B. DeepSeek) flüssig lokal im 4-Bit-Quantisierungsverfahren ausführen. Die RTX 5080 ist durch ihre 16 GB VRAM meist auf 7B- bis maximal optimierte 13B-Modelle beschränkt. [1, 2]
* Token-Generierung: Bei kleineren Modellen wie Llama 2 (7B) agieren beide Karten fast auf Augenhöhe. Die RTX 4090 erreicht laut Benchmarks von [BestGPUsforAI](https://www.bestgpusforai.com/gpu-comparison/5080-vs-4090) rund 5.013 Tokens/s im Procyon-Test, während die RTX 5080 mit 4.790 Tokens/s nur knapp dahinter liegt. [2]

## 2. Bildgenerierung (Stable Diffusion)

* SD 1.5 & SDXL: Die RTX 5080 profitiert massiv von ihren überarbeiteten Tensor-Kernen und generiert Einzelbilder in Standardauflösung durch FP4-Quantisierung teils spürbar effizienter. [2]
* Batch-Größen: Sobald jedoch große Bilder (wie SDXL nativ in 1024x1024) oder hohe Batch-Größen berechnet werden, zieht die RTX 4090 davon. Der Procyon AI Benchmark für Stable Diffusion 1.5 zeigt die 4090 mit einem Score von 5.260 vor der 5080 mit 4.650 Punkten. [2, 3]

## 3. Deep Learning & Fine-Tuning

* Das Anpassen (Fine-Tuning) von Modellen via QLoRA scheitert auf der RTX 5080 bei größeren Modellen an "Out of Memory"-Fehlern. Die RTX 4090 bietet hier den nötigen Headroom für 30B-Modelle mit angepassten Checkpoints. [4]

## Fazit: Welche Karte wählen?

* Kauf die RTX 4090, wenn der Fokus primär auf der Nutzung großer LLMs (DeepSeek, 30B+ Modellen) sowie dem Trainieren/Fine-Tuning liegt. VRAM ist in der lokalen KI-Welt durch nichts zu ersetzen. [1, 4]
* Wähle die RTX 5080, wenn du ein besseres Preis-Leistungs-Verhältnis suchst, dir kleinere Modelle bis 13B reichen und du von der moderneren, stromsparenden Blackwell-Architektur profitieren willst. [2, 5]

Teile mir gerne mit, falls du bestimmte Frameworks (wie PyTorch oder TensorRT-LLM) planst oder spezifische KI-Modelle im Kopf hast, damit ich die Performance dafür präziser abschätzen kann. [6]

[1] [https://www.reddit.com](https://www.reddit.com/r/LocalLLaMA/comments/1igoy14/5080_16gb_vs_4090_24gb/)
[2] [https://www.bestgpusforai.com](https://www.bestgpusforai.com/gpu-comparison/5080-vs-4090)
[3] [https://www.youtube.com](https://www.youtube.com/watch?v=TRSlvsYbSpA)
[4] [https://www.compute-market.com](https://www.compute-market.com/blog/rtx-5080-vs-rtx-4090-for-ai-2026)
[5] [https://www.compute-market.com](https://www.compute-market.com/compare/rtx-5080-vs-rtx-4090)
[6] [https://gpu.userbenchmark.com](https://gpu.userbenchmark.com/Compare/Nvidia-RTX-5080-vs-Nvidia-RTX-4090/4179vs4136)


-----------------------------------------------------------------------------------------------------

````
OpenRouter vs LiteLLM vs Open WebUI
````

-----------------------------------------------------------------------------------------------------

OpenRouter, LiteLLM, and Open WebUI serve fundamentally different purposes within the AI ecosystem. While OpenRouter is a fully managed cloud marketplace for AI models, LiteLLM acts as a self-hosted technical API gateway for developers, and Open WebUI provides the graphical user interface (frontend) for end-users. They are not pure competitors; instead, they complement each other perfectly.
------------------------------
## Direct Comparison

| Criterion | OpenRouter | LiteLLM | Open WebUI |
|---|---|---|---|
| Primary Function | Cloud Model Aggregator | Technical API Gateway | Graphical User Interface (UI) |
| Target Audience | Developers & Testers | Enterprise & Platform Teams | End-Users & Teams |
| Hosting | Cloud SaaS (No Infra) | Self-Hosted (Docker/K8s) | Self-Hosted (Docker/Local) |
| Data Privacy | Lower (US Server Routing) | Maximum (Infra Control) | Maximum (Infra Control) |
| Cost | Token Prices + ~5.5% Fee | Free (Open-Source Core) | Free (Open-Source) |
| Model Access | 650+ Models Instantly | Manual API Key Bundling | Via Connected Backends |

------------------------------
## 🔌 OpenRouter: The Cloud Marketplace
[OpenRouter](https://openrouter.ai/) is a cloud-based service that unites hundreds of AI models (both open-source and commercial) behind a single unified API. You do not need to register separately with Anthropic, OpenAI, and Meta; you pay centrally in one place.

* Pros: Instant access to over 650 models, automatic downtime rerouting (failover), and extremely fast prototyping without maintaining server infrastructure.
* Cons: Your data flows through OpenRouter's servers (a key factor for GDPR compliance). Additionally, a service fee of approximately 5,5% is added to your token purchases.

## 🛠️ LiteLLM: The Enterprise Gateway
[LiteLLM](https://github.com/BerriAI/litellm) is an open-source software package that you install on your own infrastructure. It translates code for over 100 different model providers into a unified, OpenAI-compatible format.

* Pros: Absolute data control within your own private network. It provides deep administrative tools for teams, including budget limits per employee, detailed spend tracking, and custom fallback routes.
* Cons: High administrative overhead (DevOps, Docker, databases). You must manually acquire, input, and manage API keys for each individual provider.

## 💻 Open WebUI: The User Frontend
[Open WebUI](https://github.com/open-webui/open-webui) does not provide a backend or routing system. Instead, it is a user interface heavily inspired by the visual design of ChatGPT. It runs locally or on a server and requires an API connection in the background to function.

* Pros: Highly feature-rich for end-users, offering chat histories, document uploads (RAG), text-to-speech, user management, and image generator integrations.
* Cons: Does not include any built-in AI models. It must be connected to Ollama (locally) or an OpenAI-compatible API (such as OpenRouter or LiteLLM).

------------------------------
## When to Use Which?

* Choose OpenRouter if you want to quickly evaluate new models, test applications, or get instant access to the latest AIs as an individual developer without maintaining servers.
* Choose LiteLLM if you work in an enterprise environment that requires strict data privacy (e.g., GDPR), needs to control spending structures, and can host the infrastructure internally.
* Choose Open WebUI if you want to provide your employees or yourself with a comfortable browser interface for daily chatting, rather than interacting with APIs via code.

The Perfect Combination: Many production setups use Open WebUI as the chat interface for the team, which sends requests to LiteLLM (for enterprise user management and budgeting), which then routes to OpenRouter to easily access a vast catalog of models.
Are you building a system for personal use or planning a deployment for an enterprise environment? Let me know, and I can help you create the matching configuration files for your scenario.


-----------------------------------------------------------------------------------------------------

````
Which consumer AMD GPUs with at least 20G VRAM are there allowing to run local inferences engines?
````

-----------------------------------------------------------------------------------------------------

For running local inference engines, AMD relies on its ROCm (Radeon Open Compute) platform. While newer generations of mid-range AMD consumer cards (like the RDNA 4-based RX 9070) have limited VRAM capacities up to 16GB, there are two primary consumer desktop GPUs from the RDNA 3 lineup that strictly meet your requirement of at least 20GB VRAM: [1, 2, 3, 4, 5] 

## Consumer AMD GPUs (20GB+ VRAM)

* AMD Radeon RX 7900 XTX (24GB GDDR6): This is AMD's top-tier consumer flagship card. Offering 24GB of VRAM and a massive 384-bit memory bus (yielding up to 960 GB/s bandwidth), it is highly popular in the local AI community. It provides enough memory capacity to load a heavily quantized 70B parameter Large Language Model (LLM) or safely run massive context windows on 32B or smaller models (such as DeepSeek-R1-Distill-Qwen-32B) entirely in VRAM. [3, 6, 7] 
* AMD Radeon RX 7900 XT (20GB GDDR6): The slightly scaled-down sibling features 20GB of VRAM on a 320-bit bus. It serves as a more affordable entry point to large-capacity VRAM, capable of running large models up to 34B parameters or tightly quantized 70B models natively. [3, 8] 

------------------------------
## Local Inference Engine Compatibility
Both cards are officially supported by AMD's ROCm software stack on Linux, with rapidly maturing native support on Windows via frameworks that bypass CUDA restrictions. You can effortlessly utilize these GPUs across the following popular engines: [4, 9, 10] 

* Ollama & LM Studio: Both tools natively detect modern AMD Radeon RX 7000-series cards out-of-the-box on both Windows and Linux, utilizing ROCm or Vulkan backends for automated hardware acceleration. [4, 10, 11] 
* Llama.cpp / KoboldCPP: Fully functional utilizing the CLBlast or ROCm compiler paths. [10, 12] 
* vLLM: Fully supported under Linux deployment pipelines for high-throughput batching and serving. [2, 10] 
* Stable Diffusion WebUIs (Automatic1111 / ComfyUI): Directly compatible for accelerated image generation using standard DirectML (Windows) or ROCm (Linux) packages. [2, 10] 

If you plan to scale out your system later, what specific model types or parameter sizes (e.g., 32B vs 70B+) are you looking to host? I can provide the approximate token-per-second generation speeds or detail the multi-GPU scaling constraints of ROCm. [10, 13] 

[1] [https://www.amd.com](https://www.amd.com/en/blogs/2025/how-to-run-openai-gpt-oss-20b-120b-models-on-amd-ryzen-ai-radeon.html)
[2] [https://discuss.huggingface.co](https://discuss.huggingface.co/t/amd-gpu-for-local-inference/167932)
[3] [https://www.promptquorum.com](https://www.promptquorum.com/local-llms/best-amd-gpus-local-llm)
[4] [https://www.corsair.com](https://www.corsair.com/us/en/explorer/diy-builder/how-tos/cpu-vs-gpu-for-local-ai-what-actually-makes-it-faster/)
[5] [https://www.youtube.com](https://www.youtube.com/watch?v=HSEuDSd_jcA)
[6] [https://www.compute-market.com](https://www.compute-market.com/blog/best-amd-gpu-local-llm-inference-2026)
[7] [https://www.reddit.com](https://www.reddit.com/r/radeon/comments/1ijxpn9/amds_larger_vram_on_gaming_gpus_is_a_huge_boon/)
[8] [https://www.scan.co.uk](https://www.scan.co.uk/buying-guides/graphics/amd-cards)
[9] [https://www.bayis.co.uk](https://www.bayis.co.uk/library/78-gpu-market-2026.html)
[10] [https://www.reddit.com](https://www.reddit.com/r/LocalLLaMA/comments/1hqeviv/radeon_gpu_for_local_llm/)
[11] [https://rocm.blogs.amd.com](https://rocm.blogs.amd.com/artificial-intelligence/language-models-locally/README.html)
[12] [https://www.reddit.com](https://www.reddit.com/r/LocalLLaMA/comments/1bia3nr/amd_gpu_for_inference/)
[13] [https://dev.to](https://dev.to/rosgluk/gpus-for-ai-in-2026-nvidia-amd-intel-compared-3gam)

-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------

````

````

-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------


