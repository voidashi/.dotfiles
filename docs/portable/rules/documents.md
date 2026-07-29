## Documents


### Every line in CLAUDE.md is paid for on every session **(borrowed)**

It loads whole, before any work starts. Ask of each line: would removing this
cause a mistake? If not, it spends attention and buys nothing. When a rule that
already exists is broken repeatedly, suspect the file's length before suspecting
the agent. Aim under 200 lines, which is the documented threshold above which
adherence drops. Splitting into `@` imports organises but does not economise:
imported files load at launch too.

Three cheaper places exist for what does not belong there. A procedure that
repeats becomes a skill, whose body loads only when invoked. A rule that only
matters near certain files becomes a file under `.claude/rules/` with a `paths:`
glob, and loads only when the agent opens something matching. A note meant for
whoever maintains the file goes in a block-level HTML comment, which is stripped
before the file reaches the agent and therefore costs nothing.

Both halves of this are measurable rather than felt: `/context` lists what
actually loaded, and `/doctor` proposes trims, cutting what the agent could have
read out of the codebase and keeping the pitfalls and the rationale.

### Decisions leave the TODO the moment they are decided **(paid)**

Including "we deliberately will not do this". Move it to `CLAUDE.md` and say it
is final. _A settled decision about an orphaned config read as an open question
and was re-raised three sessions running._

### Difficulty and priority are independent **(paid)**

Rate both, separately. A one line fix can be urgent and a rewrite optional.
_Collapsed into one axis, two trivial broken keybinds sat behind a large
optional refactor._

### Record the cause, not just the fix **(paid)**

Write what was actually wrong, especially when the obvious explanation was not
it. When something is abandoned unsolved, record what was ruled out: a parked
problem with its bisect written down is cheap to resume, one with only "does not
work" is a full restart. _A waybar bug survived a full bisect; only the written
eliminations stop the next session repeating it._

### Writing style **(paid)**

No em dashes. No stating a thing then restating it inverted. No "worth noting".
Say it once. Documentation in English for portability. Code comments follow the
surrounding file, never two languages in one. _279 em dashes had to be cleaned
out of two design documents once the tic was noticed._
