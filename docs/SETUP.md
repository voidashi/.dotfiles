# Setting these dotfiles up

The long version of the README's install section, plus the two things it cannot fit:
what you have to change for your own machine, and what to do when something does not
work.

If you want to change how it *looks*, that is a different document:
[`design/RICE-GUIDE.md`](design/RICE-GUIDE.md) holds the palette and the rules, and
[`design/THEMING.md`](design/THEMING.md) says how a colour reaches each application.

## Before you start

This is built for **Arch Linux on Wayland**. The package installer also handles apt
and dnf, but the configs themselves assume Arch: package names, AUR fallbacks, and
Hyprland at a version recent enough for a Lua config.

You will want an AUR helper (`paru`, `yay` or `pikaur`) already installed. A handful of
packages have no official-repo version and the installer falls back to whichever helper
it finds.

Nothing here needs root except the package install itself.

## Install

```bash
git clone https://github.com/voidashi/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

**The path matters.** Clone to `~/.dotfiles` exactly. Seven lines across five tracked
files reference `$HOME/.dotfiles` absolutely: the wallpaper picker and the clipboard picker in both
compositors' configs, the bar's power button, and Neovim's dashboard. Clone anywhere else
and those four things stop working with no error at all. If you must use another path,
grep for it first and change every hit:

```bash
grep -rn '\$HOME/\.dotfiles' .config/
```

**1. See what would be installed, before installing it.**

```bash
./scripts/install-packages.sh preview
```

**2. Install the packages.**

```bash
./scripts/install-packages.sh install
```

This asks for sudo. It logs to `scripts/package_install.log`, overwritten each run.

**3. Link the configs into your home directory.**

```bash
./scripts/backup-configs.sh install
```

This creates symlinks from `$HOME` into the repo. It **refuses to overwrite** a real
file that is already there. If you want it to replace one, pass `--force`, and it backs
the original up into `~/.dotfiles_backup/<timestamp>/` before removing it.

**4. Check that it worked.**

```bash
./scripts/backup-configs.sh check
```

Every tracked path should report as a symlink into the repo.

**5. Set up a way into the session.**

Nothing so far gives you a graphical login. The packages and the symlinks are only the
contents of a session; a fresh Arch install has nothing that starts one, so this is the
step between a working install and a black screen. You need one of the two paths below,
not both.

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
command = "tuigreet --time --remember --asterisks --sessions /usr/share/wayland-sessions --cmd Hyprland"
user = "greeter"
```

`--cmd` is the fallback if you press Enter without choosing; `--sessions` is what puts
Hyprland and Sway on the menu. Enable it for the *next* boot rather than starting it now:

```bash
sudo systemctl enable greetd.service
```

Use `enable` and reboot, not `enable --now`. Starting a display manager on top of a
session you are already sitting in takes that session down with it, and if the config has
a typo you want to land at a text console rather than a blank screen.

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

**6. Make fish your login shell**, if you want the prompt this repo themes.

```bash
chsh -s /usr/bin/fish
```

Nothing does this for you, and without it you get bash with its default prompt while
everything else looks themed. The tracked `.bashrc` is deliberately a stock one, so
there is no clue that anything is missing. Starship and the fish colour scheme both live
under `.config/fish/`, so they only apply once fish is actually the shell you land in.

**7. Log out and back in**, so the compositor picks up the new config and starts the
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

To undo everything, `./scripts/unlink-dotfiles.sh` removes the symlinks and moves the
files back. It asks for confirmation.

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

**The lid switch**, `.config/hypr/conf/binds.lua:114` and `:116`, also names `eDP-1`.
Change it to your internal display, or delete both lines if you are on a desktop.

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

**Sway sets no outputs at all**, so it uses whatever your compositor detects. If you
need a specific layout there, add `output` lines to `.config/sway/config`.

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

**Iosevka is the exception and you have to fetch it yourself.** Its full-family build is
around 430MB, too large to keep in git, so `fonts/Iosevka/` is gitignored. Download the
Iosevka SGr TTC build from [the releases
page](https://github.com/be5invis/Iosevka/releases), unpack it into `fonts/Iosevka/`,
then rerun `backup-configs.sh install`. Until you do, terminals fall back to whatever
monospace font fontconfig picks, which still works but is not the design.

## Wallpapers

`scripts/wm/select-random-wallpaper.sh` takes a list of directories and picks a random
image from the first one that actually contains images. Both compositors call it with
the same three:

| Directory | Purpose |
|---|---|
| `~/Pictures/Current_wallpapers` | The set currently in rotation |
| `~/Pictures/Wallpapers` | A full personal collection |
| `~/.dotfiles/wallpapers` | The sample shipped here |

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
this repo starts a session, so this is step 5 rather than a fault. Check in that order:

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
shell profile if you start Sway that way. Step 5 above covers both launch paths. Hyprland
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
