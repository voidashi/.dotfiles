# TODO

Open work, carried across sessions. Check this before assuming the rice or the repo is
finished.

Each item carries a **difficulty** and a **priority**. Difficulty is about how much work and
how much can go wrong; priority is about how much it costs to leave undone. They are
independent: deleting the legacy configs was trivial and worth doing, the elegance pass is
neither trivial nor urgent.

Decisions already made, and state that is merely being tracked, do not live here. Those
belong in `CLAUDE.md` (rules and gotchas), `docs/design/THEME-STATUS.md` (what is themed)
and `docs/SESSION-HISTORY.md` (what happened).

## Next up: the documentation pass for publication

**This is the task for the next session, and it wants a clean context.** The repo is
headed for publication and already has stars, so the question every document has to answer
is no longer "does this help us" but "does this help someone who cloned this". Nothing here
blocks a publish today; this is about the repo reading like it was written for a reader.

**The agreed method, decided rather than assumed:** survey first, edit nothing. Produce a
list saying, per document, what it claims today, what only makes sense to us, and what is
worth reframing as an explanation of *why something is built this way* rather than a record
of who decided what and when. Jeff approves the list, then it gets worked in approved
batches, the same shape as the elegance pass. The survey exists because the tempting move
is to open `SESSION-HISTORY.md` and start rewriting, and the shape of the whole thing is
not obvious until all of it has been read.

**What is already known, so it does not get re-derived:**

- The inventory is 2,300 lines across eight files. `DESIGN-SYSTEM.md` (840) and
  `RICE-GUIDE.md` (501) are the large ones, then `AESTHETIC-DIRECTION.md` (276),
  `THEME-STATUS.md` (220), `CLAUDE.md` (164), `README.md` (137), `TODO.md` (88),
  `SESSION-HISTORY.md` (75).
- **Mentions of the agent are far fewer than they look.** Grepping finds them mostly in
  `THEME-STATUS.md`, and those are all cross-references to `CLAUDE.md`, which is a normal
  file for an agent-assisted repo and is not personal. The genuine cases are two: the
  section `RICE-GUIDE.md:395`, "Working rules for Claude Code", which is instruction to an
  agent sitting inside a design document, and `CLAUDE.md`'s own framing line. So the
  agent-mention half of this task is small.
- **`SESSION-HISTORY.md` is the real work.** All 75 lines are about personal working
  decisions. Some turning points explain something a reader can see in the tree and should
  survive, reframed; the rest is a record of a collaboration, which is nobody else's
  business. Decide whether the document keeps its name.
- The working conventions have already left this repo, so there is nothing of that kind
  left to remove. `.claude/skills/verify-repo/` stays on purpose: it is about this repo's
  own validators and is useful to whoever clones it.
- **Do not add entries to `SESSION-HISTORY.md` before this pass.** Anything written now is
  written in the voice the pass exists to change, and would be work thrown away.

**Open questions to settle during the survey**, not before: whether flat `docs/` survives
or becomes a structure or a wiki; whether `DESIGN-SYSTEM.md`, which covers the web/document
side rather than the desktop, belongs in a published dotfiles repo at all; and whether the
README carries enough for someone to actually use this, since it has never been read with
that question in mind.

*Difficulty: medium, and open-ended, but smaller than it first looked. Priority: high now
that it is the next task, and it rises the moment you push.*

## Parked: diagnosed, not solved

- **Workspaces are not clickable in waybar, and it is not our config.** A full bisect ruled
  out everything on our side, so this is parked rather than solved. What is established:

  - Not the stylesheet. It fails identically with `/etc/xdg/waybar/style.css`.
  - Not the layer. It fails on both `bottom` (waybar's default) and `top`.
  - Not `persistent-workspaces`. It fails with both the legacy `{"1": [], ...}` form and
    the documented `{"*": 5}` form.
  - Not a missing `on-click`. Probes on `on-click`, `on-click-right`, `on-click-middle`
    and `on-scroll-up` running `notify-send` never fired once.
  - Not the bar's input in general. `clock` toggles and `custom/power` opens the menu, and
    hovering a workspace button does highlight it, so the widget receives motion events.
  - Nothing reaches Hyprland either: with `-l debug`, a click produces no dispatch line and
    no `workspace>>` event, while a keyboard switch produces both.

  So the buttons in waybar 0.15.0's `hyprland/workspaces` take motion events but no button
  events at all, in this build. Next avenues, in order of cost: check upstream issues for
  this version, try a different waybar build, or replace the module with a `custom` one
  that renders and dispatches workspaces itself, which would cost the module's live
  updates. Three genuine config defects were fixed along the way and are worth keeping
  regardless: `layer` is now `top`, `persistent-workspaces` uses the documented form, and a
  `disable-scroll` that belongs to `sway/workspaces` was removed.
  *Difficulty: high, now that the cheap explanations are gone. Priority: medium, since
  keyboard switching works and this is a convenience.*

## Then: quality and housekeeping

- **Elegance pass over structure, organisation and code.** Several things work but are not
  elegant. Worth a deliberate sweep for duplicated structure, files that exist for no
  current reason, inconsistent naming across the scripts, and configs that repeat what a
  shared source could hold. Open-ended by nature, so it should produce a list to approve
  before anything is moved.
  *Difficulty: high, and open-ended. Priority: medium.*

- **Wallpaper curation.** Still whatever it was before. Needs real images chosen against
  the Wallpaper section of `RICE-GUIDE.md`: material, desaturated, dark, sitting at or
  below void-00 in perceived lightness. This needs assets, not config edits.
  *Difficulty: medium, but blocked on sourcing images. Priority: medium.*

## Low priority

- **Dolphin's icons are still breeze-dark**, so folders come out blue against a Voidashi
  window. It is the only monochrome-ish set installed, and the alternatives on the machine
  (Adwaita, breeze, Breeze_Light) are no better aligned. Needs an icon theme chosen and
  installed, which is a different kind of work from everything else here: an asset
  decision, not a config one.
  *Difficulty: low once a set is chosen. Priority: low.*

## Ongoing: how the writing reads

- **Clean the AI writing tells out of the remaining documents.** No em dashes, no saying a
  thing then restating it inverted. `RICE-GUIDE.md`, `DESIGN-SYSTEM.md` and
  `THEME-STATUS.md` are done; what is left is `CLAUDE.md` (30), `AESTHETIC-DIRECTION.md`
  (40) and the README (4).
  Clean each when something else takes you into it. Note from doing the first three: an em
  dash joining two independent clauses needs a semicolon, not a comma, and a subordinate
  clause opening with "If" or "When" needs the comma, so a blanket substitution produces
  comma splices either way and the changed lines have to be read. The tic also appears as a
  double hyphen standing in for the dash, which is what the code carried; those are done.
  **Fold this into the documentation pass above rather than doing it separately**, since
  that pass opens all three remaining files anyway and reading a paragraph twice for two
  different reasons is the waste.
  *Difficulty: low per file. Priority: low on its own, but free alongside the pass.*
