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
- **Waybar design could be better.** Revisit the design and think about it better.
- **Waybar text color could be better.**
- **Unify or improve Waybar theme organization.** The themes are unorganized, chaotic, and very messy. Organize them better, and keep consistency.
- **Starship icons look bad.** Evaluate the icons chosen for it.
- **Hyprland animation time is too slow for daily workflow.** Review animation durations and
  responsiveness across common actions.
- **Wofi `--show drun`.** Fix the GTK theme import path and address any other programs using
  the same theme file path issue.
- **Wofi theme path error.** `(wofi:92862): Gtk-WARNING **: ... Failed to import: Error opening
  file /home/theme/voidashi-colors.css: No such file or directory.` The import line is using the
  wrong relative path and may affect other GTK apps.
- **Hyprlauncher theme not currently exists.** Determine whether a Hyprlauncher theme can be
  created and add it if feasible.
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
