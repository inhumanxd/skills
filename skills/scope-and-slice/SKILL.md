---
name: scope-and-slice
description: "Analyzes large or ambiguous requests before implementation, decomposes them into small verifiable slices, and prevents context drift. Use when a task is broad, multi-step, multi-file, vague, touches multiple layers, asks to create/update a module, mentions all/entire/full/refactor/flow/system, or feels too large to complete well in one focused pass."
---

# Scope And Slice

Big requests are not implementation units. Convert them into small, verifiable slices before coding.

## When To Use

Use this skill when the request is:

- Broad, ambiguous, multi-step, or context-heavy.
- Likely to touch more than 3-5 files.
- Spread across multiple layers, domains, agents, or verification paths.
- Asking for “all”, “entire”, “complete”, “full”, “refactor”, “system”, “module”, “dashboard”, or “flow”.
- Tempting to one-shot with a large diff before proving anything.

Do not use for obvious single-file fixes, direct Q&A, tiny edits, or already well-scoped tasks.

## Lifecycle

1. **Classify** — tiny, scoped, broad, bug, module, or skill/instruction.
2. **Tiny** — stop using this skill; inspect exact context, act, verify.
3. **Scoped** — skip the brief unless it clarifies risk; use `production-grade-code` for implementation.
4. **Broad** — do read-only intake, create or update a short brief, then execute one verified vertical slice at a time.
5. **Module** — before coding, mark lifecycle operations included, excluded, or blocked.
6. **Context** — gather enough to decide the next slice; if exploration is large, write a reusable brief or handoff before coding.

If the request is too large, do not silently compress, skip, or one-shot it. Slice it.

## Intake Gate

Before implementation on broad work:

1. Restate the user-visible goal in one sentence.
2. Identify deliverables, non-goals, and scope traps.
3. Inspect enough repo context to avoid planning from imagination.
4. List risks, unknowns, dependencies, and verification needs.
5. Decide the next independently verifiable slice.
6. For module creation or updates, enumerate lifecycle coverage: create, read/list/detail, update, validation, delete/archive, restore, permissions, idempotency, migrations/backfills, and edge cases.

Do not edit production code during this gate unless the task is clearly small.

## Slicing Rules

A slice must be independently understandable, implementable, and verifiable.

Prefer vertical slices: one complete behavior path through the needed layers. Avoid horizontal slices like “all schema”, then “all API”, then “all UI” unless a contract must be established first.

Good slices usually:

- Touch 1-5 files.
- Have 1 clear outcome.
- Have 1-3 acceptance criteria.
- Have a specific verification command or manual scenario.
- Leave the system working.
- Can be explained without referencing the whole original chat.
- For module work, either covers the full declared lifecycle surface or clearly excludes/defer-blocks specific operations.

If a slice title contains “and”, split it.

## Slice Brief

Do not create a brief for tiny tasks. For broad work, keep the brief short enough to reread at each boundary. Use [references/slice-brief-template.md](references/slice-brief-template.md) when the task needs a durable anchor.

At minimum, capture:

- Goal.
- Scope and non-goals.
- Slices in order.
- Acceptance criteria per slice.
- Verification per slice.
- Open questions or blockers.
- Module lifecycle matrix when the task creates or updates a module.

## Context Discipline

- Gather context before implementation, not during a half-written change.
- Load only what answers the next decision: brief, target files, nearby tests, and one precedent.
- If exploration is large, produce a reusable brief or handoff before coding.
- Use subagents only for scoped exploration or review with inspectable output, not coupled implementation.
- When context gets noisy, re-anchor on the brief or write a handoff with files, decisions, verification, and open questions.

## Execution Discipline

For each slice:

1. Load only the context needed for that slice: brief section, files to edit, nearby tests, and one existing pattern.
2. Use `production-grade-code` for implementation.
3. Verify the slice before moving on.
4. Update the brief or todos with what changed and what remains.
5. Re-check module lifecycle completeness before moving to the next slice when module work is in scope.
6. Re-check the original goal before starting the next slice.

Continue through slices only while scope remains clear and quality remains high. If context gets noisy, re-anchor on the brief.

## Red Flags

- Starting code without a written slice list for broad work.
- A slice touches unrelated subsystems.
- Acceptance criteria are vague or untestable.
- Verification is “looks good” or “compiles probably”.
- Context loaded is larger than the current slice needs.
- Context gathering and implementation are mixed so the agent loses track of which facts support the next edit.
- Subagents are used for coupled implementation work without a reviewable contract or output.
- The agent drops a requested part because it no longer fits.
- The plan grows new features not requested by the user.
- Module work implements only create/update while delete/archive/restore, permissions, validation, or edge cases are implicit.

## If The User Asks To Do Everything

Still slice internally. The user asked for completion, not one giant unsafe implementation unit.

Work slice-by-slice, verifying each slice. Do not claim the whole request is complete until every slice and acceptance criterion is complete or explicitly blocked.
