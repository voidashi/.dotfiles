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

## The repository stops at `$HOME`

Nothing here writes outside a user's home directory and nothing here manages a
system service. That is a decision rather than an omission, and it is what lets a
clone behave the same on a second machine: a dotfiles repository that needs an
`/etc` edit to work does not travel.

It answers three questions that would otherwise sit open. Theming the greeter would
mean generating into root-owned `/etc/greetd/`. Power profiles would mean
`systemctl enable` on a system unit, which `backup-configs.sh` has no business
doing. And a lid switch that misreports its own state would be corrected in logind's
configuration, which is why one such episode was closed rather than chased.

The line is the write, not the read. Declaring a package that owns a system file is
fine, and `SETUP.md` may tell a reader to run `systemctl enable` themselves. What
the scripts must not do is make that change on someone's behalf.

So this closes the question for the repository and not for its owner. Theming the
greeter and setting a power profile stay in `docs/TODO.md` as things done by hand,
with `SETUP.md` as the place a reader is told to do the same.

## Two scripts, and no inverse of `add`

`unlink-dotfiles.sh` moved the repository's files back out into `$HOME` and emptied
the clone, which is the inverse of `add` and not of `install`. Once `uninstall`
existed, its whole remaining footprint in the documents was disclaimers: six places
existed only to tell a reader this was not the script they wanted, and every edit to
those documents paid that tax. It was deleted.

A per-path `unadopt` was proposed to replace it and rejected, as was documenting the
`mv` that does the same thing: too little function for a command, for an operation
performed about once. Reopen only if the manual step turns out to be taken often
enough to hurt.

## `DESIGN-SYSTEM.md` is a guest, and the terms are written down

It is the largest file in the repository, no config cites it, its tokens appear
nowhere else in the tree, and every one of its hexes but pure white is already in
`palette.json`. Two separate audits have proposed deleting it.

It stays because it is live reference for web and print work outside this
repository, which is a fact about its author rather than about the repo, and no
audit of the tree can reach it. So the terms, to stop this being reopened a third
time: it never stops being useful in general, which makes that the wrong test. The
only question this repository asks is whether it still earns a place in this tree,
and the day it does not it moves to where the web work lives rather than being
deleted.

## Four cuts that were proposed and refused

An audit went looking for what no longer earns its place and a second reviewer
argued against everything it proposed. These four did not survive, and each still
looks cuttable from the outside, which is the only reason they are written down.

- **`RICE-GUIDE.md` keeps "Working rules" and "Anti-patterns".** The section opens
  by saying each rule is there because breaking it cost something, and `CLAUDE.md`
  points at both by name and says not to restate them here. Moving the owner leaves
  that pointer dangling.
- **The Qt entry in `SETUP.md` keeps its length.** It is a two-cause diagnostic and
  only the first cause duplicates `MAINTENANCE.md`. The second, that
  `plasma-integration` is missing so the variable is set and nothing reads it, is the
  only copy on a reader's path and carries its own check.
- **`backup-configs.sh init` is not dead code.** `DOTFILES_DIR` is overridable and is
  not derived from `SCRIPT_DIR`, `add` fills the repository it creates, and the test
  suite relies on that override for every one of its cases.
- **`mediaplayer.py` stays beside the bar.** `scripts/wm/` holds helpers the
  compositors call, and waybar is not a compositor. The script is bound to
  `common.jsonc` by a serialisation contract its own docstring names.

## Three things about the bar are provisional

Settled only until they have been lived with: whether numerals beat application
glyphs on the workspace buttons, whether the right-hand modules want separators or
should stay spaced only, and whether 15px at weight 500 is the right text size.
Nothing is owed on these. They are recorded so that changing one is not mistaken for
undoing a decision.

Open work of every kind lives in `docs/TODO.md`, including what is diagnosed and
deliberately parked. It is not repeated here.
