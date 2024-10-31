#!/bin/bash

# Set strict error handling
set -euo pipefail
IFS=$'\n\t'

# Configuration
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_FILE="$HOME/scripts/dotfiles/dotfiles.conf"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    case "$level" in
        "INFO")    echo -e "${BLUE}[INFO]${NC} $*" ;;
        "WARNING") echo -e "${YELLOW}[WARNING]${NC} $*" ;;
        "ERROR")   echo -e "${RED}[ERROR]${NC} $*" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $*" ;;
    esac
}

# Git Operations
git_is_repo() {
    [ -d "$DOTFILES_DIR/.git" ]
}

git_has_changes() {
    git -C "$DOTFILES_DIR" status --porcelain | grep -q .
}

git_commit() {
    local file="$1"
    local message="$2"
    
    if git_is_repo && git_has_changes; then
        git -C "$DOTFILES_DIR" add "$file"
        git -C "$DOTFILES_DIR" commit -m "$message"
        log "SUCCESS" "Changes committed to Git repository"
    fi
}

# Repository Management Functions
init_dotfiles() {
    if [ ! -d "$DOTFILES_DIR" ]; then
        mkdir -p "$DOTFILES_DIR"
        git init "$DOTFILES_DIR"
        log "SUCCESS" "Dotfiles repository initialized in $DOTFILES_DIR"
    else
        log "INFO" "$DOTFILES_DIR already exists"
    fi
}

add_dotfile() {
    local target="$1"
    target="${target/#\~/$HOME}"
    local dest="$DOTFILES_DIR/${target#$HOME/}"

    if [ -L "$target" ]; then
        log "INFO" "$target is already linked"
        return 0
    fi

    if [ -e "$dest" ]; then
        log "WARNING" "$dest already exists in dotfiles. File will not be moved"
        return 1
    fi

    # Backup existing file
    if [ -e "$target" ]; then
        backup_file "$target"
    fi

    mkdir -p "$(dirname "$dest")"
    mv "$target" "$dest"
    ln -s "$dest" "$target"
    log "SUCCESS" "Added and linked: $target"

    # Git integration
    if git_is_repo; then
        echo "Commit changes to Git? [y/N]"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git_commit "$dest" "Add: ${target#$HOME/}"
        fi
    fi
}

add_dotfiles() {
    local files
    files=$(load_dotfiles)

    for file in $files; do
        add_dotfile "$file"
    done
}

check_dotfiles() {
    log "INFO" "Verifying symlink integrity..."
    local status=0

    while IFS= read -r file; do
        local target="${file/#\~/$HOME}"
        local dest="$DOTFILES_DIR/${target#$HOME/}"

        if [ -L "$target" ]; then
            if [ "$(readlink "$target")" == "$dest" ]; then
                log "SUCCESS" "$target is correctly linked"
            else
                log "ERROR" "$target is incorrectly linked"
                status=1
            fi
        else
            log "WARNING" "$target is not a symlink or is not configured"
            status=1
        fi
    done < <(load_dotfiles)

    return $status
}

# Installation Functions
preview_changes() {
    log "INFO" "Files to be processed:"
    echo
    
    while IFS= read -r file; do
        local target="${file/#\~/$HOME}"
        
        if [ -e "$target" ]; then
            if [ -L "$target" ]; then
                echo -e "${BLUE}[LINKED]${NC} $target"
            else
                echo -e "${YELLOW}[EXISTS]${NC} $target (will be backed up)"
            fi
        else
            echo -e "${GREEN}[NEW]${NC} $target"
        fi
    done < <(load_dotfiles)
    
    echo
    read -p "Proceed with these changes? [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

get_categories() {
    while IFS= read -r file; do
        dirname "${file#$HOME/}" | cut -d'/' -f1
    done < <(load_dotfiles) | sort -u
}

install_category() {
    local category="$1"
    local found=false
    
    log "INFO" "Installing category: $category"
    
    while IFS= read -r file; do
        if [[ "$file" =~ ^$HOME/.*$category.* ]]; then
            found=true
            install_dotfile "$file"
        fi
    done < <(load_dotfiles)
    
    if ! $found; then
        log "ERROR" "No configurations found for: $category"
        echo "Available categories:"
        get_categories | sed 's/^/  - /'
    fi
}

install_dotfile() {
    local target="$1"
    target="${target/#\~/$HOME}"
    local dest="$DOTFILES_DIR/${target#$HOME/}"

    if [ -f "$target" ] && [ ! -L "$target" ] && [ -f "$dest" ]; then
        echo
        log "INFO" "Differences for $target:"
        if ! diff -u "$target" "$dest"; then
            log "INFO" "Files are different"
        fi
        echo
        
        read -p "Install this file? [y/N/d] (y=yes, N=no, d=show detailed diff) " -n 1 -r
        echo
        
        case $REPLY in
            [Dd])
                diff --color -y "$target" "$dest" || true
                install_dotfile "$1"
                return
                ;;
            [Yy])
                backup_file "$target"
                ln -sf "$dest" "$target"
                log "SUCCESS" "Installed: $target"
                ;;
            *)
                log "INFO" "Skipped: $target"
                ;;
        esac
    else
        mkdir -p "$(dirname "$target")"
        ln -sf "$dest" "$target"
        log "SUCCESS" "Installed: $target"
    fi
}

# Utility Functions
backup_file() {
    local target="$1"
    local backup_path="$BACKUP_DIR/${target#$HOME/}"
    
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mkdir -p "$(dirname "$backup_path")"
        cp -R "$target" "$backup_path"
        log "INFO" "Backup created: $target → $backup_path"
    fi
}

load_dotfiles() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log "ERROR" "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi

    grep -v '^#' "$CONFIG_FILE" | grep -v '^$'
}

# Main command handler
main() {
    case "${1:-}" in
        "init")
            init_dotfiles
            ;;
        "add")
            add_dotfiles
            ;;
        "check")
            check_dotfiles
            ;;
        "preview")
            preview_changes
            ;;
        "install")
            if [ -z "${2:-}" ]; then
                if preview_changes; then
                    while IFS= read -r file; do
                        install_dotfile "$file"
                    done < <(load_dotfiles)
                    log "SUCCESS" "Installation complete! Backups stored in: $BACKUP_DIR"
                fi
            else
                install_category "$2"
            fi
            ;;
        "list")
            echo "Available categories:"
            get_categories | sed 's/^/  - /'
            ;;
        "restore")
            if [ -d "$BACKUP_DIR" ]; then
                log "INFO" "Restoring from: $BACKUP_DIR"
                cp -R "$BACKUP_DIR/"* "$HOME/"
                log "SUCCESS" "Files restored from backup"
            else
                log "ERROR" "No backup directory found"
            fi
            ;;
        *)
            echo "Usage: $0 {init|add|check|preview|install [category]|list|restore}"
            echo
            echo "Management Commands:"
            echo "  init          Initialize dotfiles repository"
            echo "  add           Add and link files from config"
            echo "  check         Verify symlink integrity"
            echo
            echo "Installation Commands:"
            echo "  preview       Show planned changes"
            echo "  install      Install all or specific category"
            echo "  list         Show available categories"
            echo "  restore      Restore from backup"
            exit 1
            ;;
    esac
}

main "$@"
