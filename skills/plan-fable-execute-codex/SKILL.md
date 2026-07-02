---
name: plan-fable-execute-codex
description: Decision-layer variant of plan-opus-execute-codex — Claude Fable 5 is the scarce decision brain making ONLY the business-critical calls (design forks, arbitration of conflicting verdicts, go/no-go), Opus 4.8 expands its decision brief into the plan and reviews cross-family, GPT-5.5 builds and red-teams, Sonnet 4.6 scouts. Use when a change carries business-critical decisions — schema/data model, public API contracts, auth/security, money paths, irreversible data, vendor or build-vs-buy calls — i.e. "plan with fable", "fable decides", "use fable as the brain", "fable-opus-codex workflow". Not for tasks without a genuine business-critical fork (use plan-opus-execute-codex) or trivial edits.
---

# Fable decides, Opus plans, Codex builds

The decision-layer variant of `plan-opus-execute-codex`. Same phases, same cross-family review — one seat added on top: **Fable 5 is the decision authority**, and because it is priced far above every other seat, its exposure is capped at bounded decision memos. **Fable decides; Opus 4.8 plans and reviews; GPT-5.5 builds and red-teams; Sonnet 4.6 scouts.**

| Role | Agent | Model | Default path? |
|---|---|---|---|
| Orchestrator (you): frame, route, gate, verify | — | session | yes |
| Decision authority: business-critical forks, arbitration, go/no-go | `fable-principal` | `claude-fable-5:high` | decision points only |
| Architect: expands the decision memo into the phased plan | `opus-architect` | `claude-opus-4-8:high` | yes |
| Scout: read-only context gathering | `sonnet-scout` | `claude-sonnet-4-6:high` | yes |
| Executor: edits, builds, tests | `codex-executor` | `gpt-5.5:high` | yes |
| Reviewer: diff vs plan, cross-family | `opus-reviewer` | `claude-opus-4-8:high` | yes |
| Red team: adversarial plan attack | `codex-redteam` | `gpt-5.5:high` | high-stakes only |
| Second reviewer: independent pass, second family | `codex-reviewer` | `gpt-5.5:high` | high-stakes only |

**Cross-family review still holds.** Anthropic decides and plans (Fable memo → Opus plan) → GPT-5.5 red-teams the plan; GPT-5.5 builds → Opus reviews the diff. Both directions cross the family line.

## The Fable cost contract (the reason this variant exists)

Fable's tokens buy judgment at named decision points — never breadth, never drafting, never loops.

**What reaches Fable (business-critical only):**
- A genuine design fork with cross-cutting or irreversible consequences: data model / schema, public API contracts, auth/permissions model, money paths, irreversible data handling, vendor selection / build-vs-buy, backwards-compat breaks.
- **Arbitration** — conflicting frontier verdicts: architect vs red-team stalemate, dual reviewers disagreeing, an executor rejecting a reviewer blocker.
- A **three-strikes** escalation whose root cause implicates the design, not the implementation.
- **Go/no-go** before executing a high-stakes plan (the red-team trigger list).

**What never reaches Fable:**
- Routine design forks — `opus-architect` decides those (its mandate: pick one, never return a menu).
- Exploration, enumeration, anything a dossier answers — scouts.
- Authoring the phased plan, building, reviewing diffs — Opus/Codex seats.

**Decision packet protocol** (how Fable stays bounded):
- The escalator (you or the architect) prepares a packet ≤ 1 page: the question, the stakes, 2–3 options with cited evidence (`path:line` / dossier refs), a recommendation. Hand references (`local://…`), never pasted transcripts or plans.
- A malformed packet gets bounced back, not reconstructed — prepare it properly.
- Fable returns a memo: **Decision / Rationale / Non-negotiables / Rejected alternatives**. Persist it once (`local://decisions.md`, append per decision) and hand it downstream by reference.
- The plan MUST honor the memo's non-negotiables. A deviation goes back to Fable over `irc`; it is never silently replanned.

**Session already on Fable?** Then YOU are the decision authority: decide inline at the same gates with the same packet discipline (scouts prepare evidence; you never read breadth), and do NOT spawn `fable-principal`. Spawn it only from a non-Fable session.

## Procedure, token rules & Sonnet offload

Follow `plan-opus-execute-codex` verbatim — its **Token rules**, 8-step **Procedure**, and **Sonnet offload** — filling each seat from the table above, with two insertions:

- **Decision gate (between Frame and Plan).** Framing surfaces a business-critical fork → build the packet → `fable-principal` → persist the memo. The memo travels with the frame to `opus-architect`, whose plan states how each non-negotiable is honored. No business-critical fork surfaced → skip Fable entirely; you are running plain `plan-opus-execute-codex` and that is correct, not a degraded mode. A fork surfacing mid-flight (executor escalation, red-team kill shot) routes to Fable the same way, packet first.
- **Arbitration (during Verify & review).** Conflicting frontier verdicts and design-implicating three-strikes failures go to Fable as a packet — never resolved by peer ping-pong or by you splitting the difference. Its ruling is final; overruled seats execute without relitigating.

## Budget flex (Opus and Codex where needed)

The non-Fable seats flex exactly like the sibling variants — the Fable seat never moves. Codex scarce (`omp usage`, **Openai Codex** near cap) → build on `opus-executor` or `sonnet-executor` and flip the diff reviewer to `codex-reviewer`, per `plan-codex-execute-opus` / `plan-opus-execute-sonnet` seat tables; cross-family review is preserved in both directions. Opus-scarce plans prefer the Sonnet executor.

## Prerequisites

`anthropic/claude-fable-5`, `anthropic/claude-opus-4-8`, `openai-codex/gpt-5.5`, and `anthropic/claude-sonnet-4-6` authed (`/model` to confirm). Agents installed via `scripts/init.sh`. Fable unavailable → drop the decision seat and run `plan-opus-execute-codex` unchanged (Opus decides); everything else is unaffected.
