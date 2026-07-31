#!/bin/bash
# Sandboxed behaviour tests for the two scripts that can damage a real $HOME.
#
# Why this exists: MAINTENANCE.md tells you to prove a destructive guard with a
# throwaway HOME=, and that instruction was prose. Three defects in the dry-run
# paths of backup-configs.sh shipped anyway, and each was found by hand-building
# the same sandbox from memory. This is that sandbox, written down.
#
# Every case runs in its own mktemp -d with HOME, DOTFILES_DIR, BACKUP_DIR and
# CONFIG_FILE pointed inside it. Nothing here may touch the real home directory,
# and guard_sandbox() aborts the whole run if it ever could.
#
# Usage: ./scripts/tests/test-dotfiles.sh [name-fragment]
#        A fragment runs only the cases whose name contains it.
# Exit:  0 if every case passed, 1 if any failed, 99 on a sandbox safety abort.

# The tilde in every track '~/...' call must stay literal: it is written into
# the config file, and '~/' is the format config_files.conf uses. Expanding it
# would test a path format the scripts never see.
# shellcheck disable=SC2088

set -u

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$(cd "$TESTS_DIR/.." && pwd)"
BACKUP_SCRIPT="$SCRIPTS_DIR/backup-configs.sh"
UNLINK_SCRIPT="$SCRIPTS_DIR/unlink-dotfiles.sh"

REAL_HOME="$HOME"
SANDBOX_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-tests.XXXXXX")"
FILTER="${1:-}"

PASSED=0
FAILED=0
FAILED_NAMES=()

if [ -t 1 ]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; NC=''
fi

cleanup() { chmod -R u+rwX "$SANDBOX_ROOT" 2>/dev/null; rm -rf "$SANDBOX_ROOT"; }
trap cleanup EXIT

# ---- Sandbox ----

# The only thing in this file that must never be wrong. Every invocation of a
# script under test goes through run_backup/run_unlink, and both call this first.
guard_sandbox() {
  case "$HOME" in
    "$SANDBOX_ROOT"/*) ;;
    *) echo "FATAL: HOME is '$HOME', outside the sandbox root. Refusing to run." >&2; exit 99 ;;
  esac
  if [ "$HOME" = "$REAL_HOME" ]; then
    echo "FATAL: HOME still points at the real home directory. Refusing to run." >&2
    exit 99
  fi
  for var in DOTFILES_DIR BACKUP_DIR CONFIG_FILE; do
    case "${!var}" in
      "$SANDBOX_ROOT"/*) ;;
      *) echo "FATAL: $var is '${!var}', outside the sandbox root. Refusing to run." >&2; exit 99 ;;
    esac
  done
}

# Builds a fresh tree and exports the four variables the scripts honour.
# Sets CASE_BOX rather than echoing it: a command substitution would run this
# in a subshell and every export would be lost with it.
new_sandbox() {
  CASE_BOX="$(mktemp -d "$SANDBOX_ROOT/case.XXXXXX")"
  export HOME="$CASE_BOX/home"
  export DOTFILES_DIR="$CASE_BOX/home/.dotfiles"
  export BACKUP_DIR="$CASE_BOX/backups"
  export CONFIG_FILE="$CASE_BOX/config_files.conf"
  mkdir -p "$HOME" "$DOTFILES_DIR"
  : > "$CONFIG_FILE"
}

track() { printf '%s\n' "$1" >> "$CONFIG_FILE"; }

# A file in the repo, so install has something to link.
repo_file() { mkdir -p "$(dirname "$DOTFILES_DIR/$1")"; printf '%s\n' "${2:-repo version}" > "$DOTFILES_DIR/$1"; }

# A real file in $HOME, the thing every guard exists to protect.
home_file() { mkdir -p "$(dirname "$HOME/$1")"; printf '%s\n' "${2:-PRECIOUS USER DATA}" > "$HOME/$1"; }

run_backup() { guard_sandbox; bash "$BACKUP_SCRIPT" "$@" >"$LAST_OUT" 2>&1; LAST_RC=$?; return 0; }
# unlink-dotfiles.sh takes no arguments today and reads its confirmation from
# stdin, so the 'y' is fed in rather than passed.
run_unlink() { guard_sandbox; printf 'y\n' | bash "$UNLINK_SCRIPT" >"$LAST_OUT" 2>&1; LAST_RC=$?; return 0; }

# ---- Assertions ----

# Type, path, link target, size and content hash of everything under a root.
# Used to prove a simulation changed nothing at all.
snapshot() {
  local root="$1"
  [ -d "$root" ] || { echo "(missing)"; return 0; }
  ( cd "$root" || return 0
    find . -mindepth 1 -printf '%y|%p|%l\n' 2>/dev/null | LC_ALL=C sort
    find . -type f -print0 2>/dev/null | LC_ALL=C sort -z | xargs -0 -r md5sum 2>/dev/null
  )
}

fail() { FAIL_REASON="$1"; return 1; }

assert_content() {
  local path="$1" want="$2"
  [ -e "$path" ] || { fail "expected '$path' to exist, it does not"; return 1; }
  local got; got="$(cat "$path" 2>/dev/null)"
  [ "$got" = "$want" ] || { fail "content of '$path' is '$got', expected '$want'"; return 1; }
}

assert_symlink_to() {
  local path="$1" want="$2"
  [ -L "$path" ] || { fail "expected '$path' to be a symlink, it is not"; return 1; }
  local got; got="$(readlink "$path")"
  [ "$got" = "$want" ] || { fail "'$path' points at '$got', expected '$want'"; return 1; }
}

assert_not_symlink() {
  [ ! -L "$1" ] || { fail "'$1' is a symlink and should not be"; return 1; }
}

assert_exists() { [ -e "$1" ] || { fail "expected '$1' to exist"; return 1; }; }

assert_rc_nonzero() {
  [ "$LAST_RC" -ne 0 ] || { fail "expected a non-zero exit code, got 0"; return 1; }
}

assert_unchanged() {
  local before="$1" after="$2" what="$3"
  [ "$before" = "$after" ] || {
    fail "$what changed during what should have been a simulation:
$(diff <(printf '%s\n' "$before") <(printf '%s\n' "$after") | head -20)"
    return 1
  }
}

# ---- Runner ----

run_case() {
  local name="$1"
  if [ -n "$FILTER" ] && [[ "$name" != *"$FILTER"* ]]; then return 0; fi

  FAIL_REASON=""
  LAST_RC=0
  LAST_OUT="$SANDBOX_ROOT/last-output.txt"
  : > "$LAST_OUT"

  new_sandbox
  if "case_$name"; then
    PASSED=$((PASSED + 1))
    printf '%sPASS%s  %s\n' "$GREEN" "$NC" "$name"
  else
    FAILED=$((FAILED + 1))
    FAILED_NAMES+=("$name")
    printf '%sFAIL%s  %s\n' "$RED" "$NC" "$name"
    printf '        %s\n' "$FAIL_REASON"
    if [ -s "$LAST_OUT" ]; then
      printf '        --- script output ---\n'
      sed 's/^/        /' "$LAST_OUT"
    fi
  fi
  chmod -R u+rwX "$CASE_BOX" 2>/dev/null
}

# =====================================================================
# Group A: a simulation must change nothing
# =====================================================================

case_dryrun_install_changes_nothing() {
  track '~/.config/probe.conf'
  repo_file ".config/probe.conf"
  home_file ".config/probe.conf"
  local before; before="$(snapshot "$HOME")$(snapshot "$BACKUP_DIR")"
  run_backup install --dry-run
  local after; after="$(snapshot "$HOME")$(snapshot "$BACKUP_DIR")"
  assert_unchanged "$before" "$after" "the home tree"
}

case_dryrun_force_changes_nothing() {
  track '~/.config/probe.conf'
  repo_file ".config/probe.conf"
  home_file ".config/probe.conf"
  local before; before="$(snapshot "$HOME")$(snapshot "$BACKUP_DIR")"
  run_backup install --dry-run --force
  local after; after="$(snapshot "$HOME")$(snapshot "$BACKUP_DIR")"
  assert_unchanged "$before" "$after" "the home tree" || return 1
  assert_content "$HOME/.config/probe.conf" "PRECIOUS USER DATA"
}

case_dryrun_add_changes_nothing() {
  track '~/.config/probe.conf'
  home_file ".config/probe.conf"
  local before; before="$(snapshot "$HOME")$(snapshot "$BACKUP_DIR")"
  run_backup add --dry-run
  local after; after="$(snapshot "$HOME")$(snapshot "$BACKUP_DIR")"
  assert_unchanged "$before" "$after" "the home tree"
}

# =====================================================================
# Group B: a real run must do exactly what it announced
# =====================================================================

case_install_links_when_target_is_free() {
  track '~/.config/probe.conf'
  repo_file ".config/probe.conf"
  run_backup install
  assert_symlink_to "$HOME/.config/probe.conf" "$DOTFILES_DIR/.config/probe.conf"
}

case_install_skips_real_file_without_force() {
  track '~/.config/probe.conf'
  repo_file ".config/probe.conf"
  home_file ".config/probe.conf"
  run_backup install
  assert_not_symlink "$HOME/.config/probe.conf" || return 1
  assert_content "$HOME/.config/probe.conf" "PRECIOUS USER DATA"
}

case_install_force_backs_up_then_links() {
  track '~/.config/probe.conf'
  repo_file ".config/probe.conf"
  home_file ".config/probe.conf"
  run_backup install --force
  assert_symlink_to "$HOME/.config/probe.conf" "$DOTFILES_DIR/.config/probe.conf" || return 1
  local n; n="$(find "$BACKUP_DIR" -type f 2>/dev/null | wc -l)"
  [ "$n" -eq 1 ] || { fail "expected exactly 1 backup file, found $n"; return 1; }
  assert_content "$(find "$BACKUP_DIR" -type f | head -1)" "PRECIOUS USER DATA"
}

# =====================================================================
# Group C: the destructive paths. A failed step must not destroy the source.
# =====================================================================

# Defects 1 and 2: rsync/mv failure is followed by rm -rf / ln -sf regardless.
case_add_keeps_file_when_repo_is_unwritable() {
  track '~/.bashrc'
  home_file ".bashrc" "PRECIOUS USER DATA"
  chmod 500 "$DOTFILES_DIR"
  run_backup add
  chmod 700 "$DOTFILES_DIR"
  assert_exists "$HOME/.bashrc" || return 1
  assert_not_symlink "$HOME/.bashrc" || return 1
  assert_content "$HOME/.bashrc" "PRECIOUS USER DATA"
}

case_add_keeps_directory_when_repo_is_unwritable() {
  track '~/.config/nvim'
  mkdir -p "$HOME/.config/nvim"
  printf 'MY CONFIG\n' > "$HOME/.config/nvim/init.lua"
  chmod 500 "$DOTFILES_DIR"
  run_backup add
  chmod 700 "$DOTFILES_DIR"
  assert_content "$HOME/.config/nvim/init.lua" "MY CONFIG"
}

# Defect 3: install --force deletes the target without checking the backup landed.
case_force_keeps_file_when_backup_fails() {
  track '~/.config/probe.conf'
  repo_file ".config/probe.conf"
  home_file ".config/probe.conf"
  # A regular file where the backup root must be a directory, so every write
  # underneath it fails. This is a stale ~/.dotfiles_backup left by anything.
  rm -rf "$BACKUP_DIR"; : > "$BACKUP_DIR"
  run_backup install --force
  assert_exists "$HOME/.config/probe.conf" || return 1
  assert_content "$HOME/.config/probe.conf" "PRECIOUS USER DATA"
}

# Defect 5: a config entry that is not below $HOME reaches rm -rf "$HOME/".
case_add_rejects_entry_that_is_not_below_home() {
  track '~/'
  home_file "Documents/thesis.txt" "YEARS OF WORK"
  run_backup add
  assert_exists "$HOME/Documents/thesis.txt" || return 1
  assert_content "$HOME/Documents/thesis.txt" "YEARS OF WORK"
}

# Defect 4: unlink overwrites a real file that was never linked, with no backup.
case_unlink_does_not_overwrite_an_unlinked_real_file() {
  track '~/.bashrc'
  repo_file ".bashrc" "repo version"
  home_file ".bashrc" "LOCAL ONLY, NEVER LINKED"
  run_unlink
  assert_content "$HOME/.bashrc" "LOCAL ONLY, NEVER LINKED"
}

# Defect 16: mv of a directory onto an existing directory nests it one level deep.
case_unlink_does_not_nest_a_directory_inside_itself() {
  track '~/.config/hypr'
  mkdir -p "$DOTFILES_DIR/.config/hypr" "$HOME/.config/hypr"
  printf 'from repo\n' > "$DOTFILES_DIR/.config/hypr/hyprland.conf"
  printf 'mine\n'      > "$HOME/.config/hypr/local.conf"
  run_unlink
  [ ! -e "$HOME/.config/hypr/hypr" ] || { fail "the repo directory was nested at ~/.config/hypr/hypr"; return 1; }
}

# =====================================================================
# Group D: reporting. An audit that cannot fail is not an audit.
# =====================================================================

# Defect 10: check exits 0 even when every entry is broken.
case_check_exits_nonzero_on_a_broken_tree() {
  track '~/.config/probe.conf'
  repo_file ".config/probe.conf"
  run_backup check
  assert_rc_nonzero
}

# Defect 9: check compares the link text only, so a dangling link reads as Valid.
case_check_reports_a_dangling_symlink_as_broken() {
  track '~/.config/probe.conf'
  repo_file ".config/probe.conf"
  run_backup install
  rm -f "$DOTFILES_DIR/.config/probe.conf"   # the link now resolves to nothing
  run_backup check
  if grep -q "Valid:" "$LAST_OUT"; then
    fail "check called a dangling symlink Valid"
    return 1
  fi
  assert_rc_nonzero
}

# Defect 7: restore with no timestamp passes its own guard and empties the
# backup root into $HOME.
case_restore_without_a_timestamp_fails() {
  mkdir -p "$BACKUP_DIR/20240101_010101"
  printf 'old\n' > "$BACKUP_DIR/20240101_010101/marker"
  run_backup restore
  [ ! -e "$HOME/20240101_010101" ] || { fail "restore copied a whole timestamp directory into \$HOME"; return 1; }
  assert_rc_nonzero
}

# Defect 8: an empty config makes exit 1 kill only the subshell, and the error
# text is read back as if it were a tracked path.
case_empty_config_is_reported_and_does_not_become_a_path() {
  printf '# only a comment\n' > "$CONFIG_FILE"
  run_backup install
  if grep -q "Not in repo:.*ERROR" "$LAST_OUT"; then
    fail "the error message was consumed as a config entry"
    return 1
  fi
  assert_rc_nonzero
}

# =====================================================================

main() {
  printf 'Sandbox root: %s\n' "$SANDBOX_ROOT"
  printf 'Under test:   %s\n' "$BACKUP_SCRIPT"
  printf '              %s\n\n' "$UNLINK_SCRIPT"

  run_case dryrun_install_changes_nothing
  run_case dryrun_force_changes_nothing
  run_case dryrun_add_changes_nothing

  run_case install_links_when_target_is_free
  run_case install_skips_real_file_without_force
  run_case install_force_backs_up_then_links

  run_case add_keeps_file_when_repo_is_unwritable
  run_case add_keeps_directory_when_repo_is_unwritable
  run_case force_keeps_file_when_backup_fails
  run_case add_rejects_entry_that_is_not_below_home
  run_case unlink_does_not_overwrite_an_unlinked_real_file
  run_case unlink_does_not_nest_a_directory_inside_itself

  run_case check_exits_nonzero_on_a_broken_tree
  run_case check_reports_a_dangling_symlink_as_broken
  run_case restore_without_a_timestamp_fails
  run_case empty_config_is_reported_and_does_not_become_a_path

  printf '\n%s\n' "----------------------------------------"
  if [ "$FAILED" -eq 0 ]; then
    printf '%spassed: %d, failed: 0%s\n' "$GREEN" "$PASSED" "$NC"
    return 0
  fi
  printf '%spassed: %d, failed: %d%s\n' "$YELLOW" "$PASSED" "$FAILED" "$NC"
  printf 'failing: %s\n' "${FAILED_NAMES[*]}"
  return 1
}

main
