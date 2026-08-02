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
    s, a = p["scales"], p["alert"]

    return {
        # Surfaces, in the depth order RICE-GUIDE.md's "Form" section describes:
        # chrome recedes and content advances, so a text view reads as recessed
        # into its window rather than floating on top of it. The terminals are
        # built the same way, which is why their background is the content
        # surface and not the window one.
        #
        # content is also what a scrim takes, being the deepest thing there is.
        "surface": {
            "content": s["void"]["00"],
            "window": s["void"]["10"],
            "raised": s["void"]["20"],
            "floating": s["void"]["30"],
            "overlay": s["void"]["40"],
        },

        # Ink, at the steps the guide's palette table names. bright is "primary
        # foreground, focused text"; emphasis is "emphasis text", which is what
        # a GTK window uses for its body; body is "default terminal foreground,
        # body text". A terminal running one step dimmer than a window is the
        # guide's decision, not an oversight.
        "text": {
            "bright": s["ink"]["0"],
            "emphasis": s["ink"]["1"],
            "body": s["ink"]["2"],
            "muted": s["ink"]["3"],
            "disabled": s["ink"]["4"],
        },

        # Edge is for rules and separators, never for text or fills. dim is the
        # unfocused form: a window that lost focus loses the contrast of its
        # borders rather than their presence.
        #
        # window is a third step and a different axis: RICE-GUIDE.md's palette
        # table gives edge-30 to "unfocused window borders, input outlines",
        # which has to read across a gap against the wallpaper rather than
        # against the surface it sits on. Hyprland's appearance.lua paints the
        # same step and still reaches into the raw palette for it, so this role
        # is what Sway reads and the two are only mirrored by hand.
        "line": {
            "normal": s["edge"]["20"],
            "dim": s["edge"]["10"],
            "window": s["edge"]["30"],
        },

        # Focus is Ice across the whole desktop, and selection is the surface
        # form of it. The foreground pair inverts: text on a selection reads
        # against Ice rather than against void. The unfocused pair steps the
        # background down and the foreground back, so an inactive window keeps
        # its selection visible without competing with the active one.
        "selection": {
            "bg": s["ice"]["600"],
            "fg": s["ink"]["0"],
            "bg_unfocused": s["ice"]["700"],
            "fg_unfocused": s["ink"]["1"],
        },

        # The line form of the accent, for anything drawn as a rule rather than
        # as a filled surface: focus rings, links, active text. visited is the
        # one place Ash appears in the generated half, and it is Ash precisely
        # so that a followed link stops reading as focus.
        # decoration is the one step of Ice no document sustains. Qt and
        # hyprtoolkit both draw their focus decoration a step below the line
        # accent and two above the selection surface, and the only
        # justification on record was the name of a local variable. Two
        # toolkits reading it is the argument for the step existing and not for
        # its value. Named here so the question is visible;
        # changing it is a decision that wants eyes on a screen, and it is
        # written down in docs/TODO.md as exactly that.
        "accent": {
            "line": s["ice"]["300"],
            "decoration": s["ice"]["400"],
            "visited": s["ash"]["300"],
        },

        # Bordeaux is identity rather than focus, and it is spent at two steps.
        # The cursor is bordeaux-300, which RICE-GUIDE.md's terminal table
        # names. The mark is bordeaux-400, which is what the hand-written half
        # already calls "the identity mark" wherever it labels the colour: the
        # fetch titles, bottom's average line, hyprtoolkit's secondary accent.
        # The rest of that half is the shell prompt and the lock screen.
        # docs/SETUP.md, "Two colours get called the accent".
        "identity": {
            "cursor": s["bordeaux"]["300"],
            "mark": s["bordeaux"]["400"],
        },

        # The alert tones, under the palette's own names rather than a second
        # vocabulary of error/warning/success. They are a tuned set that does
        # not come out of the ramps, so these name a tone and not a step.
        "status": {
            "critical": {"fg": a["critical"]["fg"], "bg": a["critical"]["bg"]},
            "caution": {"fg": a["caution"]["fg"], "bg": a["caution"]["bg"]},
            "good": {"fg": a["good"]["fg"], "bg": a["good"]["bg"]},
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
