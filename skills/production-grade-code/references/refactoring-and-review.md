# Refactoring And Review Reference

## Safe Refactoring

- Preserve behavior unless the task explicitly changes behavior.
- Prefer small mechanical transformations with verification between them.
- When changing legacy code, first create or find a seam that can prove behavior.
- If no correct seam exists for a regression test, state that architecture is preventing safe verification and fix the seam when in scope.
- Delete obsolete tests that only lock down shallow internals once behavior is covered at the deeper interface.

Refactoring is not complete when code looks cleaner. It is complete when behavior is preserved or intentionally changed, and verification proves it.

## Simplicity Without Shallowness

- Use direct control flow over clever abstraction.
- Prefer cohesive functions over many tiny functions that force readers to chase the algorithm across the file.
- Extract helpers when they remove duplicated domain knowledge, clarify an invariant, isolate a volatile dependency, or create a legitimate seam.
- Keep pass-through wrappers out unless they enforce a contract, translate a shape, add observability, or isolate volatility.
- Comments should explain why, invariants, danger, non-obvious domain rules, or external constraints. Do not comment what the code plainly says.
- Types should reduce invalid states, not merely decorate them.

## Review Checklist

Before claiming completion:

- Public behavior matches the user's actual request, not a convenient subset.
- Changed exported symbols, routes, tasks, models, migrations, scripts, helpers, and consumers are handled.
- Success, absence, validation failure, authorization failure, dependency failure, and infrastructure failure are distinguishable where callers need that distinction.
- Each new module earns its interface through depth, locality, or volatility isolation.
- Duplicated business knowledge is eliminated at the source.
- Names are precise and aligned with domain vocabulary.
- Resources are bounded and failure paths explicit.
- Tests target observable behavior and survive internal refactors.
- Verification covers the edge cases most likely to cause production incidents.
- Obsolete code paths, comments, aliases, dead imports, stale tests, and debug artifacts are removed.
- Docs, examples, seed data, migrations, scripts, and operational runbooks are updated when affected.
