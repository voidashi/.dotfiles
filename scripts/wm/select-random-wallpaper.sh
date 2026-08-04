#!/bin/bash
# Pick a random wallpaper and print its path on stdout.
#
# Usage: select-random-wallpaper.sh DIR [FALLBACK_DIR...]
#
# Walks the directories in the order given and uses the first one that contains
# images. That order is this repo's convention:
#
#   ~/Pictures/Current_wallpapers        ->  the set in rotation right now
#   ~/Pictures/Wallpapers                ->  the full collection
#   ~/.local/share/wallpapers/dotfiles   ->  the sample shipped with the repo,
#                                            linked there by backup-configs.sh
#                                            install, so no caller has to know
#                                            where the repository was cloned
#
# So a fresh install works with no setup: if the first two directories do not
# exist yet, it falls back to the wallpaper the repo ships.
#
# IMPORTANT: error messages go to stderr. On stdout, the caller's $(...) would
# capture the message and pass it along as a filename, which is exactly the bug
# that left swaybg with no wallpaper under Sway.

set -uo pipefail

if [ "$#" -eq 0 ]; then
    echo "usage: $(basename "$0") DIR [FALLBACK_DIR...]" >&2
    exit 1
fi

for dir in "$@"; do
    [ -d "$dir" ] || continue

    # -print0 with shuf -z handles filenames containing spaces.
    file="$(find -L "$dir" -maxdepth 1 -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
           -o -iname '*.webp' -o -iname '*.bmp' \) -print0 2>/dev/null \
        | shuf -z -n 1 | tr -d '\0')"

    if [ -n "$file" ]; then
        echo "$file"
        exit 0
    fi
done

echo "No images found in: $*" >&2
exit 1
