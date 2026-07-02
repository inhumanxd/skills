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
| `plan-opus-execute-codex` | Two-family split: Opus plans and reviews, GPT-5.5 builds and red-teams; Sonnet 4.6 scouts (guide below) |
| `plan-opus-execute-sonnet` | Budget twin of the above: Opus plans, Sonnet builds, GPT-5.5 reviews cross-family — conserves a scarce Codex budget (guide below) |
| `plan-codex-execute-opus` | Budget mirror: GPT-5.5/Codex plans, Opus builds the heavy loop, GPT-5.5 reviews cross-family — spends a scarce Codex budget on design, not the build (guide below) |
| `plan-fable-execute-codex` | Decision-layer variant: Fable 5 makes only the business-critical calls (forks, arbitration, go/no-go), Opus expands them into the plan and reviews, GPT-5.5 builds and red-teams (guide below) |
| `fleet` | Launch multiple agents at once: fan out independent work for speed, or attack one hard design from many angles (best-of-N); reuses the six agents (guide below) |

Per-harness specifics: see [HARNESSES.md](HARNESSES.md).

## The multi-model workflow

Seven files cooperate (OMP only). The split is strict: **Opus 4.8 decides and reviews; GPT-5.5 builds and red-teams; Sonnet 4.6 scouts** — review crosses families both ways: Opus reviews GPT-5.5's diff, GPT-5.5 red-teams high-stakes Opus plans. Every load-bearing artifact is reviewed across the family line, which kills self-agreement bias.

| File | Role | Model | Default path? |
|---|---|---|---|
| `skills/plan-opus-execute-codex/SKILL.md` | Orchestration: frame → plan → gate → execute → verify | session model (Opus 4.8) | yes |
| `agents/opus-architect.md` | Decision maker: consumes scout dossiers, decides, emits a phased plan | `anthropic/claude-opus-4-8:high` | yes |
| `agents/sonnet-scout.md` | Context gatherer: read-only investigation, citation-dense dossiers | `anthropic/claude-sonnet-4-6:high` | yes |
| `agents/codex-executor.md` | Builder: implements the plan with full edit/build/test tooling | `openai-codex/gpt-5.5:high` | yes |
| `agents/opus-reviewer.md` | Reviewer: cross-family diff vs plan — conformance, correctness, security, integrity | `anthropic/claude-opus-4-8:high` | yes |
| `agents/codex-redteam.md` | Red team: cross-family adversarial attack on high-stakes plans | `openai-codex/gpt-5.5:high` | high-stakes only |
| `agents/codex-reviewer.md` | Second reviewer: independent high-stakes pass, the second family on the panel | `openai-codex/gpt-5.5:high` | high-stakes only |

### Invoke

Say *"plan with opus, execute with codex"*, *"use the split workflow"*, or *"big-brain plan then codex build"* — or frame it "plan it well, then implement it". Trivial one-file edits skip it.

### What happens

1. **Frame** — deliverable, constraints, non-goals; missing facts come from a `sonnet-scout`, never the architect reading breadth.
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
- **The architect never explores** — raw investigation runs on Sonnet 4.6 scouts (a far cheaper draw: ~8–10× slower on the shared Anthropic pool than Opus, and nothing off GPT — see the Sonnet budget playbook); Opus pays only for dossiers plus 1–3 spot-checks, and writes contracts, not implementation bodies.
- Three-strikes caps doomed fix loops; the third identical failure goes back to design.
- Cache discipline: stable prefixes (agent defs, batch `context`) first, volatile data last — prompt caching prices repeated input at ~10%.

### Harness-level levers (OMP, outside this repo)

Set once in `~/.omp/agent/config.yml`, billed independently of the workflow:

- `modelRoles.smol` / `commit` → `claude-haiku-4-5:low` — internal ops (compaction, titles, commit messages) off the frontier rate.
- `modelRoles.slow` → `claude-opus-4-8:high` — the "most capable" slow-tier role; keep it on an authed provider.
- `rtk init -g` + the Claude `PreToolUse` hook auto-wrap shell commands (~56% shell-output savings historically; `rtk discover` lists leaks).
- Compaction defaults (compact ~85%, keep 20K recent, prune stale tool output) are research-aligned; `compaction.strategy: snapcompact` archives history as image frames for vision models at lower cost.

### Why these models (June 2026 data)

Two frontier models do all load-bearing work — Opus 4.8 (Anthropic) and GPT-5.5 (OpenAI) — so every reviewed artifact crosses the family line. Exploration is the one deliberate step off the frontier: the scout runs Sonnet 4.6:high (capability-matched, never load-bearing); nothing weaker touches the workflow.

- **Opus 4.8 — architect & reviewer:** leads SWE-bench Pro (69.2% vs GPT-5.5's 58.6%) and honesty metrics (4× more likely to flag flaws, 35.9% vs 86% hallucination); the strongest reasoner, so it owns both the plan and the cross-family diff review. Prompt caching from 1,024 tokens keeps its loops cheap.
- **GPT-5.5 — executor, red team, second reviewer:** wins Terminal-Bench 2.0 (78–82% vs Opus's 74.6%), the best proxy for agentic build/test loops, and spreads load off Anthropic. As red team it hits the Opus plan cross-family; as second reviewer it adds the OpenAI family to the high-stakes panel — a fresh same-family-as-author pass, not cross-family distance (that's Opus's job).
- **Sonnet 4.6 — scout (exploration only):** breadth navigation and citation-dense extraction is its capability sweet spot, and scouting is never load-bearing — it gathers facts, makes no design call, and the architect spot-checks every claim it builds on, so a non-frontier scout costs no design quality. At `:high` it keeps dossiers sharp; it draws the shared Anthropic pool ~8–10× slower than Opus (and nothing off GPT), so exploration scales while barely denting frontier spend — see the Sonnet budget playbook.
- **Why not a cheaper reviewer:** review depth is where regressions are caught, so it stays frontier-only — a mid-tier (e.g. Sonnet 4.6) trades catch-rate for tokens on exactly the diffs that matter. Sonnet's place is the *scout*, never a reviewer.
- **No haiku/mini/nano agent:** Sonnet 4.6:high is the floor; below it, dossier quality drops and the architect re-verifies — costing more than the small model saved.

### Prerequisites

- OMP with `anthropic/claude-opus-4-8`, `openai-codex/gpt-5.5`, and `anthropic/claude-sonnet-4-6` authed (`/model` to confirm) — Opus and GPT-5.5 cover the load-bearing roles; Sonnet runs the scout.
- Agents installed via `scripts/init.sh`.

### Tuning

- `codex-executor` `:high` → `:medium` if plans are tight and execution rarely escalates.
- `sonnet-scout` runs `claude-sonnet-4-6:high` — exploration is its capability sweet spot and the architect spot-checks load-bearing claims, so it costs no design quality while keeping breadth off the frontier budget. If a dossier misses a coupling, the architect `irc`s a gap-fill or spot-checks the line itself; for a known-deep investigation pin that one scout to `openai-codex/gpt-5.5:high` for the run.
- `opus-reviewer` stays `:high` — bounded input (plan + diff), high catch value.
- `codex-redteam` is opt-in by the "high-stakes" trigger list in the skill, not by a model setting.
- **Single-family fallback:** if OpenAI is unavailable, run all-Opus (architect / executor / reviewer) — a degraded mode (no cross-family review, and Opus is less agentic in build loops).

### Variant: build with Sonnet (conserve GPT-5.5)

`plan-opus-execute-sonnet` is the budget-inverted twin of the workflow above. Same phases, same cross-family review — only the family line flips: **Sonnet 4.6 builds** (the token-heavy executor, on the abundant Claude/Sonnet budget) and **GPT-5.5 reviews** the diff cross-family, instead of GPT-5.5 building and Opus reviewing. GPT-5.5 then touches only bounded-input work (review + red-team), so a tight Codex quota stretches much further.

| Role | Agent | Model |
|---|---|---|
| Architect (plan) | `opus-architect` | `claude-opus-4-8:high` |
| Scout (explore) | `sonnet-scout` | `claude-sonnet-4-6:high` |
| Executor (build) | `sonnet-executor` | `claude-sonnet-4-6:high` |
| Reviewer (cross-family) | `codex-reviewer` | `gpt-5.5:high` |
| Red team (high-stakes) | `codex-redteam` | `gpt-5.5:high` |
| Second reviewer (high-stakes) | `opus-reviewer` | `claude-opus-4-8:high` |

Only one new agent (`sonnet-executor`) plus the new skill; every other seat reuses an existing agent. Cross-family review holds because it only needs the reviewer opposite the author: Claude builds → GPT-5.5 reviews; GPT-5.5 still red-teams the Opus plan.

### Variant: plan with Codex, execute with Opus (GPT-5.5 budget on design)

`plan-codex-execute-opus` mirrors the workflow above with **every seat's family flipped**. Same phases, same cross-family review — but **GPT-5.5 plans and reviews** while **Opus 4.8 builds** (the token-heavy executor, on the abundant Claude budget) and **red-teams**. GPT-5.5 touches only bounded-input work (the plan, authored once, plus cross-family review), so a Codex quota that's a fraction of your Claude quota still buys frontier design judgment.

| Role | Agent | Model |
|---|---|---|
| Architect (plan) | `codex-architect` | `gpt-5.5:high` |
| Scout (explore) | `sonnet-scout` | `claude-sonnet-4-6:high` |
| Executor (build) | `opus-executor` | `claude-opus-4-8:high` |
| Reviewer (cross-family) | `codex-reviewer` | `gpt-5.5:high` |
| Red team (high-stakes) | `opus-redteam` | `claude-opus-4-8:high` |
| Second reviewer (high-stakes) | `opus-reviewer` | `claude-opus-4-8:high` |

Three new agents (`codex-architect`, `opus-executor`, `opus-redteam`) plus the new skill; the scout and both GPT-5.5 reviewers reuse existing agents. Cross-family review holds in both directions: Opus builds → GPT-5.5 reviews the diff; GPT-5.5 plans → Opus red-teams the plan. Pick this over the Sonnet variant when you want GPT-5.5's reasoning on the *design* (not Opus's), with Opus as the builder.

**Choosing a variant.** All three are invocable by trigger; when unsure or asked to auto-pick, the orchestrator runs `omp usage` once and reads the **Openai Codex** account — near its cap (`5 hours`/`7 days` bars ≈ 100%, `× quota left` ≈ 0) → a Codex-light variant (`plan-opus-execute-sonnet` or `plan-codex-execute-opus`, so Codex does only bounded work); comfortable headroom → `plan-opus-execute-codex` lets GPT-5.5's agentic-build strength do the heavy lifting. Between the two Codex-light variants, pick by who should design (Opus in the Sonnet variant, GPT-5.5 in `plan-codex-execute-opus`) **and by Anthropic headroom**: `plan-codex-execute-opus` builds on Opus — the most Opus-hungry choice — so on a Sonnet-rich, Opus-scarce plan (e.g. Max 5x) default to `plan-opus-execute-sonnet` instead. See the [Sonnet budget playbook](#sonnet-budget-playbook). The `Claude 7 Day (Sonnet)` sub-cap the scout and Sonnet executor draw from rarely binds first; Opus draws the shared pool ~8–10× faster.

### Variant: Fable as the decision brain (business-critical work)

`plan-fable-execute-codex` layers one seat on top of the default workflow: **Claude Fable 5 as decision authority**. Fable is priced far above every other seat, so it touches only bounded decision memos — business-critical design forks (schema/data model, public API contracts, auth/security, money, irreversible data, vendor/build-vs-buy), arbitration of conflicting frontier verdicts, and go/no-go on high-stakes plans. It never explores, never authors the phased plan, never builds, never reviews diffs: escalations arrive as a ≤ 1-page decision packet (question, stakes, 2–3 cited options, recommendation) and leave as a Decision / Rationale / Non-negotiables / Rejected-alternatives memo that `opus-architect` expands into the plan.

| Role | Agent | Model |
|---|---|---|
| Decision authority (business-critical only) | `fable-principal` | `claude-fable-5:high` |
| Architect (plan, honoring the memo) | `opus-architect` | `claude-opus-4-8:high` |
| Scout (explore) | `sonnet-scout` | `claude-sonnet-4-6:high` |
| Executor (build) | `codex-executor` | `gpt-5.5:high` |
| Reviewer (cross-family) | `opus-reviewer` | `claude-opus-4-8:high` |
| Red team (high-stakes) | `codex-redteam` | `gpt-5.5:high` |
| Second reviewer (high-stakes) | `codex-reviewer` | `gpt-5.5:high` |

One new agent (`fable-principal`); every other seat reuses an existing agent. Cross-family review holds in both directions: Anthropic decides and plans (Fable memo → Opus plan) → GPT-5.5 red-teams; GPT-5.5 builds → Opus reviews the diff. No business-critical fork in the task → the decision seat is skipped and the run is plain `plan-opus-execute-codex`; Codex-scarce budgets flex the executor/reviewer seats exactly like the sibling variants while the Fable seat never moves.

## The fleet workflow

Where the multi-model workflow takes ONE task deep, `fleet` takes a PORTFOLIO wide. It's a layer above: the session (Opus 4.8) acts as commander, decomposing work into independent tracks and dispatching each through its own cross-family pipeline — reusing the same six agents, adding no new seat.

Two modes:

- **Speed (fan-out)** — many *different* independent tasks run at once (test-coverage sprints, independent bug-bashes, per-package migrations, a change rippling across repositories). Win = wall-clock.
- **Quality (best-of-N)** — *one* hard problem explored by N `opus-architect` instances with deliberately different framings, then attacked cross-family (`codex-redteam` per candidate) so selection rests on what survives, not on Opus grading Opus; the commander judges and picks/synthesizes. Win = a better design at ≈ one architect's wall-clock.

Three invariants keep it genius rather than chaos: **contract-first** (any shared interface is frozen to `local://contract.md` before fan-out), **disjoint ownership** (no two live tracks write the same file), and **integration is serial** (union gates + exercise every cross-track/cross-repo seam, never just per-track green). The commander refuses fake parallelism — an indivisible task runs as a single `plan-opus-execute-codex` track instead.

### Invoke

Say *"launch multiple agents"*, *"parallelize / fan out these"*, *"do these at once"*, *"this spans multiple repos"*, or *"explore a few designs and pick the best"*. A single indivisible task or a trivial edit skips it.

## Sonnet budget playbook

How to spend a Claude Max plan's Sonnet capacity for better results at no quality cost. The rule everywhere: **Sonnet does breadth and verification; the frontier models (Opus, GPT-5.5) make every load-bearing decision.**

### The budget reality (Max plans)

Max has two weekly limits — an **all-models** ceiling and a **Sonnet-only sub-cap** — but the Sonnet limit sits *inside* the overall pool, not beside it: Sonnet work drains both, Opus only the outer ([Anthropic](https://support.claude.com/en/articles/11049741-what-is-the-max-plan)). So Sonnet is **not a free parallel budget**. What it *is*: ~8–10× cheaper to draw than Opus (Max 5x ≈ 140–280 Sonnet vs 15–35 Opus hours/week — [TechCrunch](https://techcrunch.com/2025/07/28/anthropic-unveils-new-rate-limits-to-curb-claude-code-power-users/)), and its sub-cap almost never binds first. Net: every non-load-bearing unit moved Opus→Sonnet buys ~8–10× more runway on the same plan and reserves Opus's scarce hours for judgment.

### Put on Sonnet (zero quality cost — input to a verified frontier decision)

- **Scout swarm** — fan out more scouts, one per dimension (callsites, tests, conventions, prior art, dependency constraints, git history). The architect spot-checks load-bearing claims, so breadth only removes blind spots.
- **Triage/repro** — a Sonnet scout localizes a failing gate and hands a tight dossier to the frontier executor.
- **Conformance pre-screen** — a Sonnet scout checklists the diff against the plan's acceptance criteria before the authoritative frontier review (which still runs and decides).
- **Library/API research + gate-running** — read external sources; run build/lint/typecheck/test and summarize failures. Deterministic or frontier-verified.

### Put on Sonnet with a backstop (reviewed artifacts)

- The **heavy build** (`sonnet-executor`), **test drafts**, and **cleanup docs** — each backstopped by a cross-family frontier review or by execution (pass/fail is objective). This is the biggest budget lever: the agentic build is the single largest Opus draw.

### Never on Sonnet

The plan/design decision, the authoritative review verdict, the red-team, and arbitration of conflicting findings — frontier + cross-family only.

### Variant choice for a Sonnet-rich, Opus-scarce plan (e.g. Max 5x)

With ~15–35 Opus hours/week, the long agentic build is your biggest Opus draw, so:
- **Default `plan-opus-execute-sonnet`** — Opus only plans; Sonnet does the heavy build (cheap draw); GPT-5.5 reviews cross-family. Maximal Sonnet use, minimal Opus + GPT.
- **`plan-codex-execute-opus`** spends the most Opus (Opus builds) — pick it only when you specifically want Opus's build and have Anthropic headroom.
- **`plan-opus-execute-codex`** keeps the build off Anthropic entirely (GPT-5.5 builds) — best when Codex budget is healthy and you want to spare both Opus and Sonnet.

## Validate

```sh
python3 scripts/validate-skills.py
```

Checks frontmatter (kebab-case name, trigger language), the 500-line SKILL.md cap, and that relative links resolve.
