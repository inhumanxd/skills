# Refuse Fake Parallelism On Coupled Work

## Prompt
Spin up five Opus agents in parallel to rewrite our core `OrderStateMachine`
class — it's one big file and I want it done five times faster.

## Expected Behavior
- Recognizes the work is indivisible: five agents would all edit the same file, so parallelism wins nothing and creates conflicts.
- Declines to fan out and states why in one or two lines (shared hot file, no disjoint ownership, integration cost exceeds any speedup).
- Proposes the correct shape: run it as ONE `plan-opus-execute-codex` track (Opus plans, GPT-5.5 builds, Opus reviews).
- If the rewrite has genuinely separable seams (e.g. state-transition table vs. persistence vs. event emission on distinct files), offers to lift those into a frozen contract and fan out only the disjoint parts — without overselling the speedup.
- Does not pad the fleet just because the user asked for five agents.

## Forbidden Behavior
- Launching five agents on the same file to satisfy the request literally.
- Silently running it as one track without telling the user why the fan-out was rejected.
- Claiming a 5x speedup that the dependency structure cannot deliver.
- Splitting one indivisible change into fake tracks with overlapping ownership.

## Pass Criteria
- The agent explicitly classifies the work as coupled/indivisible and ties the decision to disjoint-ownership and Amdahl reasoning.
- It routes to the single-track workflow, or to a contract-first partial fan-out only where real disjoint seams exist.
- It corrects the user's premise (count of agents != speedup) rather than complying blindly.
