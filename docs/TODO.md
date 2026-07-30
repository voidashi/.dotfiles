# Open work

What is not finished, what is parked and why, and what has been decided against. Check
here before assuming something is undone: several of the entries below record an
elimination that is expensive to repeat.

The first section is what to do next and is ordered; everything after it is grouped by
kind and is not.

Each piece of work carries a **difficulty** and a **priority**, rated separately.
Difficulty is how much work it is and how much can go wrong; priority is how much it costs
to leave alone. They are independent: a one-line fix can be urgent and a rewrite optional.
The entries under "Pending actions" are unrated on purpose, being things to do rather than
work to plan.

What lives here is work, plus the decisions that were made *against* doing something,
because those are what stop a question being reopened. What does not live here is settled
knowledge: pitfalls and validators are in [`MAINTENANCE.md`](MAINTENANCE.md), how the
palette reaches each application is in [`design/THEMING.md`](design/THEMING.md), and why
the repository is shaped as it is belongs to
[`TURNING-POINTS.md`](TURNING-POINTS.md).

## Start here next session

Highest priority, before anything else. All four come from a third review, by someone
told to be an ordinary Linux user who wants a good-looking desktop without spending a
weekend on it, and who can google anything obvious. The two earlier reviews were done by
people who could read code, which is why none of this surfaced then. Every finding below
was re-verified by hand.

The fifth, "say how to get into the session", is done: `greetd` and `greetd-tuigreet` are
declared, `SETUP.md` step 5 covers the display manager and the text console paths, and the
black-screen symptom is in the troubleshooting list. What it left behind is below, under
"Pending actions" and "Features not built".

1. **Make `--dry-run` the first install step, and stop asking the reader to audit bash.**
   The README's warning currently says to read the scripts before pointing them at a home
   directory. The reviewer stopped there, correctly: they cannot audit 400 lines of bash,
   so the instruction leaves only "ignore the author" or "give up". `--dry-run` is the
   answer and appears once in the README and **zero times** in `SETUP.md`'s numbered
   steps, which is the guide they would actually follow. Make it step 0, and reword the
   warning to offer the way out rather than to demand the reading.
   *Difficulty: trivial. Priority: maximum.*

2. **Write the recipe for changing the accent colour.** The README's headline promise is
   "change one hex and everything moves together", and that promise is what makes people
   want the repo. It is also the one thing no document lets them act on. Measured:
   `palette.json` has no accent key at all, the identity colour is a ten-value `bordeaux`
   ramp, and the same values are typed again as literals in `terminal.cursor` (`#c76870`)
   and `ansi16` slot 1 (`#b44955`). The reviewer spent ten minutes across five files and
   gave up. Meanwhile `RICE-GUIDE.md`, which the index recommends for changing appearance,
   answers "never introduce a colour that is not derived from these", which is the
   opposite of what they wanted.

   So: a short section in `SETUP.md` naming the exact keys to edit, the two places the
   values are duplicated, and one worked example ending in the two commands that already
   exist. Fifteen lines. It stays true and gets shorter once the generator gains a roles
   layer, below.
   *Difficulty: low. Priority: maximum, since it is the repo's best promise with nothing
   behind it.*

3. **Make the two things a reader has to guess at explicit.** The README offers "you can
   lift the terminal colours, or the bar, or just the palette generator, and ignore the
   rest", and no document says how, while the installer brings 54 packages including both
   compositors, both notification daemons and both file managers. Write the cheap path in
   three lines, or drop the offer; the `install <path>` flag that would make it one command
   is a code change and belongs to the script audit under Housekeeping, which owns it.

   Separately, the Iosevka step is the one place the reader has to pattern-match alone:
   "the Iosevka SGr TTC build" is not a filename, the releases page is a wall of
   near-identical archives, and the theme wants "Iosevka Extended", a third name. Give the
   exact asset or a `curl` line. The penalty for guessing wrong is a default-looking
   terminal, which is the whole point of the repo.
   *Difficulty: low. Priority: maximum.*

4. **Rewrite the README's opening as an introduction that holds the reader.** "Is this for
   you?" is good and the reviewer said so, but it opens by qualifying rather than by
   selling, so it does not hold someone who just opened the repo. The page should lead
   with what this is and why it looks good, then what it contains, and only then filter
   with "is this for you". Keep the honesty that earned trust: the reviewer named "Known
   gaps" as the single thing that most made them believe the rest.
   *Difficulty: low. Priority: maximum.*

Worth keeping from that review, because it is easy to lose: the parts that worked on this
reader were "Is this for you?", the symptom-first troubleshooting section, `docs/README.md`
telling them only two documents matter, `MAINTENANCE.md` letting them back out in one line,
and "Known gaps". Do not lose those while fixing the above. Their verdict was that they
would install it on a spare machine but not on the laptop they work on, for exactly two
reasons: being told to read scripts they cannot read, and not knowing how to reach the
session.

## Pending actions, not work

- **The clipboard and idle daemons need one login to start.** `cliphist`, `hypridle` and
  `swayidle` are installed and configured, but a compositor session started before the
  autostart lines existed will not be running them. Confirm with the commands rather than
  by pressing the keybind, because a dead daemon and an empty history look identical:
  `pgrep -x hypridle`, `pgrep -x wl-paste`, `cliphist list | wc -l`.
- **The greetd path has never been run.** It is now documented in `SETUP.md` step 5 and
  declared in `packages.conf`, but this machine reaches its desktop through
  `plasmalogin` and greetd is not installed here, so nothing has exercised the config or
  the unit. What was verified is narrow and worth not re-doing: both packages exist in
  `extra` (`pacman -Si greetd greetd-tuigreet`), the config format and the tuigreet flags
  come from upstream's own README, and `/usr/share/wayland-sessions/` already holds
  `hyprland.desktop` and `sway.desktop` from the compositor packages. What is unverified
  is the whole path end to end: that the unit name is right, that the config parses, and
  that tuigreet lists both sessions. A spare machine or a VM is the honest test, and
  until then `SETUP.md` should not gain any sentence claiming it was tried.
- **`CLAUDE.md` and `.claude/` are deleted at publication.** The content moved to
  [`MAINTENANCE.md`](MAINTENANCE.md). Before deleting, run both checks, because the first
  one alone was trusted once and was not enough:

  ```bash
  # 1. no repo knowledge left in the file itself
  grep -icE "kded6|8-digit hex|process cwd|swaylock-effects" CLAUDE.md   # expect 0
  # 2. nothing anywhere points at either path. Code counts, not just docs.
  grep -rn "CLAUDE\.md\|\.claude/" --exclude-dir=.git .               # expect only CLAUDE.md's own title
  ```

  The second check exists because the first was run with `--include="*.md"` and reported
  clean while eight references sat in six config and script files.

## Known defects

- **Workspace buttons in the bar do not respond to clicks**, and it is not this
  configuration. A full bisect ruled out everything on our side, so it is parked rather
  than solved. Established:

  - Not the stylesheet. It fails identically with `/etc/xdg/waybar/style.css`.
  - Not the layer. It fails on both `bottom` and `top`.
  - Not `persistent-workspaces`. It fails with the legacy `{"1": [], ...}` form and with
    the documented `{"*": 5}` form.
  - Not a missing handler. Probes on `on-click`, `on-click-right`, `on-click-middle` and
    `on-scroll-up` running `notify-send` never fired once.
  - Not the bar's input in general. `clock` toggles, `custom/power` opens the menu, and
    hovering a workspace button highlights it, so the widget receives motion events.
  - Nothing reaches Hyprland either: with `-l debug` a click produces no dispatch line
    and no `workspace>>` event, while a keyboard switch produces both.

  So in waybar 0.15.0 those buttons take motion events and no button events at all.
  Next avenues in order of cost: check upstream issues for this version, try a different
  build, or replace the module with a `custom` one that renders and dispatches
  workspaces itself, which would cost the live updates. Three genuine config defects
  were fixed along the way and are worth keeping regardless: `layer` is `top`,
  `persistent-workspaces` uses the documented form, and a `disable-scroll` belonging to
  `sway/workspaces` was removed.
  *Difficulty: high, now that the cheap explanations are gone. Priority: medium, since
  keyboard switching works and this is a convenience.*

- **The launcher and the keybinding open different terminals.**
  `.config/wofi/config` sets `term=alacritty` while
  `.config/hypr/conf/programs.lua:10` sets `terminal = "kitty"`, so a terminal
  application started from the launcher lands in a different emulator from
  `Super`+`Return`. All four are themed identically so nothing looks wrong, which is
  why it went unnoticed. Pick one and make both agree.
  *Difficulty: trivial. Priority: low.*

- **hyprlauncher's radius contradicts the floating rule.**
  `.config/hypr/hyprtoolkit.conf:32-33` sets `rounding_large` and `rounding_small` to 0,
  but a launcher floats, and the guide's Form rule gives a floating surface 4px. It went
  unnoticed because hyprlauncher is commented out in `conf/programs.lua` in favour of
  wofi, so nothing renders it. Fix it before switching back, or the launcher arrives with
  the one geometry the design does not allow.
  *Difficulty: trivial. Priority: low while hyprlauncher stays off.*

- **The bar carries laptop-only modules with no guard.** `battery` and `backlight` are
  in `modules-right` unconditionally, so on a desktop they are empty or absent.
  `SETUP.md` tells a reader to remove them, which is a workaround rather than a fix.
  Waybar has no conditional module mechanism, so the honest options are a second
  `modules-right` in the per-compositor files or accepting the manual step.
  *Difficulty: low. Priority: low.*

## Features not built

- **Bring the greeter onto the palette.** `tuigreet` takes a `--theme` flag in
  `component=color` form, which is why it was chosen over the alternatives, and today it
  is declared and documented unthemed. The obstacle is not the flag: greetd's config is
  root-owned and outside `$HOME`, so `generate_theme.py` has nowhere to write and
  `check_palette.py` has nothing to check, and the login screen would be the one surface
  that drifts off-palette with no validator noticing. Decide first whether generating a
  file outside `$HOME` is something this repo does at all, because the same question
  governs power profiles below. Depends on the item under "Pending actions": theming a
  path nobody has booted is the wrong order.
  *Difficulty: low once the scope question is answered. Priority: low, and it is the
  first surface a visitor sees, which argues it up once greetd is actually in use.*

- **Power profiles.** Idle handling exists; switching a CPU governor or a platform
  profile does not. `power-profiles-daemon` is the usual answer and it needs
  `systemctl enable`, which is a system service rather than a dotfile, so
  `backup-configs.sh` has no way to manage it. `supergfxctl` is already declared here,
  which suggests the graphics half was once considered. The question of whether this
  repository should carry system services at all comes before the work.
  *Difficulty: low. Priority: low, and it is a scope decision more than a task.*

- **Per-application workspace layouts.** Something real exists underneath, so this is
  an extension rather than a build: `hypr/conf/window_rules.lua:10-16` already drops
  gaps and borders when a workspace holds a single window, through Hyprland's `w[tv1]`
  and `f[1]` selectors. What does not exist is any application-to-workspace assignment.
  Decide what the rule should be before writing it, because a workspace map that fights
  how you work is worse than none. Whatever it becomes has to be mirrored in the Sway
  config, which has no equivalent of those selectors and would need explicit `assign`
  rules.
  *Difficulty: low to write, and the design is the real work. Priority: low.*

## Housekeeping

- **Audit the two management scripts properly.** `install-packages.sh` and
  `backup-configs.sh` are the only code here that can damage a real `$HOME`, and neither
  has been read end to end looking for defects, or linted. The one defect found so far
  shows the shape of the risk: `&& ((success++)) || ((failures++))` counted a phantom
  failure on every run and made the script exit 1 on a completely successful install,
  for as long as that line existed, and it surfaced because a summary line looked wrong
  rather than because anything checked it.

  Three passes, in order. **Correctness** first, with arithmetic and exit-code handling
  ahead of everything else since that is where the known defect lived, along with `set
  -e` interactions, unquoted expansions, the `rsync --remove-source-files` paths that
  could move the wrong tree, and the `--force` branch that removes a real file after
  backing it up. Record what was checked and found clean, not only what was wrong, so
  the next audit does not repeat this one. Then **shellcheck**, judging its output rather
  than obeying it. Then **structure**: both scripts resolve their `.conf` from
  `SCRIPT_DIR`, both log, both colour output, both parse an INI-ish file, and whether
  that wants a shared helper or is better left as two independent readable scripts is a
  real question rather than an obvious yes.

  One capability to restore while in there: `install` used to take a path and link only
  that, and `install_dotfiles()` takes no argument today, so partial installation was lost
  rather than removed on purpose. It is what makes the README's offer of taking one piece
  true, and it is also the safest way for a stranger to try this, so it belongs in the
  correctness pass rather than being bolted on afterwards.

  Testing needs a throwaway `$HOME`. `backup-configs.sh --dry-run` already exists and is
  the cheapest start; a temporary `HOME=` or a container is the honest version.
  *Difficulty: medium to read, higher with a test harness. Priority: medium, and it rises
  for anyone else cloning this, since these scripts are the first thing they run.*

- **Rethink how the generator decides colour, and consider a roles layer.** Today
  `palette.json` holds raw ramps plus a few roles expressed as duplicated literals:
  `terminal.cursor` and `focus_ring` are semantic keys carrying a hex that also exists in
  a scale. The idea worth exploring is to make that systematic, so a role points at a
  token by name rather than repeating its value: `"accent_identity": "bordeaux-400"`,
  `"surface_panel": "void-10"`, and so on. That is not a new pattern here. The Neovim
  theme already works exactly this way in three layers, raw palette then semantic roles
  then highlight groups, and this would lift the same structure up into the source of
  truth.

  Three things to settle before writing any of it, one of which is a hard boundary.

  **ANSI must not follow the accent.** Slot 1 is red because red means red. If someone
  swaps the identity family to Ash, ANSI red has to stay red, so `ansi16` remains a
  canonical table that no role touches. Getting this wrong is the obvious way to break the
  non-negotiable that ANSI is identical everywhere.

  **The guide still constrains which family suits which role.** Ash is media and never
  functional UI, so a free accent swap can produce a configuration `RICE-GUIDE.md`
  forbids. The mechanism becomes one key; the design position does not change. Whoever
  clones this and wants a different look is entitled to ignore the guide, and saying so
  explicitly keeps the two documents from appearing to contradict each other.

  **Roles only reach the generated half.** Ten files are generated and would follow a role
  change automatically. Eight are hand-written because colour mixes with structure there,
  swaylock among them with `key-hl-color=b44955` spelled out, and those would not. So "one
  key" would be true of half the system, and any claim in the README has to say which
  half. The natural complement is a check for orphaned literals: a hex in a hand-written
  file that no role uses any more.

  This is a generator refactor with ten generated files to re-verify, so it wants its own
  plan rather than being folded into a documentation pass.
  *Difficulty: medium, and the design questions are most of it. Priority: medium, and it
  makes the recipe in item 3 above shorter rather than replacing it.*

- **catnap's tracked config dies on the next upstream bump.** Upstream is at 2.1.1, and
  catnap 2.0 replaced the TOML config with a `.cat` language, saying outright that
  `config.toml` and `distros.toml` are not compatible with v2. The AUR package is still
  1.1.1, so today it works. When it moves, both tracked files need rewriting rather than
  editing, and the payoff is real: v2 takes hex, RGB and theme imports, so the palette
  becomes reachable exactly instead of through seven ANSI tokens with no grey among them.
  The validator battery runs catnap and reports its exit code, so this surfaces as a
  failed check rather than as a broken greeter.
  *Difficulty: low, and it is a rewrite of two files. Priority: low until the AUR moves,
  then blocking for anyone using catnap as their greeter.*

- **`dunst` is declared in `packages.conf` although nothing launches it.**
  `.config/dunst/` is kept deliberately as a reference and that decision is settled, but
  installing the package on every fresh clone is a separate question that was never
  asked.
  *Difficulty: trivial. Priority: low.*

- **Elegance pass over structure and organisation.** Several things work without being
  elegant: duplicated structure, files that exist for no current reason, inconsistent
  naming across the scripts, configs that repeat what a shared source could hold.
  Open-ended by nature, so it should produce a list before anything moves.
  *Difficulty: high, and open-ended. Priority: medium.*

## Needs assets, not code

- **Wallpaper curation** is the largest remaining visual gap. It needs images chosen
  against the Wallpaper section of [`design/RICE-GUIDE.md`](design/RICE-GUIDE.md):
  material, desaturated, dark, sitting at or below `void-00` in perceived lightness.
  *Difficulty: medium, blocked on sourcing images. Priority: medium.*

- **The screenshots in the README predate the current theme.** They were committed in
  April 2025 and show the Kanagawa desktop this repo no longer contains. They stay until
  replaced, since a stale screenshot still beats none.
  *Difficulty: low. Priority: high, because it is the first thing a visitor sees.*

- **Dolphin's icons are still `breeze-dark`**, so folders come out blue against a
  Voidashi window. Every alternative installed here is worse aligned, so this waits on
  an icon set being chosen, which is an asset decision rather than a config one.
  *Difficulty: low once a set is chosen. Priority: low.*

## Provisional, not wrong

Three things about the bar are settled only until they have been lived with: whether
numerals beat application glyphs on the workspace buttons, whether the right-hand
modules want separators or should stay spaced only, and whether 15px at weight 500 is
the right text size.

## Writing standard

Every document here is at zero em dashes, verified rather than assumed. The standard,
not a task: no em dashes, and never state a thing then restate it inverted.

The double hyphens that stood in for a dash are **not** finished. They are out of the
shell scripts, and 24 remain in comments across the stylesheets, the terminal
configs and `palette.json`. Clean each when something else takes you into the file;
`set -- "$@"` in bash is real syntax and stays.
*Difficulty: trivial per file. Priority: low.*

Worth keeping from having done it three times, because a blanket substitution does not
work. An em dash between two independent clauses wants a semicolon, one introducing an
explanation wants a colon, one around a parenthetical wants parentheses, and some
sentences want rewording because no punctuation mark carries the sense. Comma everywhere
produces comma splices; semicolon everywhere produces fragments. The changed lines have
to be reread afterwards, and doing that caught a broken sentence in two of the three
passes.
