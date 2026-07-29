# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal Linux dotfiles repository (Arch Linux + Wayland), themed throughout with **Voidashi**, the design identity documented under `docs/design/`. It replaced Kanagawa Dragon everywhere, including Sway and the Neovim colorscheme. It is not a software project with a build/test pipeline: it is a curated set of config files, three bash scripts that sync them to `$HOME` and install the packages they depend on, and two Python scripts that generate and verify the theme. There is no compiler or test suite; "correctness" means the shell scripts behave safely, the config files are valid for their apps, and `check_palette.py` passes.

## Repo layout

- `.config/<app>/` — real config files for each app, tracked by symlinking (see below). Includes `hypr`, `sway`, `waybar`, `fish`, `nvim`, `alacritty`, `kitty`, `foot`, `ghostty`, `bottom`, `dunst`, `wofi`, `fastfetch`, `wlogout`, `swaylock`, `catnap`, `starship.toml`.
- `.bashrc` — root-level tracked dotfile (outside `.config`).
- `scripts/backup-configs.sh` — moves real dotfiles into this repo and symlinks them back (`add`/`install`/`check`/`restore`).
- `scripts/install-packages.sh` — cross-distro package installer (apt/pacman/dnf) driven by `scripts/packages.conf`.
- `scripts/unlink-dotfiles.sh` — the inverse of `backup-configs.sh`: removes the symlinks and moves files back to `$HOME`, leaving the repo essentially empty. Interactive confirmation required.
- `scripts/config_files.conf` — the list of paths (relative to `~`) that `backup-configs.sh` manages. Add a new dotfile here before running `add`.
- `scripts/packages.conf` — INI-style package list consumed by `install-packages.sh` (`[common]`, `[apt]`, `[pacman]`, `[dnf]`, `[hooks]` sections).
- `scripts/wm/` — helpers invoked by the Hyprland/Sway configs *at runtime*, as opposed to the top-level `scripts/`, which you run by hand: `select-random-wallpaper.sh` and `power-menu.sh`.
- `scripts/theme/` — `palette.json` (the single source of truth for every Voidashi colour token), `generate_theme.py` (stdlib-only Python, renders it into the format each app natively reads: terminal partials, a Hyprland Lua module, a shared GTK `@define-color` partial, GTK3/GTK4 named colours, a KDE colour scheme, and the Neovim palette) and `check_palette.py` (verifies nothing drifted). Rerun the generator after editing `palette.json`; never hand-edit its output, which carries a `GENERATED` header.
- **Naming**: shell scripts use hyphens (`backup-configs.sh`, `power-menu.sh`), matching how Unix names executables — hyphens outnumber underscores roughly three to one in `/usr/bin`. Python files use underscores, which is not a preference: `check_palette.py` does `import generate_theme`, and a module name cannot contain a hyphen.
- `fonts/`, `wallpapers/`, `docs/` — static assets referenced by configs/README. `fonts/` is symlinked into `~/.local/share/fonts/dotfiles` by `backup-configs.sh install`; see the README's Fonts section for the one exception (Iosevka, gitignored for size).

## The dotfiles-management scripts (important, non-obvious behavior)

All three scripts resolve their `.conf` files from the script's own location (`SCRIPT_DIR`), so they work from any cwd. Do not reintroduce cwd-relative paths — that previously made the README's own `./scripts/install-packages.sh install` abort with "Configuration file not found" and drop a stray log in the repo root.

### `scripts/backup-configs.sh [init|add|install|check|restore] [--dry-run] [--force]`
- `add`: moves each path listed in `config_files.conf` out of `$HOME` into this repo (preserving directory contents via rsync with `--remove-source-files`), backs up the original first into `~/.dotfiles_backup/<timestamp>/`, then symlinks `$HOME` path → repo path. This is destructive to the original location — treat as a one-way move, always confirm before running against a real `$HOME`.
- `install`: symlinks repo files into `$HOME` (`ln -snf`), skipping any target that already exists as a real (non-symlink) file unless `--force` is passed (in which case the existing file is backed up first, then removed).
- `check`: verifies every tracked path is a symlink pointing at the repo.
- `restore <timestamp>`: rsyncs a prior backup back into `$HOME` with `--ignore-existing` (never clobbers).
- New dotfile workflow: add the path to `scripts/config_files.conf` first, then run `add`.

### `scripts/install-packages.sh [preview|install|check|repos] [--yes] [--no-color] [--log FILE]`
- Auto-detects the package manager (apt/pacman/dnf) unless overridden.
- Reads `packages.conf`: package keys under `[common]` apply to every distro; a same-named key under `[apt]`/`[pacman]`/`[dnf]` overrides the actual package name passed to the installer for that distro (`key=value`; bare `key` means the name is identical across distros).
- `[hooks]` section: `<package-key> = <shell command>` runs immediately after that package installs successfully (matched via awk against the common name, not the distro-specific package name).
- `install` requires sudo (prompts unless `--yes`, in which case it errors out instead of hanging on a password prompt).
- On pacman, packages missing from the official repos fall back to an AUR helper (`paru`/`yay`/`pikaur`); several entries in `packages.conf` (`catnap`, `pfetch`, `pipes.sh`) are AUR-only.
- Logs to `scripts/package_install.log`, overwritten each run and gitignored.
- Section headers in `packages.conf` are skipped via `next` in the awk block. Removing it makes the literal lines `[common]`/`[pacman]` be parsed as package names.

## Config architecture notes

- **Hyprland (`.config/hypr/`) is native Lua config** (Hyprland ≥ 0.55). The entry point is `hyprland.lua`, which `require()`s modules from `conf/*.lua` in a load order that matters (`programs` loads first because it defines globals `binds` depends on). The hyprlang `.conf` setup it replaced was deleted once daily use had confirmed the migration; recover it from git if ever needed. Hyprland prefers `hyprland.lua` over `hyprland.conf` when both exist, which is why the old entry point sat inert for so long without anyone noticing.
- **Neovim (`.config/nvim/`)** uses lazy.nvim; entry point `init.lua` → `lua/voidashi/lazy.lua` bootstraps plugins declared as individual files under `lua/voidashi/plugins/` (each file returns a lazy.nvim plugin spec table). `lazy-lock.json` pins plugin versions — don't hand-edit it, let lazy.nvim regenerate it.
  - **A subdirectory of `plugins/` is only imported if it contains `init.lua`** (see `lazy/core/util.lua` → `lsmod`, which scans top-level `*.lua` plus `<dir>/init.lua`). `plugins/lsp/` once held `lspconfig.lua` and `mason.lua` with no `init.lua`, so the whole LSP stack was silently never installed — no error, just no LSP. If plugins in a subdirectory appear to do nothing, check this first.
  - LSP is configured with the **native `vim.lsp.config()` / `vim.lsp.enable()`** API (nvim 0.11+), not `lspconfig[server].setup{}`; `mason-lspconfig`'s `setup_handlers()` was removed in v2. The server list is declared once in `plugins/lsp/init.lua` and shared by mason's `ensure_installed` and `vim.lsp.enable`.
  - **nvim-treesitter tracks the `main` branch**, where `require("nvim-treesitter.configs")` does not exist. Highlighting is started by a `FileType` autocmd calling `vim.treesitter.start()`. Parser names and filetypes are separate lists because they differ (`tsx` → `typescriptreact`; `markdown_inline` is not a filetype). Building parsers needs the `tree-sitter` CLI, and most servers/formatters need `node`/`npm` — all three are in `packages.conf`.
  - Formatting on save belongs to conform.nvim only; don't also add an LSP format-on-save autocmd or files get formatted twice.
- **Fish (`.config/fish/`)**: `config.fish` is the entry point; `conf.d/*.fish` files autoload (colorscheme/theme/keybinding files are split out there). `fish_variables` is fish's own generated state file, not meant to be hand-edited.
- Multiple terminal emulators (Ghostty, Alacritty, Kitty, Foot) and both Hyprland and Sway window managers are configured in parallel — when changing shared theming (colors, fonts), check whether the change needs to be mirrored across all of them rather than assuming one canonical source. This rule went unenforced for the whole Voidashi retheme: Sway kept its stock colours until `check_palette.py` surfaced it, so run that after touching colour rather than trusting the rule to be followed.
- **Waybar is one config split three ways, not three configs**: `common.jsonc` holds the bar geometry and every module definition; `hyprland.jsonc` and `sway.jsonc` each `include` it and add only their own compositor's `modules-left`; `style.css` is shared by both. Both WMs launch it with explicit `-c`/`-s` (`.config/hypr/conf/autostart.lua`, `.config/sway/config`), so there is no default-path config — bare `waybar` will not start. This replaced three drifting copies (`config.jsonc`, `fixed/`, `floating/`) that had silently diverged; put anything shared in `common.jsonc` so that cannot happen again. Before trusting a hardcoded `bat`/backlight name, check `ls /sys/class/power_supply/` and `ls /sys/class/backlight/` — a previous config carried a `battery#bat2` module pointed at a battery this machine doesn't have.
- **GTK3 CSS (wofi, and anything else themed this way) rejects 8-digit hex colors** (`#RRGGBBAA`) on the `color` property — "Junk at end of value for color" on every launch. Use 6-digit hex or `rgba()` for alpha instead.
- **The Neovim colorscheme is ours, not a plugin.** It lives in `.config/nvim/lua/voidashi/theme/` in three layers: `palette.lua` (generated from `palette.json`), `roles.lua` (the semantic layer, hand-written, where design decisions live) and `groups.lua` (the ~378 highlight groups, which read only from roles, never from palette). `colors/voidashi.lua` is the entry point `:colorscheme` discovers, and `lua/lualine/themes/voidashi.lua` is how lualine finds its matching theme. kanagawa is kept in the plugin list with `enabled = false` purely as a rollback. **A standalone theme has no fallback underneath it**, so when adding plugins, check for groups that fall through to Neovim's defaults; the gap can be found by diffing group names against another theme's coverage.
- **Qt/KDE theming goes through `.config/kdeglobals`, and `QT_QPA_PLATFORMTHEME` must be `kde`.** Every Qt application here is a KDE one (dolphin, ark, gwenview, kate, spectacle, partitionmanager, filelight), and they read their palette from kdeglobals. That variable used to be `qt6ct`, which is meant for Qt apps that are *not* KDE: with no `~/.config/qt6ct` to read, it served its own default light palette and overrode the dark kdeglobals behind it, which is why Dolphin came up white while a dark scheme was configured. `generate_theme.py` generates the scheme and merges only the `[Colors:*]`, `[WM]` and `[ColorEffects:*]` sections into kdeglobals, leaving KDE's own keys alone. KDE tools also write to that file, so check `git diff` after using a KDE settings dialog.
- **GTK application theming lives in `.config/gtk-3.0/` and `.config/gtk-4.0/`**, and only individual files there are tracked (`gtk.css`, `settings.ini`, `voidashi.css`). The rest of those directories (`colors.css`, `window_decorations.css`, `assets/`) is written by `kde-gtk-config` and deliberately left untracked; our `gtk.css` imports theirs first and ours last, so ours wins. `voidashi.css` is generated by `generate_theme.py`.
- **On GTK 4.16+ the accent colour only answers to CSS custom properties.** Setting `@define-color accent_bg_color` does nothing on GTK 4.22: with `@define-color` set to one colour and `--accent-bg-color` to another in the same file, the custom property is what renders. Surfaces (`window_bg_color`, `view_bg_color`) still honour `@define-color`, which makes this easy to misdiagnose, because half the file appears to work. The generator emits both forms.
- **`nwg-look` is how Jeff changes GTK themes**, and it rewrites `.config/gtk-3.0/settings.ini` and gsettings. Since that file is a symlink into this repo, its edits land in the working tree: check `git diff` there after using it. It does not touch `gtk.css`, so the palette survives.
- **Nerd Font glyphs: verify coverage before trusting a codepoint.** Nerd Fonts v3 removed the old `nf-mdi-*` range, so glyphs copied from any pre-v3 config silently fall back to another font and render as a box. Four had been sitting in the waybar config this way, including the battery-charging icon. Check with `fc-list ":charset=<hex>" family | grep -i "hack nerd"`, which prints nothing when the glyph is absent. Font Awesome codepoints (`f0xx`–`f2xx`) are the safe range.
- **Waybar's `hyprland/workspaces` buttons do not respond to clicks** (waybar 0.15.0). Not a config fault: it fails with the stock stylesheet, on either layer, with either `persistent-workspaces` form, and explicit `on-click`/`on-click-right`/`on-scroll` probes never fire, while hover works and other modules' clicks work. Don't re-derive this; see `docs/TODO.md` for the full bisect before spending time on it.
- **wofi cannot `@import` the shared theme partial.** It hands its stylesheet to GTK as a string, so relative import URLs resolve against the *process cwd* (`$HOME` when launched from a keybind) instead of the CSS file's directory — the symptom is `Failed to import: Error opening file /home/theme/voidashi-colors.css` and no colours, with the paths and symlinks all correct. waybar, swaync and wlogout load by path and are unaffected. `generate_theme.py` therefore inlines the palette into `.config/wofi/style.css` between `/* >>> VOIDASHI COLORS (GENERATED) >>> */` markers; edit outside them freely, never inside.
- **Orphaned configs kept intentionally**: `.config/hypr/hyprpaper.conf` is untouched by choice (Jeff wants it as a reference in case he switches back from swaybg), and `.config/dunst/` is kept on the same terms (autostart runs `swaync`, not dunst). Both decisions are final. Don't delete either, and don't re-raise the question.
- **`.config/hypr/hyprtoolkit.conf`** themes every hyprtoolkit application, currently only hyprlauncher, which is commented out in `conf/programs.lua` in favour of wofi. The file stays so switching back is a one-line change.
- **Wallpapers**: `scripts/wm/select-random-wallpaper.sh` takes a list of directories and uses the first containing images — `~/Pictures/Current_wallpapers` (rotation), `~/Pictures/Wallpapers` (full library), then `wallpapers/` in this repo as the fallback that makes a fresh clone work. The personal folders are deliberately untracked. The script must print errors to **stderr**: callers embed it in `$(...)` and pass the result to `swaybg` as a filename.
- The lock screen is plain `swaylock`, themed entirely by `.config/swaylock/config`. Don't reintroduce a wrapper script passing the same options as CLI flags — flags override the config file, which is how the committed theme silently stopped applying.
- **wlogout is the opposite case, and does need its wrapper.** `scripts/wm/power-menu.sh` is the only place its geometry exists: wlogout reads the actions from `.config/wlogout/layout` and the colours from `style.css`, but buttons-per-row, spacing and margins are CLI-only, with no config-file equivalent to be overridden. The wrapper derives the margins from the focused output's real resolution (via `hyprctl`/`swaymsg`), so the centred column holds its proportions on any screen. Launch the menu through it, never `wlogout` bare. Also note wlogout renders each button label on a **single line** — a `\n` in the layout's `text` arrives as a visible control-character box, not a line break.

## Validating changes

Run `python3 scripts/theme/check_palette.py` after any colour change. It fails on three
things: a hex anywhere in a tracked config that is not in `palette.json`, a **named**
terminal colour (`green`, `brwhite`, `cyan`) inside fish or starship config, and a
`GENERATED` file that no longer matches what the generator would produce, which is how
hand-edits to generated output get caught. The named-colour check exists because twelve
fish variables sat on stock names for the whole retheme while the hex-only check passed.
Colour names are searched only in fish and starship, since words like "red" appear in prose
everywhere else, and comments are stripped first so a colour discussed is not a colour
applied. Deliberate exceptions (`DESIGN-SYSTEM.md`, the orphaned
`dunstrc`) are listed in the script with the reason, so a decided exception does not become
permanent noise.


Most of these tools can check their own config, which beats reading them by eye:

```bash
hyprctl configerrors                      # empty == clean
sway --validate -c .config/sway/config
foot --check-config -c .config/foot/foot.ini
ghostty +validate-config --config-file=.config/ghostty/config
alacritty migrate --dry-run -c <file>     # flags deprecated syntax
kitty +runpy "from kitty.config import load_config; bad=[]; load_config('.config/kitty/kitty.conf', accumulate_bad_lines=bad); print(bad)"  # [] == clean; --debug-config no longer exists (gone by 0.48.1)
waybar -c <config> -s <style>             # warns about unknown modules
nvim --headless "+checkhealth vim.deprecated" +qa
```

For Neovim, note that lazy-loaded plugins won't surface their deprecations until actually loaded — run the relevant command (e.g. `+Telescope find_files`) before `checkhealth`, or you'll get a false all-clear.


---

## Visual identity

This repository follows a personal design identity called **Voidashi**. Any work that
changes how something *looks* — colours, fonts, spacing, borders, animation, wallpaper,
themes — must follow it.

**Read `docs/design/RICE-GUIDE.md` before making any visual change.** It is the
authoritative document for desktop work and contains the palette, the canonical ANSI
mapping, and the rules for how colour is assigned.

| Document | When to read it |
|---|---|
| `docs/design/RICE-GUIDE.md` | **Always**, before any theming or visual change |
| `docs/design/AESTHETIC-DIRECTION.md` | When a judgement call is not covered by the rules and you need to know what the system is trying to feel like |
| `docs/design/DESIGN-SYSTEM.md` | Canonical token reference; also when the task is web/document work rather than desktop |

For desktop work, `RICE-GUIDE.md` overrides `DESIGN-SYSTEM.md` wherever they differ.

**Continuity:** `docs/design/THEME-STATUS.md` tracks what has actually been themed and what
has not. `docs/SESSION-HISTORY.md` records turning points, meaning decisions that still
explain the shape of the repo; it is deliberately not a session log. `docs/TODO.md` lists
open work. Check all three before assuming something is or is not already done.

**Propagation:** `scripts/theme/palette.json` is the machine-readable single source of
truth transcribed from `RICE-GUIDE.md`; `scripts/theme/generate_theme.py` renders it into
every app's native colour-include format. Apps whose colour keys mix with structural
config (swaylock, bottom, starship, fastfetch) are hand-edited instead, referencing the
same palette values directly — never a fresh hex.

### Non-negotiables

These hold for every visual change, without needing to re-read the guide:

- **Darkness is warm-neutral charcoal, never blue-black.** Backgrounds come from the
  `void-*` scale. A background that reads as blue is a bug.
- **Never invent a colour.** Every hex must come from the palette in `RICE-GUIDE.md`. If
  a role is not covered, use the nearest token and say so, or ask.
- **Two radii, and which one applies is not a matter of taste.** A surface that floats over
  other content (window, launcher, notification, menu) takes **4px**; a surface docked to a
  screen edge (the bar) takes **0**. No other value exists — 4px reads as cut, anything
  larger as moulded. Both live in `scripts/theme/palette.json` under `geometry`.
- **No neon, glow, vibrant gradients, or RGB effects.**
- **No bounce, spring, or overshoot animation.** No infinite loops outside loaders.
- **Colour never carries state alone** — a coloured status always has a glyph too.
- **ANSI is identical across every terminal and TUI**, taken verbatim from the guide's
  mapping table.
- **Consistency within a class.** After changing one terminal, bar, or launcher, the
  others of the same kind must match.

### Scope discipline

A theming task changes colours, fonts, padding, borders, and radii. It does not change
keybindings, module ordering, scripts, or functional options. If a functional change is
genuinely required to reach a visual goal, raise it separately instead of folding it in.

### When something is unspecified

The guide deliberately leaves per-application decisions open. Make the call, then state
the assumption in one line so it can be corrected — do not stall on it, and do not
silently invent a rule that will then propagate.

