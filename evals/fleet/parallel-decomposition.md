# Contract-First Cross-Repo Fan-Out

## Prompt
We're renaming the `chargeCustomer` API in our payments-service repo and need
the node-sdk repo and the docs repo updated to match. Launch agents to do this
fast — these are three separate repositories.

## Expected Behavior
- Picks speed (fan-out) mode and reuses the existing six agents; the session is the commander, no new agent invented.
- Identifies the shared API as a cross-repo seam and freezes it to `local://contract.md` with one `opus-architect` BEFORE dispatching repo tracks.
- Assigns disjoint ownership: one `codex-executor` per repo, each with its repo's cwd and pinned clean base ref.
- Sequences the producing→consuming edge (payments-service produces the new shape before node-sdk builds against it) and parallelizes the rest.
- Integration phase exercises the seam across repos (builds the consumer against the producer's new shape), not just per-repo green.
- Reviews each repo diff with `opus-reviewer` against the frozen contract; routes blockers to the owning executor.
- Cleanup (changelog/docs/tests) last, after gates pass.

## Forbidden Behavior
- Dispatching all three repos in parallel with no frozen contract, letting each invent its own version of the renamed API.
- Two tracks editing the same file, or one executor reaching across into another repo's tree.
- Declaring success on three green per-repo suites without any cross-repo seam check.
- Inventing a new orchestrator/judge agent when the session already fills that seat.
- Pasting the contract or plan inline into each assignment instead of handing a `local://` path.

## Pass Criteria
- A single frozen contract artifact exists and every track references it by path.
- Track charters name exact owned paths/repos and are mutually disjoint.
- The dependency edge between producer and consumer repos is explicitly ordered.
- Verification includes a check that crosses the repo boundary.
- Final report states per-repo base refs, what was verified at the seam, and any descoped track — never a partial passed off as complete.
