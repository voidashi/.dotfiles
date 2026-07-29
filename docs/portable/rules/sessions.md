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

Which disk matters. The agent also keeps its own notes, in
`~/.claude/projects/<repo>/memory/`, and those are machine-local: outside the
repo, outside git, and gone when you clone somewhere else. Treat them as a
convenience, never as the record. Anything a second machine or a second person
would need belongs in a versioned file. Compaction follows the same line: a
project-root `CLAUDE.md` is re-read from disk and re-injected afterwards, while
anything said only in conversation is not.

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

Both halves are procedures rather than facts, so they live as skills: `/session-start`
and `/session-end`. A skill's body loads when it is invoked instead of every
session, and it can inline the TODO, the log and the tree state before the agent
reads it, which beats spending four tool calls rebuilding the same picture. What
stays here is only the rule that they get run.
