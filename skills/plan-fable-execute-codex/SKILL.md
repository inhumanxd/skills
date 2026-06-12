---
name: plan-fable-execute-codex
description: Multi-model workflow that plans with Claude Fable 5 (big-brain reasoning) and executes with OpenAI Codex GPT-5.5, with cross-family review by Sonnet and optional Opus red-team plus dual review for high-stakes plans. Use when the user wants a feature or non-trivial change planned by the strongest reasoning model and implemented by the coding model — i.e. "plan with fable, execute with gpt-5.5", "use the split workflow", or "big-brain plan then codex build".
---

# Plan with Fable, execute with Codex

Delegation workflow with a strict model split: **Fable 5 decides; GPT-5.5 gathers and builds; a different Anthropic family reviews** (cross-family review kills self-agreement bias — the authoring family's blind spots are correlated).

| Role | Agent | Model | In default path? |
|---|---|---|---|
| Orchestrator (you): frame, route, gate, verify | — | session (Fable 5) | yes |
| Architect: design, trade-offs, the plan | `fable-architect` | `claude-fable-5:high` | yes |
| Scout: context gathering, read-only | `codex-scout` | `gpt-5.5:medium` | yes |
| Executor: edits, builds, tests | `codex-executor` | `gpt-5.5:high` | yes |
| Reviewer: diff vs plan, cross-family | `sonnet-reviewer` | `claude-sonnet-4-6:high` | yes |
| Red team: adversarial plan attack | `opus-redteam` | `claude-opus-4-8:high` | high-stakes only |
| Second reviewer: review-tuned, independent pass | `codex-reviewer` | `codex-auto-review:high` | high-stakes only |

## Token rules (apply throughout)
- **Fable never explores.** That includes YOU, the orchestrator. All context gathering — locating code, mapping flows, enumerating callsites, extracting contracts — goes to `codex-scout`. Fable consumes dossiers and spot-checks load-bearing lines only.
- **The plan exists once, as a file.** Hand references (`local://plan.md`), never paste plan text into assignments or retype it.
- **Shared background goes in the batch `context` field once** — never duplicated per assignment.
- **Follow-up work goes to the agent that already holds the context.** `irc` revives idle/parked agents; spawn fresh only when nobody has relevant context.
- **Three strikes.** Any agent that fails the same gate three times stops patching — the failure goes to the architect for root-cause review. Repeated symptom-patching burns tokens and ships nothing.
- **Don't break the cache.** Stable content first, volatile content last: never put timestamps, run ids, or changing status into `context` or early prompt positions; append to a conversation, never rewrite earlier turns. Exact-prefix cache hits price input at ~10% of fresh tokens — structure every spawn for prefix reuse.

## When to use
- Non-trivial features, refactors, or multi-file changes where design quality matters.
- Anything framed as "plan it well, then implement it."

Skip for trivial edits — just do those directly.

## Procedure

1. **Frame.** One short paragraph: deliverable, constraints, non-goals — from the ask and what you already know. A fact you're missing to frame correctly → spawn a `codex-scout` with the specific question; do NOT read breadth yourself. Never pass vagueness downstream.

2. **Plan.** Spawn `fable-architect` with a stable id (e.g. `Architect`) and the frame. It fans out its own `codex-scout` agents for all investigation, consumes their dossiers, spot-checks the load-bearing claims, and returns Problem / Findings / Plan / Risks & invariants / Verification with per-phase `files:` and `depends:` markers.

3. **Persist once.** Copy the plan artifact to a file: `cp` the `agent://Architect` path to `local://plan.md` (internal URIs auto-resolve in bash), or to the repo's plans dir (e.g. `plans/<slug>.md`) when it should outlive the session. Do NOT retype or summarize the plan — that re-buys what you already paid for.

4. **Review the gate, not the design.** Structural check only: does every phase name exact files and symbols? Is each verification step concretely runnable? Are `depends:` markers present? Spot-check only claims that contradict what you know. Gaps go back to `Architect` via `irc` with the specific deficiency — it is idle, not gone.

5. **Red-team (high-stakes only).** If the plan touches schema migrations, auth/permissions, money paths, irreversible data changes, or concurrency-sensitive code: spawn `opus-redteam` with the plan path and the named stakes. Kill shots go to `Architect` for revision before any execution; `STOP` means stop. Skip this step entirely for ordinary changes — the red team is not a default hop.

6. **Execute.** One `task` batch of `codex-executor` spawns — one per independent phase group, derived from the plan's `depends:` markers. Shared `context`: the frame, the plan path, the architect's agent id (for escalation), and build/test commands. Per-task assignment: phase number(s) + acceptance criteria only.
   - **Dependent phases:** when a phase needs a finished predecessor, `irc` the SAME executor with the next phase instead of spawning a new one — it already holds the conventions it just learned.
   - Executors escalate genuine design forks to the architect over `irc` on their own.

7. **Verify & review (parallel).** Independent checks at once:
   - **Gates (you):** run the union gates across the changed files — narrowest relevant tests, typecheck, lint. Subagents intentionally skip project-wide gates; closing that loop is your job.
   - **Review (`sonnet-reviewer`):** spawn it with the plan path and the diff scope (changed files or base ref). It returns a verdict with cited blockers/should-fixes.
   - **High-stakes changes get dual review:** spawn `codex-reviewer` in the same batch as `sonnet-reviewer` — independent passes, different training, different catches. Do not let them coordinate.
   - Gate failures and review blockers go to the **owning executor** via `irc` with the exact failing output or finding — it has the context to fix. Fix only trivia yourself. After fixes, `irc` the reviewer(s) for re-review of flagged items. Blockers must clear before cleanup; apply the three-strikes rule.

8. **Cleanup (last).** Only after gates pass and review blockers are clear: changelog, tests, docs, scaffolding removal — in full, before yielding.

## Routing
- Design / architecture / hard reasoning / plan revision → `fable-architect` (Fable 5).
- Context gathering / discovery / enumeration → `codex-scout` (GPT-5.5, read-only).
- Edits, builds, runs, mechanical implementation → `codex-executor` (GPT-5.5).
- Diff review against the plan → `sonnet-reviewer` (Sonnet 4.6, cross-family).
- Adversarial review of high-stakes plans → `opus-redteam` (Opus 4.8, opt-in).
- Second independent review of high-stakes diffs → `codex-reviewer` (codex-auto-review, opt-in).

## Prerequisites
- `anthropic/claude-fable-5`, `openai-codex/gpt-5.5`, `anthropic/claude-sonnet-4-6`, `anthropic/claude-opus-4-8`, and `openai-codex/codex-auto-review` must be authed (`/model` to confirm). The legacy `codex-lb` proxy (`127.0.0.1:2455`) is NOT used by this workflow.
