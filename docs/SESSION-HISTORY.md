# Session history

Chronological log of work done across recent Claude Code sessions on this repo, for
continuity when a session's own context gets compacted or ends. Each entry is a commit;
read the full message with `git show <hash>` for details. Design/theme work has its own
more detailed log at `docs/design/THEME-STATUS.md`.

## 2026-07-28

**Hyprland Lua migration + general repo health pass** (before the Voidashi design work
started):

| Commit | What |
|---|---|
| `cd504b0` | Migrated `hyprland.conf` + `conf.d/*.conf` (hyprlang) to `hyprland.lua` + `conf/*.lua`, 1:1. Legacy `.conf` setup kept as `hyprland.conf.legacy` / `conf.d.legacy/` for rollback. Fixed a few pre-existing bugs along the way (undefined `$shiftMod`, a `playerctl next33223` typo, redundant `force_no_accel`) and added a force-kill bind, resize submap, window grouping, auto-monitor fallback. |
| `dfeb821` | Neovim: `plugins/lsp/` had no `init.lua` so lazy.nvim never imported it — LSP was silently never installed. Merged into `lsp/init.lua`, switched to native `vim.lsp.config()`/`vim.lsp.enable()`. Fixed treesitter (tracks `main`, needed the `install()` + `FileType` autocmd pattern), Telescope (0.1.6 → v0.2.2 tag rename), gitsigns/conform/colorizer/kanagawa deprecations. |
| `473f0a5` | `install-packages.sh`: section headers (`[common]` etc.) were being parsed as package names (missing `next` in the awk rule); added AUR helper fallback (paru/yay/pikaur) for AUR-only packages; fixed exit-status capture. Hyprland's waybar launch switched to an absolute path. Stopped tracking the regenerated `package_install.log`. |
| `34b56d0` | Consolidated WM helper scripts that only lived in a separate `voidashi/scripts` repo into this one: `scripts/wm/select_random_wallpaper.sh` (also fixed it writing errors to stdout instead of stderr, which broke Sway's wallpaper), dropped `lock.sh` in favor of plain `swaylock -f` (the wrapper's CLI flags were overriding the tracked theme config), ported `unlink-dotfiles.sh`. |
| `9397b78` | foot: `[colors]` → `[colors-dartk]` rename, `[cursor].color` → `cursor` key move. waybar: `hyprland/mode` isn't a module (`hyprland/submap` is); fixed in `config.jsonc`/`floating/` which had stale copies. |
| `09be616` | Added `CLAUDE.md` (repo guidance for Claude Code). |
| `be03816` | Fish: cleared Neovim-adjacent deprecation warnings, variable updates. |

**Post-migration review pass**, requested explicitly ("revisar o resto das configs"):

| Commit | What |
|---|---|
| `b572565` | waybar: dead `battery#bat2` module (machine only has `BAT1`) removed from all three configs. wofi: 8-digit hex alpha (`#ffffffff`) rejected by GTK3 CSS, dropped to 6-digit; stray `--show` CLI flag removed from `config`. swaylock: `Cantarelle Regular` typo'd font name fixed to `Cantarell`. |
| `34fdfc0` | `CLAUDE.md` updated with the findings above (battery hardware-mismatch gotcha, GTK3 8-digit-hex rejection, kitty's `--debug-config` flag being gone by 0.48.1, the `hyprpaper.conf`/`dunst` orphaned-but-intentional configs). |

Then Jeff added the Voidashi design system docs and the retheme began — see
`docs/design/THEME-STATUS.md` for that work in detail (commits `764a09b` onward).

## Open items carried forward

- `.config/dunst/` is still orphaned (autostart runs `swaync`, not dunst) — same
  intentional-limbo treatment as `hyprpaper.conf`, no decision made yet either way.
- `conf.d.legacy/` and `hyprland.conf.legacy` (the pre-Lua Hyprland config) are still
  present for rollback. Jeff said he'll delete them himself once he's confirmed the Lua
  config is stable in daily use — not a task for Claude to do proactively.
- Neovim colorscheme/highlight-group theming and wallpaper curation were both explicitly
  scoped out of the Voidashi retheme (see `docs/design/THEME-STATUS.md`).
- Three stray `kitty` GUI windows (idle fish shells, no real work in them) were spawned by
  `kitty +runpy` during config validation and were never confirmed closed — a `kill` was
  blocked by the permission classifier mid-session. Harmless if still open; safe to close.
