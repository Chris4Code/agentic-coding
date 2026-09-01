# 2026-08-21 · run 1 · rag-cache-augmented-generation-fact-check

**Skill:** fact-check
**Chapter:** src/rags.md
**Scope:** whole chapter

## Trigger

Follow-up to the `basics.md` fact-check pass in the same session: user asked to continue the same corroboration effort on `rags.md`, the next chapter with zero existing `Research Note:` paragraphs (alongside `agentic-coding-harnesses.md`, not yet done).

## Input materials

- `notes/initial-notes/RAG.md` — sole original source for the whole chapter (bridging-local-DB-to-cloud patterns, Standardized Retrieval Plugin Architecture, Dual-Embedding/Hybrid-Embedding architectures, the three-tier CAG hybrid framework, LLM pipeline categories); a single ungrounded Gemini chat, no independent verification done since.
- Prior-art search across `notes/` for RAG/CAG/hybrid-embedding/retrieval-plugin/RRF terms found no other folder touching this content — confirmed nothing to avoid duplicating.
- Six subtopics identified from reading the chapter: (1) OpenAI ChatGPT Retrieval Plugin (existence, current status, endpoint spec), (2) `text-embedding-3-large` dimensionality and the dimension-matching constraint, (3) "Dual-Embedding"/"Hybrid-Embedding" as an architecture pattern, (4) retrieval fusion/reranking techniques (Reciprocal Rank Fusion, cross-encoder/BGE-Reranker), (5) Cache-Augmented Generation (CAG) as a concept and its cited savings figures, (6) the chapter's own "three-tier hybrid architecture" (cold/warm/hot combining CAG + dual-embedding) — flagged as a likely single-chat synthesis rather than an established, named industry pattern, worth checking explicitly for real-world adoption.
