# Testing And Debugging Reference

## Testing Standard

For non-trivial code changes:

- Write or update tests for changed behavior, not implementation trivia.
- Test through the public interface or deepest correct module seam.
- Use one vertical slice at a time: one behavior test, implementation, verification, then next behavior.
- Prefer integration-style tests with real domain objects and existing test infrastructure.
- Mock only true external boundaries: vendor APIs, network services, time, randomness, filesystem, and sometimes databases when no test database or local substitute exists.
- Do not mock internal collaborators you control just to assert call counts or private sequencing.
- Include meaningful failure or edge cases when behavior branches.
- Run the narrowest command that proves the changed behavior.
- Report only observed verification results.

Do not suppress, skip, weaken, or delete tests to make code pass.

## TDD Shape

Use vertical red-green-refactor when building or fixing behavior:

1. Write one failing behavior test at the right seam.
2. Implement the minimum production code to pass it.
3. Run the test and observe green.
4. Add the next behavior or edge case.
5. Refactor only while green.

Avoid horizontal slicing: writing many imagined tests before any implementation often locks in the wrong interface.

## Debugging Loop

For bugs, build a feedback loop before guessing:

1. Reproduce the user's exact failure mode with a deterministic test, script, request, CLI command, browser path, trace replay, or throwaway harness.
2. Minimize the reproduction until the signal is sharp.
3. Generate multiple falsifiable hypotheses before editing.
4. Instrument one prediction at a time; prefer debugger/REPL inspection over broad logs.
5. Convert the reproduction into a regression test at the correct seam when possible.
6. Fix, verify the regression test, and re-run the original reproduction.
7. Remove temporary instrumentation and throwaway harnesses.

If no reliable feedback loop can be built, mark `[blocked]` and state what artifact or access is missing.

## Good Test Smells

Good tests:

- Read like a specification of user/caller-visible behavior.
- Survive internal refactors.
- Use public interfaces.
- Fail for the bug they are meant to prevent.
- Require little knowledge of private implementation.

Bad tests:

- Mock internal collaborators.
- Assert private call order.
- Query implementation state when the behavior has a public observation path.
- Break when code is reorganized but behavior is unchanged.
