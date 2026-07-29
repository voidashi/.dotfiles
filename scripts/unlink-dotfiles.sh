#!/bin/bash
# Purpose: Revert all symlinks and restore files from the dotfiles repo to their original locations.
# Usage: ./unlink-dotfiles.sh   (run from inside scripts/, like the other scripts here)

# Configuration (MUST match your original script's settings)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
# Resolved from the script's own location, same as backup-configs.sh. It used
# to point at ~/scripts/dotfiles/, which was a separate copy and no longer
# exists.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/config_files.conf}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles_backup}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Resolve paths (e.g., ~/.config → /home/user/.config)
resolve_path() {
  echo "$1" | sed "s#^~#$HOME#"
}

# Load valid entries from config file
load_dotfiles() {
  grep -vE '^\s*(#|$)' "$CONFIG_FILE" || {
    echo -e "${RED}[ERROR]${NC} No valid entries found in $CONFIG_FILE."
    exit 1
  }
}

# Main restore logic
restore() {
  while IFS= read -r entry; do
    local original_path="$(resolve_path "$entry")"
    local repo_path="$DOTFILES_DIR/${original_path#$HOME/}"

    # Skip if the repo path doesn't exist
    if [ ! -e "$repo_path" ]; then
      echo -e "${YELLOW}[SKIPPED]${NC} Not in repo: $original_path"
      continue
    fi

    # Remove symlink if it points to the repo
    if [ -L "$original_path" ] && [ "$(readlink "$original_path")" = "$repo_path" ]; then
      rm -f "$original_path"
      echo -e "${GREEN}[REMOVED SYMLINK]${NC} $original_path"
    fi

    # Move file/dir from repo back to original location
    if [ -e "$repo_path" ]; then
      mkdir -p "$(dirname "$original_path")"
      mv -f "$repo_path" "$original_path"
      echo -e "${GREEN}[RESTORED]${NC} $original_path"
    fi
  done < <(load_dotfiles)

  # Cleanup empty directories in the repo. O -not -path protege o .git:
  # it has legitimately empty directories of its own (refs/tags, for one).
  find "$DOTFILES_DIR" -type d -empty -not -path "$DOTFILES_DIR/.git/*" -delete 2>/dev/null
}

# Safety confirmation
echo -e "${YELLOW}WARNING: This will delete all symlinks and restore files from $DOTFILES_DIR to their original locations.${NC}"
echo -e "${YELLOW}The files are MOVED out of the repo, so the repo is left essentially empty.${NC}"
read -p "Are you sure you want to continue? (y/N): " response
case "$response" in
  [Yy]*) restore ;;
  *)     echo "Aborted."; exit 0 ;;
esac
