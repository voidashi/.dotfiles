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
    echo -e "--- Package Installer Log $(date) ---\n" > "$LOG_FILE"
}

log() {
    local level="$1" message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    
    [ "$NO_COLOR" = true ] && NC=""
    
    case "$level" in
        "INFO") color="$BLUE" ;;
        "WARNING") color="$YELLOW" ;;
        "ERROR") color="$RED" ;;
        "SUCCESS") color="$GREEN" ;;
    esac
    
    echo -e "${color}[$level]${NC} $message"
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# ---- Core Functions ----
detect_pkg_manager() {
    declare -A managers=(
        ["apt"]="/usr/bin/apt"
        ["pacman"]="/usr/bin/pacman"
        ["dnf"]="/usr/bin/dnf"
    )
    
    for manager in "${!managers[@]}"; do
        [ -x "${managers[$manager]}" ] && {
            echo "$manager"
            return
        }
    done
    log "ERROR" "No supported package manager found"
    exit 1
}

check_sudo() {
    if ! sudo -n true 2>/dev/null && ! $UNATTENDED; then
        log "WARNING" "Sudo access required - please enter password if prompted"
        sudo -v || exit 1
    fi
}

# ---- Repository Management ----
add_repos() {
    case "$PKG_MANAGER" in
        "apt")
            if ! grep -q "packages.microsoft.com" /etc/apt/sources.list.d/*; then
                log "INFO" "Adding Microsoft repository"
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null
                echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
            fi
            ;;
        "pacman")
            if ! grep -q "ghostty" /etc/pacman.conf; then
                log "INFO" "Adding Ghostty repository"
                echo -e "\n[ghostty]\nServer = https://ghostty.org/pacman" | sudo tee -a /etc/pacman.conf
                sudo pacman-key --recv-keys B54E40E31119DFA4
                sudo pacman-key --lsign-key B54E40E31119DFA4
            fi
            ;;
        "dnf")
            if ! rpm -q rpmfusion-free-release &>/dev/null; then
                log "INFO" "Adding RPM Fusion repository"
                sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
            fi
            ;;
    esac
    update_pkg_db
}

update_pkg_db() {
    [ "$UPDATED_DB" = true ] && return
    log "INFO" "Updating package database"
    case "$PKG_MANAGER" in
        "apt") sudo apt-get update -qq ;;
        "pacman") sudo pacman -Sy ;;
        "dnf") sudo dnf makecache ;;
    esac && UPDATED_DB=true
}

# ---- Package Operations ----
load_packages() {
    declare -gA PACKAGE_MAP=()
    
    while IFS='=' read -r key value; do
        [ -z "$key" ] && continue
        PACKAGE_MAP["$key"]="${value:-$key}"
    done < <(
        awk -v pm="$PKG_MANAGER" '
            $0 ~ /^\[.*\]$/ { section = substr($0, 2, length($0)-2) }
            (section == pm || section == "common") && $0 !~ /^[;#]/ { 
                gsub(/[[:space:]]*=[[:space:]]*/, "=")
                print $0
            }
        ' "$CONFIG_FILE"
    )
}

install_package() {
    local package="$1"
    log "INFO" "Processing: $package"
    
    case "$PKG_MANAGER" in
        "apt") sudo apt-get install -yqq "$package" ;;
        "pacman") sudo pacman -S --noconfirm --needed "$package" ;;
        "dnf") sudo dnf install -y --quiet "$package" ;;
    esac
    
    if [ $? -eq 0 ]; then
        log "SUCCESS" "Installed: $package"
        run_hooks "$package"
        return 0
    else
        log "ERROR" "Failed: $package"
        return 1
    fi
}

run_hooks() {
    local package="$1"
    awk -F= -v pkg="$package" '
        $1 == "[hooks]" { in_hooks = 1; next }
        in_hooks && $1 == pkg { system($2) }
    ' "$CONFIG_FILE"
}

# ---- User Commands ----
preview() {
    log "INFO" "Packages to install:"
    for pkg in "${!PACKAGE_MAP[@]}"; do
        echo -e "  ${GREEN}➔${NC} ${pkg} (${PACKAGE_MAP[$pkg]})"
    done
    echo -e "\nTotal: ${#PACKAGE_MAP[@]} packages"
}

install_all() {
    check_sudo
    add_repos
    
    local success=0 failures=0
    for pkg in "${!PACKAGE_MAP[@]}"; do
        install_package "${PACKAGE_MAP[$pkg]}" && ((success++)) || ((failures++))
    done
    
    log "SUMMARY" "Success: $success, Failed: $failures"
    [ $failures -eq 0 ] || exit 1
}

verify_installed() {
    local status=0
    for pkg in "${!PACKAGE_MAP[@]}"; do
        case "$PKG_MANAGER" in
            "apt") dpkg -l "${PACKAGE_MAP[$pkg]}" &>/dev/null ;;
            "pacman") pacman -Qi "${PACKAGE_MAP[$pkg]}" &>/dev/null ;;
            "dnf") dnf list installed "${PACKAGE_MAP[$pkg]}" &>/dev/null ;;
        esac
        
        if [ $? -eq 0 ]; then
            log "SUCCESS" "$pkg is installed"
        else
            log "WARNING" "$pkg is MISSING"
            status=1
        fi
    done
    exit $status
}

# ---- Execution Flow ----
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --yes) UNATTENDED=true; shift ;;
            --no-color) NO_COLOR=true; shift ;;
            --log) LOG_FILE="$2"; shift 2 ;;
            *) COMMAND="$1"; shift ;;
        esac
    done
}

main() {
    trap 'log "ERROR" "Script interrupted. Exiting safely..."; exit 1' SIGINT
    init_logging
    parse_args "$@"
    PKG_MANAGER=${DEFAULT_PACKAGE_MANAGER:-$(detect_pkg_manager)}
    log "INFO" "Detected package manager: $PKG_MANAGER"
    
    load_packages
    
    case "${COMMAND:-}" in
        preview) preview ;;
        install) install_all ;;
        repos) add_repos ;;
        check) verify_installed ;;
        *) 
            echo -e "Usage: $0 [preview|install|check|repos] [--yes] [--no-color]"
            echo -e "Examples:"
            echo -e "  Install all:    ./install-packages.sh install --yes"
            echo -e "  Check status:   ./install-packages.sh check"
            echo -e "  Single package: ./install-packages.sh install neovim"
            exit 1 
            ;;
    esac
}

main "$@"