# TODO

Open work, carried across sessions. Check this before assuming the rice or the repo is
finished.

Each item carries a **difficulty** and a **priority**. Difficulty is about how much work and
how much can go wrong; priority is about how much it costs to leave undone. They are
independent: deleting the legacy configs was trivial and worth doing, the elegance pass is
neither trivial nor urgent.

Decisions already made, and state that is merely being tracked, do not live here. Those
belong in `CLAUDE.md` (rules and gotchas), `docs/design/THEME-STATUS.md` (what is themed)
and `docs/TURNING-POINTS.md` (why the repo is shaped this way).

## In progress: the documentation pass for publication

The repo is headed for publication and already has stars, so the question every document has
to answer is no longer "does this help us" but "does this help someone who cloned this".
Nothing here blocks a publish; this is about the repo reading like it was written for a
reader. The survey ran on 2026-07-29 and produced the batches below, one commit each.

**Settled by the survey, so it does not get re-opened.** Flat `docs/` stays: six markdown
files and two images do not need a hierarchy, and a wiki would move the prose out of the
clone, which is a loss for documents that get read in an editor beside the configs.
`DESIGN-SYSTEM.md` stays as well, since it is the only reason the palette does not look
arbitrary, but the three sections it already marks "not applicable to desktop work" collapse
to a pointer each. Mentions of the agent turned out to be two rather than many:
`RICE-GUIDE.md`'s "Working rules for Claude Code" section, and `CLAUDE.md`'s framing line.

1. **Done.** README rewritten around the palette pipeline, which is the only unusual thing
   here, with a Known gaps section in place of four claims that were not true.
2. **Done.** `THEME-STATUS.md`'s four factual errors.
3. **Done.** `SESSION-HISTORY.md` became `TURNING-POINTS.md`, its framing cut to the rule a
   maintainer needs, and `docs/README.md` now indexes the six documents.
4. `RICE-GUIDE.md:395` retitled and reworded so it stops addressing an agent, plus
   `CLAUDE.md`'s 31 em dashes.
5. `DESIGN-SYSTEM.md`: sections 6.2, 15 and 16 collapse to pointers.
6. `AESTHETIC-DIRECTION.md`'s 42 em dashes.

**What this pass deliberately does not touch.** The agent workflow keeps working as it is, so
`CLAUDE.md` keeps its framing and the two lines that name Jeff; those files are to be removed
at publication rather than reworded now. Before that happens, the pitfalls in `CLAUDE.md` are
worth moving into a document under `docs/` instead of leaving with it: they are the most
useful prose here for anyone who cloned this, and each one cost a real debugging session to
find. `.claude/skills/verify-repo/` is the opposite case and stays either way, since it is
about this repo's own validators.

*Difficulty: low per remaining batch. Priority: high, and it rises the moment you push.*

- **Retake the screenshots.** `docs/screenshot1.png` and `screenshot2.png` were committed in
  April 2025, before the retheme, so the two images at the top of the README show the
  Kanagawa desktop this repo no longer contains. Jeff takes these; the README's rewrite
  leaves them in place rather than removing them, since a stale screenshot still beats none.
  *Difficulty: low. Priority: high, because it is the first thing a visitor sees.*

## Features to build

Four gaps found by checking the README's claims against the configs during the documentation
survey. The README stopped claiming them; these entries are the intent to build them.

- **Clipboard integration.** Nothing exists: no `cliphist`, no `wl-clipboard`, no binding,
  nothing in `packages.conf`. The usual shape on Wayland is `wl-clipboard` for copy and paste
  plus `cliphist` for history, with the picker on a keybind through wofi, which is already
  the launcher on both compositors. Mirror the binding across Hyprland and Sway, since
  anything shell-adjacent has to exist in both.
  *Difficulty: low. Priority: medium, it is a daily-use convenience that is simply absent.*

- **Battery-friendly power management.** Also nothing: no `hypridle`, no `swayidle`, no
  `tlp`, no `power-profiles-daemon`. Two separate pieces sit behind this label. Idle
  behaviour, meaning dim, lock and suspend after a timeout, which needs `hypridle` on
  Hyprland and `swayidle` on Sway and should reach the same `swaylock` that is already
  themed. And power profiles proper, which is a system daemon rather than a compositor
  concern. Decide whether both belong here or only the idle half.
  *Difficulty: medium, since it is two mechanisms and touches both compositors. Priority:
  medium, and higher if this machine runs on battery often.*

- **Context-aware workspace layouts.** Something real exists underneath, so this one is an
  extension rather than a build: `hypr/conf/window_rules.lua:10-16` already drops gaps and
  borders when a workspace holds a single window, through Hyprland's `w[tv1]` and `f[1]`
  selectors. What does not exist is any per-application assignment, which is what the phrase
  promises. Decide what the rule should actually be before writing it, because a workspace
  map that fights how you work is worse than none.
  *Difficulty: low to write, and the design is the real work. Priority: low.*

- **Sway has no notification daemon.** Its only `exec` lines are waybar and swaybg, so
  swaync runs under Hyprland and nothing catches notifications under Sway. The config and
  the stylesheet already exist and are themed, so this is one `exec` line plus a check that
  it does not collide with anything Sway starts on its own. Note also that `dunst` is still
  declared in `packages.conf` although nothing launches it; `.config/dunst/` is kept
  deliberately as a reference, but installing the package is a separate question.
  *Difficulty: low. Priority: medium, since it is a silent failure of exactly the kind this
  repo keeps producing: configured, looks configured, never runs.*

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
  `THEME-STATUS.md` are done and verified at zero; what is left is `CLAUDE.md` (31),
  `AESTHETIC-DIRECTION.md` (42) and the README (4).
  Clean each when something else takes you into it. Note from doing the first three: an em
  dash joining two independent clauses needs a semicolon, not a comma, and a subordinate
  clause opening with "If" or "When" needs the comma, so a blanket substitution produces
  comma splices either way and the changed lines have to be read. The tic also appears as a
  double hyphen standing in for the dash, which is what the code carried; those are done.
  **Fold this into the documentation pass above rather than doing it separately**, since
  that pass opens all three remaining files anyway and reading a paragraph twice for two
  different reasons is the waste.
  *Difficulty: low per file. Priority: low on its own, but free alongside the pass.*
