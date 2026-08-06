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
  `[pacman]` and `[dnf]` sections.
- `scripts/wm/`: helpers the compositors call *while running*, as opposed to the
  top-level scripts, which you run yourself. `backup-configs.sh install` links each of
  them into `~/.local/bin`, so the configs call them by bare name.
- `scripts/theme/`: three layers, the same three the editor's theme has.
  `palette.json` holds values and nothing else; `roles.py` holds decisions, naming a
  token for each thing a colour is used for; `generate_theme.py` renders those into
  each application's own format; `check_palette.py` proves nothing drifted. Rerun the
  generator after editing either of the first two, and never hand-edit its output.
  **Change a colour in `palette.json`, change what a colour is for in `roles.py`.**
  A hex written into `roles.py` is refused at load, because a role that carries its
  own value is a second source of truth and is exactly the bug the layer ends.
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

### `backup-configs.sh [init|add|install|uninstall|check|backups|restore] [PATH...] [--dry-run] [--force] [--verbose] [--no-color]`

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
- `add`, `install`, `uninstall` and `check` take paths and act on those alone, the way
  `install-packages.sh` takes `[PACKAGE...]`. Both narrow a list once and then forget
  the filter existed: there it is `apply_package_filter` over `PACKAGE_ORDER`, here
  `apply_dotfile_filter` over `DOTFILE_ENTRIES`, which the four loops read instead of
  the config file. The one place they differ is where the arguments are taken, the
  parser there and the dispatch here, and that is forced: the command has to come off
  the front before what is left can be read as paths, or `restore` loses its timestamp
  to the filter. Four behaviours are load-bearing and each has a case in
  `scripts/tests/test-dotfiles.sh`, each proven by breaking it and watching exactly one
  case notice. An unrecognised path stops the whole run rather than acting on the ones
  it understood, because a partial run ends in a summary about a set nobody asked for,
  and one of these commands removes things. A path inside a tracked directory is
  rejected naming the entry that covers it, since `install` links a directory whole and
  there is nothing it could do with one file inside. Redundant slashes are squeezed
  before any comparison, because without that `~/.config/kitty//` is refused with an
  explanation that it sits inside itself. And `fonts/`, `wallpapers/` and the
  `scripts/wm/` helpers are not in `config_files.conf`, so no argument can name one and
  a filtered run leaves them alone in install, uninstall and check alike; a filtered
  `check` that audited them would fail over something the caller never mentioned.
  `FILTERED` is the one question those three ask, so the next thing that changes what
  "the caller narrowed the set" means edits one place.
- **The repo-root links are one list, `extra_links()`.** Those three sit at the repo
  root rather than mirroring a `$HOME` path, so `install_dotfiles` cannot carry them and
  each needs a symlink of its own: `fonts/` and `wallpapers/` under
  `~/.local/share/<name>/dotfiles`, and every `scripts/wm/*.sh` into `~/.local/bin`.
  install, uninstall and check read that one function, so a fourth is one edit. The
  helpers land on PATH so the compositors and the bar can call them by bare name, which
  is what stops the clone directory being load-bearing; see `TURNING-POINTS.md`.
  `uninstall` removes one only after `readlink` says it points into the repo, which
  matters most in `~/.local/bin`, shared with everything else the user installs.
- `--except PATH` is the filter's other direction: everything but the entries it names.
  It is path-typed like the filter, reusing `match_entry` and its two error sentences
  rather than growing a vocabulary, which is why it is a flag over paths and not a
  section marker in `config_files.conf`. One flag per path, because a greedy `--except`
  could not tell its own arguments from the positional paths that follow. **It must not
  set `FILTERED`.** That flag answers "did the caller name the set they wanted", and it
  is what keeps `fonts/` out of a filtered run; someone asking for all of it except
  `kdeglobals` is asking for the rest, the repo-root links included. Exclusions are
  applied before the
  positional filter so both are validated against the whole config file, which is why a
  path named and excluded in one run gets its own error instead of being reported absent
  from a file it is written in. Excluding every entry is refused, because a run with
  nothing to do prints a summary that reads like one that worked.
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

### `install-packages.sh [install|check|repos] [PACKAGE...] [--dry-run] [--yes] [--no-color] [--verbose] [--log FILE]`

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
  freshly installed.
- Both scripts send `ERROR` and `WARNING` to stderr and blank their colours when stdout
  is not a terminal.
- In `packages.conf`, keys under `[common]` apply to every distro. A same-named key
  under `[apt]`, `[pacman]` or `[dnf]` overrides the package name passed to that
  distro's installer (`key=value`; a bare `key` means the name is identical
  everywhere). `[apt]` and `[dnf]` carry the names that differ, read out of the
  distributions' own indexes; `[pacman]` is empty because `[common]` is already
  written in Arch names.
- **An override can only rename, never skip.** `${value:-$key}` makes an empty value
  fall back to the key, so there is no way to write "this distro has no such package".
  Where one has none, `packages.conf` says so in a comment and the install still tries
  it and fails. Hyprland is the head of both lists, so an apt or dnf run installs the
  Sway half of this desktop and none of the Hyprland half. If that ever needs to be a
  behaviour rather than a comment, it is a change to `load_packages`, and the sentinel
  has to be something an empty value is not.
- `install` needs sudo. It prompts unless `--yes`, in which case it errors out rather
  than hanging on a password prompt.
- **The rehearsal is `--dry-run` on both scripts.** It was `preview`, a command, on this
  one, and the README printed both spellings in a single code block. The flag is the
  shape that survives, because it composes: `install --dry-run` lists what is configured
  and `repos --dry-run` names the repository steps, where a command could only ever
  rehearse whichever one it was written for. Typing `preview` now reaches the
  unknown-command branch, which names the flag that replaced it rather than printing the
  command list and leaving the reader to spot what is missing.
- `install --dry-run` returns before `check_sudo` and before `add_repos`, and
  `repos --dry-run` skips the sudo check the same way, so no rehearsal asks for a
  password, reaches the network or writes outside `$HOME`.
- **Three flags are on one script and not the other, and each arises from the job.**
  `--force` only means something where there is a real file to replace, `--yes` only
  where there is sudo to prompt for, `--log FILE` only where a log is written. The four
  that mean the same thing on both are spelled the same on both: `--dry-run`,
  `--verbose`, `--no-color` and `-h`. Anything added to one from here answers that
  question first.
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
- Everything ran on one CachyOS machine, so only the pacman branches met a real
  package manager. `init_dotfiles` was read and not run, as was `install_fonts`, which
  is now `install_extras` and does have sandboxed cases.
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
- **hyprlang resolves a relative `source =` against the process cwd, not against
  the file that contains it,** and says nothing at all when the glob then finds no
  match. `hyprtoolkit.conf` therefore sources
  `~/.config/hypr/voidashi-toolkit-colors.conf` by absolute path. Measured with
  hyprlauncher on screen and the pixels sampled: started from any directory but
  `.config/hypr/`, a `./voidashi-toolkit-colors.conf` renders the toolkit's own
  default `181818` with an empty stderr, while the absolute form renders `191817`,
  which is `void-20`. Started *from* that directory the relative form works, which is
  how a broken path passes a hand test. This is wofi's `@import` failure in a second
  toolkit; the two are the same bug.
- **hyprtoolkit validates nothing it reads.** A colour key set to `notacolour` and a
  key that does not exist are both accepted in silence, inline and in a sourced file
  alike. So a hyprtoolkit config that loads without error is no evidence that any of
  it applied: the only thing an error proves is a path that failed to glob. The check
  is a screenshot. `hyprlauncher` is a layer-shell surface, so its geometry comes
  from `hyprctl layers` and never from `hyprctl clients`, and it fades in, so a
  capture taken the moment it appears samples a blend with whatever is behind it.
- **hyprtoolkit falls back to `$HOME/.config` when `XDG_CONFIG_HOME` holds no config
  of its own,** which quietly makes a throwaway config tree read the installed one.
  A control run needs both variables pointed away from `$HOME`, or it measures the
  real desktop while appearing to measure the copy.
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
- **`ColorScheme` in `[General]` is a name, and something reads it.** The colours are
  in kdeglobals and are painted whether or not the key is there, which is why it went
  missing without a symptom anyone would notice. What it changes is what reports the
  current scheme: measured under a throwaway `XDG_CONFIG_HOME` holding only this file,
  without the key `plasma-apply-colorscheme --list-schemes` marks BreezeLight as
  current while every window on screen is Voidashi, and with it the mark moves. That
  measurement covers one tool. The key itself lives in `libKF6ColorScheme`, which that
  tool links and so does every KDE application here, so a second reader is likely and
  is not established. It is set through the same key-by-key merge as the fonts. The
  other two keys
  of the scheme file's `[General]` stay out: `Name` is that file's own label, and
  `shadeSortColumn` is a sort setting rather than colour.
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
  leaving everything else alone, both measured. `starship.toml` was the fourth to
  join them. A merged file means one entry in `merged_files()` in
  `generate_theme.py`, which is the one list both the generator and the checker
  read.
- **The INI ones among those are compared by section and key, not by text**, and
  that is not fussiness. KConfig canonicalises `kdeglobals` whenever a KDE program
  writes to it, sorting sections and keys alphabetically, so a file nobody touched
  comes back reordered and the text comparison called it a hand-edit. It reached the
  repository that way once, swept into a commit about another file, and left the
  checker red until this was fixed: measured, same sections and not one key-value pair
  different. The cost of comparing this way is
  that any line which is neither a section header nor `key=value` is invisible to it,
  a comment among them. That is academic: KConfig discards exactly the same set on its
  next write, so nothing of the kind survives in either file to be checked.
  `generate_theme.py` asks the same question before writing and leaves the file alone
  when the answer is yes, printing `kept` instead of `wrote`. Without that the two
  orders take turns, and every KDE file dialog puts a diff of the whole file in the
  working tree. So a run of the generator that reports `kept` for these two is the
  normal outcome, not a sign it did nothing.
- **starship's generated palette table has to stay at the end of its file.**
  `[palettes.voidashi]` is a TOML table header, so every key below it belongs to
  that table until the next header: a module added underneath the markers becomes
  a palette entry and stops configuring anything. Nothing warns.
- **A starship style naming a colour that is not in that table renders with no
  colour and says nothing.** Only a missing table is reported, as `Could not find
  color palette`, and then the whole prompt loses its colours at once, which is the
  easy case. Measured with `ink-2` misspelt: the path segment came out with no
  escape sequence while every other segment kept its own. `check_palette.py` grew
  its `names` check for exactly this, because moving that file off pasted hex is
  what created the failure.
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
- **yazi renames theme keys and drops the old spelling without a word.** Six of ours
  named a schema it had already replaced: `mgr.hovered` and `mgr.preview_hovered` are
  `indicator.current` and `indicator.preview`, `mode.normal`, `select` and `unset` each
  split into a `_main` and an `_alt` half, and `confirm.content` is `confirm.body`. The
  ice-600 cursor fill and the bordeaux-300 mode badge were written, parsed, discarded,
  and painted zero times. Its online docs describe the current release and not the
  installed one, so diff against the default embedded in the binary:

  ```bash
  strings -n 4 /usr/bin/yazi | sed -n '/^#:schema.*theme\.json/,/^\[icon\]/p'
  ```

  The colours themselves live in a generated flavor, and `theme.toml` overrides it key
  by key rather than table by table, which is measured: the border glyph in `theme.toml`
  renders while every colour in the flavor's `[mgr]` still applies. A flavor named with
  no directory behind it fails loudly, which is the only reason a passing run means
  anything.
- **bottom rejects a bad colour and accepts a bad key, and cannot be checked without a
  terminal.** A value it cannot parse is a hard exit 1 naming the key,
  `Please update 'styles.widgets.border_colour' in your config file. 'notacolour' is an
  invalid named colour`, which is what makes a clean run worth something. A key that
  does not exist is accepted in silence and the program runs, the same shape as swaylock
  and hyprtoolkit. And `btm -C <file>` outside a terminal exits 1 with
  `No such device or address` whatever the config holds, so an exit status read from a
  pipe discriminates nothing; `scripts/theme/check_render.py` has the pty harness.
  Its whole `[styles]` tree is a generated block and the file says so.
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
  The last directory both compositors pass is `~/.local/share/wallpapers/dotfiles`,
  which `install` links at the repo's `wallpapers/`.
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
- **catnap reads `config.cat` and only that, and a `config.toml` beside it is
  inert.** The binary looks at `$XDG_CONFIG_HOME/catnap/config.cat` and then
  `/etc/catnap/config.cat`, and carries no TOML parser at all:
  `strings $(which catnap) | grep -i toml` returns nothing. The repository tracked
  a themed `config.toml` and `distros.toml` through the whole of the 2.x series
  while the fetch on screen was `/etc/catnap/config.cat` from the package, drawing
  the CachyOS logo in the cyan the guide reserves for ANSI slots 6 and 14. Nothing
  reported it, and the check that was supposed to was passing the dead file to a
  binary that could not read it.
- **Three things about the `.cat` language, each of which cost a run to find.**
  `import` resolves against the importing file's own directory, and a leading `/`
  is joined onto it rather than treated as absolute, so
  `import "/etc/catnap/distros.cat"` fails naming `.../catnap/etc/catnap/`; every
  import has to be a sibling. A variable set *after* an import wins over the
  import, which is why `config.cat` does not repeat upstream's
  `$border_color = $white`. And a stat missing a required field is a hard error
  naming the index, `$stats[16] (@colors) missing required field 'color'`, which
  is the one place catnap is loud.
- **catnap now reaches the palette exactly, and its keys match the fastfetch
  presets.** v2 takes hex, so `scripts/theme/generate_theme.py` writes
  `.config/catnap/themes/voidashi.cat` with the ANSI table and the role names the
  stat list uses. Under 1.x the vocabulary was seven ANSI tokens with no grey among
  them, which is why the keys sat at ink-2 while fastfetch used ink-4 for the same
  rows; that constraint is gone and the two fetches now agree.
- **`.config/catnap/distros.cat` is deliberately not a copy of upstream's.**
  Upstream ships 62 entries and 27KB of art; the diff against what this repository
  had actually changed was the cachy logo and the removal of an `arch_old` entry
  nothing selects. What the short file costs is that a machine whose distro is not
  listed gets no art. `catnap -g distro` says what would be detected, and the fix is
  to add an entry rather than to paste upstream's file back.
- **A colour is written five ways here, and `check_palette.py` used to see one of
  them.** Its regex wants `#RRGGBB`, so the other four went unchecked: bare hex, in
  swaylock's `ring-color=393835` and in fish, which had one scoped exception for
  swaylock alone; hyprland's `rgb(498bb2)`; the `rgb(73, 139, 178)` in swaync's and
  wlogout's stylesheets; and the `73,139,178` triplets in `kdeglobals`. Six files had no
  colour reachable at all, and an auditor swapped hyprtoolkit's `accent_secondary`,
  the identity mark, for `rgb(ff00ff)` without the checker noticing. The `FORMS`
  table now carries an entry per form and scope, each scoped to the paths where that
  form is unambiguously an applied colour, and comments are cut before matching so
  that a retired value recorded in one is not read as applied. Two rules when adding
  to it. Scope it rather than loosening a regex, because six hex digits are a commit
  hash and a decimal triple is a version number anywhere else. And keep documentation
  outside every scope, or a sentinel quoted in `TODO.md` gets reported as drift.
  The colour *names* have the same failure one level down: `NAMED_RE` wanted
  whitespace or `=` before the name, so `style = 'red'` passed while `style = 'bold
  red'` was reported, one space apart. Test a pattern against the quoted form too.
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

It fails on five things: a hex in a tracked config that is not in `palette.json`; a
**named** terminal colour (`green`, `brwhite`, `cyan`) inside fish or starship
config; bare hex with no `#` in the swaylock config; a `GENERATED` file that no
longer matches what the generator would produce, which is how a hand-edit to
generated output gets caught; and a role in `roles.py` holding a colour the palette
does not hold, which catches both a hex pasted in by hand and a token reference
mistyped into some other valid colour.

What it cannot ask is whether any of that was painted, and that is a different check:

```bash
python3 scripts/theme/check_render.py
```

It runs yazi and catnap under a pty and requires a short list of colours to appear in
the escapes they emit. Both were the reason it exists. yazi named six theme keys it
had renamed, so the cursor fill and the mode badge were written and drawn zero times;
catnap stopped reading its config format entirely, so a themed, checked, tracked file
was inert for a release. `check_palette.py` reported clean throughout both. Read its
scope narrowly: two applications, chosen because their overrides are matched by name
against something upstream owns and because they can be driven headless. Nothing here
covers the rest.

It prints every colour emitted, not only the ones it requires, and marks the ones the
palette does not hold. Those are expected rather than a fault: yazi paints its icon
glyphs from a table inside its own binary, which this repository does not override for
the reason in [`design/THEMING.md`](design/THEMING.md), and no tracked file carries
those hues, so `check_palette.py` cannot see them. A program with no such note printing
a colour outside the palette is the case worth looking at.

Three traps if you extend it. Set the window size on the pty with `TIOCSWINSZ`, not
through `LINES` and `COLUMNS`: yazi drew into an 0x0 terminal and emitted 764 bytes
with no colour in them, which is what a theme that failed to load also looks like.
Match colours in two stages, finding each SGR and then reading every colour inside it,
because both programs write foreground and background in one sequence and a single
anchored pattern silently counts only the first. And give the program a fixture whose
surroundings you control: yazi draws a parent pane, so browsing `mkdtemp()` directly
listed the machine's `/tmp` and painted an icon for everything in it. The output then
moved between runs on one machine and meant nothing across two, which is fatal for a
check whose whole output is the measurement. The fixture is nested one level down.

`check_palette.py` also warns, without failing, when an `ansi16` slot holds a hex no
scale and no alert tone does. That table is literal on purpose and is the one place a retired
colour can still hide inside the palette, where drift cannot see it: while a second
copy survives, the old hex is still a palette colour and no file left on it can be
reported. A half-finished hue swap looks exactly like this, so it is a warning and
not an error. The named-colour check exists because twelve fish
variables sat on stock names for an entire retheme while the hex-only check passed
clean. Names are searched only in fish and starship, since words like "red" appear in
prose everywhere else, and comments are stripped first so a colour discussed is not a
colour applied. Deliberate exceptions are listed in the script with their reason, so a
decided exception does not become permanent noise.

It walks what git would show you, tracked files plus untracked ones that `.gitignore`
does not cover, and not just `.config/`, so **a hex written in prose is a hex it
checks**, and so is a file you have not added yet. Quoting an off-palette colour in a document to illustrate something, an
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
alacritty --config-file <alacritty.toml, then the generated file> -e true  # a window each
alacritty migrate --dry-run -c <file>     # TOML syntax and migration needs only
kitty +runpy "from kitty.config import load_config; bad=[]; load_config('.config/kitty/kitty.conf', accumulate_bad_lines=bad); print(bad)"
waybar -c <config> -s <style>             # warns about unknown modules
nvim --headless "+checkhealth vim.deprecated" +qa
```

alacritty has no validate flag, and `migrate --dry-run` is not one wearing another
name: it fails on TOML that will not parse and accepts an invented key inside a real
section at exit 0, both measured. The command above is the only thing that reports
`Unused config key`, which is the failure that matters here, since a renamed key is
written and never painted.

Point it at both files, which is what `verify.sh` does. `alacritty.toml` reaches the
generated one only through its `~` import, and that resolves into `$HOME`: with `HOME`
pointed at a directory holding no `.config/alacritty`, the import finds nothing,
alacritty says nothing, and the check prints an empty pass for a file it never opened.
Measured, with an invented key sitting in the generated file throughout. Naming the
generated file directly costs one more window and covers it whatever `$HOME` holds. It
opens a real window for each, because alacritty parses nothing without one, so a
machine with no display is a skip rather than a pass, and the run is under a `timeout`
so a stalled client is reported instead of passing on empty output.

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

# catnap: not "does it parse" but "did the palette arrive". bordeaux-400 is the
# username, the hostname and the logo, and it lands there only if config.cat, the
# generated theme and distros.cat all resolved.
timeout 5 catnap -n -c .config/catnap/config.cat 2>&1 | grep -c "38;2;180;73;85"

# every tracked path is still a symlink into the repo
./scripts/backup-configs.sh check
```

`check` prints its own totals and exits non-zero unless everything is valid, so read
those rather than counting lines. The one thing worth knowing is that the total is the
number of paths in `scripts/config_files.conf` **plus the repo-root links**, which are
not listed in that file: the fonts and wallpapers directories, and one per
`scripts/wm/*.sh`. `extra_links()` is where they come from. If the total looks wrong,
that difference is the first thing to rule out.

**A missing helper link is a keybinding that does nothing.** `check` reports it and
exits non-zero, which is the only warning you get: the compositors call those helpers
by bare name, so an absent link produces no error anywhere. Anyone who installed before
they existed has to run `install` once more, because the configs no longer carry the
absolute path that used to work without them.
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
