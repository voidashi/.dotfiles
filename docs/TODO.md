# TODO

Open work, carried across sessions. Check this before assuming the rice or the repo is
finished.

Each item carries a **difficulty** and a **priority**. Difficulty is about how much work
and how much can go wrong; priority is about how much it costs to leave undone. They are
independent: the two broken keybinds are trivial and urgent, the elegance pass is neither.

Decisions already made, and state that is merely being tracked, do not live here. Those
belong in `CLAUDE.md` (rules and gotchas), `docs/design/THEME-STATUS.md` (what is themed)
and `docs/SESSION-HISTORY.md` (what happened).

## Now: things that are broken

- **Workspaces are not clickable in waybar.** Clicking a workspace button does not switch
  to it. The module has no `on-click`, and neither did the config that preceded the
  rewrite, so this has most likely never worked rather than being a regression. Reproduce
  first, then fix in `.config/waybar/common.jsonc`.
  *Difficulty: low. Priority: high.*

- **No bind moves a window by direction.** `SUPER + SHIFT + arrows` does nothing.
  `conf/binds.lua` binds `SUPER + arrows` to focus only; directional window movement was
  never bound at all, and `SUPER + SHIFT + [0-9]` covers workspaces rather than direction.
  Add it with `hl.dsp.window.move`, checking whether the dwindle layout wants `move` or
  `swap` for the behaviour Jeff expects.
  *Difficulty: low. Priority: high.*

## Next: the largest visual gap

- **GTK3 and GTK4 applications are unthemed.** Everything themed so far is a shell surface
  (bar, launcher, notifications, power menu). Ordinary applications still render in their
  stock theme, and GTK4/libadwaita is the worst of it: its default palette fights the
  desktop around it. Either adapt an established theme to the Voidashi palette or build
  one. GTK4 does not read `~/.themes` the way GTK3 does, so the two need different
  mechanisms, and libadwaita applications need their named colours overridden rather than
  a theme swapped underneath them.
  *Difficulty: high. Priority: high.*

- **Neovim colorscheme.** Not themed at all. Needs a Voidashi highlight-group mapping: the
  editor role in `RICE-GUIDE.md` gives void-00 for background, ink for text, the identity
  families plus Verdigris for syntax categories, Ice for selection and cursor line, and
  comments at ink-4. A scoped task of its own, not an add-on to anything.
  *Difficulty: high. Priority: medium.*

## Then: quality and housekeeping

- **Elegance pass over structure, organisation and code.** Several things work but are not
  elegant. Worth a deliberate sweep for duplicated structure, files that exist for no
  current reason, inconsistent naming across the scripts, and configs that repeat what a
  shared source could hold. Open-ended by nature, so it should produce a list to approve
  before anything is moved.
  *Difficulty: high, and open-ended. Priority: medium.*

- **Delete `conf.d.legacy/` and `hyprland.conf.legacy`.** The Lua config has proven itself
  in daily use, so the pre-Lua rollback copies can go. Jeff has authorised this.
  *Difficulty: trivial. Priority: medium.*

- **Wallpaper curation.** Still whatever it was before. Needs real images chosen against
  the Wallpaper section of `RICE-GUIDE.md`: material, desaturated, dark, sitting at or
  below void-00 in perceived lightness. This needs assets, not config edits.
  *Difficulty: medium, but blocked on sourcing images. Priority: medium.*

## Ongoing: how the writing reads

- **Drop the AI writing tells from the docs.** The em dash above all, which is scattered
  through every document in `docs/` and most config comments. Also the tic of stating a
  thing, then restating it inverted ("not x, but y"), and openers like "worth noting".
  This applies to everything written from here on, and existing files get cleaned as they
  are touched rather than in one pass.
  *Difficulty: low per file, large in aggregate. Priority: low, but permanent.*
