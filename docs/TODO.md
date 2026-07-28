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
- **Hyprland blur** is still on (small: `size=5, passes=1`). The guide says avoid, not
  never — worth a deliberate call rather than leaving it by default.
- **Terminal padding** across kitty/foot/ghostty/alacritty was never checked for
  consistency (only font, size, and colour were).

## Repo housekeeping

- **`conf.d.legacy/` and `hyprland.conf.legacy`** (pre-Lua Hyprland config) — Jeff's own
  call to delete once the Lua config has proven stable in daily use. Not a Claude task
  unless he asks.
- **Three stray `kitty` GUI windows** may still be open (idle fish shells, spawned by
  `kitty +runpy` during config validation, nothing important running in them) — safe to
  close whenever, low priority.
