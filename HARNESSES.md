# Harness Guide

What each harness gets after `scripts/init.sh`, where it lands, and how to verify. Everything symlinks back to this repo — edit here, commit, push; no reinstall.

## What lives where

| Chain | Consumers |
|---|---|
| `skills/<name>` → `~/.agents/skills/<name>` → harness skill dirs | OMP, Claude Code, Copilot, GitHub, OpenCode |
| `agents/<name>.md` → `~/.agents/agents/<name>.md` → `~/.omp/agent/agents/` | **OMP only** |
| `.github/copilot-instructions.md` → `~/.agents/AGENTS.md` → harness global files | OMP, Claude Code (`CLAUDE.md`), Codex, OpenCode |

Pre-existing real files were backed up as `<path>.backup.<timestamp>` — deletable once you trust the links.

## OMP (full experience)

The only harness that runs the complete workflow.

- **Skills**: `~/.omp/skills/<name>` — all ten, including `plan-opus-execute-codex`, `plan-opus-execute-sonnet`, `plan-codex-execute-opus`, and `fleet`.
- **Agents**: `~/.omp/agent/agents/*.md` — all ten (`opus-architect`, `codex-architect`, `sonnet-scout`, `codex-executor`, `opus-executor`, `sonnet-executor`, `opus-reviewer`, `codex-reviewer`, `codex-redteam`, `opus-redteam`) with pinned models, tool allowlists, and `spawns` permissions. OMP-specific (`irc`, `agent://`, model pins); not portable.
- **Global defaults**: `~/.omp/AGENTS.md`.
- **Config levers** (`~/.omp/agent/config.yml`, not this repo):
  - `modelRoles.smol` / `commit` → `claude-haiku-4-5:low` — internal summaries, titles, commit messages off the frontier rate.
  - `modelRoles.slow` → `claude-opus-4-8:high`; `modelRoles.plan` → `claude-opus-4-8:high` (Fable retired — the workflow ignores this role anyway and pins `opus-architect` directly).
  - Compaction defaults are research-aligned (compact ~85%, keep 20K recent); leave them.
- **Verify**: `omp models` shows the pins authed; spawning `opus-architect` resolves; `readlink ~/.omp/agent/agents/opus-architect.md` points into `~/.agents/agents/`.

## Claude Code

- **Skills**: `~/.claude/skills/<name>` — all ten discoverable. Caveat: `plan-opus-execute-codex`, `plan-opus-execute-sonnet`, `plan-codex-execute-opus`, and `fleet` reference OMP-only agents; their triggers are explicit phrases so they stay dormant — if invoked, fall back to plan-then-implement (or sequential execution) in one session.
- **Global defaults**: `~/.claude/CLAUDE.md` → shared `AGENTS.md`.
- **rtk**: `PreToolUse` hook in `~/.claude/settings.json` rewrites Bash commands (`git status` → `rtk git status`); `~/.claude/RTK.md` documents the meta commands. Verify with `rtk gain`.
- **Verify**: `readlink ~/.claude/CLAUDE.md` and `~/.claude/skills/production-grade-code` resolve into `~/.agents/`.

## OpenAI Codex (CLI)

- **Global defaults only**: `~/.codex/AGENTS.md` → shared defaults. Codex has no skills dir, so skill files aren't linked; the defaults carry skill-routing, coding standards, and the `rtk` prefix rule.
- The GPT-5.5 side of the workflow (`codex-architect`, `codex-executor`, `codex-redteam`, `codex-reviewer`) runs through OMP's `openai-codex` provider — the Codex CLI itself isn't involved; the Sonnet and Opus agents (`sonnet-scout`, `sonnet-executor`, `opus-architect`, `opus-executor`, `opus-reviewer`, `opus-redteam`) run on the `anthropic` provider.
- **Verify**: `readlink ~/.codex/AGENTS.md` resolves into `~/.agents/`.

## Updating anything

1. Edit the file here.
2. `python3 scripts/validate-skills.py` (skills only).
3. Commit and push — live everywhere immediately via symlinks.
4. New skill or agent file? Run `scripts/init.sh` once to create its links.
