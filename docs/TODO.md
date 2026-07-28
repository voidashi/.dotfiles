# TODO

Future work not yet done, carried across sessions. Check this before assuming the rice or
repo is fully finished.

## Theming

- **Neovim colorscheme.** Not themed at all yet — needs a Voidashi highlight-group mapping
  (editor role in `RICE-GUIDE.md`: void-00 background, ink for text, the identity families
  + Verdigris for syntax categories, Ice for selection/cursor line, comments at ink-4).
  This is its own scoped task, not a quick add-on.
- **Wallpaper.** Still whatever it was before — needs actual image curation (material,
  desaturated, dark, per `RICE-GUIDE.md`'s Wallpaper section), not just config edits.
  Requires real assets, not something to do from config alone.
- **`.config/dunst/`** — orphaned (autostart runs `swaync`, not dunst). No decision made on
  whether to delete it, keep it as a rollback reference, or actually theme it too.
- **swaync `config.json`** — never created, only `style.css`. Worth checking whether
  urgency levels get a distinct icon/glyph automatically or need explicit config to satisfy
  "state is never colour alone."
- **Waybar, second pass.** The redesign landed — flat surface, bordeaux rule under the
  active workspace instead of an Ice block, numerals instead of app glyphs, one shared
  config. What still needs judging in daily use: whether the glyphs are the right size
  now, whether the numerals actually beat the old icons, and whether the right-hand
  modules want a separator between them or should stay spaced only.
- **Hyprlauncher theme not currently exists.** The binary is installed
  (`/usr/bin/hyprlauncher`); determine whether it can be themed and add it if feasible.
  Note that it is a second launcher alongside wofi — worth deciding which one is actually
  the daily driver before theming both.

## Recently closed

Kept briefly so a rollback has context; delete once they've held up in daily use.

- Wofi's broken theme import (the palette is inlined now — see `CLAUDE.md`), terminal
  padding and opacity unified at 8px/0.92, Hyprland animation durations, the blur and
  window-rounding decisions, and starship's prompt glyph.
- Waybar's three drifting configs, its glyph sizing, the Ice-on-active-workspace look, and
  the inherited infinite battery blink (now a static `alert-critical` plus the glyph).
  The dead `mpd` module was dropped with them — mpd isn't running, so it rendered a
  permanent "Disconnected" in the bar, and `custom/media` already covers playback.

## Repo housekeeping

- **`conf.d.legacy/` and `hyprland.conf.legacy`** (pre-Lua Hyprland config) — Jeff's own
  call to delete once the Lua config has proven stable in daily use. Not a Claude task
  unless he asks.
- **Three stray `kitty` GUI windows** may still be open (idle fish shells, spawned by
  `kitty +runpy` during config validation, nothing important running in them) — safe to
  close whenever, low priority.
