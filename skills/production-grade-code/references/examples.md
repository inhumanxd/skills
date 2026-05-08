# Production Grade Examples

Use these as pattern checks when a change feels superficially correct but operationally weak.

## Failure Must Not Look Like Success

Bad:
```ts
try {
  await saveInvoice(invoice);
  return { ok: true };
} catch (error) {
  logger.error(error);
  return { ok: true };
}
```

Good:
```ts
try {
  await saveInvoice(invoice);
  return { ok: true };
} catch (error) {
  throw new InvoicePersistenceError(invoice.id, { cause: error });
}
```

## Absence Is Not Infrastructure Failure

Bad:
```ts
const user = await users.find(id);
if (!user) return null;
```

Good:
```ts
const result = await users.find(id);
if (result.type === "not_found") return { type: "absent" };
if (result.type === "db_error") return { type: "dependency_failure", cause: result.error };
return { type: "found", user: result.user };
```

## Mock Boundaries, Not Internals

Bad:
```ts
expect(emailRenderer.render).toHaveBeenCalledBefore(mailClient.send);
```

Good:
```ts
await sendWelcomeEmail(user);
expect(fakeMailClient.sentMessages).toContainEqual(
  expect.objectContaining({ to: user.email, subject: "Welcome" }),
);
```

## One Adapter Is Usually Not A Seam

Bad:
```ts
interface UserRepositoryAdapter {
  query(sql: string): Promise<unknown[]>;
}
```

Good:
```ts
async function loadActiveUsers(accountId: AccountId): Promise<User[]> {
  return db.user.findMany({ where: { accountId, archivedAt: null } });
}
```

Add a seam when there are two real adapters or a volatile external boundary.

## Module Lifecycle Completeness

Bad:
```text
Task: create Projects module
Implemented: createProject, updateProject
Missing: list/detail, validation errors, delete/archive/restore semantics, permissions, idempotency, tests
```

Good:
```text
Task: create Projects module
Included: create, list, detail, update, archive, restore, permission checks, duplicate-name conflict, validation errors, audit timestamps, behavior tests
Excluded: hard delete — blocked pending retention policy decision
```

## Test Friction Is A Design Smell

Bad:
```text
Skipped tests because creating a valid Booking requires 14 unrelated fields.
```

Good:
```text
Added makeBookingFixture({ startsAt, clinicianId }) and tested booking conflict behavior through the public scheduler seam.
```
