#!/usr/bin/env bash
set -euo pipefail

# Install these skills into a single global source of truth and wire the common
# agent-specific locations to it.
#
# Canonical skills:      ~/.agents/skills/<skill>
# Canonical defaults:    ~/.agents/AGENTS.md
# Compatibility links:   Claude, Copilot, OMP, GitHub, Codex, OpenCode

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"

DRY_RUN=0
COPY_MODE=0
NO_INSTRUCTIONS=0
BACKUP_SUFFIX="backup.$(date +%Y%m%d%H%M%S)"

usage() {
  cat <<'USAGE'
Usage: scripts/init.sh [options]

Installs this repo's skills globally for common coding agents.

Options:
  --dry-run          Print actions without changing files.
  --copy             Copy skill directories instead of symlinking to this repo.
  --no-instructions  Install skills only; skip global instruction files.
  -h, --help         Show this help.

Default behavior:
  - uses ~/.agents/skills as the canonical skills directory
  - symlinks Claude/Copilot/OMP/GitHub skill locations to ~/.agents/skills
  - writes ~/.agents/AGENTS.md and links Codex/OpenCode/Claude/OMP globals to it
  - backs up existing non-symlink files/dirs before replacing them
USAGE
}

log() {
  printf '%s\n' "$*"
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf 'dry-run: %q' "$1"
    shift
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
  else
    "$@"
  fi
}

backup_path() {
  local path="$1"
  local backup="$path.$BACKUP_SUFFIX"
  local i=1

  while [ -e "$backup" ] || [ -L "$backup" ]; do
    backup="$path.$BACKUP_SUFFIX.$i"
    i=$((i + 1))
  done

  log "backup $path -> $backup"
  run mv "$path" "$backup"
}

replace_with_symlink() {
  local src="$1"
  local dest="$2"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      log "ok $dest -> $src"
      return 0
    fi
    log "replace symlink $dest -> $src"
    run ln -sfn "$src" "$dest"
    return 0
  fi

  if [ -e "$dest" ]; then
    backup_path "$dest"
  fi

  log "link $dest -> $src"
  run ln -s "$src" "$dest"
}

replace_with_copy() {
  local src="$1"
  local dest="$2"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup_path "$dest"
  fi

  log "copy $src -> $dest"
  run cp -R "$src" "$dest"
}

ensure_dir() {
  local dir="$1"
  log "mkdir -p $dir"
  run mkdir -p "$dir"
}

write_global_defaults() {
  local dest="$1"
  local tmp
  tmp="${TMPDIR:-/tmp}/agent-defaults.$$.$RANDOM.md"

  cat > "$tmp" <<'DEFAULTS'
# Global Agent Defaults

## Skill routing
- For implementation, fixing, refactoring, hardening, or code review, use `production-grade-code`.
- For large, ambiguous, or multi-step requests, use `scope-and-slice` first; execute one small verified slice at a time.
- For domain language, architecture alignment, or fuzzy product concepts, use `grill-with-docs` before implementation.

## Coding defaults
- Start by pinning down the user’s actual intent: deliverables, non-goals, material unknowns, and repo facts needed before asking.
- Understand surrounding context: callers and contracts, data flow, existing patterns, and affected tests.
- Reuse existing repo patterns before inventing new ones.
- Make failure behavior explicit; never return plausible success after failure.
- Verify non-trivial behavior with the narrowest relevant test or scenario before claiming completion.
- Be concise without losing truth: omit filler and ceremony, but preserve exact technical terms, evidence, risks, blockers, and verification results.

## Shell defaults
- Prefix shell commands with `rtk` when available, including `git`, test, build, and `rg` commands.
DEFAULTS

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ ! -L "$dest" ] && cmp -s "$tmp" "$dest"; then
      log "ok $dest"
      rm -f "$tmp"
      return 0
    fi
    backup_path "$dest"
  fi

  log "write $dest"
  if [ "$DRY_RUN" -eq 1 ]; then
    log "dry-run: write global defaults to $dest"
    rm -f "$tmp"
  else
    mv "$tmp" "$dest"
  fi
}

install_skill() {
  local src="$1"
  local canonical_root="$2"
  local name
  name="$(basename "$src")"

  if [ ! -f "$src/SKILL.md" ]; then
    return 0
  fi

  if [ "$COPY_MODE" -eq 1 ]; then
    replace_with_copy "$src" "$canonical_root/$name"
  else
    replace_with_symlink "$src" "$canonical_root/$name"
  fi
}

main() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --copy) COPY_MODE=1 ;;
      --no-instructions) NO_INSTRUCTIONS=1 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "error: unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
  done

  if [ ! -d "$SKILLS_SRC" ]; then
    echo "error: skills directory not found: $SKILLS_SRC" >&2
    exit 1
  fi

  local canonical_skills="$HOME/.agents/skills"
  local canonical_defaults="$HOME/.agents/AGENTS.md"

  ensure_dir "$canonical_skills"

  local skill
  for skill in "$SKILLS_SRC"/*; do
    [ -d "$skill" ] || continue
    install_skill "$skill" "$canonical_skills"
  done

  local skill_dir
  local root
  for skill_dir in "$SKILLS_SRC"/*; do
    [ -d "$skill_dir" ] || continue
    [ -f "$skill_dir/SKILL.md" ] || continue
    local name
    name="$(basename "$skill_dir")"

    for root in \
      "$HOME/.claude/skills" \
      "$HOME/.copilot/skills" \
      "$HOME/.omp/skills" \
      "$HOME/.github/skills" \
      "$HOME/.config/opencode/skills"; do
      ensure_dir "$root"
      replace_with_symlink "$canonical_skills/$name" "$root/$name"
    done
  done

  if [ "$NO_INSTRUCTIONS" -eq 0 ]; then
    ensure_dir "$HOME/.agents"
    write_global_defaults "$canonical_defaults"

    ensure_dir "$HOME/.codex"
    ensure_dir "$HOME/.config/opencode"
    ensure_dir "$HOME/.claude"
    ensure_dir "$HOME/.omp"

    replace_with_symlink "$canonical_defaults" "$HOME/.codex/AGENTS.md"
    replace_with_symlink "$canonical_defaults" "$HOME/.config/opencode/AGENTS.md"
    replace_with_symlink "$canonical_defaults" "$HOME/.claude/CLAUDE.md"
    replace_with_symlink "$canonical_defaults" "$HOME/.omp/AGENTS.md"
  fi

  log "done"
  log "canonical skills: $canonical_skills"
  if [ "$NO_INSTRUCTIONS" -eq 0 ]; then
    log "canonical defaults: $canonical_defaults"
  fi
}

main "$@"
