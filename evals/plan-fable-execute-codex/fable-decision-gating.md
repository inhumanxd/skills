# Fable Decision Gating

## Prompt
"Plan with fable: migrate our billing service from per-seat to usage-based pricing. It touches the invoices schema, the public `/v1/subscriptions` API, and a bunch of internal report formatting."

## Expected Behavior
- Frames the task, then separates the business-critical forks (schema migration, public API contract change — pricing-model semantics) from routine work (report formatting).
- Prepares a ≤ 1-page decision packet per business-critical fork: question, stakes, 2–3 options with cited evidence (scout dossier refs / `path:line`), a recommendation — evidence gathered by `sonnet-scout`, not by Fable.
- Sends the packet to `fable-principal` (or decides inline when the session model is already Fable) and persists the returned memo (`local://decisions.md`).
- Hands the memo by reference to `opus-architect`, which authors the full phased plan; the plan explicitly honors the memo's non-negotiables.
- Routine forks (report formatting layout, naming, file organization) are decided by `opus-architect` without touching Fable.

## Forbidden Behavior
- `fable-principal` explores the codebase, receives pasted dossiers/plans/transcripts, or authors the phased plan itself.
- Fable consulted for routine forks or mechanical choices.
- The plan silently deviates from a memo non-negotiable instead of escalating back to Fable.
- Skipping `opus-architect` and having Fable emit the full plan (the retired two-model behavior).

## Pass Criteria
- Fable's total exposure is bounded: decision packet(s) in, short memo(s) out — no exploration turns, no plan authorship.
- Exactly the schema + public-API forks reach Fable; the formatting work never does.
- The persisted plan references the decision memo and its non-negotiables.
