---
name: plan-opus-execute-codex
description: Multi-model workflow that plans with Claude Opus 4.8 (the strongest available reasoner) and executes with OpenAI Codex GPT-5.5, with cross-family diff review by Opus and an optional cross-family GPT-5.5 red team plus a two-family review panel for high-stakes plans. Use when the user wants a feature or non-trivial change planned by the strongest reasoning model and implemented by the coding model — i.e. "plan with opus, execute with gpt-5.5", "use the split workflow", or "big-brain plan then codex build".
---

# Plan with Opus, execute with Codex

Delegation workflow with a strict model split: **Opus 4.8 decides; GPT-5.5 gathers and builds; review always crosses model families** (cross-family review kills self-agreement bias — the authoring family's blind spots are correlated). GPT-5.5's diff is reviewed by Opus; high-stakes Opus plans are red-teamed by GPT-5.5. Two frontier models, two families — every artifact is reviewed across the family line.

| Role | Agent | Model | In default path? |
|---|---|---|---|
| Orchestrator (you): frame, route, gate, verify | — | session (Opus 4.8) | yes |
| Architect: design, trade-offs, the plan | `opus-architect` | `claude-opus-4-8:high` | yes |
| Scout: context gathering, read-only | `codex-scout` | `gpt-5.5:medium` | yes |
| Executor: edits, builds, tests | `codex-executor` | `gpt-5.5:high` | yes |
| Reviewer: diff vs plan, cross-family | `opus-reviewer` | `claude-opus-4-8:high` | yes |
| Red team: adversarial plan attack, cross-family | `codex-redteam` | `gpt-5.5:high` | high-stakes only |
| Second reviewer: independent pass, second family | `codex-reviewer` | `gpt-5.5:high` | high-stakes only |

**Model policy.** Only the two frontier models do load-bearing work — Opus 4.8 for design and review, GPT-5.5 for scouting, building, and red-teaming. The sole sanctioned step down is the scout: exploration may run on Sonnet 4.6 at high thinking (`claude-sonnet-4-6:high`), a capable mid-tier that keeps dossiers sharp at lower cost. Nothing weaker than Sonnet does any workflow work; nothing but the frontier two touches design, review, or implementation.

## Token rules (apply throughout)
- **The architect never explores.** That includes YOU, the orchestrator — both run on Opus. All context gathering — locating code, mapping flows, enumerating callsites, extracting contracts — goes to `codex-scout`. The architect consumes dossiers and spot-checks load-bearing lines only.
- **Context you already hold is not re-scouted.** If the live session already produced the relevant findings, persist them once as a dossier file and hand it to the architect by reference — don't force a re-scout of what you can already cite. Genuinely new gaps still go to `codex-scout`.
- **The plan exists once, as a file.** Hand references (`local://plan.md`), never paste plan text into assignments or retype it.
- **Shared background goes in the batch `context` field once** — never duplicated per assignment.
- **Follow-up work goes to the agent that already holds the context.** `irc` revives idle/parked agents; spawn fresh only when nobody has relevant context.
- **Three strikes.** Any agent that fails the same gate three times stops patching — the failure goes to the architect for root-cause review. Repeated symptom-patching burns tokens and ships nothing.
- **Don't break the cache.** Stable content first, volatile content last: never put timestamps, run ids, or changing status into `context` or early prompt positions; append to a conversation, never rewrite earlier turns. Exact-prefix cache hits price input at ~10% of fresh tokens — structure every spawn for prefix reuse.

## When to use
- Non-trivial features, refactors, or multi-file changes where design quality matters.
- Anything framed as "plan it well, then implement it."

Skip for trivial edits — just do those directly.

**Right-size the plan.** Reserve `opus-architect` for changes with a real design fork — unclear approach, cross-cutting trade-offs, or risky surface. When a change is multi-file but mechanically clear, author the short plan yourself (you are also Opus) and go straight to execute + review. Spawning the architect for a change with no decision to make buys wall-clock and tokens without buying design.

## Procedure

1. **Frame.** One short paragraph: deliverable, constraints, non-goals — from the ask and what you already know. A fact you're missing to frame correctly → spawn a `codex-scout` with the specific question; do NOT read breadth yourself. Never pass vagueness downstream.

2. **Plan.** Spawn `opus-architect` with a stable id (e.g. `Architect`) and the frame. It fans out its own `codex-scout` agents for all investigation, consumes their dossiers, spot-checks the load-bearing claims, and returns Problem / Findings / Plan / Risks & invariants / Verification with per-phase `files:` and `depends:` markers.

3. **Persist once.** Copy the plan to a file — `local://plan.md`, or the repo's plans dir (e.g. `plans/<slug>.md`) when it should outlive the session. If the architect returns raw markdown, `cp` the `agent://Architect` path (internal URIs auto-resolve in bash). If it returns structured output (e.g. JSON with a `plan` field), extract that field with the selector — `read agent://Architect/<field>` — rather than persisting the wrapper. Either way, do NOT retype or summarize the plan — that re-buys what you already paid for.

4. **Review the gate, not the design.** Structural check only: does every phase name exact files and symbols? Is each verification step concretely runnable? Are `depends:` markers present? Spot-check only claims that contradict what you know. Gaps go back to `Architect` via `irc` with the specific deficiency — it is idle, not gone.

5. **Red-team (high-stakes only).** If the plan touches schema migrations, auth/permissions, money paths, irreversible data changes, or concurrency-sensitive code: spawn `codex-redteam` with the plan path and the named stakes — a GPT-5.5 brain attacking the Opus plan from outside its family. Kill shots go to `Architect` for revision before any execution; `STOP` means stop. Skip this step entirely for ordinary changes — the red team is not a default hop.

6. **Execute.** One `task` batch of `codex-executor` spawns — one per independent phase group, derived from the plan's `depends:` markers. Shared `context`: the frame, the plan path, the architect's agent id (for escalation), and build/test commands. Per-task assignment: phase number(s) + acceptance criteria only.
   - **Pin a clean base first.** Before the batch, commit or stash unrelated work (or record the base commit) so the tree holds only this change. Step 7 diffs the review against this base; stray uncommitted work left in the tree gets misread as part of the change.
   - **Dependent phases:** when a phase needs a finished predecessor, `irc` the SAME executor with the next phase instead of spawning a new one — it already holds the conventions it just learned.
   - Executors escalate genuine design forks to the architect over `irc` on their own.

7. **Verify & review (parallel).** Independent checks at once:
   - **Gates (you):** run the union gates across the changed files — narrowest relevant tests, typecheck, lint. For UI or behavioral changes, also *exercise* the change — build plus a render/smoke of the affected surface — since static checks don't prove it runs. Subagents intentionally skip project-wide gates; closing that loop is your job.
   - **Review (`opus-reviewer`):** spawn it with the plan path and an explicit base ref so the reviewed diff equals the plan's diff. A dirty tree (unrelated uncommitted changes) silently poisons the review — pre-existing work gets flagged as scope creep or regression; pin the base from step 6. It returns a verdict with cited blockers/should-fixes.
   - **High-stakes changes get dual review:** spawn `codex-reviewer` in the same batch as `opus-reviewer` — one reviewer per family, independent passes, different catches. Do not let them coordinate.
   - Gate failures and review blockers go to the **owning executor** via `irc` with the exact failing output or finding — it has the context to fix. Fix only trivia yourself. After fixes, `irc` the reviewer(s) for re-review of flagged items. Blockers must clear before cleanup; apply the three-strikes rule.

8. **Cleanup (last).** Only after gates pass and review blockers are clear: changelog, tests, docs, scaffolding removal — in full, before yielding.

## Routing
- Design / architecture / hard reasoning / plan revision → `opus-architect` (Opus 4.8).
- Context gathering / discovery / enumeration → `codex-scout` (GPT-5.5, read-only).
- Edits, builds, runs, mechanical implementation → `codex-executor` (GPT-5.5).
- Diff review against the plan → `opus-reviewer` (Opus 4.8, cross-family).
- Adversarial review of high-stakes plans → `codex-redteam` (GPT-5.5, cross-family, opt-in).
- Second independent review of high-stakes diffs → `codex-reviewer` (GPT-5.5, opt-in).

## Prerequisites
- `anthropic/claude-opus-4-8` and `openai-codex/gpt-5.5` must be authed (`/model` to confirm) — those two models cover every role. The legacy `codex-lb` proxy (`127.0.0.1:2455`) is NOT used by this workflow.
