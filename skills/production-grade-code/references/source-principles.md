# Source Principles Reference

This skill condenses observed guidance from high-signal engineering sources. Do not apply any source as dogma; the governing standard is production correctness, maintainability, and fit to the real codebase.

## Skill Authoring Guidance Applied

- Matt Pocock's skills emphasize small, composable skills, shared domain language, feedback loops, and architecture care.
- Matt's `write-a-skill` guidance recommends concise `SKILL.md`, progressive disclosure, and splitting content into supporting files when the main skill grows.
- Anthropic skill guidance recommends assuming Claude is already smart, keeping the active skill concise, and loading reference files only when needed.
- GitHub Copilot skill guidance emphasizes keyword-dense descriptions, high-signal gotchas, flexible guidance for open-ended work, and splitting near 200 lines.

## Engineering Sources Applied

- John Ousterhout, _A Philosophy of Software Design_: deep modules, simple interfaces with high leverage, choosing what matters, avoiding shallow abstractions.
- Martin Fowler, _Refactoring_: safe behavior-preserving transformations backed by tests.
- Michael Feathers, _Working Effectively with Legacy Code_: seams, test harnesses, and safe change in legacy systems.
- Eric Evans, _Domain-Driven Design_: ubiquitous language and domain-aligned module seams.
- Hunt and Thomas, _The Pragmatic Programmer_: DRY as knowledge deduplication, design by contract, tracer bullets, avoiding programming by coincidence, not outrunning feedback.
- Forsgren, Humble, and Kim, _Accelerate_: fast reliable feedback, small safe changes, quality and delivery speed reinforcing each other.

## Practical Synthesis

The best code is not the most abstract, shortest, or most pattern-heavy code. It is code where:

- Callers know the truth.
- Maintainers can find the rule that matters.
- Failure is explicit.
- Change is localized.
- Tests prove behavior without freezing internals.
- The implementation is only as clever as the domain requires.
    