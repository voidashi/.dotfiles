# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in
this repository.

**This file holds no knowledge of its own.** It points at the documentation and adds
the few rules that only make sense to an agent. It can be deleted without losing
anything; everything it references lives under `docs/`.

## Read first

- [`docs/README.md`](docs/README.md) indexes every document and says which question
  each one owns, and who it is for.
- [`docs/MAINTENANCE.md`](docs/MAINTENANCE.md) before touching any config file. It
  holds the non-obvious behaviour of the two management scripts, every architecture
  pitfall this repo has paid for, and how to validate a change. Most of the failures
  here are silent, so reading it first is cheaper than debugging.
- [`docs/design/RICE-GUIDE.md`](docs/design/RICE-GUIDE.md) before changing anything
  that affects how something *looks*: colours, fonts, spacing, borders, animation,
  wallpaper. It is the authority for desktop work and it overrides
  `DESIGN-SYSTEM.md` wherever the two differ. Its non-negotiables and its "Working
  rules" section are the rules for this kind of change; do not restate them here.
- [`docs/design/THEME-STATUS.md`](docs/design/THEME-STATUS.md) to find out how the
  palette reaches a given application before assuming it needs a new mechanism.
- [`docs/TODO.md`](docs/TODO.md) and
  [`docs/TURNING-POINTS.md`](docs/TURNING-POINTS.md) before concluding something is
  undone or asking why a structure is the way it is. Several questions in there are
  settled, with the reasons recorded, including things deliberately not done.

## Working here

- **Run the checks, do not reason about them.** `python3
  scripts/theme/check_palette.py` after any colour change, and `/verify-repo` for the
  whole battery, before calling work done. The commands are in `MAINTENANCE.md` if
  the skill is unavailable.
- **Report the measurement, not the verdict.** Quote what a command returned. This
  repo's characteristic bug is something configured, looking configured, and doing
  nothing, so a config that reads correctly is not evidence that it applies.
- **Scope discipline.** A theming task changes colour, font, padding, border and
  radius. It does not change keybindings, module ordering, scripts or functional
  options. If a functional change is genuinely needed to reach a visual goal, raise
  it separately rather than folding it in.
- **State what you assumed, in one line.** The guide leaves per-application
  decisions open on purpose. Make the call and name it so it can be corrected; do
  not stall, and do not silently invent a rule that then propagates.
- **Writing style for every file here:** no em dashes, and never state a thing then
  restate it inverted. Documentation in English. Code comments follow the language of
  the surrounding file, never two languages in one file.
