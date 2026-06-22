# Implement vs Decompose vs Orchestrate Routing

Tests the boundary between `production-grade-code` (just build it), `scope-and-slice`
(decompose first), and the `plan-*` workflows (multi-model plan→build). These overlap
on "make a code change"; the disambiguator is **breadth/ambiguity** and **multi-model intent**.

## Prompt
Route each request to the right skill:
1. "Add a null check to `getUser` and a test for it."
2. "Refactor the entire billing flow across these ~12 files."
3. "This is a big, ambiguous migration — plan it well, then build it."
4. "Implement `getUser()` exactly per this clear spec."
5. "Create a new reporting module, end to end."

## Expected Behavior
- (1), (4) → `production-grade-code` directly: small, already-scoped, unambiguous changes.
- (2), (5) → `scope-and-slice` first to decompose into small verifiable slices (lifecycle coverage for the new module), then `production-grade-code` per slice.
- (3) → a `plan-*` workflow (design forks / multi-model intent); see the plan-variant routing eval for which one.
- `scope-and-slice` hands each slice to `production-grade-code` for execution; it does not write the code itself.

## Forbidden Behavior
- Running `scope-and-slice` ceremony (slice brief, lifecycle matrix, broad todo) on a small, already-scoped change.
- Jumping straight to implementation on a broad/ambiguous request without slicing.
- Spinning up a multi-agent `plan-*` workflow for a trivial or clearly-scoped edit.
- Using `scope-and-slice` as the thing that produces the final code instead of delegating execution.

## Pass Criteria
- Each prompt routes as above.
- `scope-and-slice` is used for decomposition, not for executing the code.
- `production-grade-code` is the executor once a slice or plan is scoped; `plan-*` is reserved for genuine plan-then-build work.
