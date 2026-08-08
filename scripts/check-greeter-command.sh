#!/usr/bin/env bash
# Would this greetd command line actually start a greeter?
#
# Run it BEFORE rebooting. A greetd `command` that tuigreet rejects leaves you
# with no login screen and a trip to a TTY, and nothing warns you first: greetd
# starts the greeter, the greeter exits, greetd retries, and you get a black
# screen. This has happened here once already.
#
# Usage:
#   scripts/check-greeter-command.sh                 # checks /etc/greetd/config.toml
#   scripts/check-greeter-command.sh 'tuigreet ...'  # checks a line you are about to write
#
# What it does and does not prove. greetd runs the line through sh(1), so this
# runs it the same way with GREETD_SOCK unset. Reaching "GREETD_SOCK must be
# defined" means tuigreet parsed every argument and would have started. A usage
# error means it would not. It says nothing about whether the session you log
# into then works, which is a different failure and a recoverable one.
set -uo pipefail

line="${1:-}"
if [ -z "$line" ]; then
    line=$(sed -n 's/^[[:space:]]*command[[:space:]]*=[[:space:]]*"\(.*\)"[[:space:]]*$/\1/p' \
           /etc/greetd/config.toml 2>/dev/null | head -1)
    if [ -z "$line" ]; then
        echo "Could not read a command from /etc/greetd/config.toml. Pass one as an argument."
        exit 1
    fi
    echo "From /etc/greetd/config.toml:"
fi
echo "  $line"
echo

if ! command -v script >/dev/null 2>&1; then
    echo "This needs util-linux's 'script' to give the greeter a pty."
    exit 1
fi

# A pty, because tuigreet panics without one and that panic looks like a failure
# whatever the arguments are. Without this the check reports the same thing for a
# good line and a bad one, which is worse than no check.
out=$(env -u GREETD_SOCK script -qec "$line" /dev/null 2>&1 </dev/null | head -5)

echo "$out" | sed 's/^/  /'
echo

if echo "$out" | grep -qi "GREETD_SOCK"; then
    echo "PASS: every argument was accepted. It would start."
    exit 0
fi
if echo "$out" | grep -qiE "unrecognized option|invalid|usage:"; then
    echo "FAIL: the greeter rejected an argument and would exit, leaving no login screen."
    echo "      A multi-word --cmd needs quoting that survives into sh, for example:"
    echo "        --cmd 'uwsm start -e -D Hyprland hyprland.desktop'"
    exit 1
fi
echo "UNCLEAR: neither a socket complaint nor a usage error. Read the output above"
echo "         rather than trusting this script."
exit 2
