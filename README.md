# 🖥️ Zen Linux Dotfiles

*A curated collection of minimal, performant, and aesthetic Linux configurations*

[![Linux](https://img.shields.io/badge/OS-Linux-informational?style=flat&logo=linux&logoColor=white)](https://www.linux.org/)
[![Arch](https://img.shields.io/badge/Distro-Arch_Linux-informational?style=flat&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat)](LICENSE)

![Hyprland Screenshot](./.github/screenshot.png) *Example: Hyprland WM Setup*

## 📦 Features

### **Core Components**
- Window Managers: Hyprland + Sway (Wayland)
- Terminals: Ghostty • Alacritty • Kitty • Foot
- Shell: Fish with Starship prompt
- Editor: Neovim
- System: Bottom • Dunst • Waybar • Wofi

### **Key Configurations**
- Unified theming (Kanagawa Dragon)
- Performance-optimized WM rules
- Battery-friendly power management
- Context-aware workspace layouts
- Seamless clipboard integration

### **Automation Tools**
- `backup-configs.sh` - Smart config synchronization
- `install-packages.sh` - Cross-distro package installer
- 1-click restore for new installations

## 🚀 Installation

### Quick Start (For Brave Souls)
#### WIP: TO BE ADDED
```bash
git clone https://github.com/voidashi/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Backup existing configs (optional but recommended)
./scripts/backup-configs.sh add

# Install packages and apply configs
./scripts/install-packages.sh install
```

**Note:** Review config files before running install scripts!

## 🗂️ Structure
#### WIP: TO BE ADDED
```
.
├── config/               # Main config directory
│   ├── hypr/            # Hyprland window manager
│   ├── nvim/            # Neovim IDE setup
│   ├── fish/            # Fish shell configuration
│   └── ...              # Other app configs
├── scripts/              # Maintenance utilities
├── wallpapers/           # Curated desktop backgrounds
├── backup-configs.sh     # Config synchronization tool
└── install-packages.sh   # Package management system
```

## 🔧 Customization
#### WIP: TO BE ADDED
1. Edit `config_files.conf` to select tracked configurations
2. Modify `packages.conf` to add/remove applications
3. Adjust theme colors in `.config/colorscheme/`

## 🤝 Contributing
Found a bug? Have an improvement?  
- Open an issue for feature requests
- Submit PRs for well-documented fixes
- Share your modified configs in Discussions

## 📜 License
MIT Licensed - See [LICENSE](LICENSE) for details

---

*Inspired by the Linux ricing community • Built with ❤️ and too much coffee*