# RTK — Token-Optimized CLI

**rtk** is a CLI proxy that filters and compresses command outputs, saving 60-90% tokens.

## Skills

Before writing, fixing, refactoring, or reviewing code, load and follow the relevant installed skill first. For implementation work, use `production-grade-code`.
For large, ambiguous, or multi-step requests, use `scope-and-slice` before implementation; execute one small verified slice at a time.
For skill or instruction changes, use `skill-authoring` and add/update evals when expected agent behavior changes.

## Agent Lifecycle

- Classify first: tiny, scoped, broad, bug, module, or skill/instruction.
- Tiny: inspect exact context, act, verify. No written plan.
- Scoped: inspect nearby pattern, make one coherent change, verify.
- Broad: use `scope-and-slice`; do read-only intake, keep a short brief only if useful, then ship one verified vertical slice at a time.
- Bug: reproduce the exact failure before fixing.
- Module: account for lifecycle coverage before coding; include, exclude, or block each operation.
- Skill/instruction: use `skill-authoring` and update evals when expected agent behavior changes.
- Yield only with observed verification or an explicit blocker.

Core coding defaults:
- Start by pinning down the user’s actual intent: deliverables, non-goals, material unknowns, and the repo facts needed before asking.
- Understand the surrounding context—callers and their contracts, data flow, existing patterns, and affected tests—before making changes.
- Reuse existing repo patterns before inventing new ones.
- Make failure behavior explicit; never return plausible success after failure.
- Verify non-trivial behavior with the narrowest relevant test or scenario before claiming completion.
- For module creation or updates, account for full lifecycle coverage; use `scope-and-slice` for broad module work.
- Be concise without losing truth: omit filler and ceremony, but preserve exact technical terms, evidence, risks, blockers, and verification results.

## Rule

Always prefix shell commands with `rtk`:

```bash
# Instead of:              Use:
git status                 rtk git status
git log -10                rtk git log -10
rg "pattern" src/          rtk rg "pattern" src/
cargo test                 rtk cargo test
docker ps                  rtk docker ps
kubectl get pods           rtk kubectl pods
```

## Meta commands (use directly)

```bash
rtk gain              # Token savings dashboard
rtk gain --history    # Per-command savings history
rtk discover          # Find missed rtk opportunities
rtk proxy <cmd>       # Run raw (no filtering) but track usage
```

## Daily Timesheet Rule (Mandatory)

Applies to every user prompt, every skill prompt, every agent run, and every subagent run.

1. Before doing task work, write one line to the daily timesheet.
2. Timesheet path: tasks/timesheets/YYYY-MM-DD.md (local date).
3. If file is missing, create it. If file exists, append.
4. Log every distinct task handled in the prompt.
5. Keep each line caveman style: lowercase, no fluff, max 7 words.

Line format:
task words

Example:
read auth flow
patch token bug
run tests fail
