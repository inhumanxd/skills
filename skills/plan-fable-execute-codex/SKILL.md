---
name: plan-fable-execute-codex
description: Two-model workflow that plans with Claude Fable 5 (big-brain reasoning) and executes with OpenAI Codex GPT-5.5. Use when the user wants a feature or non-trivial change planned by the strongest reasoning model and implemented by the coding model — i.e. "plan with fable, execute with gpt-5.5", "use the split workflow", or "big-brain plan then codex build".
---

# Plan with Fable, execute with Codex

Delegation workflow: the **big brain** (`fable-architect`, `anthropic/claude-fable-5:high`) designs; the **executor** (`codex-executor`, `openai-codex/gpt-5.5:high`) builds. You orchestrate: frame, route, verify. Models are pinned in the agent files — spawning routes automatically.

## Token rules (apply throughout)
- **The plan exists once, as a file.** Hand references (`local://plan.md`), never paste plan text into assignments or retype it.
- **Shared background goes in the batch `context` field once** — never duplicated per assignment.
- **Follow-up work goes to the agent that already holds the context.** `irc` revives idle/parked agents; spawn fresh only when nobody has relevant context.
- **Mechanical lookups** (where does X live, list callsites, map a package) → `explore` / `quick_task`. Never spend Fable tokens on enumeration.

## When to use
- Non-trivial features, refactors, or multi-file changes where design quality matters.
- Anything framed as "plan it well, then implement it."

Skip for trivial edits — just do those directly.

## Procedure

1. **Frame.** One short paragraph: deliverable, constraints, non-goals. Resolve unknowns from the repo (delegate breadth to `explore`) before delegating; never pass vagueness downstream.

2. **Plan.** Spawn `fable-architect` with a stable id (e.g. `Architect`) and the frame. It investigates read-only — fanning out its own `explore` scouts for breadth — and returns Problem / Findings / Plan / Risks & invariants / Verification, with per-phase `files:` and `depends:` markers.

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
- Edits, builds, runs, mechanical implementation → `codex-executor` (GPT-5.5).
- Mechanical discovery / enumeration → `explore` (read-only) or `quick_task`.

## Prerequisites
- `anthropic/claude-fable-5` and `openai-codex/gpt-5.5` must be authed (`/model` to confirm). The legacy `codex-lb` proxy (`127.0.0.1:2455`) is NOT used by this workflow.
