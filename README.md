# Voidashi dotfiles

A Wayland desktop for Arch Linux, themed end to end from a single palette file.
Two compositors (Hyprland and Sway), four terminal emulators, fish, Neovim, and the
shell surfaces around them: bar, launcher, notifications, lock screen, power menu.

[![Arch](https://img.shields.io/badge/Distro-Arch_Linux-informational?style=flat&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Wayland](https://img.shields.io/badge/Display-Wayland-informational?style=flat)](https://wayland.freedesktop.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat)](LICENSE)

![Hyprland Screenshot 1](docs/screenshot1.png)
![Hyprland Screenshot 2](docs/screenshot2.png)

*The screenshots predate the current theme and are due to be retaken.*

## What makes this different from most dotfiles

Every colour in every application comes from one file, `scripts/theme/palette.json`,
and a generator renders it into the format each program natively reads. Change a hex
there, run the generator, and the terminals, the bar, the launcher, Neovim, GTK
applications and KDE applications all move together. A checker then proves nothing
drifted.

That is the whole point of the repository. The design identity behind it is called
Voidashi and is documented under `docs/design/`.

```bash
$EDITOR scripts/theme/palette.json          # change a value
python3 scripts/theme/generate_theme.py     # render it into every app's own format
python3 scripts/theme/check_palette.py      # prove nothing drifted
```

The generator is stdlib-only Python, no dependencies. Its output files carry a
`GENERATED` header and should never be edited by hand; the checker fails if they were.

## What is configured

| Piece | Program | Notes |
|---|---|---|
| Compositor | Hyprland | Native Lua config, entry point `.config/hypr/hyprland.lua` |
| Compositor | Sway | The fallback, themed to match |
| Bar | Waybar | One config described once, with a thin per-compositor file on top |
| Launcher | wofi | `hyprlauncher` is configured too, commented out |
| Notifications | swaync | Started by both compositors |
| Lock screen | swaylock | Themed entirely from its own config file, no wrapper |
| Power menu | wlogout | Launched through `scripts/wm/power-menu.sh`, never bare |
| Clipboard | cliphist | History on `SUPER`+`Shift`+`V`, through the same wofi |
| Idle | hypridle, swayidle | Lock at 5 min, screen off at 6, suspend at 30 |
| Terminals | Kitty, Ghostty, Alacritty, Foot | Identical palette, font and padding in all four |
| Shell | fish + starship | |
| Editor | Neovim | lazy.nvim, with a colorscheme written for this palette rather than a plugin |
| File managers | Dolphin, yazi | Graphical and terminal |
| System monitor | bottom | |
| Fetch | fastfetch, catnap | |
| Wallpaper | swaybg | Set from a random image, see Wallpapers |
| Application theming | GTK 3, GTK 4, Qt/KDE | Generated named colours and a generated `kdeglobals` |

## Installation

```bash
git clone https://github.com/voidashi/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

./scripts/install-packages.sh preview    # see what it would install first
./scripts/install-packages.sh install
./scripts/backup-configs.sh install
```

`backup-configs.sh install` symlinks the repository's files into `$HOME`. It refuses to
overwrite a real file that is already there unless you pass `--force`, in which case it
backs the original up first. Read the configs before running it; a desktop config is
opinionated by nature and this one is opinionated about a lot.

The package installer detects pacman, apt or dnf, and falls back to an AUR helper on
Arch for the handful of packages that need one. The configs themselves assume Arch and
Wayland.

To check afterwards that every tracked path really is a symlink into the repository:

```bash
./scripts/backup-configs.sh check
```

## Layout

```
.
├── .config/                  # one directory per application, symlinked into ~/.config
├── docs/
│   ├── design/               # the design documents, start with RICE-GUIDE.md
│   └── TODO.md               # open work, including what is missing
├── fonts/                    # the four faces the theme uses
├── scripts/
│   ├── backup-configs.sh     # link, unlink and audit the tracked dotfiles
│   ├── install-packages.sh   # cross-distro package installer
│   ├── unlink-dotfiles.sh    # the inverse of the above, moves files back to $HOME
│   ├── theme/                # palette.json, the generator and the checker
│   └── wm/                   # helpers the compositors call while running
└── wallpapers/               # one sample, so a fresh clone has something to show
```

## Scripts

Two kinds live here, split by who runs them:

| Path | Who runs it |
|---|---|
| `scripts/*.sh` | You, by hand: installing packages, linking and unlinking configs |
| `scripts/wm/*.sh` | Hyprland and Sway, automatically, while running |

All of them resolve their config files relative to the script's own location, so they
work from any directory.

## Keybindings

The entry points under Hyprland, with `SUPER` as the modifier. The full set is in
`.config/hypr/conf/binds.lua`, which is readable Lua rather than a config dialect.

| Keys | Action |
|---|---|
| `SUPER` + `Return` | Terminal |
| `SUPER` + `R` | Launcher |
| `SUPER` + `E` | File manager, `SUPER` + `Shift` + `E` for yazi in a terminal |
| `SUPER` + `Q` | Close window, `SUPER` + `Shift` + `Q` to kill it |
| `SUPER` + `F` | Fullscreen, `SUPER` + `V` to toggle floating |
| `SUPER` + `Shift` + `V` | Clipboard history |
| `SUPER` + `1`…`9` | Switch workspace, add `Shift` to move the window there |
| `Print` | Screenshot the output, `Shift` for a region, `SUPER` for the window |
| `SUPER` + `M` | Exit the compositor |

The power menu opens from the bar's power button rather than a keybinding. Closing the
lid locks the screen.

Sway's bindings live in `.config/sway/config` and are close to these but not identical:
its launcher is on `$mod` + `D`, for instance.

## Wallpapers

`scripts/wm/select-random-wallpaper.sh` takes a list of directories and picks a random
image from the first one that actually contains images. Both compositors call it with
the same three-tier chain:

| Directory | Purpose |
|---|---|
| `~/Pictures/Current_wallpapers` | The set currently in rotation |
| `~/Pictures/Wallpapers` | Full personal collection |
| `~/.dotfiles/wallpapers` | Sample shipped with the repository |

The last entry is the fallback, so a fresh clone shows a wallpaper immediately. The two
personal directories are deliberately not tracked, because GitHub is a poor place to
store an image library. Copy the sample out of `wallpapers/` into one of the first two
once you have cloned.

What the theme asks of a wallpaper is in `docs/design/RICE-GUIDE.md`: at or below the
darkest UI surface in perceived lightness, warm-neutral or neutral, heavily desaturated.
A solid dark fill is always a legitimate choice.

## Fonts

`fonts/` bundles the faces the theme uses, one per voice in the typography table of
`docs/design/RICE-GUIDE.md`:

| Face | Voice | Where |
|---|---|---|
| Iosevka Extended | mono, primary | Terminals, editor, TUIs |
| Hack Nerd Font | mono, glyphs | Icons Iosevka does not cover |
| Instrument Sans | sans, secondary | GTK and Qt application UI |
| Spectral | serif, exceptional | Lock screen, fetch banners |

`backup-configs.sh install` symlinks the directory to `~/.local/share/fonts/dotfiles`
and refreshes the font cache, so a fresh clone gets them with no separate step.

**Iosevka is the exception.** Its full-family build is around 430MB, too large to
version, so `fonts/Iosevka/` is gitignored. Download the Iosevka SGr TTC build from
[the releases page](https://github.com/be5invis/Iosevka/releases), drop it into
`fonts/Iosevka/`, then rerun `backup-configs.sh install`; the symlink and cache refresh
pick it up the same way as the tracked fonts.

## Customising

- `scripts/config_files.conf` is the list of paths `backup-configs.sh` manages. Add a
  path here before running `add`.
- `scripts/packages.conf` is the package list, with per-distro name overrides.
- `scripts/theme/palette.json` is every colour, and the fonts and geometry that Qt and
  GTK read. Rerun the generator after editing it.

## Documentation

[`docs/README.md`](docs/README.md) indexes all six documents and says which
question each one owns. The two worth knowing about up front:

- [`docs/design/RICE-GUIDE.md`](docs/design/RICE-GUIDE.md) is the authority on
  anything visual. The palette, the ANSI mapping, and the rules for how colour
  gets assigned all live there.
- [`docs/TODO.md`](docs/TODO.md) is what is open, what is parked with the
  explanations already ruled out, and what has been decided against.

## Known gaps

Named here rather than left for you to discover:

- **Workspace buttons in the bar are not clickable.** Traced to the Waybar build rather
  than to this configuration; the full elimination is written down in `docs/TODO.md`.
  Keyboard switching works.
- **Workspace layouts are geometric, not per-application.** A workspace holding a single
  window drops its gaps and borders, but no application is assigned to a workspace.
- **No power profiles.** Idle handling exists, but switching a CPU governor or a platform
  profile does not, since that is a system service rather than a dotfile.

`docs/TODO.md` carries these with the shape of the work each one needs.

## Contributing

Issues and pull requests are welcome. This is a personal configuration rather than a
framework, so the useful contributions are usually bug reports, portability fixes, and
telling me something is wrong on a machine that is not mine.

## License

MIT. See [LICENSE](LICENSE).
