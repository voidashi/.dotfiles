# Working conventions

How this repo works with an AI coding agent. Portable: take it into another
project and adapt the file names. `ADOPTING-CONVENTIONS.md` covers how to set it
up in a new repo and can be deleted once you have.

This is the entry point. It holds the framing and the two orientation sections;
the rules themselves are grouped by subject and imported below, which is
organisation rather than economy, since an `@` import loads at launch exactly
like the file that imports it.

@rules/documents.md
@rules/verification.md
@rules/design.md
@rules/sessions.md
@rules/instructing.md

Each rule is an instruction, not an argument. Rules marked **(paid)** came from a
failure in this repo, with the incident named. Rules marked **(borrowed)** are
general practice that has not bitten us yet; treat them as weaker and drop them
if they do not earn their place. When a borrowed rule finally costs you
something, rewrite it as paid with what happened.

All of this loads on every session, so it is kept to rules. The mechanism that
would make it cheaper is a `paths:` field on a file under `.claude/rules/`, which
loads only when the agent reads a matching file. That is deliberately not used
yet: the globs would be project-specific, and this file's whole value is that it
is not.

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

