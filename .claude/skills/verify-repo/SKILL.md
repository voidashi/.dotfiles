---
description: Run every validator this repo has and report what each one returned. Covers the palette check, the compositor and terminal config validators, and the symlink audit. Use after any change to colour, config or the theme generator, and before calling work done.
---

Each block below is the command and what it returned. Most of these print
nothing when they are clean, so an empty block is a pass, not a failure to run.

## Palette and generated files

!`cd "$(git rev-parse --show-toplevel)" && python3 scripts/theme/check_palette.py 2>&1`

## Hyprland

!`hyprctl configerrors 2>&1 || echo "hyprctl unavailable (not running under Hyprland)"`

## Sway

!`cd "$(git rev-parse --show-toplevel)" && sway --validate -c .config/sway/config 2>&1`

## foot

!`cd "$(git rev-parse --show-toplevel)" && foot --check-config -c .config/foot/foot.ini 2>&1`

## Ghostty

!`cd "$(git rev-parse --show-toplevel)" && ghostty +validate-config --config-file=.config/ghostty/config 2>&1`

## kitty

!`cd "$(git rev-parse --show-toplevel)" && kitty +runpy "from kitty.config import load_config; bad=[]; load_config('.config/kitty/kitty.conf', accumulate_bad_lines=bad); print(bad)" 2>&1 | tail -3`

## fastfetch, every config

!`cd "$(git rev-parse --show-toplevel)/.config/fastfetch" && for f in config.jsonc */config.jsonc minimal/*.jsonc; do out=$(fastfetch --pipe true -c "$f" 2>&1 >/dev/null); [ -n "$out" ] && echo "$f: $out"; done; echo "checked: $(ls config.jsonc */config.jsonc minimal/*.jsonc 2>/dev/null | wc -l)"`

## catnap

!`cd "$(git rev-parse --show-toplevel)" && err=$(catnap -n -c .config/catnap/config.toml -a .config/catnap/distros.toml 2>&1 >/dev/null | grep -i error | head -3); rc=$?; catnap -n -c .config/catnap/config.toml -a .config/catnap/distros.toml >/dev/null 2>&1; echo "exit: $?"; [ -n "$err" ] && echo "$err"`

## Tracked symlinks

!`cd "$(git rev-parse --show-toplevel)" && bash scripts/backup-configs.sh check 2>&1 | grep -v SUCCESS; echo "valid: $(cd "$(git rev-parse --show-toplevel)" && bash scripts/backup-configs.sh check 2>&1 | grep -c SUCCESS)"`

## Working tree

!`git -C "$(git rev-parse --show-toplevel)" status --short || echo "clean"`

## Instructions

Report the measurement, not a verdict: for anything that failed, quote what it
actually returned rather than describing it.

How to read these:

- **kitty** prints `[]` when clean. Anything else is the list of bad lines.
- **fastfetch** should list no file and report `checked: 10`. A file named here
  failed to parse; the message after the colon is fastfetch's own.
- **catnap** should report `exit: 0` and nothing else. Its render goes to stdout
  and its errors to stderr, and the exit code is the reliable signal: 1 on an
  invalid config, 0 on a valid one. This block exists for one specific future
  failure: catnap 2.0 replaced the TOML config format entirely and the AUR package
  is still on 1.x, so the day it updates, both tracked files stop being valid at
  once. This is what will say so.
- **Tracked symlinks** should equal the number of paths in
  `scripts/config_files.conf`, which is 31 as of this writing, with no `Broken`
  lines. If the count differs, check that file before assuming a fault. A broken one
  usually means an external program replaced the symlink with a real file, which
  `kded6` has done to `gtk.css` before; the repair is to re-link, but check the
  content first, because the same event has also overwritten what the repo held.
- **Working tree** dirt is worth a second look rather than an automatic commit.
  `kdeglobals` and both GTK `settings.ini` files have a second owner in KDE, so
  changes there may be something else's, not ours.

Two checks are not run above because they are slow or need a display. Run them
by hand when the change touches what they cover:

```bash
nvim --headless "+checkhealth vim.deprecated" +qa
waybar -c .config/waybar/hyprland.jsonc -s .config/waybar/style.css
```

For Neovim, a lazy-loaded plugin does not surface its deprecations until it is
actually loaded, so run the relevant command first or the all-clear is false.
