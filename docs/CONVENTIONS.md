# Working conventions

**This file is portable.** It describes a way of organising documentation and
working with an AI coding agent that was arrived at by hitting the failure modes
it prevents, not by design. Copy it into another project and adapt the file
names; the principles do not depend on this repo being a dotfiles repo.

It has a second job here: to stop us drifting from decisions we already made.
Every rule below exists because something went wrong without it, and the failure
is recorded alongside so the rule is not obeyed on faith.

---

## The four documents, and why they do not overlap

Most documentation rots because a fact has no obvious home, so it gets written
wherever someone is typing, then contradicts its copy elsewhere. Give each
document one question to answer and the ambiguity disappears.

| Document | Answers | Lifecycle |
|---|---|---|
| `CLAUDE.md` | What must I know before touching this, or I will break something? | Edited in place. Grows slowly. |
| `docs/TODO.md` | What is still to do? | Entries are deleted when done, never marked done. |
| `docs/SESSION-HISTORY.md` | Why is the repo shaped this way? | Turning points only. Rarely appended. |
| `docs/design/` | What are the rules for how this looks or behaves? | The authority. Code conforms to it, not the reverse. |

The test for where something goes: **would a person about to make a mistake need
this?** That is `CLAUDE.md`. Would someone wondering why a weird structure
exists need it? That is the history. Is it work not yet done? `TODO.md`.
Anything else probably belongs in a comment next to the code it explains.

## Rules

### Decisions leave the TODO the moment they are decided

A settled decision sitting in a task list reads as an open question and gets
re-raised every session. When something is decided, including "we deliberately
will not do this", move it to `CLAUDE.md` and say it is final.

*Cost of not doing this: the same orphaned config was raised as an open question
three sessions running.*

### Difficulty and priority are independent

Rate both, separately. A one line fix can be urgent and a rewrite can be
optional. Collapsing them into a single "importance" hides the cheap urgent
work behind the expensive unimportant kind.

### A rule nobody checks is a rule nobody follows

Where a convention can become a script, make it one. Not as ceremony: write the
check the first time the convention is violated, because that proves it is
violable.

*Cost of not doing this: a documented rule to mirror theming between two window
managers went unenforced through an entire retheme. A twenty line checker found
it in one run.*

### Record the cause, not just the fix

In commits and in docs, write what was actually wrong, especially when the
obvious explanation was not it. A future reader inherits the elimination for
free instead of re-deriving it.

Corollary: **when something is abandoned unsolved, record what was ruled out.**
A parked problem with its bisect written down is cheap to resume. A parked
problem with only "does not work" is a full restart.

### Verify by measuring the result, not by reading the config

Reading a config tells you what it says, not what happened. Sample the pixel,
read the value back out of the running program, diff the generated file against
what the generator produces now.

*Cost of not doing this: three separate things in this repo were configured,
looked configured, and did nothing, with no error message in any of the three.*

### Generated files must be marked and verified

A `GENERATED` header at the top and a check that regeneration is idempotent.
Without the second half, a hand edit to generated output survives until the next
regeneration silently discards it.

### Prefer the mechanism the tool already has

Override the named colours a toolkit already paints from rather than shipping a
theme. Use the application's own config format rather than a wrapper. Reach for
a wrapper only when the tool genuinely has no config surface, and say so where
it lives, or someone will delete it as redundant.

### Own your dependencies at the boundary that matters

Borrowing structure is free. Depending on a third party's key names is not: an
override matched by name breaks silently when upstream renames. Decide which one
you are doing.

## Working with the agent

### Ask when the answer changes the work, decide otherwise

Aesthetic preference, irreversible action, and anything where two readings lead
to materially different output: ask. Everything else: decide, do it, and state
the assumption in one line so it can be corrected.

### One approved thing at a time

Bring a proposal, get it approved, do it, commit, bring the next. Large mixed
commits are hard to review and harder to revert. The exception is a survey:
gather the whole list first, then work through it in approved batches.

### The agent should report what it found, including against itself

A misread measurement, an edit that broke a sentence, a variable left unused in
its own new code: say so plainly and fix it. Confidence that survives contact
with evidence is worth something; confidence that does not is worse than none.

### Writing style

No em dashes. No stating a thing and then restating it inverted. No "worth
noting" or "it's important to note". Say the thing once.

Documentation in English for portability. Code comments follow whatever the
surrounding file already uses; do not mix two languages inside one file.
