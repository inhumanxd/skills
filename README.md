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
| `handoff` | `/handoff frontend\|backend\|qa\|all` — concise backend-change handoff docs per audience |
| `skill-authoring` | Create, update, or review skills and shared agent instructions |
| `plan-fable-execute-codex` | Two-model split: strongest reasoning model plans, coding model builds (guide below) |

## The two-model workflow

Four files cooperate (OMP only). The split is strict: **Fable 5 decides; GPT-5.5 does everything else.**

| File | Role | Model |
|---|---|---|
| `skills/plan-fable-execute-codex/SKILL.md` | Orchestration: frame → plan → gate → execute → verify | session model (Fable 5) |
| `agents/fable-architect.md` | Decision maker: consumes scout dossiers, decides, emits a phased plan | `anthropic/claude-fable-5:high` |
| `agents/codex-scout.md` | Context gatherer: read-only investigation, returns citation-dense dossiers | `openai-codex/gpt-5.5:medium` |
| `agents/codex-executor.md` | Builder: implements the plan with full edit/build/test tooling | `openai-codex/gpt-5.5:high` |

### Invoke

Say any of: *"plan with fable, execute with codex"*, *"use the split workflow"*, *"big-brain plan then codex build"* — or frame the task as "plan it well, then implement it". The skill's description carries these triggers, so the orchestrator picks it up automatically. Trivial one-file edits don't need it; the skill tells the orchestrator to just do those directly.

### What happens

1. **Frame** — orchestrator states deliverable, constraints, non-goals. Missing facts are fetched by a `codex-scout`, never by Fable reading breadth.
2. **Plan** — `fable-architect` (id `Architect`) fans out `codex-scout` agents for all investigation, consumes their dossiers, spot-checks only load-bearing claims, and returns Problem / Findings / Plan / Risks / Verification. Every phase carries `files:` and `depends:` markers.
3. **Persist** — the plan is copied once to a file (`local://plan.md`, or the repo's plans dir for durable plans). It is never pasted into prompts again; everything downstream gets the reference.
4. **Gate** — orchestrator checks structure (exact files/symbols named? verification runnable? deps marked?), not the design. Gaps go back to the idle architect over `irc`.
5. **Execute** — one batch of `codex-executor` spawns, one per independent phase group. Dependent phases are sent to the *same* executor via `irc` (it keeps its context). Executors escalate genuine design forks to the original architect over `irc` — reviving it, not respawning it.
6. **Verify** — orchestrator runs the union gates (tests/typecheck/lint over changed files). Failures route back to the owning executor with the failing output.
7. **Cleanup** — changelog, tests, docs — only after the smoke check passes.

### Why it's token-efficient

- The plan exists **once**, as a file; agents receive paths, not pasted text.
- Shared background goes in the batch `context` field once, not per assignment.
- Idle/parked agents are **revived by messaging them** — escalations and follow-up phases reuse existing context instead of paying for fresh investigation.
- **Fable never explores.** Raw investigation — file reads, searches, dead ends — runs on GPT-5.5 scouts; Fable pays only for compressed dossiers plus 1–3 spot-check range reads per load-bearing claim.
- The architect writes contracts (signatures, types, schemas), never implementation bodies — the executor retypes code anyway.

### Prerequisites

- OMP harness with `anthropic/claude-fable-5` and `openai-codex/gpt-5.5` authed (`/model` to confirm).
- Agents installed via `scripts/init.sh` so `fable-architect` / `codex-scout` / `codex-executor` are discoverable.

### Tuning

- `codex-executor` is pinned `:high`. If plans are consistently tight and execution rarely escalates, drop to `openai-codex/gpt-5.5:medium` in `agents/codex-executor.md` for cheaper builds.
- `codex-scout` is pinned `:medium` — right for navigation and extraction. Raise to `:high` only if dossiers keep missing couplings in gnarly code.

## Validate

```sh
python3 scripts/validate-skills.py
```

Checks frontmatter (kebab-case name, description with trigger language), the 500-line SKILL.md cap, and that relative links resolve.
