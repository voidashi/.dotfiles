# 🛠️ Dotfiles Management Script

## 📝 Overview

The `manage.sh` script is a comprehensive bash utility designed to manage dotfile configurations efficiently and safely.

## 🌟 Key Features

### 🔒 Safety First
- Automatic backup of existing configurations
- Preview mode to review changes
- Symlink integrity verification
- Timestamped backup directories

### 🚀 Flexible Management
- Initialize dotfiles repository
- Add new configurations
- Install all or specific configuration categories
- Restore from backups
- Git integration for version control

## 🖥️ Usage Guide

### Basic Commands

```bash
# Initialize dotfiles repository
./manage.sh init

# Add files to dotfiles
./manage.sh add

# Check symlink configuration
./manage.sh check

# Preview planned changes
./manage.sh preview

# Install all configurations
./manage.sh install

# Install specific category (e.g., nvim)
./manage.sh install nvim

# List available categories
./manage.sh list

# Restore from latest backup
./manage.sh restore
```

## 📂 Configuration

Manage which files are tracked via `scripts/dotfiles/dotfiles.conf`:
- List full paths of files/directories
- Use `#` for comments
- One path per line

Example:
```bash
~/.bashrc
~/.config/nvim/init.lua
~/.config/starship.toml
```

## 🔍 How It Works

1. **Initialization**: Creates a Git repository in `~/.dotfiles`
2. **Adding Files**: 
   - Moves specified files to `.dotfiles`
   - Creates symlinks in original locations
   - Optional Git commit
3. **Installation**: 
   - Backs up existing files
   - Creates symlinks to dotfiles repository
4. **Restoration**: Recovers files from timestamped backup

## 🛡️ Error Handling

- Strict error handling with `set -euo pipefail`
- Colorized logging
- Detailed error messages
- Interactive confirmation prompts

## 🤝 Contributing

Improvements and bug reports are welcome! Open an issue or submit a pull request.

## 📄 License

[MIT License](LICENSE)