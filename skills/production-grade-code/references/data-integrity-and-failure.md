# Data Integrity And Failure Reference

## Honest Outcomes

Return types must distinguish success, absence, validation failure, authorization failure, conflict, dependency failure, and infrastructure failure when callers need to react differently.

Do not encode errors as empty arrays, `null`, `false`, or default objects unless that is the explicit domain contract.

Never hide partial success. Make it visible, resumable, or transactional.

## Failure Handling

- Let unexpected infrastructure errors propagate to the framework's error path unless the caller can recover.
- Catch errors only to add context, translate into a domain error, compensate safely, or release resources.
- Never log-and-continue after failed writes, authorization checks, payment actions, notification contracts, migration steps, or clinical/data-integrity operations unless continuing is explicitly safe.
- Logs must identify operation and entity enough for diagnosis without leaking secrets, tokens, credentials, or protected data.
- Cleanup, retry, rollback, and compensation behavior must be explicit for multi-step side effects.

## High-Risk Paths

Treat writes, migrations, sync jobs, billing, scheduling, clinical records, permissions, and notifications as high-risk paths.

For high-risk paths:

- Use transactions when multiple writes represent one domain action and the datastore supports it.
- Use idempotent reconciliation when transactions are impossible or cross-system.
- Bound queries, loops, fanout, retries, and memory use.
- Preserve audit-relevant fields and timestamps.
- Make destructive operations reversible, dry-runnable, or explicitly approved.
- Prefer resumable jobs over all-or-nothing scripts for large datasets.

## Input And Resource Boundaries

At external boundaries, validate:

- Shape and required fields.
- Authorization and tenancy/scope.
- Timezone, locale, currency, and unit assumptions.
- Pagination, sorting, and limit semantics.
- Idempotency keys or duplicate handling.
- Concurrency and stale-write behavior.

Inside the system, keep functions typed and narrow. Do not repeatedly revalidate trusted internal shapes unless the boundary has been crossed again.
