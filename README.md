# Voidashi dotfiles

A dark, warm-charcoal Wayland desktop for Arch Linux, themed end to end from a single
file.

[![Arch](https://img.shields.io/badge/Distro-Arch_Linux-informational?style=flat&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Wayland](https://img.shields.io/badge/Display-Wayland-informational?style=flat)](https://wayland.freedesktop.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat)](LICENSE)

![Hyprland Screenshot 1](docs/screenshot1.png)
![Hyprland Screenshot 2](docs/screenshot2.png)

*The screenshots predate the current theme and are due to be retaken.*

## Is this for you?

**Probably yes** if you run Arch on Wayland, want a desktop that looks deliberate
rather than assembled, and would rather change one file than thirty.

**Probably not** if you are on X11, on a distro other than Arch, or looking for a
framework you can configure without reading anything. This is one person's desktop,
published because the theming approach is worth copying, not a distribution.

You do not have to take all of it. Every piece is a normal config file in its normal
place, so you can lift the terminal colours, or the bar, or just the palette
generator, and ignore the rest.

## The one idea worth stealing

Every colour in every application comes from **one file**:
`scripts/theme/palette.json`. A generator renders it into the format each program
natively reads, and a checker proves nothing drifted afterwards.

```bash
$EDITOR scripts/theme/palette.json          # change a colour
python3 scripts/theme/generate_theme.py     # push it into every app's own format
python3 scripts/theme/check_palette.py      # prove nothing was missed
```

Change one hex and the terminals, the bar, the launcher, Neovim, GTK applications and
KDE applications all move together. The generator is plain Python with no
dependencies. Its output carries a `GENERATED` header, and the checker fails if you
edit it by hand.

The design identity behind the palette is called Voidashi, and it is documented in
[`docs/design/`](docs/design/).

## What is in it

| Piece | Program | Notes |
|---|---|---|
| Compositor | Hyprland | Native Lua config, entry point `.config/hypr/hyprland.lua` |
| Compositor | Sway | The fallback, themed to match |
| Bar | Waybar | One description of the bar, shared by both compositors |
| Launcher | wofi | hyprlauncher is configured too, commented out |
| Notifications | swaync | |
| Lock screen | swaylock | |
| Power menu | wlogout | Launched through `scripts/wm/power-menu.sh`, never bare |
| Clipboard | cliphist | History on `Super`+`Shift`+`V` |
| Idle | hypridle, swayidle | Lock at 5 min, screen off at 6, suspend at 30 |
| Terminals | Kitty, Ghostty, Alacritty, Foot | Identical palette, font and padding in all four |
| Shell | fish + starship | |
| Editor | Neovim | lazy.nvim, with a colorscheme written for this palette rather than a plugin |
| File managers | Dolphin, yazi | Graphical and terminal |
| System monitor | bottom | |
| Fetch | fastfetch, catnap | |
| Wallpaper | swaybg | A random image from your own directory |
| Applications | GTK 3, GTK 4, Qt and KDE | Themed by overriding the colours each toolkit already paints from |

## Install

```bash
git clone https://github.com/voidashi/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

./scripts/install-packages.sh preview    # see what it would install
./scripts/install-packages.sh install    # install it
./scripts/backup-configs.sh install      # symlink the configs into $HOME
./scripts/backup-configs.sh check        # confirm every link landed
```

Then log out and back in.

> [!WARNING]
> `backup-configs.sh install` is safe: it refuses to overwrite a real file unless you
> pass `--force`, and backs up anything it replaces. Its sibling `add` runs the other
> direction and **moves files out of `$HOME`** into the repo. You want `install`.

> [!IMPORTANT]
> Two things need a look before this feels right on your machine: the monitor layout in
> `.config/hypr/conf/monitors.lua` names specific outputs, and the bar carries
> laptop-only modules. [`docs/SETUP.md`](docs/SETUP.md) lists everything to change, with
> the file and line for each.

**[Full setup guide](docs/SETUP.md)** covers the long-form install, what to change for
your hardware, the Iosevka font you have to fetch yourself, and what to do when
something does not work.

## Keybindings

The entry points under Hyprland, with `Super` as the modifier. The full set is in
`.config/hypr/conf/binds.lua`, which is readable Lua rather than a config dialect.

| Keys | Action |
|---|---|
| `Super` + `Return` | Terminal |
| `Super` + `R` | Launcher |
| `Super` + `E` | File manager, add `Shift` for yazi in a terminal |
| `Super` + `Q` | Close window, add `Shift` to kill it |
| `Super` + `F` | Fullscreen, `Super` + `V` to toggle floating |
| `Super` + `Shift` + `V` | Clipboard history |
| `Super` + `1`…`9` | Switch workspace, add `Shift` to move the window there |
| `Print` | Screenshot the output, `Shift` for a region, `Super` for the window |
| `Super` + `M` | Exit the compositor |

The power menu opens from the bar's power button. Closing the lid locks the screen.

Sway's bindings are in `.config/sway/config` and are close but not identical: its
launcher is on `$mod` + `D`.

## Repository layout

```
.config/                  one directory per application, symlinked into ~/.config
docs/                     everything written down, see docs/README.md
fonts/                    the four faces the theme uses
scripts/
  backup-configs.sh       link, unlink and audit the tracked dotfiles
  install-packages.sh     cross-distro package installer
  unlink-dotfiles.sh      the inverse: move everything back to $HOME
  theme/                  palette.json, the generator and the checker
  wm/                     helpers the compositors call while running
wallpapers/               one sample, so a fresh clone has something to show
```

## Documentation

[`docs/README.md`](docs/README.md) indexes everything and says who each document is
for. The three that matter most:

- **[`docs/SETUP.md`](docs/SETUP.md)** to install it and make it yours.
- **[`docs/design/RICE-GUIDE.md`](docs/design/RICE-GUIDE.md)** for the palette, the
  ANSI table, and the rules about how colour gets used.
- **[`docs/TODO.md`](docs/TODO.md)** for what is open, what is parked and why, and what
  has been decided against.

## Known gaps

Named here rather than left for you to find:

- **Workspace buttons in the bar are not clickable.** Traced to the Waybar build rather
  than this configuration; the full elimination is written down in
  [`docs/TODO.md`](docs/TODO.md). Keyboard switching works.
- **Workspace layouts are geometric, not per-application.** A workspace holding a single
  window drops its gaps and borders, but no application is assigned to a workspace.
- **No power profiles.** Idle handling exists; switching a CPU governor does not, since
  that is a system service rather than a dotfile.

## Contributing

Issues and pull requests are welcome. This is a personal configuration rather than a
framework, so the most useful contributions are bug reports, portability fixes, and
telling me something is broken on a machine that is not mine.

## License

MIT. See [LICENSE](LICENSE).
