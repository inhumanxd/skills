# Slice Brief Template

Use this for large, ambiguous, or multi-step requests. Keep it short enough to reread at every phase boundary.

```md
# Slice Brief: [Task Name]

## Goal
[One sentence describing the user-visible outcome.]

## Scope
- [Included deliverable]
- [Included deliverable]

## Non-Goals
- [Explicitly excluded or deferred work]
- [Nearby tempting work not included]

## Constraints
- [Repo/user/technical constraint]
- [Risk or compatibility constraint]

## Module Lifecycle Matrix

Use only when creating or updating a module. Mark each row `included`, `excluded`, or `blocked`.

| Operation | Status | Acceptance / reason |
| --- | --- | --- |
| Create | [included/excluded/blocked] | [condition or reason] |
| Read/list/detail | [included/excluded/blocked] | [condition or reason] |
| Update | [included/excluded/blocked] | [condition or reason] |
| Delete / soft-delete / archive | [included/excluded/blocked] | [condition or reason] |
| Restore / unarchive | [included/excluded/blocked] | [condition or reason] |
| Validation / conflicts | [included/excluded/blocked] | [condition or reason] |
| Permissions / tenancy | [included/excluded/blocked] | [condition or reason] |
| Idempotency / concurrency | [included/excluded/blocked] | [condition or reason] |
| Migration / backfill / cleanup | [included/excluded/blocked] | [condition or reason] |

## Slices

### Slice 1: [Small outcome]
Acceptance:
- [Specific, testable condition]
Verification:
- [Command, test, script, or manual scenario]
Likely files:
- [file/path]
Dependencies: None

### Slice 2: [Small outcome]
Acceptance:
- [Specific, testable condition]
Verification:
- [Command, test, script, or manual scenario]
Likely files:
- [file/path]
Dependencies: Slice 1

## Open Questions / Blockers
- [Question that changes implementation if unresolved]

## Drift Check
Before each new slice, confirm:
- Are we still solving the original goal?
- Did scope silently expand or shrink?
- If module work is in scope, did we cover or explicitly exclude lifecycle operations and edge cases?
- Did repo facts contradict the brief?
- Is the next slice still small and verifiable?
```

## Sizing Guide

- XS: 1 file, one function/config/doc update.
- S: 1-2 files, one small endpoint/helper/component/test path.
- M: 3-5 files, one coherent behavior slice.
- L: 5-8 files, risky; split unless tightly coupled.
- XL: 8+ files, not a slice.

## Good Slice Examples

- “Patient can archive one assignment from the dashboard, with API and UI test coverage.”
- “Backend validates duplicate booking link slugs and returns the existing error shape.”
- “Migration dry-run reports invalid rows without writing changes.”
- “Projects module supports create/list/detail/update/archive/restore with permission and validation coverage; hard delete explicitly excluded by retention policy.”

## Bad Slice Examples

- “Implement the whole dashboard.”
- “Refactor auth and update tests.”
- “Clean up the exercise module.”
- “Add all API, UI, and docs.”
- “Create the projects module” with only create/update paths and no lifecycle exclusions.
