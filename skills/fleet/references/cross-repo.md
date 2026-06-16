# Cross-repo fleet mechanics

A task spanning repos is the canonical fleet job: disjoint ownership is free
(each repo is its own tree), but the **seam between repos** is where it breaks.
Per-repo green proves nothing about whether producer and consumer still agree.

## Working trees
- One `codex-executor` per repo, with that repo's **absolute path as cwd** in
  the assignment, told to read that repo's conventions first — they differ per
  repo. An executor owns one repo end-to-end and never reaches across trees;
  cross-repo changes happen through the seam contract.
- Pin a **clean base ref per repo** (commit/stash unrelated work) and record it
  — reviewers need it so each repo's diff is exactly the fleet's change.

## The seam is the contract
The producer↔consumer interface (HTTP/RPC shape, shared package API,
event/message schema, DB contract) is designed ONCE and frozen to
`local://contract.md` **before** any repo starts. Both sides build to the frozen
contract, not to each other's in-progress code. A mid-flight seam change returns
to you → re-freeze → broadcast to both repos. Without this the repos converge on
two different shapes and integration silently fails.

## Dependency ordering
If repo B depends on a built/published artifact from repo A (package version,
generated client, compiled types):
- Sequence that edge — A produces (publish / `npm link` / generate / build)
  before B builds against it; mark it `depends:`.
- Independent repos still parallelize fully; only the producing→consuming edge
  is serial.
- Prefer a local link / path override / generated file in the contract over a
  real registry publish during the run, so integration isn't blocked on a
  release.

## Integration check — exercise the seam
The integration phase MUST cross the repo boundary, not just run each repo's
suite:
- Build/typecheck the **consumer against the producer's new shape** (linked or
  path-overridden) so a renamed field or changed signature fails here, not in
  prod.
- For a network seam, run the consumer's contract test against the producer (or
  a stub generated from the frozen contract).
- Green per-repo + red cross-repo build = the seam drifted; blocker, route it to
  whichever repo violated `local://contract.md`.

## Review & hygiene
- One `opus-reviewer` per repo diff (batched), each with its pinned base ref and
  the contract path, checking conformance to the frozen contract on top of the
  usual correctness/security/integrity pass. High-stakes seams (auth, money,
  irreversible data crossing the boundary) add `codex-reviewer` per affected
  repo.
- One commit/PR per repo, self-describing and referencing the contract, so each
  history is independently reviewable and revertable. Land in dependency order
  (producer before consumer) if a real publish is involved.
