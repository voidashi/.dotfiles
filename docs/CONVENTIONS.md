# Working conventions

How this repo works with an AI coding agent. Portable: copy it into another
project and adapt the file names. `ADOPTING-CONVENTIONS.md` covers how to set it
up in a new repo and can be deleted once you have.

This file is loaded on every session, so it is kept to rules. Each one is an
instruction, not an argument. Rules marked **(paid)** came from a failure in
this repo, with the incident named. Rules marked **(borrowed)** are general
practice that has not bitten us yet; treat them as weaker and drop them if they
do not earn their place. When a borrowed rule finally costs you something,
rewrite it as paid with what happened.

---

## Where things live

| Document                         | Answers                                                           | When it applies                                          |
| -------------------------------- | ----------------------------------------------------------------- | -------------------------------------------------------- |
| `CLAUDE.md`                      | What must I know before touching this, or I will break something? | Always                                                   |
| `docs/TODO.md`                   | What is still to do?                                              | Always                                                   |
| `docs/SESSION-HISTORY.md`        | Why is the repo shaped this way?                                  | Once there is a turning point to record                  |
| `docs/design/`                   | What are the rules for how this looks and behaves?                | Only projects with a visual or behavioural identity      |
| `docs/specs/<feature>.md`        | What exactly are we building in this one piece of work?           | Per feature, deleted after it ships                      |
| `.claude/skills/<name>/SKILL.md` | How do we do this recurring task?                                 | When a procedure repeats but is not needed every session |

The first two are permanent. The rest are created when they have a first entry,
not in advance.

**Where does this fact go?** Would someone about to make a mistake need it:
`CLAUDE.md`. Would someone wondering why a strange structure exists need it:
the history. Is it work not yet done: `TODO.md`. Otherwise it probably belongs
in a comment beside the code it explains.

**When two documents disagree**, each is authoritative only on the question it
owns: `docs/design/` on appearance and behaviour, `CLAUDE.md` on what breaks,
the spec on the boundaries of the work in progress, and the code last. Code
losing to `CLAUDE.md` usually means the document went stale, and the fix belongs
in the document. The agent stops and asks rather than picking a side, because
silently choosing is how a stale document survives another six months.

## Start here

Six rules do most of the work. Adopt these on day one and add the rest when
something goes wrong without them.

1. Open the session by reading `docs/TODO.md` and naming the task and the check
   that ends it. Close it by pruning what got done.
2. A decision leaves `TODO.md` the moment it is decided.
3. Give the agent a check it can run itself, and make it show the output rather
   than report a verdict.
4. One session, one task.
5. Treat the context window as scratch space: everything durable is on disk.
6. Commit before anything expensive to redo.

## Documents

### Every line in CLAUDE.md is paid for on every session **(borrowed)**

It loads whole, before any work starts. Ask of each line: would removing this
cause a mistake? If not, it spends attention and buys nothing. When a rule that
already exists is broken repeatedly, suspect the file's length before suspecting
the agent.

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

## Verification

### Convention, then checker, then hook **(paid)**

Three rungs, climbed as a rule proves violable. Prose is advisory, a checker is
a script you remember to run, a hook fires on the event and cannot be reasoned
out of. Write the checker the first time the convention is broken, because that
is the proof it can be, and reserve prose for judgement calls. _A documented
rule to mirror theming across two window managers went unenforced through an
entire retheme; a twenty line checker found it in one run._

### Verify by measuring the result, not by reading the config **(paid)**

Reading a config tells you what it says, not what happened. Sample the pixel,
read the value back out of the running program, diff generated output against
what the generator produces now. Pointed at the agent this is the same rule:
**give it a check it can run itself**, in the same instruction as the work, or
you are the verification loop. _Three things here were configured, looked
configured, and did nothing, with no error message in any of the three._

### Report the measurement, not the conclusion **(paid)**

"It works now" is not a result, it is a claim about one. Show what was run and
what came back, so the reader can catch a misread before it becomes a decision.
A measurement quoted in full also survives into the next session; a verdict does
not. _Twice in one session a conclusion was reported as verified and was wrong:
a pixel sampled at the wrong coordinates after the window moved, and a bug
called fixed on the strength of a log line that meant something else. Both were
caught by the person who had actually watched the screen, which is the loop this
rule exists to close._

### Generated files must be marked and verified **(paid)**

A `GENERATED` header, and a check that regeneration is idempotent. Without the
second half a hand edit survives until the next regeneration silently discards
it. _Applies to any project with codegen; skip it if nothing is generated._

### The author is the wrong reviewer **(borrowed)**

An agent reviewing its own diff still holds the reasoning that produced it and
will defend it. Review in a fresh context, scoped: gaps against stated
requirements and correctness, style ruled out explicitly. Anything asked to find
problems will find some.

## Design and dependencies

### Prefer the mechanism the tool already has **(paid)**

Override the named colours a toolkit already paints from rather than shipping a
theme; use the application's own config format rather than a wrapper. Reach for
a wrapper only when the tool has no config surface, and say so where it lives or
someone will delete it as redundant.

### Own your dependencies at the boundary that matters **(paid)**

Borrowing structure is free. Depending on a third party's key names is not: an
override matched by name breaks silently when upstream renames one. Decide which
you are doing. _An override that matched half its keys produced a themed surface
under a stock accent colour, which read as a bug in our code._

## Sessions

### One session, one task **(borrowed)**

Reset the context between unrelated tasks. A session that detours and returns
carries the detour for the rest of its life. Summarising is for continuity
inside one task; between two it hands the failed attempts of the first to the
second in compressed form.

### Two failed corrections mean the context is spent **(borrowed)**

After the same mistake is corrected twice, the window holds two wrong approaches
and the agent keeps reaching for them. Reset and reopen with a sharper prompt
built from what they taught you.

### The context window is scratch space **(paid)**

Anything that must outlive the session is on disk before it ends: the decision
in `CLAUDE.md`, the work in `TODO.md`, the turning point in the history, the
code in a commit. Aim for a state where someone with no memory of the session
can resume from the repo alone.

### Git is the boundary of what can be undone **(paid)**

Commit before anything you would hate to redo by hand: a bulk rename, a
regeneration, a refactor across files. The agent's checkpoints cover only files
it edited through its file tools; anything written by a shell command, a
generator or an external process is outside them and does not come back.
_Bulk rewrites in this repo are routinely done through shell heredocs, which are
exactly the case checkpoints miss._

### Work that would flood the context goes to a subagent **(borrowed)**

Answering one question by reading twenty files spends the main context on twenty
files to keep one paragraph. Delegate the search, take the summary. Scope it or
it reads the whole repo.

The same move buys a second thing: a subagent starts with no memory of the work,
which is what makes it a usable reviewer. Standing roles worth naming are an
architect that plans before anything is written, a reviewer that sees the diff
and the requirements but not the reasoning, and a searcher that answers one
scoped question. Name the role in the request rather than assuming the default
agent will adopt it.

### Name sessions after workstreams **(borrowed)**

Resumable sessions are only useful if you can tell them apart. One name per
workstream, and separate checkouts when two touch the same files.

### Start at the TODO and end at the TODO **(paid)**

Open by naming, in one line, the task and the check that will end it. Close by
pruning what got done and writing what was parked, with what was ruled out.
_A session that starts unnamed drifts; one that ends without updating the list
leaves the next to reconstruct where things stood from a diff._

## Instructing the agent

### Ask when the answer changes the work, decide otherwise **(paid)**

Aesthetic preference, irreversible action, and anything where two readings give
materially different output: ask. Everything else: decide, do it, and state the
assumption in one line so it can be corrected.

### Point at the evidence, not just the goal **(borrowed)**

Name the file, the symptom, and the pattern in the repo the new work should
resemble. "Fix the login bug" and "login fails after session timeout, look at
token refresh in `src/auth/`, write the failing test first" have different hit
rates. Keep the vague version for when you want to see what the agent notices
unprompted.

### Plan before the work, in proportion to the work **(paid)**

For anything touching several files or where the approach is not obvious, have
the agent read first and write a plan, then approve the plan rather than the
diff. The plan is worth writing when it is self-contained: the files it will
touch, what is explicitly out of scope, and the check that will prove it
finished. Skip it when you could describe the diff in one sentence, because the
plan then costs more than the change. _Every large piece of work here went this
way and none of them had to be unpicked; the one bulk substitution done without
a plan broke 26 lines and was reverted whole._

### One approved thing at a time **(paid)**

Propose, get approval, do it, commit, propose the next. Large mixed commits are
hard to review and harder to revert. The exception is a survey: gather the whole
list first, then work through it in approved batches.

### Approval fatigue is a failure mode **(borrowed)**

By the tenth prompt you are approving rather than reading. Allowlist what you
have already judged safe so the remaining prompts are ones you will look at. An
approval nobody read is worse than none, because it leaves a record that looks
like review.

### The agent reports what it found, including against itself **(paid)**

An edit that broke a sentence, a variable left unused in its own new code, a
scope that turned out larger than the one just quoted: say so plainly and fix
it. Confidence that survives contact with evidence is worth something;
confidence that does not is worse than none.
