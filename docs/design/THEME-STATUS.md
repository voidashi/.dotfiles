# Voidashi theme: status

Where the retheme to Voidashi stands. Read `RICE-GUIDE.md` first for the actual rules; this
is state tracking only. Repo-wide history that is not about theming lives in
`docs/SESSION-HISTORY.md`.

## Shell surfaces: done

These are the surfaces the compositor puts on screen: bar, launcher, notifications, power
menu, lock screen, terminals. Ordinary applications are a separate matter and are covered
under "Known gaps" at the bottom.

- **Terminals** (kitty, foot, ghostty, alacritty): full palette + Iosevka Extended at size
  12, matched across all four.
- **waybar, wofi, wlogout** (GTK3) and **swaync** (GTK4): themed from the shared GTK CSS
  partial, except wofi, which inlines it for the reason recorded in `CLAUDE.md`. swaync had
  no config anywhere before this, in the repo or on the live system.
- **Hyprland**: window borders and decoration recolored.
- **Sway**: focus in Ice, unfocused in edge-30, surfaces on the void scale, mirroring
  `hypr/conf/appearance.lua`. It had never been themed at all: the config carried the 41
  Kanagawa colours as variables and used none of them, since there was not a single
  `client.*` directive in the file, so Sway ran on its stock blue while the repo looked
  themed. Terminal and launcher were also diverging from Hyprland (foot and wmenu-run
  against kitty and wofi) and now match.
- **swaylock, fastfetch, bottom, starship, fish**: themed by hand (their colour keys mix
  with structural config, so they aren't generated). Fish's `conf.d/` only autoloads one
  colorscheme at a time, so the previous Flexoki theme files moved to
  `.config/fish/conf.d.legacy/` rather than being deleted. That is the only `conf.d.legacy`
  left; Hyprland's was deleted once the Lua config had proven itself.
- A full audit against the guide's non-negotiables and anti-patterns caught three real bugs
  no earlier pass had touched: Hyprland's window rounding was still at the inherited
  Kanagawa 10px, one animation curve had a mathematical overshoot, which is forbidden
  outright, and terminal font sizes were inconsistent across the four emulators. All fixed.
  Every hex in every themed file was checked against the palette, and nothing was invented.
  The rounding later became the deliberate 4px recorded under "Key decisions".

## Como cada app recebe a paleta

Cinco mecanismos, porque cinco toolkits diferentes não aceitam o mesmo tratamento.
Antes de mexer em qualquer app, veja por qual linha ele entra:

| Mecanismo | Como funciona | Apps |
|---|---|---|
| **Partial gerado + include** | O gerador escreve um arquivo só de cor, no formato nativo do app, e a config o inclui | kitty, foot, ghostty, alacritty, Hyprland (`conf/palette.lua`) |
| **Bloco gerado inline** | Mesmo conteúdo, mas colado dentro da folha entre marcadores, porque o app não consegue importar | wofi |
| **Cores nomeadas geradas** | O gerador mapeia a paleta nos nomes que o toolkit já pinta, e o app segue sem saber | GTK3, GTK4/libadwaita |
| **INI mesclado** | O gerador substitui só as seções de cor de um arquivo que outro programa também escreve | KDE (`kdeglobals`) |
| **Escrito à mão** | Cor se mistura com config estrutural, então gerar arriscaria corromper o que não é cor | swaylock, bottom, starship, fastfetch, fish, yazi, `nvim/theme/roles.lua`, Sway |

Os escritos à mão são os que envelhecem em silêncio quando a paleta muda, e por isso
existe `scripts/theme/check_palette.py`: ele acusa hex fora da paleta, nome de cor de
terminal em config de fish ou starship, e arquivo `GENERATED` editado à mão. Rode depois de
mexer em cor. A verificação por nome existe porque doze variáveis do fish passaram o
retheme inteiro em `green`, `red` e `brgreen` enquanto a verificação por hex passava
limpa.

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
- **Recolouring preserves the previous version; restructuring does not.** Files whose
  colours changed keep their old version beside them (`*.kanagawa.css`, `*.kanagawa.legacy`,
  commented-out `include` lines). Files removed by a redesign are gone from the working
  tree and recoverable from git instead: wlogout's lavender PNGs, and waybar's three
  drifting config variants.

## Key decisions

- **Role model**: focus/active/selected is **Ice**, not Bordeaux — Bordeaux is reserved for
  identity/primary-action (terminal cursor, prompt accent, lockscreen accent). A
  **Verdigris** family fills the ANSI cyan slot the core palette has no family for.
  Terminal cursor is `bordeaux-300`; terminal selection background is `ice-600`.
  "Semantic states" are called **alert tones** (`alert-critical/caution/good/neutral`).
- **Radius became a system rule instead of a one-off exception.** It had been "0 everywhere,
  except Hyprland windows at 4px". It is now decided by whether a surface floats: floating
  surfaces (windows, launcher, notifications, the power menu) take 4px, docked ones (the
  bar) take 0. Two values, no scale. Alongside it, **weight 500 is the UI font weight** for
  every GTK app — Regular thins out on surfaces this dark. Both live in `palette.json`
  under `geometry`; Hyprland and swaync read them, while GTK3 apps (waybar, wofi, wlogout)
  carry the literal because GTK3 has no CSS custom properties.
- **Neovim has its own colorscheme, borrowed in structure but not in dependency.** The
  three-layer split came from reading kanagawa: a raw palette, a semantic layer of roles,
  and highlight groups that read only from the roles. That separation is what lets the theme
  be recoloured without touching hundreds of group definitions, and it is the part worth
  copying. Nothing depends on kanagawa at runtime; it stays declared with `enabled = false`
  as a rollback.

  Syntax follows the editor entry in the guide: Bordeaux on keywords, since Bordeaux is the
  identity mark and keyword is the most structural token; Ice on functions, since focus is
  Ice across the whole desktop; moss for strings, bronze for numbers and operators,
  Verdigris for types, which is the slot it was added to the palette for; comments at ink-4
  nominally. Selection is Ice, search is bronze, so the two states never read as the same
  thing. `:terminal` takes the ANSI table verbatim, so the non-negotiable about ANSI being
  identical everywhere holds inside the editor too.

  Transparency is deliberate and Jeff's call: `Normal` is unpainted so the editor matches
  the terminal at 0.92, while popups, menus and floats stay opaque, because text over text
  cannot be read. The cost of a standalone theme is that nothing covers what you miss: 55
  groups were found falling through to Neovim defaults by diffing our group names against
  kanagawa's, and closed.
- **Qt applications are themed through kdeglobals, which is generated too.** All nine Qt
  applications here are KDE ones, and they read their palette from that file rather than
  from anything GTK. `generate_theme.py` emits a KDE colour scheme, installs it as
  `Voidashi.colors` so it is selectable, and merges its colour sections into kdeglobals,
  which is what applications actually read. Window chrome is void-10, content void-00,
  buttons void-20, tooltips void-30, selection ice-600, matching the GTK mapping so the two
  toolkits agree.

  The bug behind the white Dolphin was not a missing theme. `QT_QPA_PLATFORMTHEME` was set
  to `qt6ct`, which exists for Qt applications that are not KDE, and with no `~/.config/qt6ct`
  to read it served its own default light palette over a kdeglobals that was already dark.
  It now points at `kde`. Worth noting for its own sake: the dark scheme it was hiding was
  BreezeDark, whose greys are blue-tinted, which the guide forbids outright.
- **yazi is the terminal file manager**, themed by hand in `.config/yazi/theme.toml` since
  its colours mix with structural config. It inherits the emulator's background and ANSI
  table and supplies only its own chrome: Ice for the hovered row, Bordeaux on the mode
  indicator as the identity mark, alert tones for real states.
- **Ordinary GTK applications are themed by overriding named colours, not by shipping a
  theme.** `generate_theme.py` maps the palette onto the names GTK and libadwaita already
  paint from and writes `.config/gtk-{3.0,4.0}/voidashi.css`, which each `gtk.css` imports
  after the Breeze files that `kde-gtk-config` leaves there. Window chrome sits at void-10
  and content at void-00, so a text view reads as recessed into the window, the same
  relationship the terminals have. `adw-gtk3-dark` is the GTK3 theme, which gives GTK3 and
  GTK4 applications the same widget shapes as well as the same colours. The font moved from
  Noto Sans, which no part of the design system uses, to Instrument Sans.

  Two things made this harder than it reads. On GTK 4.22 the accent answers only to CSS
  custom properties, while surfaces still answer to `@define-color`, so half the file
  appeared to work and the accent stayed Adwaita blue. And the GTK4 apps here are the ones
  worth caring about: pavucontrol, which the bar opens on the volume click, plus zenity,
  zathura and the network dialogs. The GTK3 side is nearly empty, since the only GTK3 apps
  on this machine are waybar, wofi and wlogout, all of which we style directly.
- **hyprlauncher is themed through the toolkit, not through itself.** It has no colour
  options: its own config covers behaviour only (`general:grab_focus`, `ui:window_size`,
  `finders:*`). Appearance comes from hyprtoolkit, which reads
  `.config/hypr/hyprtoolkit.conf` — a new file, top-level keys, no sections. The launcher
  on `mainMod+R` is wofi; the hyprlauncher theme is kept because that file covers any
  hyprtoolkit application and makes switching back a one-line change. Roles follow the launcher entry in the guide: void-20 surface, the
  input one step lighter, Ice for selection, Bordeaux as the identity mark, radius 0.
- **swaync now has a `config.json`**, which it never had — it had been running entirely on
  `/etc/xdg` defaults, so nothing about it was a deliberate choice. Its stylesheet was also
  rewritten: swaync paints from custom properties on `:root`, and the earlier pass wrote
  its own selectors instead of overriding those, so notifications kept upstream's 12px
  radius and critical ones kept the default surface. Urgency now carries a **shape**
  signal — a heavy left rule on critical — because swaync exposes no way to inject a glyph
  per urgency, and colour may not carry a state alone.
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
- **Waybar is marked, not filled.** The active workspace carries a 3px `bordeaux-400` rule
  beneath it instead of an `ice-800` block, and modules no longer sit on individual
  `void-20` pills — a row of raised chips is what made the bar read as a default status
  bar. Bordeaux stays the identity mark here rather than becoming a second focus colour;
  Ice remains focus everywhere else, including Hyprland's window borders. Workspace labels
  are numerals in both bars, where before Sway showed app glyphs and Hyprland showed
  numbers.
- **Bar glyphs are sized in the config, not the stylesheet.** They arrive from Hack Nerd
  Font through fontconfig fallback and are drawn smaller per em than Instrument Sans, so at
  a shared `font-size` they looked undersized next to their own labels. `common.jsonc` wraps
  each `{icon}` in Pango `<span size="110%">`, which is relative to the stylesheet size, so
  the two move together. Glyph codepoints need checking before use: Nerd Fonts v3 dropped
  the `nf-mdi-*` range, and four icons inherited from the old config had been rendering as
  boxes because of it.
- **Terminals: 0.92 opacity and 8px padding, all four.** Both were inconsistent — three
  different opacities and no padding set anywhere, so each emulator used its own default.
  The guide's "opaque by default" was rewritten to describe the transparency actually in
  use; foot's `alpha` sits in a second `[colors-dark]` block in `foot.ini`, since the
  generated palette include must not be hand-edited.
- **Hyprland keeps a small blur (`size=5, passes=1`).** The guide had answered this with a
  flat "no"; Jeff's call is that a small amount is right for this desktop, and
  `RICE-GUIDE.md` and `CLAUDE.md` were amended to say so. The window radius that arrived
  with it has since been generalised into the floating/docked rule above.
- **Animation durations sit a notch above the guide's original table** (windows 300ms,
  workspace 350ms, focus 150ms, fade 200ms) with the ease-out curve now applied to every
  leaf. The old values were 600–1000ms, slow enough to be the daily-use complaint that
  started this; the guide's UI-transition numbers read as abrupt on full windows, so the
  motion table was rewritten around a ~400ms ceiling.
- **wofi's palette is inlined, not imported** — it is the one GTK app whose `@import`
  resolves against the process cwd. See `CLAUDE.md`.
- **GTK apps use Instrument Sans, not Iosevka Extended.** waybar, wofi and wlogout (GTK3)
  and swaync (GTK4) fall under the guide's "GTK / Qt application theming" rule, not the
  typography table's mono-primary row, which is for bars that render their own text outside
  a toolkit. The guide's typography table now says so explicitly.
- Iosevka Extended, Instrument Sans and Spectral are symlinked from `fonts/` into
  `~/.local/share/fonts/dotfiles` by `backup-configs.sh install`. `fonts/Iosevka/` itself is
  `.gitignore`d — its full-family build is ~430MB, too large to version; see the README's
  Fonts section for where to re-download it.

## Known gaps / deliberately not done

- Neovim colorscheme and wallpaper curation remain untouched. Both are scoped tasks of
  their own; see `docs/TODO.md`.
- Waybar's redesign is in and the sizing was tuned against live feedback, but three things
  are still only settled provisionally: whether numerals beat the old app glyphs on the
  workspace buttons, whether the right-hand modules want separators or should stay spaced
  only, and whether 15px/500 is the right weight once it has been lived with.
- The Neovim colorscheme is now the largest remaining visual gap.
