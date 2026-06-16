# Agent Skills

Canonical home for shared coding-agent skills, OMP agent definitions, and global instruction defaults. Install once; every harness reads the same files through symlinks, so editing this repo is live everywhere.

## Layout

| Path | What |
|---|---|
| `skills/<name>/SKILL.md` | Skill definitions — portable across Claude, Copilot, OMP, GitHub, OpenCode |
| `agents/<name>.md` | Agent definitions — OMP-only (pin OMP model ids and tool sets) |
| `.github/copilot-instructions.md` | Global instruction defaults, installed as `~/.agents/AGENTS.md` |
| `scripts/init.sh` | Installer — wires everything into the harness config dirs |
| `scripts/validate-skills.py` | Structure/discoverability check for skills |
| `evals/` | Behavioral evals for selected skills |

## Install

```sh
scripts/init.sh                    # symlink everything (default; repo stays canonical)
scripts/init.sh --dry-run          # preview every action
scripts/init.sh --copy             # copy instead of symlink (snapshot; edits won't propagate)
scripts/init.sh --no-instructions  # skills + agents only; skip the AGENTS.md globals
```

Everything links through `~/.agents/` into each harness's config dir: `skills/*` into all five skill dirs, `agents/*.md` into `~/.omp/agent/agents` only, and `.github/copilot-instructions.md` as `~/.agents/AGENTS.md` → each harness's global file. Pre-existing real files are backed up as `<path>.backup.<timestamp>` — nothing is destroyed.

## Skills

| Skill | Use when |
|---|---|
| `production-grade-code` | Implement, fix, refactor, harden, or review code to senior/staff standards |
| `scope-and-slice` | A request is broad, vague, or multi-layer — decompose into small verifiable slices first |
| `grill-with-docs` | Stress-test a plan against domain language, CONTEXT.md, and ADRs; record resolved decisions |
| `grill-me` | Interview the user relentlessly about a plan or design until shared understanding is reached |
| `handoff` | `/handoff frontend\|backend\|qa\|all` — concise backend-change handoff docs per audience |
| `skill-authoring` | Create, update, or review skills and shared agent instructions |
| `plan-opus-execute-codex` | Two-family split: Opus plans and reviews; GPT-5.5 scouts, builds, and red-teams high-stakes plans (guide below) |
| `fleet` | Launch multiple agents at once: fan out independent work for speed, or attack one hard design from many angles (best-of-N); reuses the six agents (guide below) |

Per-harness specifics: see [HARNESSES.md](HARNESSES.md).

## The multi-model workflow

Seven files cooperate (OMP only). The split is strict: **Opus 4.8 decides; GPT-5.5 gathers and builds; review crosses families both ways** — Opus reviews GPT-5.5's diff, GPT-5.5 red-teams high-stakes Opus plans. Every artifact is reviewed across the family line, which kills self-agreement bias.

| File | Role | Model | Default path? |
|---|---|---|---|
| `skills/plan-opus-execute-codex/SKILL.md` | Orchestration: frame → plan → gate → execute → verify | session model (Opus 4.8) | yes |
| `agents/opus-architect.md` | Decision maker: consumes scout dossiers, decides, emits a phased plan | `anthropic/claude-opus-4-8:high` | yes |
| `agents/codex-scout.md` | Context gatherer: read-only investigation, citation-dense dossiers | `openai-codex/gpt-5.5:medium` | yes |
| `agents/codex-executor.md` | Builder: implements the plan with full edit/build/test tooling | `openai-codex/gpt-5.5:high` | yes |
| `agents/opus-reviewer.md` | Reviewer: cross-family diff vs plan — conformance, correctness, security, integrity | `anthropic/claude-opus-4-8:high` | yes |
| `agents/codex-redteam.md` | Red team: cross-family adversarial attack on high-stakes plans | `openai-codex/gpt-5.5:high` | high-stakes only |
| `agents/codex-reviewer.md` | Second reviewer: independent high-stakes pass, the second family on the panel | `openai-codex/gpt-5.5:high` | high-stakes only |

### Invoke

Say *"plan with opus, execute with codex"*, *"use the split workflow"*, or *"big-brain plan then codex build"* — or frame it "plan it well, then implement it". Trivial one-file edits skip it.

### What happens

1. **Frame** — deliverable, constraints, non-goals; missing facts come from a `codex-scout`, never the architect reading breadth.
2. **Plan** — `opus-architect` fans out scouts, spot-checks load-bearing claims, returns Problem / Findings / Plan / Risks / Verification with per-phase `files:` and `depends:` markers.
3. **Persist** — the plan is copied once to a file; everything downstream gets the path, never pasted text.
4. **Gate** — orchestrator checks structure (files/symbols named? verification runnable? deps marked?), not design; gaps go back to the idle architect over `irc`.
5. **Red-team (high-stakes only)** — migrations / auth / money / irreversible data / concurrency get a `codex-redteam` pass first; kill shots return to the architect before execution.
6. **Execute** — a `codex-executor` batch, one per independent phase group; dependent phases reuse the same executor via `irc`; design forks escalate to the architect.
7. **Verify & review (parallel)** — orchestrator runs union gates (and *exercises* UI/behavioral changes) while `opus-reviewer` reviews the diff vs plan against a pinned base; high-stakes adds an independent `codex-reviewer`. Blockers route to the owning executor (three-strikes caps fix loops) and clear before cleanup.
8. **Cleanup** — changelog, tests, docs, last.

### Why it's token-efficient

- The plan and shared background exist **once**; agents get paths and a single batch `context`, not pasted text.
- Idle/parked agents are revived by messaging — escalations and follow-up phases reuse context instead of re-investigating.
- **The architect never explores** — raw investigation runs on GPT-5.5 scouts; Opus pays only for dossiers plus 1–3 spot-checks, and writes contracts, not implementation bodies.
- Three-strikes caps doomed fix loops; the third identical failure goes back to design.
- Cache discipline: stable prefixes (agent defs, batch `context`) first, volatile data last — prompt caching prices repeated input at ~10%.

### Harness-level levers (OMP, outside this repo)

Set once in `~/.omp/agent/config.yml`, billed independently of the workflow:

- `modelRoles.smol` / `commit` → `claude-haiku-4-5:low` — internal ops (compaction, titles, commit messages) off the frontier rate.
- `modelRoles.slow` → `claude-opus-4-8:high` — the "most capable" slow-tier role; keep it on an authed provider.
- `rtk init -g` + the Claude `PreToolUse` hook auto-wrap shell commands (~56% shell-output savings historically; `rtk discover` lists leaks).
- Compaction defaults (compact ~85%, keep 20K recent, prune stale tool output) are research-aligned; `compaction.strategy: snapcompact` archives history as image frames for vision models at lower cost.

### Why these models (June 2026 data)

Two frontier models do all load-bearing work — Opus 4.8 (Anthropic) and GPT-5.5 (OpenAI) — so every artifact is reviewed across the family line. The only step down is the scout (optionally Sonnet 4.6:high); nothing weaker touches the workflow.

- **Opus 4.8 — architect & reviewer:** leads SWE-bench Pro (69.2% vs GPT-5.5's 58.6%) and honesty metrics (4× more likely to flag flaws, 35.9% vs 86% hallucination); the strongest reasoner, so it owns both the plan and the cross-family diff review. Prompt caching from 1,024 tokens keeps its loops cheap.
- **GPT-5.5 — scout, executor, red team, second reviewer:** wins Terminal-Bench 2.0 (78–82% vs Opus's 74.6%), the best proxy for agentic build/test loops, and spreads load off Anthropic. As red team it hits the Opus plan cross-family; as second reviewer it adds the OpenAI family to the high-stakes panel — a fresh same-family-as-author pass, not cross-family distance (that's Opus's job).
- **Why not a cheaper reviewer:** review depth is where regressions are caught, so it stays frontier-only — a mid-tier (e.g. Sonnet 4.6) trades catch-rate for tokens on exactly the diffs that matter. Sonnet earns its place as the cheaper *scout*, not as a reviewer.
- **No haiku/mini/nano agent:** Sonnet 4.6:high is the floor; below it, dossier quality drops and the architect re-verifies — costing more than the small model saved.

### Prerequisites

- OMP with `anthropic/claude-opus-4-8` and `openai-codex/gpt-5.5` authed (`/model` to confirm) — two models cover every role.
- Agents installed via `scripts/init.sh`.

### Tuning

- `codex-executor` `:high` → `:medium` if plans are tight and execution rarely escalates.
- `codex-scout` `:medium` is right for navigation; raise to `:high` only if dossiers miss couplings. For cheaper exploration it can run `anthropic/claude-sonnet-4-6:high` — the one sanctioned sub-frontier step (keeps dossiers sharp, but moves the scout off the OpenAI provider; making it default means renaming to `sonnet-scout`).
- `opus-reviewer` stays `:high` — bounded input (plan + diff), high catch value.
- `codex-redteam` is opt-in by the "high-stakes" trigger list in the skill, not by a model setting.
- **Single-family fallback:** if OpenAI is unavailable, run all-Opus (architect / executor / reviewer) — a degraded mode (no cross-family review, and Opus is less agentic in build loops).

## The fleet workflow

Where the multi-model workflow takes ONE task deep, `fleet` takes a PORTFOLIO wide. It's a layer above: the session (Opus 4.8) acts as commander, decomposing work into independent tracks and dispatching each through its own cross-family pipeline — reusing the same six agents, adding no new seat.

Two modes:

- **Speed (fan-out)** — many *different* independent tasks run at once (test-coverage sprints, independent bug-bashes, per-package migrations, a change rippling across repositories). Win = wall-clock.
- **Quality (best-of-N)** — *one* hard problem explored by N `opus-architect` instances with deliberately different framings, then attacked cross-family (`codex-redteam` per candidate) so selection rests on what survives, not on Opus grading Opus; the commander judges and picks/synthesizes. Win = a better design at ≈ one architect's wall-clock.

Three invariants keep it genius rather than chaos: **contract-first** (any shared interface is frozen to `local://contract.md` before fan-out), **disjoint ownership** (no two live tracks write the same file), and **integration is serial** (union gates + exercise every cross-track/cross-repo seam, never just per-track green). The commander refuses fake parallelism — an indivisible task runs as a single `plan-opus-execute-codex` track instead.

### Invoke

Say *"launch multiple agents"*, *"parallelize / fan out these"*, *"do these at once"*, *"this spans multiple repos"*, or *"explore a few designs and pick the best"*. A single indivisible task or a trivial edit skips it.

## Validate

```sh
python3 scripts/validate-skills.py
```

Checks frontmatter (kebab-case name, trigger language), the 500-line SKILL.md cap, and that relative links resolve.
