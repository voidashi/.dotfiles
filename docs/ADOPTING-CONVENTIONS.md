# Adopting the conventions in a new project

Read once, then delete this file or leave it for the next person. It is not
imported into `CLAUDE.md` and costs nothing per session.

## Order

Run `/init` **before** copying anything in.

1. `/init` on the untouched repo. It reads the codebase and writes a `CLAUDE.md`
   describing the build commands, test runner and structure it found. Those are
   facts about the project, which is what that file is for.
2. Prune what it wrote. `/init` is generous, and the rule about paying for every
   line applies to its output first. Delete anything the agent could have
   learned by reading the code.
3. Copy `CONVENTIONS.md` into the repo, and this file beside it if you want the
   setup notes.
4. Add one line to `CLAUDE.md`:

   ```markdown
   See @docs/CONVENTIONS.md for how we work in this repo.
   ```

5. Create `docs/TODO.md` with the first real task in it. Create nothing else.

Order matters in one direction only: `/init` inspects the repository, so a
`CONVENTIONS.md` already sitting there is likely to be summarised into the
generated `CLAUDE.md`, duplicating the content you are about to import on the
next line. Running it first avoids the overlap. This is reasoning about how
`/init` behaves rather than a measured result, so if you watch it do something
else, correct this file.

## Loading: import or reference

The line above uses `@`, which loads the file eagerly, on every session, exactly
like `CLAUDE.md` itself. That is the point for rules meant to shape behaviour,
and it is the reason `CONVENTIONS.md` is kept short.

The alternative is a plain reference without the `@`, which leaves it on disk
for the agent to open when relevant. Cheaper, and unreliable for anything the
agent should not be able to skip. Pick the import for rules and the reference
for reference material.

Whichever you choose, make the repo actually do it. A file that prescribes one
loading method while the repo uses another is the first inconsistency someone
will copy.

## Day zero: the empty documents stay empty

`docs/SESSION-HISTORY.md` has no turning points yet, because nothing has turned.
`docs/design/` has no authority to assert until something looks a certain way on
purpose. `docs/specs/` has no feature in flight. Create each when it has a first
entry.

The temptation is to write the conventions you intend to follow into `CLAUDE.md`
in advance. A rule with no failure behind it is a guess: it costs context every
session and dilutes the rules that were paid for. Wait for the mistake, then
write the line.

`CONVENTIONS.md` is the exception, and only because its rules were paid for
somewhere else. That is why it marks each one **(paid)** or **(borrowed)**: the
paid ones name the incident, the borrowed ones are general practice that has not
yet cost anything here. Borrowed rules are the ones to drop first if they are
not earning their place, and to rewrite as paid the day one of them bites.

## Adapting to the project type

Not every rule transfers. Two are conditional:

- `docs/design/` and everything about visual authority applies only to projects
  with a visual or behavioural identity. A backend service has no equivalent,
  and the rows about it are noise there.
- "Generated files must be marked and verified" applies only where something is
  generated. Delete it otherwise rather than leaving a rule with nothing to
  govern.

The rest is about how work is organised and verified, and survives the change of
domain. If a third rule turns out not to transfer, delete it in that repo rather
than carrying a rule nobody follows: a convention that is visibly ignored
teaches that conventions here are optional.

## What this looked like in practice

The repo these came from is a personal dotfiles repository, so the specifics are
about colours and window managers. The failures were not about colours:

- A rule written in `CLAUDE.md` and never checked went unenforced through an
  entire redesign, until a twenty line script found it on its first run.
- Three separate things were configured, looked configured, and did nothing,
  none of them producing an error message.
- A settled decision left inside the task list was re-raised as an open question
  three sessions running.
- A history document written as a session diary reached 324 lines and started
  contradicting itself, because nobody prunes a diary.

Every one of those is a documentation or verification failure wearing a
domain-specific costume. That is the part that transfers.
