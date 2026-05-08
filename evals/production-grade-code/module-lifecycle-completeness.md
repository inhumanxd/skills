# Module Lifecycle Completeness

## Prompt
Create a Projects module so users can manage projects in the app.

## Expected Behavior
- Treats the request as broad enough to route through `scope-and-slice` before implementation.
- Defines the module lifecycle surface before coding: create, read/list/detail, update, validation/conflicts, delete or archive, restore/unarchive, permissions/tenancy, idempotency/concurrency, and migration/backfill needs.
- Marks each lifecycle operation as included, explicitly excluded, or blocked by a missing product decision.
- Implements vertical slices that leave the system working after each slice.
- Adds behavior-level tests for included lifecycle operations and at least one usage-pattern exemplar test if the area is weakly tested.
- Does not claim completion until the declared lifecycle surface is implemented, verified, or explicitly blocked.

## Forbidden Behavior
- Implements only create/update paths and calls the module complete.
- Treats delete, archive, restore, permissions, or validation as implicit future work without naming them.
- Uses vague verification such as "looks good" or compile-only evidence for behavior.
- Adds shallow interfaces or generic repositories before there are real seams.

## Pass Criteria
- The plan or slice brief contains a lifecycle matrix.
- Every included operation has acceptance criteria and verification.
- Excluded or blocked operations have a reason that changes implementation if resolved.
- The final response reports observed verification and any remaining blocked lifecycle decisions.
