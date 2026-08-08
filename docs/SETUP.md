# Setting these dotfiles up

The long version of the README's install section, plus the two things it cannot fit:
what you have to change for your own machine, and what to do when something does not
work.

If you want to change how it *looks*, that is a different document:
[`design/RICE-GUIDE.md`](design/RICE-GUIDE.md) holds the palette and the rules, and
[`design/THEMING.md`](design/THEMING.md) says how a colour reaches each application.
The one exception is "Changing the accent colour" below, which is a procedure rather
than a design decision and lives here with the rest of the procedures.

## Before you start

This is built for **Arch Linux on Wayland**. The configs assume Arch: package names,
AUR fallbacks, and Hyprland at a version recent enough for a Lua config.

The package installer dispatches to apt and dnf as well, and `packages.conf` carries
the Debian and Fedora names for the packages whose names differ. That is narrower than
it sounds, and the limit is packaging rather than the script: Hyprland itself has no
package in Debian trixie main or in Fedora 43, nor do hypridle, hyprpaper, hyprshot,
hyprpicker, hyprlauncher, ghostty or yazi. Each section of `packages.conf` lists what
its distribution has no package for. So apt or dnf gets you the Sway half of this
desktop and none of the Hyprland half, and neither branch has ever been run: the
machine this was developed on is Arch.

You will want an AUR helper (`paru`, `yay` or `pikaur`) already installed. A handful of
packages have no official-repo version and the installer falls back to whichever helper
it finds.

Nothing here needs root except the package install itself.

## Install

```bash
git clone https://github.com/voidashi/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

**Clone anywhere you like, with one exception.** The configs used to name
`~/.dotfiles` in seven places, so any other location silently broke the wallpaper, the
clipboard picker and the bar's power button. They no longer do: `install` links the
`scripts/wm/` helpers into `~/.local/bin`, which is on PATH, and the sample wallpaper
into `~/.local/share/wallpapers/dotfiles`, and the configs call both by those names.

The exception is Neovim's dashboard, whose `dotfiles` entry opens `~/.dotfiles` and has
to name it. One line, and this finds it:

```bash
grep -rn '\$HOME/\.dotfiles' .config/
```

**If you installed before this change, run `install` again.** The configs no longer
carry the absolute path, and the links that replaced it do not exist until the script
creates them. Between pulling and re-running, the power button and the clipboard picker
do nothing.

Two of the steps below change nothing. Step 1 lists the packages without installing
them and step 3 walks the whole symlink pass without touching a file, so you can watch
both scripts describe their own work before you let either of them do it. Both are the
same `--dry-run` flag, which is the rehearsal on either script. Neither needs you to read
any bash.

**1. See what would be installed, before installing it.**

```bash
./scripts/install-packages.sh install --dry-run
```

**2. Install the packages.**

```bash
./scripts/install-packages.sh install
```

This asks for sudo. It logs to `scripts/package_install.log`, overwritten each run.

**3. See what the linking would do, without doing it.**

```bash
./scripts/backup-configs.sh install --dry-run
```

It creates, moves and deletes nothing. Work it would do is prefixed `Simulate:`, and a
path it would leave alone because a real file is already there says `Skipping existing
file`. Read the list: it is the set of paths the next step will touch, so this is where
you find out it wants a file you care about, while finding out still costs nothing.

**4. Link the configs into your home directory.**

```bash
./scripts/backup-configs.sh install
```

This creates symlinks from `$HOME` into the repo. It **refuses to overwrite** a real
file that is already there, which is why the dry run above reports some paths as
`Skipping existing file`. To replace one, pass `--force`, and it copies the original
into `~/.dotfiles_backup/<timestamp>/` before removing it. `--force` is also worth a dry
run first, since it is the flag that has something to destroy:

```bash
./scripts/backup-configs.sh install --dry-run --force
```

For part of it rather than all of it, name the paths you want. They have to be entries
of `scripts/config_files.conf`, and naming any of them leaves `fonts/` alone, which a
bare run links:

```bash
./scripts/backup-configs.sh install ~/.config/kitty ~/.config/fish
```

`uninstall` and `check` take paths the same way, so the subset can be undone and audited
on its own terms.

**5. Check that it worked.**

```bash
./scripts/backup-configs.sh check
```

Every tracked path should report as a symlink into the repo.

**6. Set up a way into the session.**

Nothing so far gives you a graphical login. The packages and the symlinks are only the
contents of a session; a fresh Arch install has nothing that starts one, so this is the
step between a working install and a black screen. Three cases follow and you need
exactly one of them.

Both compositors install their own session entry, so anything that reads them will find
Hyprland and Sway without help from this repo:

```bash
ls /usr/share/wayland-sessions/    # expect hyprland.desktop and sway.desktop
```

**If you already run a display manager**, SDDM, GDM, plasmalogin, ly or another, you are
done: it will list both on the next boot. Remove `greetd` and `greetd-tuigreet` from
`scripts/packages.conf` before installing, or drop them afterwards, since enabling a
second display manager conflicts with the first over the `display-manager.service` alias.

**If you have no display manager**, this repo suggests `greetd` with `tuigreet`. It is
Wayland-native, it is two packages, and its colours are settable from the command line,
so it can be brought onto the palette later. Both are declared in `packages.conf` and
come from the official repositories. Confirm the unit arrived before you rely on it:

```bash
systemctl cat greetd.service | head -3   # prints the unit, or "No files found"
```

Then write `/etc/greetd/config.toml`. This needs root, it is outside `$HOME`, and
`backup-configs.sh` neither creates nor checks it:

```toml
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --asterisks --sessions /usr/share/wayland-sessions --cmd start-hyprland"
user = "greeter"
```

`--cmd` is the fallback if you press Enter without choosing; `--sessions` is what puts
Hyprland and Sway on the menu.

**Give `--cmd` what the session file gives it, not the compositor's own name.** On Arch
today `/usr/share/wayland-sessions/hyprland.desktop` runs `Exec=/usr/bin/start-hyprland`,
and Hyprland warns on startup when it is launched any other way. This line used to say
`--cmd Hyprland`, which reaches a desktop and prints that warning, so check the `Exec=`
line of the session you actually want rather than copying this one. Choosing the session
from tuigreet's menu runs the `.desktop` file and is correct whatever `--cmd` says; the
fallback is the path that goes wrong quietly.

**If you are replacing an existing display manager, disable it in the same sitting.** Two
enabled display managers is a machine that does not reach a desktop:

```bash
sudo systemctl disable plasmalogin.service   # or sddm, gdm, whichever you have
systemctl is-enabled plasmalogin.service greetd.service   # expect: disabled, enabled
```

Enable it for the *next* boot rather than starting it now:

```bash
sudo systemctl enable greetd.service
```

Use `enable` and reboot, not `enable --now`. Starting a display manager on top of a
session you are already sitting in takes that session down with it, and if the config has
a typo you want to land at a text console rather than a blank screen.

**A greeter that starts the compositor directly gives it no session environment.** This
is worth doing something about rather than discovering later. `~/.config/environment.d/`
is read by `systemd --user`, and a compositor the greeter `exec`s is not a systemd user
unit, so it inherits nothing from there. Under Hyprland it does not show, because
`conf/env_vars.lua` sets the same values again for everything it launches. Under Sway it
shows immediately: `QT_QPA_PLATFORMTHEME` never arrives and Qt applications come up
unthemed against a dark desktop.

`uwsm`, declared in `packages.conf`, fixes it by starting the compositor as a systemd
user unit. Hyprland ships its own entry for this, `hyprland-uwsm.desktop`. Sway has none,
and `uwsm` ships no session entries at all, so write one:

```bash
sudo tee /usr/share/wayland-sessions/sway-uwsm.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Sway (uwsm-managed)
Comment=An i3-compatible Wayland compositor
Exec=uwsm start -e -D sway:wlroots sway.desktop
TryExec=uwsm
Type=Application
DesktopNames=sway;wlroots
EOF
```

This one needs root and lives outside `$HOME`, the same as greetd's own config and for
the same reason, so `backup-configs.sh` neither creates nor checks it. It cannot live in
`~/.local/share/wayland-sessions/` instead: the greeter runs as its own `greeter` user
and a home directory at `0700` is unreadable to it, so the entry would never appear in
the menu.

Both compositors already call `uwsm finalize` on startup, which is what exports
`WAYLAND_DISPLAY` and reports the unit as started.

**Check any change to this line before you reboot on it.** A `command` that tuigreet
rejects leaves you with no login screen and a trip to a text console, and nothing warns
you: greetd starts the greeter, the greeter exits on a usage error, greetd retries, and
you get a black screen. That has happened here once.

```bash
scripts/check-greeter-command.sh                 # the line currently in the config
scripts/check-greeter-command.sh 'tuigreet ...'  # a line you are about to write
```

**Making the uwsm entry the default** is one flag, and there is a second that is
tempting and is where the accident came from.

`--remember-user-session` remembers the session you last chose, per user. It needs
`--remember`, which the line above already has, and it takes no argument, so there is
nothing to quote and nothing to get wrong. Pick the uwsm entry once and every login after
that gets it. This is the one to use.

`--cmd` is the other half: it is what runs when you press Enter without opening the
session menu, so it covers the first login and any account with no history, and pointing
it at the plain compositor is what makes the non-uwsm session the quiet default. Changing
it means giving it a multi-word command, and that is the trap. greetd runs the line
through `sh(1)`, so the quoting has to survive into the shell:

```
--cmd 'uwsm start -e -D Hyprland hyprland.desktop'      # correct
--cmd uwsm start -e -D Hyprland hyprland.desktop        # no greeter
```

Without the quotes tuigreet reads `--cmd uwsm` and then meets `start`, `-e` and the rest
as arguments of its own, fails with `Unrecognized option: 'e'`, and exits. Both forms
above were run through the checker; the first passes and the second is what it was
written to catch.

Then pick the uwsm entry at the greeter. The plain entries stay in the menu, which is what makes trying this cheap. To
check it worked, from inside the session:

```bash
./scripts/check-session-env.sh
```

It reads what the compositor actually hands its children, and it says why
`XCURSOR_SIZE` is not evidence.

**Or skip the display manager entirely.** Log in at a text console and type the
compositor's name:

```bash
Hyprland     # or: sway
```

This is a legitimate way to run either one, and it is the fastest way to find out whether
a login problem is the compositor or the greeter. Under Hyprland it costs you nothing,
because `.config/hypr/conf/env_vars.lua` sets the environment for everything the
compositor launches. Under Sway it does cost something:
`~/.config/environment.d/50-voidashi.conf` is read by `systemd --user`, while a compositor
you start by typing its name inherits your login shell's environment instead. Sway cannot
set a variable from its own config, so put `QT_QPA_PLATFORMTHEME=kde` in your shell
profile if you take this path, or Qt applications come up light.

**7. Make fish your login shell**, if you want the prompt this repo themes.

```bash
chsh -s /usr/bin/fish
```

Nothing does this for you, and without it you get bash with its default prompt while
everything else looks themed. The tracked `.bashrc` is deliberately a stock one, so
there is no clue that anything is missing. Starship and the fish colour scheme both live
under `.config/fish/`, so they only apply once fish is actually the shell you land in.

**8. Log out and back in**, so the compositor picks up the new config and starts the
background pieces: the bar, the wallpaper, notifications, the clipboard watcher and the
idle daemon. This step is also what loads
`~/.config/environment.d/50-voidashi.conf`, which is the only thing that sets
`QT_QPA_PLATFORMTHEME` under Sway.

### The one command that can lose your files

`backup-configs.sh` has two directions and they are easy to confuse:

| Command | What it does |
|---|---|
| `install` | Repo to `$HOME`. Safe: it skips real files unless you pass `--force`. |
| `add` | `$HOME` to repo. **Destructive to the original location.** |

`add` is for the repo's author adding a new dotfile. It *moves* files out of `$HOME`
into the repo and leaves symlinks behind. It backs up first, but treat it as a one-way
move and never run it against a home directory you care about without reading it.

### Undoing it

**To undo an install, run `./scripts/backup-configs.sh uninstall`.** It removes the
symlinks this repo created and nothing else: your own files stay, the repo stays, and a
link pointing anywhere other than the repo is left alone. Add `--dry-run` first if you
want to see the list.

**Your originals are in `~/.dotfiles_backup/<timestamp>/`, and nothing moves them back
for you.** Anything `install --force` replaced went there. `./scripts/backup-configs.sh
backups` lists the timestamps with a file count each. Copy what you want out by hand, or
run `uninstall` first and then `restore <timestamp>`, in that order: `restore` refuses to
overwrite anything already at the path, and while the symlink is still there it counts
as already at the path.

## What you must change for your machine

None of this breaks the install, but leaving it alone means running someone else's
hardware layout.

**Monitors.** `.config/hypr/conf/monitors.lua:8` and `:10` name two specific outputs at
specific modes:

```lua
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-1", mode = "1920x1080@144", position = "1920x0", scale = 1 })
```

Line 12 is a catch-all that gives any other output its preferred mode, so if your
outputs have different names you are fine. If you *do* have an `eDP-1` or a `DP-1` at
another resolution, change these or delete them and let the catch-all handle it. Run
`hyprctl monitors` to see what yours are called.

**The lid switch**, the two `switch:on:Lid Switch` and `switch:off:Lid Switch` binds at
the end of `.config/hypr/conf/binds.lua`, also names `eDP-1`. Change it to your internal
display, or delete both lines if you are on a desktop.

**Laptop-only bar modules.** `.config/waybar/common.jsonc` puts `backlight` and
`battery` in the bar. On a desktop they will be empty or missing. Remove them from
`modules-right`. Before trusting either on a laptop, check that the names match your
hardware:

```bash
ls /sys/class/power_supply/    # battery
ls /sys/class/backlight/       # backlight
```

**Your programs.** `.config/hypr/conf/programs.lua` sets what the keybindings launch:

```lua
terminal = "kitty"   -- line 10
fileManager = "dolphin"   -- line 15
terminalFileManager = "yazi"   -- line 16
menu = "wofi --show drun"   -- line 22
```

All four terminals are configured and themed identically, so switching `terminal` to
`ghostty`, `alacritty` or `foot` costs nothing.

**Sway names the same two outputs**, in its own `### Output` section, and this is the
one place its config is more brittle than Hyprland's. Sway has no catch-all line, so
where Hyprland falls back to a preferred mode for an output it does not recognise, sway
simply has no directive for it, which is fine, and it also has no way to say "that one,
but at whatever mode it prefers". If your internal panel is not `eDP-1`, or is `eDP-1`
at another resolution, edit or delete those two lines the same way you edited the
Hyprland ones. An output with no directive comes up at its preferred mode and
auto-positioned, so deleting is safe. A wrong mode is not: it is the one thing
`sway --validate` does fail on, which at least means you find out immediately. Run
`swaymsg -t get_outputs` to see what yours are called.

**If you already run KDE.** `~/.config/kdeglobals` and `~/.config/kcminputrc` are tracked
entries, and they are where Plasma reads its palette, fonts, icon theme and cursor. On a
machine that already runs Plasma those files exist, so `install` refuses them the way it
refuses any real file, and prints one line each:

```
[WARNING] Skipping existing file: /home/you/.config/kdeglobals (use --force to overwrite)
[WARNING] Skipping existing file: /home/you/.config/kcminputrc (use --force to overwrite)
```

That run does not retheme your session. `--force` is what replaces them, after copying
the originals into `~/.dotfiles_backup/<timestamp>/`. Two things to know before reaching
for it. The palette also ships as an ordinary KDE colour scheme,
`~/.local/share/color-schemes/Voidashi.colors`, which the same run *does* link because
nothing is there to skip, and which changes nothing until you select it. And once
`kdeglobals` is a symlink, KDE writes through it: every change made in System Settings
lands in the repository, so `git status` in `~/.dotfiles` starts reporting your desktop
settings.

So on a machine that already runs Plasma, leave those two out and take the palette the
way KDE hands it to everyone else:

```bash
./scripts/backup-configs.sh install \
  --except ~/.config/kdeglobals \
  --except ~/.config/kcminputrc

plasma-apply-colorscheme Voidashi     # or System Settings > Colours > Voidashi
```

The first command links everything else, `fonts/` included. The second is Plasma's own
mechanism, it writes the colours into your `kdeglobals` rather than replacing the file,
and picking Breeze again undoes it. What you give up is the cursor and the font keys,
which live in `kcminputrc` and in the `[General]` section this repository does not reach
that way; set them in System Settings if you want them.

Applying a scheme copies its colours into your `kdeglobals` once, so after changing the
accent colour and regenerating, run the second command again.

If you do not run Plasma, none of this applies: there is no System Settings to select the
scheme, which is exactly why `kdeglobals` is written directly, and both files are almost
certainly absent so `install` links them without a word.

## Changing the accent colour

The README promises that one hex moves everything. That is true of the generated half of
the tree and not of the rest, so this is the whole procedure.

**Two colours get called the accent, and they are different keys.** Ice is *focus*: the
focused window border, the active workspace, the selected launcher entry, GTK and Qt
selection. Bordeaux is *identity*: the terminal cursor, the shell prompt, the lock
screen, the fetch banners. Asking to change the accent almost always means Bordeaux, and
that is what this section does. Ice works the same way, out of `scales.ice` alone. The
role table is in [`design/RICE-GUIDE.md`](design/RICE-GUIDE.md), and which role reads
which step is `scripts/theme/roles.py`.

### The keys

Bordeaux is a ten-step ramp in `scripts/theme/palette.json` under `scales.bordeaux`,
`100` lightest down to `deep`. Every step is used somewhere, so all ten move together.

One value is typed a second time in the same file, and it does not follow the ramp:

| Key | Today | What to do with it |
|---|---|---|
| `ansi16` slot 1 | `#b44955`, a copy of `bordeaux.400` | Leave it. |

`ansi16` is the sixteen-colour terminal table, and slot 1 is red because a program that
asks for red expects red. It carries the identity colour today only because the identity
colour is a red. Move Bordeaux to another hue and the two stop being the same value,
which is correct.

Everything else that uses Bordeaux follows the ramp on its own. The terminal cursor used
to be a second copy here and is now a role in `roles.py`, which names `bordeaux.300`
instead of repeating its hex.

### What follows the generator, and what does not

Rerunning the generator rewrites the four terminals, Hyprland's palette, Neovim's
palette, the GTK stylesheets, wofi and the KDE colour scheme. It leaves alone every file
where colour sits inside structural config, and those paste the hex directly: `bottom`,
the fastfetch presets, `fish`, `hyprtoolkit.conf`, `swaylock` and `yazi`.

Do not work from that list, because it is only true on the day it was written. Change the
ramp, run the generator, then search `.config` for the values you replaced. Whatever
still matches is a file that did not follow.

### A worked example

A plum identity instead of a red one. Keep each step's lightness and saturation and move
only the hue, because the ten steps are tuned for contrast against the void surfaces.

**Replace the ramp.** `scales.bordeaux` in `scripts/theme/palette.json`:

```json
"bordeaux": {
  "100": "#e2afcd",
  "200": "#d78db8",
  "300": "#c7689f",
  "400": "#b44987",
  "500": "#99306d",
  "600": "#7f1f57",
  "700": "#621341",
  "800": "#490c30",
  "900": "#310c22",
  "deep": "#1c0b15"
},
```

Leave `ansi16` alone.

**Regenerate.**

```bash
python3 scripts/theme/generate_theme.py
```

**Find what did not follow**, searching for the ten values you just replaced:

```bash
git grep -nIiE "e2afb1|d78d91|c76870|b44955|99303f|7f1f2f|621321|490c17|310c11|1c0b0c" -- .config
```

Edit each hit to its new value. What legitimately still matches afterwards is `#b44955`
in the four terminal colour files and in Neovim's `palette.lua`, which is ANSI slot 1,
and one mention inside a comment in `.config/catnap/config.toml`. Anything else is a file
you missed.

**Update the guide.** [`design/RICE-GUIDE.md`](design/RICE-GUIDE.md) prints the palette
and `check_palette.py` reads it, so its Bordeaux row and its cursor row have to move with
the ramp or the check fails on the guide rather than on a config. Its ANSI table keeps
`#b44955`, but the note calling that value bordeaux-400 stops being true.

**Prove it.**

```bash
python3 scripts/theme/check_palette.py
```

### What the check will not tell you

`check_palette.py` reports a colour that `palette.json` does not contain, which is not
the same question as "did the accent move everywhere". Two gaps to know about, both
measured rather than read off the source:

- **While `ansi16` slot 1 holds the old `bordeaux.400`, that value is still a palette
  colour.** Changing the ramp alone and regenerating moved four files and left nineteen
  tracked files on the old accent, at exit 0 throughout, and the checker's colour count
  went *up* by one rather than staying flat, which is the signal that a retired value is
  still alive. The checker now says so in as many words, on its `ansi:` line, and the
  warning is not a failure because this recipe puts the palette in exactly that state
  between the ramp and the grep. What still ends it is the grep above. `ansi16` is the
  only place left where this can happen: everything else that uses a colour names a
  token in `roles.py` rather than repeating its hex.
- **This document is skipped by the checker**, because the example ramp above is
  deliberately not the palette. The current values quoted here are therefore unchecked
  too, so update them by hand if you swap the accent.

## Fonts

`fonts/` ships the faces the theme uses, and `backup-configs.sh install` symlinks the
directory into `~/.local/share/fonts/dotfiles` and refreshes the font cache. No separate
step.

| Face | Where it is used |
|---|---|
| Iosevka Extended | Terminals, editor, TUIs |
| Hack Nerd Font | The icons Iosevka does not cover |
| Instrument Sans | GTK and Qt application interfaces |
| Spectral | Lock screen and fetch banners |

**Iosevka is the exception and you have to fetch it yourself.** It unpacks to around
430MB, too large to keep in git, so `fonts/Iosevka/` is gitignored.

Three names have to line up and none of them is spelled like the others. The configs ask
for the face **Iosevka Extended**, which is a width of the family **Iosevka**, which
arrives in the release asset **`PkgTTC-SGr-Iosevka-<version>.zip`**. A release carries
several hundred archives whose names differ by a few characters, so take that one by
name rather than by eye:

```bash
curl -sL https://api.github.com/repos/be5invis/Iosevka/releases/latest \
  | grep -oE 'https://[A-Za-z0-9._/-]+/PkgTTC-SGr-Iosevka-[0-9][A-Za-z0-9._-]*\.zip' \
  | sort -u | xargs curl -L -o /tmp/iosevka.zip
unzip -o /tmp/iosevka.zip -d fonts/Iosevka/
./scripts/backup-configs.sh install
```

That drops nine `SGr-Iosevka-<weight>.ttc` files straight into `fonts/Iosevka/`. Two of
them carry what is used today, `Regular` for Iosevka Extended and its oblique and `Bold`
for the bold pair, and all nine are kept so a future weight costs no second download. To
see which file actually answered for a face, run `fc-match "Iosevka Extended" -v`.

The near misses are what catch people. `Term`, `Fixed`, `Curly`, `Slab` and `SS01`
through `SS18` are different designs; `SuperTTC-` packs every weight into one file
instead of nine; and `PkgTTC-Iosevka-` without the `SGr-` is a separate package that
unpacks to `Iosevka-<weight>.ttc` rather than the `SGr-` names these configs were built
against. The command above rejects all of them.

Until Iosevka is in place, terminals fall back to whatever monospace font fontconfig
picks, which still works but is not the design.

## Wallpapers

`scripts/wm/select-random-wallpaper.sh` takes a list of directories and picks a random
image from the first one that actually contains images. Both compositors call it with
the same three:

| Directory | Purpose |
|---|---|
| `~/Pictures/Current_wallpapers` | The set currently in rotation |
| `~/Pictures/Wallpapers` | A full personal collection |
| `~/.local/share/wallpapers/dotfiles` | The sample shipped here, linked by `install` |

The last one is the fallback, so a fresh clone shows something immediately. The two
personal directories are deliberately not tracked, because GitHub is a poor place to
keep an image library. Copy the sample into one of the first two, or point the script
somewhere else in `.config/hypr/conf/autostart.lua` and `.config/sway/config`.

What the theme wants from a wallpaper is in
[`design/RICE-GUIDE.md`](design/RICE-GUIDE.md): at or below the darkest interface
surface in perceived lightness, warm-neutral or neutral, heavily desaturated. A solid
dark fill is always a legitimate choice.

## When it does not work

Symptom first. The *why* for most of these is in
[`MAINTENANCE.md`](MAINTENANCE.md).

**You reboot and get a text console, or a black screen, and never a desktop.** Nothing in
this repo starts a session, so this is step 6 rather than a fault. Check in that order:

```bash
ls /usr/share/wayland-sessions/          # the compositors are installed at all
systemctl status display-manager         # something is meant to be greeting you
```

If the second says the unit does not exist, you have no display manager. Either set one
up, or log in at a console and type `Hyprland`. If it exists but failed, `journalctl -b
-u greetd` has the reason, and a text console is still reachable with `Ctrl`+`Alt`+`F2`.

**The bar does not appear.** Bare `waybar` will not start: there is no config at the
default path, on purpose, because one description of the bar is shared by both
compositors. Both launch it with explicit `-c` and `-s`. Start it the way the configs
do:

```bash
waybar -c ~/.config/waybar/hyprland.jsonc -s ~/.config/waybar/style.css
```

**Icons show as empty boxes.** A missing glyph, not a broken config. Check whether the
font has the codepoint:

```bash
fc-list ":charset=f0e7" family | grep -i "hack nerd"
```

Nothing printed means the glyph is absent. Nerd Fonts v3 dropped a whole range that
older configs used.

**The launcher comes up with no colours.** wofi cannot import the shared palette file,
so the generator inlines the palette into `.config/wofi/style.css` between
`/* >>> VOIDASHI COLORS (GENERATED) >>> */` markers. If you edited inside those markers,
rerun `python3 scripts/theme/generate_theme.py`.

**`backup-configs.sh check` says a file is not a symlink any more.** Something replaced
the link with a real file. KDE does this to `.config/gtk-3.0/gtk.css` whenever a KDE
application starts. Look at the file first, then re-link:

```bash
./scripts/backup-configs.sh install --force
```

**Qt applications come up light while everything else is dark.** Two separate causes,
so check both.

First, is the variable set at all?

```bash
echo "$QT_QPA_PLATFORMTHEME"      # expect: kde
```

If it is empty, the session did not pick up
`~/.config/environment.d/50-voidashi.conf`. That file is the only thing that sets it
under Sway, because Sway has no way to set an environment variable from its own config.
It is read by `systemd --user`, so how you started the session decides whether Sway sees
it: launched from a display manager it does, but typed at a text console it inherits your
login shell's environment instead, which does not include it. Put the variable in your
shell profile if you start Sway that way. Step 6 above covers both launch paths. Hyprland
is unaffected either way, since `conf/env_vars.lua` sets the variable itself.

Second, is anything honouring it? `plasma-integration` provides the platform theme the
variable actually loads. Without that package the variable is set and nothing reads it,
silently. It is declared in `packages.conf`, so a full install covers it:

```bash
pacman -Q plasma-integration
```

**Terminal colours look wrong in one emulator only.** Its generated palette include is
probably stale or was edited by hand:

```bash
python3 scripts/theme/check_palette.py
```

**Clipboard history is empty.** The store daemon has to be running; it is what feeds the
history, and the keybinding only reads it.

```bash
pgrep -x wl-paste || echo "not running: log out and back in"
```

**Nothing locks or suspends on idle.** Same cause, different daemon:

```bash
pgrep -x hypridle || echo "not running: log out and back in"
```

**Something else.** Most of these applications can check their own config, which beats
guessing. The full list of commands is in [`MAINTENANCE.md`](MAINTENANCE.md), and the
quick ones are:

```bash
hyprctl configerrors                            # empty means clean
sway --validate -c ~/.config/sway/config
python3 scripts/theme/check_palette.py
./scripts/backup-configs.sh check
```
