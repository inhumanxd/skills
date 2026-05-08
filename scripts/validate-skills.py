#!/usr/bin/env python3
"""Validate repository skill structure and discoverability."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"
NAME_RE = re.compile(r"^[a-z0-9][a-z0-9-]{0,63}$")
LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+\.md)\)")
TRIGGER_RE = re.compile(r"\b(use when|used when|asks? to|mentions?|/[-a-z0-9]+)\b", re.I)
XML_RE = re.compile(r"<[^>]+>")


def parse_frontmatter(path: Path) -> tuple[dict[str, str], list[str]]:
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        return {}, ["missing YAML frontmatter"]

    errors: list[str] = []
    data: dict[str, str] = {}
    end = None
    for index, line in enumerate(lines[1:], start=2):
        if line.strip() == "---":
            end = index
            break
        if ":" not in line:
            errors.append(f"frontmatter line {index} is not key: value")
            continue
        key, value = line.split(":", 1)
        data[key.strip()] = value.strip().strip('"').strip("'")

    if end is None:
        errors.append("frontmatter is not closed")
    return data, errors


def validate_skill(skill_dir: Path) -> list[str]:
    errors: list[str] = []
    skill = skill_dir / "SKILL.md"
    text = skill.read_text(encoding="utf-8")
    lines = text.splitlines()
    frontmatter, fm_errors = parse_frontmatter(skill)
    errors.extend(f"{skill}: {error}" for error in fm_errors)

    name = frontmatter.get("name")
    description = frontmatter.get("description")

    if not name:
        errors.append(f"{skill}: missing name")
    elif not NAME_RE.match(name):
        errors.append(f"{skill}: invalid name {name!r}; use lowercase kebab-case under 64 chars")

    if not description:
        errors.append(f"{skill}: missing description")
    else:
        if len(description) > 1024:
            errors.append(f"{skill}: description exceeds 1024 characters")
        if XML_RE.search(description):
            errors.append(f"{skill}: description must not contain XML-like tags")
        if not TRIGGER_RE.search(description):
            errors.append(f"{skill}: description should include concrete trigger language such as 'Use when' or 'asks to'")

    if len(lines) > 500:
        errors.append(f"{skill}: SKILL.md exceeds 500 lines; split details into references")

    for match in LINK_RE.finditer(text):
        target = match.group(1).split("#", 1)[0]
        if target.startswith(("http://", "https://", "mailto:")):
            continue
        target_path = (skill_dir / target).resolve()
        try:
            target_path.relative_to(skill_dir.resolve())
        except ValueError:
            errors.append(f"{skill}: link escapes skill directory: {target}")
            continue
        if not target_path.exists():
            errors.append(f"{skill}: linked file does not exist: {target}")

    return errors


def main() -> int:
    if not SKILLS.is_dir():
        print(f"missing skills directory: {SKILLS}", file=sys.stderr)
        return 1

    skill_dirs = sorted(path for path in SKILLS.iterdir() if path.is_dir() and (path / "SKILL.md").exists())
    if not skill_dirs:
        print("no skills found", file=sys.stderr)
        return 1

    errors: list[str] = []
    for skill_dir in skill_dirs:
        errors.extend(validate_skill(skill_dir))

    if errors:
        print("skill validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(f"validated {len(skill_dirs)} skills")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
