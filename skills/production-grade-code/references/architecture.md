# Architecture Reference

## Vocabulary

- **Module** — anything with an interface and implementation: function, class, file, package, workflow, service slice.
- **Interface** — everything callers must know: types, invariants, ordering, errors, side effects, performance, configuration, permissions, and data guarantees.
- **Implementation** — what sits behind the interface.
- **Seam** — where behavior can vary without editing the caller.
- **Adapter** — concrete implementation at a seam, especially for storage, queues, vendors, time, randomness, files, or network calls.
- **Depth** — leverage at the interface: little caller knowledge unlocks substantial behavior.
- **Locality** — change, bugs, validation, and tests concentrate in one place.

Use these terms instead of vague labels like component, utility, service, API, layer, or boundary unless the repo already uses those as domain terms.

## Deep Modules And Deletability

Prefer deep modules: small honest interfaces hiding meaningful behavior.
Prefer deletable modules: clear ownership, limited callers, and no hidden global coupling. A feature should be removable or replaceable without unrelated edits across the system.

Use the deletion test:

- If deleting the module makes complexity vanish, it was shallow ceremony.
- If deleting it spreads rules, validation, sequencing, or error handling across callers, it was earning its keep.

Deepen when you see:

- Repeated orchestration across callers.
- Validation duplicated outside the owner of the data.
- Tests that know private call order.
- Pass-through wrappers leaking vendor, transport, or storage shapes.
- Helpers extracted only to unit-test tiny pieces while real behavior remains untested.

Avoid over-deepening:

- One adapter usually means a hypothetical seam.
- Two real adapters usually justify a seam.
- Internal seams can exist, but do not expose them just because tests want access.
- Avoid broad utility modules that collect unrelated behavior.

## Interface Design

A production interface includes:

- Types and shapes.
- Invariants and preconditions.
- Success, absence, and error modes.
- Side effects and transactional expectations.
- Ordering, idempotency, concurrency, and retry semantics.
- Performance and bounded-resource expectations.
- Security and privacy expectations.

Prefer:

- Few entry points with high leverage.
- Domain-shaped parameters over primitive soup.
- Named option objects over ambiguous booleans.
- Specific dependency ports at true external seams over generic fetch/query wrappers.
- Return values that communicate outcomes clearly.
- Compatibility rules: shared/public APIs preserve compatibility or include explicit deprecation and migration; private internals prefer clean cutover over permanent legacy branches.

For significant interface changes, design at least two materially different options before choosing. Pick the best combination of depth, locality, caller simplicity, and testability.
For module creation or updates, design the full lifecycle before coding: create, read/list/detail, update, validation, delete, soft-delete/archive, restore/unarchive, permissions, idempotency, and migration/backfill behavior. Implement included operations, explicitly exclude non-goals, or mark blockers.

## Domain Language

- Name modules after domain outcomes or concepts, not implementation mechanisms.
- Put rules where the domain concept already lives.
- Do not leak vendor, database, transport, or UI shapes through domain interfaces unless that is the domain itself.
- When two names mean the same concept, consolidate vocabulary instead of encoding both forever.
