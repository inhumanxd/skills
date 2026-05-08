# Backend Handoff

Use this shape:

```markdown
# Backend Handoff: <change>

## Scope
- <what changed and why it matters>

## Entry Points
- `<METHOD> <path>` or `<job/webhook/service>`: <one-line behavior>

## State And Contracts
- <tables, migrations, idempotency, transactions, indexes, cache, compatibility, or config/env changes>

## Risks / Follow-Ups
- <only real operational or maintenance notes>
```

Backend handoff should help another backend developer continue, review, or operate the change without rereading the whole diff.
