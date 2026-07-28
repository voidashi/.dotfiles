# 🖥️ Zen Linux Dotfiles

*A curated collection of minimal, performant, and aesthetic Linux configurations*

[![Linux](https://img.shields.io/badge/OS-Linux-informational?style=flat&logo=linux&logoColor=white)](https://www.linux.org/)
[![Arch](https://img.shields.io/badge/Distro-Arch_Linux-informational?style=flat&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat)](LICENSE)

![Hyprland Screenshot 1](docs/screenshot1.png)
![Hyprland Screenshot 2](docs/screenshot2.png)

## 📦 Features

### **Core Components**
- Window Managers: Hyprland + Sway (Wayland)
- Terminals: Ghostty • Alacritty • Kitty • Foot
- Shell: Fish with Starship prompt
- Editor: Neovim
- System: Bottom • Dunst • Waybar • Wofi

### **Key Configurations**
- Unified theming (Voidashi — see `docs/design/`)
- Performance-optimized WM rules
- Battery-friendly power management
- Context-aware workspace layouts
- Seamless clipboard integration

### **Automation Tools**
- `backup-configs.sh` - Smart config synchronization
- `install-packages.sh` - Cross-distro package installer (with AUR support)
- `unlink-dotfiles.sh` - Undo the symlinks and move files back to `$HOME`
- 1-click restore for new installations

## 🚀 Installation

### Quick Start (For Brave Souls)
```bash
git clone https://github.com/voidashi/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install packages
./scripts/install-packages.sh install

# Install configs
./scripts/backup-configs.sh install
```

**Note:** Review config files before running install scripts!

## 🗂️ Structure
```
.
├── .config/               # Main config directory
│   ├── hypr/            # Hyprland window manager
│   ├── nvim/            # Neovim IDE setup
│   ├── fish/            # Fish shell configuration
│   └── ...              # Other app configs
├── scripts/              # Maintenance utilities (you run these by hand)
│   └── wm/              # Helpers the WM configs call at runtime
├── wallpapers/           # Sample wallpaper shipped with the repo
...
```

## 📜 Scripts

Two different kinds of script live here, split by **who runs them**:

| Path | Who runs it |
|---|---|
| `scripts/*.sh` | You, by hand — installing packages, linking/unlinking configs |
| `scripts/wm/*.sh` | Hyprland and Sway, automatically, while running |

All of them resolve their config files relative to the script's own location,
so they work from anywhere.

### Wallpapers

`scripts/wm/select_random_wallpaper.sh` takes a list of directories and picks a
random image from the **first one that actually contains images**. Both WMs call
it with the same three-tier chain:

| Directory | Purpose |
|---|---|
| `~/Pictures/Current_wallpapers` | The set currently in rotation |
| `~/Pictures/Wallpapers` | Full personal collection |
| `~/.dotfiles/wallpapers` | Sample shipped with the repo |

The last entry is the fallback, so a fresh clone shows a wallpaper immediately.
The personal folders are deliberately **not** tracked here — GitHub is a poor
place to store image libraries. Copy the sample out of `wallpapers/` into one of
the first two once you've cloned.

The lock screen is plain `swaylock`; its appearance comes from
`.config/swaylock/config`.

### Fonts

`fonts/` bundles the faces the theme depends on (Hack Nerd Font, Inter, Roboto
Mono, Ubuntu Mono, Instrument Sans, Spectral). `backup-configs.sh install`
symlinks the whole directory to `~/.local/share/fonts/dotfiles` and refreshes
the font cache, so a fresh clone gets them automatically — no separate step.

**Iosevka is the exception.** Its full-family build is ~430MB and is
`.gitignore`d rather than committed. Download the "Iosevka" SGr TTC build (or
any variant you prefer) from https://github.com/be5invis/Iosevka/releases,
drop it into `fonts/Iosevka/`, then rerun `backup-configs.sh install` — the
symlink and cache refresh pick it up the same way as the tracked fonts.

## 🔧 Customization
1. Edit `scripts/config_files.conf` to select tracked configurations
2. Modify `scripts/packages.conf` to add/remove applications

## 🤝 Contributing
Found a bug? Have an improvement?  
- Open an issue for feature requests
- Submit PRs for well-documented fixes
- Share your modified configs in Discussions

## 📜 License
MIT Licensed - See [LICENSE](LICENSE) for details

---

*Inspired by the Linux ricing community • Built with ❤️ and too much coffee*
