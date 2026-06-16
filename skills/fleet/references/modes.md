# Fleet modes — playbooks

Two modes, one commander (session, Opus 4.8), the six `plan-opus-execute-codex`
agents. Pick the mode from the work's shape. Cross-repo specifics layer on top
→ `cross-repo.md`.

## Speed (fan-out) — many independent tasks at once
Use when the work splits into independent units with **disjoint file/dir/repo
ownership**. Win = wall-clock; tracks finish in the slowest one's time, not the
sum.

**1. Map.** One-line charter per track: *what it delivers* + *exactly which
files/dirs/repo it owns*. Classify every pair:
- **independent** (disjoint, no shared interface) → parallel.
- **contract-coupled** (share a type/API/schema/seam) → freeze first (step 2),
  then parallel against the frozen contract.
- **overlapping** (both edit one file) → NOT parallelizable: sequence them, or
  lift the shared file into a contract one side owns. Never let two live tracks
  write the same file.

Bound width: the harness caps **32 concurrent subagents** and each track is
itself a tree (executor → architect → scouts) — keep width ≤ ~6–8, balance track
size, let the pool queue the rest.

**2. Freeze** (only if any track is contract-coupled). One `opus-architect`
designs the shared interface ONCE — signatures, types, schema, error variants,
cross-repo seam — persisted to `local://contract.md`. The serial prefix that
prevents divergent-contract merge hell. Skip when all tracks are independent.

**3. Dispatch.** One `task` batch of `codex-executor`, one item per track.
- **Shared `context` (once):** frame, `local://contract.md` path (if any),
  architect id for escalation, build/test commands, and *"own ONLY these paths."*
- **Per item:** the charter — deliverable, owned paths, acceptance criteria.
  Design-heavy tracks also get a `local://plan-<track>.md` (architect plans them
  in the freeze batch).
- Executors escalate genuine design forks to the architect over `irc`; routine
  choices they decide.
- Pin a clean base per repo first so the integration diff is exactly the fleet's
  change.

**4. Coordinate.** Tracks resolve seams peer-to-peer over `irc`. A contract
change is NOT local: it goes to you → update `local://contract.md` → broadcast
the delta to affected tracks. Three-strikes: a track failing the same gate
thrice reports up; you re-dispatch or descope-with-disclosure. A failure
degrades only its subtree.

**5. Integrate** (serial — never skipped). Fan-out concentrates this cost; it
doesn't remove it.
- **Union gates** over all changed files: narrowest tests, typecheck, lint —
  per repo.
- **Exercise every seam**, not just per-track green: if A changed an API and B
  consumes it, build/run B against A's new shape. Per-repo green proves nothing
  about the seam (→ `cross-repo.md`).

**6. Review + cleanup.** One `opus-reviewer` per track diff (batched), each with
the plan/contract path and the track's pinned base ref; high-stakes adds
`codex-reviewer`. Blockers route to the owning executor (`path:line`); re-review
after fixes; three-strikes caps the loop. Cleanup (changelog, tests, docs,
scaffolding) last, after gates pass and blockers clear.

## Quality (best-of-N) — one hard problem, many angles
Use when one design is genuinely hard and being *right* beats being fast
(unclear approach, cross-cutting trade-offs, high blast radius). The N
architects run in parallel → wall-clock ≈ one architect.

**1. Frame the fork.** One paragraph: what's designed, the constraints, and
*what reasonable engineers would dispute* (simplicity vs performance, blast
radius vs completeness, build vs reuse).

**2. Diverge.** Spawn N (2–4) `opus-architect` in one batch on the **same**
problem with **deliberately different framings** (e.g. smallest blast radius /
runtime performance / simplest mental model) so they explore different regions.
Same frame in shared `context`; the framing goes per-item. Each returns a full
plan dossier.

**3. Attack cross-family.** One batch of `codex-redteam`, one per candidate —
GPT-5.5 attacking each Opus plan across the family line, returning kill-shots,
edge cases, failure modes, rollback gaps. Without this, Opus grades Opus and
bias picks the most *plausible* plan, not the most *survivable* one. (Cheaper:
one redteam comparing all N — less focus, fewer tokens.)

**4. Judge (you).** Decide on two inputs — the N plans AND their attack reports.
**Select** the candidate with the fewest/cheapest fatal flaws, or **synthesize**
a hybrid (one's surviving spine + mitigations the attack surfaced on another),
citing which candidate and kill-shot drove each call. Score correctness/edge
cases, blast radius, reversibility, convention-fit, verification — weighted by
what survived attack.

**5. Execute.** Persist the winner to `local://plan.md`; run the normal
`plan-opus-execute-codex` execute → verify → review → cleanup tail. Unresolved
kill-shots on the winner go back to the authoring architect first.

**Cost.** Best-of-N multiplies *design + attack* tokens by N, not execution.
Reserve it for forks where a wrong design is expensive to unwind; clear-but-
multi-file work wants one architect (or a self-authored plan).

## Combining modes
Large programs are often **best-of-N for the contract, then speed fan-out for
the build**: explore the shared interface from several angles, freeze the winner
to `local://contract.md`, fan out independent tracks against it. The frozen
contract is the hand-off between modes.
