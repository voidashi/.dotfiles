#!/bin/bash
# Linux Dotfiles Manager
# Purpose: Backup, version-control, and sync config files across machines.
# Usage: ./backup-configs.sh [init|add|install|uninstall|check|backups|restore] [--dry-run] [--force]

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

# Colors. Blanked when stdout is not a terminal, so a redirected run does not
# fill a file with escape sequences. This script has no --no-color flag and does
# not need one now.
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
[ -t 1 ] || { RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''; }

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
    # An unrecognised level used to print an untagged line with no prefix at
    # all, silently. install-packages.sh's log has always had this arm.
    *) color="$NC"; prefix="[$level]" ;;
  esac

  # Problems go to stderr, so `check 2>&1 >/dev/null` shows only what is wrong
  # and a redirected run is not silent about failing. Nothing in this script
  # wrote to fd 2 before, while scripts/wm/ in the same repo does.
  case "$level" in
    ERROR|WARNING) echo -e "${color}${prefix}${NC} $*" >&2 ;;
    *)             echo -e "${color}${prefix}${NC} $*" ;;
  esac
}

resolve_path() {
  local path="$1"
  echo "${path/#\~/$HOME}"
}

# The repo mirrors $HOME by construction, so a managed path maps to its place
# in the repo by stripping the $HOME prefix. That strip was written inline in
# four places and validated in none, and an entry that is not below $HOME
# strips to nothing: a stray "~/" line in config_files.conf made $dest the repo
# root, left [ -d "$target" ] true, and reached rm -rf "$HOME/".
#
# Returns the relative path on stdout, or 1 with nothing printed. It must not
# log its own failure, because callers read it through a command substitution
# and log() writes to stdout, so an error message would be captured and used as
# a path. The caller reports it instead.
repo_relative() {
  local path="${1%/}"
  case "$path" in
    "$HOME"/?*) printf '%s\n' "${path#"$HOME"/}" ;;
    *) return 1 ;;
  esac
}

load_dotfiles() {
  grep -vE '^\s*(#|$)' "$CONFIG_FILE"
}

# load_dotfiles() used to raise this itself. It is always called as
# `< <(load_dotfiles)`, so its exit 1 killed only the process-substitution
# subshell, and its error text went to the same stdout the loop was reading:
# the message came back as a bogus filename, every command processed it as a
# path, and the script exited 0. Check once, in main, before anything runs.
require_entries() {
  if [ -z "$(load_dotfiles)" ]; then
    log "ERROR" "No valid entries in $CONFIG_FILE"
    exit 1
  fi
}

init_dotfiles() {
  if [ -d "$DOTFILES_DIR" ]; then
    log "INFO" "Repo already exists: $DOTFILES_DIR"
    return 0
  fi
  # --dry-run reached neither of these, so `init --dry-run` created the
  # directory and ran git init for real.
  if $DRY_RUN; then
    log "INFO" "Simulate: create and git init $DOTFILES_DIR"
    return 0
  fi
  mkdir -p "$DOTFILES_DIR"
  git init -q "$DOTFILES_DIR"
  log "SUCCESS" "Initialized repo: $DOTFILES_DIR"
}

backup_file() {
  local target="$1"
  local rel
  if ! rel="$(repo_relative "$target")"; then
    log "ERROR" "Not below \$HOME, refusing to back up: $target"
    return 1
  fi
  local backup_path="$CURRENT_BACKUP/$rel"

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
  local target
  target="$(resolve_path "$1")"
  local rel
  if ! rel="$(repo_relative "$target")"; then
    log "ERROR" "Not below \$HOME, refusing to add: $1"
    return 1
  fi
  local dest="$DOTFILES_DIR/$rel"

  # Validate source
  [ -e "$target" ] || { log "ERROR" "Source not found: $target"; return 1; }

  # Skip if already linked
  [ -L "$target" ] && [ "$(readlink "$target")" = "$dest" ] && {
    log "INFO" "Already linked: $target"; return 0
  }

  # A symlink pointing somewhere other than the repo is a trap. rsync -a copies
  # it as a link, so the backup holds a dangling link and no data, while
  # --remove-source-files reads through it and empties whatever it points at,
  # which is a path nobody listed in the config.
  if [ -L "$target" ]; then
    log "ERROR" "Refusing to add a symlink: $target → $(readlink "$target")"
    return 1
  fi

  # Backup existing file/dir. A failed backup means the only copy is still the
  # one at $target, so moving it into the repo is the one thing not to do next.
  if [ -e "$target" ] && ! $DRY_RUN; then
    if ! backup_file "$target"; then
      log "ERROR" "Backup failed, refusing to move $target"
      return 1
    fi
  fi

  # Dry run simulation
  if $DRY_RUN; then
    log "INFO" "Simulate: move $target → $dest and symlink"
    return 0
  fi

  # Move to repo and symlink. Every step below is checked before the next one
  # runs: an unchecked rsync followed by rm -rf, and an unchecked mv followed
  # by ln -sf, each deleted the only copy of a file when the first step failed
  # and then reported SUCCESS.
  mkdir -p "$(dirname "$dest")"
  if [ -d "$target" ]; then
    # For directories: Ensure rsync copies CONTENTS, not the directory itself
    mkdir -p "$dest"  # Explicitly create destination directory
    if ! rsync -a --remove-source-files "$target/" "$dest/"; then  # Trailing slashes are critical
      log "ERROR" "Copy into the repo failed, leaving $target untouched"
      return 1
    fi
    rm -rf "$target"
  else
    if ! mv "$target" "$dest"; then
      log "ERROR" "Move into the repo failed, leaving $target untouched"
      return 1
    fi
  fi

  if ln -sf "$dest" "$target"; then
    log "SUCCESS" "Added: $target → $dest"
  else
    log "ERROR" "Moved into the repo but could not link it back: $target. The content is at $dest"
    return 1
  fi
}

install_dotfiles() {
  local linked=0 unchanged=0 skipped=0 failed=0

  while IFS= read -r file; do
    local target
    target="$(resolve_path "$file")"
    local rel
    if ! rel="$(repo_relative "$target")"; then
      log "ERROR" "Not below \$HOME, skipping: $file"
      failed=$((failed + 1))
      continue
    fi
    local dest="$DOTFILES_DIR/$rel"
    [ -e "$dest" ] || { log "ERROR" "Not in repo: $dest"; failed=$((failed + 1)); continue; }

    # add_dotfile has always made this distinction and install never did, so a
    # second run announced thirty-one links it had not created. Reporting work
    # that did not happen is how a reader learns to stop reading the output.
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$dest" ]; then
      log "INFO" "Unchanged: $target"
      unchanged=$((unchanged + 1))
      continue
    fi

    if [ -e "$target" ] && ! [ -L "$target" ]; then
      if $FORCE; then
        # Both of these destroy the original, so a simulation must not reach
        # them. Before this guard, `install --dry-run --force` ran the rm for
        # real while backup_file skipped its rsync: the file was removed, no
        # backup was written, and the log claimed both had happened.
        if $DRY_RUN; then
          log "INFO" "Simulate: back up and replace $target"
        else
          # backup_file returns 1 when the copy failed, and that return was
          # ignored, so the rm ran against a backup that did not exist and the
          # content survived nowhere. Same shape as the dry-run bug above:
          # acting on the result of a step nobody checked.
          if ! backup_file "$target"; then
            log "ERROR" "Backup failed, refusing to replace $target"
            failed=$((failed + 1))
            continue
          fi
          rm -rf "$target"
        fi
      else
        log "WARNING" "Skipping existing file: $target (use --force to overwrite)"
        skipped=$((skipped + 1))
        continue
      fi
    fi

    # The -n flag treats a symlink to a directory as a normal file,
    # replacing it instead of creating a link inside it.
    if $DRY_RUN; then
      # "Simulate:", never "Linked:". This said SUCCESS with the same wording as
      # the real branch below, so a dry run's output was indistinguishable from
      # a run that had changed the machine.
      log "INFO" "Simulate: link $target"
    else
      # Create the parent first: an entry can live under a directory that does
      # not exist yet, such as ~/.local/share/color-schemes on a machine that
      # has never had a KDE colour scheme installed. And report what actually
      # happened, since announcing success unconditionally is what hid that failure.
      mkdir -p "$(dirname "$target")"
      if ln -snf "$dest" "$target"; then
        log "SUCCESS" "Linked: $target"
        linked=$((linked + 1))
      else
        log "ERROR" "Failed to link: $dest → $target"
        failed=$((failed + 1))
      fi
    fi
  done < <(load_dotfiles)

  if $DRY_RUN; then
    log "INFO" "Simulated. Nothing above was carried out."
  else
    log "INFO" "Linked: $linked. Unchanged: $unchanged. Skipped: $skipped. Failed: $failed."
  fi
  [ "$failed" -eq 0 ]
}

# The loop lived in main while install_dotfiles owned an identical one, which is
# why add never gained the summary or the exit code that install has.
add_dotfiles() {
  local added=0 failed=0
  while IFS= read -r file; do
    if add_dotfile "$file"; then
      added=$((added + 1))
    else
      failed=$((failed + 1))
    fi
  done < <(load_dotfiles)
  log "INFO" "Added: $added. Failed: $failed."
  [ "$failed" -eq 0 ]
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

# The inverse of install, and until now nothing was. install creates symlinks
# into the repo; this removes exactly those and nothing else. It never touches
# the repo, and never touches a real file that install skipped, so running it
# on a machine that was never installed onto changes nothing.
#
# unlink-dotfiles.sh is not this. That one moves the repo's files out into
# $HOME and leaves the repo empty, which is the inverse of `add`. Pointing a
# stranger at it to undo an install is how they lose their clone.
uninstall_dotfiles() {
  local removed=0 kept=0 failed=0

  while IFS= read -r file; do
    local target
    target="$(resolve_path "$file")"
    local rel
    if ! rel="$(repo_relative "$target")"; then
      log "ERROR" "Not below \$HOME, skipping: $file"
      continue
    fi
    local dest="$DOTFILES_DIR/$rel"

    if [ ! -L "$target" ]; then
      # A real file here means install skipped it, or --force replaced it and
      # the original is in the backup directory. Either way it is not ours.
      [ -e "$target" ] && { log "INFO" "Kept, not a link: $target"; kept=$((kept + 1)); }
      continue
    fi

    if [ "$(readlink "$target")" != "$dest" ]; then
      log "WARNING" "Kept, links outside the repo: $target → $(readlink "$target")"
      kept=$((kept + 1))
      continue
    fi

    if $DRY_RUN; then
      log "INFO" "Simulate: remove link $target"
      removed=$((removed + 1))
    elif rm -f "$target"; then
      log "SUCCESS" "Removed link: $target"
      removed=$((removed + 1))
    else
      log "ERROR" "Could not remove link: $target"
      failed=$((failed + 1))
    fi
  done < <(load_dotfiles)

  # fonts/ is linked outside config_files.conf by install_fonts, so it has to
  # be removed here too or uninstall leaves one link behind.
  local fonts_dest="$HOME/.local/share/fonts/dotfiles"
  if [ -L "$fonts_dest" ] && [ "$(readlink "$fonts_dest")" = "$DOTFILES_DIR/fonts" ]; then
    if $DRY_RUN; then
      log "INFO" "Simulate: remove link $fonts_dest"
      removed=$((removed + 1))
    elif rm -f "$fonts_dest"; then
      log "SUCCESS" "Removed link: $fonts_dest"
      removed=$((removed + 1))
    else
      log "ERROR" "Could not remove link: $fonts_dest"
      failed=$((failed + 1))
    fi
  fi

  log "INFO" "Links removed: $removed. Left alone: $kept. Failed: $failed."

  # The originals of anything install --force replaced are here and nothing
  # moves them back automatically, which is the one thing nobody was told.
  if [ -d "$BACKUP_DIR" ] && [ -n "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    log "INFO" "Files replaced by --force are still in $BACKUP_DIR. List them with: $0 backups"
  fi

  [ "$failed" -eq 0 ]
}

# One entry, five outcomes. This used to be `[ -L ] && [ readlink = dest ] &&
# log SUCCESS || log ERROR`, which is two outcomes: it compared the link text
# and never asked whether the link resolves, so a link into a repo copy that had
# been deleted was reported Valid. It also called a fresh clone, where nothing
# is linked yet because nobody has run install, a wall of thirty-two errors.
#
# Prints one line and returns: 0 valid, 1 broken, 2 not installed yet.
check_one() {
  local target="$1" dest="$2"

  if [ -L "$target" ]; then
    local actual; actual="$(readlink "$target")"
    if [ "$actual" != "$dest" ]; then
      log "ERROR" "Wrong target: $target → $actual"
      return 1
    fi
    # -e follows the link, so this is a link into the repo whose repo copy is
    # gone. Exactly the case the old text comparison called Valid.
    if [ ! -e "$target" ]; then
      log "ERROR" "Dangling: $target → $dest (nothing there)"
      return 1
    fi
    log "SUCCESS" "Valid: $target"
    return 0
  fi

  if [ -e "$target" ]; then
    log "WARNING" "Not linked: $target (a real file is there; install --force replaces it)"
    return 2
  fi

  log "WARNING" "Missing: $target (nothing there; run install)"
  return 2
}

check_dotfiles() {
  local valid=0 broken=0 pending=0 rc

  while IFS= read -r file; do
    local target
    target="$(resolve_path "$file")"
    local rel
    if ! rel="$(repo_relative "$target")"; then
      log "ERROR" "Not below \$HOME, skipping: $file"
      broken=$((broken + 1))
      continue
    fi
    check_one "$target" "$DOTFILES_DIR/$rel"; rc=$?
    case $rc in
      0) valid=$((valid + 1)) ;;
      1) broken=$((broken + 1)) ;;
      *) pending=$((pending + 1)) ;;
    esac
  done < <(load_dotfiles)

  check_one "$HOME/.local/share/fonts/dotfiles" "$DOTFILES_DIR/fonts"; rc=$?
  case $rc in
    0) valid=$((valid + 1)) ;;
    1) broken=$((broken + 1)) ;;
    *) pending=$((pending + 1)) ;;
  esac

  log "INFO" "Valid: $valid. Broken: $broken. Not installed: $pending."

  # Non-zero whenever the tree is not fully installed, so this can be used as a
  # gate. install-packages.sh check has always done this; its sibling always
  # exited 0, which made the symlink audit useless to any automated caller.
  [ "$broken" -eq 0 ] && [ "$pending" -eq 0 ]
}

# restore TIMESTAMP takes an argument the tool gave you no way to obtain.
list_backups() {
  if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    log "INFO" "No backups in $BACKUP_DIR"
    return 0
  fi
  log "INFO" "Backups in $BACKUP_DIR:"
  local dir
  for dir in "$BACKUP_DIR"/*/; do
    [ -d "$dir" ] || continue
    local name n
    name="$(basename "$dir")"
    n="$(find "$dir" -type f | wc -l)"
    printf '  %s  (%s file%s)\n' "$name" "$n" "$([ "$n" -eq 1 ] || echo s)"
  done
}

restore_backup() {
  local timestamp="${1:-}"

  # With $1 empty, $backup was "$BACKUP_DIR/", which is a directory, so the
  # guard below passed and rsync emptied every timestamped directory into $HOME.
  if [ -z "$timestamp" ]; then
    log "ERROR" "restore needs a timestamp. List them with: $0 backups"
    exit 1
  fi

  local backup="$BACKUP_DIR/$timestamp"
  [ -d "$backup" ] || { log "ERROR" "Backup not found: $backup"; exit 1; }

  local total; total="$(find "$backup" -type f | wc -l)"

  if $DRY_RUN; then
    log "INFO" "Simulate: restore $total file(s) from $timestamp into \$HOME"
    rsync -a --ignore-existing --dry-run --out-format='  would restore: %n' "$backup/" "$HOME/" \
      | grep -v '/$'
    return 0
  fi

  local moved
  moved="$(rsync -a --ignore-existing --out-format='%n' "$backup/" "$HOME/" | grep -cv '/$')"

  if [ "$moved" -eq 0 ]; then
    # --ignore-existing never overwrites, and after an install every managed
    # path exists as a symlink, so restore skips all of them and used to report
    # SUCCESS for having done nothing. It is the undo for add, not for install.
    log "WARNING" "Restored nothing: all $total file(s) already exist in \$HOME."
    log "INFO" "--ignore-existing never overwrites, and after an install the symlink counts as existing. Run '$0 uninstall' first."
    return 1
  fi

  log "SUCCESS" "Restored $moved of $total file(s) from $timestamp"
}

# ---- Main ----
main() {
  # Preflight checks
  command -v git >/dev/null || { log "ERROR" "Git not installed"; exit 1; }
  [ -f "$CONFIG_FILE" ] || { log "ERROR" "Config file missing: $CONFIG_FILE"; exit 1; }

  case "$1" in
    "init") init_dotfiles ;;
    "add")
      require_entries
      add_dotfiles
      ;;
    "install")
      require_entries
      local rc=0
      install_dotfiles || rc=1
      install_fonts || rc=1
      return $rc
      ;;
    "check") require_entries; check_dotfiles ;;
    "uninstall") require_entries; uninstall_dotfiles ;;
    "backups") list_backups ;;
    "restore") restore_backup "$2" ;;
    *)
      echo -e "Usage: $0 COMMAND [--dry-run] [--force]"
      echo -e "Commands:"
      echo -e "  init       Initialize dotfiles repo"
      echo -e "  add        Move files to repo and symlink"
      echo -e "  install    Symlink files from repo"
      echo -e "  uninstall  Remove the symlinks install created, leaving the repo alone"
      echo -e "  check      Validate symlinks"
      echo -e "  backups    List the backups taken by --force"
      echo -e "  restore TIMESTAMP  Restore from backup (list them with: $0 backups)"
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

# Restore the positional arguments (for example "install", "restore 2023...")
set -- "${POSITIONAL_ARGS[@]}"

main "$@"
exit $?