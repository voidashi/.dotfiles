#!/usr/bin/env bash
# Does the running compositor hand its children the session environment?
#
# Run this from inside the session you want to test. It asks the compositor to
# launch a process and reads what that process inherited, which is exactly what
# an application gets. Reading the compositor's own /proc entry does not work:
# ptrace_scope blocks it for anything that is not a descendant.
#
# Why it exists. ~/.config/environment.d/ is read by `systemd --user`, and a
# greeter that execs the compositor directly never makes it a systemd user unit,
# so the environment is correct in one place and never handed over. The symptom
# is Qt applications rendering unthemed, because QT_QPA_PLATFORMTHEME does not
# arrive. See docs/TODO.md.
#
# Do NOT read XCURSOR_SIZE as evidence. sway sets it to 24 by itself and its
# default happens to equal ours, so it reports a pass whether or not anything was
# delivered. HYPRCURSOR_SIZE is the honest probe: only environment.d sets it.
set -uo pipefail

OUT=$(mktemp) || exit 1
trap 'rm -f "$OUT"' EXIT

if command -v swaymsg >/dev/null 2>&1 && swaymsg -t get_version >/dev/null 2>&1; then
    compositor=sway
    swaymsg exec -- "sh -c 'env > $OUT'" >/dev/null 2>&1
elif command -v hyprctl >/dev/null 2>&1 && hyprctl version >/dev/null 2>&1; then
    compositor=Hyprland
    hyprctl dispatch exec "sh -c 'env > $OUT'" >/dev/null 2>&1
else
    echo "No compositor IPC reachable. Run this from inside a sway or Hyprland session."
    exit 1
fi

sleep 2
if [ ! -s "$OUT" ]; then
    echo "$compositor did not run the probe, so nothing can be said."
    exit 1
fi

get() { grep -m1 "^$1=" "$OUT" | cut -d= -f2-; }

qt=$(get QT_QPA_PLATFORMTHEME)
hyprcursor=$(get HYPRCURSOR_SIZE)
path=$(get PATH)

echo "compositor:           $compositor"
echo "QT_QPA_PLATFORMTHEME: ${qt:-(UNSET)}"
echo "HYPRCURSOR_SIZE:      ${hyprcursor:-(UNSET)}"
case ":$path:" in
    *":$HOME/.local/bin:"*) helpers=yes ;;
    *)                      helpers=no ;;
esac
echo "~/.local/bin on PATH: $helpers"
echo

# Hyprland sets these again for its own children through conf/env_vars.lua, so a
# pass there says nothing about the session. sway has no such fallback, which is
# what makes it the compositor worth testing.
if [ "$compositor" = Hyprland ]; then
    echo "Note: Hyprland sets these for its children in conf/env_vars.lua whatever the"
    echo "session provides, so a pass here is not evidence about the bridge. Test sway."
fi

if [ "$qt" = "kde" ] && [ -n "$hyprcursor" ]; then
    echo "PASS: the session environment reaches the compositor's children."
    [ "$helpers" = no ] && echo "      PATH is not carried yet, which is stage two in docs/TODO.md."
    exit 0
fi

echo "FAIL: the session environment does not reach the compositor's children."
echo "      docs/TODO.md has the two stages that fix it."
exit 1
