# ✨ Dotfiles

This repository contains my personal **dotfiles** and a management script to facilitate the installation, synchronization, and restoration of these files across multiple machines. With it, you can keep your configurations consistent and synchronized between different devices.

## 📂 Content

This repository manages configurations for:

- **Bash** (`~/.bashrc`)
- **Starship** (`~/.config/starship.toml`)
- **Fish** (`~/.config/fish/`)
- **Foot** (`~/.config/foot/`)
- **Hyprland** (`~/.config/hypr/`)
- **Neovim** (`~/.config/nvim/`)
- **Sway** (`~/.config/sway/`)
- **Waybar** (`~/.config/waybar/`)

## 🚀 Script Features

The `manage.sh`, inside `scripts/dotfiles/` script provides a comprehensive set of features to manage your dotfiles effectively. Here are the main functionalities:

### ⚙️ Initialize
Initialize the dotfiles directory and set up Git repository:
```bash
./manage.sh init
```

### ➕ Add Files
Move files/directories listed in `dotfiles.conf`, inside `scripts/dotfiles/` to the `.dotfiles` directory, create symlinks in the home folder, and optionally commit to Git:
```bash
./manage.sh add
```

### 🔍 Check Symlinks
Verify if all dotfile symlinks are correctly configured:
```bash
./manage.sh check
```

### 👀 Preview Changes
Preview planned changes before installation:
```bash
./manage.sh preview
```

### 📦 Install
Install all dotfiles or a specific category:
```bash
# Install all
./manage.sh install

# Install specific category
./manage.sh install nvim
```

### 📋 List Categories
Show available configuration categories:
```bash
./manage.sh list
```

### 🔄 Restore
Restore files from the latest backup:
```bash
./manage.sh restore
```

## 🖥️ Setup on a New Machine

To set up your dotfiles on a new machine, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/voidashi/.dotfiles.git ~/.dotfiles
   ```

2. **Review planned changes** (optional but recommended):
   ```bash
   cd ~/.dotfiles/scripts/dotfiles
   ./manage.sh preview
   ```

3. **Install the dotfiles**:
   ```bash
   # Install everything
   ./manage.sh install

   # Or install specific categories
   ./manage.sh install nvim
   ./manage.sh install bash
   ```

The script will automatically create backups of existing files before making any changes. Backups are stored in `~/.dotfiles_backup/` with timestamps.

## 🛠️ Customization

To add new files or directories to the repository:

1. **Edit the `dotfiles.conf`** file in `scripts/dotfiles/dotfiles.conf`, adding the full paths of desired files or directories.

   Example:
   ```bash
   # Adding Zsh configuration
   ~/.zshrc
   ~/.zsh_aliases
   ```

2. **Run the add command** to move the files to the dotfiles repository:
   ```bash
   ./manage.sh add
   ```

## 🔒 Safety Features

- **Automatic Backups**: The script creates timestamped backups before making any changes
- **Preview Mode**: Review changes before applying them
- **Diff Viewing**: Compare existing files with repository versions before installation
- **Category-based Installation**: Install only specific configuration categories
- **Symlink Verification**: Check if all symlinks are correctly configured

## 📝 Contributing

If you have suggestions, improvements, or found issues, feel free to open a pull request or report a problem!

## 🛡️ License

This project is licensed under the [MIT License](LICENSE). Feel free to use and modify as needed.
