---
name: plan-opus-execute-sonnet
description: Budget-aware twin of plan-opus-execute-codex — Opus plans, Sonnet 4.6 explores AND builds, GPT-5.5 reviews cross-family. Use when the scarce GPT-5.5/Codex budget must be conserved for review only, when you want the token-heavy build on the Claude/Sonnet quota, or when `omp usage` shows the Openai Codex account near its cap — i.e. "execute with sonnet", "build with claude, review with codex", "conserve codex budget". Not for when Codex budget is healthy and you want GPT-5.5 to build (use plan-opus-execute-codex), or when you want GPT-5.5 to design the plan (use plan-codex-execute-opus).
---

# Plan with Opus, build with Sonnet, review with Codex

The budget-inverted twin of `plan-opus-execute-codex`. Same strict cross-family review — **only the family line is mirrored**: here Claude builds and GPT-5.5 reviews, instead of GPT-5.5 building and Opus reviewing. The token-heavy agentic build moves onto the abundant Claude budget (the Sonnet sub-cap rarely binds first and draws the shared weekly pool ~8–10× slower than Opus), and the scarce GPT-5.5/Codex budget is spent **only** on bounded-input work — review and red-team — where its cross-family value is highest per token.

| Role | Agent | Model | Default path? |
|---|---|---|---|
| Orchestrator (you): frame, route, gate, verify | — | session (Opus 4.8) | yes |
| Architect: design, trade-offs, the plan | `opus-architect` | `claude-opus-4-8:high` | yes |
| Scout: read-only context gathering | `sonnet-scout` | `claude-sonnet-4-6:high` | yes |
| Executor: edits, builds, tests | `sonnet-executor` | `claude-sonnet-4-6:high` | yes |
| Reviewer: diff vs plan, cross-family | `codex-reviewer` | `gpt-5.5:high` | yes |
| Red team: adversarial plan attack | `codex-redteam` | `gpt-5.5:high` | high-stakes only |
| Second reviewer: independent pass, same family as author | `opus-reviewer` | `claude-opus-4-8:high` | high-stakes only |

**Why it still kills self-agreement bias.** Cross-family review only requires the *reviewer* to sit opposite the *author* across the family line. Claude builds → GPT-5.5 (`codex-reviewer`) reviews the diff; GPT-5.5 (`codex-redteam`) red-teams the Opus plan. Both directions still cross. The high-stakes second reviewer (`opus-reviewer`) is the same-family independent pass (Anthropic), mirroring how the codex variant uses GPT-5.5 as its same-family second.

**Model policy.** Reasoning stays on Opus (plan, high-stakes second review). Exploration and the build run on Sonnet 4.6:high — a capable agentic coder following a precise Opus plan, with a GPT-5.5 cross-family review as the regression backstop, so no design quality is traded. GPT-5.5 touches only review and red-team (bounded input: plan + diff), never the long build loop.

## When to use vs `plan-opus-execute-codex`
Same workflow, opposite budget profile; right-size exactly as the codex variant (reserve `opus-architect` for a real design fork; author the short plan yourself when the work is mechanically clear). Pick by which budget is scarce:
- **This variant** when the GPT-5.5/Codex budget is constrained or reserved for review — a Codex plan that throttles fast, or a long build that would drain it. The build lands on the Claude/Sonnet quota.
- **`plan-opus-execute-codex`** when Codex is healthy and you want GPT-5.5's agentic build/test strength (Terminal-Bench lead), with Opus reviewing cross-family.
- **Let usage decide.** Run `omp usage` once and read the **Openai Codex** account: `5 hours`/`7 days` bars near 100% (`× quota left` ≈ 0) → this variant so Codex only reviews; comfortable headroom → the codex variant. The **`Claude 7 Day (Sonnet)`** sub-cap the scout and executor draw from rarely binds first. Full chooser: the Sonnet budget playbook in the README.

## Procedure, token rules & Sonnet offload
Follow `plan-opus-execute-codex` verbatim — its **Token rules**, 8-step **Procedure**, and **Sonnet offload** section — filling each role from the seat table above. Substitutions vs that skill: executor `sonnet-executor` (not `codex-executor`); cross-family reviewer `codex-reviewer` (not `opus-reviewer`); high-stakes second reviewer `opus-reviewer` (not `codex-reviewer`). Architect (`opus-architect`) and red-team (`codex-redteam`) are unchanged. The build already runs on Sonnet here, so the offload section's "reviewed artifacts" lane is the default, not an add-on.

## Prerequisites
`anthropic/claude-opus-4-8`, `anthropic/claude-sonnet-4-6`, and `openai-codex/gpt-5.5` authed (`/model` to confirm). Opus plans and second-reviews; Sonnet scouts and builds; GPT-5.5 reviews and red-teams. Agents installed via `scripts/init.sh`. Single-family fallback (OpenAI down): `opus-reviewer` becomes the sole reviewer — degraded (no cross-family review), but the build is unaffected since it never used GPT-5.5.
