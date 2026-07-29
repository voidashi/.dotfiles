# TODO

Open work, carried across sessions. Check this before assuming the rice or the repo is
finished.

Each item carries a **difficulty** and a **priority**. Difficulty is about how much work and
how much can go wrong; priority is about how much it costs to leave undone. They are
independent: deleting the legacy configs was trivial and worth doing, the elegance pass is
neither trivial nor urgent.

Decisions already made, and state that is merely being tracked, do not live here. Those
belong in `CLAUDE.md` (rules and gotchas), `docs/design/THEME-STATUS.md` (what is themed)
and `docs/SESSION-HISTORY.md` (what happened).

## Parked: diagnosed, not solved

- **Workspaces are not clickable in waybar, and it is not our config.** A full bisect ruled
  out everything on our side, so this is parked rather than solved. What is established:

  - Not the stylesheet. It fails identically with `/etc/xdg/waybar/style.css`.
  - Not the layer. It fails on both `bottom` (waybar's default) and `top`.
  - Not `persistent-workspaces`. It fails with both the legacy `{"1": [], ...}` form and
    the documented `{"*": 5}` form.
  - Not a missing `on-click`. Probes on `on-click`, `on-click-right`, `on-click-middle`
    and `on-scroll-up` running `notify-send` never fired once.
  - Not the bar's input in general. `clock` toggles and `custom/power` opens the menu, and
    hovering a workspace button does highlight it, so the widget receives motion events.
  - Nothing reaches Hyprland either: with `-l debug`, a click produces no dispatch line and
    no `workspace>>` event, while a keyboard switch produces both.

  So the buttons in waybar 0.15.0's `hyprland/workspaces` take motion events but no button
  events at all, in this build. Next avenues, in order of cost: check upstream issues for
  this version, try a different waybar build, or replace the module with a `custom` one
  that renders and dispatches workspaces itself, which would cost the module's live
  updates. Three genuine config defects were fixed along the way and are worth keeping
  regardless: `layer` is now `top`, `persistent-workspaces` uses the documented form, and a
  `disable-scroll` that belongs to `sway/workspaces` was removed.
  *Difficulty: high, now that the cheap explanations are gone. Priority: medium, since
  keyboard switching works and this is a convenience.*

## Next: the largest visual gap

- **Neovim colorscheme, plus the plugins that draw their own interface.** Still on
  kanagawa-dragon with `transparent = true`, so the editor currently borrows whatever the
  terminal is showing rather than the void-00 the guide specifies. The colorscheme is the
  smaller half of this: eleven plugins render chrome that a colorscheme does not reach, and
  each needs its highlight groups mapped. `lualine` (which sets no theme today and
  auto-detects kanagawa's), `neotree`, `telescope`, `cmp`, `gitsigns`, `welcome`,
  `toggleterm`, `colorizer`, and the LSP diagnostic groups. Syntax itself comes from
  treesitter and follows the colorscheme.

  Roles from the editor entry in `RICE-GUIDE.md`: void-00 background, ink for text, the
  identity families plus Verdigris for syntax categories, Ice for selection and cursor
  line, comments at ink-4. Two decisions to make up front: whether to write a Voidashi
  colorscheme from scratch or override kanagawa's groups, and whether to keep transparency
  now that the terminals sit at 0.92 with compositor blur behind them.
  *Difficulty: high. Priority: medium.*

## Then: quality and housekeeping

- **Elegance pass over structure, organisation and code.** Several things work but are not
  elegant. Worth a deliberate sweep for duplicated structure, files that exist for no
  current reason, inconsistent naming across the scripts, and configs that repeat what a
  shared source could hold. Open-ended by nature, so it should produce a list to approve
  before anything is moved.
  *Difficulty: high, and open-ended. Priority: medium.*

- **Wallpaper curation.** Still whatever it was before. Needs real images chosen against
  the Wallpaper section of `RICE-GUIDE.md`: material, desaturated, dark, sitting at or
  below void-00 in perceived lightness. This needs assets, not config edits.
  *Difficulty: medium, but blocked on sourcing images. Priority: medium.*

## Low priority

- **Dolphin's icons are still breeze-dark**, so folders come out blue against a Voidashi
  window. It is the only monochrome-ish set installed, and the alternatives on the machine
  (Adwaita, breeze, Breeze_Light) are no better aligned. Needs an icon theme chosen and
  installed, which is a different kind of work from everything else here: an asset
  decision, not a config one.
  *Difficulty: low once a set is chosen. Priority: low.*

- **`qt6ct` is installed and now unused.** `QT_QPA_PLATFORMTHEME` points at `kde`, so it
  does nothing. Decide whether it comes out of `packages.conf` or stays as a fallback for
  some future Qt application that is not a KDE one. Costs nothing where it is.
  *Difficulty: trivial. Priority: low.*

## Ongoing: how the writing reads

- **Drop the AI writing tells from the docs.** The em dash above all, which is scattered
  through every document in `docs/` and most config comments. Also the tic of stating a
  thing, then restating it inverted ("not x, but y"), and openers like "worth noting".
  This applies to everything written from here on, and existing files get cleaned as they
  are touched rather than in one pass.
  *Difficulty: low per file, large in aggregate. Priority: low, but permanent.*
