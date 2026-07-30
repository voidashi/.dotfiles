# Open work

What is not finished, what is parked and why, and what has been decided against. Check
here before assuming something is undone: several of the entries below record an
elimination that is expensive to repeat.

Each item carries a **difficulty** and a **priority**, rated separately. Difficulty is
how much work it is and how much can go wrong; priority is how much it costs to leave
alone. They are independent: a one-line fix can be urgent and a rewrite optional.

What lives here is work, plus the decisions that were made *against* doing something,
because those are what stop a question being reopened. What does not live here is settled
knowledge: pitfalls and validators are in [`MAINTENANCE.md`](MAINTENANCE.md), how the
palette reaches each application is in [`design/THEMING.md`](design/THEMING.md), and why
the repository is shaped as it is belongs to
[`TURNING-POINTS.md`](TURNING-POINTS.md).

## Pending actions, not work

- **The clipboard and idle daemons need one login to start.** `cliphist`, `hypridle` and
  `swayidle` are installed and configured, but a compositor session started before the
  autostart lines existed will not be running them. Confirm with the commands rather than
  by pressing the keybind, because a dead daemon and an empty history look identical:
  `pgrep -x hypridle`, `pgrep -x wl-paste`, `cliphist list | wc -l`.
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

- **The bar carries laptop-only modules with no guard.** `battery` and `backlight` are
  in `modules-right` unconditionally, so on a desktop they are empty or absent.
  `SETUP.md` tells a reader to remove them, which is a workaround rather than a fix.
  Waybar has no conditional module mechanism, so the honest options are a second
  `modules-right` in the per-compositor files or accepting the manual step.
  *Difficulty: low. Priority: low.*

## Features not built

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

  Testing needs a throwaway `$HOME`. `backup-configs.sh --dry-run` already exists and is
  the cheapest start; a temporary `HOME=` or a container is the honest version.
  *Difficulty: medium to read, higher with a test harness. Priority: medium, and it rises
  for anyone else cloning this, since these scripts are the first thing they run.*

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
shell scripts, and about 25 remain in comments across the stylesheets, the terminal
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
