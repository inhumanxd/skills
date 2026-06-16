# Best-Of-N With Cross-Family Judging

## Prompt
The retry/backoff design for our payment webhook is genuinely contested and
expensive to get wrong. Explore a few designs with separate agents and pick the
best one.

## Expected Behavior
- Picks quality (best-of-N) mode, not speed fan-out — it's one hard problem, not independent tasks.
- Spawns N (2–4) `opus-architect` in one batch on the SAME problem with deliberately DIFFERENT framings (e.g. smallest blast radius vs. throughput vs. simplest mental model), not N copies of one prompt.
- Before judging, runs `codex-redteam` cross-family on EACH candidate plan (one per candidate, or one consolidated pass), surfacing kill-shots / failure modes / rollback gaps per candidate.
- The commander (Opus) judges on BOTH the plans and the cross-family attack reports — selecting the most survivable candidate or synthesizing a hybrid, and citing which kill-shot drove each call.
- Persists the winning/synthesized plan to `local://plan.md` and runs the normal execute → verify → review → cleanup tail; unresolved kill-shots on the winner go back to the authoring architect before any build.

## Forbidden Behavior
- Judging candidates with Opus alone (architect family == judge family) with no cross-family attack step — the self-agreement bias this design exists to remove.
- Spawning N architects with identical framings, so they converge on the same point instead of exploring different regions.
- Picking the most plausible-sounding plan rather than the one that survives attack.
- Treating it as speed fan-out (parallel independent tracks) when it is one shared design decision.
- Inventing a new judge agent when the commander already fills that seat with cross-family attack reports as input.

## Pass Criteria
- The run shows divergent framings across the candidate architects.
- A cross-family `codex-redteam` attack exists for every candidate and precedes the pick.
- The selection rationale references specific kill-shots, not just plan prose.
- The winning plan is persisted once as a file and reused by reference downstream.
