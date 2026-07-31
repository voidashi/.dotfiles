# Turning points

Why this repository is shaped the way it is. Each entry is a decision whose
result is visible in the tree but whose reason is not, which is the only kind of
thing worth keeping here.

Not a changelog. The git log holds the blow by blow, attached to the diffs that
prove it. An entry earns a place here only when a decision changed the shape of
the repository, and the test is whether someone reading the configs would
otherwise be left guessing.

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
into the format each application natively reads, which takes six different
mechanisms because toolkits do not accept the same treatment; the table in
`docs/design/THEMING.md` maps which application uses which.

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

## The documents were rewritten for a reader who did not write them

They had been written for whoever was already inside the work, which is a
different document from the one someone who cloned it needs. The rewrite happened in one
pass and left three marks worth knowing about.

The README had been claiming four features that did not exist, found by checking
its own feature list against the configs rather than reading it. They are now in
`docs/TODO.md` as work to do and in the README as a Known gaps section, because a
gap you are told about costs a reader nothing and a gap you discover costs trust.

`DESIGN-SYSTEM.md` is the identity system for web and document work, and three of
its sections describe apparatus a desktop has no equivalent for: a 12-column
grid, the three-context matrix, and WCAG conformance through a high-contrast
alternate mode. They are summaries rather than specifications here, keeping the
decision and dropping the tables, which is why those sections read thinner than
the rest of the file.

This document was called `SESSION-HISTORY.md` and read as a log of who decided
what. What survived the rename is only the decisions whose result is visible in
the tree while the reason is not, which is a smaller and more useful thing.

A second pass split the documents by audience, which is why two of them have
names that do not match their git history. `docs/MAINTENANCE.md` is new, and most
of it was written elsewhere: the repository's pitfalls had accumulated in a file
meant for an AI coding agent, where they were unreachable by anyone who cloned
this and would have gone in the bin the day that file did. And
`docs/design/THEMING.md` was `THEME-STATUS.md`, because a document that tracks
status accumulates a changelog, while what a reader wants from it is the
reference: which mechanism carries colour to which application. The history it
used to carry is either a pitfall, in which case `MAINTENANCE.md` has it, or it
is in the git log.

## Some configs are kept deliberately, and are not dead weight

Five things here are kept for a program or a variant that is not in use. They look
like leftovers and are not, which is the only reason this entry exists. Keep the
list complete: when it named only the first two, an audit reported the rest as
dead weight and had to be told otherwise.

Which of each pair is actually in use is decided in one file, named below, and is
deliberately not repeated here. Repeat it and this entry goes false the moment
that line changes, with nothing to catch it.

- `.config/dunst/`, against swaync. Decided in `hypr/conf/autostart.lua` and
  `sway/config`.
- `.config/hypr/hyprpaper.conf`, against swaybg. Decided in the same two files. It
  preloads an image this repository does not carry, so switching back means editing
  it rather than only reading it.
- `.config/hypr/hyprtoolkit.conf`, which themes hyprlauncher, against wofi. Decided
  in `hypr/conf/programs.lua`.
- `.config/catnap/`, against fastfetch. Decided in `.config/fish/config.fish`.
- `.config/fastfetch/` beyond the preset that file runs. The other presets are
  dormant by choice, kept for the day the greeting changes rather than as history.

These stay themed and tracked so that switching is reading a file rather than
writing one.

Open work of every kind lives in `docs/TODO.md`, including what is diagnosed and
deliberately parked. It is not repeated here.
