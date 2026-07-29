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

## Before publishing

The documentation pass ran on 2026-07-29 and is done; what it left behind is here. See
`docs/TURNING-POINTS.md` for what it changed and why.

- **Decide what happens to `CLAUDE.md` and `.claude/`.** The plan is to remove them at
  publication, since a clone does not need them, and the agent workflow keeps using them
  until then. But the pitfalls in `CLAUDE.md` are the most useful prose here for anyone who
  cloned this repo, and each one cost a real debugging session to find: the Nerd Font
  codepoints that silently fall back to a box, the GTK4 accent that only answers to custom
  properties, the KDE daemon that rewrites `settings.ini`, the wofi import that resolves
  against the process cwd. Deleting the file throws that away. Moving it into a document
  under `docs/` keeps it. `.claude/skills/verify-repo/` is the opposite case and stays either
  way, since it only runs this repo's own validators.
  *Difficulty: low to move, and the decision is the work. Priority: high, it gates the push.*

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

Every document is at zero em dashes, verified rather than assumed, and the double hyphens
that stood in for them are out of the code as well. What stays is the standard, not a task:
no em dashes, and no saying a thing then restating it inverted.

Worth keeping from having done it, because the next person to try will hit it: a blanket
substitution does not work. An em dash between two independent clauses wants a semicolon, one
introducing an explanation wants a colon, one around a parenthetical wants parentheses, and
some sentences want rewording because no mark carries the sense. Comma everywhere produces
comma splices; semicolon everywhere produces fragments. The changed lines have to be read
afterwards, and doing that caught a broken sentence in two of the three passes.
