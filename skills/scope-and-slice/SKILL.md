---
name: scope-and-slice
description: "Analyzes large or ambiguous requests before implementation, decomposes them into small verifiable slices, and prevents context drift. Use when a task is broad, multi-step, multi-file, vague, touches multiple layers, mentions all/entire/full/refactor/flow/system, or feels too large to complete well in one focused pass."
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

## Core Rule

First decide the right unit of work. Then execute one unit well.

If the request is too large, do not silently compress, skip, or one-shot it. Slice it.

## Read-Only Intake Gate

Before implementation:

1. Restate the user’s actual goal in one sentence.
2. Identify explicit deliverables and implied work.
3. Identify non-goals and likely scope traps.
4. Inspect enough repo context to avoid planning from imagination.
5. List risks, unknowns, dependencies, and verification needs.
6. Decide whether the task is small enough to execute as one slice.

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

If a slice title contains “and”, split it.

## Slice Brief

For large work, create or maintain a short brief using [references/slice-brief-template.md](references/slice-brief-template.md). Keep it durable and concise enough to reread.

At minimum, capture:

- Goal.
- Scope and non-goals.
- Slices in order.
- Acceptance criteria per slice.
- Verification per slice.
- Open questions or blockers.

## Execution Discipline

For each slice:

1. Load only the context needed for that slice: relevant spec/brief section, files to edit, nearby tests, and one existing pattern.
2. Use `production-grade-code` for implementation.
3. Verify the slice before moving on.
4. Update the brief or todos with what changed and what remains.
5. Re-check the original goal before starting the next slice.

Continue through slices only while scope remains clear and quality remains high. If context gets noisy, re-anchor on the brief.

## Red Flags

- Starting code without a written slice list for broad work.
- A slice touches unrelated subsystems.
- Acceptance criteria are vague or untestable.
- Verification is “looks good” or “compiles probably”.
- Context loaded is larger than the current slice needs.
- The agent drops a requested part because it no longer fits.
- The plan grows new features not requested by the user.

## If The User Asks To Do Everything

Still slice internally. The user asked for completion, not one giant unsafe implementation unit.

Work slice-by-slice, verifying each slice. Do not claim the whole request is complete until every slice and acceptance criterion is complete or explicitly blocked.
