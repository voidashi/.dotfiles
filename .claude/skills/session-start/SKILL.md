---
description: Open a working session. Loads the open work, recent commits and working tree state, then names the task and the check that will end it. Use at the start of a session, or when the user asks what to work on or where things stood.
---

## Open work

!`cat "$(git rev-parse --show-toplevel)/docs/TODO.md"`

## Recent commits

!`git -C "$(git rev-parse --show-toplevel)" log --oneline -12`

## Working tree

!`git -C "$(git rev-parse --show-toplevel)" status --short || echo "clean"`

## Instructions

Everything above is already current; do not re-read those files.

Report, in this order and briefly:

1. **Where things stand.** What the last few commits were working on, and whether
   the tree is clean. If it is not clean, say what is uncommitted and whether it
   looks like our work in progress or something an external program wrote, since
   both happen in this repo.
2. **The task.** Name one item from the TODO as the task for this session, chosen
   on priority rather than on how easy it is. If the user already named a task,
   use theirs and skip the choosing.
3. **The check that ends it.** One line: the command or observation that will
   prove the task is done. If no such check exists, say so plainly, because that
   is itself worth knowing before starting.

Then stop and wait for approval. Do not begin the work from this skill.

One session, one task: if the user's request turns out to be a different task
from the one chosen, say so rather than doing both.
