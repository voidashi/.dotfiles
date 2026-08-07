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

## The hand-written half was surveyed, and two of it stayed hand-written

Sixteen files pasted a palette colour by hand and followed nothing. Each was
asked one question against its own documentation or binary: can the palette
reach it. Most could, and did: Sway, hyprtoolkit and starship first, then yazi
through a generated flavor, catnap through a generated `.cat` theme, and
swaylock and bottom through marked blocks spliced into their own files. What is
recorded here is the other answer, for the two where the survey found no route,
because an entry saying only what was rejected gets read as a fence.

**fastfetch stays hand-written**, eight presets and 107 colour sites.
`fastfetch -c a -c b` answers `only one config file can be loaded`, so there is
no include. `display.constants` does not expand inside a colour field: pointed
at one it emitted the placeholder literally. Generating the presets whole was
the remaining option and was refused, because their colour is a handful of keys
inside module lists, output formats and comments, and moving all of that into a
Python emitter to reach the colour would make the presets uneditable by the
person who tunes them. The drift check is the coverage, and `MAINTENANCE.md`
already requires hex rather than ANSI codes there for exactly that reason.

**`waybar/common.jsonc` keeps one hex**, `alert-critical` inside a Pango span on
four notification glyphs. waybar's `include` works at the module level, so
reaching that one value would move the whole module definition into a generated
file. The right answer is CSS, which `waybar/style.css` already imports, but a
glyph that takes its colour from a stylesheet class instead of from inline
markup changes what the module outputs, and that is a functional change rather
than a theming one. It is recorded here as unblocked and out of scope, not as
impossible.

Neither of these forecloses anything else in those files. What was rejected is
one proposal per file: generating the fastfetch presets, and moving waybar's
notification module to reach one colour.

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
its own feature list against the configs rather than reading it. They went into
`docs/TODO.md` as work to do and into the README as a Known gaps section, because a
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

## The README stopped explaining itself

Two sections a reviewer had praised were cut, so the record has to say they were
cut rather than lost.

"Is this for you?" opened the file by qualifying. It turned away X11 users and
non-Arch users, and neither is turned away by anything in the tree: the theming
is Wayland-shaped but the palette, the terminals and the editor are not, and
someone on another distro can read `packages.conf` and translate. A README's
opening screen is the one that decides whether there is a second screen, and
spending it on who should leave was the wrong trade. What the section was right
about survives in three places: the badges and the first line still say Arch and
Wayland, which is honest because the installer really is Arch, the Contributing
section still says this is one person's desktop rather than a framework, and the
paragraph about not having to take all of it is in the opening section, reworded
and intact.

"Known gaps" listed four rough edges, and the reasoning that put it there still
holds; what changed is where the honesty is paid for. Sixteen lines of defects in
a file that has one screen to earn a reader's attention cost more than they buy,
and all four items are in `docs/TODO.md` in more detail than the README carried.
The pointer to that file now names the rough edges as part of what lives there.
The rule this leaves behind: a gap may move to the document that owns it, but it
may not stop being reachable from the README in one hop.

The same pass cut the paragraph in the install warning that explained why the
`--dry-run` rehearsal is worth running, which recounted the file-losing bugs an
audit had found and fixed. A reader deciding whether to run a script needs the
rehearsal command, not the incident history. The audit's findings are in the git
log and what it did not cover is in `docs/TODO.md`. The general form, and the
reason this is recorded rather than left as taste: the README is a document that
sells and instructs, and it is not a place where this repository narrates its own
mistakes to itself.

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
  `minimal/` is named separately because it is the one that looked like history and
  was not: a variant of every preset beside it, taking the guide's other reading of a
  fetch, one accent instead of the semantic mapping. Their own header used to call them "frozen snapshots ...
  NOT kept in sync", which is what `design/THEMING.md`'s "Rollback is git, not a
  directory" forbids, so the two entries read as contradicting each other for as long
  as that wording stood. The wording was the error. Nothing keeps `minimal/` in step
  with the presets above it and no check would report the drift, so a module added
  there has to be added here by hand.

These stay themed and tracked so that switching is reading a file rather than
writing one.

## `packages.conf` is a list of what its owner installs, not a minimal set

Several declared packages have no config here, no launch and no keybind, and several
tracked configs are for programs a stranger has no reason to want: `dunst`,
`hyprpaper`, `hyprlauncher` and `catnap` are deliberate keeps, documented as such
above. The proposal that fell was to prune the package list down to what the rest of
the repository demonstrably uses, on the grounds that a reference config does not need
its program present.

It was refused because the file is not a dependency manifest. It is what this desktop's
owner installs on a new machine, and that is the job it does well; a name in it costs a
line and a package, and removing one costs a step nobody remembers on the next install.
Anyone cloning this reads `install --dry-run` first, which prints the whole list.

What was open on the same file was different work and is settled below, under "`[apt]`
and `[dnf]` were filled in rather than removed". This entry does not bear on it.

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

## The checks moved out of `.claude/` so that a clone can run them

The only tracked file under `.claude/` was a skill that ran the whole validator
battery, and it was the single artefact that ran all of it. Deleting the directory
at publication, which this repository has always intended, would have taken the
battery with it and left `MAINTENANCE.md` describing checks with nothing to run
them. So the checks moved first, into `scripts/verify.sh`, and `.claude/` is now
untracked and ignored whole.

That ordering is the decision worth recording: a thing that is going to be deleted
cannot also be the only place a capability lives, and the fix is to move the
capability rather than to postpone the deletion. `MAINTENANCE.md` keeps the reasoning
for each check and points at the script for the commands, instead of holding a second
copy of them, which it did until the two had drifted apart.

Writing the script found three checks that had been reporting success while doing
nothing, which is this repository's characteristic bug turned on its own validators:
catnap was passed a flag it has never had, catnap's exit code was read in the
direction that does not mean anything, and `ghostty +validate-config` truncated the
file the battery was writing to.

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

## Replacing the generator wholesale was authorised and then ruled out by measurement

This entry is about one specific proposal, not about the generator being off limits.
The proposal was to throw `generate_theme.py` away and write another one, on the
reading that "change one hex and nothing moves". Measurement did not support that
diagnosis, so the file was kept. Restructuring it is a different question and has
since been done; see the entry below.

What the measurement said. Every colour key in `palette.json` reaches at least one
generated file and no generated file is unreachable, so there was no dead key and no
orphaned emitter. The generator is idempotent across repeated runs, including the
three files it merges into rather than writes. Its output is accepted by the
applications' own parsers rather than by inspection: `foot --check-config`, `ghostty
+validate-config`, kitty's own `load_config`, luajit and Neovim on both generated
`palette.lua` files, and GTK4's `CssProvider` on the stylesheets, each with a negative
control that failed.

What was actually wrong was two things replacing the file would not have fixed.
`palette.json` expressed roles as *copies* of scale values rather than references, so
moving `scales.ice.300` left even the generated stylesheet emitting the retired
`focus-ring`. And most themed files are outside the generator's reach entirely, which
is still open work in `docs/TODO.md`.

The lasting shape of it: this repository's characteristic bug had reached the tool
built to prevent it. Dropping the `#` from one value passed the generator, passed
both checks, and shipped a stylesheet GTK rejects. The generator now refuses a
malformed value at load, which is the fix a replacement would have had to include
anyway.

## The desktop got the three layers the editor already had

`roles.py` sits between the palette and the emitters, and the split it makes is that
`palette.json` holds values while roles hold decisions. It was copied from
`.config/nvim/lua/voidashi/theme/`, which had worked this way since the colorscheme was
written: palette, roles, groups. Written in Python rather than as data in JSON for the
reason `roles.lua` gives about its own layer, that this is where colour mixes with
design decision and the rationale belongs beside the choice; and referencing tokens in
the language rather than through string paths, so a typo is an error at generation time
instead of a value that silently resolves to something else.

Two measurements bracket it. Before: moving `scales.ice.300` left seven lines of the
generator's own output on the retired value and moving `scales.bordeaux.300` left four.
After: five and zero, and the five are the ANSI slots, which is the table doing its job.
Throughout the conversion the generated output stayed byte for byte identical, which is
the only reason a change of that size is reviewable at all.

`ansi16` did not move and should not. A program asking for red expects red whatever the
identity colour is, and the accent recipe in `docs/SETUP.md` rewrites the whole Bordeaux
ramp, so a slot naming `scales.bordeaux.400` would repaint ANSI red in silence.

## `[hooks]` was deleted rather than repaired

`packages.conf` had a `[hooks]` section that ran a shell command after a package
installed. It had zero entries and one commented example for its whole life, and
`run_hooks()` was fifteen lines of awk-inside-bash carrying three defects the script
audit found: a command containing `=` was truncated at the first one, the package key
was interpolated into a regex rather than compared literally so `pipesXsh` matched
`pipes.sh`, and the `system()` call was the one thing in the audit nobody was willing
to let execute. The repair was known and was a bash read loop.

It was deleted because the feature had no users, and a rewrite would have been work
scheduled on something nobody had ever run. What fell is this mechanism, not the idea:
if a package here ever needs a post-install step, write it deliberately against a real
case rather than restoring an awk program that was never exercised. Nothing else read
the section, since `load_packages` filters on the manager's name and `[common]`.

## The compositors reach this repo's helpers through `~/.local/bin`

Seven lines across five tracked files named `$HOME/.dotfiles` absolutely, so cloning
anywhere else silently broke the wallpaper, the clipboard picker, the bar's power
button and Neovim's dashboard. `install` now links every `scripts/wm/*.sh` into
`~/.local/bin` and the `wallpapers/` directory into
`~/.local/share/wallpapers/dotfiles`, and the configs use those names. One line is
left, Neovim's dashboard, which opens this repository and therefore names it by
definition.

`~/.local/bin` was chosen because it is already on PATH and nothing has to arrange
that. Measured on a live session started by plasmalogin, Hyprland, waybar and swaync
all carry it first in PATH, and `config.fish` prepends it as well, so the console
start path has it too. That is the whole argument: the configs end up with no path in
them at all.

What fell was a directory of this repository's own, `~/scripts/wm`. It fixes the same
problem, since it is a fixed location independent of the clone, and it isolates these
three helpers from a `~/.local/bin` shared with everything else the user installs. It
lost on the mechanism rather than on taste. Nothing puts it on PATH, so it either
keeps an absolute path in five config lines, which renames the coupling instead of
removing it, or it needs `environment.d`, whose delivery could not be isolated on this
machine: `conf/env_vars.lua` sets the same variables through `hl.env`, so the values
reaching waybar and swaync prove only that one of the two sources works.

Reopen it if `~/.local/bin` turns out to collide. The names are generic
(`clipboard-picker.sh`, `power-menu.sh`, `select-random-wallpaper.sh`) and the risk is
real rather than theoretical; what makes it cheap today is that `uninstall` removes a
link only after `readlink` says it points into the repo, so a collision costs a
warning and not someone else's file. A case in `scripts/tests/test-dotfiles.sh` holds
that.

## `[apt]` and `[dnf]` were filled in rather than removed

The two sections were empty while every name sat in `[common]` in its Arch spelling,
so the cross-distro branches dispatched correctly and then asked apt for
`hyprland`. The proposal that fell was deleting those branches and making the
installer Arch-only. What replaced it is data: the sections now carry the names that
differ, read out of the distributions' own package indexes rather than recalled.

Two things were learned while pricing it, and both outlived the choice. The override
mechanism the task list proposed building already existed, and only the data was
missing; a test config with `bat = batcat` under `[apt]` printed `bat (batcat)` on the
first try. And an override can only rename. There is no spelling for "this
distribution has no such package", because an empty value falls back to the key, so
absences are comments and an install still tries them.

That matters because the absences are not a fringe. Hyprland has no package in Debian
trixie main or in Fedora 43, and neither do hypridle, hyprpaper, hyprshot, hyprpicker,
hyprlauncher, ghostty or yazi. So the apt and dnf branches reach the Sway half of this
desktop and none of the Hyprland half. That is packaging rather than a defect here,
and it is the reason the promise in `SETUP.md` is now bounded instead of removed.

What stays open is one thing and it is in `docs/TODO.md`: none of it has been run. The
machine this was written on is Arch, so every name above is read from an index and
not from an install. Nothing here may gain a sentence saying otherwise until a machine
with those repositories has tried it.

## Three things about the bar are provisional

Settled only until they have been lived with: whether numerals beat application
glyphs on the workspace buttons, whether the right-hand modules want separators or
should stay spaced only, and whether 15px at weight 500 is the right text size.
Nothing is owed on these. They are recorded so that changing one is not mistaken for
undoing a decision.

## Sway follows Hyprland, and the direction is the decision

The two compositors had drifted apart in everything but colour: different launcher
key, no media keys, one screenshot mode against three, no input block, no output
block, and an idle schedule that agreed on its numbers while reaching the locker by
a different route. The choice was between converging them and writing the divergence
down as intentional. They converged, one way: `sway/config` follows `.config/hypr/`
and never the reverse, so a key that means something under one means it under the
other. Sway keeps what Hyprland has no counterpart for, as long as it does not sit on
a key Hyprland has already spent, which is why the home-row focus row went.

The cost was known and taken. Sway is validated and never booted here, so every line
mirrored into it is parsed and unrun, and full convergence enlarges that surface on
purpose rather than by accident. `sway --validate` does not narrow it much:
`MAINTENANCE.md` has the measurement, but it accepts an invented command inside a
`bindsym` at exit 0.

Four things stayed different because sway cannot express them: a SIGKILL bind, since
`kill` is its only verb; directional swap, since sway swaps by criterion rather than
direction; pseudotiling; and the lid binds, which are absent for the separate reason
in `MAINTENANCE.md`. Those are written into the file as absent on purpose, so the
next reader does not close them as gaps.

What this does not settle: nothing above says the two must stay identical forever.
It says which file moves when they differ.

## The bar carries laptop modules on every machine

`battery` and `backlight` sit in `modules-right` unconditionally, and on a desktop
they are empty or absent. `SETUP.md` tells such a reader to delete them, which is a
manual step in an install that otherwise has none, and it stays.

The alternative that looks obvious does not work. Waybar here is one config split
three ways: `common.jsonc` holds every module definition and the whole of
`modules-right`, while `hyprland.jsonc` and `sway.jsonc` add only their own
`modules-left`. So a per-compositor `modules-right` is available and answers the
wrong question, because this is a hardware axis and not a compositor one. A desktop
running Hyprland wants the same removal as a desktop running sway. Waybar has no
conditional module mechanism to key off the hardware instead.

Not measured, and worth saying rather than implying: whether waybar hides a `battery`
module on a machine with no battery was never tested, because the machine this was
written on is a laptop. If it does, the manual step is unnecessary and this entry is
the thing to revisit.

## Per-application workspace layouts will not be built

Neither compositor assigns an application to a workspace today, and neither will.
`window_rules.lua` already drops gaps and borders when a workspace holds one window,
so the mechanism to extend was there and the design was the whole job: a map that
fights how you actually work is worse than no map, and nothing in daily use asks for
one. Deciding not to write it is cheaper than writing one to find out.

This is about the application-to-workspace map and nothing else. The smart-gaps rules
in `window_rules.lua` stay, adding a rule for some other reason stays open, and if a
workspace habit ever becomes stable enough to write down, this entry is not the
argument against writing it. It is the record that no such habit existed when the
question was asked.

Open work of every kind lives in `docs/TODO.md`, including what is diagnosed and
deliberately parked. It is not repeated here.
