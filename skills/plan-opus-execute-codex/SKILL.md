---
name: plan-opus-execute-codex
description: Multi-model workflow — plan with Claude Opus 4.8, build with OpenAI Codex GPT-5.5, cross-family review by Opus, optional GPT-5.5 red team + dual review for high-stakes plans. Use when the user wants a feature or non-trivial change planned by the strongest reasoner and built by the coding model — i.e. "plan with opus, execute with gpt-5.5", "use the split workflow", or "big-brain plan then codex build". Not for trivial one-file edits, or when the Codex/GPT-5.5 budget is scarce (use plan-opus-execute-sonnet or plan-codex-execute-opus).
---

# Plan with Opus, execute with Codex

Strict model split: **Opus 4.8 decides and reviews; GPT-5.5 builds and red-teams; Sonnet 4.6 scouts** — review still crosses families both ways: Opus reviews GPT-5.5's diff, GPT-5.5 red-teams high-stakes Opus plans. Cross-family review kills self-agreement bias.

| Role | Agent | Model | Default path? |
|---|---|---|---|
| Orchestrator (you): frame, route, gate, verify | — | session (Opus 4.8) | yes |
| Architect: design, trade-offs, the plan | `opus-architect` | `claude-opus-4-8:high` | yes |
| Scout: read-only context gathering | `sonnet-scout` | `claude-sonnet-4-6:high` | yes |
| Executor: edits, builds, tests | `codex-executor` | `gpt-5.5:high` | yes |
| Reviewer: diff vs plan, cross-family | `opus-reviewer` | `claude-opus-4-8:high` | yes |
| Red team: adversarial plan attack | `codex-redteam` | `gpt-5.5:high` | high-stakes only |
| Second reviewer: independent pass, second family | `codex-reviewer` | `gpt-5.5:high` | high-stakes only |

**Model policy.** Load-bearing work — design, implementation, review, red-team — stays on the two frontier families (Opus 4.8, GPT-5.5), reviewed across the family line. Exploration is the deliberate exception: `sonnet-scout` runs `claude-sonnet-4-6:high` because breadth-gathering is its capability sweet spot, not a bottleneck — the architect spot-checks every load-bearing claim, so a non-frontier scout costs no design quality while keeping breadth off the frontier draw (Sonnet runs ~8–10× cheaper than Opus on the shared Anthropic pool, and nothing off GPT). Nothing weaker than Sonnet 4.6:high gathers; nothing but the frontier two touches design, review, or implementation.

## Token rules (apply throughout)
- **The architect never explores — nor do you.** All context gathering (locating code, mapping flows, enumerating callsites, extracting contracts) goes to `sonnet-scout`; the architect only consumes dossiers and spot-checks load-bearing lines. Context the live session already holds → persist it once as a dossier and hand it by reference, don't force a re-scout.
- **The plan exists once, as a file.** Hand references (`local://plan.md`); never paste or retype plan text.
- **Shared background goes in the batch `context` field once**, never per assignment.
- **Follow-up goes to the agent that already holds the context** — `irc` revives idle/parked agents; spawn fresh only when nobody has it. A malformed or unparseable yield is the same move: `irc` that agent to re-emit cleanly, read the well-formed siblings meanwhile — never discard the work or re-spawn.
- **Three strikes.** Any agent failing the same gate three times stops patching; the failure goes to the architect for root-cause.
- **Don't break the cache.** Stable content first, volatile last (no timestamps/run-ids/status in `context` or early positions); append, never rewrite earlier turns. Exact-prefix hits price input at ~10%.

## When to use
Non-trivial features, refactors, or multi-file changes where design quality matters — anything framed as "plan it well, then implement it." Skip trivial edits; just do those.

**Right-size the plan.** Reserve `opus-architect` for a real design fork (unclear approach, cross-cutting trade-offs, risky surface). Multi-file but mechanically clear → author the short plan yourself (you're also Opus) and go straight to execute + review. Spawning the architect with no decision to make buys wall-clock and tokens, not design.

**Budget variants.** This path spends the scarce GPT-5.5/Codex budget on the token-heavy executor. If that budget is constrained — or `omp usage` shows the **Openai Codex** account near its cap (`5 hours`/`7 days` bars ≈ 100%, `× quota left` ≈ 0) — switch to a Codex-light mirror: `plan-opus-execute-sonnet` (Sonnet builds, Opus still plans) or `plan-codex-execute-opus` (GPT-5.5 plans, Opus builds). Both keep GPT-5.5 to bounded-input work only. When asked to pick automatically, read `omp usage` once and route on Codex headroom; full chooser in the README's Sonnet budget playbook.

## Procedure
1. **Frame.** One paragraph: deliverable, constraints, non-goals. Missing a framing fact → spawn a `sonnet-scout` for it; never read breadth yourself or pass vagueness downstream.
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

## Sonnet offload (cheap breadth + verification)
Sonnet draws the shared Anthropic weekly pool ~8–10× slower than Opus and its sub-cap rarely binds first, so push every non-load-bearing unit onto `sonnet-scout` — it buys far more runway and reserves the frontier budgets for judgment. None owns a decision, so none can degrade output:
- **Scout swarm.** Prefer MORE scouts over fewer — one per dimension (callsites via `lsp references`, test inventory + run commands, conventions/prior art, dependency/version constraints, git-blame "why"). The architect spot-checks load-bearing claims, so extra breadth only removes blind spots.
- **Triage/repro.** A failing gate → a `sonnet-scout` localizes the failure and collects the exact code + context before the frontier executor fixes — the fix loop starts from a diagnosis, not a cold read.
- **Conformance pre-screen.** Before the authoritative review, a `sonnet-scout` checklists the diff against each phase's acceptance criteria (touched vs. the `lsp references` list) and flags mechanical misses; the frontier review still runs and decides.
- **Reviewed artifacts (where a Sonnet writer is in the roster).** Heavy build, test drafts, and cleanup docs on a Sonnet executor, each backstopped by cross-family review or by execution — or switch to `plan-opus-execute-sonnet` to make that the default.
- **Never Sonnet:** the plan/design, the authoritative review verdict, red-team, arbitration of conflicting findings — frontier + cross-family only. Full rationale: the Sonnet budget playbook in the README.

## Prerequisites
`anthropic/claude-opus-4-8`, `openai-codex/gpt-5.5`, and `anthropic/claude-sonnet-4-6` authed (`/model` to confirm) — Opus and GPT-5.5 cover the load-bearing roles, Sonnet runs the scout. The legacy `codex-lb` proxy (`127.0.0.1:2455`) is NOT used.
