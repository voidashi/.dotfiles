#!/bin/bash
# Unified Package Installer (Optimized)
# Purpose: Reliably install packages across Linux distros with third-party repo support
# Usage: ./install-packages.sh [preview|install|check|repos] [--yes] [--no-color] [--log FILE]

# ---- Configuration ----
# Resolved from the script's own location, not the current directory, so it
# works both from inside scripts/ and from the repo root, which is exactly how
# the README tells you to run it.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/packages.conf}"
LOG_FILE="${LOG_FILE:-$SCRIPT_DIR/package_install.log}"
# Overridable, which it was not: a plain assignment made the "else" branch in
# main unreachable and left MAINTENANCE.md's "unless overridden" untrue. Setting
# it is how you exercise the apt or dnf path from an Arch machine.
DEFAULT_PACKAGE_MANAGER="${DEFAULT_PACKAGE_MANAGER:-auto}"
AUR_HELPER=""
UNATTENDED=false
NO_COLOR=false
UPDATED_DB=false

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; NC='\033[0m'

# ---- Initialization ----
init_logging() {
    # Overwrite log file at the start of each run
    echo -e "--- Package Installer Log $(date) ---\n" > "$LOG_FILE"
}

log() {
    local level="$1" message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    
    # Disable color if NO_COLOR is true
    [ "$NO_COLOR" = true ] && NC=""
    
    case "$level" in
        "INFO") color="$BLUE" ;;
        "WARNING") color="$YELLOW" ;;
        "ERROR") color="$RED" ;;
        "SUCCESS") color="$GREEN" ;;
        *) color="$NC" ;; # Default for SUMMARY etc.
    esac
    
    # Print to console
    echo -e "${color}[$level]${NC} $message"
    # Print to log file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# ---- Core Functions ----
detect_pkg_manager() {
    # A plain list, not an associative array. Bash iterates those in hash order,
    # so the declared apt/pacman/dnf precedence was applied as pacman/apt/dnf,
    # and which manager wins on a machine with two of them was decided by a hash
    # function rather than by this list.
    local manager
    for manager in apt pacman dnf; do
        if [ -x "/usr/bin/$manager" ]; then
            echo "$manager"
            return 0
        fi
    done

    # No logging and no exit here. The caller reads this through a command
    # substitution and log() writes to stdout, so the error text was captured
    # into PKG_MANAGER while the exit 1 killed only the subshell. The run then
    # carried on with the package manager set to its own error message, matched
    # no branch in install_package, and reported all 56 packages installed.
    return 1
}

# One place that answers "is this package present". verify_installed had its own
# copy of this case statement, and install_package had no way to ask at all.
is_installed() {
    local package_name="$1"
    case "$PKG_MANAGER" in
        "apt")    dpkg-query -W -f='${Status}' "$package_name" 2>/dev/null | grep -q "ok installed" ;;
        "pacman") pacman -Q "$package_name" &>/dev/null ;;
        "dnf")    dnf list installed "$package_name" &>/dev/null ;;
        *)        return 1 ;;
    esac
}

detect_aur_helper() {
    # A few packages in packages.conf (catnap, pfetch, pipes.sh) exist only in
    # the AUR. pacman alone will not install them, so a helper is required.
    local helper
    for helper in paru yay pikaur; do
        if command -v "$helper" >/dev/null 2>&1; then
            echo "$helper"
            return
        fi
    done
}

check_sudo() {
    # Only prompt for sudo password if in an interactive session
    if ! sudo -n true 2>/dev/null && ! $UNATTENDED; then
        log "WARNING" "Sudo access is required. Please enter your password if prompted."
        sudo -v || exit 1
    elif ! sudo -n true 2>/dev/null && $UNATTENDED; then
        log "ERROR" "Sudo access is required, but running in unattended mode. Cannot ask for password."
        exit 1
    fi
}

# ---- Repository Management ----
add_repos() {
    case "$PKG_MANAGER" in
        "apt")
            if ! grep -qr "packages.microsoft.com" /etc/apt/sources.list.d/; then
                log "INFO" "Adding Microsoft repository for VSCode"
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null
                echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
            fi
            ;;
        "pacman")
            # No third-party repositories needed by default in this configuration.
            log "INFO" "No extra pacman repositories required."
            ;;
        "dnf")
            if ! rpm -q rpmfusion-free-release &>/dev/null; then
                log "INFO" "Adding RPM Fusion repository"
                sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
            fi
            ;;
    esac
    update_pkg_db
}

update_pkg_db() {
    # Prevent multiple updates in one run
    [ "$UPDATED_DB" = true ] && return
    
    log "INFO" "Updating package database..."
    case "$PKG_MANAGER" in
        "apt") sudo apt-get update -qq ;;
        ### MODIFICATION ###
        # Changed to 'Syy' to force a refresh of databases, which is more
        # robust and helps prevent "could not find database" errors.
        "pacman") sudo pacman -Syy --noconfirm ;;
        "dnf") sudo dnf makecache ;;
    esac && UPDATED_DB=true
}

# ---- Package Operations ----
load_packages() {
    # Use a global associative array to map common names to distro-specific names
    declare -gA PACKAGE_MAP=()
    
    # Read from config file using awk to filter relevant sections
    while IFS='=' read -r key value; do
        # Skip empty lines
        [[ -z "$key" ]] && continue
        # Use the key as the value if no specific value is provided
        PACKAGE_MAP["$key"]="${value:-$key}"
    done < <(
        awk -v pm="$PKG_MANAGER" '
            # Identify the current section. The "next" is required: without it
            # the "[common]" line itself matches the rule below and becomes a
            # "package" named [common], which never exists.
            $0 ~ /^\[.*\]$/ { section = substr($0, 2, length($0)-2); next }
            # Process lines in [common] or the relevant distro section
            (section == pm || section == "common") && $0 !~ /^(#|;|$)/ {
                # Standardize format to key=value and print
                gsub(/[[:space:]]*=[[:space:]]*/, "=")
                print
            }
        ' "$CONFIG_FILE"
    )
}

install_package() {
    local key="$1"
    local package_name="$2"
    local status=0
    log "INFO" "Processing: $key ($package_name)"

    # Asked before the install runs, not instead of it. The install command
    # still runs so an out-of-date package is still upgraded; this only decides
    # what to call the outcome. Every installer here exits 0 when there is
    # nothing to do, so "Installed" was printed for all 56 packages on a second
    # run, and every line the script produced was false.
    local was_present=false
    is_installed "$package_name" && was_present=true

    case "$PKG_MANAGER" in
        "apt") sudo apt-get install -yqq "$package_name" || status=$? ;;
        "pacman")
            # If it is not in the official repos the package is probably from
            # the AUR, so fall back to the helper instead of failing outright.
            if pacman -Si "$package_name" &>/dev/null; then
                sudo pacman -S --noconfirm --needed "$package_name" || status=$?
            elif [ -n "$AUR_HELPER" ]; then
                log "INFO" "$key is not in the official repos, using $AUR_HELPER (AUR)"
                "$AUR_HELPER" -S --noconfirm --needed "$package_name" || status=$?
            else
                log "ERROR" "$key exists only in the AUR and no helper (paru/yay/pikaur) was found"
                status=1
            fi
            ;;
        "dnf") sudo dnf install -y --quiet "$package_name" || status=$? ;;
        *)
            # Without this branch the case matched nothing, status stayed 0, and
            # the package was reported installed. On a distro with none of the
            # three managers that meant a full run of green SUCCESS lines, a
            # "Success: 56, Failed: 0" summary, exit 0, and nothing installed.
            log "ERROR" "Cannot install $key: unsupported package manager '$PKG_MANAGER'"
            status=1
            ;;
    esac

    if [ $status -ne 0 ]; then
        log "ERROR" "Failed to install: $key ($package_name)"
        return 1
    fi

    if $was_present; then
        log "INFO" "Already present: $key"
        return 2
    fi

    log "SUCCESS" "Installed: $key"
    run_hooks "$key" # Use the key for hooks
    return 0
}

run_hooks() {
    local common_name="$1"
    # Use awk to find and execute the hook command for the given common name
    awk -F'=' -v pkg="$common_name" '
        BEGIN { in_hooks = 0 }
        /\[hooks\]/ { in_hooks = 1; next }
        /\[.*\]/ && !/\[hooks\]/ { in_hooks = 0 } # Exit hooks section
        in_hooks && $1 ~ "^[[:space:]]*" pkg "[[:space:]]*$" {
            # Trim whitespace and execute the command
            sub(/^[[:space:]]*/, "", $2);
            sub(/[[:space:]]*$/, "", $2);
            system($2)
        }
    ' "$CONFIG_FILE"
}

# ---- User Commands ----
preview() {
    log "INFO" "Packages to be installed:"
    for key in "${!PACKAGE_MAP[@]}"; do
        # Display: ➔ common-name (distro-package-name)
        echo -e "  ${GREEN}➔${NC} ${key} (${PACKAGE_MAP[$key]})"
    done
    echo -e "\nTotal: ${#PACKAGE_MAP[@]} packages"
}

install_all() {
    check_sudo
    add_repos
    
    local installed=0 present=0 failures=0 rc
    local failed_keys=()
    for key in "${!PACKAGE_MAP[@]}"; do
        # Not "&& ((success++)) || ((failures++))". Post-increment evaluates to
        # the old value, so on the first success the arithmetic result is 0,
        # (( )) exits 1, the || fires, and one phantom failure is counted on
        # every run. That also made the exit 1 below trigger on an install where
        # nothing had failed.
        install_package "$key" "${PACKAGE_MAP[$key]}"; rc=$?
        case $rc in
            0) installed=$((installed + 1)) ;;
            2) present=$((present + 1)) ;;
            *) failures=$((failures + 1)); failed_keys+=("$key") ;;
        esac
    done

    log "SUMMARY" "${#PACKAGE_MAP[@]} configured: $present already present, $installed installed, $failures failed"
    # Naming them matters: "Failed: 3" sends you scrolling back through several
    # hundred lines of package-manager output to find out which three.
    if [ "$failures" -gt 0 ]; then
        log "ERROR" "Failed: ${failed_keys[*]}"
        exit 1
    fi
}

verify_installed() {
    local present=0
    local missing_keys=()
    log "INFO" "Checking ${#PACKAGE_MAP[@]} configured packages against $PKG_MANAGER..."
    for key in "${!PACKAGE_MAP[@]}"; do
        if is_installed "${PACKAGE_MAP[$key]}"; then
            present=$((present + 1))
        else
            missing_keys+=("$key")
        fi
    done

    # This printed one line per package and no summary, so the command whose
    # whole job is to answer "what is missing?" made you read 56 lines to find
    # out. The names go on one line instead.
    if [ "${#missing_keys[@]}" -eq 0 ]; then
        log "SUMMARY" "$present of ${#PACKAGE_MAP[@]} installed, none missing"
        exit 0
    fi
    log "WARNING" "Missing: ${missing_keys[*]}"
    log "SUMMARY" "$present of ${#PACKAGE_MAP[@]} installed, ${#missing_keys[@]} missing"
    exit 1
}

# ---- Execution Flow ----
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --yes) UNATTENDED=true; shift ;;
            --no-color) NO_COLOR=true; shift ;;
            --log)
                # shift 2 with only one argument left shifts nothing and returns
                # 1, so the loop rematched --log forever. parse_args runs before
                # init_logging, so the script hung with no output at all.
                if [ $# -lt 2 ] || [ -z "$2" ]; then
                    echo "install-packages.sh: --log needs a file path" >&2
                    exit 1
                fi
                LOG_FILE="$2"; shift 2 ;;
            -h|--help) # Added help flag
                echo "Usage: $0 [command] [options]"
                echo "Commands: install, preview, check, repos"
                exit 0 ;;
            *)
                # Assume the first non-flag argument is the command
                if [[ -z "$COMMAND" ]]; then
                    COMMAND="$1"
                fi
                shift
                ;;
        esac
    done
}

main() {
    # Ensure the script exits gracefully on interruption
    trap 'log "ERROR" "Script interrupted. Exiting..."; exit 1' SIGINT
    
    parse_args "$@"
    
    # Initialize logging after parsing args in case a custom log file was specified
    init_logging
    
    if [[ "${DEFAULT_PACKAGE_MANAGER:-auto}" == "auto" ]]; then
        if ! PKG_MANAGER=$(detect_pkg_manager); then
            log "ERROR" "No supported package manager found (apt, pacman, dnf)."
            exit 1
        fi
    else
        PKG_MANAGER="$DEFAULT_PACKAGE_MANAGER"
    fi
    
    log "INFO" "Using package manager: $PKG_MANAGER"

    if [ "$PKG_MANAGER" = "pacman" ]; then
        AUR_HELPER="$(detect_aur_helper)"
        if [ -n "$AUR_HELPER" ]; then
            log "INFO" "Using AUR helper: $AUR_HELPER"
        else
            log "WARNING" "No AUR helper (paru/yay/pikaur) found; AUR-only packages will fail."
        fi
    fi

    if ! [ -f "$CONFIG_FILE" ]; then
        log "ERROR" "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    
    load_packages
    
    case "${COMMAND:-install}" in # Default to 'install' if no command is given
        preview) preview ;;
        install) install_all ;;
        repos) check_sudo; add_repos ;;
        check) verify_installed ;;
        *) 
            log "ERROR" "Unknown command: '$COMMAND'"
            echo -e "Usage: $0 [preview|install|check|repos] [--yes] [--no-color] [--log FILE]"
            echo -e "Examples:"
            echo -e "  Install all packages: ./install-packages.sh install --yes"
            echo -e "  Check installed status: ./install-packages.sh check"
            exit 1 
            ;;
    esac
}

# Pass all script arguments to main
main "$@"




