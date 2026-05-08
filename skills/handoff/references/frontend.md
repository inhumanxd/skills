# Frontend Handoff

Use this shape:

```markdown
# Frontend Handoff: <change>

## Changed
- `<METHOD> <path>`: <one-line purpose or contract change>. Swagger: `<swagger file>`.

## Contract Notes
- <added/changed/removed fields, enums, query params, status codes, auth, pagination, errors>

## UI Notes
- <state transitions, disabled states, optimistic updates, compatibility, feature flags, or no-op notes>

## Open Questions
- <only if needed>
```

Focus on what the UI must send, render, handle, or stop assuming. Do not explain backend internals unless they change frontend behavior.
