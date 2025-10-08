#!/bin/bash
# Linux Dotfiles Manager
# Purpose: Backup, version-control, and sync config files across machines.
# Usage: ./backup-configs.sh [init|add|install|check|restore] [--dry-run] [--force]

# ---- Configuration ----
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
#CONFIG_FILE="${CONFIG_FILE:-$HOME/scripts/dotfiles/config_files.conf}"
#CONFIG_FILE="${CONFIG_FILE:-$HOME/.dotfiles/scripts/config_files.conf}"
CONFIG_FILE="config_files.conf"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles_backup}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
CURRENT_BACKUP="$BACKUP_DIR/$TIMESTAMP"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

# Flags
DRY_RUN=false
FORCE=false
VERBOSE=false

# ---- Functions ----
log() {
  local level=$1; shift
  local color=""; local prefix=""
  case "$level" in
    "INFO") color="$BLUE"; prefix="[INFO]" ;;
    "WARNING") color="$YELLOW"; prefix="[WARNING]" ;;
    "ERROR") color="$RED"; prefix="[ERROR]" ;;
    "SUCCESS") color="$GREEN"; prefix="[SUCCESS]" ;;
  esac
  echo -e "${color}${prefix}${NC} $*"
}

resolve_path() {
  local path="$1"
  echo "${path/#\~/$HOME}"
}

load_dotfiles() {
  grep -vE '^\s*(#|$)' "$CONFIG_FILE" || {
    log "ERROR" "No valid entries found in $CONFIG_FILE."
    exit 1
  }
}

init_dotfiles() {
  if [ ! -d "$DOTFILES_DIR" ]; then
    mkdir -p "$DOTFILES_DIR"
    git init -q "$DOTFILES_DIR"
    log "SUCCESS" "Initialized repo: $DOTFILES_DIR"
  else
    log "INFO" "Repo already exists: $DOTFILES_DIR"
  fi
}

backup_file() {
  local target="$1"
  local backup_path="$CURRENT_BACKUP/${target#$HOME/}"
  mkdir -p "$(dirname "$backup_path")"
  $DRY_RUN || rsync -a "$target" "$backup_path" && log "INFO" "Backup: $target → $backup_path"
}

add_dotfile() {
  local target="$(resolve_path "$1")"
  local dest="$DOTFILES_DIR/${target#$HOME/}"

  # Validate source
  [ -e "$target" ] || { log "ERROR" "Source not found: $target"; return 1; }

  # Skip if already linked
  [ -L "$target" ] && [ "$(readlink "$target")" = "$dest" ] && {
    log "INFO" "Already linked: $target"; return 0
  }

  # Backup existing file/dir
  if [ -e "$target" ] && ! $DRY_RUN; then
    backup_file "$target"
  fi

  # Dry run simulation
  if $DRY_RUN; then
    log "INFO" "Simulate: Move $target → $dest and symlink"
    return 0
  fi

  # Move to repo and symlink
  mkdir -p "$(dirname "$dest")"
  if [ -d "$target" ]; then
    # For directories: Ensure rsync copies CONTENTS, not the directory itself
    mkdir -p "$dest"  # Explicitly create destination directory
    rsync -a --remove-source-files "$target/" "$dest/"  # Trailing slashes are critical
    rm -rf "$target"
  else
    mv "$target" "$dest"
  fi
  ln -sf "$dest" "$target"
  log "SUCCESS" "Added: $target → $dest"
}

install_dotfiles() {
  while IFS= read -r file; do
    local target="$(resolve_path "$file")"
    local dest="$DOTFILES_DIR/${target#$HOME/}"
    [ -e "$dest" ] || { log "ERROR" "Not in repo: $dest"; continue; }

    if [ -e "$target" ] && ! [ -L "$target" ]; then
      if $FORCE; then
        backup_file "$target"
        rm -rf "$target"
      else
        log "WARNING" "Skipping existing file: $target (use --force to overwrite)"
        continue
      fi
    fi

    # The -n flag treats a symlink to a directory as a normal file,
    # replacing it instead of creating a link inside it.
    $DRY_RUN || ln -snf "$dest" "$target"
    log "SUCCESS" "Linked: $dest → $target"
  done < <(load_dotfiles)
}

restore_backup() {
  local timestamp="$1"
  local backup="$BACKUP_DIR/$timestamp"
  [ -d "$backup" ] || { log "ERROR" "Backup not found: $backup"; exit 1; }
  rsync -a --ignore-existing "$backup/" "$HOME/"
  log "SUCCESS" "Restored backup: $timestamp"
}

# ---- Main ----
main() {
  # Preflight checks
  command -v git >/dev/null || { log "ERROR" "Git not installed"; exit 1; }
  [ -f "$CONFIG_FILE" ] || { log "ERROR" "Config file missing: $CONFIG_FILE"; exit 1; }

  case "$1" in
    "init") init_dotfiles ;;
    "add")
      while IFS= read -r file; do
        add_dotfile "$file"
      done < <(load_dotfiles)
      ;;
    "install") install_dotfiles ;;
    "check")
      while IFS= read -r file; do
        target="$(resolve_path "$file")"
        [ -L "$target" ] && [ "$(readlink "$target")" = "$DOTFILES_DIR/${target#$HOME/}" ] \
          && log "SUCCESS" "Valid: $target" || log "ERROR" "Broken: $target"
      done < <(load_dotfiles)
      ;;
    "restore") restore_backup "$2" ;;
    *)
      echo -e "Usage: $0 COMMAND [--dry-run] [--force]"
      echo -e "Commands:"
      echo -e "  init       Initialize dotfiles repo"
      echo -e "  add        Move files to repo and symlink"
      echo -e "  install    Symlink files from repo"
      echo -e "  check      Validate symlinks"
      echo -e "  restore TIMESTAMP  Restore from backup"
      echo -e "Flags:"
      echo -e "  --dry-run  Simulate changes"
      echo -e "  --force    Overwrite conflicts"
      exit 1
      ;;
  esac
}

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --force) FORCE=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    *) break ;;
  esac
done

main "$@"