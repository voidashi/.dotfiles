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

## hyprlauncher, swaync, and a radius that became a rule

hyprlauncher — which is the launcher actually bound to `mainMod+R`, the wofi line above it
in `programs.lua` having been commented out — has no colour options at all. Its own config
covers behaviour only. It is built on hyprtoolkit, and the toolkit reads
`.config/hypr/hyprtoolkit.conf`, a file that did not exist. That is where the theme went.
Verified by control: with the file present the toolkit logs nothing, and removing it makes
it log "no hyprtoolkit.conf found, using defaults".

swaync had no `config.json` either, so it had been running entirely on `/etc/xdg` defaults.
Its stylesheet also had to be rewritten rather than extended: swaync paints from custom
properties on `:root`, and the earlier pass wrote its own selectors instead of overriding
those, so notifications kept upstream's 12px radius and critical ones kept the default
surface — the rules that actually paint them read from variables nobody had set. Urgency
now carries shape as well as colour, a heavy left rule on critical, because swaync gives no
way to inject a glyph per urgency and colour may not carry a state alone.

The 4px radius stopped being an exception for Hyprland windows and became the system rule:
a surface that floats takes 4px, a surface docked to a screen edge takes 0. Two values, no
scale, and which applies is answered by the surface rather than by taste. Weight 500 became
the UI font weight everywhere for the same kind of reason — Regular optically erodes on
charcoal. Both now live in `palette.json` under `geometry`, and the generator propagates
them to Hyprland and the GTK partial. GTK3 has no CSS custom properties, so waybar, wofi
and wlogout carry the literal with a comment pointing back at the source.

## Directional window movement, and a click that never arrives

Moving a window by direction turned out not to be a broken bind but a missing one:
`conf/binds.lua` bound `SUPER + arrows` to focus and nothing to movement. `SUPER + SHIFT +
arrows` now swaps the active window with its neighbour. `swap` rather than `move` because
dwindle is what Jeff runs: swapping preserves the tree geometry, so the windows keep their
sizes, while `movewindow` reinserts into the split tree and resizes things on the way. The
`move` variant sits commented above it.

Four glyphs in the waybar config were rendering as boxes, the battery-charging icon among
them. They came from the `nf-mdi-*` range, which Nerd Fonts v3 removed, so fontconfig had
been falling back to a font that has nothing at those codepoints. All the config's glyphs
were checked against Hack Nerd Font, and the four were replaced with Font Awesome
equivalents. Muting now uses the waveless speaker, which also fixes it having doubled as
the "low volume" icon.

Clicking a workspace still does nothing, and it is not our configuration. The bisect ruled
out the stylesheet, the layer, the `persistent-workspaces` format and a missing `on-click`,
one at a time; probes bound to every mouse button never fired, while hover highlights and
other modules' clicks work normally. In waybar 0.15.0 those buttons appear to receive
motion events but no button events. Parked with the evidence recorded in `docs/TODO.md`.
Three real config defects were found and fixed on the way, none of them the cause: the bar
was on waybar's default `bottom` layer rather than `top`, `persistent-workspaces` used a
key form the current version reads as an output name, and a `sway/workspaces` option had
been copied into the hyprland module.

## GTK applications, and a docs audit

The docs had drifted, mostly in `THEME-STATUS.md`, because sections kept being appended
without the old ones being pruned. It ended up contradicting itself: the "Known gaps"
section still said swaync had no `config.json` and that the urgency-glyph question was
unanswered, sixty lines after the same file described both being resolved. It also called
all four shell apps GTK3 when swaync is GTK4, which mattered, since GTK3 versus GTK4 is the
whole axis of the theming work that followed. Pruned rather than rewritten.

The pre-Lua Hyprland configs were deleted, along with `hyprland.conf` itself, which existed
only to source them. A session restart mid-session gave a clean natural experiment for
whether it was inert: a freshly started Hyprland came up with rounding at 4 and 66 binds,
both Lua-only values, confirming that `hyprland.lua` wins when both exist.

Then GTK application theming, which turned out narrower and deeper than the TODO described.
Narrower because the only GTK3 applications here are waybar, wofi and wlogout, all styled
directly already; the applications that actually render untouched are GTK4, and the one that
matters is pavucontrol, which the bar opens on the volume click. Deeper because of a
version-specific trap: on GTK 4.22 the accent colour responds only to CSS custom properties
while surfaces still respond to `@define-color`, so the first attempt looked half-successful,
with charcoal surfaces and a stock Adwaita blue accent. Both forms are emitted now.

`generate_theme.py` grew a function that maps the palette onto the named colours GTK and
libadwaita paint from, so applications nobody wrote a stylesheet for follow the desktop. The
GTK config directories were also untracked until now, which is how they had quietly become
territory of `kde-gtk-config`; the files that are ours are tracked, and the Breeze artifacts
beside them are left alone.

## Qt applications, and a file manager that was never installed

Dolphin came up white, and the reason was not a missing theme. `QT_QPA_PLATFORMTHEME` was
set to `qt6ct`, which exists for Qt applications that are not KDE, and `~/.config/qt6ct` did
not exist. With nothing to read, it served its own default light palette on top of a
kdeglobals that was already dark. A theming engine pointed at nothing, sitting in front of a
configuration that was fine.

Since all nine Qt applications here are KDE ones, the variable now points at `kde` and the
palette is generated into kdeglobals, which is the file those applications actually read.
The scheme is also installed as `Voidashi.colors` so it is selectable in KDE's own settings.
The merge replaces only the colour sections and copies KDE's other keys through, because
that file is shared: KDE tools write to it too. Verified by sampling pixels, Dolphin's
chrome is void-10 and its content area void-00, both warm, where BreezeDark would have given
blue-tinted greys the guide forbids.

Separately, `programs.lua` had `fileManager = "cosmic-files"`, which is not installed, so
`SUPER + E` had been running a binary that does not exist. Dolphin takes that bind now, and
yazi was added as the terminal counterpart on `SUPER + SHIFT + E`, themed by hand so it
inherits the emulator's background and supplies only its own chrome.

One defect turned up in `backup-configs.sh` on the way: it printed SUCCESS after every `ln`
without checking whether the link was made, and it did not create missing parent
directories. Linking `~/.local/share/color-schemes/Voidashi.colors` failed silently on a
machine that had never had a KDE colour scheme, while the script reported success. Both
fixed.

## The Neovim colorscheme

The first proposal was to override kanagawa's semantic layer through its own `setup()`. Jeff
pushed back, and was right: even through a public API that is still a dependency, matched by
key name, so a rename upstream would silently drop half the theme. The same partial, quiet
failure that had already cost time on the GTK4 accent.

So the theme is ours. What was worth taking from kanagawa was its structure, not its code: a
raw palette, a semantic layer of roles, and highlight groups that read only from the roles.
That separation is what makes a theme recolourable without touching hundreds of definitions.
`palette.lua` is generated from `palette.json` like every other palette in the repo, `roles.lua`
is hand-written because it holds design decisions, and `groups.lua` holds the groups.

The cost of standing alone is that nothing covers a miss. Diffing our group names against
kanagawa's found 55 groups falling through to Neovim's defaults, mostly LSP semantic tokens,
cmp's own floating windows, and neo-tree's git and tab states. All closed, and the diff is
worth re-running whenever a plugin is added.

Verified by reading the highlight groups back rather than by eye: `Comment` at ink-4,
`Visual` at ice-800, `Function` at ice-300, `String` at moss-300, `Keyword` at bordeaux-300,
`Type` at verdigris-300. Transparency stays, so `Normal` is unpainted and the editor matches
the terminal, while neo-tree and popups sit opaque on their own surfaces.

## Open items carried forward

- `.config/dunst/` is still orphaned (autostart runs `swaync`, not dunst) — same
  intentional-limbo treatment as `hyprpaper.conf`, no decision made yet either way.
- `conf.d.legacy/` and `hyprland.conf.legacy` (the pre-Lua Hyprland config) are still
  present for rollback, kept until daily use confirms the Lua config is stable.
- Wallpaper curation is the last unthemed piece, and it is blocked on choosing images
  rather than on config.
- Waybar's redesign needs a verdict from daily use: glyph sizing, numerals versus app icons
  on the workspace buttons, and whether the right-hand modules want separators.
- Three stray `kitty` GUI windows (idle fish shells, nothing running in them) were spawned
  by `kitty +runpy` during config validation and may still be open — harmless, safe to
  close whenever.
