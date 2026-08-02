#!/usr/bin/env bash
#
# Runs every validator this repository has and prints what each one returned.
#
# The discipline it serves is in docs/MAINTENANCE.md: report the measurement, not
# a verdict. So each block prints the command and its output verbatim, including
# the empty output that most of them produce when they pass. An empty block is a
# pass, not a validator that failed to run.
#
# A check whose tool is missing is reported as skipped and does not fail the run.
# This repository configures four terminals and two compositors and no machine is
# expected to have all of them installed.
#
# Exit status: 1 if any check failed, 0 otherwise. Skips do not fail the run.

# Not `set -e`: a failing check has to be reported and the run continued, which is
# the whole point of a battery.
set -uo pipefail

# No check here has any business reading input, and one of them does: catnap waits
# on stdin and hangs the whole run when it inherits a terminal. Closing it once
# here is what stops the next tool added below doing the same thing intermittently,
# which is how this surfaced: the first run of this script happened to pass.
exec </dev/null

cd "$(git rev-parse --show-toplevel)" || exit 1

FAILED=0
SKIPPED=0
declare -a FAILED_NAMES=()

section() { printf '\n== %s ==\n$ %s\n' "$1" "$2"; }

# Records the outcome of the check that just ran. Takes the exit status and the
# name, because the caller is the only thing that knows both.
verdict() {
    if [ "$1" -ne 0 ]; then
        FAILED=$((FAILED + 1))
        FAILED_NAMES+=("$2")
        printf '[FAIL] %s\n' "$2"
    fi
}

# Reports a missing tool and returns non-zero so the caller can skip its block.
have() {
    command -v "$1" >/dev/null 2>&1 && return 0
    SKIPPED=$((SKIPPED + 1))
    printf 'skipped: %s is not installed\n' "$1"
    return 1
}

section "Palette and generated files" "python3 scripts/theme/check_palette.py"
python3 scripts/theme/check_palette.py 2>&1
verdict $? "palette"

section "Hyprland" "hyprctl configerrors"
if have hyprctl; then
    # Only answers under a running Hyprland, so a failure here off-session is not
    # a config error and is reported as a skip.
    if out=$(hyprctl configerrors 2>&1); then
        printf '%s\n' "$out"
        case "$out" in *"no errors"*|"") ;; *) verdict 1 "hyprland" ;; esac
    else
        SKIPPED=$((SKIPPED + 1))
        printf 'skipped: hyprctl did not answer, so no Hyprland is running\n'
    fi
fi

section "hyprtoolkit source path" "sed -n 's/^source *= *//p' .config/hypr/hyprtoolkit.conf"
# hyprtoolkit validates nothing and hyprlang resolves a relative source against
# the process cwd, so a path written "./file.conf" loads the toolkit's own
# defaults from every launcher not started in .config/hypr/, with no error
# anywhere. Nothing here can prove the colours arrived, which takes a screenshot;
# this proves only that the path is one hyprlang can still find at runtime.
htk_bad=0
while IFS= read -r htk_path; do
    printf 'source = %s\n' "$htk_path"
    case "$htk_path" in
        "~/.config/"*)
            htk_target=".${htk_path#\~}"
            if [ ! -f "$htk_target" ]; then
                printf '[FAIL] no such file: %s\n' "$htk_target"
                htk_bad=1
            fi
            ;;
        /*)
            printf 'absolute path outside $HOME, not checkable from the repo\n'
            ;;
        *)
            printf '[FAIL] relative path, which hyprlang resolves against the process cwd\n'
            htk_bad=1
            ;;
    esac
done < <(sed -n 's/^source *= *//p' .config/hypr/hyprtoolkit.conf)
verdict "$htk_bad" "hyprtoolkit source"

section "Sway" "sway --validate -c .config/sway/config"
if have sway; then
    sway --validate -c .config/sway/config 2>&1
    verdict $? "sway"
fi

section "foot" "foot --check-config -c .config/foot/foot.ini"
if have foot; then
    foot --check-config -c .config/foot/foot.ini 2>&1
    verdict $? "foot"
fi

section "Ghostty" "ghostty +validate-config --config-file=.config/ghostty/config"
if have ghostty; then
    # Capture instead of letting it inherit stdout. ghostty truncates the file it
    # writes to, so when this battery's output is redirected anywhere it wipes
    # every block printed before it and leaves a zero-filled hole in their place.
    # Measured: with ghostty inheriting stdout, the first five sections vanished
    # and 394 NUL bytes appeared at offset 0. A pipe cannot be truncated, which is
    # what a command substitution gives it.
    out=$(ghostty +validate-config --config-file=.config/ghostty/config 2>&1)
    status=$?
    [ -n "$out" ] && printf '%s\n' "$out"
    verdict "$status" "ghostty"
fi

section "kitty" "kitty +runpy ... load_config(accumulate_bad_lines)"
if have kitty; then
    # kitty exits 0 on a bad config and reports the offending lines in a list, so
    # the list is the signal and the exit status is not. Prints [] when clean.
    bad=$(kitty +runpy \
        "from kitty.config import load_config; bad=[]; load_config('.config/kitty/kitty.conf', accumulate_bad_lines=bad); print(bad)" \
        2>&1 | tail -1)
    printf '%s\n' "$bad"
    [ "$bad" = "[]" ] || verdict 1 "kitty"
fi

section "fastfetch, every config" "fastfetch --pipe true -c <each>"
if have fastfetch; then
    ff_bad=0
    ff_count=0
    for f in .config/fastfetch/config.jsonc .config/fastfetch/*/config.jsonc \
             .config/fastfetch/minimal/*.jsonc; do
        [ -f "$f" ] || continue
        ff_count=$((ff_count + 1))
        # Renders to stdout and complains on stderr, so only stderr is the signal.
        out=$(fastfetch --pipe true -c "$f" 2>&1 >/dev/null)
        if [ -n "$out" ]; then
            printf '%s: %s\n' "$f" "$out"
            ff_bad=1
        fi
    done
    printf 'checked: %d\n' "$ff_count"
    verdict "$ff_bad" "fastfetch"
fi

section "catnap" "timeout 5 catnap -n -c .config/catnap/config.toml"
if have catnap; then
    # Covers config.toml only. There is no flag for distros.toml: catnap's whole
    # option list is -h -v -d -g -n -c -m -l, and the -a this check used to pass
    # was rejected as an unknown option every single run, so that file has never
    # been validated by anything. Do not add it back without a flag that exists.
    #
    # Read the exit code only in the negative. catnap renders to a terminal and
    # never exits when its stdout is not one, so a config it accepts leaves it
    # running until the timeout while a broken one is rejected immediately with 1.
    # Measured all three ways: the tracked config times out, a garbage TOML exits
    # 1, and a path that does not exist exits 0 because catnap falls back to its
    # defaults in silence. That last one is the limit of this check: it proves the
    # file parses, not that catnap read the file you meant.
    #
    # This check lived in an agent skill and reported "exit: 0" for months, because
    # the harness handed it a pty and the unknown-option errors went unread.
    err=$(timeout 5 catnap -n -c .config/catnap/config.toml 2>&1 >/dev/null \
          | grep -i error | head -3)
    timeout 5 catnap -n -c .config/catnap/config.toml >/dev/null 2>&1
    status=$?
    [ -n "$err" ] && printf '%s\n' "$err"
    case "$status" in
        124) printf 'accepted: still rendering at the timeout, which is the pass\n' ;;
        0)   printf 'exited 0, which also means the config file was not found\n' ;;
        *)   printf 'rejected the config, exit %d\n' "$status"
             verdict 1 "catnap" ;;
    esac
fi

section "Tracked symlinks" "bash scripts/backup-configs.sh check"
# SUCCESS lines only appear under --verbose, so this filter is insurance rather
# than a filter. Never count them: doing so is how this block once reported
# "valid: 0" beside a summary saying the opposite. The summary line is the
# measurement, and Broken is the number that matters.
bash scripts/backup-configs.sh check 2>&1 | grep -v SUCCESS
verdict "${PIPESTATUS[0]}" "symlinks"

section "Sandboxed tests for backup-configs.sh" "bash scripts/tests/test-dotfiles.sh"
# The only executable proof that the one script able to damage a real $HOME is
# still safe. It runs entirely inside a throwaway HOME.
bash scripts/tests/test-dotfiles.sh 2>&1 | tail -3
verdict "${PIPESTATUS[0]}" "tests"

section "No gitlink in the index" "git ls-files -s | grep '^160000'"
# An agent worktree was committed as a gitlink twice: once by accident, and once
# when a merge kept the side of the history that still had it. .gitignore cannot
# prevent the second, because git ignores it for a path that is already tracked.
# This is the only thing that catches it.
if links=$(git ls-files -s | grep "^160000"); then
    printf '%s\n' "$links"
    verdict 1 "gitlink"
else
    printf 'none\n'
fi

section "Working tree" "git status --short"
# Not a pass or a fail. kdeglobals and both GTK settings.ini files have a second
# owner in KDE, so dirt here may be something else's rather than ours.
git status --short

printf '\n== Summary ==\n'
if [ "$FAILED" -eq 0 ]; then
    printf 'all checks passed, %d skipped\n' "$SKIPPED"
else
    printf 'failed: %s\n' "${FAILED_NAMES[*]}"
    printf '%d failed, %d skipped\n' "$FAILED" "$SKIPPED"
fi

exit $((FAILED > 0))
