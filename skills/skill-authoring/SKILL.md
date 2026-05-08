---
name: skill-authoring
description: "Improves, creates, and reviews agent skills and shared coding-agent instructions. Use when the user asks to create a skill, update a skill, improve agent behavior, refine prompts/instructions, add evaluations, validate skill structure, or apply Anthropic/Matt Pocock skill-writing guidance."
---

# Skill Authoring

Create skills that make future agents behave better on real tasks, not just read better to humans.

## Operating Loop

1. **Start from observed behavior** — identify the agent failure, repeated instruction, workflow, or missing context the skill should fix.
2. **Define trigger scope** — decide when the skill should load and when it should not.
3. **Keep `SKILL.md` lean** — put active protocol and navigation in `SKILL.md`; move detailed references, templates, and examples to one-level supporting files.
4. **Set the right freedom** — use high-level guidance for judgment tasks, exact steps or scripts for fragile operations.
5. **Add feedback loops** — include validation, tests, or review checklists for quality-critical work.
6. **Evaluate with real prompts** — add or update evals that prove the skill changes agent behavior.

## Skill Quality Gate

Before finishing a skill change, verify:

- `name` is lowercase kebab-case, concrete, and not reserved.
- `description` says what the skill does and when to use it, with trigger terms a user would actually say.
- `SKILL.md` assumes the model is competent; it avoids generic explanation and keeps only reusable non-obvious guidance.
- References are one level deep from `SKILL.md` and named by content, not `doc1.md` or vague labels.
- Detailed material is not duplicated between `SKILL.md` and references.
- Examples are concrete bad/good or input/output pairs, not abstract advice.
- Scripts are used for deterministic, repetitive, or fragile operations and include clear error output.
- Critical workflows include a validator/fix/retry loop.
- No time-sensitive guidance is written as a future condition; current and legacy paths are explicit.
- The change includes at least one eval or rubric when it changes expected agent behavior.

## Evaluation Pattern

Use `evals/<skill-name>/<case>.md` for behavior rubrics. Each eval should include:

```md
# <Case Name>

## Prompt
<representative user request>

## Expected Behavior
- <observable behavior the agent must perform>

## Forbidden Behavior
- <failure mode the skill is meant to prevent>

## Pass Criteria
- <how a reviewer can decide pass/fail>
```

## Common Fixes

- Vague description → add exact trigger phrases and contexts.
- Bloated `SKILL.md` → move rarely needed detail to `references/` and link it directly.
- Skill not followed → make the required step earlier, shorter, and more concrete.
- Agent skips verification → add an explicit feedback loop and eval for that failure.
- Agent over-applies skill → narrow description triggers and add non-goals.

Run `python3 scripts/validate-skills.py` after editing skills.
