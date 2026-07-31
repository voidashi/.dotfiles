#!/bin/bash
# Purpose: Revert all symlinks and restore files from the dotfiles repo to their original locations.
# Usage: ./unlink-dotfiles.sh   (run from inside scripts/, like the other scripts here)

# Configuration (MUST match your original script's settings)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_DIR="${DOTFILES_DIR%/}"   # see the find at the end of restore()
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

FAILURES=0

# Main restore logic
restore() {
  while IFS= read -r entry; do
    local original_path
    original_path="$(resolve_path "$entry")"

    # The repo mirrors $HOME, so the mapping is a prefix strip, and an entry
    # that is not below $HOME strips to nothing and makes repo_path the repo
    # root itself. backup-configs.sh validates this in repo_relative(); this is
    # the fourth copy of the same mapping and the one that could disagree.
    case "${original_path%/}" in
      "$HOME"/?*) ;;
      *) echo -e "${RED}[ERROR]${NC} Not below \$HOME, skipping: $entry" >&2; continue ;;
    esac
    local repo_path="$DOTFILES_DIR/${original_path#"$HOME"/}"

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

    # Move the repo copy back, but never onto something that is already there.
    # This was `mv -f`, which has two ways of destroying work: onto a real file
    # it overwrites with no backup, and onto a real directory it moves the
    # source *inside* the destination, leaving ~/.config/hypr/hypr/. Either way
    # the script printed [RESTORED] in green. install refuses to touch a real
    # file without --force; the undo must not be more destructive than the
    # thing it undoes.
    if [ -e "$original_path" ] || [ -L "$original_path" ]; then
      echo -e "${YELLOW}[SKIPPED]${NC} $original_path already exists, leaving the repo copy at $repo_path"
      continue
    fi

    mkdir -p "$(dirname "$original_path")"
    if mv "$repo_path" "$original_path"; then
      echo -e "${GREEN}[RESTORED]${NC} $original_path"
    else
      echo -e "${RED}[ERROR]${NC} Could not move $repo_path → $original_path" >&2
      FAILURES=$((FAILURES + 1))
    fi
  done < <(load_dotfiles)

  # Cleanup empty directories in the repo. The -not -path protects .git, which
  # has legitimately empty directories of its own (refs/tags, for one).
  #
  # -mindepth 1 protects the repo root: -delete works depth-first, so once the
  # contents have moved out the root itself is empty and was being removed. The
  # trailing slash is stripped from DOTFILES_DIR at the top of this file, because
  # find normalises the paths it emits but the -path pattern is built by
  # concatenation, and a doubled slash made the .git exclusion match nothing.
  find "$DOTFILES_DIR" -mindepth 1 -type d -empty -not -path "$DOTFILES_DIR/.git/*" -delete 2>/dev/null
}

# Safety confirmation
echo -e "${YELLOW}WARNING: This will delete all symlinks and restore files from $DOTFILES_DIR to their original locations.${NC}"
echo -e "${YELLOW}The files are MOVED out of the repo, so the repo is left essentially empty.${NC}"
read -p "Are you sure you want to continue? (y/N): " response
case "$response" in
  [Yy]*) restore ;;
  *)     echo "Aborted."; exit 0 ;;
esac

# Exit non-zero when anything failed to move, so a caller can tell a clean run
# from one that left files in the repo.
if [ "$FAILURES" -gt 0 ]; then
  echo -e "${RED}[ERROR]${NC} $FAILURES entr$([ "$FAILURES" -eq 1 ] && echo y || echo ies) could not be moved and are still in $DOTFILES_DIR" >&2
  exit 1
fi
exit 0
