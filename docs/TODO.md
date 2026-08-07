# Open work

Everything here is something to do. Decisions already taken, including the decisions not
to do something, live in [`TURNING-POINTS.md`](TURNING-POINTS.md); what breaks if you
touch a thing is in [`MAINTENANCE.md`](MAINTENANCE.md); how the palette reaches each
application is in [`design/THEMING.md`](design/THEMING.md). If an entry below stops being
work, it moves to one of those rather than staying here as a record.

Each entry carries a **difficulty** and a **priority**, rated separately: difficulty is
how much work it is and how much can go wrong, priority is how much it costs to leave
alone. A one-line fix can be urgent and a rewrite optional.

Entries are grouped by the session that would do them, meaning they open the same files or
answer the same question. A flat list sorted by priority put two entries about the same
script two hundred lines apart, and a session that picks up the second one pays for the
first file all over again. The groups run in the order work can start rather than by
rating: the ones that can be done at this keyboard today come first, the ones waiting on
hardware, images or a decision come last. Inside a group, by priority.

## Start here next

"Documents that answer the same question twice", below. It is the cheapest group left
that finishes at this keyboard. After it, "The two compositors". Maybe in the same session.


## The two compositors

`.config/hypr/` against `.config/sway/`: what is mirrored between them and has
diverged, and what exists in one and not the other. The palette half of that divergence is
in "Configs that still paste hex" and not here.

- **The two compositors describe every runtime service twice, and have diverged.** The
  autostart block in `autostart.lua` against the run of `exec` lines in `sway/config`; the
  idle schedule in two syntaxes with a comment asking future editors to keep them in step;
  three screenshot binds under Hyprland against one bare `grim` under Sway; different
  launcher keys. The palette half of this divergence is closed: both compositors now read
  generated colour, Sway through an included partial and Hyprland through `palette.lua`,
  so what is left here is behaviour. Dropping Sway is not on the table: `sway/config` carries four findings that
  could only come from booting it, including notifications that were dead under Sway with
  the config themed and in place. The standing cost is that anything mirrored into
  `sway/config` from a Hyprland session is checked by `sway --validate` and never run. The
  brightness curve and the clipboard wipe both went in that way: confirmed working under
  Hyprland, untried under Sway.
  *Difficulty: high, now that the palette half has landed and what is left is the
  divergence. Priority: medium.*

- **The launcher and the keybinding open different terminals.** `.config/wofi/config` sets
  `term=alacritty` while `.config/hypr/conf/programs.lua` sets `terminal = "kitty"`.
  All four terminals are themed identically, which is why it went unnoticed. Pick one.
  *Difficulty: trivial. Priority: low.*

- **hyprlauncher's radius contradicts the floating rule.** `hyprtoolkit.conf` sets both
  `rounding_large` and `rounding_small` to 0, but a launcher floats and the guide gives a
  floating surface 4px. Confirmed on screen rather than only in the file: a capture of the
  launcher's layer shows square corners. Nothing renders it in daily use today, so fix it
  before switching back or the launcher arrives with the one geometry the design does not
  allow. The two keys are hand-written and stay that way, since neither is colour.
  *Difficulty: trivial. Priority: low while hyprlauncher stays off.*

- **The bar carries laptop-only modules with no guard.** `battery` and `backlight` sit in
  `modules-right` unconditionally, so on a desktop they are empty or absent, and
  `SETUP.md` tells a reader to remove them, which is a workaround. Waybar has no
  conditional module mechanism, so the options are a second `modules-right` in the
  per-compositor files or accepting the manual step.
  *Difficulty: low. Priority: low.*

- **Per-application workspace layouts.** `hypr/conf/window_rules.lua` already drops gaps
  and borders when a workspace holds one window, so this is an extension rather than
  a build. What does not exist is any application-to-workspace assignment. Decide the rule
  before writing it, because a workspace map that fights how you work is worse than none,
  and mirror it in the Sway config, which has no equivalent selectors and would need
  explicit `assign` rules.
  *Difficulty: low to write, and the design is the real work. Priority: low.*

## Documents that answer the same question twice

`docs/` and `docs/design/`. Each entry is one fact with two owners, which is the
failure the layout exists to prevent, so each is settled by deciding which document owns
the question and cutting the other copy.

- **`CLAUDE.md` holds one rule that exists nowhere else.** It claims it "can be deleted
  without losing anything", which is true of four of its five rules. "Never write a count
  that a config file owns" appears nowhere under `docs/`. Move it to `MAINTENANCE.md`
  before the file goes, and move the general form with it: a file must not restate a fact
  another file owns, only point at the owner. The count is the narrow case.
  `hyprtoolkit.conf` carried the wide one twice. A line number is a third case worth
  naming in the same breath, because it is a coordinate rather than a fact: a citation of
  `README.md:161` went stale twice inside one session as the file grew, and both times
  nothing failed. Cite the sentence, not where it currently sits.
  *Difficulty: trivial. Priority: medium, because it is lost silently at deletion.*

- **`THEMING.md` carries open work eight lines after saying this file owns it.** Delete its
  "Not covered yet" section, whose three items are verbatim from here. One bullet is left
  of the second half: the two radii, which still opens by restating `RICE-GUIDE.md`. Cut
  that sentence and keep the mechanism clause after it, which is this document's actual
  subject and exists only here. The role model and bright green bullets were the other
  two and are done, rewritten to the mechanism half while the decisions behind them were
  being settled. Named rather than numbered on purpose, and the reason keeps growing: one
  bullet was inserted after this entry was written, the ordinals were already off by one
  before that, and an `alert.neutral` bullet has since made a second.
  Three must survive whole: the relaxed accent budget for fetches, "Rollback is git, not a
  directory", and yazi's icon table, which is a decision this file now owns.
  *Difficulty: trivial. Priority: medium.*

- **Decide whether `minimal/` survives its own rule.** `THEMING.md`'s "Rollback is git, not
  a directory" bullet settles "Do not reintroduce a legacy directory", and
  `.config/fastfetch/minimal/` is five files whose own header calls them frozen snapshots
  "NOT kept in sync". The presets are a recorded keep, so the two statements now disagree
  and one has to move: either `minimal/` is the documented exception, or it is the thing
  the rule was written about.
  *Difficulty: trivial, and it is a decision rather than work. Priority: low.*

- **`AESTHETIC-DIRECTION.md` states photography direction that two other documents also
  state**, for a repository that has no photography; `RICE-GUIDE.md` already carries the
  wallpaper rules standalone. Its temperature map overlaps `DESIGN-SYSTEM.md`'s but the
  two disagree on row count and wording, so reconcile before deleting either, and decide
  the map's home only once `DESIGN-SYSTEM.md`'s is decided. Untouchable: the material
  references, "The right temperature of darkness", "What the system is not" and the note
  on coherence over time.
  *Difficulty: low. Priority: low.*

## The reader deciding whether to install

`README.md` and `SETUP.md`, read by someone who has not cloned anything yet, plus the
one file that leaves the repository at publication.

- **The README does not answer the reader who is deciding whether to install.** Six gaps
  from the same review, none of them worth a section on their own and all of them cheap.
  There is no statement of what the repository assumes beyond Arch and Wayland: nothing
  about Nvidia, nothing about laptop against desktop, while the install block says the
  bar carries laptop-only modules, so hardware evidently matters. There is no order of
  magnitude for what will be installed, so the rehearsal means reading sixty lines cold. The
  section on taking only part of it does not say which file inside a terminal's directory
  carries the colours, so the reader lists the directory to find `voidashi-colors.conf`.
  It also does not say whether `generate_theme.py` reaches a config that was copied by
  hand rather than symlinked, which is the first thing that reader wants after copying
  one. The three badges restate the first sentence and the last section. And the
  repository layout block sits above the reader's decision while answering a question
  they only have afterwards, which is why it was skipped outright.
  *Difficulty: trivial each. Priority: medium, and they are worth doing in one pass
  rather than one at a time.*

- **`CLAUDE.md` is deleted at publication.** `.claude/` is already out: it is untracked and
  ignored, and the checks it held are in `scripts/verify.sh`, which every clone gets. Only
  the root file is left. Before deleting it, run both checks, because the first alone was
  trusted once and was not enough:

  ```bash
  # 1. no repo knowledge left in the file itself
  grep -icE "kded6|8-digit hex|process cwd|swaylock-effects" CLAUDE.md   # expect 0
  # 2. nothing anywhere points at it. Code counts, not just docs.
  grep -rn "CLAUDE\.md" --exclude-dir=.git --exclude-dir=.claude .
  ```

  The second exists because the first was run with `--include="*.md"` and reported clean
  while eight references sat in six config and script files. What it may legitimately
  return is prose about the file rather than a use of it: `CLAUDE.md`'s own title line,
  this entry, "`CLAUDE.md` holds one rule that exists nowhere else", and the mention in
  `TURNING-POINTS.md` of where the rules came from. Anything else is a real reference to
  deal with first. Note the "Never write a count that a config file owns" rule still has no
  home under `docs/`, which is that entry.
  *Difficulty: low. Priority: medium, and it blocks nothing until publication.*

- **`wallpapers/` holds two files of one image.** `Topography.png` and `Topography.jpg`
  are the same image at the same size, mean absolute difference 0.78/255, and both match
  the picker's glob, so a fresh clone randomises between two copies of one wallpaper while
  the README's repository layout promises "one sample image". Deleting the 1.1MB PNG makes
  the sentence true with no edit.
  *Difficulty: trivial. Priority: low.*

- **The greetd section of `SETUP.md` explains greetd's own documentation.** The stock
  config, the flag
  meanings and `systemctl enable` are greetd's README and `tuigreet --help`. Three things
  are not: the `systemctl cat` verification, the `--sessions`/`--cmd` values tuned to this
  repository, and the "enable, not `enable --now`" footgun. Cut the per-flag prose only,
  and carefully, since shortening an untested procedure is how a claim of having tried it
  gets introduced by accident.
  *Difficulty: trivial. Priority: low.*

## Waiting on the world

None of these finishes at this keyboard today: they want a second machine, images, an
icon set, or a look at a running screen. The screenshots are the highest-priority entry in
the file and still belong here, because they are the last thing to do rather than the next.
Photographing a desktop that is still being edited is work done twice, so they wait until
the groups above have stopped changing what the desktop looks like.

- **The screenshots in the README predate the current theme.** Committed April 2025, they
  show the Kanagawa desktop this repo no longer contains. They stay until replaced, since
  a stale screenshot beats none.
  *Difficulty: low, blocked on taking new ones. Priority: high, because it is the first
  thing a visitor sees.*

- **The greetd path has never been run.** It is documented in `SETUP.md` step 6 and
  declared in `packages.conf`, but this machine reaches its desktop through `plasmalogin`,
  so nothing has exercised the config or the unit. Verified and worth not re-doing: both
  packages exist in `extra`, the config format and tuigreet flags come from upstream's own
  README, and `/usr/share/wayland-sessions/` already holds `hyprland.desktop` and
  `sway.desktop`. Unverified is the whole path end to end. A spare machine or a VM is the
  honest test, and until then `SETUP.md` must not gain a sentence claiming it was tried.
  *Difficulty: low, blocked on a second machine. Priority: medium.*

- **The apt and dnf names are written and have never been installed.** `[apt]` and
  `[dnf]` in `packages.conf` now carry the names that differ, and where a package
  exists the name is right by construction: each one was read out of the Debian trixie
  main index or the Fedora 43 metadata before it was written, and each is a name the
  key itself is not. Why that is not the same as working: an index says a package
  exists, not that installing it succeeds, that it pulls what the configs expect, or
  that `add_repos` does the right thing, and that last one has never executed on any
  distribution. The check is one run of
  `./scripts/install-packages.sh install --dry-run` and then a real `install` on a
  machine with those repositories. Recorded so the next reader does not redo it: the
  absences are listed per section in `packages.conf` and are packaging rather than
  configuration, so finding that Hyprland fails to install under apt is the documented
  outcome and not a bug to chase. Until such a machine exists, no document here may say
  the branches were tried.
  *Difficulty: low, blocked on a Debian or Fedora machine. Priority: medium.*

- **Wallpaper curation** is the largest remaining visual gap. Images chosen against the
  Wallpaper section of [`design/RICE-GUIDE.md`](design/RICE-GUIDE.md): material,
  desaturated, dark, at or below `void-00` in perceived lightness.
  *Difficulty: medium, blocked on sourcing images. Priority: medium.*

- **Bring the greeter onto the palette, by hand.** `tuigreet` takes a `--theme` flag in
  `component=color` form, which is why it was chosen over the alternatives, and today it
  is declared and documented unthemed. This repository will not generate that file:
  greetd's config is root-owned and outside `$HOME`, so `generate_theme.py` has nowhere to
  write and `check_palette.py` nothing to check, and that stays true for the reason in
  [`TURNING-POINTS.md`](TURNING-POINTS.md). What is owed is smaller and is a task for the
  person, not the scripts: derive the theme string from `palette.json` once, apply it, and
  put it in `SETUP.md` for a reader to paste. It is the one surface that would then drift
  off-palette with no validator noticing, so the string wants a comment saying where it
  came from. Wait until the greetd path has actually been booted; theming a path nobody
  has reached is the wrong order.
  *Difficulty: low. Priority: low, and it is the first surface a visitor sees, which
  argues it up once greetd is in use.*

- **Half of hyprlauncher has now been seen on a screen, and the other half has not.**
  `programs.lua` still runs wofi and the hyprlauncher line stays commented, but the
  launcher was started against this repository's config and its layer captured with `grim`
  while converting `hyprtoolkit.conf`. Settled by that: the surface is `void-20`, measured
  at 87.9% of the window against `181818` for the toolkit's own default, and the corners
  are square, which confirms the radius entry under "The two compositors" is a real defect
  and not a paper one. Not settled: the input field one step lighter, the selected entry
  Ice, and the identity mark Bordeaux rather than a second selection colour, because the
  finder listed nothing under a throwaway `$HOME` and none of the three was on screen.
  Anyone repeating this wants `hyprctl layers` rather than `hyprctl clients`, and a wait
  before the capture, both for the reason in `MAINTENANCE.md`.
  *Difficulty: trivial, blocked on someone switching the launcher and looking at a
  populated list. Priority: low, since nothing runs it today.*

- **Dolphin's icons are still `breeze-dark`**, so folders come out blue against a Voidashi
  window. Every alternative installed here is worse aligned, so this waits on an icon set
  being chosen, which is an asset decision.
  *Difficulty: low once a set is chosen. Priority: low.*

- **Power profiles, on the machine rather than in the repo.** Idle handling exists;
  switching a CPU governor or a platform profile does not. `power-profiles-daemon` is the
  usual answer and it needs `systemctl enable`, a system service that `backup-configs.sh`
  will not manage, again for the reason in `TURNING-POINTS.md`. So this is a one-off to do
  by hand, plus a line in `SETUP.md` telling a reader to do the same if it turns out to be
  worth it. `supergfxctl` is already declared here, which suggests the graphics half was
  once considered.
  *Difficulty: low. Priority: low.*

## While you are already in the file

Never a session of their own. The cost of each is opening the file, so they are paid by
whatever task opens it for another reason.

- **Many comments under `.config/hypr/` are in Portuguese** while the rest of the tree is
  English. Translate on touch, which is how the two in `autostart.lua` that the
  `~/.local/bin` work touched came across: the note on why absolute paths are used, and
  the wallpaper order above the swaybg line. The rest of that file is still Portuguese,
  including the `kill mako` note and the one on why hypridle runs under `systemd-cat`,
  both of which are worth reading. This is a translation and not a deletion, so it should
  not be batched with cuts.
  *Difficulty: trivial per file. Priority: low.*

- **Double hyphens standing in for a dash are not finished.** They are out of the shell
  scripts and remain in comments throughout `.config/`, including the stylesheets, the
  waybar and swaync JSON, `hyprtoolkit.conf`, several Lua comment bodies and
  `palette.json`. Clean each when something else takes you into the file. No count on
  purpose: `--` is Lua's comment marker and the prefix of every long flag, so a naive
  search returns hundreds of legitimate lines. The pattern that finds them is two hyphens
  with a space on both sides, `[[:alnum:],)] -- [[:alnum:]]`, and even that needs reading;
  `set -- "$@"` is real syntax and stays. A blanket substitution does not work: an em dash
  between two independent clauses wants a semicolon, one introducing an explanation wants
  a colon, one around a parenthetical wants parentheses, and some sentences want
  rewording. Reread the changed lines, which caught a broken sentence in two of three
  passes.
  *Difficulty: trivial per file. Priority: low.*

## Parked, and what was ruled out

Still open, but stopped. What matters in each is the list of eliminations, which is what
stops the next session repeating the work.

- **Workspace buttons in the bar do not respond to clicks**, and it is not this
  configuration. A full bisect ruled out everything on our side. Established:

  - Not the stylesheet. It fails identically with `/etc/xdg/waybar/style.css`.
  - Not the layer. It fails on both `bottom` and `top`.
  - Not `persistent-workspaces`. It fails with the legacy `{"1": [], ...}` form and with
    the documented `{"*": 5}` form.
  - Not a missing handler. Probes on `on-click`, `on-click-right`, `on-click-middle` and
    `on-scroll-up` running `notify-send` never fired once.
  - Not the bar's input in general. `clock` toggles, `custom/power` opens the menu, and
    hovering a workspace button highlights it, so the widget receives motion events.
  - Nothing reaches Hyprland either: with `-l debug` a click produces no dispatch line and
    no `workspace>>` event, while a keyboard switch produces both.

  So in waybar 0.15.0 those buttons take motion events and no button events at all. Next
  avenues by cost: check upstream issues for this version, try a different build, or
  replace the module with a `custom` one that renders and dispatches workspaces itself,
  which would cost the live updates. Three genuine config defects were fixed along the way
  and are worth keeping regardless: `layer` is `top`, `persistent-workspaces` uses the
  documented form, and a `disable-scroll` belonging to `sway/workspaces` was removed.
  *Difficulty: high, now that the cheap explanations are gone. Priority: medium, since
  keyboard switching works and this is a convenience.*
