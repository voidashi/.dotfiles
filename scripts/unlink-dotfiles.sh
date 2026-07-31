#!/bin/bash
# Purpose: Revert all symlinks and restore files from the dotfiles repo to their original locations.
# Usage: ./unlink-dotfiles.sh [--dry-run] [--yes]
#        (run from inside scripts/, like the other scripts here)

# Configuration (MUST match your original script's settings)
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_DIR="${DOTFILES_DIR%/}"   # see the find at the end of restore()
# Resolved from the script's own location, same as backup-configs.sh. It used
# to point at ~/scripts/dotfiles/, which was a separate copy and no longer
# exists.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/config_files.conf}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles_backup}"

# Colors, blanked when stdout is not a terminal so a redirected run does not
# fill a file with escape sequences.
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
[ -t 1 ] || { RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''; }

# Resolve paths (e.g., ~/.config to /home/user/.config).
# Parameter expansion, not sed: this interpolated $HOME into a s### expression
# and broke on a home directory containing # or &. It is now the same three
# lines as backup-configs.sh, which is the point of two copies existing.
resolve_path() {
  local path="$1"
  echo "${path/#\~/$HOME}"
}

# Load valid entries from config file
load_dotfiles() {
  grep -vE '^\s*(#|$)' "$CONFIG_FILE" || {
    echo -e "${RED}[ERROR]${NC} No valid entries found in $CONFIG_FILE."
    exit 1
  }
}

FAILURES=0
DRY_RUN=false
ASSUME_YES=false

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

    # Remove symlink if it points to the repo. This used to print its own line,
    # so every entry produced [REMOVED SYMLINK] followed by [RESTORED] for the
    # same path: 62 lines for 31 entries, and the first said nothing the second
    # did not imply.
    if [ -L "$original_path" ] && [ "$(readlink "$original_path")" = "$repo_path" ]; then
      $DRY_RUN || rm -f "$original_path"
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

    if $DRY_RUN; then
      echo -e "${BLUE}[SIMULATE]${NC} would move $repo_path → $original_path"
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
  if $DRY_RUN; then
    local would
    would="$(find "$DOTFILES_DIR" -mindepth 1 -type d -empty -not -path "$DOTFILES_DIR/.git/*" 2>/dev/null | wc -l)"
    echo -e "${BLUE}[SIMULATE]${NC} would prune $would empty director$([ "$would" -eq 1 ] && echo y || echo ies). Nothing above was carried out."
    return 0
  fi

  local pruned
  pruned="$(find "$DOTFILES_DIR" -mindepth 1 -type d -empty -not -path "$DOTFILES_DIR/.git/*" -print -delete 2>/dev/null | wc -l)"
  # This was the script's last act and it was silent, deleting directories out
  # of the user's git repository with its errors discarded.
  echo -e "${YELLOW}[PRUNED]${NC} $pruned empty director$([ "$pruned" -eq 1 ] && echo y || echo ies) removed from $DOTFILES_DIR"
}

usage() {
  echo "Usage: $0 [--dry-run] [--yes]"
  echo "  Moves the tracked files out of $DOTFILES_DIR back into \$HOME."
  echo "  This is the inverse of 'backup-configs.sh add'. To undo an install,"
  echo "  use 'backup-configs.sh uninstall' instead, which leaves the repo intact."
  echo "Flags:"
  echo "  --dry-run  Show what would move, change nothing"
  echo "  --yes      Skip the confirmation prompt"
}

# The confirmation used to run at the top level, so sourcing this file ran it,
# there was no way to skip it for a test, and there was nowhere to hang a flag.
main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=true; shift ;;
      --yes|-y)  ASSUME_YES=true; shift ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown argument: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  if $DRY_RUN; then
    echo -e "${BLUE}Simulating. Nothing will be moved or deleted.${NC}"
  elif ! $ASSUME_YES; then
    echo -e "${YELLOW}WARNING: This will delete all symlinks and restore files from $DOTFILES_DIR to their original locations.${NC}"
    echo -e "${YELLOW}The files are MOVED out of the repo, so the repo is left essentially empty.${NC}"
    echo -e "${YELLOW}Anything install --force replaced is in $BACKUP_DIR and is NOT restored by this.${NC}"
    echo -e "${YELLOW}Run with --dry-run first to see exactly what would move.${NC}"
    read -r -p "Are you sure you want to continue? (y/N): " response
    case "$response" in
      [Yy]*) ;;
      *) echo "Aborted."; exit 0 ;;
    esac
  fi

  restore

  # Exit non-zero when anything failed to move, so a caller can tell a clean run
  # from one that left files in the repo.
  if [ "$FAILURES" -gt 0 ]; then
    echo -e "${RED}[ERROR]${NC} $FAILURES entr$([ "$FAILURES" -eq 1 ] && echo y || echo ies) could not be moved and are still in $DOTFILES_DIR" >&2
    exit 1
  fi
  exit 0
}

main "$@"
