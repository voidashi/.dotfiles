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
- **Waybar's battery-critical blink** is an infinite-loop animation inherited from the old
  theme (only recolored, not reconsidered) — technically reads as an anti-pattern. Decide
  whether to keep it, tone it down, or replace with a non-looping treatment.
- **Waybar icons should be bigger.** The current font size feels counter-intuitive: When writing the code, you think they'll appear good, but the
  glyphs appear very small.
- **Waybar design could be better.** Revisit the design and think about it better. Personally, i, Jeff, don't think the blue goes well on the selected workspaces... Looks like a default WM Status bar, not like a curated design. Maybe bordeaux can go better. Also the current design can improve. You can edit the md docs with my decisions so they better reflect the current decisions.
- **Unify or improve Waybar theme organization.** The themes are unorganized, chaotic, and very messy. Organize them better, and keep consistency.
- **Hyprlauncher theme not currently exists.** The binary is installed
  (`/usr/bin/hyprlauncher`); determine whether it can be themed and add it if feasible.
  Note that it is a second launcher alongside wofi — worth deciding which one is actually
  the daily driver before theming both.

## Recently closed

Kept briefly so a rollback has context; delete once they've held up in daily use.

- Wofi's broken theme import (the palette is inlined now — see `CLAUDE.md`), terminal
  padding and opacity unified at 8px/0.92, Hyprland animation durations, the blur and
  window-rounding decisions, and starship's prompt glyph.

## Repo housekeeping

- **`conf.d.legacy/` and `hyprland.conf.legacy`** (pre-Lua Hyprland config) — Jeff's own
  call to delete once the Lua config has proven stable in daily use. Not a Claude task
  unless he asks.
- **Three stray `kitty` GUI windows** may still be open (idle fish shells, spawned by
  `kitty +runpy` during config validation, nothing important running in them) — safe to
  close whenever, low priority.
