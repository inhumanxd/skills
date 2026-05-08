---
name: production-grade-code
description: "Writes, refactors, debugs, and reviews production-grade code. Use when the user asks to implement, fix, refactor, harden, simplify, improve architecture, create/update modules, make reusable, make maintainable, or write code like a senior/staff engineer. Enforces outside-in design, honest interfaces, module lifecycle completeness, deep-enough modules, behavior verification, safe refactoring, and explicit failure handling."
---

# Production Grade Code

Write code a senior maintainer can defend in production: correct under real inputs, easy to change, explicit when it fails, and simpler than the problem allows.

## Load The Right Detail

Use this file as the active protocol. Read references only when the task needs that depth:

- Architecture, module depth, seams, and interface design: [references/architecture.md](references/architecture.md)
- Tests, TDD, debugging, and feedback loops: [references/testing-and-debugging.md](references/testing-and-debugging.md)
- Failure handling, high-risk writes, and data integrity: [references/data-integrity-and-failure.md](references/data-integrity-and-failure.md)
- Safe refactoring and final review: [references/refactoring-and-review.md](references/refactoring-and-review.md)
- Source principles behind this skill: [references/source-principles.md](references/source-principles.md)
- Concrete bad/good patterns: [references/examples.md](references/examples.md)

If the request is broad, ambiguous, or missing lifecycle scope, use `scope-and-slice` first. If it is mainly about domain language or design alignment, use `grill-with-docs` first. If it is mainly a bug, use the debugging loop.

## Non-Negotiable Standard

Code is production-grade only when it has:

1. **Honest contract** — callers can understand inputs, outputs, side effects, persistence, events, errors, and performance expectations.
2. **Truthful failures** — no plausible success values after lost data, skipped work, swallowed errors, or unsafe partial completion.
3. **Codebase fit** — follows existing domain language, architecture, validation, persistence, logging, authorization, transactions, config, and tests unless the pattern is demonstrably unsafe.
4. **Deep-enough shape** — important behavior sits behind a simple interface; shallow pass-through abstractions are removed or avoided.
5. **Simple implementation** — clear control flow, cohesive functions, precise names, no cleverness that hides risk.
6. **Verified behavior** — a deterministic test or execution path proves the important success and failure cases.
7. **Deletable shape** — behavior has clear ownership and can be removed, replaced, or isolated without unrelated edits across the system.

If any item cannot be satisfied, continue working or mark `[blocked]` with the missing fact, access, or decision.

## Implementation Loop

For every non-trivial code task:

1. **Confirm scope** — know the user-visible goal, affected callers, and verification path. If scope is unclear, return to `scope-and-slice`.
2. **State the outside contract** — define success, absence, validation failure, authorization failure, dependency failure, infrastructure failure, partial success, and retry behavior as applicable.
   For module creation or updates, confirm lifecycle operations are included, excluded, or blocked before coding.
3. **Search for precedent** — reuse nearby codebase conventions before inventing a pattern.
4. **Choose the seam** — put the interface where callers get leverage and maintainers get locality.
5. **Implement one behavior** — smallest coherent behavior that can be verified end-to-end.
6. **Verify immediately** — run the narrowest deterministic test or scenario that proves the behavior.
7. **Refactor only when green** — improve names, remove duplication, deepen modules, and delete obsolete code.
8. **Repeat until complete** — update affected callsites, tests, scripts, docs, and cleanup.

If adding behavior in an area with weak tests, leave at least one behavior-level exemplar test at the correct seam for future changes to copy.

Do not make a broad horizontal pass before any behavior is verified.

## Outside-In Questions

Before editing, know:

- Who calls this now, and who is likely to call it next?
- What may callers assume after success?
- What must callers know when it fails?
- Which inputs are untrusted, missing, malformed, duplicated, stale, concurrent, timezone-sensitive, currency-sensitive, or permission-sensitive?
- What data or side effects must never be silently dropped?
- What should be transactional, idempotent, retryable, resumable, or bounded?
- What test or execution path will prove the real behavior?

## Highest-Signal Gotchas

- **Never** encode errors as `null`, `false`, empty arrays, or default objects unless that is the explicit domain contract.
- **Never** log-and-continue after failed writes, authorization, payments, notifications, migrations, or clinical/data-integrity work unless continuing is explicitly safe.
- **Never** mock internal collaborators just to assert private call order; test behavior through the public interface or deepest correct seam.
- **Never** create a seam for one hypothetical adapter; one adapter is usually indirection, two real adapters can justify a seam.
- **Never** normalize away fields callers may depend on because the current branch does not need them.
- **Never** treat a module as complete after only create/update paths; lifecycle operations and edge cases must be implemented, explicitly excluded, or blocked.
- **Never** use unbounded queries, loops, fanout, retries, or memory-heavy processing in production paths.
- **Never** present partial work as complete because it compiles or the happy path works.
- **Never** leave a local hack as an attractive precedent; contain it, name the constraint, and prevent future callers from copying it accidentally.

## Final Review Gate

Before yielding, inspect the diff like a production PR:

- Public behavior matches the user's actual request.
- Changed exported symbols, routes, tasks, models, migrations, scripts, helpers, and consumers are handled.
- Success and failure modes are distinguishable where callers need them.
- Shared/public APIs preserve compatibility or include an explicit deprecation and migration path; private internals prefer clean cutover.
- New modules earn their interface through depth, locality, or volatility isolation.
- Duplicated business knowledge is removed at the source.
- Names align with domain language.
- Resources and failure paths are bounded and explicit.
- Security boundaries are handled: authentication, authorization, tenancy/scope, untrusted input, injection-safe APIs, secrets, and sensitive logs.
- Tests verify observable behavior, important edge cases, and at least one normal usage path for new public behavior.
- Obsolete code, comments, aliases, dead imports, stale tests, and debug artifacts are removed.
- Verification was run and the observed result is reported.
