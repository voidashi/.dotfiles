# Maintaining these dotfiles

For whoever edits this repository, including its author six months from now. If you
only want to install and use it, read the [README](../README.md) instead.

This is not a software project with a build and a test suite. It is a curated set of
config files, two bash scripts that sync them to `$HOME` and install the packages
they depend on, and two Python scripts that generate and verify the theme. So
"correct" here means three things: the shell scripts behave safely, each config file
is valid for the application that reads it, and `check_palette.py` passes.

Almost everything below is here because it cost a debugging session to find. The
common shape is a silent failure: something configured, looking configured, and
doing nothing, with no error message anywhere.

## How the repo is laid out

- `.config/<app>/`: the real config files, tracked by symlinking them back into
  `$HOME`. Covers `hypr`, `sway`, `waybar`, `fish`, `nvim`, `alacritty`, `kitty`,
  `foot`, `ghostty`, `bottom`, `dunst`, `wofi`, `fastfetch`, `catnap`, `wlogout`,
  `swaylock`, `swaync`, `yazi`, `starship.toml`, the GTK and KDE files.
- `.config/theme/`: one generated file, `voidashi-colors.css`, which the waybar,
  wlogout and swaync stylesheets `@import`. wofi is the exception: the generator
  inlines the palette into its stylesheet instead, for the reason written at the top
  of `.config/wofi/style.css`. It belongs to no single application, which is why it
  has a directory of its own.
- `.bashrc`: the one tracked dotfile outside `.config`.
- `scripts/backup-configs.sh`, `install-packages.sh`: run by hand. See below.
- `scripts/config_files.conf`: every path, relative to `~`, that
  `backup-configs.sh` manages. A new dotfile goes here before anything else.
- `scripts/packages.conf`: the package list, INI-style, with `[common]`, `[apt]`,
  `[pacman]`, `[dnf]` and `[hooks]` sections.
- `scripts/wm/`: helpers the compositors call *while running*, as opposed to the
  top-level scripts, which you run yourself.
- `scripts/theme/`: `palette.json` is the single source of truth for every colour;
  `generate_theme.py` renders it into each application's own format;
  `check_palette.py` proves nothing drifted. Rerun the generator after editing the
  palette, and never hand-edit its output, which carries a `GENERATED` header.
- `fonts/`, `wallpapers/`, `docs/`: assets and documentation.

**Naming is not a preference.** Shell scripts use hyphens (`backup-configs.sh`),
matching how Unix names executables, where hyphens outnumber underscores about three
to one in `/usr/bin`. Python files use underscores because `check_palette.py` does
`import generate_theme`, and a module name cannot contain a hyphen.

## The management scripts

All three resolve their `.conf` files from the script's own location (`SCRIPT_DIR`),
so they work from any directory. Do not reintroduce cwd-relative paths: that
previously made the README's own `./scripts/install-packages.sh install` abort with
"Configuration file not found" and drop a stray log in the repo root.

### `backup-configs.sh [init|add|install|uninstall|check|backups|restore] [--dry-run] [--force] [--verbose]`

- `add` moves each path in `config_files.conf` out of `$HOME` into this repo,
  preserving directory contents via rsync with `--remove-source-files`, backs the
  original up into `~/.dotfiles_backup/<timestamp>/` first, then symlinks the `$HOME`
  path at the repo path. **This is destructive to the original location.** Treat it as
  a one-way move and always confirm before running it against a real `$HOME`.
- `install` symlinks repo files into `$HOME` with `ln -snf`, skipping any target that
  already exists as a real file unless `--force` is passed, in which case the
  existing file is backed up first and then removed.
- `uninstall` is the inverse of `install`, and until the script audit there was none.
  It removes only the symlinks that point into this repo. A real file is left alone, a
  link pointing elsewhere is left alone, the repo is untouched, and the parent
  directories `install` created are deliberately not pruned, because `~/.config` is
  shared with every other application on the machine.
- `check` reports five states, not two: valid, wrong target, dangling, not linked,
  missing. It resolves the link rather than only comparing its text, so a link into a
  repo copy that has been deleted is reported rather than called valid. It exits
  non-zero unless every entry is correctly linked, which is what makes it usable as a
  gate. The two expected states on a fresh clone are warnings, not errors.
- `backups` lists the timestamps in `$BACKUP_DIR` with a file count each. `restore`
  needs one of them and refuses to run without it.
- `restore <timestamp>` rsyncs a prior backup back into `$HOME` with
  `--ignore-existing`, so it never clobbers. **That also means it cannot undo an
  install**: after one, every managed path exists as a symlink, the symlink counts as
  existing, and every file is skipped. Run `uninstall` first. It reports how many of how
  many files actually moved and returns non-zero when that is none.
- `init` runs `git init` in the repo and creates the directory skeleton. It is for
  starting a dotfiles repo from nothing, not for using this one, which is why the
  install path never mentions it.
- `--dry-run` must reach every destructive line, and once did not. `install --dry-run
  --force` ran `rm -rf "$target"` for real, because the guard sat around the linking
  block further down and not around the `$FORCE` branch that removes the original.
  `backup_file()` made it worse: written as `$DRY_RUN || rsync ... && log "Backup: ..."`
  it parses as `(A || B) && C`, so the simulation skipped the copy and printed the
  backup line anyway. The file was destroyed, no backup existed, and the output claimed
  both. When adding anything that writes or deletes here, guard it and then prove the
  guard with a throwaway `HOME=`, because this is the failure the flag exists to
  prevent. Simulated lines say `Simulate:` at INFO; only real ones say `Linked:` at
  SUCCESS, and keeping those two vocabularies apart is what makes a dry run readable.
  Both guards are proven by `scripts/tests/test-dotfiles.sh`, which is where that
  proof belongs rather than in this paragraph.
- `--verbose` prints the entries that are already correct, which are the boring
  majority: without it, `check` on a healthy tree is one summary line instead of one
  green line per tracked path, and `install` reports the unchanged entries as a count.
  It was parsed into a variable nothing read for as long as it existed, while this
  document told you to reach for it.
- **Every path must be below `$HOME`.** `repo_relative()` enforces it and the four
  inline copies of the prefix strip are gone. An entry that is not below `$HOME`
  stripped to nothing, which made the repo destination the repo root itself: a stray
  `~/` line in `config_files.conf` reached `rm -rf "$HOME/"`.
- **Check the exit status before the line that destroys the original.** `add` ran
  `rm -rf` after an unchecked `rsync` and `ln -sf` after an unchecked `mv`, and
  `install --force` ran `rm -rf` after an unchecked `backup_file`. All three reported
  SUCCESS. This is the same failure as the `--dry-run` one above wearing a different
  hat: acting on the result of a step nobody looked at.
- New dotfile: add the path to `config_files.conf`, then run `add`.

### `scripts/tests/test-dotfiles.sh`

Sandboxed cases over `backup-configs.sh`, the one script here that can damage a real
`$HOME`. Run it after touching that file. Each case gets its own `mktemp -d` with `HOME`, `DOTFILES_DIR`,
`BACKUP_DIR` and `CONFIG_FILE` pointed inside it, and `guard_sandbox()` aborts the whole
run with exit 99 if any of the four ever points outside, so it cannot touch a real home
directory.

Those four environment variables are also how *you* try any of this safely, and they
were documented nowhere before. They are in the script's `-h` output now.

The harness exists because the instruction to prove a guard with a throwaway `HOME=`
was prose, and three defects shipped in the simulation paths regardless. When you fix
something here, add the case first and watch it fail: on the run that introduced it, 10
of 16 cases failed against the code as it stood, and that is what made the fixes worth
believing.

### `install-packages.sh [preview|install|check|repos] [PACKAGE...] [--yes] [--no-color] [--log FILE]`

- Detects apt, pacman or dnf, unless `DEFAULT_PACKAGE_MANAGER` is set in the
  environment. That override was a plain assignment for a long time, so it could not be
  overridden and this line was untrue; setting it is how you exercise the apt or dnf
  path from an Arch machine.
- **A command is required.** A bare invocation used to default to `install` and put
  every package in `packages.conf` on the machine with sudo and no confirmation.
- Any command takes package names after it, so a few failures can be retried without
  reinstalling everything else. An unrecognised name exits 1.
- `install` distinguishes `Already present` from `Installed`. Every installer here
  exits 0 when there is nothing to do, so a second run used to report the whole list as
  freshly installed. Hooks fire only on a real install, not on a re-run.
- Both scripts send `ERROR` and `WARNING` to stderr and blank their colours when stdout
  is not a terminal.
- In `packages.conf`, keys under `[common]` apply to every distro. A same-named key
  under `[apt]`, `[pacman]` or `[dnf]` overrides the package name passed to that
  distro's installer (`key=value`; a bare `key` means the name is identical
  everywhere).
- `[hooks]`: `<package-key> = <shell command>` runs immediately after that package
  installs successfully. Matched via awk against the common name, not the
  distro-specific one.
- `install` needs sudo. It prompts unless `--yes`, in which case it errors out rather
  than hanging on a password prompt.
- On pacman, anything missing from the official repos falls back to an AUR helper
  (`paru`, `yay`, `pikaur`). `catnap` and `pipes.sh` have no official-repo version.
  `pfetch-rs` usually needs the AUR too, though a repo that rebuilds AUR packages, as
  CachyOS does, may carry it. Note also that `pfetch-rs` *provides* `pfetch`, so
  declaring the bare name would let the helper pick either package.
- Logs to `scripts/package_install.log`, overwritten each run and gitignored.
- Section headers are skipped by a `next` in the awk block. Remove it and the literal
  lines `[common]` and `[pacman]` get parsed as package names.

### How far the audit of these scripts actually went

These two are the only code here that can damage a real `$HOME`, so they were audited
by four reviewers with different lenses. `shellcheck` was run for the first time, and
the correctness pass reproduced every defect in a throwaway `HOME=` before reporting
it. Twenty-six were found; the fixes are above and in the git history, and
`scripts/tests/test-dotfiles.sh` holds them fixed.

What was never executed, so nobody reads that number as broader than it is:

- Nothing touching `sudo`, `apt`, `pacman -Syy` or `dnf`. `add_repos` and
  `update_pkg_db` are reasoned from reading alone, including an unchecked
  `wget | gpg | tee` that writes an empty repository key when the download fails and
  leaves every later `apt-get update` broken.
- `run_hooks` was analysed by running its awk program standalone. Its `system()` call
  was never allowed to execute anything.
- Everything ran on one CachyOS machine, so only the pacman branches met a real
  package manager. `install_fonts` and `init_dotfiles` were read and not run.
- Two runs sharing a `$TIMESTAMP`, and behaviour under an empty `$HOME`, were reasoned
  about rather than reproduced.

## Config architecture notes

### Compositors and the bar

- **Hyprland is native Lua config** (Hyprland >= 0.55). The entry point is
  `hyprland.lua`, which `require()`s `conf/*.lua` in an order that matters:
  `programs` loads first because it defines globals that `binds` reads. Hyprland
  prefers `hyprland.lua` over `hyprland.conf` when both exist, which is why the old
  entry point sat inert for months while looking entirely alive.
- **Only `hyprland.lua` is Lua. The other three files in `.config/hypr/` are
  hyprlang**: `hypridle.conf`, `hyprpaper.conf` and `hyprtoolkit.conf`. Only Hyprland
  itself gained a Lua config in 0.55; hypridle, hyprlock and hyprtoolkit still read
  hyprlang. Do not port any of them to the syntax `conf/*.lua` uses.
- **Waybar is one config split three ways, not three configs.** `common.jsonc` holds
  the bar geometry and every module definition; `hyprland.jsonc` and `sway.jsonc`
  each `include` it and add only their own compositor's `modules-left`; `style.css`
  is shared. Both compositors launch it with explicit `-c` and `-s`, so there is no
  default-path config and bare `waybar` will not start. This replaced three drifting
  copies that had silently diverged, so anything shared belongs in `common.jsonc`.
- Before trusting a hardcoded battery or backlight name, check
  `ls /sys/class/power_supply/` and `ls /sys/class/backlight/`. A previous config
  carried a `battery#bat2` module pointed at a battery this machine does not have.
- **The `-e3` on the brightness keys is load-bearing.** Without it brightnessctl's
  percentage is a linear fraction of the raw backlight value, and raw value tracks
  luminance while perceived lightness follows the cube root in CIE L\*. Measured on
  this machine's `amdgpu_bl2`, whose maximum is 62451, with 5% steps: the press from
  0 to 5% moves 26.72 L\* and the press from 95 to 100% moves 1.97, so the darkest
  press is 13.6 times the brightest one. `-e3` makes the percentage the perceptual
  axis instead, `raw = max * (p/100)^3`, which cancels that cube root exactly and
  leaves every press worth 5.80 L\*. It applies to the deltas the keys actually use
  and not only to an absolute `set`: from 62451, `-e3 s 5%-` returns 53544, which is
  `max * 0.95^3`, against 59328 without the flag. Both compositors carry these binds,
  so both change together. Two things this rests on. The exponent is a plain power
  law, so it matches L\* above the toe and not below it, which is why the bottom four
  presses land under 1% of maximum. And `raw` is assumed proportional to panel
  luminance, which nothing here has measured with a photometer, so the curve is right
  for the driver and only probably right for the glass.
- **`brightnessctl -n` takes a raw value and silently ignores a percent sign.**
  `-n5%` sets the floor to 5, not to 5% of maximum, and the value has to be attached
  to the flag: `-n 5` is parsed as a positional and turns the command into `info`,
  which reports the current state and writes nothing, so a wrong invocation looks
  like a working one. A raw floor is also specific to one panel's maximum, so it does
  not belong in a repository that gets cloned onto other machines.
- **Waybar's `hyprland/workspaces` buttons do not respond to clicks** in waybar
  0.15.0, and it is not a config fault: it fails with the stock stylesheet, on either
  layer, with either `persistent-workspaces` form, and explicit `on-click` probes
  never fire while hover works. The full elimination is in [`TODO.md`](TODO.md). Do
  not re-derive it.
- **The session environment exists twice and has to be changed twice.** Sway has no
  `env` directive: `man 5 sway` has none, and an `exec` line cannot change its parent's
  environment. So the variables live in `.config/environment.d/50-voidashi.conf`, which
  `systemd --user` reads at login and Sway therefore inherits. Hyprland sets the same
  values in `conf/env_vars.lua` and propagates them into the systemd and D-Bus
  environment itself, so under Hyprland they arrive twice, harmlessly. Change one file
  and you must change the other. The variable that matters most is
  `QT_QPA_PLATFORMTHEME=kde`; without it Qt applications come up light against a dark
  desktop, which is what happened under Sway for as long as only Hyprland set it. Note
  the caveat in that file's header: a compositor started from a bare TTY in a session
  systemd does not manage gets nothing from it.
- **The idle schedule exists twice and has to be changed twice.** `hypridle` reads
  `.config/hypr/hypridle.conf`; `swayidle` has no config file at all and takes its
  whole schedule as CLI arguments in `.config/sway/config`. Both carry the same three
  timeouts, and the middle one is the lock's plus sixty seconds on purpose, so that
  the screen blanks after the lock rather than with it: move one and the other has to
  move too. They reach the locker differently: hypridle fires `loginctl lock-session`,
  which routes every request through its own `lock_cmd`, while swayidle calls
  `swaylock -f` directly. Changing how the screen locks therefore means editing both.
- **hypridle runs under `systemd-cat -t hypridle`**, so `journalctl -t hypridle` shows
  every timeout with a time. It writes only to stdout, and launched bare from
  `autostart.lua` nothing captured that: a night of unexplained locks had to be
  reconstructed from suspend and PAM lines in the journal because not one of them had
  left a record. Do not drop the wrapper to tidy the line.
- **No lid event locks the screen, and none should.** Closing the lid makes
  `systemd-logind` suspend, which is its default (`HandleLidSwitch=suspend`) and which
  this repo neither sets nor may depend on, and hypridle's
  `before_sleep_cmd = loginctl lock-session` locks on the way down. Sway has no lid
  bind at all; `binds.lua` keeps only the two that disable and restore `eDP-1`. A
  `swaylock -f` on `switch:Lid Switch` used to sit beside them and was removed for two
  reasons. It was the second of two paths to the same locked screen. And a bare
  `switch:` bind is never one-directional: Hyprland's `InputManager.cpp` calls
  `onSwitchEvent(NAME)` unconditionally and only then dispatches `onSwitchOnEvent` or
  `onSwitchOffEvent`, so that bind ran on **opening** the lid as well as on closing it.

### Neovim

- Uses lazy.nvim. `init.lua` -> `lua/voidashi/lazy.lua` bootstraps plugins declared
  as individual files under `lua/voidashi/plugins/`, each returning a spec table.
  `lazy-lock.json` pins versions; let lazy.nvim regenerate it rather than editing it.
- **A subdirectory of `plugins/` is only imported if it contains `init.lua`** (see
  `lazy/core/util.lua` -> `lsmod`, which scans top-level `*.lua` plus
  `<dir>/init.lua`). `plugins/lsp/` once held `lspconfig.lua` and `mason.lua` with no
  `init.lua`, so the entire LSP stack was never installed: no error, just no LSP. If
  plugins in a subdirectory appear to do nothing, check this first.
- LSP uses the native `vim.lsp.config()` and `vim.lsp.enable()` API (nvim 0.11+),
  not `lspconfig[server].setup{}`; `mason-lspconfig`'s `setup_handlers()` was removed
  in v2. The server list is declared once in `plugins/lsp/init.lua` and shared by
  mason's `ensure_installed` and `vim.lsp.enable`.
- **nvim-treesitter tracks the `main` branch**, where
  `require("nvim-treesitter.configs")` does not exist. Highlighting starts from a
  `FileType` autocmd calling `vim.treesitter.start()`. Parser names and filetypes are
  separate lists because they differ (`tsx` -> `typescriptreact`; `markdown_inline`
  is not a filetype). Building parsers needs the `tree-sitter` CLI, and most servers
  and formatters need `node` and `npm`; all three are in `packages.conf`.
- Format on save belongs to conform.nvim only. Adding an LSP format-on-save autocmd
  as well formats every file twice.
- **The colorscheme is ours, not a plugin**, in three layers under
  `lua/voidashi/theme/`: `palette.lua` (generated), `roles.lua` (the semantic layer,
  hand-written, where the design decisions live) and `groups.lua` (the highlight
  groups, which read only from roles). Two entry points make it discoverable and
  neither is obvious: `colors/voidashi.lua` is what `:colorscheme voidashi` finds, and
  `lua/lualine/themes/voidashi.lua` is how lualine finds its matching theme, because
  lualine looks up that path on the runtimepath. kanagawa stays in the plugin list with
  `enabled = false`, purely as a rollback. A standalone theme has no fallback underneath
  it, so when adding a plugin, check for groups falling through to Neovim's defaults;
  the gap is found by diffing group names against another theme's coverage.

### Fish

- `config.fish` is the entry point, and `conf.d/*.fish` autoload, which is where the
  colorscheme, theme and keybinding files are split out. `conf.d` loads
  **alphabetically**, and that has bitten this repo: a file fish generated during a
  version upgrade defined more colour variables than ours did and won, leaving twelve
  on factory values for an entire retheme.
- `fish_variables` is fish's own generated state file. Do not hand-edit it. It is
  tracked, so it will show up in `git diff` after fish writes to it.
- The greeter is a `fish_greeting` function in `config.fish` that runs fastfetch with
  an explicit `--config`. Two other fetches sit commented out beside it.

### GTK and Qt

- **Qt and KDE theming goes through `.config/kdeglobals`, and
  `QT_QPA_PLATFORMTHEME` must be `kde`.** Most Qt applications here are KDE ones and
  read their palette from kdeglobals; the ones that are not, VLC among them, get the
  same palette through `KDEPlasmaPlatformTheme6.so` from `plasma-integration`, which
  is the package that makes the variable mean anything. Without it the variable is
  set and nothing honours it, with no error. `generate_theme.py` merges only the
  `[Colors:*]`, `[WM]` and `[ColorEffects:*]` sections, and sets the font keys one by
  one, because they sit in `[General]` beside keys that are none of our business.
- **The font weight in kdeglobals is Qt's 0-99 scale, not the CSS one.** Writing
  `500` does not fail; it clamps and renders as Black. `57` is the Medium that 500
  means.
- **GTK theming lives in `.config/gtk-3.0/` and `.config/gtk-4.0/`**, and only
  individual files there are tracked (`gtk.css`, `settings.ini`, `voidashi.css`). The
  rest is written by `kde-gtk-config` and deliberately untracked; our `gtk.css`
  imports theirs first and ours last, so ours wins.
- **On GTK 4.16+ the accent colour only answers to CSS custom properties.** Setting
  `@define-color accent_bg_color` does nothing on GTK 4.22. Surfaces still honour
  `@define-color`, which makes this easy to misdiagnose, because half the file
  appears to work. The generator emits both forms.
- **GTK3 CSS rejects 8-digit hex colours** (`#RRGGBBAA`) on the `color` property:
  "Junk at end of value for color" on every launch. Use 6-digit hex or `rgba()`.
- **The GTK `settings.ini` files are written by KDE, not by hand.** `kded6` is
  D-Bus activated, so it starts on any KDE application launch, and its `gtkconfig`
  module copies KDE's font, icon theme, cursor and toolbar settings into both
  `settings.ini` files. It wins every contest with hand-edited values. Disabling it
  does not work: `[Module-gtkconfig] autoload=false` in `kdedrc` is read and ignored,
  because the module is also `load-on-demand`. So the source of truth for GTK's font,
  icons and cursor is `kdeglobals` and `kcminputrc`, both generated, and `gtkconfig`
  copies them across. Two consequences: it writes only when a value differs, so the
  symlinks survive once the values agree, and `gtk-theme-name` is not a key it
  manages, so `adw-gtk3-dark` is preserved. Comments in those files never survive.
- **KDE's writes replace symlinks with real files.** `gtkconfig` rewrites `gtk.css`
  on every start even when the content is unchanged, and the rename-over-target
  lands a real file where the symlink was. `backup-configs.sh check` catches it and
  `backup-configs.sh install --force` repairs it, safely, because the content is
  preserved byte for byte apart from the trailing newline. `kdeglobals` and
  `kcminputrc` are unaffected, since KConfig writes those through the link.
- **`nwg-look` rewrites `.config/gtk-3.0/settings.ini` and gsettings.** That file is
  a symlink into this repo, so its edits land in the working tree; check `git diff`
  after using it. It does not touch `gtk.css`, so the palette survives.

### Everything else

- **Two terminal emulators too many is the point.** Ghostty, Alacritty, Kitty and
  Foot are configured in parallel, as are both compositors. When changing shared
  theming, check whether it needs mirroring rather than assuming one canonical
  source. This rule went unenforced for an entire retheme: Sway kept its stock
  colours until `check_palette.py` surfaced it. Run the checker rather than trusting
  the rule.
- **wofi cannot `@import` the shared theme partial.** It hands its stylesheet to GTK
  as a string, so relative import URLs resolve against the *process cwd* (`$HOME`
  when launched from a keybind) rather than the CSS file's directory. The symptom is
  `Failed to import: Error opening file /home/theme/voidashi-colors.css` and no
  colours at all, with every path and symlink correct. `generate_theme.py` therefore
  inlines the palette into `.config/wofi/style.css` between
  `/* >>> VOIDASHI COLORS (GENERATED) >>> */` markers. Edit outside them freely,
  never inside.
- **The three merged files went unchecked because they carry no `GENERATED`
  header.** `check_sync` compared whole files against the generator's output, so
  `.config/wofi/style.css`, `kdeglobals` and `kcminputrc` were outside it: an edit
  was made in each and the checker returned 0 for all three. It now merges again
  and compares, which reports any difference in a section the generator owns while
  leaving everything else alone, both measured. Adding a fourth merged file means
  adding it to `merged_files()` in `generate_theme.py`, which is the one list both
  the generator and the checker read.
- **The lock screen is plain `swaylock`, not `swaylock-effects`,** and its config was
  originally written for the latter. Seven options were unknown to the installed
  binary: `screenshots`, `effect-blur`, `effect-vignette`, `indicator`, `clock`,
  `timestr`, `datestr`. That mattered because `screenshots` was the only thing
  setting a background, so with no `color=` line the lock screen came up in
  swaylock's own default light grey while all 28 of its colours were correct. Diff
  any new option against `swaylock --help`: the binary ignores what it does not know
  and says nothing. Also never wrap it in a script passing the same options as CLI
  flags, because flags override the config file, which is how the committed theme
  silently stopped applying once before.
- **wlogout is the opposite case and does need its wrapper.**
  `scripts/wm/power-menu.sh` is the only place its geometry exists: wlogout reads
  actions from `.config/wlogout/layout` and colours from `style.css`, but
  buttons-per-row, spacing and margins are CLI-only. The wrapper derives margins from
  the focused output's real resolution, so the centred column holds its proportions
  on any screen. Launch the menu through it, never `wlogout` bare. Note also that
  wlogout renders each label on a single line: a `\n` in the layout's `text` arrives
  as a visible control-character box.
- **Clipboard history is `cliphist` over `wl-clipboard`, and the picker is a
  script.** `scripts/wm/clipboard-picker.sh` holds the whole pipeline because both
  compositors need exactly the same one. `wl-paste --watch cliphist store` in both
  autostarts is the only thing that feeds the history, so without it the keybind
  opens a permanently empty menu. The leading id in `cliphist list` output is hidden
  with wofi's `--pre-display-cmd`, which changes only what is drawn and never what is
  returned, so a badly quoted entry can draw wrong but can never paste the wrong
  thing.
- **The clipboard history does not expire on its own, which is why both autostarts
  wipe it.** `cliphist`'s store is a plain file at `~/.cache/cliphist/db` and nothing
  in it is time-based: the only thing that ever removes an entry is `-max-items`,
  which defaults to 750. Measured before the wipe existed: the db had been created
  four boots earlier, `journalctl --list-boots` confirmed the reboots, index 1 was
  still the last line of `cliphist list`, and 40 entries sat well under the cap, so
  the oldest thing ever copied into that db was still offerable to the picker two
  days later. The autostarts now run `sh -c 'cliphist wipe; exec wl-paste --watch
  cliphist store'`, one shell so the wipe cannot land after the watcher. Two things
  to know before changing it. This clears at **session start, not at boot**, so a
  logout and back in clears it too, and a machine left logged in for a week keeps a
  week of history. And `cliphist wipe` does remove the plaintext rather than only
  unlinking the index: a canary string stored into a throwaway db was findable with
  `grep -a` and `strings` before the wipe and by neither afterwards, though that says
  nothing about blocks already freed on the filesystem underneath.
- **`hyprctl dispatch` takes Lua in Hyprland 0.56, and the old syntax fails loudly
  enough to be mistaken for something else.** `hyprctl dispatch exec "touch /tmp/x"`
  returns a Lua parse error and spawns nothing; the working form is
  `hyprctl dispatch 'hl.dsp.exec_cmd("touch /tmp/x")'`, with the same `hl.` prefix
  the config files use. Verified in passing that this path goes through a shell and
  survives nested quoting, which is what makes the `sh -c '...'` autostart line above
  safe.
- **Wallpapers:** `scripts/wm/select-random-wallpaper.sh` takes a list of directories
  and uses the first one that contains images. It must print errors to **stderr**,
  because callers embed it in `$(...)` and pass the result to `swaybg` as a filename.
- **Nerd Font glyphs: verify a codepoint before trusting it.** Nerd Fonts v3 removed
  the old `nf-mdi-*` range, so a glyph copied from any pre-v3 config silently falls
  back to another font and renders as a box. Four had been sitting in the waybar
  config that way, the battery-charging icon among them. Check with
  `fc-list ":charset=<hex>" family | grep -i "hack nerd"`, which prints nothing when
  the glyph is absent. Font Awesome codepoints (`f0xx` to `f2xx`) are the safe range.
- **fastfetch colours must be hex, never ANSI codes.** It accepts both, and
  `38;2;180;73;85` is the same colour as `#b44955` and invisible to
  `check_palette.py`. Ten configs live under `.config/fastfetch/`. Set
  `display.percent.type` to `["num"]` on the short ones: the default is `9`, a
  *coloured* number, which tints by threshold and puts an accent on screen at rest.
- **catnap cannot do hex, and its config format is one upstream release from being
  deleted.** Writing `#b44955` in `config.toml` prints the literal string. The whole
  vocabulary is seven tokens and anything unrecognised silently becomes a reset:
  `(RD)`->31, `(YW)`->33, `(BE)`->34, `(GN)`->32, `(MA)`->35, `(CN)`->36, `(BK)`->30.
  Those are ANSI slots and the ANSI table is the palette, so catnap cannot drift
  off-palette; what it cannot reach is a specific level. Separately, catnap 2.0
  replaced TOML with a `.cat` language and upstream says `config.toml` and
  `distros.toml` are not compatible with v2. **The installed version is already
  2.1.1**, not the 1.1.1 this note used to claim, and the tracked `config.toml` is
  still not rejected by it. Whether it is still honoured is unmeasured, and that is
  the open question in `TODO.md`. Two things about validating it, both learned the
  hard way: catnap has no flag for `distros.toml`, so that file is checked by
  nothing, and catnap never exits when its stdout is not a terminal, so its exit
  code is only readable as a rejection.
- **A colour is written five ways here, and `check_palette.py` used to see one of
  them.** Its regex wants `#RRGGBB`, so every application that writes colour some
  other way was unchecked: swaylock's `ring-color=393835`, fish's bare hex,
  hyprland's `rgb(498bb2)`, the `rgb(73, 139, 178)` in swaync's and wlogout's
  stylesheets, and the `73,139,178` triplets in `kdeglobals`. Six files had no
  colour reachable at all, and an auditor swapped hyprtoolkit's `accent_secondary`,
  the identity mark, for `rgb(ff00ff)` without the checker noticing. The `FORMS`
  table now carries one entry per form, each scoped to the paths where that form is
  unambiguously an applied colour. Two rules when adding to it. Scope it rather than
  loosening a regex, because six hex digits are a commit hash and a decimal triple
  is a version number anywhere else. And keep documentation outside every scope, or
  a sentinel quoted in `TODO.md` gets reported as drift.
- **The session is declared here but cannot be managed here.** `greetd` and
  `greetd-tuigreet` are in `packages.conf`, but what makes them do anything is
  `/etc/greetd/config.toml` plus `systemctl enable greetd.service`, both root-owned and
  outside `$HOME`. `backup-configs.sh` tracks nothing there and `check` cannot report a
  file it was never given, so a clone that installs cleanly and passes every validator
  in this document can still boot to a text console. That is the one gap the validator
  battery does not cover. Two consequences when editing this: enabling greetd on a
  machine that already has a display manager conflicts with it over the
  `display-manager.service` alias, so the packages are declared with a comment saying to
  drop them in that case; and the greetd path is a recommendation rather than something
  exercised here, because this machine runs `plasmalogin`. Verified locally is only that
  both packages exist in `extra` and that `hyprland.desktop` and `sway.desktop` are
  installed into `/usr/share/wayland-sessions/` by the compositors themselves.
- **Configs kept on purpose, not leftovers.** Several configs here belong to programs
  that are not in use, and treating one as dead weight is a mistake this repository has
  already watched an audit make. The complete list, and which file decides in each case,
  is in [`TURNING-POINTS.md`](TURNING-POINTS.md), which owns it. These decisions are
  settled.

## Validating a change

Run the whole battery before calling anything done:

```bash
./scripts/verify.sh
```

It runs every check named in this section plus two nothing else runs, the sandboxed
tests and the gitlink guard, prints each command with what it returned, and exits
non-zero if any failed. A check whose tool is not installed is skipped rather than
failed, since no machine has all four terminals and both compositors. The rest of this
section is why each check exists and how to read it, which is the part a script cannot
carry. Run one by hand when you want only that one.

After any colour change, on its own:

```bash
python3 scripts/theme/check_palette.py
```

It fails on four things: a hex in a tracked config that is not in `palette.json`; a
**named** terminal colour (`green`, `brwhite`, `cyan`) inside fish or starship
config; bare hex with no `#` in the swaylock config; and a `GENERATED` file that no
longer matches what the generator would produce, which is how a hand-edit to
generated output gets caught. The named-colour check exists because twelve fish
variables sat on stock names for an entire retheme while the hex-only check passed
clean. Names are searched only in fish and starship, since words like "red" appear in
prose everywhere else, and comments are stripped first so a colour discussed is not a
colour applied. Deliberate exceptions are listed in the script with their reason, so a
decided exception does not become permanent noise.

It walks the whole repository, not just `.config/`, so **a hex written in prose is a hex
it checks**. Quoting an off-palette colour in a document to illustrate something, an
example value, a before-and-after, a colour from someone else's theme, fails the drift
check with the document named as the offender. Describe the change instead of pasting
the value, or you will fail your own validator with a sentence.

Most of the applications here can check their own config, which beats reading them by
eye:

```bash
hyprctl configerrors                      # empty means clean
sway --validate -c .config/sway/config
foot --check-config -c .config/foot/foot.ini
ghostty +validate-config --config-file=.config/ghostty/config
alacritty migrate --dry-run -c <file>     # flags deprecated syntax
kitty +runpy "from kitty.config import load_config; bad=[]; load_config('.config/kitty/kitty.conf', accumulate_bad_lines=bad); print(bad)"
waybar -c <config> -s <style>             # warns about unknown modules
nvim --headless "+checkhealth vim.deprecated" +qa
```

kitty prints `[]` when clean; anything else is the list of bad lines. Its
`--debug-config` flag no longer exists, gone by 0.48.1. For Neovim, a lazy-loaded
plugin does not surface its deprecations until it is actually loaded, so run the
relevant command first or the all-clear is false.

The fetches and the symlinks need a loop rather than a single command:

```bash
# every fastfetch config parses
cd .config/fastfetch && for f in config.jsonc */config.jsonc minimal/*.jsonc; do
  out=$(fastfetch --pipe true -c "$f" 2>&1 >/dev/null); [ -n "$out" ] && echo "$f: $out"
done

# catnap: exit 1 means it rejected the config. It never exits when stdout is not a
# terminal, so the timeout is the pass, and there is no flag for distros.toml.
timeout 5 catnap -n -c .config/catnap/config.toml >/dev/null 2>&1; echo $?

# every tracked path is still a symlink into the repo
./scripts/backup-configs.sh check
```

`check` prints its own totals and exits non-zero unless everything is valid, so read
those rather than counting lines. The one thing worth knowing is that the total is the
number of paths in `scripts/config_files.conf` **plus one**: `check_dotfiles()` also
checks the font symlink at `~/.local/share/fonts/dotfiles`, which is not listed in that
file. If the total looks wrong, that off-by-one is the first thing to rule out.
A broken link usually means an external program replaced it with a real file,
which `kded6` has done to `gtk.css` before; re-link with `install --force`, but look
at the content first, because the same event has also overwritten what the repo held.

The gitlink guard is in the battery for a reason worth knowing, because the failure it
catches is silent and arrives through a merge:

```bash
git ls-files -s | grep '^160000'   # expect no output
```

A worktree under `.claude/` was swept into the index once as a gitlink, removed on
purpose by `5ab0358`, and then restored by a merge that kept the other side of the
history. `.gitignore` cannot prevent the recurrence, because git ignores nothing for a
path that is already tracked, which is why this is a check rather than a rule. Prose had
failed at it twice before the check existed.
