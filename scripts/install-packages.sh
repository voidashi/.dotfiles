#!/bin/bash
# Unified Package Installer (Optimized)
# Purpose: Reliably install packages across Linux distros with third-party repo support
# Usage: ./install-packages.sh [preview|install|check|repos] [--yes] [--no-color] [--log FILE]

# ---- Configuration ----
CONFIG_FILE="packages.conf"
LOG_FILE="${LOG_FILE:-package_install.log}"
DEFAULT_PACKAGE_MANAGER="auto"
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
    # Use a local associative array for clarity
    declare -A managers=(
        ["apt"]="/usr/bin/apt"
        ["pacman"]="/usr/bin/pacman"
        ["dnf"]="/usr/bin/dnf"
    )
    
    for manager in "${!managers[@]}"; do
        if [ -x "${managers[$manager]}" ]; then
            echo "$manager"
            return
        fi
    done
    
    log "ERROR" "No supported package manager found (apt, pacman, dnf)."
    exit 1
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
        ### MODIFICATION ###
        # The ghostty repository is no longer needed for pacman as the package
        # is in the official 'extra' repository. This block has been removed.
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
            # Identify the current section
            $0 ~ /^\[.*\]$/ { section = substr($0, 2, length($0)-2) }
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
    log "INFO" "Processing: $key ($package_name)"
    
    case "$PKG_MANAGER" in
        "apt") sudo apt-get install -yqq "$package_name" ;;
        "pacman") sudo pacman -S --noconfirm --needed "$package_name" ;;
        "dnf") sudo dnf install -y --quiet "$package_name" ;;
    esac
    
    if [ $? -eq 0 ]; then
        log "SUCCESS" "Installed: $key"
        run_hooks "$key" # Use the key for hooks
        return 0
    else
        log "ERROR" "Failed to install: $key ($package_name)"
        return 1
    fi
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
    
    local success=0 failures=0
    for key in "${!PACKAGE_MAP[@]}"; do
        install_package "$key" "${PACKAGE_MAP[$key]}" && ((success++)) || ((failures++))
    done
    
    log "SUMMARY" "Installation complete. Success: $success, Failed: $failures"
    [ $failures -eq 0 ] || exit 1
}

verify_installed() {
    local overall_status=0
    log "INFO" "Checking status of configured packages..."
    for key in "${!PACKAGE_MAP[@]}"; do
        local package_name="${PACKAGE_MAP[$key]}"
        local installed=1 # 0 = yes, 1 = no
        
        # Check status based on package manager
        case "$PKG_MANAGER" in
            "apt") dpkg-query -W -f='${Status}' "$package_name" 2>/dev/null | grep -q "ok installed" && installed=0 ;;
            "pacman") pacman -Q "$package_name" &>/dev/null && installed=0 ;;
            "dnf") dnf list installed "$package_name" &>/dev/null && installed=0 ;;
        esac
        
        if [ $installed -eq 0 ]; then
            log "SUCCESS" "$key is installed."
        else
            log "WARNING" "$key is MISSING."
            overall_status=1 # Mark that at least one package is missing
        fi
    done
    exit $overall_status
}

# ---- Execution Flow ----
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --yes) UNATTENDED=true; shift ;;
            --no-color) NO_COLOR=true; shift ;;
            --log) LOG_FILE="$2"; shift 2 ;;
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
        PKG_MANAGER=$(detect_pkg_manager)
    else
        PKG_MANAGER="$DEFAULT_PACKAGE_MANAGER"
    fi
    
    log "INFO" "Using package manager: $PKG_MANAGER"
    
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




