---
description: Close a working session. Checks that what was done is committed and that the TODO reflects reality, so the next session can resume from the repo alone. Use when the user says they are done, wrapping up, or stopping for now.
disable-model-invocation: true
---

## Working tree

!`git -C "$(git rev-parse --show-toplevel)" status --short || echo "clean"`

## Commits this session

!`git -C "$(git rev-parse --show-toplevel)" log --oneline --since="12 hours ago"`

## Current TODO

!`cat "$(git rev-parse --show-toplevel)/docs/TODO.md"`

## Instructions

The context window is scratch space: anything that must outlive this session has
to be on disk before it ends. Work through these and report what you changed.

1. **Uncommitted work.** If the tree is not clean, say what is there and why it
   is uncommitted. Offer to commit it. Do not commit without approval, and do not
   commit something an external program wrote as if it were our change.
2. **Prune the TODO.** Remove what the commits above actually finished. Finished
   means the check passed, not that the edit was made.
3. **Write down what was parked.** Anything abandoned unsolved needs what was
   *ruled out*, not just "does not work": a parked problem with its bisect
   written down is cheap to resume, one without is a full restart.
4. **Place the durable facts.** A rule that would stop someone breaking
   something goes to `CLAUDE.md`. A decision that explains why the repo is shaped
   the way it is goes to `docs/SESSION-HISTORY.md`, which records turning points
   and is not a diary. A settled decision leaves the TODO entirely, including
   "we deliberately will not do this".
5. **Aim for the resume test.** Someone with no memory of this session should be
   able to pick up from the repo alone. Say plainly if they could not.

Finish by naming anything you could not resolve and left for next time.
