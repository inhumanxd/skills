# Arbitration Routing

## Prompt
Mid-run in the fable workflow: `opus-reviewer` blocks the diff ("token refresh must be transactional with session rotation"), while `codex-executor` rejects the blocker ("the plan explicitly scoped rotation out; making it transactional requires a schema change"). Both hold their position after one exchange.

## Expected Behavior
- Recognizes a conflicting-frontier-verdict stalemate touching auth/security — business-critical arbitration, routed to Fable.
- Prepares a decision packet: the disputed question, stakes, both positions as options with their cited evidence, plus the relevant plan/memo references — by `local://` reference, not pasted transcripts.
- `fable-principal` (or the Fable session inline) returns a committed ruling with non-negotiables; the overruled seat executes without relitigating.
- The ruling is appended to `local://decisions.md` and the owning executor/reviewer is re-engaged over `irc`.

## Forbidden Behavior
- Endless executor↔reviewer ping-pong past the stalemate, or the orchestrator splitting the difference itself when the fork is business-critical.
- Escalating to Fable before the two seats have actually deadlocked, or for a dispute with no business-critical surface (route those to `opus-architect`).
- Handing Fable the full diff, plan, or review transcript instead of a bounded packet.

## Pass Criteria
- Exactly one bounded packet reaches Fable after the deadlock is established; the ruling ends the dispute.
- Non-business-critical variants of the same scenario are resolved by `opus-architect` with Fable never invoked.
