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
- **`.config/dunst/`** — kept deliberately. Autostart runs `swaync`, not dunst, so it is
  orphaned, but Jeff wants it there in case he switches back. Don't delete it, and don't
  re-raise the question.
- **Waybar, second pass.** The redesign landed — flat surface, bordeaux rule under the
  active workspace instead of an Ice block, numerals instead of app glyphs, one shared
  config. What still needs judging in daily use: whether the glyphs are the right size
  now, whether the numerals actually beat the old icons, and whether the right-hand
  modules want a separator between them or should stay spaced only.
- **hyprlauncher is themed but not in use.** `conf/programs.lua` binds `mainMod+R` to wofi;
  the hyprlauncher line above it is commented out. Its theme lives in
  `.config/hypr/hyprtoolkit.conf` and is kept so switching back is a one-line change —
  that file themes any hyprtoolkit application, not just this one.

## Recently closed

Kept briefly so a rollback has context; delete once they've held up in daily use.

- Wofi's broken theme import (the palette is inlined now — see `CLAUDE.md`), terminal
  padding and opacity unified at 8px/0.92, Hyprland animation durations, the blur and
  window-rounding decisions, and starship's prompt glyph.
- Waybar's three drifting configs, its glyph sizing, the Ice-on-active-workspace look, and
  the inherited infinite battery blink (now a static `alert-critical` plus the glyph).
  The dead `mpd` module was dropped with them — mpd isn't running, so it rendered a
  permanent "Disconnected" in the bar, and `custom/media` already covers playback.
- wlogout redesigned as a list and its orphaned lavender PNGs deleted; hyprlauncher themed
  through `.config/hypr/hyprtoolkit.conf`; swaync's `config.json` created and its stylesheet
  rewritten against the upstream `:root` variables.

## Repo housekeeping

- **`conf.d.legacy/` and `hyprland.conf.legacy`** (pre-Lua Hyprland config) — Jeff's own
  call to delete once the Lua config has proven stable in daily use. Not a Claude task
  unless he asks.
- **Three stray `kitty` GUI windows** may still be open (idle fish shells, spawned by
  `kitty +runpy` during config validation, nothing important running in them) — safe to
  close whenever, low priority.
