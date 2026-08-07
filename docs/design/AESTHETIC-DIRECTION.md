# Voidashi Aesthetic Direction

*Orientation document. No values. No tokens. No implementation rules.*
*This describes what the system should feel like, not how to build it.*

---

## What this document is

This precedes every technical decision. Before choosing a colour, a typeface, or a
spacing value, you need to know what temperature the darkness is, what kind of stone the
background is, what material a surface is made of.

Design systems without sensory grounding become arbitrary over time: the rules lose
their reason, and without the reason, exceptions multiply without criteria. This document
exists so that any future decision (colour, type, photography, image treatment,
spacing) can be tested against something concrete: *does this look right? does it belong
to this world?*

Read this before opening an editor. Read it again when a decision feels hard.

---

## The world the system inhabits

The system is not dark mode. Dark mode is an interface preference. The system is a
complete aesthetic, a specific way for darkness to exist.

That darkness has precise physical references. It is not the darkness of a powered-off
monitor, nor of deep space, nor of a 3D render on a black background. It is:

- **Charcoal.** Organic material, old combustion. It holds residual heat even when out.
- **Old stone.** Dark sandstone, basalt, cathedral granite. Neutral, dense, with a texture
  the eye feels without seeing.
- **Wrought iron.** Tempered. Neutral with a touch of warm grey. It does not shine; it
  absorbs.
- **Burnt wood.** After the fire. Not the black of a recent blaze, but of something that
  passed through fire long ago and came out more solid.
- **Dark velvet.** Depth without reflection. It takes light in and does not give it back.

None of these materials is blue. None has a cool undertone. All of them have weight,
presence, and a quality that makes the thing *be there* rather than float on a technical
background.

---

## The right temperature of darkness

This is the most important correction in the document.

Cold is not gothic. Cold is clinical, technical, digital. What reads as gothic in darkness
is **neutral with residual warmth**: the difference between an unlit room and an unlit
stone corridor. The second has presence. The first has absence.

The palette operates in neutral-warm darkness, not cold. That does not mean warm colours.
It means the black has the temperature of charcoal, not of glass.

The conflation of "gothic" with "cold" comes from the cyber-goth aesthetic of the 90s and
2000s: neon blue, blued black, terminal aesthetics. This system is not that. It is older,
more material, heavier. Its aesthetic references (Robert Eggers, Guillermo del Toro,
darkwave and death-adjacent music) share a quality cyber-goth does not have: **organic**.
Something that decayed. Something made by hands.

When in doubt about the temperature of a colour decision, the question is: *does this look
made of material, or made of light?* Material is the way.

---

## The colour families and what each one means sensorially

### The base darkness

Darkness is not neutral in character. It is the ground everything stands on. It should
read as a physical surface that absorbs light, not as a void created by the absence of it.

The progression of surface levels should feel like different depths of the same material:
the wall further away versus the table nearby. Not coats of paint on a digital canvas.
Materially consistent, with perceptible separation that never feels artificial.

The undertone should be **slightly neutral-warm**: not yellow, not brown, but with the
quality of something that has organic density. The darkest stone is not blue. It is almost
black with the temperature of iron.

### Bordeaux: identity, presence, blood

This is the identity colour. It carries the weight of existing with conviction.

Sensorially: dark wine at the bottom of the glass. Old burgundy velvet. Clotted blood.
Oxblood: the English name says everything about what this colour is. Not cold pink, not
magenta, not vibrant red. Red that has lived through something.

The right temperature for bordeaux is **slightly warm, not cold**. The historical gothic
red (cathedral velvet, red wine, blood) leans toward the warm side of the spectrum, not
toward pink. Cold bordeaux reads as tech crimson or app branding. Slightly warm bordeaux
reads as real material.

Where it appears: personal identity, high-impact titles, elements of maximum presence. It
is the colour that says *I am here*.

### Ice: precision, instrument, technique

This is the colour of function. No emotional charge, only operational clarity.

Sensorially: stainless steel. The frosted glass of a measuring instrument. A scope
display. Quartz crystal.

The right temperature for ice is **neutral to slightly cold**: more steel than sky, more
instrument than atmosphere. Baby blue and sky blue are to be avoided; the family should
feel like metallic precision, not like a startup's interface colour.

The coldness here is functional, not decorative. Ice is cold because instruments are
cold: they have no feeling, they have function.

Where it appears: interactive UI, functional links, technical states, syntax highlighting,
dashboards, anything that says *this is how it works*.

### Ash Violet: art, expression, what has no name

This is the colour of what cannot be said directly. The coldest of the palette, by its
own logic.

Sensorially: mist with moonlight passing through. Spilled ink that has almost dried. The
colour of an old bruise. Darkwave lilac, not vibrant, present but distant.

Violet belongs to the cold because it is the colour of the immaterial. Art, poetry, music,
philosophy, things without physical weight but with real weight. The coldness here is not
a mistake: violet belongs to the cold-spiritual side, not the warm-organic one.

Where it appears: contexts of non-technical expression, art, music, philosophy. Never in
functional UI.

### Moss: growth, completion, presence in time

Sensorially: moss on old stone. Something that grew slowly, over a long time. The patina
of aged copper, the colour metal takes on after decades. Lichen on granite. Alive, but
discreet. Persistent.

This is a colour that carries *duration*. Not the excitement of an achievement, but the
solidity of something that was done and stayed. That is why it works for "complete",
"growth" and "progress", both semantically and perceptually.

Its temperature is neutral-warm so it stays in the same material register as the
background and bordeaux, avoiding a palette with two cold function colours that are nearly
indistinguishable in temperature.

Where it appears: success states, progress, completion, finished projects, positive
indicators.

### Bronze: achievement, rarity, the weight of something earned

Sensorially: a real medal. Not shiny gold, but matte bronze with patina. The prize that sat
in a drawer for years and is still there. Dark amber.

Rarity of use is part of the meaning. If bronze appears frequently, it stops feeling like
achievement and starts feeling like decoration. The rule of sparse use is not aesthetic;
it is semantic.

---

## Temperature: the general map

To avoid future ambiguity, the temperature of each element in plain terms. Grouped rather
than sorted: the two neutrals everything else sits on, then the five families, then the
two semantic states. Reading down the temperature column is not a spectrum, and the
paragraph after the table is where the spectrum is described.

| Element | Temperature | Material reference |
|---|---|---|
| Surfaces / Void and Edge | Very subtle neutral-warm | Charcoal, dark stone, iron |
| Text / Ink | Pure neutral | Smoke grey |
| Bordeaux | Slightly warm | Blood, wine, oxblood |
| Bronze | Warm | Matte bronze, amber, medal |
| Moss | Subtle neutral-warm | Moss, patina, lichen |
| Ice | Restrained cold | Steel, instrument, crystal |
| Ash Violet | Cold | Mist, moon, the immaterial |
| Error | Saturated warm | Fresh blood |
| Warning | Light warm | Lit amber |

The spectrum runs from warm-organic (bordeaux, bronze, surfaces) to cold-immaterial (ash
violet, ice), with text as a neutral mediator of reading. This creates real temperature
contrast, something a uniformly cold palette does not have, and that contrast is an
active mechanism of hierarchy rather than an accident to be suppressed.

Error and Warning are on the map because they are the two places where a temperature is
chosen against a family's meaning rather than with it: both are warm because a warning is
urgent, not because they belong to Bordeaux or Bronze. Their values are in
[`DESIGN-SYSTEM.md`](DESIGN-SYSTEM.md), which owns values.

---

## Typography: what each voice should feel like

The system uses at most three simultaneous voices in any project. Not out of a simplicity
rule, but out of coherence of intent. More than three voices in one space is noise, not
tension.

### The editorial voice

A serif with history. It should feel like something printed on good paper and digitised,
not like a system font. It has the elegance of light weight, strokes that carry intent. In
italic, it should feel like a signature, not like technical emphasis.

This voice belongs to titles of personal identity, text with emotional weight, moments
where the word matters beyond its content.

### The functional voice

A sans-serif with discreet character, not generic, but muted enough not to compete with
the editorial. It should feel like a well-calibrated instrument: present, reliable,
without drama. Never the most memorable typeface in a composition, but the one that makes
everything legible.

This voice belongs to body text, interfaces, documentation, anything that must be read
without effort.

### The technical voice

Monospaced. This voice has a double function in the system: real function (code, terminal,
data) and aesthetic function (distance, precision, the world of the terminal). When it
appears outside a genuinely technical context (as a label, as metadata) it creates the
editorial/terminal tension that is part of the identity.

This is the voice that does not belong to the editorial, and that is exactly why it
creates productive friction next to it.

---

## What the system is not, and why it matters

**Not cyberpunk.** Cyberpunk is neon on blued black, high-tech, dystopian future. This
system is material, organic, historical. The difference is the difference between a data
centre and a cathedral.

**Not product dark mode.** Product dark mode (Spotify, GitHub Dark, VS Code) exists to
reduce eye strain. This system exists to create a world with its own character. Product
dark mode is functional. This system is expressive.

**Not dark Scandinavian minimalism.** That is cold, clean, tensionless. This system has
tension: between editorial and technical, between organic and precise. The restraint here
is not serenity; it is control over something that could be chaos.

**Not hacker aesthetics.** The technical voice exists in this system but does not dominate.
The terminal is one of the voices, not the central identity.

---

## Photography and image

Photography is in [`DESIGN-SYSTEM.md`](DESIGN-SYSTEM.md) section 10, which owns it. The
direction is a treatment with numbers behind it (how far to desaturate, how much
contrast, what an overlay is worth), and it is for the web and document work that
document is written for. This repository has no photography in it.

What stays here is the test the treatment answers to, and it is above in "The right
temperature of darkness": does this look made of material, or made of light? An image
fails that test the same way a surface does, and the Eggers reference behind it is the
same reference.

---

## A note on coherence over time

Personal design systems have a problem corporate ones do not: the individual changes. What
feels right now may feel wrong in two years. The system needs to be revised, not preserved.

The purpose of this document is not to fix the aesthetic forever. It is to give language
concrete enough that future revisions are conscious: that a change to the system is a
decision, not a drift.

When something feels wrong in the system, the question is: *did the system change without a
decision, or did I change and the system needs to follow?* Both are valid answers. The
difference is the awareness you bring to the change.

---

*Voidashi · Aesthetic Direction*
*Precedes and informs: `DESIGN-SYSTEM.md`, `RICE-GUIDE.md`, and any future adaptation of
the system.*
