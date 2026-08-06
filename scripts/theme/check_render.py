#!/usr/bin/env python3
"""Prove the palette was painted, not merely written down.

check_palette.py asks whether a colour belongs to the palette and whether a
generated file matches its source. Neither question catches the failure this
repository keeps paying for, which is a config that is correct and reaches
nothing:

  yazi renamed six theme keys and dropped the old spelling in silence, so the
  ice-600 cursor fill and the bordeaux-300 mode badge sat in theme.toml while
  yazi painted its own blue. Rendered, both appeared zero times.

  catnap 2 replaced its config format and stopped reading config.toml at all.
  The tracked file was themed, checked and inert for a whole release while the
  fetch on screen came from the package's own config in /etc.

So this runs the program and reads the escapes it emits. A colour that is
required and absent is a failure; everything emitted is printed either way,
because the measurement is the useful part and a verdict is not.

Deliberately narrow. It covers the two applications whose overrides are matched
by name against something upstream owns and that can be driven headless. It is
not a general answer to "did this config apply", and nothing here should be read
as covering the others.

Usage:
    python3 scripts/theme/check_render.py

Exits 1 if a required colour was not emitted. A program that is not installed is
reported as skipped and does not fail the run.
"""
import fcntl
import json
import os
import pty
import re
import select
import shutil
import struct
import subprocess
import sys
import tempfile
import termios
import time
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent
CONFIG = REPO_ROOT / ".config"

# Two stages rather than one pattern. Both programs write foreground and
# background in a single SGR, "\x1b[38;2;r;g;b;48;2;r;g;b m", so one anchored
# pattern matches whichever comes first and never counts the other: the mode
# badge reported its fill and lost its text colour, and the numbers looked
# right enough to publish.
SGR = re.compile(r"\x1b\[([0-9;]*)m")
COLOUR = re.compile(r"(?:^|;)([34])8;2;(\d{1,3});(\d{1,3});(\d{1,3})")

TIMEOUT = 6.0


def run_in_pty(argv: list, env: dict, cwd: str) -> str:
    """Everything the program wrote, given a terminal it will actually draw on.

    The window size has to be set on the pty itself. With only LINES and COLUMNS
    in the environment yazi drew into an 0x0 terminal and emitted 764 bytes with
    no colour in any of them, which is indistinguishable from a theme that
    failed to load. And `btm -C <file>` outside a terminal exits 1 with "No such
    device or address" whatever the config says, so an exit status read without
    a pty discriminates nothing.
    """
    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 40, 120, 0, 0))
    full = dict(os.environ, TERM="xterm-256color", COLORTERM="truecolor", **env)
    proc = subprocess.Popen(argv, stdin=slave, stdout=slave, stderr=slave,
                            env=full, cwd=cwd, close_fds=True)
    os.close(slave)
    out = b""
    deadline = time.time() + TIMEOUT
    while time.time() < deadline:
        if proc.poll() is not None:
            # Drain whatever is still buffered before giving up on the pty.
            try:
                while True:
                    chunk = os.read(master, 65536)
                    if not chunk:
                        break
                    out += chunk
            except OSError:
                pass
            break
        ready, _, _ = select.select([master], [], [], 0.25)
        if ready:
            try:
                chunk = os.read(master, 65536)
            except OSError:
                break
            if not chunk:
                break
            out += chunk
    if proc.poll() is None:
        proc.terminate()
    try:
        proc.wait(timeout=3)
    except subprocess.TimeoutExpired:
        proc.kill()
    os.close(master)
    return out.decode("utf-8", "replace")


def colours_emitted(text: str) -> dict:
    """Every truecolor escape in the output, as (role, #rrggbb) -> count."""
    counts = {}
    for params in SGR.findall(text):
        for kind, r, g, b in COLOUR.findall(params):
            key = ("fg" if kind == "3" else "bg",
                   "#%02x%02x%02x" % (int(r), int(g), int(b)))
            counts[key] = counts.get(key, 0) + 1
    return counts


def render_yazi(p: dict, r: dict):
    """yazi against the tracked config, browsing a throwaway directory.

    Required: the cursor row's fill, the mode badge and the pane border. Those
    three come from three different tables, so one of them missing localises the
    fault rather than only reporting it. They are also exactly what the renamed
    keys were carrying.

    The fixture is nested one level inside the temporary directory because yazi
    draws a parent pane, and browsing mkdtemp() directly put the machine's whole
    /tmp in it: every icon in there was emitted, so the output moved between runs
    on one machine and could not be compared across two. Measured, that pane
    contributed three colours the fixture never asks for, the commonest of them
    more than a dozen times and a different number on each measurement, which is
    the instability itself and not a figure worth writing down.
    """
    top = tempfile.mkdtemp(prefix="voidashi-render-")
    browse = Path(top) / "fixture"
    browse.mkdir()
    for name in ("alpha.txt", "beta.md", "gamma.rs"):
        (browse / name).touch()
    (browse / "a-directory").mkdir()
    try:
        text = run_in_pty(["yazi", str(browse)],
                          {"YAZI_CONFIG_HOME": str(CONFIG / "yazi")}, str(browse))
    finally:
        shutil.rmtree(top, ignore_errors=True)
    required = [
        ("bg", r["selection"]["bg"], "the cursor row, indicator.current"),
        ("bg", r["identity"]["cursor"], "the mode badge, mode.normal_main"),
        ("fg", r["line"]["window"], "the pane border, mgr.border_style"),
    ]
    return text, required


def render_catnap(p: dict, r: dict):
    """catnap against the tracked config.

    -c reads the repository rather than whatever is linked into $HOME. `import`
    resolves against the config file's own directory either way, so the theme
    and the art come from the repo too.
    """
    text = run_in_pty(
        ["catnap", "-n", "-c", str(CONFIG / "catnap" / "config.cat")],
        {}, str(REPO_ROOT))
    required = [
        ("fg", r["identity"]["mark"], "the username, hostname and logo"),
        ("fg", r["accent"]["decoration"], "the function rows"),
        ("fg", r["line"]["window"], "the frame"),
    ]
    return text, required


# Third element: what a colour outside the palette means for this program, or None
# when nothing accounts for one. yazi's icons come from the [icon] table of the
# default theme embedded in the binary, one colour per file type, and this
# repository does not override it: the decision and its reasons are in THEMING.md.
# Nothing overrides it in catnap either, so an unexplained colour there is a
# finding rather than a note.
PROGRAMS = (
    ("yazi", render_yazi,
     "yazi's own [icon] table, one colour per file type, which this repository "
     "does not override. See docs/design/THEMING.md."),
    ("catnap", render_catnap, None),
)


def main() -> int:
    sys.path.insert(0, str(SCRIPT_DIR))
    import check_palette  # noqa: E402
    import generate_theme as gen  # noqa: E402
    import roles  # noqa: E402

    p = gen.load_palette()
    r = roles.build(p)
    # Borrowed rather than restated: one definition of what the palette holds,
    # and it is the one the drift check uses.
    known = check_palette.palette_colours(p)

    failed = False
    for name, render, exempt in PROGRAMS:
        print(f"\n{name}:")
        if shutil.which(name) is None:
            print(f"  skipped: {name} is not installed")
            continue
        text, required = render(p, r)
        counts = colours_emitted(text)
        if not counts:
            failed = True
            print(f"  [FAIL] emitted no truecolor escape at all, in {len(text)} bytes")
            for line in text.splitlines()[:3]:
                print(f"    {line.strip()[:100]}")
            continue
        print("  emitted:")
        for (kind, hexval), n in sorted(counts.items()):
            mark = "" if hexval in known else "   outside the palette"
            print(f"    {kind} {hexval}  x{n}{mark}")
        # Never a failure. A program paints things this repository does not
        # configure, and the useful thing is that they are named rather than
        # buried in a list of hex nobody reads twice.
        outside = sorted({hexval for _, hexval in counts} - known)
        if outside:
            print(f"  outside the palette: {' '.join(outside)}")
            print(f"    {exempt}" if exempt else
                  "    Nothing here accounts for these, which is worth a look: the "
                  "file checks cannot\n    see a colour that is not in a file.")
        print("  required:")
        for kind, hexval, what in required:
            n = counts.get((kind, hexval.lower()), 0)
            if n:
                print(f"    ok    {kind} {hexval} x{n}   {what}")
            else:
                failed = True
                print(f"    [FAIL] {kind} {hexval} never emitted, so {what} "
                      f"is written and not painted")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
