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

## Voidashi follow-ups: the small stuff

A pass over the loose ends the retheme left behind, plus two inconsistencies the TODO had
not caught — the four terminals were running three different opacities, and none of them
set padding at all, so each used its own default.

The wofi theme bug turned out not to be a wrong path: the symlinks and the target file
were correct all along. wofi hands its stylesheet to GTK as a string, so a relative
`@import` resolves against the process cwd (`$HOME`) rather than the file's directory,
which is where `/home/theme/voidashi-colors.css` came from. `generate_theme.py` now inlines
the palette into wofi's `style.css` between markers instead.

Hyprland's animations were running at 600–1000ms — the cause of the "too slow for daily
workflow" complaint. Now 150–350ms, with the ease-out curve applied to every leaf rather
than just `windows`.

Three decisions the design docs had answered with a flat "no" went the other way, on
Jeff's call: the small compositor blur stays, terminals keep transparency (0.92 everywhere),
and windows get a 4px radius. `RICE-GUIDE.md` and `CLAUDE.md` were amended to describe the
desktop that exists rather than the one they originally specified — including the motion
table, whose UI-transition durations read as abrupt on full windows.

## Waybar: one bar, described once

Waybar was not three copies of one config. `.config/sway/config` ran plain `waybar`, which
loads the default-path `config.jsonc` — so the root config was Sway's live bar, `fixed/`
was Hyprland's, and only `floating/` was dead. That is why they drifted: nothing tied them
together, and two of them were in use.

Now `common.jsonc` holds the geometry and every module definition, and `hyprland.jsonc` /
`sway.jsonc` include it and add only their own `modules-left`. One `style.css` serves both.
Both compositors launch with explicit `-c`/`-s`, so neither bar is the default one — the
tradeoff is that bare `waybar` no longer starts.

The design changed with it: no more per-module `void-20` pills, and the active workspace is
marked by a bordeaux rule beneath it rather than an Ice block. Also fixed along the way —
glyphs are wrapped in Pango `<span size="large">` (they come from Nerd Font fallback and
were rendering smaller than their own labels), the notification dot's literal `red` became
`alert-critical`, the battery blink became static, and the `mpd` module was dropped, since
mpd isn't running and the module rendered a permanent "Disconnected".

## The two custom waybar modules

`mediaplayer.py` had three real defects. `add_argument("-x", "--exclude", "- Comma-separated
list of excluded player")` passed the description as a third *option string* rather than
`help=`, which argparse accepted silently. `title.replace(...)` ran before any None check,
so a player reporting no title — streams, some web players — threw an AttributeError. And
the script escaped `&` itself while the module also sets `"escape": true`, so an ampersand
in a track name reached the bar as a literal `&amp;`.

It now reports playback state as well: `alt` carries playing/paused/stopped so the glyph
changes with it, and `class` carries the same state plus the player name, so a paused track
dims. The module also takes click to play/pause and scroll to change track.

wlogout's buttons were still lavender PNGs loaded from absolute `/home/jeff` paths — raster
images the palette could never reach, which is how they survived the retheme untouched. The
glyphs are text in the `layout` file now, and the menu was redesigned around that: a centred
vertical list of six labelled rows rather than a grid of tiles, ordered by escalating
consequence with reboot and shutdown last.

Two constraints shaped it. wlogout renders each label on a single line, so a `\n` between
glyph and label arrives as a visible control-character box — glyph and label share a line by
necessity. And its geometry is CLI-only, with no config-file equivalent, so
`scripts/wm/power_menu.sh` holds it and derives the margins from the focused output's
resolution. That is the opposite of the swaylock lesson recorded in `CLAUDE.md`, where the
wrapper was the bug; here there is nothing for flags to override.

The design was iterated against real screenshots rather than by eye, using a throwaway copy
of the layout with every action replaced by `true` — a power menu is not something to open
speculatively next to a keyboard someone is typing on.

## Open items carried forward

- `.config/dunst/` is still orphaned (autostart runs `swaync`, not dunst) — same
  intentional-limbo treatment as `hyprpaper.conf`, no decision made yet either way.
- `conf.d.legacy/` and `hyprland.conf.legacy` (the pre-Lua Hyprland config) are still
  present for rollback, kept until daily use confirms the Lua config is stable.
- Neovim colorscheme/highlight-group theming and wallpaper curation are still unthemed —
  both were explicitly scoped out of the Voidashi retheme so far.
- Waybar's redesign needs a verdict from daily use: glyph sizing, numerals versus app icons
  on the workspace buttons, and whether the right-hand modules want separators.
- Three stray `kitty` GUI windows (idle fish shells, nothing running in them) were spawned
  by `kitty +runpy` during config validation and may still be open — harmless, safe to
  close whenever.
