# Review checklist

## Method (in order)
1. Intent: what should this change do? Which files should it touch?
   Unexpected files are the first red flag.
2. Tests first: what do they promise? Were any weakened or deleted?
3. Trace one real input through the changed code, end to end.
4. Failure questions:
   - empty / missing / huge input
   - errors handled, or swallowed?
   - fails halfway: partial writes, retries
   - off-by-one, units, time zones
   - cleanup: files, connections, locks
   - two things at once: races, shared state
5. Outside the diff: `grr` on changed functions. Did a caller break?
6. Could it be smaller? Unneeded abstraction, impossible-case fallbacks,
   a helper that already exists.
7. Run it. Try to break it.

## Agent failure modes
- APIs or flags that don't exist
- tests edited to pass instead of the code fixed
- catch-all error handling that hides failures
- edits to unrelated files
- comments describing what the code should do, not what it does

## Keys
`]h` `[h` hunks · `Tab` `S-Tab` files · `<leader>hs` approve (stage)
`<leader>hr` discard · `<leader>a` ask the agent · `gd` `grr` `K` investigate

## Bugs I missed (add one line each time; they become new checks)
-
