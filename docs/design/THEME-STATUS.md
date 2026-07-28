# Voidashi theme — status

Where the rice's retheme to Voidashi stands. Read `RICE-GUIDE.md` first for the actual
rules; this is just state tracking. Repo-wide (non-theme) history is in
`docs/SESSION-HISTORY.md`. Commits: `764a09b`..`12bef77` (2026-07-28).

## Status: all six planned steps done

1. **Infra** — `scripts/theme/palette.json` (source of truth, transcribed from
   `RICE-GUIDE.md`/`DESIGN-SYSTEM.md`) + `scripts/theme/generate_theme.py` (stdlib
   Python). Generates: `kitty/foot/ghostty/alacritty` colour partials, `hypr/conf/palette.lua`,
   `theme/voidashi-colors.css` (shared GTK `@define-color` partial).
2. **Terminals** — kitty/foot/ghostty/alacritty theme + Iosevka Extended font + size 12
   (matched across all four — was inconsistent, fixed in the final audit).
3. **waybar/wofi/wlogout + swaync** — all import the shared CSS partial. swaync had no
   config anywhere before this (repo or live); `style.css` created from scratch,
   `~/.config/swaync` + `~/.config/theme` added to `config_files.conf`.
4. **Hyprland** — `appearance.lua` recolored via `require("conf/palette")`.
5. **swaylock/fastfetch/bottom/starship/fish** — hand-edited (colour mixes with structural
   config in these, so no generator). Fish's `conf.d/` only autoloads one colorscheme at a
   time, so the old Flexoki files moved to `conf.d.legacy/`.
6. **Audit** — found and fixed 3 real bugs the earlier steps hadn't touched: Hyprland
   `rounding=10` (should be 0, non-negotiable), an overshooting animation bezier (`y=1.1`,
   forbidden outright), inconsistent terminal font sizes (fixed in step 2 above).
   Programmatic check confirmed every hex in every themed file traces to `palette.json`.

## Architecture (for future theme work)

- **Tier A** (pure colour, generated): terminals, `theme/voidashi-colors.css`, `palette.lua`.
  Never hand-edit — rerun `generate_theme.py` after changing `palette.json`.
- **Tier B** (colour mixed with structural config, hand-edited): swaylock, bottom, starship,
  fastfetch, fish. Values still must trace back to `palette.json` — just pasted, not generated.
- Every active-theme file that replaced prior colours has its previous version preserved
  alongside it (`*.kanagawa.css`, `*.kanagawa.legacy`, `conf.d.legacy/`, commented-out
  `include` lines) — nothing was deleted, only deactivated.

## Corrections made mid-session (worth knowing before touching this again)

- **The design docs themselves were rewritten** (Portuguese → English, `system.md` →
  `DESIGN-SYSTEM.md` etc.) partway through, changing real values: focus/active/selected is
  **Ice**, not Bordeaux (Bordeaux is identity/primary-action only — terminal cursor, prompt,
  lockscreen); a new **Verdigris** family fills the ANSI cyan slot; terminal cursor is
  `bordeaux-300` (not 400); terminal selection background is `ice-600` (not `bordeaux-800`);
  "semantic states" are now called **alert tones** (`alert-critical/caution/good/neutral`).
  `palette.json` reflects the current, correct values.
- **GTK apps use Instrument Sans, not Iosevka Extended** — waybar/wofi/wlogout/swaync are
  GTK3 applications, which RICE-GUIDE.md's "GTK / Qt application theming" section covers
  separately from the typography table's "bar modules" row (now clarified in the doc itself).
- Fonts (Iosevka Extended, Instrument Sans, Spectral) weren't installed anywhere fontconfig
  scans until mid-session — `~/.local/share/fonts/dotfiles` now symlinks `fonts/` (repo)
  there, via `backup-configs.sh install`'s new `install_fonts()`. `fonts/Iosevka/` itself is
  `.gitignore`d (431MB); see README's Fonts section to re-obtain it.

## Known gaps / deliberately not done

- `.config/dunst/` still orphaned, untouched (same as `hyprpaper.conf` — no decision made).
- Neovim colorscheme and wallpaper curation: explicitly out of scope for this pass.
- swaync's `config.json` was never created (only `style.css`) — whether urgency levels get
  a distinct icon/glyph automatically or need explicit config is unverified.
- The infinite-loop battery-critical blink in waybar predates this work (inherited, only
  recolored) and technically reads as an anti-pattern ("no infinite loops outside
  loaders") — left alone since removing it would be a functional change, not a theming one.
- Hyprland blur is still on (small: `size=5, passes=1`). Guide says "avoid", not "never".
- Terminal padding across the four emulators was never checked for consistency.
