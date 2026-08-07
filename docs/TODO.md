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

"Picked by hand, in this order", immediately below, and its first entry before anything
else in this file: one login confirms whether a fix that touched the wallpaper, a
keybinding and the bar landed, and nothing else here can proceed on the assumption that
it did.

After that group, "Four more documents that answer the same question twice", then "The
reader deciding whether to install". Both finish at this keyboard, as does "While you
are already in the file", which stays where it is because those entries are meant to be
paid by a session that opened the file for another reason.

Before reopening anything about the two compositors, read
[`TURNING-POINTS.md`](TURNING-POINTS.md): sway follows Hyprland, one way, and four
things are recorded there as deliberately absent from sway.


## Picked by hand, in this order

Every other group here shares a file or a question, which is what makes a group worth
sitting down to. This one does not: it is what the repository's owner asked for next, and
its entries touch the bar, the palette, a package list, the greeter and the session's
PATH. Ordered by priority like the others, and a session taking it will open unrelated
files. That is the cost of the group existing, and it exists because the order came from
outside the file.

Each entry below was measured before it was written, and three of them do not say what
they were first described as saying. Where that happened it is marked, because the
description is what someone will remember.

- **Confirm the helper paths work in a real session.** The five call sites that reach
  `scripts/wm/` helpers were changed from a bare name to `$HOME/.local/bin/<name>`, which
  fixes a wallpaper, a clipboard bind and the bar's power button that a greetd session
  left dead. Nothing has confirmed it on a screen: the change was verified only by
  running the command under the PATH greetd hands the session, and a session cannot be
  checked from outside itself. Log out and back in, then look for three things: the
  wallpaper appears, `$mod+Shift+V` opens the picker, and the bar's power button opens
  the menu. Why it broke and what was ruled out is in
  [`TURNING-POINTS.md`](TURNING-POINTS.md), not here.
  *Difficulty: trivial, it is one look. Priority: high, because until it is looked at
  nobody knows whether the fix landed.*

- **Sway under this greeter has no session environment at all.** Found while fixing the
  entry above and separate from it. `environment.d/50-voidashi.conf` is Sway's only
  source for session variables, because `man 5 sway` has no `env` directive and an `exec`
  cannot change its parent's environment, and that file does not reach a greetd-launched
  session: `XCURSOR_SIZE`, `HYPRCURSOR_SIZE` and `QT_QPA_PLATFORMTHEME` are all set in it
  and all three are unset in the compositor's own inherited environment. Hyprland does not
  care, because `conf/env_vars.lua` sets them again for everything it launches. Sway has
  no equivalent, so under greetd it would come up with `QT_QPA_PLATFORMTHEME` unset, which
  is the exact failure [`MAINTENANCE.md`](MAINTENANCE.md) records as having already
  happened once: Qt applications light against a dark desktop. Unmeasured, because nobody
  has booted Sway from this greeter, and the honest test is doing so and opening a Qt
  application. If it reproduces, the options are a wrapper session that exports before
  exec'ing sway, or a `.desktop` of this repository's own, and both are new mechanism for
  a compositor nothing runs daily.
  *Difficulty: low to confirm, and the fix is a design question. Priority: medium, and it
  is the second thing this greeter exposed rather than caused.*

- **The bar shows workspaces 6 to 10 with nothing in them.** `common.jsonc`'s
  `hyprland/workspaces` sets `all-outputs: true` and `persistent-workspaces: {"*": 5}`.
  The `*` is not "five workspaces" but "five per output", so a second monitor
  manufactures a second run of five and the bar carries ten buttons where at most a few
  hold windows. Both halves were deliberate and are recorded: the `{"*": 5}` form
  replaced a legacy one during the click bisect in "Parked" below, and it is the form
  waybar documents. So the fix is choosing what the pair should be rather than correcting
  a mistake. Naming the primary output explicitly instead of `*` keeps five buttons on
  one monitor and none manufactured on the other, at the cost of writing an output name
  into a config that is meant to travel. Dropping `all-outputs` scopes each bar to its
  own monitor, which is a different desktop rather than a smaller one. Decide which,
  because both are defensible and only one survives a machine with a different monitor
  layout.
  *Difficulty: trivial to change, and the decision is the work. Priority: medium, since
  it is wrong on screen every day.*

- **Bring the greeter onto the palette.** This was waiting on greetd actually running and
  now is not. `tuigreet` takes `--theme` in `component=color` form, and the string has to
  be derived from `palette.json` by hand and pasted into `/etc/greetd/config.toml`, which
  this repository will not generate for the reason in
  [`TURNING-POINTS.md`](TURNING-POINTS.md): the file is root-owned and outside `$HOME`, so
  `generate_theme.py` has nowhere to write and `check_palette.py` nothing to check. It is
  the one surface that will drift off-palette with no validator noticing, so the string
  wants a comment saying which palette entries it came from, and `SETUP.md` wants it for a
  reader to paste.
  *Difficulty: low. Priority: medium now that it is the first surface seen on every boot.*

- **Verdigris is on the lightness ladder and off the chroma curve.** This was written down
  as "check whether verdigris follows OKLCH like the others", and half of it is already
  answered. Measured, converting `palette.json` to OKLCH: verdigris 300/400/500 sit at
  L\* 68.94, 60.92, 52.96, against ice at 68.99, 60.94, 52.97, so it tracks the eight-point
  ladder every other family uses to two decimal places, and its hue drifts 0.9 degrees
  across the three, which is tighter than ice. What it does not share is chroma. Verdigris
  runs 0.070, 0.075, 0.075 where bordeaux, ice, ash, moss and bronze all run roughly 0.080
  to 0.100 at the same steps, and every one of them peaks at 400 and comes back down while
  verdigris is flat. So it is a family built to the right lightness and a visibly weaker
  saturation. Whether that is the defect or the point is the actual question, and
  `palette.json`'s own note argues for the point: verdigris is a terminal-only extension
  filling the cyan ANSI slots, never a UI accent, and a colour that must not compete for
  attention has a reason to sit under the accent families. Settle it as a decision either
  way, because a family that is deliberately off the curve should say so where the curve
  is defined.
  *Difficulty: low to change, and it is a judgement rather than a computation. Priority:
  medium, since an unexplained outlier in the palette invites someone to "fix" it.*

- **OKLCH is used everywhere and explained nowhere at the depth CIELAB is.** This was asked
  for as documenting OKLCH "in that same brightness script", and there is no brightness
  script: the stepping lives in the two `brightnessctl -e3` binds, and the CIE L\* argument
  behind them is a paragraph in [`MAINTENANCE.md`](MAINTENANCE.md), with a measured curve,
  the numbers from this machine's panel, and the two assumptions it rests on named. That
  paragraph is the standard to match. OKLCH appears in `design/DESIGN-SYSTEM.md` and
  `design/RICE-GUIDE.md` as the space the scales are built in, and the eight-point ladder
  in the verdigris entry above is visible in the numbers with nothing written down that
  says it is eight, why eight, or what happens at the ends where the steps compress to
  five. Write that where the palette is defined rather than where a compositor is
  configured, and include the measurement, since the whole point of the CIELAB paragraph
  is that it shows its working.
  *Difficulty: medium, because it is the writing rather than the finding. Priority: medium,
  and it is what makes the verdigris decision above arguable instead of a matter of taste.*

- **`vlc` is named in `packages.conf` and not declared by it.** The Qt theming comment
  names VLC as one of the applications the platform theme reaches, so a reader would fairly
  conclude the repository installs it. Nothing does: there is no media player of any kind
  in the list. Either add it or stop naming it, and if it goes in, the `[apt]` and `[dnf]`
  sections take the same name, which is one of the few where all three agree.
  *Difficulty: trivial. Priority: low, and it is a one-line entry in a list built for
  exactly this.*

- **The brightness exponent could be 2.4 instead of 3, and it is a native flag.** Asked as
  whether this needs a script, and it does not. Measured on this machine, reading the
  percentage back for one raw value at three exponents: `-e2` gives 66%, `-e2.4` gives 70%,
  `-e3` gives 75%, each matching `(raw/max)^(1/e)` exactly, so `brightnessctl` parses a
  fractional exponent and the change is one character in two files. What it decides is
  which curve the keys walk. 3 is the cube root in CIE L\*, which
  [`MAINTENANCE.md`](MAINTENANCE.md) derives and measures; 2.4 is the sRGB transfer
  exponent, which is a display convention rather than a perceptual one. So this is a
  smaller step at the dark end against a curve that matches how the panel is driven. Try
  it before writing it down, and keep the current reasoning in the file rather than
  replacing it, since the CIELAB paragraph is what makes either choice legible. Both
  compositors carry these binds and both change together.
  *Difficulty: trivial. Priority: low, since the current curve was measured and works.*

## Four more documents that answer the same question twice

The group of this name was closed, and then a reviewer reading the documents cold found
four more instances of the same failure. They are listed separately rather than reopening
that group, because the four it held are settled and these are not the same four. None of
them was introduced by the work that closed it; they were simply never looked for.

- **Nothing owns the keybindings.** `docs/README.md` says every document answers exactly
  one question and lists eight questions. "What are the keys" is not among them, and the
  only answer in the repository is the table in the root `README.md`. That table is now
  correct for both compositors, since sway's binds were converged onto Hyprland's, so what
  is missing is not the content but the index entry pointing at it. Decide whether the
  root `README.md` is a legitimate owner of a question, given that it is written for a
  reader deciding whether to install rather than for one already using it.
  *Difficulty: low, and the real work is the decision. Priority: medium, because it is
  the question a user has most often.*

- **`THEMING.md` describes a check `check_palette.py` does not perform.** It says the
  warning fires "when a role literal holds a hex no scale or alert tone holds". The script
  says an `ansi16` slot, in its own header and in the function's docstring, and that
  docstring records that the roles case was deliberately removed because a role names a
  token and cannot hold a retired value. `MAINTENANCE.md` and `SETUP.md` both say `ansi16`
  correctly, so `THEMING.md` is the sole outlier. It is also duplication: that whole
  passage restates `check_palette.py`'s behaviour, which `MAINTENANCE.md` owns under
  "Validating a change". Cut it there and point, which fixes the error by removing it.
  *Difficulty: trivial. Priority: medium, since it is wrong rather than merely doubled.*

- **`MAINTENANCE.md` states the `ansi16` warning twice**, about forty lines apart, in the
  document that now opens with the rule against restating a fact another file owns. Its
  list of what `check_palette.py` fails on gives five conditions where the script's own
  header says three checks and a warning; the fifth is a load-time refusal in `roles.py`
  rather than a check. Reconcile against the script rather than against either paragraph.
  *Difficulty: trivial. Priority: low.*

- **Neither compositor's gaps come from the spacing scale the guide names.**
  `design/RICE-GUIDE.md` asks for window gaps that are even and drawn from 4, 8, 12, 16,
  24, and `CLAUDE.md` makes that document the authority for desktop work. Hyprland runs
  `gaps_in = 3`, `gaps_out = 10`; sway now runs `inner 6`, `outer 4`, which are the
  values that reproduce Hyprland's spacing, measured rather than derived. So 4 is the
  only one of the four on the scale and 3 is not even. Parity between the two
  compositors was chosen over the scale when sway was converged, deliberately and in one
  direction, but that only moved the conflict rather than settling it. Settling it means
  picking scale values for Hyprland first and letting sway follow, which is a visible
  change to the desktop and wants an eye on it rather than arithmetic.
  *Difficulty: low to change, and the judgement is whether the current spacing is
  actually wrong. Priority: low.*

- **A pointer in `THEMING.md` promises four explanations and the target holds two.** It
  says why "the last row is only four entries" is in `TURNING-POINTS.md`; the row names
  fastfetch, fish, `waybar/common.jsonc` and `nvim/theme/roles.lua`, and the entry it
  points at is about the two the survey found no route for. Nothing explains fish or
  `nvim/theme/roles.lua`. Either the pointer narrows to the two it can deliver, or the
  entry grows the other two.
  *Difficulty: trivial. Priority: low.*

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
  this entry, and the mention in `TURNING-POINTS.md` of where the rules came from.
  Anything else is a real reference to deal with first. The blocker this entry used to
  carry is gone: "Never write a count that a config file owns" was the one rule with no
  home under `docs/`, and it is now in `MAINTENANCE.md` as the narrow case of the wider
  rule about restating a fact another file owns. Nothing else in `CLAUDE.md` is unique to
  it, so the file can go whenever publication does.
  *Difficulty: low. Priority: medium, and it blocks nothing until publication.*

- **`wallpapers/` holds two files of one image.** `Topography.png` and `Topography.jpg`
  are the same image at the same size, mean absolute difference 0.78/255, and both match
  the picker's glob, so a fresh clone randomises between two copies of one wallpaper while
  the README's repository layout promises "one sample image". Deleting the 1.1MB PNG makes
  the sentence true with no edit.
  *Difficulty: trivial. Priority: low.*

- **The greetd section of `SETUP.md` explains greetd's own documentation.** The stock
  config, the flag meanings and `systemctl enable` are greetd's README and
  `tuigreet --help`. What is not, and must survive any cut, is now five things rather
  than the three this entry first listed, because running the procedure added two: the
  `systemctl cat` verification, the `--sessions` and `--cmd` values tuned to this
  repository, the "enable, not `enable --now`" footgun, the rule that `--cmd` takes what
  the session's `.desktop` file execs rather than the compositor's name, and disabling
  the previous display manager in the same sitting. Cut the per-flag prose only. The
  caution about shortening an untested procedure no longer applies, since it has been
  run, but the section is longer than it was and the two newest paragraphs are the ones
  that cost something to learn.
  *Difficulty: trivial. Priority: low.*

## Waiting on the world

None of these finishes at this keyboard today: they want a second machine, images, an
icon set, or a look at a running screen. The screenshots are the highest-priority entry
in the file and still belong here, because they are the last thing to do rather than the
next. Photographing a desktop that is still being edited is work done twice, so they wait
until the groups above have stopped changing what the desktop looks like.

That condition is nearly met. Nothing open above changes a Hyprland screenshot: the
groups above are documentation apart from deleting a duplicate wallpaper file, which
removes one of two copies of one image. Wallpaper curation is the one open entry that
would make a photograph stale.

- **The screenshots in the README predate the current theme.** Committed April 2025, they
  show the Kanagawa desktop this repo no longer contains. They stay until replaced, since
  a stale screenshot beats none.
  *Difficulty: low, blocked on taking new ones. Priority: high, because it is the first
  thing a visitor sees.*

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

- **Half of hyprlauncher has now been seen on a screen, and the other half has not.**
  `programs.lua` still runs wofi and the hyprlauncher line stays commented, but the
  launcher was started against this repository's config and its layer captured with `grim`
  while converting `hyprtoolkit.conf`. Settled by that: the surface is `void-20`, measured
  at 87.9% of the window against `181818` for the toolkit's own default, and the corners
  were square, which is what made the radius a real defect rather than a paper one. That
  half is now fixed: `hyprtoolkit.conf` sets both radii to 4, the value the guide gives a
  floating surface. Nothing has rendered it since, so the fix is read and not seen, and
  a capture of the layer is the check. Not settled: the input field one step lighter, the
  selected entry
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

Never a session of their own. The cost of each is paid by whatever task opens the file
for another reason. The exception is the first entry, which is one pass over one file and
sits here because nothing else will ever open that file.

- **Every link in `DESIGN-SYSTEM.md`'s table of contents is dead.** All seventeen of them.
  The links assume two spaces after the section number (`#1--operating-principles`) and
  the headings carry one (`## 1 Operating principles`), so every anchor misses. Found by a
  link checker written to verify a different change and pointed at the whole tree; it is
  not this repo's oldest defect, only its quietest, since a markdown anchor that does not
  resolve scrolls nowhere and reports nothing. Fix the links rather than the headings:
  seventeen link targets against seventeen headings is the same count, but a heading is
  quoted elsewhere and an anchor is not. Nothing under `scripts/` checks markdown, so this
  will not be caught again on its own.
  *Difficulty: trivial. Priority: low, since the document is optional reading by its own
  entry in `README.md`.*

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
