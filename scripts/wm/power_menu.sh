#!/usr/bin/env bash
# Voidashi power menu -- wlogout with the geometry the theme expects.
#
# wlogout takes its layout from a file but its geometry only from CLI flags,
# so this wrapper is the single source of truth for both. Call it instead of
# calling wlogout directly, or the menu comes up full-bleed and untuned.
#
# The design is a centred vertical list rather than the default grid of tiles:
# six labelled rows, one per action, ordered by escalating consequence, with
# the two destructive ones last. Margins are derived from the actual output
# resolution so the column keeps its proportions on any screen.
set -euo pipefail

# Target column: a narrow list, not a wall of buttons.
COLUMN_WIDTH=460
ROW_HEIGHT=90
ROW_SPACING=4
ROWS=6

read_resolution() {
    if command -v hyprctl >/dev/null 2>&1 && hyprctl monitors -j >/dev/null 2>&1; then
        hyprctl monitors -j | python3 -c '
import json, sys
mons = json.load(sys.stdin)
mon = next((m for m in mons if m.get("focused")), mons[0] if mons else None)
if mon:
    print(mon["width"], mon["height"])
' && return 0
    fi

    if command -v swaymsg >/dev/null 2>&1 && swaymsg -t get_outputs >/dev/null 2>&1; then
        swaymsg -t get_outputs | python3 -c '
import json, sys
outs = [o for o in json.load(sys.stdin) if o.get("active")]
out = next((o for o in outs if o.get("focused")), outs[0] if outs else None)
if out:
    print(out["rect"]["width"], out["rect"]["height"])
' && return 0
    fi

    return 1
}

# Fall back to the most common laptop panel rather than failing outright: a
# slightly off-centre menu beats no menu.
if ! read -r WIDTH HEIGHT < <(read_resolution) || [[ -z ${WIDTH:-} || -z ${HEIGHT:-} ]]; then
    WIDTH=1920
    HEIGHT=1080
fi

STACK_HEIGHT=$(( ROWS * ROW_HEIGHT + (ROWS - 1) * ROW_SPACING ))
MARGIN_X=$(( (WIDTH - COLUMN_WIDTH) / 2 ))
MARGIN_Y=$(( (HEIGHT - STACK_HEIGHT) / 2 ))
# Clamp, so a small screen degrades to a full-bleed list instead of negatives.
(( MARGIN_X < 0 )) && MARGIN_X=0
(( MARGIN_Y < 0 )) && MARGIN_Y=0

exec wlogout \
    --buttons-per-row 1 \
    --column-spacing 0 \
    --row-spacing "$ROW_SPACING" \
    --margin-left "$MARGIN_X" \
    --margin-right "$MARGIN_X" \
    --margin-top "$MARGIN_Y" \
    --margin-bottom "$MARGIN_Y" \
    "$@"
