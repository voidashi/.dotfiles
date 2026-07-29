#!/usr/bin/env bash
# Voidashi clipboard picker: cliphist history, presented through wofi.
#
# Usage: clipboard-picker.sh [wipe]
#
# This lives in one script rather than inline in two compositor configs because
# the pipeline is identical for Hyprland and Sway. Three drifting copies of the
# waybar config is what the other choice looks like a year later.
#
# The one non-obvious part is the id. "cliphist list" prints "<id><TAB><preview>"
# and "cliphist decode" needs that id back to find the entry, so it has to
# survive the round trip through the menu. wofi's --pre-display-cmd changes only
# what is drawn and never what is returned, which is what lets the menu show the
# text alone while the id still reaches decode.
#
# Geometry is passed here rather than put in .config/wofi/config because that
# file is shared with drun mode, where a launcher wants different proportions
# from a list of pasted text.

set -uo pipefail

if ! command -v cliphist >/dev/null 2>&1; then
    notify-send -u critical "Clipboard" "cliphist is not installed" 2>/dev/null
    echo "clipboard-picker: cliphist not found. It is declared in scripts/packages.conf; run scripts/install-packages.sh install." >&2
    exit 1
fi

if [ "${1:-}" = "wipe" ]; then
    cliphist wipe
    notify-send "Clipboard" "History cleared" 2>/dev/null
    exit 0
fi

history="$(cliphist list)"

# An empty menu looks like a broken keybinding, so say which it is. This is the
# normal state right after login, before anything has been copied.
if [ -z "$history" ]; then
    notify-send "Clipboard" "History is empty" 2>/dev/null
    exit 0
fi

# A quoting oddity inside an entry can make one row draw wrong, but because
# --pre-display-cmd cannot alter the returned value, it can never paste the
# wrong entry.
selection="$(printf '%s\n' "$history" \
    | wofi --dmenu --prompt clipboard --lines 12 --width 720 \
           --pre-display-cmd "echo '%s' | cut -f 2-")"

# Empty means the menu was dismissed with Escape, which is not an error.
[ -n "$selection" ] || exit 0

printf '%s' "$selection" | cliphist decode | wl-copy
