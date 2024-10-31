# 🛠️ Dotfiles Management Script

## 📝 Overview

The `manage.sh` script is a robust utility for managing dotfiles with safety and flexibility. It handles installation, backup, restoration, and version control of your configuration files.

## 🎯 Core Concepts

- **Dotfiles Directory**: All configurations are stored in `~/.dotfiles`
- **Symlinks**: Original locations link to files in the dotfiles directory
- **Backups**: Automatic timestamped backups before any changes
- **Categories**: Configurations grouped by functionality (e.g., nvim, bash)

## 🚀 Getting Started

### Initial Setup

1. **Initialize Repository**:
   ```bash
   ./manage.sh init
   ```
   This creates the dotfiles directory and initializes Git.

2. **Preview Changes**:
   ```bash
   ./manage.sh preview
   ```
   Shows what files will be affected before making changes.

3. **Install Configurations**:
   ```bash
   # Install everything
   ./manage.sh install
   
   # Or install specific parts
   ./manage.sh install nvim
   ```

### Daily Usage

#### Adding New Configurations
1. Add paths to `scripts/dotfiles/dotfiles.conf`:
   ```bash
   ~/.config/new-tool/config
   ```

2. Run the add command:
   ```bash
   ./manage.sh add
   ```
   This moves files to the dotfiles repository and creates symlinks.

#### Checking Setup
```bash
# Verify symlink integrity
./manage.sh check

# List available categories
./manage.sh list
```

#### Handling Changes
- The script prompts for Git commits when adding files
- Shows diffs before replacing existing files
- Creates backups automatically in `~/.dotfiles_backup/`

#### Restoration
```bash
# Restore from latest backup
./manage.sh restore
```

## 🔍 Command Details

### `init`
- Creates `~/.dotfiles` directory
- Initializes Git repository
- Sets up basic structure

### `add`
- Moves files to dotfiles repository
- Creates symlinks in original locations
- Offers Git integration
- Creates backups of existing files

### `check`
- Verifies all symlinks
- Reports broken or incorrect links
- Shows status of each configured file

### `preview`
- Shows planned changes
- Indicates new, existing, and linked files
- Requires confirmation before proceeding

### `install`
- Creates necessary directories
- Shows diffs for existing files
- Offers selective installation
- Creates backups automatically

### `list`
- Shows available configuration categories
- Based on directory structure
- Helps with partial installations

### `restore`
- Recovers files from latest backup
- Maintains directory structure
- Preserves timestamps

## 🛡️ Safety Features

- **Automatic Backups**: Timestamped copies in `~/.dotfiles_backup/`
- **Interactive Prompts**: Confirmation before overwrites
- **Diff Viewing**: Compare changes before applying
- **Error Handling**: Strict mode with helpful messages
- **Dry Run**: Preview mode for safety

## 🤝 Contributing

The script is designed to be extensible. Contributions welcome for:
- New features
- Better error handling
- Additional safety checks
- Performance improvements
- Documentation updates

## 📄 License

[MIT License](LICENSE)

## 🎯 Future Enhancements

- [ ] Remote backup integration
- [ ] Multiple backup management
- [ ] Configuration templates
- [ ] Plugin system for extensions
