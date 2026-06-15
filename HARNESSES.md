# Harness Guide

What each harness gets from this repo after `scripts/init.sh`, where it lands, and how to verify it. Everything is a symlink back to this repo — edit here, commit, push; no reinstall.

## What lives where

| Chain | Consumers |
|---|---|
| `skills/<name>` → `~/.agents/skills/<name>` → harness skill dirs | OMP, Claude Code, Copilot, GitHub, OpenCode |
| `agents/<name>.md` → `~/.agents/agents/<name>.md` → `~/.omp/agent/agents/` | **OMP only** |
| `.github/copilot-instructions.md` → `~/.agents/AGENTS.md` → harness global files | OMP, Claude Code (`CLAUDE.md`), Codex, OpenCode |

Pre-existing real files were backed up as `<path>.backup.<timestamp>` — deletable once you trust the links.

## OMP (full experience)

The only harness that runs the complete multi-model workflow.

- **Skills**: `~/.omp/skills/<name>` — all seven, including `plan-opus-execute-codex`.
- **Agents**: `~/.omp/agent/agents/*.md` — all six (`opus-architect`, `codex-scout`, `codex-executor`, `opus-reviewer`, `codex-redteam`, `codex-reviewer`) with pinned models, tool allowlists, and `spawns` permissions. These use OMP-specific frontmatter and features (`irc`, `agent://`, model pins) and are not portable.
- **Global defaults**: `~/.omp/AGENTS.md`.
- **Config levers** (in `~/.omp/agent/config.yml`, not this repo):
  - `modelRoles.smol` / `commit` → `claude-haiku-4-5:low` — internal summaries, titles, commit messages off the frontier rate.
  - `modelRoles.slow` → `claude-opus-4-8:high`; `modelRoles.plan` → `claude-opus-4-8:high` (Fable is retired — point the plan role at the architect's model or drop it; the workflow ignores this role anyway and pins `opus-architect` directly).
  - Compaction defaults are research-aligned (compact ~85%, keep 20K recent); leave them.
- **Verify**: `omp models` shows the pinned models authed; spawning `opus-architect` from a session resolves; `readlink ~/.omp/agent/agents/opus-architect.md` points into `~/.agents/agents/`.

## Claude Code

- **Skills**: `~/.claude/skills/<name>` — all seven discoverable.
  - Caveat: `plan-opus-execute-codex` references OMP agents that do not exist in Claude Code. Its triggers are explicit phrases, so it stays dormant; if invoked, treat it as OMP-only and fall back to plan-then-implement in one session.
- **Global defaults**: `~/.claude/CLAUDE.md` → the shared `AGENTS.md` (skill routing + coding/shell defaults).
- **rtk**: `PreToolUse` hook in `~/.claude/settings.json` auto-rewrites Bash commands (`git status` → `rtk git status`); `~/.claude/RTK.md` documents the meta commands. Verify with `rtk gain` after a few commands.
- **Verify**: `readlink ~/.claude/CLAUDE.md` and `readlink ~/.claude/skills/production-grade-code` both resolve into `~/.agents/`.

## OpenAI Codex (CLI)

- **Global defaults only**: `~/.codex/AGENTS.md` → the shared defaults. Codex reads `AGENTS.md`; it has no skills directory, so skill files are not linked.
- The defaults carry the load: skill-routing language, coding standards, and the `rtk` prefix rule all apply to Codex sessions through `AGENTS.md`.
- The GPT-5.5 side of the multi-model workflow (`codex-scout`, `codex-executor`, `codex-redteam`, `codex-reviewer`) runs through OMP's `openai-codex` provider — the Codex CLI itself is not involved.
- **Verify**: `readlink ~/.codex/AGENTS.md` resolves into `~/.agents/`.

## Updating anything

1. Edit the file in this repo.
2. `python3 scripts/validate-skills.py` (skills only).
3. Commit and push. Changes are live in every harness immediately via the symlinks.
4. Added a new skill or agent file? Run `scripts/init.sh` once to create its links.
