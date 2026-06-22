# Skill Evaluations

These rubrics define representative tasks that should improve when the skills are working. They are not executable tests by themselves; use them to review fresh agent runs or to build automated evals later.

Each eval records:

- **Prompt** — the user request or scenario.
- **Expected Behavior** — observable actions the agent should take.
- **Forbidden Behavior** — failure modes the skill should prevent.
- **Pass Criteria** — reviewer-readable acceptance criteria.

When a skill change is meant to improve agent behavior, add or update an eval that would have caught the old behavior.

Coverage is partial — eval folders exist for `fleet`, `production-grade-code`, `scope-and-slice`, and `plan-opus-execute-codex` (its `variant-routing.md` covers all three `plan-*` variants). Still uncovered: `grill-me`, `grill-with-docs`, `handoff`, `skill-authoring`. Add one when a change to those skills needs regression cover.
