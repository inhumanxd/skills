---
name: plan-fable-execute-codex
description: Two-model workflow that plans with Claude Fable 5 (big-brain reasoning) and executes with OpenAI Codex GPT-5.5. Use when the user wants a feature or non-trivial change planned by the strongest reasoning model and implemented by the coding model — i.e. "plan with fable, execute with gpt-5.5", "use the split workflow", or "big-brain plan then codex build".
---

# Plan with Fable, execute with Codex

Delegation workflow with a strict model split. **Fable 5 decides; GPT-5.5 does everything else.**

| Role | Agent | Model |
|---|---|---|
| Orchestrator (you): frame, route, gate, verify | — | session (Fable 5) |
| Architect: design, trade-offs, the plan | `fable-architect` | `anthropic/claude-fable-5:high` |
| Scout: context gathering, read-only | `codex-scout` | `openai-codex/gpt-5.5:medium` |
| Executor: edits, builds, tests | `codex-executor` | `openai-codex/gpt-5.5:high` |

## Token rules (apply throughout)
- **Fable never explores.** That includes YOU, the orchestrator. All context gathering — locating code, mapping flows, enumerating callsites, extracting contracts — goes to `codex-scout`. Fable consumes dossiers and spot-checks load-bearing lines only.
- **The plan exists once, as a file.** Hand references (`local://plan.md`), never paste plan text into assignments or retype it.
- **Shared background goes in the batch `context` field once** — never duplicated per assignment.
- **Follow-up work goes to the agent that already holds the context.** `irc` revives idle/parked agents; spawn fresh only when nobody has relevant context.

## When to use
- Non-trivial features, refactors, or multi-file changes where design quality matters.
- Anything framed as "plan it well, then implement it."

Skip for trivial edits — just do those directly.

## Procedure

1. **Frame.** One short paragraph: deliverable, constraints, non-goals — from the ask and what you already know. A fact you're missing to frame correctly → spawn a `codex-scout` with the specific question; do NOT read breadth yourself. Never pass vagueness downstream.

2. **Plan.** Spawn `fable-architect` with a stable id (e.g. `Architect`) and the frame. It fans out its own `codex-scout` agents for all investigation, consumes their dossiers, spot-checks the load-bearing claims, and returns Problem / Findings / Plan / Risks & invariants / Verification with per-phase `files:` and `depends:` markers.

3. **Persist once.** Copy the plan artifact to a file: `cp` the `agent://Architect` path to `local://plan.md` (internal URIs auto-resolve in bash), or to the repo's plans dir (e.g. `plans/<slug>.md`) when it should outlive the session. Do NOT retype or summarize the plan — that re-buys what you already paid for.

4. **Review the gate, not the design.** Structural check only: does every phase name exact files and symbols? Is each verification step concretely runnable? Are `depends:` markers present? Spot-check only claims that contradict what you know. Gaps go back to `Architect` via `irc` with the specific deficiency — it is idle, not gone.

5. **Execute.** One `task` batch of `codex-executor` spawns — one per independent phase group, derived from the plan's `depends:` markers. Shared `context`: the frame, the plan path, the architect's agent id (for escalation), and build/test commands. Per-task assignment: phase number(s) + acceptance criteria only.
   - **Dependent phases:** when a phase needs a finished predecessor, `irc` the SAME executor with the next phase instead of spawning a new one — it already holds the conventions it just learned.
   - Executors escalate genuine design forks to the architect over `irc` on their own.

6. **Verify.** Run the union gates yourself across the changed files: narrowest relevant tests, typecheck, lint. Subagents intentionally skip project-wide gates; closing that loop is your job.
   - A failure goes back to the **owning executor** via `irc` with the exact failing output — it has the context to fix it. Fix only trivia yourself.

7. **Cleanup (last).** Only after your own smoke check confirms it works: changelog, tests, docs, scaffolding removal — in full, before yielding.

## Routing
- Design / architecture / hard reasoning / plan revision → `fable-architect` (Fable 5).
- Context gathering / discovery / enumeration → `codex-scout` (GPT-5.5, read-only).
- Edits, builds, runs, mechanical implementation → `codex-executor` (GPT-5.5).

## Prerequisites
- `anthropic/claude-fable-5` and `openai-codex/gpt-5.5` must be authed (`/model` to confirm). The legacy `codex-lb` proxy (`127.0.0.1:2455`) is NOT used by this workflow.
