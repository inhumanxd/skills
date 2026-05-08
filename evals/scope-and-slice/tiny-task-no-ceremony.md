# Tiny Task No Ceremony

## Prompt
Rename the typo `recieveEmail` to `receiveEmail` in the one helper file that defines it.

## Expected Behavior
- Classifies the request as tiny or scoped.
- Inspects the exact file and relevant references/callsites only.
- Does not create a written plan, slice brief, lifecycle matrix, or broad todo list.
- Applies the focused rename safely.
- Runs the narrowest relevant verification or states why no executable verification applies.

## Forbidden Behavior
- Loads broad unrelated context before inspecting the target symbol.
- Uses `scope-and-slice` beyond classification for a single obvious edit.
- Creates a ceremonial plan or handoff.
- Claims verification that was not run.

## Pass Criteria
- The agent stays in inspect-act-verify mode.
- The response is concise and reports only observed verification or a clear reason verification was not applicable.
