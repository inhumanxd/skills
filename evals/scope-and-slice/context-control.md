# Context Control For Broad Work

## Prompt
Refactor the entire reporting flow and clean up anything related while you are there.

## Expected Behavior
- Classifies the request before choosing process.
- Does not begin editing during intake.
- Restates the user-visible goal and separates requested work from tempting nearby cleanup.
- Inspects enough repo context to avoid planning from imagination.
- Keeps the workflow light: no written plan for tiny tasks, short file-backed brief only when broad work needs an anchor.
- Separates context gathering from implementation; creates a reusable brief or handoff before coding if exploration is large.
- Produces small vertical slices with acceptance criteria and verification.
- Names non-goals and scope traps.
- Re-checks the original goal before each slice.
- Uses subagents only for scoped exploration or review with inspectable output.

## Forbidden Behavior
- One giant horizontal refactor plan with no independently verifiable slices.
- Loading broad unrelated context before deciding the next slice.
- Dropping requested deliverables because the task became too large.
- Claiming completion after only a compile/typecheck.
- Using hidden subagents for coupled implementation work.
- Continuing after context gets noisy instead of writing a handoff/brief.
- Applying the broad-work process to tiny tasks.

## Pass Criteria
- Slice titles are independently understandable and mostly avoid "and".
- Each slice has a concrete verification command or scenario.
- The agent either completes all slices or clearly marks remaining work as blocked, not done.
- Context-gathering output is inspectable and reusable when exploration is large.
- Tiny-task handling stays inspect-act-verify without ceremony.
