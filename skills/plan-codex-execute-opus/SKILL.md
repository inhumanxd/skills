---
name: plan-codex-execute-opus
description: Budget-aware mirror of plan-opus-execute-codex — GPT-5.5/Codex plans, Opus 4.8 builds the token-heavy loop on the abundant Claude budget, GPT-5.5 reviews cross-family. Use when the scarce Codex budget should buy design judgment not the build, when you want GPT-5.5's reasoning on the plan with Opus implementing, or when Codex quota is a fraction of your Claude quota — i.e. "plan with gpt/codex, execute with opus", "orchestrate with gpt, build with claude", "GPT designs, Opus builds". Not for when you want Opus to design the plan (use plan-opus-execute-sonnet), or when Codex budget is healthy enough to build on GPT-5.5 (use plan-opus-execute-codex).
---

# Plan with Codex, execute with Opus

The budget-inverted mirror of `plan-opus-execute-codex`. Same strict cross-family review — **every seat's family is flipped**: here GPT-5.5 decides and reviews, Opus 4.8 builds and red-teams, Sonnet 4.6 scouts. The token-heavy agentic build moves onto the abundant Claude/Opus budget, and the scarce GPT-5.5/Codex budget buys **only** bounded-input work — the plan (authored once) and cross-family review (plan + diff) — where GPT's frontier reasoning is highest-value per token.

| Role | Agent | Model | Default path? |
|---|---|---|---|
| Orchestrator (you): frame, route, gate, verify | — | session (Opus 4.8) | yes |
| Architect: design, trade-offs, the plan | `codex-architect` | `gpt-5.5:high` | yes |
| Scout: read-only context gathering | `sonnet-scout` | `claude-sonnet-4-6:high` | yes |
| Executor: edits, builds, tests | `opus-executor` | `claude-opus-4-8:high` | yes |
| Reviewer: diff vs plan, cross-family | `codex-reviewer` | `gpt-5.5:high` | yes |
| Red team: adversarial plan attack | `opus-redteam` | `claude-opus-4-8:high` | high-stakes only |
| Second reviewer: independent pass, same family as author | `opus-reviewer` | `claude-opus-4-8:high` | high-stakes only |

**Why it still kills self-agreement bias.** Cross-family review only requires the *reviewer* to sit opposite the *author* across the family line. GPT-5.5 plans → Opus (`opus-redteam`) red-teams the plan; Opus builds → GPT-5.5 (`codex-reviewer`) reviews the diff. Both directions cross. The high-stakes second reviewer (`opus-reviewer`) is the same-family independent pass (Anthropic, matching the diff author), mirroring how the codex variant uses GPT-5.5 as its same-family second.

**Budget policy (the reason this variant exists).** GPT-5.5 touches only the two bounded-input seats — the architect (the plan, produced once) and the cross-family reviewer (plan + diff). The long agentic build loop runs on Opus, and even the high-stakes additions (red-team + second review) are both Opus — so GPT spend is **two bounded seats per task regardless of stakes**, never the token-heavy loop. Use this when your Codex/GPT-5.5 quota is a small fraction of your Claude/Opus quota but you still want GPT-5.5's reasoning steering the design. Exploration runs on Sonnet 4.6:high (the Sonnet sub-cap rarely binds first and draws the shared pool ~8–10× slower than Opus); the architect spot-checks every load-bearing claim, so a non-frontier scout costs no design quality.

## When to use vs the other two variants
All three keep the same phases and cross-family review; pick by which budget is scarce and where you want each family's strength:
- **This variant** (`plan-codex-execute-opus`): Codex scarce **and** you want GPT-5.5's design judgment on the plan, Opus doing the heavy build. GPT pays only for plan + review.
- **`plan-opus-execute-sonnet`**: Codex scarce but planning on Opus; Sonnet builds, GPT-5.5 reviews. GPT pays only for review + red-team.
- **`plan-opus-execute-codex`**: Codex healthy; Opus plans and reviews, GPT-5.5 builds (its Terminal-Bench strength).
- **Let usage decide.** Run `omp usage` once and read the **Openai Codex** account. Near its cap (`5 hours`/`7 days` bars ≈ 100%, `× quota left` ≈ 0) → a Codex-light variant (this or the Sonnet one); comfortable headroom → the codex variant. Between this and the Sonnet variant, choose by who should design: GPT-5.5 here, Opus there. The **`Claude 7 Day (Sonnet)`** sub-cap the scout draws rarely binds first; the Opus executor here draws the shared Claude pool ~8–10× faster than Sonnet. Full chooser: the Sonnet budget playbook in the README.

**Right-size the plan.** Reserve `codex-architect` for a real design fork — spending scarce GPT on a no-decision plan is pure waste. Multi-file but mechanically clear → author the short plan yourself (you're Opus) and go straight to execute + review, keeping GPT only in the review seat.

## Procedure, token rules & Sonnet offload
Follow `plan-opus-execute-codex` verbatim — its **Token rules**, 8-step **Procedure**, and **Sonnet offload** section — filling each role from the seat table above. Nearly every seat flips: architect `codex-architect`, executor `opus-executor`, cross-family reviewer `codex-reviewer`, red-team `opus-redteam`, high-stakes second reviewer `opus-reviewer`; only `sonnet-scout` is shared. Persisting the plan once and reviving idle agents save **GPT** tokens here (the architect is GPT-5.5), so never retype the plan.

## Prerequisites
`openai-codex/gpt-5.5`, `anthropic/claude-opus-4-8`, and `anthropic/claude-sonnet-4-6` authed (`/model` to confirm). GPT-5.5 plans and reviews; Opus scouts nothing but builds and red-teams; Sonnet scouts. Agents installed via `scripts/init.sh`. **Minimum-GPT knob:** if Codex is fully exhausted mid-task, the cross-family reviewer falls back to `opus-reviewer` (same-family, degraded — no cross-family review) so GPT touches only the plan; the build is unaffected since it never used GPT-5.5. Single-family fallback (OpenAI down): author the short plan yourself (you're Opus) and run all-Anthropic (Opus build + `opus-reviewer`) — degraded, build unaffected.
