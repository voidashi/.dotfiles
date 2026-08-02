#!/usr/bin/env python3
"""What each colour means, between the raw palette and the files that use it.

palette.json holds values. This holds decisions: the window chrome is void-10,
selection is Ice everywhere, the cursor carries the identity colour. The
emitters in generate_theme.py read from here rather than reaching into a scale,
so a decision is written once and every toolkit follows the same one.

Hand-written, not generated, for the reason the editor's own layer gives in
.config/nvim/lua/voidashi/theme/roles.lua: this is where colour mixes with
design decision, and the rationale belongs beside the choice it explains. The
desktop now has the three layers the editor already had, palette then roles
then output.

The names follow docs/design/RICE-GUIDE.md's vocabulary rather than a new one.
"Body text" and "emphasis text" are its words, and the two are different steps
of Ink: a terminal runs its text one step dimmer than a GTK window does, which
reads as a mistake until you see it written down.

Two things deliberately do not pass through here. ansi16 is a canonical table
the terminals consume raw, because slot 1 is red for reasons that have nothing
to do with what this desktop's identity colour happens to be; docs/SETUP.md,
"The keys", is where that is settled. geometry and typography are values with
no decision to add.

Every value here must be a colour palette.json already holds. validate()
refuses anything else, so a hex pasted in by hand cannot quietly become a
second source of truth, which is the failure this layer exists to end.
"""


def build(p: dict) -> dict:
    """The semantic layer, as section -> role -> colour."""
    s = p["scales"]

    return {
        # Surfaces, in the depth order RICE-GUIDE.md's "Form" section describes:
        # chrome recedes and content advances, so a text view reads as recessed
        # into its window rather than floating on top of it. The terminals are
        # built the same way, which is why their background is the content
        # surface and not the window one.
        "surface": {
            "content": s["void"]["00"],
        },

        # Ink, at the three steps the guide's palette table names. bright is
        # "primary foreground, focused text"; emphasis is "emphasis text", which
        # is what a GTK window uses for its body; body is "default terminal
        # foreground, body text".
        "text": {
            "bright": s["ink"]["0"],
            "body": s["ink"]["2"],
        },

        # Focus is Ice across the whole desktop, and selection is the surface
        # form of it. The foreground pair inverts: text on a selection reads
        # against Ice rather than against void.
        "selection": {
            "bg": s["ice"]["600"],
            "fg": s["ink"]["0"],
        },

        # The line form of the accent, for anything drawn as a rule rather than
        # as a filled surface: focus rings, links, active text.
        "accent": {
            "line": s["ice"]["300"],
        },

        # Bordeaux is identity rather than focus. The terminal cursor is the
        # one place the identity colour appears in the generated half; the rest
        # of it is the shell prompt, the lock screen and the fetch banners, all
        # hand-written. docs/SETUP.md, "Two colours get called the accent".
        "identity": {
            "cursor": s["bordeaux"]["300"],
        },
    }


def leaves(node: dict, prefix: str = ""):
    """Every role as (dotted name, colour), whatever depth a section has."""
    for name, value in node.items():
        path = f"{prefix}{name}"
        if isinstance(value, dict):
            yield from leaves(value, f"{path}.")
        else:
            yield path, value


def validate(p: dict, r: dict) -> None:
    """Refuse a role holding a colour palette.json does not hold.

    This is the whole contract of the layer. A role names a token; the moment
    one carries a value of its own, the palette has a second source of truth
    and moving a ramp stops moving the desktop, which is the bug this file was
    written to end. It catches a hex pasted in by hand and it catches a token
    reference that was mistyped into some other valid colour, because both come
    out the same way here: a value that is not in the palette.

    Cheap enough to run on every load, and it runs there rather than in
    check_palette.py so that generating with a broken layer is impossible
    rather than merely reported.
    """
    known = set()
    for shades in p["scales"].values():
        known |= set(shades.values())
    for entry in p["alert"].values():
        known |= {entry[key] for key in ("fg", "bg", "border")}

    bad = [f"{name} = {value!r}" for name, value in leaves(r) if value not in known]
    if bad:
        raise SystemExit(
            "roles.py: these are not colours palette.json holds:\n  "
            + "\n  ".join(bad)
        )
