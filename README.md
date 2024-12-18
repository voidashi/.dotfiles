# Dotfiles Repository

Welcome to my **dotfiles** repository! This project is a curated collection of my personal Linux configurations. It serves as a backup of my essential settings and a way to quickly set up a new environment with my preferred tools and tweaks.

## Overview
This repository includes configurations for:

- Shell (e.g., `~/.bashrc`)
- Terminal emulators (e.g., Alacritty, Kitty)
- Editors (e.g., Neovim)
- Window managers and compositors (e.g., Sway, Hypr)
- Status bars (e.g., Waybar)
- Various utilities (e.g., Fish shell, Starship prompt, Dunst notifications, etc.)

## Managed Files and Directories
The following files and directories are tracked in this repository:

### Individual Files
- `~/.bashrc`
- `~/.config/starship.toml`

### Directories
- `~/.config/alacritty`
- `~/.config/bottom`
- `~/.config/catnap`
- `~/.config/dunst`
- `~/.config/fish`
- `~/.config/foot`
- `~/.config/hypr`
- `~/.config/kitty`
- `~/.config/nvim`
- `~/.config/sway`
- `~/.config/waybar`

## Features
- **Simple Backup and Restore**: A straightforward setup to ensure that all critical configurations are preserved.
- **Modular and Organized**: Easily customize or replace individual components without breaking the overall setup.
- **Minimalist Design**: Focused on lightweight, efficient, and modern tools.

## Getting Started
### Prerequisites
- A Linux distribution (tested on [your preferred distro]).
- Git installed.

### Clone the Repository
```bash
cd ~
git clone https://github.com/yourusername/dotfiles.git
```

### Backup Current Configurations
Before applying these dotfiles, back up any existing configurations to avoid overwriting anything important.

```bash
mkdir -p ~/backup_dotfiles
mv ~/.bashrc ~/.config ~/.ssh ~/backup_dotfiles
```

### Apply the Configurations
Manually copy or create symbolic links for the tracked files and directories to their appropriate locations.

## Customization
Feel free to modify any configuration to suit your workflow. Contributions and suggestions are also welcome!

## Future Plans
- Add automated installation scripts for dependencies.
- Expand support for more Linux applications.
- Improve documentation and setup process.

## License
This repository is licensed under the [MIT License](LICENSE).

---
**Happy configuring!**

