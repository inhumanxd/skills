---
name: handoff
description: "Generates concise backend-change handoff docs for frontend, QA, backend, or all audiences. Use when: /handoff, /handoff frontend, /handoff backend, /handoff qa, /handoff all, frontend handoff, QA test handoff, backend handoff, implementation handoff after backend changes."
argument-hint: "frontend | backend | qa | all [optional change scope]"
---

# Handoff

Generate need-to-know handoff docs from completed backend changes. Write like a senior backend engineer handing context to another senior engineer: direct, scoped, and useful without restating Swagger or the diff.

## Invocation

- `/handoff frontend` creates a frontend handoff.
- `/handoff qa` creates a QA handoff.
- `/handoff backend` creates a backend handoff.
- `/handoff all` creates separate frontend, QA, and backend handoff docs.
- If the audience is missing, stop and ask exactly: `Which handoff should I create: frontend, backend, qa, or all?`
- Do not generate a handoff until the audience is clear.

Accept common aliases only after normalizing them to the four audience values: `fe`/`ui` -> `frontend`, `be`/`api` -> `backend`, `test`/`tester` -> `qa`.

## Source Of Truth

1. Use the user's stated scope when provided: branch, commit range, PR, files, module, or task name.
2. If no scope is provided, use the current worktree and staged diff.
3. Inspect only the files needed to understand the contract: routes, controllers, validators, services, models, migrations, Swagger, Hoppscotch, and module context.
4. If the module is identifiable, read `.modules/<module>/CONTEXT.md` before source files.
5. Cross-check endpoint method/path/request/response details against Swagger, but do not copy full schemas into the handoff.
6. Do not guess. If a detail matters and cannot be verified quickly, put it under `Open Questions` or ask before writing.

## Output Files

- Create one Markdown file per requested audience.
- Prefer the current task directory: `tasks/<module>/<task>.handoff.<audience>.md`.
- If a matching walkthrough exists, reuse its directory and slug.
- If the module or slug cannot be inferred from the change scope, ask one concise question for the missing value.
- Keep generated handoffs task-scoped. Do not put them in `docs/` unless the user explicitly asks for reusable documentation.

## Brevity Rules

- Frontend and backend handoffs: target 15-25 lines.
- QA handoffs: target 25-45 lines.
- Use bullets, short labels, and exact endpoint names.
- Mention Swagger file names or endpoint paths instead of reproducing schemas.
- Include only behavior, contracts, risks, migration/state, and testing notes that affect the audience.
- Omit implementation trivia, commit narration, generic summaries, and long background.
- Include `Open Questions` only when there are real unresolved items.

## Audience Content

- Frontend handoff template and audience rules: [references/frontend.md](references/frontend.md)
- QA handoff template and audience rules: [references/qa.md](references/qa.md)
- Backend handoff template and audience rules: [references/backend.md](references/backend.md)

Read only the requested audience file. For `/handoff all`, read all three and create separate docs.

## Final Response

After creating docs, reply with:

- created file paths
- audience(s) covered
- any Swagger/source gaps that could not be verified
- any Notion/task tracker update that failed

Keep the final reply shorter than the generated docs.