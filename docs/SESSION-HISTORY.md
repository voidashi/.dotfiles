# Recent work

What's been done in this repo recently, for continuity across sessions. Design/theme work
has its own more detailed log at `docs/design/THEME-STATUS.md`.

## Hyprland: migrated from hyprlang to Lua

Hyprland's config moved from `hyprland.conf` + `conf.d/*.conf` (hyprlang) to
`hyprland.lua` + `conf/*.lua`, translated 1:1 — same binds, appearance, animations,
layout, window rules. The old hyprlang setup is kept as `hyprland.conf.legacy` /
`conf.d.legacy/` for rollback, not deleted.

A few pre-existing bugs got fixed along the way: an undefined `$shiftMod` (the
screenshot-region bind had no modifier), a `playerctl next33223` typo, a redundant/risky
`force_no_accel` alongside `accel_profile=flat`. Also added: a force-kill bind, a resize
submap, window grouping, and an auto-monitor fallback rule.

## Neovim: LSP and treesitter were silently broken

`plugins/lsp/` had no `init.lua`, and lazy.nvim only imports plugin subdirectories that
have one — so the entire LSP stack (nvim-lspconfig, mason, etc.) was never installed, with
no error. Merged into `lsp/init.lua` and switched to the native `vim.lsp.config()` /
`vim.lsp.enable()` API (mason-lspconfig's old `setup_handlers()` is gone).

treesitter was separately broken: the lockfile tracks the `main` branch, where
`require("nvim-treesitter.configs")` no longer exists. Fixed to use `install()` plus a
`FileType` autocmd calling `vim.treesitter.start()`.

Also fixed: Telescope's tag scheme (0.1.6 → v0.2.2, dropping deprecated-API warnings on
every picker), a couple of broken dashboard/keymap references, and small deprecations in
gitsigns/conform/colorizer/kanagawa.

## Package installer and repo scripts

`install-packages.sh` had a bug where section headers like `[common]`/`[pacman]` were
being parsed as package names and always failed to install (missing `next` in the awk
rule) — fixed, and AUR helper fallback (paru/yay/pikaur) added for AUR-only packages.

The WM helper scripts (`select_random_wallpaper.sh`, the lockscreen binding,
`unlink-dotfiles.sh`) used to live only in a separate scripts repo, so a fresh clone of
just this repo had a broken wallpaper and lockscreen. Consolidated into
`scripts/wm/` and `scripts/` here. The wallpaper script also had a real bug: it wrote
errors to stdout instead of stderr, so a missing directory's error message got treated as
a filename and handed to `swaybg` — silently broken wallpaper on Sway. Fixed.

The dedicated `lock.sh` wrapper was dropped in favor of plain `swaylock -f`: the wrapper's
CLI flags were overriding the tracked `swaylock` config, so the committed theme was never
actually the one showing on screen.

## Config review pass

A full pass over every app config (not just Hyprland/Neovim) turned up a handful of small
but real bugs: foot's deprecated `[colors]` section and `[cursor].color` key, waybar
referencing a `hyprland/mode` module that doesn't exist (it's `hyprland/submap`) in two of
its three config variants, a dead `battery#bat2` module pointed at a battery this machine
doesn't have, an 8-digit hex alpha value in wofi's CSS that GTK3 rejects, a stray CLI flag
pasted into wofi's config file, and a typo'd font name in swaylock (`Cantarelle` instead of
`Cantarell`). All fixed.

`CLAUDE.md` was created around this point to capture the non-obvious gotchas discovered
along the way, and gets updated as new ones turn up.

Then the Voidashi design system was introduced and the rice's theming work began — see
`docs/design/THEME-STATUS.md`.

## Open items carried forward

- `.config/dunst/` is still orphaned (autostart runs `swaync`, not dunst) — same
  intentional-limbo treatment as `hyprpaper.conf`, no decision made yet either way.
- `conf.d.legacy/` and `hyprland.conf.legacy` (the pre-Lua Hyprland config) are still
  present for rollback, kept until daily use confirms the Lua config is stable.
- Neovim colorscheme/highlight-group theming and wallpaper curation are still unthemed —
  both were explicitly scoped out of the Voidashi retheme so far.
- Three stray `kitty` GUI windows (idle fish shells, nothing running in them) were spawned
  by `kitty +runpy` during config validation and may still be open — harmless, safe to
  close whenever.
