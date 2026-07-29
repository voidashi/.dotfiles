# Turning points

Why this repo is shaped the way it is. Each entry is a decision that still
explains something you can see in the tree today.

**This is not a session log.** It used to be, one section per working session,
and that contract guaranteed two things: unbounded growth, and rot, because
nobody goes back to prune a diary. It reached 324 lines and had started
contradicting itself. The git log holds the blow by blow far better, attached to
the diffs that prove it. Add an entry here only when a decision changes the
shape of the repo. See `CONVENTIONS.md`.

## Hyprland moved from hyprlang to Lua

The config is `hyprland.lua` requiring `conf/*.lua`, in a load order that
matters: `programs` defines globals that `binds` reads. The old `.conf` tree
was kept for rollback and later deleted once daily use had proven the migration.

Worth knowing because it explains a trap: Hyprland prefers `hyprland.lua` when
both exist, so the old `hyprland.conf` sat inert for months, sourcing a
directory of settings that never applied while looking entirely alive.

## Silent failures are this repo's characteristic bug

Three separate times, something was configured, looked configured, and did
nothing:

- `plugins/lsp/` had no `init.lua`, and lazy.nvim only imports subdirectories
  that have one, so the entire LSP stack was never installed. No error.
- Sway's config carried the 41 Kanagawa colours as variables and used none of
  them, because the file had no `client.*` directive at all. It ran on stock
  blue while the repo looked themed.
- Twelve fish colour variables stayed on factory values because a file fish
  generated during a version upgrade defined more of them than ours did, and
  `conf.d` loads alphabetically.

None produced an error message. That is why verification here means measuring
the result rather than reading the config: sampling pixels out of a screenshot,
reading highlight groups back out of Neovim, diffing generated output against
what the generator would produce now.

## The palette became a single source of truth, then an enforced one

`scripts/theme/palette.json` holds every colour. `generate_theme.py` renders it
into the format each application natively reads, which is five different
mechanisms because five toolkits accept five different things; the table in
`docs/design/THEME-STATUS.md` maps which application uses which.

Applications whose colour keys mix with structural config are hand written
instead, and those are the ones that drift. `check_palette.py` exists because
"never invent a colour" was an honour system rule that went unenforced through
an entire retheme. It found Sway on its first run.

## Waybar became one bar described once

There were three configs: the root one Sway loaded, `fixed/` that Hyprland
loaded, and `floating/` that nothing loaded. Two were live, which is why they
drifted apart unnoticed. Now `common.jsonc` holds every module definition and
the two thin per compositor files add only their own `modules-left`.

## Applications are themed through what their toolkit already paints

Rather than shipping themes. GTK and libadwaita read named colours, KDE reads
`kdeglobals`, and both are generated from the palette. The Neovim colorscheme is
ours outright: it borrowed kanagawa's three layer structure (raw palette,
semantic roles, highlight groups that read only from roles) but depends on
nothing at runtime, because an override matched by key name breaks silently when
upstream renames a key.

## Open questions

- Clicking a workspace in waybar does nothing, and it is not our configuration.
  The full bisect is recorded in `docs/TODO.md`; do not re-derive it.
- `.config/dunst/` and `.config/hypr/hyprpaper.conf` are kept deliberately,
  unthemed, as references in case of a switch back. Decided, not pending.
