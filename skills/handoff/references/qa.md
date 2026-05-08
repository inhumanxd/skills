# QA Handoff

Use this shape:

```markdown
# QA Handoff: <change>

## Done
- <brief behavior summary>

## Test Surface
- `<METHOD> <path>`: <what to verify>. Swagger: `<swagger file>`.

## Scenarios
- <happy path with expected result>
- <edge case with expected result>
- <permission/auth/tenant boundary if relevant>
- <validation/error case if relevant>
- <regression check if relevant>

## Test Notes
- <required setup, seed data, migrations, webhooks, async jobs, or environment caveats>

## Not In Scope
- <only if it prevents false expectations>
```

QA gets slightly more detail than frontend, but still only concrete behavior and what to test.
