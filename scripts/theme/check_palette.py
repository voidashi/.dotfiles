#!/usr/bin/env python3
"""Prove the rice has not drifted off the palette.

RICE-GUIDE.md has a non-negotiable, "never invent a colour", which used to be
an honour-system rule. Several files carry hand-pasted hex because colour mixes
with structural config in them (swaylock, bottom, fastfetch, catnap, fish,
yazi and Neovim's roles layer), and nothing said so when one of them aged
out of step with palette.json.

Three checks and a warning:

  drift    a colour in a tracked config that palette.json does not contain, in
           any of the forms colour is written here rather than only "#rrggbb"
  sync     a generated file that differs from what the generator would write
           now, or a merged file whose owned sections a second merge would
           change, both of which mean someone edited the output not the source.
           The merged INI files are compared by section and key rather than by
           text, because KDE rewrites them in its own order
  names    a starship style naming a colour its generated palette table does
           not define, which renders that one segment uncoloured and says
           nothing. Measured: with 'ink-2' misspelt, the path lost its escape
           sequence while every other segment kept its own
  ansi     an ansi16 slot holding a hex no scale or alert tone holds, which is
           a retired colour still inside the palette and therefore invisible to
           drift. A warning, since a half-finished hue swap looks like this

Usage:
    python3 scripts/theme/check_palette.py

Exits 1 if any check fails, so it can be wired into a hook. The warning does
not affect the exit code.
"""
import json
import re
import subprocess
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
# The optional quote is not decoration. Without it the name had to be preceded
# by a line start, whitespace or "=", so in starship.toml "style = 'red'" passed
# and "style = 'bold red'" was reported, separated by one space and by which of
# them the quote sat against.
NAMED_RE = re.compile(
    r"(?:^|\s|=)['\"]?(?:--background=)?(" + "|".join(NAMED) + r")\b",
    re.MULTILINE,
)

# Where to look for colour names. Deliberately narrow: "red" and "white" turn up
# in prose and in variable names constantly, so scanning the whole repo would
# produce endless false positives. These are the formats where such a name is
# unambiguously an applied colour.
NAMED_SCOPE = (".config/fish/", ".config/starship.toml")

KDEGLOBALS = ".config/kdeglobals"


def from_hex(m) -> str:
    # Group 1 is RRGGBB. hyprland's rgba() carries two more digits, which are
    # opacity rather than colour and are not in the palette.
    return "#" + m.group(1).lower()


def from_decimal(m) -> str:
    return "#%02x%02x%02x" % tuple(int(g) for g in m.groups())


# Colour is not always written "#rrggbb", and every other form it takes here was
# outside this check until someone measured it. An auditor replaced hyprtoolkit's
# accent_secondary with rgb(ff00ff), the identity mark of the whole rice, and the
# run printed "no colour outside the palette" and exited 0.
#
# Each entry is (scope, pattern, convert): where the form is unambiguously an
# applied colour, what finds it, and how to turn a match into #rrggbb. Scope is
# what keeps this from crying wolf, since six hex digits and a decimal triple
# both match plenty of things that are not colours. Documentation sits outside
# every scope on purpose: docs/TODO.md quotes rgb(ff00ff) as a sentinel and must
# not be reported for saying so.
FORMS = (
    # swaylock writes "ring-color=393835", so the hex regex above sees none of
    # its colours: they went unchecked from the start and happened to be right.
    # Coverage here is complete, 29 colour lines and 29 matched.
    ((".config/swaylock/config",),
     re.compile(r"^[a-z-]*color=([0-9a-fA-F]{6})$", re.MULTILINE), from_hex),
    # fish takes the same bare hex, in "set -g fish_color_command 498bb2" and in
    # "--background=215b7c". A bare token counts as colour only inside this tree,
    # because six hex digits anywhere else are as likely to be a commit hash.
    ((".config/fish/",),
     re.compile(r"\b([0-9a-fA-F]{6})\b"), from_hex),
    # hyprland's own form: rgb(RRGGBB) and rgba(RRGGBBAA).
    ((".config/hypr/",),
     re.compile(r"rgba?\(([0-9a-fA-F]{6})(?:[0-9a-fA-F]{2})?\)"), from_hex),
    # CSS, where the same function takes decimals instead. swaync and wlogout
    # write every colour this way while the other stylesheets here use hex.
    ((".config/",),
     re.compile(r"rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*[,)]"),
     from_decimal),
    # kdeglobals, where a colour is a bare decimal triple and nothing else in
    # the file is shaped like one.
    ((KDEGLOBALS,),
     re.compile(r"^[A-Za-z][\w ]*=(\d{1,3}),(\d{1,3}),(\d{1,3})$", re.MULTILINE),
     from_decimal),
)

# Files that are not part of the live theme: the palette itself is the source rather
# than a consumer, and a lock file and shell state carry colours nobody chose. These
# are content exceptions. Scope exceptions used to live here too, .git/ and an agent
# worktree, and git answers both without an entry, which is why the walk below asks
# it rather than the filesystem.
SKIP_PARTS = (
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


LUA_COMMENT = re.compile(r"--[^\n]*")
CSS_COMMENT = re.compile(r"/\*.*?\*/", re.DOTALL)


def drop_ini_sections(text: str, prefix: str) -> str:
    out, keep = [], True
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            keep = not stripped[1:-1].startswith(prefix)
        if keep:
            out.append(line)
    return "\n".join(out)


def applied_text(rel: str, text: str) -> str:
    """The part of a file where a colour is a colour someone chose.

    Comments come out. Both lua files under .config/hypr/ record the Kanagawa
    values they replaced, so reading a comment as applied colour would report
    three findings that are the opposite of drift, and a check that always fails
    stops being read. Which marker to cut at follows the language rather than
    the path.

    kdeglobals also loses its [ColorEffects:*] sections, which carry Breeze's
    fade values on purpose and are never palette colours. generate_theme.py says
    why beside the lines that write them.
    """
    if rel.endswith(".lua"):
        text = LUA_COMMENT.sub("", text)
    elif rel.endswith(".css"):
        text = CSS_COMMENT.sub("", text)
    else:
        text = strip_comments(text)
    if rel == KDEGLOBALS:
        text = drop_ini_sections(text, "ColorEffects:")
    return text


def palette_colours(p: dict) -> set:
    known = set()
    for shades in p["scales"].values():
        known |= {v.lower() for v in shades.values()}
    for entry in p["alert"].values():
        # fg, bg and border only. Taking every value swept in the four glyph
        # strings, so the count this script prints claimed four more colours
        # than the palette has.
        known |= {v.lower() for v in entry.values() if v.startswith("#")}
    known |= {v.lower() for v in p["ansi16"]}
    # Roles are not unioned in, and must not be: roles.validate() refuses one
    # that is not already a scale or an alert tone, so adding them here would
    # be a no-op that reads like coverage. If that ever stops being true, this
    # check is not the place to find out.
    return known


def listed_files() -> list:
    """Every file git would show you: tracked, plus untracked and not ignored.

    The walk used to be REPO_ROOT.rglob("*") with a SKIP_PARTS entry for each
    directory git already knows to leave alone, .git/ and then an agent
    worktree. Asking git removes that whole class of edit, since .gitignore is
    where an ignored directory is named once.

    --others is not decoration and the first version of this went in without it.
    Tracked-only is the wrong scope for a check whose job is to catch a pasted
    hex before it is committed: measured, a new config carrying an off-palette
    hex was reported by the old walk and passed silently under the index alone
    (the value is not written out here, because this check reads its own source
    and would report the example), and
    CLAUDE.md tells you to run this before calling work done. So the list is
    wider than the index and narrower than the filesystem, which is what the
    docstring's "tracked config" was reaching for.
    """
    try:
        out = subprocess.run(
            ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
            cwd=REPO_ROOT, check=True, capture_output=True, text=True).stdout
    except (OSError, subprocess.CalledProcessError) as exc:
        # An exported tree has no index, and a stack trace is a poor way to say
        # so. verify.sh already requires git; this script is documented as
        # runnable on its own.
        raise SystemExit(f"check_palette needs a git checkout to know what to "
                         f"read: {exc}")
    return sorted(rel for rel in out.split("\0") if rel)


def check_drift(known: set) -> list:
    problems = []
    for rel in listed_files():
        path = REPO_ROOT / rel
        # A path staged for deletion is in the index and not on disk.
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
        code = applied_text(rel, text)
        stray = sorted({m.group(0).lower() for m in HEX.finditer(text)} - known)
        if any(rel.startswith(scope) for scope in NAMED_SCOPE):
            stray += sorted({m.group(1) for m in NAMED_RE.finditer(code)})
        for scope, pattern, convert in FORMS:
            if not any(rel.startswith(s) for s in scope):
                continue
            stray += sorted({convert(m) for m in pattern.finditer(code)} - known)
        if stray:
            problems.append((rel, stray))
    return problems


def check_orphan_roles(p: dict) -> list:
    """An ansi16 slot holding a hex that no scale and no alert tone holds.

    palette_colours() unions every value in the file, so a hex that appears
    twice stays a palette colour while either copy survives, and drift can never
    report a file carrying it. ansi16 is the only place left where that can
    happen: every slot repeats a scale value or an alert tone rather than naming
    it, and it stays that way on purpose, because a program asking for red
    expects red whatever the identity colour is. Measured: moving the bordeaux
    ramp alone and regenerating moved four files and left nineteen tracked files
    on the old accent, at exit 0 throughout.

    The roles used to be here too and are not any more; roles.py names a token,
    so it cannot hold a retired value and there is nothing here to report. This
    is what is left, not what was forgotten.

    A warning and not a failure. A deliberate hue swap puts the palette in this
    state on the way through.
    """
    live = set()
    for shades in p["scales"].values():
        live |= {v.lower() for v in shades.values()}
    for entry in p["alert"].values():
        live |= {entry[key].lower() for key in ("fg", "bg", "border")}
    return [(name, value) for name, value in gen.colour_keys(p)
            if not name.startswith(("scales.", "alert.")) and value.lower() not in live]


STARSHIP = ".config/starship.toml"

# What a starship style token may be besides a colour: its modifiers, and the
# two prefixes that put a colour on the background or the foreground.
STYLE_WORDS = {
    "bold", "italic", "underline", "dimmed", "inverted", "blink", "hidden",
    "strikethrough", "none", "prev_fg", "prev_bg", "",
}
# style = '...' and the markdown form inside a symbol, "[glyph](style)".
STYLE_RE = re.compile(r"^\s*style\s*=\s*['\"]([^'\"]*)['\"]", re.MULTILINE)
INLINE_STYLE_RE = re.compile(r"\]\(([^)]*)\)")
PALETTE_ENTRY_RE = re.compile(r"^([A-Za-z][\w-]*)\s*=\s*['\"]#", re.MULTILINE)


def check_starship_names(p: dict) -> list:
    """A starship style naming a colour its palette table does not define.

    Moving that file from pasted hex onto names traded one failure for another.
    A hex typo was still a colour; a name typo is not, and starship neither
    fails nor warns: the segment renders in the terminal's default while every
    other one stays right, which is this repository's signature bug wearing a
    new hat. Its own warning covers only the whole table going missing.

    The names come out of the generated block rather than from palette.json, so
    what is checked is what starship will actually resolve against.
    """
    path = REPO_ROOT / STARSHIP
    if not path.exists():
        return [(STARSHIP, "does not exist")]
    text = path.read_text(encoding="utf-8")
    known = set(PALETTE_ENTRY_RE.findall(text))
    if not known:
        return [(STARSHIP, "no palette table, so no style in it can resolve")]

    problems = []
    for style in STYLE_RE.findall(text) + INLINE_STYLE_RE.findall(text):
        for token in style.split():
            colour = token.split(":", 1)[-1] if token.startswith(("bg:", "fg:")) else token
            if colour in STYLE_WORDS or colour in known:
                continue
            # A hex or an ANSI index is legal starship and is somebody else's
            # problem: drift is what reports a hex outside the palette.
            if HEX.fullmatch(colour) or colour.isdigit():
                continue
            problems.append((STARSHIP, f"{token!r} in style {style!r}"))
    return problems


# The merged files that are INI, where order carries nothing and a second owner
# rewrites it. KConfig canonicalises kdeglobals whenever any KDE program writes to
# it, sections and keys both alphabetical. That reordering reached the repository
# once, swept into a commit about another file, and the sync check read it as a
# hand-edit because it compared text: measured, same sections and zero key-value
# pairs different. Which files these are is generate_theme.py's to say, not this
# file's; matching by path string here is what would go quiet if one were renamed.
MERGED_INI = gen.MERGED_INI


def check_sync(p: dict) -> list:
    stale = []
    for path, expected in gen.generated_files(p).items():
        rel = path.relative_to(REPO_ROOT).as_posix()
        if not path.exists():
            stale.append((rel, "does not exist"))
        elif path.read_text(encoding="utf-8") != expected:
            stale.append((rel, "differs from what the generator would write"))
    # The files the generator merges into rather than writes whole. This loop
    # iterated generated_files() alone, so a hand-edit to wofi's generated block,
    # to kdeglobals' colour sections or to kcminputrc's cursor keys was reported
    # by nothing: measured, one edit in each, and the checker returned 0 for all
    # three. Merging again and comparing asks the question the right way round,
    # and it borrows the generator's own idea of which sections it owns rather
    # than restating it here, where the two would drift apart.
    for path, merge in gen.merged_files(p).items():
        rel = path.relative_to(REPO_ROOT).as_posix()
        if not path.exists():
            stale.append((rel, "does not exist"))
            continue
        current = path.read_text(encoding="utf-8")
        merged = merge(current)
        if merged == current:
            continue
        if rel in MERGED_INI and gen.ini_pairs(merged) == gen.ini_pairs(current):
            continue
        stale.append((rel, "a section the generator owns has been hand-edited"))
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
        written = len(gen.generated_files(p))
        merged = len(gen.merged_files(p))
        print(f"sync:  {written} generated and {merged} merged files match palette.json")

    unknown = check_starship_names(p)
    if unknown:
        failed = True
        print("starship styles naming a colour its palette does not define:\n")
        for rel, what in unknown:
            print(f"  {rel}: {what}")
        print()
    else:
        print("names: every starship style names a colour its palette defines")

    orphans = check_orphan_roles(p)
    if orphans:
        print("\nWarning, not a failure: an ANSI slot holds a colour no scale or alert "
              "tone does.")
        for name, value in orphans:
            print(f"  {name} = {value}")
        print("  While a second copy of a retired hex survives, that hex is still a "
              "palette\n  colour and no file left on it can be reported. Expected "
              "mid-swap; finish it.")
    else:
        print("ansi:  every ANSI slot is also a scale or alert tone")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
