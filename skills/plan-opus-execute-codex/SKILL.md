---
name: plan-opus-execute-codex
description: Multi-model workflow — plan with Claude Opus 4.8, build with OpenAI Codex GPT-5.5, cross-family review by Opus, optional GPT-5.5 red team + dual review for high-stakes plans. Use when the user wants a feature or non-trivial change planned by the strongest reasoner and built by the coding model — i.e. "plan with opus, execute with gpt-5.5", "use the split workflow", or "big-brain plan then codex build".
---

# Plan with Opus, execute with Codex

Strict model split: **Opus 4.8 decides; GPT-5.5 gathers and builds; review crosses families both ways** — Opus reviews GPT-5.5's diff, GPT-5.5 red-teams high-stakes Opus plans. Cross-family review kills self-agreement bias.

| Role | Agent | Model | Default path? |
|---|---|---|---|
| Orchestrator (you): frame, route, gate, verify | — | session (Opus 4.8) | yes |
| Architect: design, trade-offs, the plan | `opus-architect` | `claude-opus-4-8:high` | yes |
| Scout: read-only context gathering | `codex-scout` | `gpt-5.5:medium` | yes |
| Executor: edits, builds, tests | `codex-executor` | `gpt-5.5:high` | yes |
| Reviewer: diff vs plan, cross-family | `opus-reviewer` | `claude-opus-4-8:high` | yes |
| Red team: adversarial plan attack | `codex-redteam` | `gpt-5.5:high` | high-stakes only |
| Second reviewer: independent pass, second family | `codex-reviewer` | `gpt-5.5:high` | high-stakes only |

**Model policy.** Only Opus 4.8 and GPT-5.5 do load-bearing work. The one step down is the scout, which may run on `claude-sonnet-4-6:high` for cheaper exploration — nothing weaker, and nothing but the frontier two touches design, review, or implementation.

## Token rules (apply throughout)
- **The architect never explores — nor do you.** All context gathering (locating code, mapping flows, enumerating callsites, extracting contracts) goes to `codex-scout`; the architect only consumes dossiers and spot-checks load-bearing lines. Context the live session already holds → persist it once as a dossier and hand it by reference, don't force a re-scout.
- **The plan exists once, as a file.** Hand references (`local://plan.md`); never paste or retype plan text.
- **Shared background goes in the batch `context` field once**, never per assignment.
- **Follow-up goes to the agent that already holds the context** — `irc` revives idle/parked agents; spawn fresh only when nobody has it. A malformed or unparseable yield is the same move: `irc` that agent to re-emit cleanly, read the well-formed siblings meanwhile — never discard the work or re-spawn.
- **Three strikes.** Any agent failing the same gate three times stops patching; the failure goes to the architect for root-cause.
- **Don't break the cache.** Stable content first, volatile last (no timestamps/run-ids/status in `context` or early positions); append, never rewrite earlier turns. Exact-prefix hits price input at ~10%.

## When to use
Non-trivial features, refactors, or multi-file changes where design quality matters — anything framed as "plan it well, then implement it." Skip trivial edits; just do those.

**Right-size the plan.** Reserve `opus-architect` for a real design fork (unclear approach, cross-cutting trade-offs, risky surface). Multi-file but mechanically clear → author the short plan yourself (you're also Opus) and go straight to execute + review. Spawning the architect with no decision to make buys wall-clock and tokens, not design.

## Procedure
1. **Frame.** One paragraph: deliverable, constraints, non-goals. Missing a framing fact → spawn a `codex-scout` for it; never read breadth yourself or pass vagueness downstream.
2. **Plan.** Spawn `opus-architect` (stable id, e.g. `Architect`) with the frame. It fans out its own scouts, consumes dossiers, spot-checks load-bearing claims, and returns Problem / Findings / Plan / Risks & invariants / Verification with per-phase `files:` and `depends:` markers.
3. **Persist once.** Copy the plan to a file (`local://plan.md`, or `plans/<slug>.md` to outlive the session). Raw markdown → `cp` the `agent://Architect` path; structured output (JSON with a `plan` field) → extract it via `read agent://Architect/<field>`, not the wrapper. Never retype or summarize — that re-buys what you paid for.
4. **Gate the structure, not the design.** Every phase names exact files/symbols? Each verification runnable? `depends:` present? Spot-check only claims that contradict what you know. Gaps go back to `Architect` over `irc` — it's idle, not gone.
5. **Red-team (high-stakes only).** Schema migrations, auth/permissions, money, irreversible data, or concurrency → spawn `codex-redteam` with the plan path and named stakes (GPT-5.5 attacking the Opus plan cross-family). Kill shots go to `Architect` before any execution; `STOP` means stop. Skip entirely otherwise.
6. **Execute.** One `task` batch of `codex-executor`, one per independent phase group (from `depends:`). Shared `context`: frame, plan path, architect id (for escalation), build/test commands. Per-task: phase number(s) + acceptance criteria only.
   - **Pin a clean base first** — commit or stash unrelated work so the tree holds only this change; step 7 diffs against this base, and stray uncommitted work reads as part of the change.
   - **Dependent phases** → `irc` the SAME executor with the next phase, not a new spawn; it holds the conventions it just learned.
   - Executors escalate genuine design forks to the architect over `irc` themselves.
7. **Verify & review (parallel).**
   - **Gates (you):** union gates over changed files — narrowest tests, typecheck, lint. UI/behavioral changes → also *exercise* the change (build + render/smoke); static checks don't prove it runs. Subagents skip project-wide gates; that loop is yours.
   - **Review (`opus-reviewer`):** spawn with the plan path and an explicit base ref so the reviewed diff equals the plan's diff — a dirty tree poisons the review (pre-existing work flagged as scope creep/regression). Returns a verdict with cited blockers/should-fixes.
   - **High-stakes → dual review:** add `codex-reviewer` in the same batch — one reviewer per family, independent passes, no coordination.
   - Gate failures and review blockers → the owning executor over `irc` with the exact output/finding; fix only trivia yourself. Re-`irc` the reviewer(s) after fixes. Blockers clear before cleanup; three-strikes applies.
8. **Cleanup (last).** Only after gates pass and blockers clear: changelog, tests, docs, scaffolding removal — in full, before yielding.

## Prerequisites
`anthropic/claude-opus-4-8` and `openai-codex/gpt-5.5` authed (`/model` to confirm) — those two cover every role. The legacy `codex-lb` proxy (`127.0.0.1:2455`) is NOT used.
