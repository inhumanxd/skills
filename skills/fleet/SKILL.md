---
name: fleet
description: Orchestrates a fleet of frontier agents to run independent work in parallel (speed) or attack one hard problem from many angles (best-of-N quality), keeping cross-family review per track. Use when the user asks to launch multiple agents, parallelize tasks, fan out work, run unrelated tasks at once, coordinate a change across multiple repositories, or explore several designs and pick the best. NOT for a single indivisible task or work that all touches the same files.
---

# Fleet — parallel orchestration of frontier agents

You (session, Opus 4.8) are the **commander**: map the work, freeze any shared
contract, dispatch parallel tracks, integrate, review. Each track runs a
`plan-*` workflow — `plan-opus-execute-codex` by default, or a budget variant
(`plan-opus-execute-sonnet`, `plan-codex-execute-opus`) per track — reusing the
existing agents, no new seat. Every track keeps **cross-family review** (the
reviewer always sits opposite the diff's author), so scaling out never trades
away the bias protection.

| Seat | Agent | Model | When |
|---|---|---|---|
| Commander: map, freeze, dispatch, integrate, judge | — | session (Opus 4.8) | always |
| Per-track architect / best-of-N candidate | `opus-architect` | `claude-opus-4-8:high` | design forks |
| Context gatherer | `sonnet-scout` | `claude-sonnet-4-6:high` | breadth lookup |
| Per-track builder | `codex-executor` | `gpt-5.5:high` | every build track |
| Per-track reviewer | `opus-reviewer` | `claude-opus-4-8:high` | every track diff |
| Red team: attack each best-of-N candidate / high-stakes plan | `codex-redteam` | `gpt-5.5:high` | best-of-N; high-stakes |
| Second reviewer: independent pass, second family | `codex-reviewer` | `gpt-5.5:high` | high-stakes only |

## Two modes
- **Speed (fan-out)** — many *different* independent tasks at once. Win =
  wall-clock. Fit: test-coverage sprints, independent bug-bashes, per-package
  migrations, a change rippling across repos.
- **Quality (best-of-N)** — *one* hard problem explored by N architects with
  different framings, then attacked cross-family (`codex-redteam` per candidate)
  before you judge on what survived. Win = a better design at ≈ one architect's
  wall-clock. Fit: genuinely contested design forks.

Step-by-step per mode → [references/modes.md](references/modes.md). Cross-repo
trees, seams, integration → [references/cross-repo.md](references/cross-repo.md).

**Flow:** classify & map → freeze contract (if coupled) → dispatch one `task`
batch → coordinate over `irc` → integrate (union gates + exercise seams) →
review per track → cleanup last.

## Core invariants (these make it genius, not chaos)
1. **Contract-first.** Any interface two tracks share (types, API, schema,
   shared module, cross-repo seam) is designed ONCE, serially, and frozen to
   `local://contract.md` **before** fan-out; tracks build against it. A
   mid-flight change returns to you → re-freeze → broadcast. This serial prefix
   bounds speedup but prevents divergent-contract merge hell.
2. **Disjoint ownership.** Each track owns a disjoint set of files/dirs/repos,
   named in its assignment. No two live tracks write the same file — that makes
   integration a clean merge. Overlap → sequence, or lift the shared file into
   the contract.
3. **Failure isolation.** A track failure degrades only its subtree;
   independents still finish. Three-strikes: a track failing the same gate
   thrice stops patching and reports up; you re-dispatch or
   descope-with-disclosure.
4. **Integration is serial.** Fan-out concentrates the merge/integration/review
   cost — never removes it. Budget the suffix: union gates over *all* changed
   files, **exercise every seam** (not just per-track green), cross-family
   review per track.
5. **Right-size the fleet.** Only fan out genuinely independent, balanced work.
   An indivisible task in fake tracks pays coordination + integration cost on
   serial work — a net loss. Refuse it, say why, run it as one
   `plan-opus-execute-codex` track.

## Token & cache rules
- **Artifacts exist once, as files** (`local://contract.md`, plans) — hand
  paths, never paste; shared background goes in the batch `context` once.
- **Follow-up goes to the agent that holds the context** — `irc` revives
  idle/parked agents; spawn fresh only when nobody holds it.
- **Cache discipline** — stable content first (agent defs, `context`), volatile
  last; append, never rewrite earlier turns.
- **Width cap** — the harness caps 32 concurrent subagents and each track is its
  own tree; keep fleet width ≤ ~6–8, let the pool queue the rest.

## When NOT to use
- A single indivisible task, or work where every unit edits the same hot file →
  one `plan-opus-execute-codex` track.
- Tracks that depend on each other's output in series → no parallelism to win;
  sequence it.
- A trivial edit → just do it.

## Prerequisites
OMP with `anthropic/claude-opus-4-8`, `openai-codex/gpt-5.5`, and
`anthropic/claude-sonnet-4-6` authed (`/model` to confirm); the agents
installed via `scripts/init.sh`. Single-family fallback (OpenAI down): all-Opus
tracks — degraded, no cross-family review.
