# Voidashi theme — status

Where the rice's retheme to Voidashi stands. Read `RICE-GUIDE.md` first for the actual
rules; this is just state tracking. Repo-wide (non-theme) history is in
`docs/SESSION-HISTORY.md`.

## Status: fully themed

- **Terminals** (kitty, foot, ghostty, alacritty): full palette + Iosevka Extended at size
  12, matched across all four.
- **waybar, wofi, wlogout, swaync**: themed via a shared GTK CSS partial. swaync had no
  config anywhere before this (repo or live system) — its `style.css` was created from
  scratch and added to `config_files.conf`.
- **Hyprland**: window borders and decoration recolored.
- **swaylock, fastfetch, bottom, starship, fish**: themed by hand (their colour keys mix
  with structural config, so they aren't generated). Fish's `conf.d/` only autoloads one
  colorscheme at a time, so the previous Flexoki theme files moved to `conf.d.legacy/`
  rather than being deleted.
- A full audit against the guide's non-negotiables and anti-patterns caught three real
  bugs no earlier pass had touched: Hyprland's window rounding was still 10px (must be 0),
  one animation curve had a mathematical overshoot (forbidden outright), and terminal font
  sizes weren't consistent across the four emulators. All fixed. Every hex value in every
  themed file was also checked against the palette — nothing invented.

## Architecture

- **Single source of truth**: `scripts/theme/palette.json`, transcribed from
  `RICE-GUIDE.md`/`DESIGN-SYSTEM.md`. Edit here, never a hex in an app config directly.
- **Generator**: `scripts/theme/generate_theme.py` (stdlib Python) renders the source into
  each app's native colour-include format — terminal colour partials, a Hyprland Lua
  palette module, and a shared GTK `@define-color` partial for the CSS-based apps. Rerun it
  after any `palette.json` change; its output files carry a `GENERATED` header and should
  never be hand-edited.
- **Hand-edited apps**: swaylock, bottom, starship, fastfetch, fish — colour there mixes
  with structural config, so generating into them risked corrupting settings unrelated to
  colour. Values still come straight from the palette, just pasted rather than generated.
- **Nothing was deleted**: every file whose active colours changed has its previous version
  preserved alongside it (`*.kanagawa.css`, `*.kanagawa.legacy`, `conf.d.legacy/`,
  commented-out `include` lines) rather than removed.

## Key decisions

- **Role model**: focus/active/selected is **Ice**, not Bordeaux — Bordeaux is reserved for
  identity/primary-action (terminal cursor, prompt accent, lockscreen accent). A
  **Verdigris** family fills the ANSI cyan slot the core palette has no family for.
  Terminal cursor is `bordeaux-300`; terminal selection background is `ice-600`.
  "Semantic states" are called **alert tones** (`alert-critical/caution/good/neutral`).
- **wlogout was rebuilt, not just recoloured.** It had been listed as fully themed, but its
  six buttons carried lavender PNGs from `wlogout/icons/` — a colour from no Voidashi
  scale, raster so unreachable by the palette, and loaded through absolute `/home/jeff`
  paths that break on any other machine. The glyphs are text in the `layout` file now, so
  they inherit `color` like anything else. The shape changed with them: a centred vertical
  list of six labelled rows instead of a grid of tiles, ordered by escalating consequence,
  with reboot and shutdown last and turning `alert-critical` on approach — they keep glyph
  and label, so colour reinforces rather than carries. Focus stays Ice, per the role table.
  Geometry lives in `scripts/wm/power_menu.sh` because wlogout accepts it only as CLI
  flags; the wrapper reads the focused output's resolution so the proportions survive a
  different screen.
- **Waybar is marked, not filled.** The active workspace carries a 2px `bordeaux-400` rule
  beneath it instead of an `ice-800` block, and modules no longer sit on individual
  `void-20` pills — a row of raised chips is what made the bar read as a default status
  bar. Bordeaux stays the identity mark here rather than becoming a second focus colour;
  Ice remains focus everywhere else, including Hyprland's window borders. Workspace labels
  are numerals in both bars, where before Sway showed app glyphs and Hyprland showed
  numbers.
- **Bar glyphs are sized in the config, not the stylesheet.** They arrive from Hack Nerd
  Font through fontconfig fallback and are drawn smaller per em than Instrument Sans, so
  at a shared `font-size` they looked undersized next to their own labels. `common.jsonc`
  wraps each `{icon}` in Pango `<span size="large">`.
- **Terminals: 0.92 opacity and 8px padding, all four.** Both were inconsistent — three
  different opacities and no padding set anywhere, so each emulator used its own default.
  The guide's "opaque by default" was rewritten to describe the transparency actually in
  use; foot's `alpha` sits in a second `[colors-dark]` block in `foot.ini`, since the
  generated palette include must not be hand-edited.
- **Hyprland keeps a small blur (`size=5, passes=1`) and gains a 4px window radius.** Both
  were open questions the guide answered with a flat "no"; Jeff's call is that a small
  amount of each is right for this desktop, and `RICE-GUIDE.md` and `CLAUDE.md` were
  amended to say so. The radius applies to compositor windows only — every other surface
  is still square.
- **Animation durations sit a notch above the guide's original table** (windows 300ms,
  workspace 350ms, focus 150ms, fade 200ms) with the ease-out curve now applied to every
  leaf. The old values were 600–1000ms, slow enough to be the daily-use complaint that
  started this; the guide's UI-transition numbers read as abrupt on full windows, so the
  motion table was rewritten around a ~400ms ceiling.
- **wofi's palette is inlined, not imported** — it is the one GTK app whose `@import`
  resolves against the process cwd. See `CLAUDE.md`.
- **GTK apps use Instrument Sans, not Iosevka Extended.** waybar, wofi, wlogout and swaync
  are GTK3 applications and fall under the guide's "GTK/Qt application theming" rule, not
  the typography table's mono-primary row (which is for bars that render their own text
  outside a toolkit). The guide's typography table now says so explicitly.
- Iosevka Extended, Instrument Sans and Spectral are symlinked from `fonts/` into
  `~/.local/share/fonts/dotfiles` by `backup-configs.sh install`. `fonts/Iosevka/` itself is
  `.gitignore`d — its full-family build is ~430MB, too large to version; see the README's
  Fonts section for where to re-download it.

## Known gaps / deliberately not done

- `.config/dunst/` is still orphaned and untouched (same as `hyprpaper.conf` — no decision
  made either way).
- Neovim colorscheme and wallpaper curation are explicitly out of scope for this pass.
- swaync's `config.json` was never created (only `style.css`) — whether urgency levels get
  a distinct icon/glyph automatically or need explicit config is unverified.
- The infinite-loop battery-critical blink in waybar predates this theme (inherited, only
  recolored) and technically reads as an anti-pattern ("no infinite loops outside
  loaders") — left alone since removing it would be a functional change, not a theming one.
- Waybar's redesign is in, but only daily use will say whether the glyph sizing and the
  numeral workspace labels are right. See `docs/TODO.md`.
