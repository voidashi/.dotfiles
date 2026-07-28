# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal Linux dotfiles repository (Arch Linux + Wayland, "Kanagawa Dragon" theming throughout). It is not a software project with a build/test pipeline — it's a curated set of config files plus two bash scripts that sync them to/from `$HOME` and install the packages they depend on. There is no compiler, linter, or test suite to run; "correctness" means the shell scripts behave safely and the config files are valid for their respective apps.

## Repo layout

- `.config/<app>/` — real config files for each app, tracked by symlinking (see below). Includes `hypr`, `sway`, `waybar`, `fish`, `nvim`, `alacritty`, `kitty`, `foot`, `ghostty`, `bottom`, `dunst`, `wofi`, `fastfetch`, `wlogout`, `swaylock`, `catnap`, `starship.toml`.
- `.bashrc` — root-level tracked dotfile (outside `.config`).
- `scripts/backup-configs.sh` — moves real dotfiles into this repo and symlinks them back (`add`/`install`/`check`/`restore`).
- `scripts/install-packages.sh` — cross-distro package installer (apt/pacman/dnf) driven by `scripts/packages.conf`.
- `scripts/unlink-dotfiles.sh` — the inverse of `backup-configs.sh`: removes the symlinks and moves files back to `$HOME`, leaving the repo essentially empty. Interactive confirmation required.
- `scripts/config_files.conf` — the list of paths (relative to `~`) that `backup-configs.sh` manages. Add a new dotfile here before running `add`.
- `scripts/packages.conf` — INI-style package list consumed by `install-packages.sh` (`[common]`, `[apt]`, `[pacman]`, `[dnf]`, `[hooks]` sections).
- `scripts/wm/` — helpers invoked by the Hyprland/Sway configs *at runtime*, as opposed to the top-level `scripts/`, which you run by hand. Currently `select_random_wallpaper.sh`.
- `fonts/`, `wallpapers/`, `docs/` — static assets referenced by configs/README.

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

- **Hyprland (`.config/hypr/`) is mid-migration** from hyprlang (`.conf`) to native Lua config (Hyprland ≥ 0.55). The active config is `hyprland.lua`, which `require()`s modules from `conf/*.lua` in a load order that matters (`programs` loads first because it defines globals `binds` depends on). The old `.conf`-based setup is preserved under `conf.d.legacy/` and `hyprland.conf.legacy` for reference only — do not edit those expecting them to take effect; edit the `.lua` counterparts.
- **Neovim (`.config/nvim/`)** uses lazy.nvim; entry point `init.lua` → `lua/voidashi/lazy.lua` bootstraps plugins declared as individual files under `lua/voidashi/plugins/` (each file returns a lazy.nvim plugin spec table). `lazy-lock.json` pins plugin versions — don't hand-edit it, let lazy.nvim regenerate it.
  - **A subdirectory of `plugins/` is only imported if it contains `init.lua`** (see `lazy/core/util.lua` → `lsmod`, which scans top-level `*.lua` plus `<dir>/init.lua`). `plugins/lsp/` once held `lspconfig.lua` and `mason.lua` with no `init.lua`, so the whole LSP stack was silently never installed — no error, just no LSP. If plugins in a subdirectory appear to do nothing, check this first.
  - LSP is configured with the **native `vim.lsp.config()` / `vim.lsp.enable()`** API (nvim 0.11+), not `lspconfig[server].setup{}`; `mason-lspconfig`'s `setup_handlers()` was removed in v2. The server list is declared once in `plugins/lsp/init.lua` and shared by mason's `ensure_installed` and `vim.lsp.enable`.
  - **nvim-treesitter tracks the `main` branch**, where `require("nvim-treesitter.configs")` does not exist. Highlighting is started by a `FileType` autocmd calling `vim.treesitter.start()`. Parser names and filetypes are separate lists because they differ (`tsx` → `typescriptreact`; `markdown_inline` is not a filetype). Building parsers needs the `tree-sitter` CLI, and most servers/formatters need `node`/`npm` — all three are in `packages.conf`.
  - Formatting on save belongs to conform.nvim only; don't also add an LSP format-on-save autocmd or files get formatted twice.
- **Fish (`.config/fish/`)**: `config.fish` is the entry point; `conf.d/*.fish` files autoload (colorscheme/theme/keybinding files are split out there). `fish_variables` is fish's own generated state file, not meant to be hand-edited.
- Multiple terminal emulators (Ghostty, Alacritty, Kitty, Foot) and both Hyprland and Sway window managers are configured in parallel — when changing shared theming (colors, fonts), check whether the change needs to be mirrored across all of them rather than assuming one canonical source.
- **Waybar has three configs**: `fixed/` is the one Hyprland actually launches; `config.jsonc` and `floating/` are alternates that drift out of sync (they kept a `hyprland/mode` module long after `fixed/` was corrected to `hyprland/submap`, and all three carried a dead `battery#bat2` module pointed at a battery this machine doesn't have — check `ls /sys/class/power_supply/` before trusting a hardcoded `bat` name). Change all three, or knowingly don't.
- **GTK3 CSS (wofi, and anything else themed this way) rejects 8-digit hex colors** (`#RRGGBBAA`) on the `color` property — "Junk at end of value for color" on every launch. Use 6-digit hex or `rgba()` for alpha instead.
- **Orphaned configs kept intentionally**: `.config/hypr/hyprpaper.conf` is untouched by choice (Jeff wants it as a reference in case he switches back from swaybg); `.config/dunst/` looks similarly orphaned — Hyprland's autostart kills `mako` and starts `swaync`, with no mention of dunst and no dunst process running live, but this hasn't been explicitly decided yet. Don't delete either without asking first.
- **Wallpapers**: `scripts/wm/select_random_wallpaper.sh` takes a list of directories and uses the first containing images — `~/Pictures/Current_wallpapers` (rotation), `~/Pictures/Wallpapers` (full library), then `wallpapers/` in this repo as the fallback that makes a fresh clone work. The personal folders are deliberately untracked. The script must print errors to **stderr**: callers embed it in `$(...)` and pass the result to `swaybg` as a filename.
- The lock screen is plain `swaylock`, themed entirely by `.config/swaylock/config`. Don't reintroduce a wrapper script passing the same options as CLI flags — flags override the config file, which is how the committed theme silently stopped applying.

## Validating changes

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

### Non-negotiables

These hold for every visual change, without needing to re-read the guide:

- **Darkness is warm-neutral charcoal, never blue-black.** Backgrounds come from the
  `void-*` scale. A background that reads as blue is a bug.
- **Never invent a colour.** Every hex must come from the palette in `RICE-GUIDE.md`. If
  a role is not covered, use the nearest token and say so, or ask.
- **Sharp corners.** Zero border radius wherever it can be set.
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

