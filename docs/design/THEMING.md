# How the palette reaches each application

Reference, not history. [`RICE-GUIDE.md`](RICE-GUIDE.md) holds the rules and the
palette itself; this document says which route each application's colour arrives by,
what each surface is set to, and which design decisions are settled. Open work lives in
[`TODO.md`](../TODO.md), and the pitfalls of editing any of it are in
[`MAINTENANCE.md`](../MAINTENANCE.md).

Read the mechanism table before theming anything new. Picking the wrong route is how a
change ends up looking applied and doing nothing.

## The six mechanisms

Six, because different toolkits do not accept the same treatment. The first two differ
only in how the file is pulled in, but the distinction is the one that matters when a
colour fails to arrive.

| Mechanism | How it works | Applications |
|---|---|---|
| **Generated partial, included** | The generator writes a colour-only file in the application's native format and its config includes it | kitty, foot, ghostty, alacritty, Sway (`sway/voidashi-colors`), Hyprland (`conf/palette.lua`), hyprtoolkit (`hypr/voidashi-toolkit-colors.conf`), Neovim (`theme/palette.lua`), yazi (`yazi/flavors/voidashi.yazi/flavor.toml`), catnap (`catnap/themes/voidashi.cat`) |
| **Generated partial, `@import`ed** | The same idea through CSS: one shared file at `.config/theme/voidashi-colors.css`, imported by path on the stylesheet's first line | waybar, swaync, wlogout |
| **Generated block, inlined** | The palette pasted into the file itself between markers, because the application cannot include anything | wofi, starship, swaylock, bottom |
| **Generated named colours** | The palette is mapped onto the names the toolkit already paints from, and the application carries on unaware | GTK3, GTK4 and libadwaita |
| **Merged INI** | Only the colour, font and cursor keys of a file another program also writes | KDE (`kdeglobals`, `kcminputrc`) |
| **Hand-written** | No route the survey could find, or colour that is a per-file decision rather than a palette value | fastfetch, fish, `waybar/common.jsonc`, `nvim/theme/roles.lua` |

The hand-written ones are the ones that age in silence, which is why
`scripts/theme/check_palette.py` exists. Run it after touching colour. Why the
last row is only four entries, and which proposals were refused to get there, is
in [`TURNING-POINTS.md`](../TURNING-POINTS.md).

A block inlined into an application's own config is a wrapper and not that
application's mechanism, so each of the four says so in the file itself. Reach
for one only when the application has no include at all, which is measured
rather than assumed: swaylock and bottom each take one config file and no
directive to pull in another.

## The pipeline

`scripts/theme/palette.json` is the single source of truth, transcribed from
`RICE-GUIDE.md`. Edit it there, never a hex in an application config.

`scripts/theme/roles.py` sits between the palette and the output and holds what a colour
is *for*: window chrome is `surface.window`, selection is `selection.bg`, the terminal
cursor is `identity.cursor`. Every role names a token rather than repeating its hex, and
one that does not is refused at load. This is the same three-layer shape the editor's
theme has had all along, and it is why one decision reaches GTK, Qt and the terminals
without being written three times: before it existed, "the window chrome is `void-10`"
was typed in three separate places and "selection is `ice-600`" in four.

Two things skip the layer. `ansi16` is consumed raw by the four terminals and by Neovim,
because slot 1 is red whatever this desktop's identity colour happens to be, and
`geometry` and `typography` are values with no decision to add.

`scripts/theme/generate_theme.py` **writes** files whole, each in the format its
consumer already reads: the four terminal partials, Sway's variables, the Hyprland Lua
module, hyprtoolkit's six colour keys, the Neovim palette layer, yazi's flavor,
catnap's `.cat` theme, the shared CSS partial at `.config/theme/voidashi-colors.css`,
the GTK3 and GTK4 named-colour files, and the selectable KDE colour scheme
`Voidashi.colors`. `generated_files()` is the list; `check_palette.py` prints how many
there are, so no count is written here.

Sway's partial holds variables and nothing else: which window state takes which role is
hand-written beside the `client.*` directives that read them, the same split as
Hyprland, where `appearance.lua` decides and `palette.lua` is generated. It is also what
gives the file a check that can fail, since `sway --validate` rejects a `$vd_*` that no
include defined.

It also **edits** files it does not own rather than writing them: wofi's stylesheet,
`starship.toml`, swaylock's config and `bottom.toml`, where the palette is spliced
between markers because none of the four can include a file, and `kdeglobals` plus
`kcminputrc`, where colour, font and cursor keys are merged in one by one so nothing
of KDE's own is lost. The distinction matters when reading the generator:
`generated_files()` holds the ones it writes whole and `merged_files()` the ones it
merges into. Output written whole carries a `GENERATED` header and must not be
hand-edited.

`check_palette.py` proves it held: no colour outside the palette, in any of the five
forms colour is written here; no named terminal colour in fish or starship; no file
written whole that differs from what the generator would produce now; no section of a
merged file that a second merge would change, which is what a hand-edit to one looks
like; and no starship style naming a colour its own palette table does not define, which
would render that segment uncoloured without a word. It also warns, without failing, when a role literal holds a hex no scale or alert
tone holds, since a duplicated value keeps a retired colour inside the palette and hides
every file still carrying it.

## What each surface is set to

**Terminals**, all four identically: the full palette, the ANSI table verbatim, Iosevka
Extended at size 12, 0.92 opacity, 8px padding. Four emulators at three opacities is
the same failure as four ANSI tables. foot's `alpha` sits in a second `[colors-dark]`
block in `foot.ini`, because the generated include must stay untouched.

**Compositors.** Focused border Ice, unfocused `edge-30`, windows at the 4px floating
radius, gaps from the spacing scale. Hyprland runs a small blur, `size=5, passes=1`,
which is a deliberate exception the guide records. Animation is ease-out on every leaf:
windows 300ms, workspace 350ms, focus 150ms, fade 200ms, under a ~400ms ceiling. Sway
mirrors `hypr/conf/appearance.lua`.

**Bar.** `void-10`, compact, modules at `ink-3` at rest. The active workspace carries a
3px `bordeaux-400` rule beneath it rather than a filled block, and modules do not sit on
individual pills, because a row of raised chips is what makes a bar read as a default
status bar. Bordeaux is the identity mark here; Ice stays focus everywhere else. Glyphs
come from Hack Nerd Font through fontconfig fallback and are drawn smaller per em than
Instrument Sans, so `common.jsonc` wraps each `{icon}` in a Pango `<span size="110%">`,
relative to the stylesheet size so the two move together.

**Launcher.** wofi on `void-20`, input one step lighter, Ice on the selected entry,
Bordeaux on the prompt. Its palette is inlined rather than imported. hyprlauncher is
configured too and takes its appearance from `.config/hypr/hyprtoolkit.conf`, since its
own config covers behaviour only; that file's six colour keys are sourced from a
generated partial and the rest of it, rounding and fonts, stays hand-written. Rendered
and sampled once: the surface comes out `191817`, against `181818` for the toolkit's
own default, and the corners are square. The selected entry and the identity mark were
not on screen in that capture, since the list was empty.

**Notifications.** swaync on `void-20`, painting from custom properties on `:root`
rather than from our own selectors, which is what makes upstream's radius and surfaces
give way. Urgency carries a **shape** signal, a heavy left rule on critical, because
swaync exposes no way to inject a glyph per urgency and colour may not carry a state
alone.

**Power menu.** wlogout as a centred vertical list of six labelled rows, ordered by
escalating consequence, reboot and shutdown last and turning `alert-critical` on
approach. Every row keeps both glyph and label, so colour reinforces rather than
carries. Glyphs are text in the `layout` file, so they inherit `color`. Geometry lives
in `scripts/wm/power-menu.sh`, because wlogout accepts it only as CLI flags.

**Lock screen.** swaylock on solid `void-00`, Spectral, the typing indicator in Bordeaux
as the lockscreen accent, `alert-critical` on a wrong password alongside
`show-failed-attempts`, so the state is not carried by colour alone.

**Editor.** The Neovim colorscheme is ours, in three layers: a generated palette,
hand-written roles where the design decisions live, and highlight groups that read only
from roles. Syntax follows the guide's editor entry: Bordeaux on keywords, Ice on
functions, moss on strings, bronze on numbers and operators, Verdigris on types,
comments at `ink-4`. Selection is Ice and search is bronze, so the two never read as the
same state. `:terminal` takes the ANSI table verbatim. `Normal` is unpainted so the
editor matches the terminal's 0.92, while popups, menus and floats stay opaque, because
text over text cannot be read.

**Fetches.** Colour is assigned by what a row means, not by rotation: Bordeaux on
identity, Ice on function, Moss on duration, Ash on media, ink on counts, with the key
carrying the family and the value staying `ink-2` so the content column reads uniformly.
Bronze and Verdigris stay out. A one-accent variant of every fastfetch preset lives in
`.config/fastfetch/minimal/`, because the competing reading is also legitimate: the
guide calls a fetch the desktop's cover page, and a cover page wants one focal point.
catnap follows the same mapping row for row. It could not until it moved to the `.cat`
format, whose theme import takes hex: under 1.x its whole vocabulary was seven ANSI
tokens with no grey among them, so its keys sat at `ink-2` where fastfetch's sit at
`ink-4`. Its distro art names the same roles, which is why the CachyOS logo is
Bordeaux rather than the Verdigris upstream draws it in.

**Terminal file manager.** yazi inherits the emulator's background and ANSI table and
supplies only its own chrome: Ice on the hovered row, Bordeaux on the mode indicator,
alert tones for real states. That chrome is a generated flavor and `theme.toml` keeps
only the border glyph, the status separators and the button labels. Its chrome reads
roles so the cursor row moves with GTK's and Qt's selection; its file-type
classification names scale steps, because which family marks an archive is a decision
this document leaves to the application.

The icon glyph beside each name is the one thing on that screen that is not ours.
yazi's binary carries an `[icon]` table with a colour per file type, and it stays
upstream's. Its sources are not one palette: the named directories are Material, and
the file rules carry each language's own brand colour, Rust's for `.rs` and the
Linguist shell green for `.bashrc`. Overriding it means restating hundreds of rules,
each of which
carries a glyph as well as a colour, so it would be a copy of somebody else's data
that ages without a word: the same reason the ANSI mapping is canonical rather than
re-derived per application. What it costs is a handful of off-palette hues among the
glyphs. What limits the cost is that the filename beside the glyph is already on the
palette through `[filetype]`, and a plain directory takes Ice from it, because yazi
gives generic directories no colour of their own and only named ones like `.git` or
`Downloads` carry upstream's. No tracked file holds those hues, so `check_palette.py`
cannot see them and never could; `check_render.py` names them on every run instead.

**Ordinary GTK applications** are themed by overriding the named colours GTK and
libadwaita already paint from, not by shipping a theme. Window chrome sits at `void-10`
and content at `void-00`, so a text view reads as recessed into the window, the same
relationship the terminals have. `adw-gtk3-dark` gives GTK3 and GTK4 the same widget
shapes as well as the same colours. The GTK4 applications are the ones that matter here,
pavucontrol among them; the GTK3 side is nearly empty, since waybar, wofi and wlogout
are styled directly.

**Qt and KDE applications** read their palette from `kdeglobals`. Window chrome
`void-10`, content `void-00`, buttons `void-20`, tooltips `void-30`, selection `ice-600`,
matching the GTK mapping so the two toolkits agree. Applications that are not KDE ones
reach the same palette through the KDE platform theme.

**Fonts.** All four faces in `fonts/` are symlinked into
`~/.local/share/fonts/dotfiles` as a directory, so Hack Nerd Font arrives with Iosevka
Extended, Instrument Sans and Spectral. Hack is what the bar's glyphs come from. GTK and Qt application UI uses Instrument Sans at
weight 500, not Iosevka: they fall under the guide's GTK and Qt rule, not the typography
table's mono-primary row, which is for bars that render their own text outside a toolkit.

## Settled decisions

- **Role model.** `RICE-GUIDE.md` owns which colour carries which role. What this file
  owns is that `roles.py` names each one once and every emitter reads the name, which is
  how the three steps of Ice reach four toolkits without being decided four times.
  `selection.bg` is `ice-600`, read by GTK4's `accent_bg_color`, GTK3's
  `theme_selected_bg_color`, Qt's `Selection` and yazi's hovered row. `accent.line` is
  `ice-300`, read by Sway's focus variable, GTK4's `accent_color`, GTK3's `link_color`,
  Qt's `ForegroundActive` and `ForegroundLink`, hyprtoolkit's `link_text` and yazi's cwd.
  `accent.decoration` is `ice-400`, read by Qt's `DecorationFocus` and `DecorationHover`,
  hyprtoolkit's `accent`, yazi's dialog borders and mode badge, bottom's graphs and
  catnap's function row. The boundary between the last two is in `RICE-GUIDE.md`, "The
  three steps of Ice"; swaylock is where to see it, since it draws both while verifying.
- **Bright green stays `moss-300`.** The alert tone displaces a ramp step only where the
  family's hue does not carry the signal a terminal expects, and Moss is already green;
  `RICE-GUIDE.md`, "On slots 9, 10 and 11", carries the measurement. What this file owns
  is the route: `ansi16` is the one table that skips `roles.py` and is consumed raw by
  the four terminals and Neovim, so no role reaches that slot and changing it means
  editing the table itself.
- **yazi's icon table stays upstream's.** The one deliberate patch of off-palette
  colour on the desktop, decided rather than overlooked, with the reasoning in the
  terminal file manager paragraph above. `check_render.py` names the colours on every
  run, since no tracked file carries them and the drift check cannot.
- **Two radii, decided by whether a surface floats.** Floating takes 4px, docked takes
  0. No scale, no third value. Both live in `palette.json` under `geometry`; Hyprland and
  swaync read them, while GTK3 stylesheets carry the literal because GTK3 has no CSS
  custom properties.
- **Weight 500 is the UI font weight** for every GTK and Qt application. Regular thins
  out on surfaces this dark.
- **The accent budget is relaxed for fetches only.** The guide's ceiling of two families
  is written for a screen at rest. A fetch may show more, on the condition that each
  family lands on the rows that mean it rather than rotating. Ice belongs there because a
  fetch has nothing focused, which is what frees Ice to carry its other meaning,
  function.
- **Rollback is git, not a directory.** During the retheme every recoloured file kept its
  previous version beside it. Once the theme was proven, all 14 were deleted along with
  the commented references pointing at them, because they gave the impression of an
  active choice between themes where there was none. Do not reintroduce a legacy
  directory.

## Not covered yet

Wallpaper curation is the largest remaining visual gap and the only one that needs
assets rather than config. Dolphin still uses `breeze-dark` icons, so folders come out
blue. Three things about the bar are settled only provisionally: numerals against app
glyphs on the workspace buttons, whether the right-hand modules want separators, and
whether 15px at weight 500 survives being lived with. All of these are in
[`TODO.md`](../TODO.md) with what each one needs.
