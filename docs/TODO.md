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

Three items, in this order. All come from a review by someone told to be an ordinary
Linux user who wants a good-looking desktop without spending a weekend on it. Two earlier
reviews were done by people who could read code, which is why none of this surfaced then.

What that reader valued, and what must survive these edits: "Is this for you?", the
symptom-first troubleshooting section, `docs/README.md` telling them only two documents
matter, `MAINTENANCE.md` letting them back out in one line, and "Known gaps". Their
verdict was that they would install this on a spare machine but not on their working
laptop, for two reasons: being told to read scripts they cannot read, and not knowing how
to reach the session. Both of those are now addressed.

1. **Write the recipe for changing the accent colour.** The README's headline promise is
   "change one hex and everything moves together", and it is the one promise no document
   lets a reader act on. Measured: `palette.json` has no accent key, the identity colour
   is a ten-value `bordeaux` ramp, and the same values are typed again as literals in
   `terminal.cursor` and `ansi16` slot 1. The reviewer spent ten minutes across five files
   and gave up. `RICE-GUIDE.md`, which the index recommends for changing appearance,
   answers "never introduce a colour that is not derived from these", which is the
   opposite of what they wanted. Owed: a short section in `SETUP.md` naming the exact keys,
   the two places the values are duplicated, and one worked example ending in the two
   commands that already exist. It gets shorter once the generator gains a roles layer.
   *Difficulty: low. Priority: maximum, since it is the repo's best promise with nothing
   behind it.*

2. **Make the two things a reader has to guess at explicit.** The README offers that you
   can lift the terminal colours, or the bar, or just the palette generator, and no
   document says how, while the installer brings all of `packages.conf` including both
   compositors and both notification daemons. Write the cheap path in three lines or drop
   the offer; this is the documentation half and does not wait on "Let `install` take
   paths". Separately, the Iosevka step is the one place a reader must pattern-match
   alone: "the Iosevka SGr TTC build" is not a filename, the releases page is a wall of
   near-identical archives, and the theme wants "Iosevka Extended", a third name. Give the
   exact asset or a `curl` line.
   *Difficulty: low. Priority: maximum.*

3. **Rewrite the README's opening so it holds the reader.** "Is this for you?" is good and
   the reviewer said so, but it opens by qualifying rather than by selling. Lead with what
   this is and why it looks good, then what it contains, and only then filter.
   *Difficulty: low. Priority: maximum.*

## Open work

Sorted by priority. Within a priority, by nothing.

- **The brightness keys are dead on this machine.** `binds.lua:91-92` and
  `sway/config:178-179` bind them to `brightnessctl`, which is neither installed nor
  declared under any name. `nm-applet` is in the same position, autostarted by
  `autostart.lua:10` and absent. The other six binaries once listed as undeclared
  (`rfkill`, `playerctl`, `wpctl`, `pactl`, `grim`, `swaynag`) arrive as hard dependencies
  of declared packages, so they are not a problem: `grim` and `slurp` come with
  `hyprshot`.
  *Difficulty: trivial. Priority: high, and it is a live defect.*

- **The screenshots in the README predate the current theme.** Committed April 2025, they
  show the Kanagawa desktop this repo no longer contains. They stay until replaced, since
  a stale screenshot beats none.
  *Difficulty: low, blocked on taking new ones. Priority: high, because it is the first
  thing a visitor sees.*

- **A tracked gitlink can come back through a merge, and nothing notices.**
  `.claude/worktrees/greetd-session-entry` was swept into the index once, removed on
  purpose by `5ab0358`, and restored by a merge that kept the other side of the history.
  It is untracked again, but `.gitignore` cannot prevent a recurrence, because git ignores
  it for a path already tracked. Prose has failed at this twice, so what is owed is a
  check: `git ls-files -s | grep '^160000'` must come back empty. It would have caught
  both occurrences.
  *Difficulty: trivial. Priority: high, because it survives a merge silently.*

- **One command should run every validator, and it cannot live in `.claude/`.** The
  verify-repo skill is the only artefact that runs all nine checks, and this file commits
  to deleting `.claude/` at publication. Its content is duplicated as prose in
  `MAINTENANCE.md`, the two have already diverged, and neither runs
  `scripts/tests/test-dotfiles.sh`. Worse, the skill's symlink block measures nothing: it
  counts `SUCCESS` lines that `backup-configs.sh` gates behind `--verbose`, which the block
  does not pass, so it prints `valid: 0` on a healthy tree beside a summary reading
  "Valid: 32". A `scripts/verify.sh` that both call is the answer, and it is the
  precondition for deleting `.claude/` without loss. Two checks belong in it that nothing
  runs today: the test suite, and the gitlink guard above.
  *Difficulty: low. Priority: high, and higher the day publication is real.*

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
  `hyprtoolkit.conf` carried the wide one twice.
  *Difficulty: trivial. Priority: medium, because it is lost silently at deletion.*

- **Five stale counts in `install-packages.sh`, and one leftover marker.** Lines 90, 175,
  212, 219 and 342 say "56 packages" or "56 lines"; `packages.conf` holds 57 names. The
  rule against this is in `CLAUDE.md`, which uses `"56 packages"` as its example of what
  not to write. Line 160 also still carries a `### MODIFICATION ###` banner from
  development.
  *Difficulty: trivial. Priority: medium.*

- **`generate_theme.py` generates everything twice.** `if __name__ == "__main__": main()`
  appears at lines 626 and 630, both at top level, so every run repeats all ten files and
  the three in-place edits. The comment at line 618 says "These two" and there are three:
  `inline_block`, `merge_kde_globals`, `merge_kcm_input`. Fix the comment in the same
  edit. Invisible only because the writes are idempotent.
  *Difficulty: trivial. Priority: medium, since those three edit files in place.*

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

- **Let `install` take paths, so the README's offer is true.** `backup-configs.sh install`
  is still every path in `config_files.conf` or nothing. `install_dotfiles`,
  `check_dotfiles` and `uninstall_dotfiles` are each a loop over `load_dotfiles`, so
  filtering by positional arguments is roughly ten lines and needs no config format
  change. `add_dotfile` already takes one path.
  *Difficulty: low. Priority: medium, and it is the cheapest way for a stranger to try
  this without committing to all of it.*

- **The two compositors describe every runtime service twice, and have diverged.** The
  autostart set at `autostart.lua:15-35` against `sway/config:237-265`; the idle schedule
  in two syntaxes with a comment asking future editors to keep them in step; three
  screenshot binds under Hyprland against one bare `grim` under Sway; different launcher
  keys. Sway also carries nine hand-pasted hex while Hyprland reads a generated
  `palette.lua`, so the two sit on opposite sides of this repo's most important seam. The
  cheap half is generating a Sway palette include, about fifteen lines in
  `generate_theme.py`, which moves nine literals off the drift surface. Dropping Sway is
  not on the table: `sway/config` carries four findings that could only come from booting
  it, including notifications that were dead under Sway with the config themed and in
  place.
  *Difficulty: low for the include, high for the rest. Priority: medium.*

- **Rethink how the generator decides colour, and consider a roles layer.**
  `palette.json` holds raw ramps plus a few roles expressed as duplicated literals:
  `terminal.cursor` and `focus_ring` are semantic keys carrying a hex that also exists in a
  scale. Making that systematic would have a role point at a token by name rather than
  repeat its value. The Neovim theme already works this way in three layers. Three things
  to settle first. **ANSI must not follow the accent**: slot 1 is red because red means
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

- **The clipboard and idle daemons need one login to start.** `cliphist`, `hypridle` and
  `swayidle` are installed and configured, but a session started before the autostart
  lines existed is not running them, and the running `hypridle` also predates the
  `systemd-cat` wrapper and the current timeouts. One logout fixes both. Confirm with
  commands rather than by pressing a keybind, because a dead daemon and an empty history
  look identical: `pgrep -x hypridle`, `pgrep -x wl-paste`, `cliphist list | wc -l`, and
  `journalctl -t hypridle --since "-1h"`, which stays empty until the wrapped one has run.
  *Difficulty: trivial. Priority: medium.*

- **`.claude/` and `CLAUDE.md` are deleted at publication.** Before deleting, run both
  checks, because the first alone was trusted once and was not enough:

  ```bash
  # 1. no repo knowledge left in the file itself
  grep -icE "kded6|8-digit hex|process cwd|swaylock-effects" CLAUDE.md   # expect 0
  # 2. nothing anywhere points at either path. Code counts, not just docs.
  grep -rn "CLAUDE\.md\|\.claude/" --exclude-dir=.git .
  ```

  The second exists because the first was run with `--include="*.md"` and reported clean
  while eight references sat in six config and script files. What it may legitimately
  return: this entry, `CLAUDE.md`'s title line, the `.claude/worktrees/` rule in
  `.gitignore`, and hits inside the gitignored `scripts/package_install.log`. Anything else
  is a real reference to deal with first.
  *Difficulty: low. Priority: medium, and it blocks nothing until publication.*

- **The apt and dnf machinery has never run.** Fourteen non-comment lines mention apt or
  dnf, in the low thirties counting whole `case` branches and the `repos` dispatch. Two
  costs before touching it: `SETUP.md:12` and `README.md:157` advertise cross-distro
  support to a reader, so this is a documentation edit too; and `install_all()` reaches
  `update_pkg_db()` only through `add_repos()`, so deleting that function without rewiring
  drops `pacman -Syy` from every Arch install. The Microsoft repository key at lines
  133-137 serves `code`, which is declared at `packages.conf:107`, so it is apt-only
  machinery rather than an orphan and stands or falls with the branch.
  *Difficulty: low. Priority: medium.*

- **`THEMING.md` carries open work eight lines after saying this file owns it.** Delete
  159-166, whose three items are verbatim from here. Its first three "Settled decisions"
  bullets restate `RICE-GUIDE.md` in their opening sentences; cut those sentences and keep
  the mechanism clause after each, which is this document's actual subject and exists only
  here. Bullets 4 and 5 must survive whole: the relaxed accent budget for fetches, and
  "Rollback is git, not a directory".
  *Difficulty: trivial. Priority: medium.*

- **Decide whether `minimal/` survives its own rule.** `THEMING.md:153-157` settles
  "Rollback is git, not a directory. Do not reintroduce a legacy directory", and
  `.config/fastfetch/minimal/` is five files whose own header calls them frozen snapshots
  "NOT kept in sync". The presets are a recorded keep, so the two statements now disagree
  and one has to move: either `minimal/` is the documented exception, or it is the thing
  the rule was written about.
  *Difficulty: trivial, and it is a decision rather than work. Priority: low.*

- **Six packages are declared for programs nothing here launches.** `dunst`, `hyprpaper`,
  `hyprlauncher` and `catnap` all have configs that are deliberate keeps, but a reference
  config does not need its program on a stranger's machine, and the question was only ever
  asked of `dunst`. `pfetch-rs` is the same shape with no config at all. `ranger`,
  `supergfxctl`, `cava`, `zathura`, `cmatrix` and `hyprpicker` have no config, launch or
  bind either, though `hyprpicker` is an optional dependency of `hyprshot`. If `pfetch-rs`
  goes, its comment about declaring a bare AUR name letting the helper pick a different
  provider applies to every AUR entry here and belongs in `MAINTENANCE.md`.
  *Difficulty: trivial. Priority: low.*

- **The launcher and the keybinding open different terminals.** `.config/wofi/config` sets
  `term=alacritty` while `.config/hypr/conf/programs.lua:10` sets `terminal = "kitty"`.
  All four terminals are themed identically, which is why it went unnoticed. Pick one.
  *Difficulty: trivial. Priority: low.*

- **hyprlauncher's radius contradicts the floating rule.** `hyprtoolkit.conf:32-33` sets
  both radii to 0, but a launcher floats and the guide gives a floating surface 4px.
  Nothing renders it today, so fix it before switching back or the launcher arrives with
  the one geometry the design does not allow.
  *Difficulty: trivial. Priority: low while hyprlauncher stays off.*

- **`wallpapers/` holds two files of one image.** `Topography.png` and `Topography.jpg`
  are the same image at the same size, mean absolute difference 0.78/255, and both match
  the picker's glob, so a fresh clone randomises between two copies of one wallpaper while
  `README.md:161` promises one. Deleting the 1.1MB PNG makes the sentence true with no
  edit.
  *Difficulty: trivial. Priority: low.*

- **`config_files.conf` carries example blocks.** "Template Examples" is filler for a
  format that is one path per line. "Optional Configurations" is not: it names
  `~/.ssh/config`, `~/.ssh/known_hosts` and `~/.local/share/applications/`, and a
  commented `~/.ssh` is a visible decision not to track secrets by default.
  *Difficulty: trivial. Priority: low.*

- **`SETUP.md:118-143` explains greetd's own documentation.** The stock config, the flag
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

- **catnap's tracked config dies on the next upstream bump.** catnap 2.0 replaced the TOML
  config with a `.cat` language and says outright that `config.toml` and `distros.toml`
  are not compatible. The AUR package is still 1.1.1, so today it works. When it moves,
  both files need rewriting rather than editing, and the payoff is real: v2 takes hex and
  theme imports, so the palette becomes reachable exactly instead of through seven ANSI
  tokens with no grey among them. The validator battery runs catnap and reports its exit
  code, so this surfaces as a failed check.
  *Difficulty: low. Priority: low until the AUR moves.*

- **The bar carries laptop-only modules with no guard.** `battery` and `backlight` sit in
  `modules-right` unconditionally, so on a desktop they are empty or absent, and
  `SETUP.md` tells a reader to remove them, which is a workaround. Waybar has no
  conditional module mechanism, so the options are a second `modules-right` in the
  per-compositor files or accepting the manual step.
  *Difficulty: low. Priority: low.*

- **Per-application workspace layouts.** `hypr/conf/window_rules.lua:10-16` already drops
  gaps and borders when a workspace holds one window, so this is an extension rather than
  a build. What does not exist is any application-to-workspace assignment. Decide the rule
  before writing it, because a workspace map that fights how you work is worse than none,
  and mirror it in the Sway config, which has no equivalent selectors and would need
  explicit `assign` rules.
  *Difficulty: low to write, and the design is the real work. Priority: low.*

- **Comments in about 8 of the 17 files under `.config/hypr/` are in Portuguese** while
  the rest of the tree is English, including the note at `autostart.lua:12` on why
  absolute paths are used, which is worth reading. Translate on touch. This is a
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
