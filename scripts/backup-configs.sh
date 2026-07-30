#!/bin/bash
# Linux Dotfiles Manager
# Purpose: Backup, version-control, and sync config files across machines.
# Usage: ./backup-configs.sh [init|add|install|check|restore] [--dry-run] [--force]

# ---- Configuration ----
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
# Resolved from the script's own location, not the current directory, so it
# works both from inside scripts/ and from the repo root, which is exactly how
# the README tells you to run it.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/config_files.conf}"
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

  # This was one line: `$DRY_RUN || rsync ... && log "Backup: ..."`, which parses
  # as `(A || B) && C`. Under --dry-run the rsync was skipped and the log ran
  # anyway, so the script announced a backup that did not exist. Report what
  # actually happened, and create no directories during a simulation.
  if $DRY_RUN; then
    log "INFO" "Simulate: backup $target → $backup_path"
    return 0
  fi

  mkdir -p "$(dirname "$backup_path")"
  if rsync -a "$target" "$backup_path"; then
    log "INFO" "Backup: $target → $backup_path"
  else
    log "ERROR" "Backup failed: $target"
    return 1
  fi
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
        # Both of these destroy the original, so a simulation must not reach
        # them. Before this guard, `install --dry-run --force` ran the rm for
        # real while backup_file skipped its rsync: the file was removed, no
        # backup was written, and the log claimed both had happened.
        if $DRY_RUN; then
          log "INFO" "Simulate: back up and replace $target"
        else
          backup_file "$target"
          rm -rf "$target"
        fi
      else
        log "WARNING" "Skipping existing file: $target (use --force to overwrite)"
        continue
      fi
    fi

    # The -n flag treats a symlink to a directory as a normal file,
    # replacing it instead of creating a link inside it.
    if $DRY_RUN; then
      # "Simulate:", never "Linked:". This said SUCCESS with the same wording as
      # the real branch below, so a dry run's output was indistinguishable from
      # a run that had changed the machine.
      log "INFO" "Simulate: link $dest → $target"
    else
      # Create the parent first: an entry can live under a directory that does
      # not exist yet, such as ~/.local/share/color-schemes on a machine that
      # has never had a KDE colour scheme installed. And report what actually
      # happened, since announcing success unconditionally is what hid that failure.
      mkdir -p "$(dirname "$target")"
      if ln -snf "$dest" "$target"; then
        log "SUCCESS" "Linked: $dest → $target"
      else
        log "ERROR" "Failed to link: $dest → $target"
      fi
    fi
  done < <(load_dotfiles)
}

# fonts/ lives at the repo root, not mirrored under a $HOME-relative path like
# config_files.conf entries, so it can't go through install_dotfiles(); it
# gets its own symlink into the XDG font directory instead.
install_fonts() {
  local fonts_src="$DOTFILES_DIR/fonts"
  local fonts_dest="$HOME/.local/share/fonts/dotfiles"
  [ -d "$fonts_src" ] || { log "WARNING" "No fonts/ directory in repo, skipping font install"; return 0; }

  if [ -L "$fonts_dest" ] && [ "$(readlink "$fonts_dest")" = "$fonts_src" ]; then
    log "INFO" "Fonts already linked: $fonts_dest"
  else
    if $DRY_RUN; then
      log "INFO" "Simulate: Link $fonts_src → $fonts_dest"
    else
      mkdir -p "$(dirname "$fonts_dest")"
      ln -snf "$fonts_src" "$fonts_dest"
      log "SUCCESS" "Linked: $fonts_src → $fonts_dest"
    fi
  fi

  if ! $DRY_RUN && command -v fc-cache >/dev/null; then
    fc-cache -f "$fonts_dest" >/dev/null 2>&1
    log "INFO" "Refreshed font cache"
  fi
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
    "install") install_dotfiles; install_fonts ;;
    "check")
      while IFS= read -r file; do
        target="$(resolve_path "$file")"
        [ -L "$target" ] && [ "$(readlink "$target")" = "$DOTFILES_DIR/${target#$HOME/}" ] \
          && log "SUCCESS" "Valid: $target" || log "ERROR" "Broken: $target"
      done < <(load_dotfiles)
      fonts_target="$HOME/.local/share/fonts/dotfiles"
      [ -L "$fonts_target" ] && [ "$(readlink "$fonts_target")" = "$DOTFILES_DIR/fonts" ] \
        && log "SUCCESS" "Valid: $fonts_target" || log "ERROR" "Broken: $fonts_target"
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

# ---- Argument Parsing & Execution ----
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --force) FORCE=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    # Not a flag: store it in the positional argument array and carry on
    *) POSITIONAL_ARGS+=("$1"); shift ;;
  esac
done

# Restaura os argumentos posicionais (ex: "install", "restore 2023...")
set -- "${POSITIONAL_ARGS[@]}"

main "$@"