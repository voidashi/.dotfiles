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
- **Waybar has three configs**: `fixed/` is the one Hyprland actually launches; `config.jsonc` and `floating/` are alternates that drift out of sync (they kept a `hyprland/mode` module long after `fixed/` was corrected to `hyprland/submap`). Change all three, or knowingly don't.
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
kitty --debug-config -c .config/kitty/kitty.conf
waybar -c <config> -s <style>             # warns about unknown modules
nvim --headless "+checkhealth vim.deprecated" +qa
```

For Neovim, note that lazy-loaded plugins won't surface their deprecations until actually loaded — run the relevant command (e.g. `+Telescope find_files`) before `checkhealth`, or you'll get a false all-clear.
