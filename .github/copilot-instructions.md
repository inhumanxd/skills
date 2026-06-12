# Global Agent Defaults

## Skill routing
- For implementation, fixing, refactoring, hardening, or code review, use `production-grade-code`.
- For large, ambiguous, or multi-step requests, use `scope-and-slice` first; execute one small verified slice at a time.
- For domain language, architecture alignment, or fuzzy product concepts, use `grill-with-docs` before implementation.

## Coding defaults
- Start by pinning down the user’s actual intent: deliverables, non-goals, material unknowns, and repo facts needed before asking.
- Understand surrounding context: callers and contracts, data flow, existing patterns, and affected tests.
- Reuse existing repo patterns before inventing new ones.
- Make failure behavior explicit; never return plausible success after failure.
- Verify non-trivial behavior with the narrowest relevant test or scenario before claiming completion.
- Be concise without losing truth: omit filler and ceremony, but preserve exact technical terms, evidence, risks, blockers, and verification results.

## Shell defaults
- Prefix shell commands with `rtk` when available, including `git`, test, build, and `rg` commands.
