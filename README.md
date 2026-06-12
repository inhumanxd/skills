# Agent Skills

Canonical home for shared coding-agent skills, OMP agent definitions, and global instruction defaults. Install once; every supported harness reads the same files through symlinks, so editing this repo is immediately live everywhere.

## Layout

| Path | What |
|---|---|
| `skills/<name>/SKILL.md` | Skill definitions — portable across Claude, Copilot, OMP, GitHub, OpenCode |
| `agents/<name>.md` | Agent definitions — OMP-only (they pin OMP model ids and tool sets) |
| `.github/copilot-instructions.md` | Global instruction defaults, installed as `~/.agents/AGENTS.md` |
| `scripts/init.sh` | Installer — wires everything into the harness config dirs |
| `scripts/validate-skills.py` | Structure/discoverability check for skills |
| `evals/` | Behavioral evals for selected skills |

## Install

```sh
scripts/init.sh                    # symlink everything (default; repo stays canonical)
scripts/init.sh --dry-run          # preview every action without changing files
scripts/init.sh --copy             # copy instead of symlink (snapshot; repo edits won't propagate)
scripts/init.sh --no-instructions  # skills + agents only; skip the AGENTS.md globals
```

What it wires:

- `skills/*` → `~/.agents/skills/<name>` → linked into `~/.claude/skills`, `~/.copilot/skills`, `~/.omp/skills`, `~/.github/skills`, `~/.config/opencode/skills`
- `agents/*.md` → `~/.agents/agents/<name>.md` → linked into `~/.omp/agent/agents`
- `.github/copilot-instructions.md` → `~/.agents/AGENTS.md` → linked as `~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md`, `~/.claude/CLAUDE.md`, `~/.omp/AGENTS.md`

Existing real files and directories are backed up as `<path>.backup.<timestamp>` before being replaced — nothing is destroyed.

## Skills

| Skill | Use when |
|---|---|
| `production-grade-code` | Implement, fix, refactor, harden, or review code to senior/staff standards |
| `scope-and-slice` | A request is broad, vague, or multi-layer — decompose into small verifiable slices first |
| `grill-with-docs` | Stress-test a plan against domain language, CONTEXT.md, and ADRs; record resolved decisions |
| `grill-me` | Interview the user relentlessly about a plan or design until shared understanding is reached |
| `handoff` | `/handoff frontend\|backend\|qa\|all` — concise backend-change handoff docs per audience |
| `skill-authoring` | Create, update, or review skills and shared agent instructions |
| `plan-fable-execute-codex` | Multi-model split: Fable plans, Codex builds, Sonnet reviews, Opus red-teams high-stakes (guide below) |

Per-harness specifics (what OMP, Claude Code, and OpenAI Codex each get): see [HARNESSES.md](HARNESSES.md).

## The multi-model workflow

Seven files cooperate (OMP only). The split is strict: **Fable 5 decides; GPT-5.5 gathers and builds; a different Anthropic family reviews** — cross-family review kills self-agreement bias.

| File | Role | Model | Default path? |
|---|---|---|---|
| `skills/plan-fable-execute-codex/SKILL.md` | Orchestration: frame → plan → gate → execute → verify | session model (Fable 5) | yes |
| `agents/fable-architect.md` | Decision maker: consumes scout dossiers, decides, emits a phased plan | `anthropic/claude-fable-5:high` | yes |
| `agents/codex-scout.md` | Context gatherer: read-only investigation, returns citation-dense dossiers | `openai-codex/gpt-5.5:medium` | yes |
| `agents/codex-executor.md` | Builder: implements the plan with full edit/build/test tooling | `openai-codex/gpt-5.5:high` | yes |
| `agents/sonnet-reviewer.md` | Reviewer: diff vs plan — conformance, correctness, security, integrity | `anthropic/claude-sonnet-4-6:high` | yes |
| `agents/opus-redteam.md` | Red team: adversarial attack on high-stakes plans before execution | `anthropic/claude-opus-4-8:high` | high-stakes only |
| `agents/codex-reviewer.md` | Second reviewer: review-tuned model, independent pass on high-stakes diffs | `openai-codex/codex-auto-review:high` | high-stakes only |

### Invoke

Say any of: *"plan with fable, execute with codex"*, *"use the split workflow"*, *"big-brain plan then codex build"* — or frame the task as "plan it well, then implement it". The skill's description carries these triggers, so the orchestrator picks it up automatically. Trivial one-file edits don't need it; the skill tells the orchestrator to just do those directly.

### What happens

1. **Frame** — orchestrator states deliverable, constraints, non-goals. Missing facts are fetched by a `codex-scout`, never by Fable reading breadth.
2. **Plan** — `fable-architect` (id `Architect`) fans out `codex-scout` agents for all investigation, consumes their dossiers, spot-checks only load-bearing claims, and returns Problem / Findings / Plan / Risks / Verification. Every phase carries `files:` and `depends:` markers.
3. **Persist** — the plan is copied once to a file (`local://plan.md`, or the repo's plans dir for durable plans). It is never pasted into prompts again; everything downstream gets the reference.
4. **Gate** — orchestrator checks structure (exact files/symbols named? verification runnable? deps marked?), not the design. Gaps go back to the idle architect over `irc`.
5. **Red-team (high-stakes only)** — plans touching migrations, auth, money, irreversible data, or concurrency get attacked by `opus-redteam` first: kill shots go back to the architect before any execution. Ordinary changes skip this hop entirely.
6. **Execute** — one batch of `codex-executor` spawns, one per independent phase group. Dependent phases are sent to the *same* executor via `irc` (it keeps its context). Executors escalate genuine design forks to the original architect over `irc` — reviving it, not respawning it.
7. **Verify & review (parallel)** — orchestrator runs the union gates (tests/typecheck/lint over changed files) while `sonnet-reviewer` reviews the diff against the plan; high-stakes diffs additionally get an independent pass from `codex-reviewer` (review-tuned, no coordination between reviewers). Gate failures and review blockers route to the owning executor; three failed fixes of the same failure force escalation to the architect (no symptom-patching loops). Blockers clear before cleanup.
8. **Cleanup** — changelog, tests, docs — only after gates pass and blockers are clear.

### Why it's token-efficient

- The plan exists **once**, as a file; agents receive paths, not pasted text.
- Shared background goes in the batch `context` field once, not per assignment.
- Idle/parked agents are **revived by messaging them** — escalations and follow-up phases reuse existing context instead of paying for fresh investigation.
- **Fable never explores.** Raw investigation — file reads, searches, dead ends — runs on GPT-5.5 scouts; Fable pays only for compressed dossiers plus 1–3 spot-check range reads per load-bearing claim.
- The architect writes contracts (signatures, types, schemas), never implementation bodies — the executor retypes code anyway.
- Review is evidence-bound: the reviewer gets the plan path and the diff scope, not a conversation transcript. The red team runs only when stakes justify a second frontier brain.
- Three-strikes caps doomed fix loops — the third identical failure stops burning executor tokens and goes back to design.
- Cache discipline: agent definitions and the batch `context` field are stable prefixes; volatile data (status, timestamps) goes last or not at all. Prompt caching prices repeated input at ~10% — structure, not wording, is what earns it.

### Harness-level levers (OMP, outside this repo)

Set once in `~/.omp/agent/config.yml` — these bill independently of the workflow:

- `modelRoles.smol: anthropic/claude-haiku-4-5:low` — internal operations (compaction summaries, session titles, short summaries) otherwise bill at the default model's frontier rate.
- `modelRoles.commit: anthropic/claude-haiku-4-5:low` — commit-message generation on the cheap tier.
- `modelRoles.slow: anthropic/claude-opus-4-8:high` — the "most capable" role for explicit slow-tier calls; keep it on an authed provider.
- `rtk init -g` + the Claude `PreToolUse` hook — auto-wraps shell commands; historical `rtk gain` shows ~56% shell-output savings, and `rtk discover` lists what raw commands are still leaking.
- Compaction defaults (compact near 85% of context, keep 20K recent, prune stale tool outputs) are already research-aligned; `compaction.strategy: snapcompact` is an experimental option that archives history as image frames for vision models at lower billed cost.

### Why these models (June 2026 data)

- **Opus 4.8 as red team** — leads SWE-bench Pro (69.2% vs GPT-5.5's 58.6%) and honesty metrics (4× more likely to flag flaws in code, 35.9% vs 86% hallucination rate); prompt caching from 1,024 tokens makes its loops cheap. The strongest available second brain, reserved for when stakes justify it.
- **GPT-5.5 as executor/scout** — wins Terminal-Bench 2.0 (78–82% vs Opus's 74.6%), the closest proxy for in-harness agentic build/test loops; also spreads load across both provider subscriptions instead of concentrating rate limits on Anthropic.
- **Sonnet 4.6 as reviewer** — $3/$15 per MTok vs GPT-5.5's $5/$30, 79.6% SWE-bench Verified: frontier-adjacent review at mid-tier price, and cross-family vs the GPT-5.5 author. Practitioner consensus: reviewers from a different company than the author, because single-family review loops self-agree.
- **codex-auto-review as second reviewer** — review-tuned; a second independent pass with different training catches different defects. High-stakes only: review panels are a pro pattern, but two reviewers on every change is orchestration tax.
- **No haiku/mini/nano agent** — mechanical lookups already run on `codex-scout`; below that, dossier quality drops and the architect pays to re-verify, which costs more than the scout saved. Documented as a knob, not a default.

### Prerequisites

- OMP harness with `anthropic/claude-fable-5`, `openai-codex/gpt-5.5`, `anthropic/claude-sonnet-4-6`, `anthropic/claude-opus-4-8`, and `openai-codex/codex-auto-review` authed (`/model` to confirm).
- Agents installed via `scripts/init.sh` so all six agents are discoverable.

### Tuning

- `codex-executor` is pinned `:high`. If plans are consistently tight and execution rarely escalates, drop to `openai-codex/gpt-5.5:medium` in `agents/codex-executor.md` for cheaper builds.
- `codex-scout` is pinned `:medium` — right for navigation and extraction. Raise to `:high` only if dossiers keep missing couplings in gnarly code.
- `sonnet-reviewer` is pinned `:high` — review depth is where regressions get caught; the input (plan + diff) is bounded, so the cost is too.
- `opus-redteam` is opt-in by workflow design, not by model setting. Widen or narrow the "high-stakes" trigger list in the skill to tune how often it runs.
- `codex-scout` can drop to `openai-codex/gpt-5.4-mini:medium` for very large mechanical sweeps where dossier depth matters less than volume — measure whether architect re-verification eats the savings before making it the default.
- **Alternative executor profile:** `anthropic/claude-sonnet-4-6:high` is cheaper per token than GPT-5.5 and scores higher on SWE-bench — but it concentrates all heavy roles on one provider and puts author and reviewer in the same family; if you switch, move review to `codex-reviewer`.

## Validate

```sh
python3 scripts/validate-skills.py
```

Checks frontmatter (kebab-case name, description with trigger language), the 500-line SKILL.md cap, and that relative links resolve.
