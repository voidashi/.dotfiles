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

One item, chosen for the next session rather than by rating: it is `medium` on both axes
while the stale screenshots are `high`, and those are blocked on someone taking new ones.

1. **Rethink how the generator decides colour, and consider a roles layer.**
   `palette.json` holds raw ramps plus a few roles expressed as duplicated literals:
   `terminal.cursor` and `focus_ring` are semantic keys carrying a hex that also exists in a
   scale. Making that systematic would have a role point at a token by name rather than
   repeat its value. The Neovim theme already works this way in three layers.

   What an audit of the generator added, and it raises the priority of this rather than
   the difficulty. **The leak is not confined to the hand-written half.** Two swaps,
   each measured by moving one scale value, regenerating and grepping the output.
   Moving `scales.ice.300` leaves `@define-color focus-ring #6aa3c7`, the retired value,
   in the shared GTK partial and in wofi's merged block, because `gen_gtk_css` reads
   `focus_ring` as an independent literal. Moving `scales.bordeaux.300` leaves all four
   terminals on the old cursor, `terminal.cursor` being the same shape. So "change one
   hex and everything moves" is false inside the generator's own output, not only
   outside it, and that is the sharpest argument for doing this at all.

   What the same runs showed is *not* a leak, and the distinction is the design: after
   moving `ice.300`, five generated files still carry the old hex as ANSI slot 12, in
   the four terminals and Neovim. That is the canonical table doing its job, and any
   check written for this work has to exempt it or it will report the decision as a
   bug.

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

   Three things to settle first. **ANSI must not follow the accent**: slot 1 is red
   because red means red, so `ansi16` stays a canonical table no role touches. **The
   guide still constrains which family suits which role**, so a free accent swap can
   produce a configuration `RICE-GUIDE.md` forbids, and whoever clones this is entitled
   to ignore that. **Roles only reach the generated half**, so any README claim has to
   say which half; which files those are, and which of them could be brought across, is
   the entry on bringing the hand-written half onto the generator, not a second count
   here.

   The check for orphaned literals that would complement this now exists, in the weak
   form: `check_palette.py` warns, without failing, when a role literal holds a hex no
   scale and no alert tone holds, which is what a half-finished hue swap leaves behind.
   It reads `colour_keys()`, so it covers `ansi16`, `focus_ring` and every `terminal.*`
   key. What it cannot see is a role that repeats the *wrong* scale value, since that
   value is in the palette and the question drift asks is only whether it is there at
   all. Naming the token is what answers the real question, and it retires the warning
   with it.

   **The check that ends it.** Move `scales.ice.300` by one digit, regenerate, and
   `git grep` the retired hex over the generator's own output, meaning the files
   carrying a `GENERATED` header plus wofi's block. Today it comes back in seven: the
   two role leaks and the five ANSI slots. When it comes back in the ANSI five alone,
   every role has followed its token. Repeat with `scales.bordeaux.300` for the cursor,
   which is the second shape. Scope matters here: the same grep over all of `.config`
   also returns six hand-written files, and those are the coverage entry's business
   rather than this one's.
   *Difficulty: medium, and the design questions are most of it. Priority: medium, and it
   makes the accent recipe shorter rather than replacing it.*

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

- **Bring the hand-written half onto the generator, in the order the survey found.** The
  generator owns 13 files; 19 more paste a palette colour by hand and follow nothing. A
  survey established, per application and against its own documentation or binary, whether
  the palette could reach it. The precedent is `.config/hypr/conf/decoration.lua`, already
  converted: it read `require("conf/palette")` for its radius while its shadow colour sat
  pasted, and the fix was one line.

  **The application has its own include, confirmed by running it.** These want a generated
  partial and one directive in the hand-written file, which is the pattern the four
  terminals already use.

  | File | Directive | Colours | How it was confirmed |
  |---|---|---|---|
  | `.config/sway/config` | `include <path>` | 9 | `sway --validate` rejects a bare `$var` and accepts it after the include |
  | `.config/hypr/hyprtoolkit.conf` | `source = <path>` | 6 | hyprtoolkit's own `source= globbing error` on a bad path, silent on a good one |
  | `.config/yazi/theme.toml` | `[flavor]` dark/light | 18 | the yazi binary's embedded default `theme.toml` and its `flavors/<name>.yazi/flavor.toml` path |

  Sway is the cheapest of the three and hyprtoolkit splits cleanest, 6 colour lines out and
  `rounding_*` and the font keys staying. Yazi is the largest single drift surface in the
  repository, 18 colours over 69 sites, but it needs a flavor package built, and whether
  `tmtheme.xml` is required at load is **unconfirmed**: the binary references it, the
  upstream package layout lists it, and nobody has watched yazi refuse a flavor without it.

  **Named colours in the same file, so a generated block inside it.** `.config/starship.toml`
  takes `palette = "<name>"` plus a `[palettes.<name>]` table, and `style` fields then name
  colours instead of repeating hex. Confirmed end to end: with the table in place,
  `starship prompt` emitted `38;2;177;177;177`, which is `ink-2`. 5 colours, and unlike the
  three above it rewrites the hand-written side too, since the hex become names.

  **No mechanism, and the reason differs.** `bottom` (18 colours) and `swaylock` (15) have
  one config file each and no include; their colour keys are contiguous, so a marked block
  like wofi's would work, but that is a wrapper rather than the application's own mechanism
  and taking it means saying so where it lives. The eight `fastfetch` presets are 107 sites
  and have neither route: measured, `fastfetch -c a -c b` answers `only one config file can
  be loaded`, and `display.constants` does not expand inside a colour field, which emitted
  the placeholder literally. `.config/waybar/common.jsonc` has one colour, inside pango
  markup, and waybar's `include` would force the whole module to move; the real answer there
  is CSS, since `waybar/style.css` already imports the generated stylesheet, but that
  changes module output and is a functional change rather than a theming one.
  `.config/catnap/config.toml` needs nothing and should not be counted: it pastes no hex at
  all, only ANSI tokens, which already resolve through the generated terminal table.
  *Difficulty: low each for sway, hyprtoolkit and starship; medium for yazi; high for
  fastfetch. Priority: medium, and it is what would make the README's promise true.*

- **The two compositors describe every runtime service twice, and have diverged.** The
  autostart block in `autostart.lua` against the run of `exec` lines in `sway/config`; the
  idle schedule in two syntaxes with a comment asking future editors to keep them in step;
  three screenshot binds under Hyprland against one bare `grim` under Sway; different
  launcher keys. Sway also carries nine hand-pasted hex while Hyprland reads a generated
  `palette.lua`, so the two sit on opposite sides of this repo's most important seam;
  the palette half of that is the entry above and not this one. Dropping Sway is
  not on the table: `sway/config` carries four findings that could only come from booting
  it, including notifications that were dead under Sway with the config themed and in
  place. The standing cost is that anything mirrored into `sway/config` from a Hyprland
  session is checked by `sway --validate` and never run. The brightness curve and the
  clipboard wipe both went in that way: confirmed working under Hyprland, untried under
  Sway.
  *Difficulty: high, now that the palette half has its own entry and what is left is the
  divergence. Priority: medium.*

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
