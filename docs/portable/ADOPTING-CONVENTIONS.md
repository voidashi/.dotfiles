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
3. Bring in `docs/portable/`: `CONVENTIONS.md` is the entry point and
   `rules/*.md` are the rules it imports, grouped by subject. Take this file too
   if you want the setup notes; it is not imported and costs nothing per session.
4. Add one line to `CLAUDE.md`:

   ```markdown
   See @docs/portable/CONVENTIONS.md for how we work in this repo.
   ```

5. Create `docs/TODO.md` with the first real task in it. Create nothing else.
6. Run `/context` and confirm the files appear under **Memory files**. An import
   that does not resolve fails silently: nothing errors, the rules simply never
   load. This has already happened once, when moving the files into
   `docs/portable/` left the import pointing at the old path.

Step 3 says "bring in" rather than "copy" because copying is the weakest of the
options. See the section on that below.

Order matters in one direction only. `/init` analyses the codebase to detect
build systems, test frameworks and code patterns, so a `CONVENTIONS.md` already
sitting there is one more file for it to read and fold into the `CLAUDE.md` you
are about to point at it, duplicating on line four what you copied in on line
three. Running it first avoids the overlap. That the duplication happens is
inference rather than something measured here; if you watch it do otherwise,
correct this file.

## Getting the files there: copy, symlink, or user-level

Copying is what this file used to say, and it is the option that ages worst. N
copies in N projects diverge, and a fix made in one is a fix the others never
see. That is not a hypothetical here: the rule about a shared source existing so
that copies cannot drift was paid for by three window-manager bar configs that
had silently diverged.

Two mechanisms avoid it. `.claude/rules/` resolves symlinks normally, so one
canonical copy can be linked into every project that wants it:

```bash
ln -s ~/where-the-canonical-copy-lives .claude/rules/conventions
```

And `~/.claude/rules/` holds personal rules that load in every project on the
machine with no per-project step at all. They load before project rules, so a
project can still override them.

Which to use is a question about scope, not about storage. Rules that describe
how *you* work travel with you and belong at user level. Rules that assume the
project has a `TODO.md`, a design document or a generator are about *this*
project and belong in it, where a collaborator can see and argue with them.
Putting the second kind at user level is how an agent starts citing a document
that does not exist.

Wherever the canonical copy lives, it should be somewhere that gets pushed. The
cheapest version of that is a repository you already back up, with the link
created by whatever already installs your dotfiles, so the conventions arrive on
a new machine in the same step as everything else.

One thing to verify rather than assume: symlink support is documented for a
project's `.claude/rules/` and is not stated either way for `~/.claude/rules/`.
`/context` answers it in one command.

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

Where the importing file sits decides who gets the rules. A `CLAUDE.md` in the
project root is checked in and applies to everyone working on the repo, which is
right for conventions the team has agreed to. `CLAUDE.local.md`, gitignored, is
the same load for you alone, and is where these belong in a repo whose owners
have not signed up for them. `~/.claude/CLAUDE.md` applies to every project you
open, which suits how you work rather than how a project works. Copying a
personal working style into a shared root file is how a convention starts being
resented instead of followed.

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
- A verified-sounding result was reported twice from a misread measurement, and
  both times the person watching the screen was the one who caught it.

Every one of those is a documentation or verification failure wearing a
domain-specific costume. That is the part that transfers.

## Where the borrowed rules come from

The ones marked **(borrowed)** are general practice, most of it stated in
Anthropic's own guidance at <https://code.claude.com/docs/en/best-practices>.
Read that for the mechanisms this file does not cover, since it describes tools
rather than habits: hooks that gate a turn on a check, `/goal` conditions,
non-interactive runs, and parallel sessions. Do not copy it in. It is versioned
upstream and will drift, and the point of `CONVENTIONS.md` is the subset that
survived contact with a real project.
