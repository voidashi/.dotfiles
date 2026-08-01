#!/usr/bin/env python3
"""Prove the rice has not drifted off the palette.

RICE-GUIDE.md has a non-negotiable, "never invent a colour", which used to be
an honour-system rule. Several files carry hand-pasted hex because colour mixes
with structural config in them (swaylock, bottom, starship, fastfetch, catnap,
fish, yazi, Sway and Neovim's roles layer), and nothing said so when one of them
aged out of step with palette.json.

Two checks:

  drift    a colour in a tracked config that palette.json does not contain
  sync     a GENERATED file that differs from what the generator would write
           now, which is what happens when someone edits the output instead of
           the source

Usage:
    python3 scripts/theme/check_palette.py

Exits 1 if either fails, so it can be wired into a hook.
"""
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate_theme as gen  # noqa: E402

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent

HEX = re.compile(r"#[0-9a-fA-F]{6}\b")

# Terminal colour names. Twelve fish variables sat on green, red, brgreen and
# cyan with nobody noticing, because the check only looked at hex. A colour name
# never comes from the palette: it is always what the program inherited.
NAMED = (
    "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white",
    "brblack", "brred", "brgreen", "bryellow", "brblue", "brmagenta",
    "brcyan", "brwhite",
)
NAMED_RE = re.compile(
    r"(?:^|\s|=)(?:--background=)?(" + "|".join(NAMED) + r")\b",
    re.MULTILINE,
)

# Where to look for colour names. Deliberately narrow: "red" and "white" turn up
# in prose and in variable names constantly, so scanning the whole repo would
# produce endless false positives. These are the formats where such a name is
# unambiguously an applied colour.
NAMED_SCOPE = (".config/fish/", ".config/starship.toml")

# Hex with no "#". swaylock writes "ring-color=393835", so the regex above sees
# none of its 28 colours: they went unchecked from the start and happened to be
# right. Scoped to this one file on purpose, because six hex digits without a "#"
# match anything at all elsewhere, a commit hash included.
BARE_HEX_SCOPE = (".config/swaylock/config",)
BARE_HEX = re.compile(r"^[a-z-]*color=([0-9a-fA-F]{6})$", re.MULTILINE)

# Paths that are not part of the live theme: the palette itself is the source rather
# than a consumer, lock files and shell state carry colours nobody chose, and an agent
# worktree is a second copy of the whole repository. That last one matters more than it
# looks: SKIP_FILES below matches an exact relative path, so a decided exception like
# .config/dunst/dunstrc is not skipped in a worktree copy and gets reported as drift.
SKIP_PARTS = (
    ".git/",
    ".claude/worktrees/",
    "lazy-lock.json",
    "fish_variables",
    "scripts/theme/palette.json",
)
SKIP_SUFFIX = (".png", ".jpg", ".jpeg", ".ttf", ".otf", ".woff", ".woff2", ".log", ".pyc")

# Decided exceptions, not forgotten ones. DESIGN-SYSTEM.md is the web-side
# document with its own scale and does not describe the desktop. The dunstrc is
# orphaned on purpose, kept as a reference in case of a switch back from swaync,
# and the decision not to theme it is recorded in docs/MAINTENANCE.md. SETUP.md's
# accent recipe prints a worked example of a ramp that is deliberately not this
# palette, since a recipe with no values in it is what the reader complained
# about; the cost is that the current values it also quotes are unchecked, which
# the recipe says about itself. A check that always fails stops being read, so a
# decided exception leaves the list rather than becoming permanent noise.
SKIP_FILES = (
    "docs/design/DESIGN-SYSTEM.md",
    ".config/dunst/dunstrc",
    "docs/SETUP.md",
)


def strip_comments(text: str) -> str:
    """Strip comments while preserving hex values.

    Needed for the name search: a colour mentioned in prose is not a colour
    applied, and without this the very comment explaining what the old values
    were becomes a finding. The catch is that hex also starts with '#', so the
    cut only happens at a '#' that does not begin a six-digit hex.
    """
    out = []
    for line in text.splitlines():
        i = 0
        while True:
            i = line.find("#", i)
            if i == -1:
                break
            if re.match(r"#[0-9a-fA-F]{6}\b", line[i:]):
                i += 7
                continue
            line = line[:i]
            break
        out.append(line)
    return "\n".join(out)


def palette_colours(p: dict) -> set:
    known = set()
    for shades in p["scales"].values():
        known |= {v.lower() for v in shades.values()}
    for entry in p["alert"].values():
        known |= {v.lower() for v in entry.values()}
    known |= {v.lower() for v in p["ansi16"]}
    known.add(p["focus_ring"].lower())
    for value in p["terminal"].values():
        if isinstance(value, str) and value.startswith("#"):
            known.add(value.lower())
    return known


def check_drift(known: set) -> list:
    problems = []
    for path in sorted(REPO_ROOT.rglob("*")):
        rel = path.relative_to(REPO_ROOT).as_posix()
        if not path.is_file():
            continue
        if any(part in rel for part in SKIP_PARTS) or rel in SKIP_FILES:
            continue
        if path.suffix.lower() in SKIP_SUFFIX:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        # Generated files are covered by the sync check, not by this one.
        if "GENERATED by scripts/theme" in text[:300]:
            continue
        stray = sorted({m.group(0).lower() for m in HEX.finditer(text)} - known)
        if any(rel.startswith(scope) for scope in NAMED_SCOPE):
            code = strip_comments(text)
            stray += sorted({m.group(1) for m in NAMED_RE.finditer(code)})
        if rel in BARE_HEX_SCOPE:
            bare = {"#" + m.group(1).lower() for m in BARE_HEX.finditer(text)}
            stray += sorted(bare - known)
        if stray:
            problems.append((rel, stray))
    return problems


def check_sync(p: dict) -> list:
    stale = []
    for path, expected in gen.generated_files(p).items():
        rel = path.relative_to(REPO_ROOT).as_posix()
        if not path.exists():
            stale.append((rel, "does not exist"))
        elif path.read_text(encoding="utf-8") != expected:
            stale.append((rel, "differs from what the generator would write"))
    return stale


def main() -> int:
    p = gen.load_palette()
    known = palette_colours(p)
    failed = False

    drift = check_drift(known)
    if drift:
        failed = True
        print("Colours outside the palette:\n")
        for rel, stray in drift:
            print(f"  {rel}")
            print(f"      {' '.join(stray)}")
        print()
    else:
        print(f"drift: no colour outside the palette's {len(known)}")

    stale = check_sync(p)
    if stale:
        failed = True
        print("Generated files out of sync (run generate_theme.py):\n")
        for rel, why in stale:
            print(f"  {rel}: {why}")
        print()
    else:
        print(f"sync:  {len(gen.generated_files(p))} generated files match palette.json")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
