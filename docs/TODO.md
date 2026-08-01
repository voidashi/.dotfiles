# Open work

Everything here is something to do. Decisions already taken, including the decisions not
to do something, live in [`TURNING-POINTS.md`](TURNING-POINTS.md); what breaks if you
touch a thing is in [`MAINTENANCE.md`](MAINTENANCE.md); how the palette reaches each
application is in [`design/THEMING.md`](design/THEMING.md). If an entry below stops being
work, it moves to one of those rather than staying here as a record.

Each entry carries a **difficulty** and a **priority**, rated separately: difficulty is
how much work it is and how much can go wrong, priority is how much it costs to leave
alone. A one-line fix can be urgent and a rewrite optional. "Start here next" is ordered;
"Open work" is sorted by priority and nothing else.

## Start here next

One item. The two that stood here, the accent recipe and the Iosevka asset, both shipped
into `SETUP.md`, and writing the first one is what produced the third hole below.

1. **`check_palette.py` passes on colours it cannot see.** Three holes, every one of them
   found by measurement rather than by reading it, and a checker that passes on a colour
   nobody chose is worse than no checker. Two neighbouring defects are already fixed and
   are not part of this: the palette count now reads 78 rather than 82, which is why older
   notes quote the larger number, and a value that is not `#RRGGBB` is refused at load.

   - **Every colour format except `#RRGGBB` is outside the check.** The `rgb(...)` case
     was found first: an auditor replaced `rgb(498bb2)` with `rgb(ff00ff)` in
     `.config/hypr/hyprtoolkit.conf` and the checker returned `no colour outside the
     palette` and exit 0, because its pattern is `#[0-9a-fA-F]{6}` and `BARE_HEX_SCOPE`
     covers only `.config/swaylock/config`. Six `rgb(...)` colours live in that file,
     `accent_secondary` among them, which is the identity mark. Confirmed again while
     writing the accent recipe: a scratch swap left hyprtoolkit on the old accent and the
     checker said nothing.

     The hole is wider than that one form. Measured, with a positive control on the same
     run to prove the checker was not simply inert: `ff00ff` planted in
     `.config/waybar/style.css` was caught, while every one of these was not.
     Sentinels are written here without the leading `#`, or the drift check reads this
     document's examples as applied colour and reports them.

     | Format | Where it is used | Colours unchecked |
     |---|---|---|
     | bare hex, no `#` | `.config/fish/conf.d/voidashi-colorscheme.fish` | 15 |
     | `rgb(hexdigits)` | `hyprtoolkit.conf`, `hypr/conf/appearance.lua`, `decoration.lua` | 10 |
     | `rgb(decimal)` | `.config/swaync/style.css`, `.config/wlogout/style.css` | 11 |
     | `R,G,B` decimal | `.config/kdeglobals` | all of them |

     Six files with no colour reachable at all. Two things not to redo: swaylock's bare-hex
     coverage is complete, 29 colour lines and 29 matched, so the scope is right there and
     only there. And a quoted colour name is invisible while a decorated one is not, since
     `NAMED_RE` wants `^`, whitespace or `=` before the name: in `.config/starship.toml`,
     `style = 'red'` passes and `style = 'bold red'` is reported, separated by one space.
   - **A value duplicated inside `palette.json` shadows every stale copy of itself.**
     `ansi16` slot 1 is a second copy of `bordeaux.400`, so while it holds the old hex
     that hex is still a palette colour and no file carrying it can ever be reported.
     Measured: changing the `bordeaux` ramp alone and regenerating moved four files and
     left nineteen tracked files on the old accent, with the checker at exit 0 throughout.
     This is the general shape rather than one key: any role literal that repeats a scale
     value does it. There is no cheap complete fix, because drift asks whether a colour is
     in the palette and the real question is whether it is the right one for the role, so
     the roles-layer entry below is what removes the shape. What is cheap is a warning
     when a hex sits in `ansi16` and in no scale or alert tone, which is exactly the state
     that keeps a retired value alive. Measured before proposing it: that check returns
     nothing on the palette as it stands, and reports `ansi16` slot 1 the moment the
     `bordeaux` ramp moves without it. Do not make it fatal, since a deliberate hue swap
     puts the palette in that state on purpose.
   - **`check_sync` only sees the files written whole.** It iterates `generated_files()`,
     the ten files the generator writes, while the generator also writes
     `.config/wofi/style.css`, `.config/kdeglobals` and `.config/kcminputrc` by merging.
     Hand-edits to those three were made and the checker returned 0 for each. The merge
     cases are deliberate and documented in `generate_theme.py` beside the merge itself,
     so what is owed is either a partial comparison of the sections the generator owns, or
     a sentence saying they are unchecked on purpose.

     Drift partly compensates, and knowing where it stops decides how much is owed. In
     wofi's generated block an off-palette value is caught, `6aa3c8` reported at exit 1,
     while swapping one palette colour for another inside the same block, `ice-300` set to
     `ice-400`'s hex, passes both checks. The swap is the likelier hand-edit, so wofi is
     covered for the careless case and open for the plausible one. `kdeglobals` is open
     either way, since its `R,G,B` triplets match no pattern in the checker.

   `SETUP.md` now warns a reader about the first two in its accent recipe, which limits
   the damage and does not fix any of them.
   *Difficulty: low for the `rgb(...)` form and for the duplicate-value check, medium for
   the merged files. Priority: high.*

The other `high` entry, the stale screenshots, sits below rather than here because it is
blocked on someone taking new ones.

## Open work

Sorted by priority. Within a priority, by nothing.

- **The screenshots in the README predate the current theme.** Committed April 2025, they
  show the Kanagawa desktop this repo no longer contains. They stay until replaced, since
  a stale screenshot beats none.
  *Difficulty: low, blocked on taking new ones. Priority: high, because it is the first
  thing a visitor sees.*

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

- **KDE theming is not optional, and it lands on a session the reader did not offer.**
  `config_files.conf` links `~/.config/kdeglobals`, `~/.config/kcminputrc` and
  `~/.local/share/color-schemes/Voidashi.colors`, which is where Plasma applications read
  their palette and their cursor, so installing on a machine that already runs KDE
  rethemes the desktop the reader meant to keep. A reviewer reading only the README
  named this as the single reason not to install on a working laptop, and they were right
  before the README warned about it. The warning is now in the install block, which fixes
  the surprise and not the situation. Options, in rough order of cost: let
  `backup-configs.sh install` take paths, which has its own entry below and makes every
  subset possible rather than this one; a documented "everything except the Qt/KDE
  paths" invocation; or splitting the Qt/KDE entries into their own section of
  `config_files.conf` so they can be skipped by name. Isolating it to the Hyprland and
  Sway sessions is the option that sounds best and does not exist: `kdeglobals` is read
  per user, not per session.
  *Difficulty: low once `install` takes paths. Priority: medium, and it is the one
  finding that changed a reviewer's answer from yes to no.*

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

- **The greetd path has never been run.** It is documented in `SETUP.md` step 6 and
  declared in `packages.conf`, but this machine reaches its desktop through `plasmalogin`,
  so nothing has exercised the config or the unit. Verified and worth not re-doing: both
  packages exist in `extra`, the config format and tuigreet flags come from upstream's own
  README, and `/usr/share/wayland-sessions/` already holds `hyprland.desktop` and
  `sway.desktop`. Unverified is the whole path end to end. A spare machine or a VM is the
  honest test, and until then `SETUP.md` must not gain a sentence claiming it was tried.
  *Difficulty: low, blocked on a second machine. Priority: medium.*

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

- **`[hooks]` has no users and a repair plan.** Zero entries, one commented example, and
  `run_hooks()` is fifteen lines of awk-inside-bash carrying three known MEDIUM defects: a
  hook command containing `=` is truncated at the first one; a hook key is interpolated
  into a regex rather than compared literally, so `pipesXsh` fires for `pipes.sh`; and
  `add_repos` discards `update_pkg_db`'s status. The honest fix was always to replace that
  awk with a bash read loop. Deleting the feature closes all three instead.
  *Difficulty: trivial to delete, low to rewrite. Priority: medium, because work is
  scheduled on something nobody uses.*

- **`check_palette.py` should walk `git ls-files` rather than the filesystem.** Its
  docstring promises "a colour in a tracked config" and it walks `REPO_ROOT.rglob("*")`,
  which is why `SKIP_PARTS` keeps growing entries that patch around what git already
  knows: `.git/`, and now `.claude/worktrees/`. Walking the index makes both unnecessary,
  makes the docstring true, and means the next ignored directory needs no edit here.
  Three entries stay, since `fish_variables`, `lazy-lock.json` and `palette.json` are
  tracked and are content exceptions rather than scope ones.
  *Difficulty: low, about ten lines. Priority: medium, and it removes a class of edit
  rather than an instance.*

- **The two management scripts are two CLIs for one job.** The rehearsal is `preview`, a
  subcommand, on one and `--dry-run`, a flag, on the other, and the README prints both in
  one code block. Four flags exist on one and not the other for no reason arising from its
  job. Pick one vocabulary. Whichever loses, `README.md`, `SETUP.md` steps 1 to 5 and
  `MAINTENANCE.md` all name the old one, so this is four documents as well as two scripts.
  *Difficulty: low. Priority: medium.*

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

- **The two compositors describe every runtime service twice, and have diverged.** The
  autostart block in `autostart.lua` against the run of `exec` lines in `sway/config`; the
  idle schedule in two syntaxes with a comment asking future editors to keep them in step;
  three screenshot binds under Hyprland against one bare `grim` under Sway; different
  launcher keys. Sway also carries nine hand-pasted hex while Hyprland reads a generated
  `palette.lua`, so the two sit on opposite sides of this repo's most important seam. The
  cheap half is generating a Sway palette include, about fifteen lines in
  `generate_theme.py`, which moves nine literals off the drift surface. Dropping Sway is
  not on the table: `sway/config` carries four findings that could only come from booting
  it, including notifications that were dead under Sway with the config themed and in
  place. The standing cost is that anything mirrored into `sway/config` from a Hyprland
  session is checked by `sway --validate` and never run. The brightness curve and the
  clipboard wipe both went in that way: confirmed working under Hyprland, untried under
  Sway.
  *Difficulty: low for the include, high for the rest. Priority: medium.*

- **Rethink how the generator decides colour, and consider a roles layer.**
  `palette.json` holds raw ramps plus a few roles expressed as duplicated literals:
  `terminal.cursor` and `focus_ring` are semantic keys carrying a hex that also exists in a
  scale. Making that systematic would have a role point at a token by name rather than
  repeat its value. The Neovim theme already works this way in three layers.

  What an audit of the generator added, and it raises the priority of this rather than the
  difficulty. **The leak is not confined to the hand-written half.** Moving
  `scales.ice.300` alone and regenerating leaves the *generated* GTK stylesheet emitting
  `@define-color focus-ring #6aa3c7`, the retired value, because `gen_gtk_css` reads
  `focus_ring` as an independent literal; the four terminals keep their old cursor,
  background and selection for the same reason. So "change one hex and everything moves"
  is false inside the generator's own output, not only outside it, and that is the
  sharpest argument for doing this at all.

  Three things that make the work cheaper than it looks. `colour_keys()` in
  `generate_theme.py` already enumerates every place that must hold a colour in one
  function, which is the hook a resolver would use. `palette.json` is structurally sound
  today, so the conversion starts from a consistent state: every role literal still equals
  the scale value it was copied from, and every ramp is monotonic in relative luminance.
  And the checker's palette count is a free signal for the failure this fixes, since a
  value entering while the old one stays makes the count go *up*, which is exactly the
  retired-value-still-alive state; a real swap leaves it flat or smaller.

  One design inconsistency to settle in passing, since it is a role question: ANSI 9 and
  11 take `alert.critical.fg` and `alert.caution.fg`, while ANSI 10 takes `moss.300`
  rather than `alert.good.fg`.

  Three things to settle first. **ANSI must not follow the accent**: slot 1 is red because red means
  red, so `ansi16` stays a canonical table no role touches. **The guide still constrains
  which family suits which role**, so a free accent swap can produce a configuration
  `RICE-GUIDE.md` forbids, and whoever clones this is entitled to ignore that. **Roles
  only reach the generated half**: ten files would follow automatically and eight
  hand-written ones would not, swaylock among them with `key-hl-color` spelled out, so any
  README claim has to say which half. The natural complement is a check for orphaned
  literals.
  *Difficulty: medium, and the design questions are most of it. Priority: medium, and it
  makes the accent recipe shorter rather than replacing it.*

- **Wallpaper curation** is the largest remaining visual gap. Images chosen against the
  Wallpaper section of [`design/RICE-GUIDE.md`](design/RICE-GUIDE.md): material,
  desaturated, dark, at or below `void-00` in perceived lightness.
  *Difficulty: medium, blocked on sourcing images. Priority: medium.*

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
  this entry, the entry above about the rule with no home, and the mention in
  `TURNING-POINTS.md` of where the rules came from. Anything else is a real reference to
  deal with first. Note the "Never write a count that a config file owns" rule still has no
  home under `docs/`, which is the entry above.
  *Difficulty: low. Priority: medium, and it blocks nothing until publication.*

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

- **`THEMING.md` carries open work eight lines after saying this file owns it.** Delete its
  "Not covered yet" section, whose three items are verbatim from here. Its first three
  "Settled decisions"
  bullets restate `RICE-GUIDE.md` in their opening sentences; cut those sentences and keep
  the mechanism clause after each, which is this document's actual subject and exists only
  here. Bullets 4 and 5 must survive whole: the relaxed accent budget for fetches, and
  "Rollback is git, not a directory".
  *Difficulty: trivial. Priority: medium.*

- **The upstream bump this entry was waiting for has already happened, and nobody
  noticed.** It said the AUR package was still on 1.1.1 and that catnap 2.0 would break
  both tracked files. Measured: `catnap --version` reports `Catnap v2.1.1` and `pacman -Q`
  says `catnap 2.1.1-2`. What did not happen is the breakage: `catnap -n -c
  .config/catnap/config.toml` is not rejected under 2.1.1, where a garbage TOML exits 1
  immediately, so the file still parses. What is unmeasured is whether it is still
  *honoured*, and that is the question worth answering, because a config that parses and
  is ignored is this repository's signature failure.

  Two reasons the check said nothing. It passed `-a .config/catnap/distros.toml` and
  catnap has no `-a`, so every run printed `ERROR: Unknown option '-a'` and `distros.toml`
  has never been validated by anything. And it read the exit code the wrong way round:
  catnap does not exit at all when its stdout is not a terminal, so the code only means
  something in the negative. Both are fixed in `scripts/verify.sh`, which now covers
  `config.toml` only and says why.

  The payoff for moving to the `.cat` format is unchanged and real: v2 takes hex and theme
  imports, so the palette becomes reachable exactly instead of through seven ANSI tokens
  with no grey among them.
  *Difficulty: low, and it is a rewrite of two files. Priority: medium, because the
  version that was supposed to be the trigger is already installed.*

- **Decide whether `minimal/` survives its own rule.** `THEMING.md`'s "Rollback is git, not
  a directory" bullet settles "Do not reintroduce a legacy directory", and
  `.config/fastfetch/minimal/` is five files whose own header calls them frozen snapshots
  "NOT kept in sync". The presets are a recorded keep, so the two statements now disagree
  and one has to move: either `minimal/` is the documented exception, or it is the thing
  the rule was written about.
  *Difficulty: trivial, and it is a decision rather than work. Priority: low.*

- **Packages are declared for programs nothing here launches.** `dunst`, `hyprpaper`,
  `hyprlauncher` and `catnap` all have configs that are deliberate keeps, but a reference
  config does not need its program on a stranger's machine, and the question was only ever
  asked of `dunst`. `pfetch-rs` is the same shape with no config at all. `ranger`,
  `supergfxctl`, `cava`, `zathura`, `cmatrix` and `hyprpicker` have no config, launch or
  bind either, though `hyprpicker` is an optional dependency of `hyprshot`. If `pfetch-rs`
  goes, its comment about declaring a bare AUR name letting the helper pick a different
  provider applies to every AUR entry here and belongs in `MAINTENANCE.md`.
  *Difficulty: trivial. Priority: low.*

- **The launcher and the keybinding open different terminals.** `.config/wofi/config` sets
  `term=alacritty` while `.config/hypr/conf/programs.lua` sets `terminal = "kitty"`.
  All four terminals are themed identically, which is why it went unnoticed. Pick one.
  *Difficulty: trivial. Priority: low.*

- **hyprlauncher's radius contradicts the floating rule.** `hyprtoolkit.conf` sets both
  `rounding_large` and `rounding_small` to 0, but a launcher floats and the guide gives a
  floating surface 4px.
  Nothing renders it today, so fix it before switching back or the launcher arrives with
  the one geometry the design does not allow.
  *Difficulty: trivial. Priority: low while hyprlauncher stays off.*

- **`wallpapers/` holds two files of one image.** `Topography.png` and `Topography.jpg`
  are the same image at the same size, mean absolute difference 0.78/255, and both match
  the picker's glob, so a fresh clone randomises between two copies of one wallpaper while
  the README's repository layout promises "one sample image". Deleting the 1.1MB PNG makes
  the sentence true with no edit.
  *Difficulty: trivial. Priority: low.*

- **`config_files.conf` carries example blocks.** "Template Examples" is filler for a
  format that is one path per line. "Optional Configurations" is not: it names
  `~/.ssh/config`, `~/.ssh/known_hosts` and `~/.local/share/applications/`, and a
  commented `~/.ssh` is a visible decision not to track secrets by default.
  *Difficulty: trivial. Priority: low.*

- **The greetd section of `SETUP.md` explains greetd's own documentation.** The stock
  config, the flag
  meanings and `systemctl enable` are greetd's README and `tuigreet --help`. Three things
  are not: the `systemctl cat` verification, the `--sessions`/`--cmd` values tuned to this
  repository, and the "enable, not `enable --now`" footgun. Cut the per-flag prose only,
  and carefully, since shortening an untested procedure is how a claim of having tried it
  gets introduced by accident.
  *Difficulty: trivial. Priority: low.*

- **`AESTHETIC-DIRECTION.md` states photography direction that two other documents also
  state**, for a repository that has no photography; `RICE-GUIDE.md` already carries the
  wallpaper rules standalone. Its temperature map overlaps `DESIGN-SYSTEM.md`'s but the
  two disagree on row count and wording, so reconcile before deleting either, and decide
  the map's home only once `DESIGN-SYSTEM.md`'s is decided. Untouchable: the material
  references, "The right temperature of darkness", "What the system is not" and the note
  on coherence over time.
  *Difficulty: low. Priority: low.*

- **Dolphin's icons are still `breeze-dark`**, so folders come out blue against a Voidashi
  window. Every alternative installed here is worse aligned, so this waits on an icon set
  being chosen, which is an asset decision.
  *Difficulty: low once a set is chosen. Priority: low.*

- **The bar carries laptop-only modules with no guard.** `battery` and `backlight` sit in
  `modules-right` unconditionally, so on a desktop they are empty or absent, and
  `SETUP.md` tells a reader to remove them, which is a workaround. Waybar has no
  conditional module mechanism, so the options are a second `modules-right` in the
  per-compositor files or accepting the manual step.
  *Difficulty: low. Priority: low.*

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

- **Power profiles, on the machine rather than in the repo.** Idle handling exists;
  switching a CPU governor or a platform profile does not. `power-profiles-daemon` is the
  usual answer and it needs `systemctl enable`, a system service that `backup-configs.sh`
  will not manage, again for the reason in `TURNING-POINTS.md`. So this is a one-off to do
  by hand, plus a line in `SETUP.md` telling a reader to do the same if it turns out to be
  worth it. `supergfxctl` is already declared here, which suggests the graphics half was
  once considered.
  *Difficulty: low. Priority: low.*

- **Per-application workspace layouts.** `hypr/conf/window_rules.lua` already drops gaps
  and borders when a workspace holds one window, so this is an extension rather than
  a build. What does not exist is any application-to-workspace assignment. Decide the rule
  before writing it, because a workspace map that fights how you work is worse than none,
  and mirror it in the Sway config, which has no equivalent selectors and would need
  explicit `assign` rules.
  *Difficulty: low to write, and the design is the real work. Priority: low.*

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
