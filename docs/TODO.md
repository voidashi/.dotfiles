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

One item, chosen for the next session rather than by rating. Everything rated `high` is in
"Waiting on the world" and cannot start today.

1. **`check_palette.py` should walk `git ls-files` rather than the filesystem.** The entry
   is under "The generator and its checks". It is worth doing next because it removes a
   class of edit rather than an instance, and because the group above it, "Configs that
   still paste hex", is now closed: every file the survey found a route for reads its
   colour instead of pasting it, and the two it found no route for are settled in
   [`TURNING-POINTS.md`](TURNING-POINTS.md).

## The two management scripts

`backup-configs.sh` and `install-packages.sh`, the two `.conf` files they read, and
`README.md`, `SETUP.md` and `MAINTENANCE.md`, which all print their vocabulary. More than
one session's work, and the order at the top is not arbitrary: the KDE opt-out is cheap
once `install` takes paths and awkward before.

- **Let `install` take paths, the way the package installer already does.**
  `backup-configs.sh install` is still every path in `config_files.conf` or nothing:
  `main()` dispatches on `$1` alone and `install_dotfiles` takes no argument. The
  asymmetry is the argument for fixing it, since `install-packages.sh` gained a
  `[PACKAGE...]` filter in `4a81c1b`, in `apply_package_filter()`, so a reader learns one
  vocabulary from one script and finds it missing on the other. `install_dotfiles`,
  `check_dotfiles` and `uninstall_dotfiles` are each a loop over `load_dotfiles`, so
  filtering by positional arguments is roughly ten lines and needs no config format
  change. `add_dotfile` already takes one path. The README no longer overpromises here:
  "Taking only part of it" states the all-or-nothing plainly and sends the reader to
  copy by hand, so this is now a convenience rather than a correction.
  *Difficulty: low. Priority: medium, and it is the cheapest way for a stranger to try
  this without committing to all of it.*

- **KDE theming is not optional, and it lands on a session the reader did not offer.**
  `config_files.conf` links `~/.config/kdeglobals`, `~/.config/kcminputrc` and
  `~/.local/share/color-schemes/Voidashi.colors`, which is where Plasma applications read
  their palette and their cursor, so installing on a machine that already runs KDE
  rethemes the desktop the reader meant to keep. A reviewer reading only the README
  named this as the single reason not to install on a working laptop, and they were right
  before the README warned about it. The warning is now in the install block, which fixes
  the surprise and not the situation. Options, in rough order of cost: let
  `backup-configs.sh install` take paths, which is the first entry of this group and
  makes every subset possible rather than this one; a documented "everything except
  the Qt/KDE paths" invocation; or splitting the Qt/KDE entries into their own section
  of `config_files.conf` so they can be skipped by name. Isolating it to the Hyprland and
  Sway sessions is the option that sounds best and does not exist: `kdeglobals` is read
  per user, not per session.
  *Difficulty: low once `install` takes paths. Priority: medium, and it is the one
  finding that changed a reviewer's answer from yes to no.*

- **The two management scripts are two CLIs for one job.** The rehearsal is `preview`, a
  subcommand, on one and `--dry-run`, a flag, on the other, and the README prints both in
  one code block. Four flags exist on one and not the other for no reason arising from its
  job. Pick one vocabulary. Whichever loses, `README.md`, `SETUP.md` steps 1 to 5 and
  `MAINTENANCE.md` all name the old one, so this is four documents as well as two scripts.
  *Difficulty: low. Priority: medium.*

- **The clone path is load-bearing in seven lines, and it does not have to be.** Cloning
  anywhere but `~/.dotfiles` silently breaks the wallpaper, the clipboard picker, the
  bar's power button and Neovim's dashboard. Ruled out already, with the incident recorded
  in the `autostart.lua` comment on absolute paths: relative paths, because they depended
  on the cwd Hyprland was started with and the bar did not come up depending on how you
  logged in.
  The seven lines are three different problems. Five are script calls
  (`clipboard-picker.sh` in both compositors, `power-menu.sh` in the bar,
  `select-random-wallpaper.sh` in both), one is a data directory
  (`$HOME/.dotfiles/wallpapers` as the picker's last fallback), and one is Neovim's
  dashboard opening the repo as a project, which names the repo by definition and should
  probably stay. Two mechanisms, and the choice is the work. A symlink farm, where
  `backup-configs.sh install` links the `scripts/wm/` helpers into `~/.local/bin` from
  whatever root it is actually running in, fixes the five script calls and works whatever
  starts the session. A session variable in the already-tracked
  `~/.config/environment.d/50-voidashi.conf` reaches all seven and turns the edit into one
  line in one file, but `environment.d` is read by the systemd user session, and this
  repo documents reaching the desktop by typing `Hyprland` at a console, which is exactly
  where it may not arrive.
  *Difficulty: low either way, and the decision is most of it. Priority: medium.*

- **`[hooks]` has no users and a repair plan.** Zero entries, one commented example, and
  `run_hooks()` is fifteen lines of awk-inside-bash carrying three known MEDIUM defects: a
  hook command containing `=` is truncated at the first one; a hook key is interpolated
  into a regex rather than compared literally, so `pipesXsh` fires for `pipes.sh`; and
  `add_repos` discards `update_pkg_db`'s status. The honest fix was always to replace that
  awk with a bash read loop. Deleting the feature closes all three instead.
  *Difficulty: trivial to delete, low to rewrite. Priority: medium, because work is
  scheduled on something nobody uses.*

- **The apt and dnf machinery has never run, and could not work as configured.** Fourteen
  non-comment lines mention apt or dnf, in the low thirties counting whole `case` branches
  and the `repos` dispatch. The dispatch itself is sound. Measured with
  `DEFAULT_PACKAGE_MANAGER=apt ./scripts/install-packages.sh preview`, which selects the
  apt branch and lists every package for it. What is not sound is the data: `[apt]` and
  `[dnf]` in `packages.conf` are empty, so all the names live in `[common]` and are Arch
  names. On Debian this resolves to `apt-get install hyprland`, `apt-get install paru`.
  So the choice is to populate the two sections or to delete the branches, and it is not
  a question of testing what is there. One cost before touching it: `SETUP.md` still tells
  a reader "the package installer also handles apt and dnf", so this is a documentation
  edit too. The
  README no longer does, since "cross-distro package installer" is gone from the
  repository layout. And `install_all()` reaches
  `update_pkg_db()` only through `add_repos()`, so deleting that function without rewiring
  drops `pacman -Syy` from every Arch install. The Microsoft repository key in the apt
  branch serves `code`, which is declared in `packages.conf`, so it is apt-only
  machinery rather than an orphan and stands or falls with the branch.
  *Difficulty: low. Priority: medium.*

- **Packages are declared for programs nothing here launches.** `dunst`, `hyprpaper`,
  `hyprlauncher` and `catnap` all have configs that are deliberate keeps, but a reference
  config does not need its program on a stranger's machine, and the question was only ever
  asked of `dunst`. `pfetch-rs` is the same shape with no config at all. `ranger`,
  `supergfxctl`, `cava`, `zathura`, `cmatrix` and `hyprpicker` have no config, launch or
  bind either, though `hyprpicker` is an optional dependency of `hyprshot`. If `pfetch-rs`
  goes, its comment about declaring a bare AUR name letting the helper pick a different
  provider applies to every AUR entry here and belongs in `MAINTENANCE.md`.
  *Difficulty: trivial. Priority: low.*

- **`config_files.conf` carries example blocks.** "Template Examples" is filler for a
  format that is one path per line. "Optional Configurations" is not: it names
  `~/.ssh/config`, `~/.ssh/known_hosts` and `~/.local/share/applications/`, and a
  commented `~/.ssh` is a visible decision not to track secrets by default.
  *Difficulty: trivial. Priority: low.*

## The generator and its checks

`scripts/theme/` and `scripts/verify.sh`: what the checkers look at, and what is
emitted today without anything looking at it.

- **`check_palette.py` should walk `git ls-files` rather than the filesystem.** Its
  docstring promises "a colour in a tracked config" and it walks `REPO_ROOT.rglob("*")`,
  which is why `SKIP_PARTS` keeps growing entries that patch around what git already
  knows: `.git/`, and now `.claude/worktrees/`. Walking the index makes both unnecessary,
  makes the docstring true, and means the next ignored directory needs no edit here.
  Three entries stay, since `fish_variables`, `lazy-lock.json` and `palette.json` are
  tracked and are content exceptions rather than scope ones.
  *Difficulty: low, about ten lines. Priority: medium, and it removes a class of edit
  rather than an instance.*

- **`kdeglobals` never learns the scheme's name, and it is not clear that it should.**
  `kde_globals_merged` drops the `[General]` of the generated `.colors` file, on the stated
  grounds that it would collide with the `[General]` kdeglobals already has. That section
  carries `ColorScheme=Voidashi`, `Name=Voidashi` and `shadeSortColumn=true`, and the first
  two collide with nothing: kdeglobals holds only a stale KDE-written `ColorSchemeHash` and
  no `ColorScheme` at all. So the justification covers `shadeSortColumn` and not the other
  two. What is *not* established, and is the whole question, is whether any KDE component
  reads `ColorScheme` from kdeglobals rather than from the `.colors` file; an audit could
  not settle it from the installed binaries. Establish that before changing anything, since
  the colours themselves are demonstrably applied today and this may be a key nobody reads.
  *Difficulty: low to change, and the work is answering the question. Priority: low.*

- **Alacritty's generated file is the one terminal output nothing validates.** The other
  three are checked by their own programs in `scripts/verify.sh`, and alacritty is absent
  from it. Ruled out as the validator: `alacritty migrate --dry-run` accepts a config
  carrying `[colors.primary] bogus = "ffffff"` and exits 0, so it reports migration
  needs and not correctness. The file is covered against hand-edits by `check_sync` and
  against invented colours by drift, so what is unchecked is narrower than it sounds: that
  the key names and TOML shape are the ones alacritty actually reads, which today rests on
  inspection alone. A TOML parse plus a comparison against alacritty's documented key names
  is the likely substitute.
  *Difficulty: low. Priority: low.*

## Colour decisions the roles layer made visible

`roles.py` and [`design/RICE-GUIDE.md`](design/RICE-GUIDE.md). None of these is a bug
and none has a check that would catch it, which is why they are questions rather than
work. Two of them want eyes on a screen rather than a refactor.

- **Three role decisions the layer made visible and did not settle.** `roles.py` names
  each of them now, so each is legible in one place. None is a bug and none has a check
  that would catch it, which is why they are here rather than in the code.
  - **Ice is spent at three steps and only two are written down.** `ice-600` is the
    selection surface and `ice-300` the line form for rings, links and active text, both
    in `RICE-GUIDE.md`. `ice-400` is Qt's focus decoration and is documented nowhere: the
    only justification on record was the name of a local variable, `ice_focus`. It has a
    second reader now: hyprtoolkit's `accent` is the same step, which was pasted as
    `ice-400` before the conversion and reads the role after it. Two toolkits on a step is
    an argument for the step existing, not for its value. Decide whether that focus
    decoration belongs between the two or should join one of them. It changes what Qt
    applications and the launcher look like, so it wants eyes on a screen rather than a
    refactor.
  - **Bright green does not follow the rule that placed bright red and bright yellow.**
    `RICE-GUIDE.md` justifies slots 9 and 11 taking alert tones, because in a terminal
    bright red means *error* and bright yellow means *warning*. By that argument bright
    green means *success* and should take `alert.good.fg`; it takes `moss-300` instead,
    which the guide's own ANSI table states without explaining. Either the argument
    extends and the slot moves, or it has a boundary and the guide should say where.
  - **`alert.neutral` is the Ice family without saying so.** Its `bg` and `border` are
    `ice-deep` and `ice-800` exactly, while its `fg` is a step of nothing; the other three
    alert families have a `bg` and `border` of their own. Turning the pair into references
    would *create* a coupling that today may be coincidence, so the question is whether
    the coincidence was intent. Worth knowing while deciding: the orphan warning cannot
    see this pair, because it skips everything under `alert.`, and moving `scales.ice.deep`
    leaves four generated lines behind with nothing reported.
  *Difficulty: trivial each, and they are decisions rather than work. Priority: medium,
  and the first is the only one of the three that shows on a screen.*

- **`focus-ring` is a GTK variable nobody reads.** `gen_gtk_css` emits
  `@define-color focus-ring` into the shared partial and into wofi's block, and no
  stylesheet uses `@focus-ring`: measured, the only two hits in the tree are the two
  definitions. It follows the Ice ramp correctly now that it is a role, so nothing renders
  wrong; what is open is what it should be. Emit it as `@define-color focus-ring @ice-300`,
  which is GTK's own named-colour reference, renders identically and puts the dependency in
  the output where a reader sees it. Delete it, which is cheapest, and means the next
  stylesheet wanting a focus ring pastes a hex, which is the thing this pipeline exists to
  prevent. Or leave it as an export for a consumer that does not exist yet. One thing to
  check before the first option: no stylesheet here uses the `@name` reference form at all
  today, so it would be the first, and it has to be tried on GTK3 as well as GTK4, since
  waybar and wlogout are GTK3 while swaync is GTK4.
  *Difficulty: trivial. Priority: low, since nothing renders wrong either way.*

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
  "Not covered yet" section, whose three items are verbatim from here. Its first three
  "Settled decisions"
  bullets restate `RICE-GUIDE.md` in their opening sentences; cut those sentences and keep
  the mechanism clause after each, which is this document's actual subject and exists only
  here. Bullets 4 and 5 must survive whole: the relaxed accent budget for fetches, and
  "Rollback is git, not a directory".
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
  magnitude for what will be installed, so `preview` means reading sixty lines cold. The
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
  English, including the `autostart.lua` note on why absolute paths are used, which is
  worth reading. Translate on touch. This is a
  translation and not a deletion, so it should not be batched with cuts.
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
