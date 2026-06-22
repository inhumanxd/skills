# Plan-* Variant Routing

Tests that the orchestrator picks the right multi-model variant (or none) from the
request and budget signals. The three `plan-*` skills are near-twins; the
disambiguators are **who designs** (Opus vs GPT-5.5) and **which budget is scarce**.

## Prompt
Route each request to one variant — or to no workflow at all:
1. "Plan this refactor well with Opus, then have GPT-5.5 build it."
2. "My Codex quota is nearly out — plan it properly but keep GPT off the build."
3. "Let GPT-5.5 design the approach; Opus can do the implementation."
4. "Fix this one-line typo in `parseDate`."
5. "Build this feature; my Codex 7-day bar is ~100%, conserve it — I still want Opus planning."
6. "I want GPT-5.5's reasoning on the architecture, but my Codex quota is tiny."

## Expected Behavior
- (1) → `plan-opus-execute-codex` (Opus plans, GPT-5.5 builds).
- (2) → a Codex-light variant; default `plan-opus-execute-sonnet` (Opus still plans, Sonnet builds) unless the user wants GPT-5.5 to design.
- (3), (6) → `plan-codex-execute-opus` (GPT-5.5 plans, Opus builds, GPT-5.5 only reviews).
- (4) → no `plan-*` workflow; a single focused edit (`production-grade-code` at most).
- (5) → `plan-opus-execute-sonnet` (Opus plans, Sonnet builds, Codex only reviews).
- When budget is ambiguous, reads `omp usage` (the **Openai Codex** account) once before choosing.

## Forbidden Behavior
- Routing a trivial one-file edit into any `plan-*` workflow.
- Picking `plan-opus-execute-codex` when the Codex/GPT-5.5 budget is signalled scarce.
- Confusing the two Codex-light variants: building on Sonnet when the user explicitly wants GPT-5.5 to design (that is `plan-codex-execute-opus`), or routing to `plan-codex-execute-opus` when the user wants Opus to design (that is `plan-opus-execute-sonnet`).
- Inventing a fourth variant or mixing seats not in the chosen skill's table.

## Pass Criteria
- Each prompt maps to the variant named above (or to none for the trivial edit).
- The two Codex-light variants are distinguished by who designs: Opus → Sonnet variant; GPT-5.5 → `plan-codex-execute-opus`.
- Budget-driven choices cite the **Openai Codex** usage signal rather than guessing.
