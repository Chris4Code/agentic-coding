# 2026-08-30 · Run 1 · local-models · agent-sandbox-landscape-research

**Type:** `deep-book-research` pass (live web research).

## Triggering request

User asked for a deep-book-research pass on "self-hosted and cloud-hosted agent
sandboxes like E2B, Daytona and Modal Sandboxes" for the **"On Premise Agent
Sandboxes"** section of `src/local-models.md`, with the findings to be written
into that section and compared against **Warp Oz**.

## Seed

- Chapter file: `src/local-models.md` — existing section `## On Premise Agent
  Sandboxes` (subsections: `### Warp and Oz`, `### Ghostty, Alacritty, WezTerm`,
  `### Agent sandboxing`).
- Named products supplied by the user: E2B, Daytona, Modal Sandboxes.
- Prior art extended: `notes/2026-08-29-3-local-models-frontends-proxies-terminals-security/`
  (covered Warp Oz identity/launch/pricing in depth; only lightly listed
  E2B/Daytona/Modal and flagged the section name as not resolving to one product).

## Subtopics targeted (research order)

1. E2B — architecture (Firecracker micro-VMs), open-source status, self-hosting, SDK/runtimes, pricing
2. Daytona — architecture (isolation tech), snapshots, self-hosting, pricing, positioning
3. Modal Sandboxes — architecture (gVisor), serverless infra, filesystem/snapshots, pricing
4. Comparable sandboxes — Cloudflare Sandbox, Vercel Sandbox, Northflank, Runloop, Blaxel, Coder, hopx.ai, others
5. Isolation technology spectrum — containers vs gVisor vs Firecracker/Kata micro-VMs, security/perf trade-offs
6. Self-hosted / bring-your-own-cloud / on-premise deployment options across the market
7. Comparison with Warp Oz — orchestration vs raw sandbox primitive, deployment, models, target user

## Notes

Written live during the run.
