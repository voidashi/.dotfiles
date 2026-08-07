# Voidashi Design Identity System

*Personal visual identity system. Technical reference document.*
*Companion to `AESTHETIC-DIRECTION.md`, which defines the why. This defines the what and
the how.*

> **Desktop work:** see `RICE-GUIDE.md`. It translates this system to a Linux desktop and
> overrides this document wherever the two differ for that medium.

---

## Contents

1. [Operating principles](#1--operating-principles)
2. [Colour](#2--colour)
3. [Typography](#3--typography)
4. [Type scale](#4--type-scale)
5. [Spacing](#5--spacing)
6. [Grid](#6--grid)
7. [Surfaces and elevation](#7--surfaces-and-elevation)
8. [Shape and borders](#8--shape-and-borders)
9. [Iconography](#9--iconography)
10. [Photography and image](#10--photography-and-image)
11. [Motion](#11--motion)
12. [Density](#12--density)
13. [Interactive and semantic states](#13--interactive-and-semantic-states)
14. [Numbers](#14--numbers)
15. [Context matrix](#15--context-matrix)
16. [WCAG conformance and high contrast](#16--wcag-conformance-and-high-contrast)
17. [Anti-patterns](#17--anti-patterns)

---

## 1 Operating principles

Decision rules for when the system does not cover a case explicitly.

**P.01 Material over digital.** When in doubt about a visual decision, choose the option
that looks made of material (stone, charcoal, iron, velvet) rather than made of light
(neon, glow, vibrant gradient). The system inhabits neutral-warm darkness, not technical
coldness.

**P.02 Restraint as control.** Fewer elements, more intent in each. Emptiness is
attention space, not absence. Before adding an element, ask what it takes away from the
ones already there.

**P.03 Identity is dark and desaturated; semantics are light and saturated.** This single
rule separates the identity colours (bordeaux, bronze) from the functional states (error,
warning). If a colour needs to demand immediate attention, it is semantic. If it confers
weight and presence, it is identity.

**P.04 Temperature carries meaning.** Warm-organic = identity, achievement, duration.
Cold-immaterial = function, abstract expression. Neutral = mediation (text, slightly warmed
surfaces). A new colour enters the system by declaring its temperature and why.

**P.05 Three voices, never more.** Any composition uses at most three simultaneous
typefaces: one editorial, one functional, one technical. The tension between editorial and
terminal is part of the identity, but tension between three voices is composition; between
five it is noise.

**P.06 Accessibility is not negotiable: conformance via alternate version.** The system's
priority is aesthetic; WCAG conformance is guaranteed through the *conforming alternate
version* strategy (a concept from WCAG itself): the default mode may contain deliberate,
documented AA violations, provided the high-contrast mode (`data-contrast="high"`, section
16) resolves all of them. What is never negotiable in any mode: visible focus,
`prefers-reduced-motion`, and meaning never conveyed by colour alone.

---

## 2 Colour

The whole palette was generated in OKLCH for perceptual uniformity between steps and
converted to sRGB. Contrast verified against WCAG 2.1.

### 2.1 Void (surfaces)

The base darkness. Subtle neutral-warm undertone (chroma 0.0035, OKLCH hue 75), charcoal,
not monitor. The progression feels like depths of the same material.

| Token | Hex | Use |
|---|---|---|
| `--void-00` | `#0a0908` | Canvas, page background |
| `--void-10` | `#121110` | Cards, panels |
| `--void-20` | `#191817` | Elevated elements, surface hover |
| `--void-30` | `#201f1d` | Modals, drawers |
| `--void-40` | `#272625` | Tooltips, topmost layer |

### 2.2 Edge (borders and dividers)

Same thermal family as void, one step up in lightness.

| Token | Hex | Use |
|---|---|---|
| `--edge-10` | `#1e1d1b` | Subtle dividers, internal rules |
| `--edge-20` | `#2a2927` | Default borders for cards and sections |
| `--edge-30` | `#393835` | Input borders, interactive elements |
| `--edge-40` | `#4f4d4a` | Emphasis borders, hover |

### 2.3 Ink (text)

Pure neutral, zero chroma. Text is the system's mediator, and a mediator has no
temperature.

| Token | Hex | Use | Contrast vs void-00 |
|---|---|---|---|
| `--ink-0` | `#e8e8e8` | Titles, maximum emphasis | 16.2:1 |
| `--ink-1` | `#cecece` | Emphasis text | 12.6:1 |
| `--ink-2` | `#b1b1b1` | Default body text | 9.3:1 |
| `--ink-3` | `#929292` | Secondary body, descriptions | 6.4:1 |
| `--ink-4` | `#6c6c6c` | Metadata, labels, min. 14px | 3.8:1 |
| `--ink-5` | `#4d4d4d` | Decorative only, never information | 2.4:1 |

**Rule:** `ink-4` is the floor for informational text (and only at sizes ≥ 14px or weight ≥
500). `ink-5` never carries necessary information.

**WCAG note:** `ink-0`–`ink-3` pass AA 1.4.3 (ink-2 passes AAA). `ink-4` at 3.8:1 is a
**deliberate AA violation**: kept for aesthetic reasons and resolved in high-contrast mode
(section 16), where it rises to 5.8:1.

### 2.4 Bordeaux (identity)

Wine, oxblood, settled blood. Hue ~353°, slightly warm, never cold pink. The colour that
says *I am here*.

| Token | Hex | | Token | Hex |
|---|---|---|---|---|
| `--bordeaux-100` | `#e2afb1` | | `--bordeaux-600` | `#7f1f2f` |
| `--bordeaux-200` | `#d78d91` | | `--bordeaux-700` | `#621321` |
| `--bordeaux-300` | `#c76870` | | `--bordeaux-800` | `#490c17` |
| `--bordeaux-400` | `#b44955` | | `--bordeaux-900` | `#310c11` |
| `--bordeaux-500` | `#99303f` | | `--bordeaux-deep` | `#1c0b0c` |

**Identity levels:** 400–700. The light steps (100–200) are rare tints, never primary use;
at high values red inevitably turns pink.
**Text on void:** `bordeaux-300` (5.4:1, passes AA 1.4.3 for normal text); `bordeaux-400`
(3.8:1) only for large text or UI, conforming for large text, where AA requires 3:1.
**`-deep`:** background tint for blocks with identity presence.

### 2.5 Ice (function)

Steel, instrument, precision. Hue ~205°, restrained chroma, never sky blue, never startup
blue.

| Token | Hex | | Token | Hex |
|---|---|---|---|---|
| `--ice-100` | `#b6d2e5` | | `--ice-600` | `#215b7c` |
| `--ice-200` | `#90bbd6` | | `--ice-700` | `#124560` |
| `--ice-300` | `#6aa3c7` | | `--ice-800` | `#113144` |
| `--ice-400` | `#498bb2` | | `--ice-900` | `#0a2230` |
| `--ice-500` | `#307399` | | `--ice-deep` | `#0a141b` |

**Use:** links, functional actions, syntax highlighting, dashboards, interactive UI.
Functional coldness, instruments are cold because they have no feeling; they have function.

### 2.6 Ash Violet (expression)

Mist, the immaterial. The only intentionally cold family by meaning, violet belongs to the
cold-spiritual.

| Token | Hex | | Token | Hex |
|---|---|---|---|---|
| `--ash-100` | `#d3c4de` | | `--ash-600` | `#614572` |
| `--ash-200` | `#bea7cd` | | `--ash-700` | `#493258` |
| `--ash-300` | `#a98abc` | | `--ash-800` | `#34243d` |
| `--ash-400` | `#9270a7` | | `--ash-900` | `#23172a` |
| `--ash-500` | `#7a598e` | | `--ash-deep` | `#150f18` |

**Use:** art, poetry, music, philosophy, non-technical expression. Never in functional UI.

### 2.7 Moss (duration)

Moss on stone, patina, lichen. Desaturated neutral-warm green; it carries *duration*:
something that was done and stayed.

| Token | Hex | | Token | Hex |
|---|---|---|---|---|
| `--moss-100` | `#b3d4bb` | | `--moss-600` | `#2c5f3c` |
| `--moss-200` | `#90be9b` | | `--moss-700` | `#23462d` |
| `--moss-300` | `#6da97d` | | `--moss-800` | `#16321f` |
| `--moss-400` | `#4e9162` | | `--moss-900` | `#0d2213` |
| `--moss-500` | `#3d784f` | | `--moss-deep` | `#0b140d` |

**Saturation floor:** levels 300–400 keep enough chroma to read unambiguously as green in
8px elements on dark backgrounds. When adjusting these levels in future, that is the test: an
8px dot in `moss-400` on `void-00` must be green without ambiguity. The poetry of
desaturation applies to the deep tones (600–900); the working tones must function first.

**Use:** progress, completion, finished projects, persistent positive state.

### 2.8 Bronze (achievement)

Matte medal, bronze patina, dark amber. Warm by nature.

| Token | Hex | | Token | Hex |
|---|---|---|---|---|
| `--bronze-100` | `#e3c5a0` | | `--bronze-600` | `#6e4a19` |
| `--bronze-200` | `#d1a978` | | `--bronze-700` | `#53360a` |
| `--bronze-300` | `#bb8f58` | | `--bronze-800` | `#3b270c` |
| `--bronze-400` | `#a57636` | | `--bronze-900` | `#281a06` |
| `--bronze-500` | `#896027` | | `--bronze-deep` | `#171008` |

**Sparse use by semantics, not aesthetics:** bronze marks real achievements and exceptional
milestones. If it appears often, it stops meaning achievement and becomes decoration. Valid
in any context where a genuine milestone exists, including a portfolio, when a project is
truly exceptional.

### 2.9 Semantic states

Their own tones, separated from the identity families by rule P.03: **lighter, more
saturated, temperature shifted**. Bordeaux is settled wine; error is fresh blood. Bronze is
matte patina; warning is lit amber.

| Token | Hex | Glyph | Meaning |
|---|---|---|---|
| `--state-error` | `#e14b39` | `[✗]` | Failure, invalid action, incorrect input |
| `--state-error-bg` | `#200c09` | | |
| `--state-error-border` | `#521710` | | |
| `--state-warning` | `#d89529` | `[!]` | Attention, action with consequence |
| `--state-warning-bg` | `#1b1004` | | |
| `--state-warning-border` | `#482c00` | | |
| `--state-success` | `#57a26d` | `[✓]` | Confirmation, completion |
| `--state-success-bg` | `#0a160d` | | |
| `--state-success-border` | `#12361e` | | |
| `--state-info` | `#5697bf` | `[i]` | Note, neutral information |
| `--state-info-bg` | `#0a141b` | | |
| `--state-info-border` | `#113144` | | |

**Glyphs are mandatory.** Every semantic state carries its glyph, rendered in a mono
typeface (JetBrains Mono, or the context's equivalent). This resolves accessibility , 
meaning never depends on colour alone, WCAG 1.4.1, and reinforces the technical voice
exactly where it belongs: states are pure function.

**Structural rule:** identity never carries a glyph; semantics always do. The distinction
between "bordeaux as presence" and "red as error" is structural, not merely chromatic.

### 2.10 Temperature map

The map is in [`AESTHETIC-DIRECTION.md`](AESTHETIC-DIRECTION.md), "Temperature: the
general map", which owns it: a temperature is a sensory judgement and carries no value.
It covers every family plus Error and Warning. This document owns what those elements are
worth, in 2.1 to 2.9 above.

### 2.11 Cross-family compatibility

| | Bordeaux | Ice | Ash | Moss | Bronze |
|---|---|---|---|---|---|
| **Bordeaux** | none | ✓ contrast | ✓ artistic mood | ✓ ok | ⚠ rare |
| **Ice** | ✓ contrast | none | ✗ avoid | ✓ ok | ✗ avoid |
| **Ash** | ✓ artistic mood | ✗ avoid | none | ⚠ rare | ⚠ rare |
| **Moss** | ✓ ok | ✓ ok | ⚠ rare | none | ✓ ok |
| **Bronze** | ⚠ rare | ✗ avoid | ⚠ rare | ✓ ok | none |

Ice + Ash do not coexist: two cold families together push the composition into the cyber
register the system rejects. Ice + Bronze do not coexist: steel and amber compete without
clear hierarchy.

---

## 3 Typography

### 3.1 The three voices

The system runs on three voices. Each project picks **one typeface per voice**: never two
faces of the same voice in one composition.

**Editorial voice, Spectral**
Screen serif, weights 200–600. The voice of personal identity, of titles with emotional
weight, of text that matters beyond its content. In italic, it works as a signature.
- Use: identity titles, heroes, long editorial text, quotations.
- Weights: 300 for large display, 400–500 for smaller titles, italic for identity emphasis.
- *Documented alternative:* **Newsreader**: comparable screen quality, slightly warmer
  undertone, aligned with the system's material direction. Valid as a full substitute for
  Spectral if a project calls for more warmth.

**Impact voice, Fraunces** *(subordinate to the editorial)*
Display serif with old letterpress quality. For moments of maximum impact where Spectral is
too restrained: covers, posters, single large-scale titles.
- **Axis restriction:** `SOFT` and `WONK` restrained or zeroed. Drama comes from weight and
  size, not eccentricity, high wonk slides into "crafty cute", which is not the system.
- Fraunces does not replace Spectral in running text or interface titles. It is punctual.

**Functional voice, Instrument Sans**
Discreet sans-serif. Present, reliable, undramatic, the voice that makes everything legible
without competing with the editorial.
- Use: UI body text, documentation, labels, navigation, buttons.
- Weights: 300–400 for body, 500–600 for labels and functional emphasis.

**Technical voice, mono stack**
- **JetBrains Mono**: default for web, code, data, styled metadata.
- **Iosevka Extended**: terminal and local environment.
- **Hack Nerd Font**: terminal where glyph/icon coverage is required.
Interchangeable by platform context, not by aesthetics. Within one environment, only one.

### 3.2 Composition rule

At most three simultaneous voices (P.05). The impact voice (Fraunces) counts as editorial , 
Fraunces and Spectral do not coexist in the same composition.

Default pairing for most projects:
**Spectral (titles) + Instrument Sans (body) + JetBrains Mono (technical/metadata).**

### 3.3 Legacy typefaces

Faces that were once part of the repertoire and remain available for conscious future
adaptations, but sit **outside the active system**: Playfair Display, Cormorant Garamond,
Epilogue, Bricolage Grotesque, Syne, Space Grotesk, Josefin Sans. Using one of them is a
decision to revise the system, not a project-level choice.

---

## 4 Type scale

Modular scale on a 16px base, ratio ~1.25, hand-adjusted at the extremes.

| Token | Size | Line-height | Use |
|---|---|---|---|
| `--ts-xs` | 11px | 1.5 | Metadata, mono labels |
| `--ts-sm` | 13px | 1.6 | Secondary text, captions |
| `--ts-base` | 16px | 1.7 | Default body text |
| `--ts-md` | 18px | 1.65 | Emphasised body, leads |
| `--ts-lg` | 22px | 1.4 | Subheads, card titles |
| `--ts-xl` | 28px | 1.3 | Section titles |
| `--ts-2xl` | 36px | 1.2 | Larger titles |
| `--ts-3xl` | 48px | 1.1 | Page titles |
| `--ts-display` | 64px+ | 1.05 | Heroes, use `clamp()` |

**Rules:**
- Display and large titles in Spectral: negative letter-spacing (-0.02em to -0.04em),
  weight 300.
- Mono labels: positive letter-spacing (0.1em–0.22em), uppercase, xs/sm size.
- Reading measure: maximum 70ch (`--measure-base`), also satisfies WCAG 1.4.8 (AAA, ≤ 80
  characters).
- Responsive heroes: `clamp(3rem, 8vw, var(--ts-display))`.

---

## 5 Spacing

Base-4 scale with hybrid progression (linear early, geometric late).

| Token | Value | | Token | Value |
|---|---|---|---|---|
| `--sp-1` | 4px | | `--sp-6` | 32px |
| `--sp-2` | 8px | | `--sp-7` | 48px |
| `--sp-3` | 12px | | `--sp-8` | 64px |
| `--sp-4` | 16px | | `--sp-9` | 96px |
| `--sp-5` | 24px | | `--sp-10` | 128px |

**Rules:**
- Component inner padding: sp-3 to sp-5.
- Gaps between related elements: sp-2 to sp-4.
- Separation between sections: sp-8 to sp-10.
- Never values outside the scale. If an intermediate value seems necessary, the problem is
  the composition, not the scale.

---

## 6 Grid

### 6.1 Specification

| Parameter | Value |
|---|---|
| Columns (desktop) | 12 |
| Desktop gutter | 24px (`--sp-5`) |
| Mobile gutter | 16px (`--sp-4`) |
| Max-width | 1200px (`--grid-max`) |
| Side padding | `--sp-6` desktop, `--sp-4` mobile |

**Breakpoints:**

| Token | Range | Columns |
|---|---|---|
| xs | < 480px | 4 |
| sm | 480–767px | 4–6 |
| md | 768–1023px | 8 |
| lg | 1024–1279px | 12 |
| xl | ≥ 1280px | 12, increased padding |

**Editorial grid (asymmetric 7-column):** for portfolio, art and long-form, typical split
of 4 content columns + 3 of breathing room. Creates the editorial tension a symmetric grid
lacks.

The values above are the specification; implementing them is plain CSS grid with the
spacing scale as gutters, and nothing about it is particular to this system. The desktop
has no equivalent, so `RICE-GUIDE.md` drops the grid entirely.

---

## 7 Surfaces and elevation

In a dark theme, a black shadow on a dark background disappears. Elevation works through
three simultaneous mechanisms: **lighter surface + more visible border + subtle shadow**.

| Level | Surface | Border | Shadow | Use |
|---|---|---|---|---|
| 0 | `void-00` | none |, | Canvas |
| 1 | `void-10` | `edge-20` | `--shadow-sm` | Cards, panels |
| 2 | `void-20` | `edge-20` | `--shadow-md` | Elevated elements, dropdowns |
| 3 | `void-30` | `edge-30` | `--shadow-lg` | Modals, drawers |
| 4 | `void-40` | `edge-30` | `--shadow-lg` | Tooltips |

```css
--shadow-sm: 0 1px 3px rgba(0,0,0,0.4);
--shadow-md: 0 4px 12px rgba(0,0,0,0.5);
--shadow-lg: 0 8px 32px rgba(0,0,0,0.6);
--shadow-bordeaux: 0 4px 24px rgba(127,31,47,0.25);  /* identity glow, rare */
--shadow-ice: 0 4px 24px rgba(33,91,124,0.25);       /* technical glow, rare */
```

**Rule:** coloured shadows (`-bordeaux`, `-ice`) are punctual identity effects, never
structural elevation.

---

## 8 Shape and borders

The system is built on straight edges, gothic-architectural, without soft curves.

| Token | Value | Use |
|---|---|---|
| `--radius-none` | 0px | **Universal default**: cards, modals, inputs, buttons, images |
| `--radius-micro` | 2px | Interactive elements ≤ 20px: checkboxes, micro-controls |
| `--radius-pill` | 9999px | Pills and tags, exclusively |
| `--radius-round` | 50% | Circular indicators ≤ 12px (state dots) |

**On `--radius-micro`:** in very small elements, 2px is visually identical to 0px but
eliminates the aliasing of straight corners on dark backgrounds and softens the relationship
with the focus ring. Not an aesthetic concession, a rendering correction.

**Forbidden:** any radius between 3px and 9998px. Rounded corners on cards, modals, inputs
or buttons break the system's austerity.

---

## 9 Iconography

The system does not define a proprietary set, it defines criteria any library must meet.

| Criterion | Specification |
|---|---|
| Style | Line, never filled by default |
| Stroke | 1.5px consistent (2px accepted) |
| Corners | Sharp, aligned with the system |
| Base grid | 24px |
| Filled | Only for active/selected states |

**Compatible libraries:** Lucide (preferred), Phosphor Regular, Tabler Icons.
**Incompatible:** Material Icons (rounded), Font Awesome Solid (filled).

**Icon colour:**

| Function | Token |
|---|---|
| Decorative | `ink-4` |
| Informational | `ink-2` / `ink-3` |
| Functional (action) | `ice-400` |
| Identity/brand | `bordeaux-400` |
| State | matching semantic token + glyph when it is a state |

---

## 10 Photography and image

*Detailed editing guide in its own document.*

Photography within this system should feel like a frame from a film that was never graded
to be beautiful, only to be real and specific. The permanent visual reference is Robert
Eggers: not the "Eggers palette" as an abstract concept, but the actual frames of The
Witch, The Lighthouse and The Northman, how light exists in them, how shadows have
texture, how white is not white and black is not black.

Operational summary:

| Parameter | Treatment |
|---|---|
| Saturation | -30% to -50% |
| Contrast | +10% to +20% |
| Temperature | **Neutral**: no global shift toward cold or warm |
| Highlights | Faintest cool touch, haze, not blue |
| Shadows | Slightly warm-grey cast, charcoal, not dark blue |
| Reference | Analogue film photography, high ISO, careful development |

**Absolute rules:**
- Background behind images: always `void-00`, never white.
- Forbidden: app filters in any direction, vibrant warm (social-media vintage) or
  excessively cold (surveillance/blued aesthetic). Both are surface processing, not vision.
- Never vibrant saturation; the image does not compete with the system.
- Black and white: always valid as the stronger editorial option.
- Crop: tight, vertical for portraits, clear centre of attention.

**Optional overlays:** bordeaux 10–15% (identity heroes), ice 5–10% (technical projects),
ash 8–12% (artistic contexts), or no overlay (clean editorial).

---

## 11 Motion

Restrained movement. Every transition has a reason. One well-orchestrated entrance is worth
more than ten scattered micro-interactions.

| Category | Duration | Easing | Use |
|---|---|---|---|
| Micro | 100–150ms | `ease-out` | Hover, focus, colour change |
| Standard | 250–300ms | `cubic-bezier(.4,0,.2,1)` | Modals, panels, toggles |
| Entrance | 400–500ms | `cubic-bezier(.16,1,.3,1)` | Page load, hero, stagger |
| Exit | 150–200ms | `ease-in` | Dismiss, close |

```css
--dur-micro: 120ms;
--dur-standard: 280ms;
--dur-entrance: 450ms;
--dur-exit: 180ms;
--ease-out: ease-out;
--ease-standard: cubic-bezier(.4,0,.2,1);
--ease-entrance: cubic-bezier(.16,1,.3,1);
```

**Rules:**
- Infinite loops only in loaders and waiting states. Never in content or decoration (aligns
  with WCAG 2.2.2, pause, stop, hide).
- No bounce, spring or overshoot > 1.0; the system does not bounce.
- Entrance stagger: 80–100ms delays between elements, maximum 4 elements.

**`prefers-reduced-motion`: mandatory in every project (WCAG 2.3.3):**

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 12 Density

The same identity at three densities, via data-attribute. **The tokens have defaults in
`:root`**: the absence of the attribute produces standard mode, never a broken layout.

```css
:root {
  /* standard is the default, always present */
  --sp-content: var(--sp-5);
  --sp-gap: var(--sp-4);
  --sp-section: var(--sp-9);
}

[data-density="compact"] {
  --sp-content: var(--sp-3);
  --sp-gap: var(--sp-2);
  --sp-section: var(--sp-5);
}

[data-density="spacious"] {
  --sp-content: var(--sp-7);
  --sp-gap: var(--sp-6);
  --sp-section: var(--sp-10);
}
```

| Mode | Use |
|---|---|
| `compact` | Terminal, dense tables, dashboards |
| `standard` | General UI, docs, web apps |
| `spacious` | Portfolio, art, editorial |

`data-density` coexists with `data-contrast` (section 16), the system's two mode axes
follow the same pattern: attribute on an ancestor, defaults in `:root`.

---

## 13 Interactive and semantic states

### 13.1 Semantic states

Own colours (section 2.9) + mandatory mono glyph. Anatomy of a state indicator:

```
[✗] ERROR    bg: --state-error-bg    border: --state-error-border    text/glyph: --state-error
[!] WARNING  bg: --state-warning-bg  border: --state-warning-border  text/glyph: --state-warning
[✓] SUCCESS  bg: --state-success-bg  border: --state-success-border  text/glyph: --state-success
[i] INFO     bg: --state-info-bg     border: --state-info-border     text/glyph: --state-info
```

The glyph renders in the technical voice (mono) even when the rest of the component uses
the functional voice.

### 13.2 Interactive states

| Token | Value |
|---|---|
| `--focus-ring` | `2px solid var(--ice-300)` |
| `--focus-offset` | `2px` |
| `--active-scale` | `0.98` |
| `--disabled-opacity` | `0.38` + `cursor: not-allowed` |

**Focus ring in `ice-300`** (7.3:1 on void-00): a focus indicator needs separation, not
coherence, it exists to be seen. A 2px offset keeps the ring visually connected to a
straight-edged element. Satisfies WCAG 2.4.7 (focus visible) and 1.4.11 (non-text contrast
≥ 3:1) in all modes.

**WCAG note:** input borders in `edge-30` (1.6:1 on void-10) are a **deliberate violation of
1.4.11**: kept for the aesthetic discretion of surfaces and resolved in high-contrast mode
(section 16).

**Rules:**
- Never `outline: none` without a substitute (WCAG 2.4.7).
- Loading: skeleton with opacity pulse (0.4 → 0.7). Never a coloured spinner.
- Surface hover: one step up the void scale (`void-10` → `void-20`) plus one step up the
  edge scale.

---

## 14 Numbers

| Context | Treatment |
|---|---|
| Running editorial text | Proportional; they flow with the text |
| Tables, data, dashboards | Tabular, columns align |
| Prices, metrics, dates in UI | Tabular, JetBrains Mono preferred |

**Implementation, use the high-level property:**

```css
.tabular { font-variant-numeric: tabular-nums; }
```

`font-variant-numeric` enables tabular figures only, without overriding the font's other
OpenType features (`font-feature-settings` is low-level and cancels kerning and ligatures
when declared). Spectral and Instrument Sans support both sets.

---

## 15 Context matrix

Three macro-contexts, defined by the **nature of the content** rather than by platform. A
project identifies its context and takes that family as its lead colour:

| Context | What it covers | Lead colour |
|---|---|---|
| **Identity** | Personal branding, portfolio, CV, profiles | **Bordeaux**, with Ice on technical elements and Ash on artistic ones |
| **Function** | UI, web apps, documentation, dashboards, notes | **Ice**, with Bordeaux only for primary actions, critical warnings and the signature |
| **Expression** | Art, poetry, music, covers, worldbuilding | **Ash Violet**, with Bordeaux for emotional emphasis. Ice is forbidden here: functional coldness does not belong to expression |

The lead family carries roughly three quarters of the coloured surface and the support
families the rest. Hybrid work leads with the dominant context and admits the other inside
contained elements, as a portfolio leads Bordeaux and uses Ice only within the cards for
technical projects.

> **Not applicable to desktop work.** A desktop is all three contexts at once, permanently,
> on one screen, which makes every per-application assignment arbitrary. `RICE-GUIDE.md`
> replaces this matrix with role-based colour assignment. This section is a summary for that
> reason, and the git history holds the per-parameter tables it used to carry.

---

## 16 WCAG conformance and high contrast

The system's priority is aesthetic. Conformance is reached through the strategy WCAG itself
provides, a **conforming alternate version**: the default mode privileges identity and admits
deliberate AA violations, named below and never accidental, while a high-contrast mode
(`data-contrast="high"`, an official mode of the system alongside `data-density` and
orthogonal to it) resolves all of them. Hues never change in that mode; only lightness rises
where needed, so the identity survives.

Two violations are on the list, and nothing else joins it without a measurement and a reason:
`ink-4` as informational text, at 3.8:1 against a required 4.5:1, because recessed metadata
is the point of a fading hierarchy; and input borders at `edge-30`, at 1.6:1 against a
required 3:1, because those borders are meant to whisper.

Three things are never negotiable in any mode: a visible focus ring, honouring
`prefers-reduced-motion`, and meaning never carried by colour alone.

> **Not applicable to desktop work.** In the rice, aesthetics take precedence and this
> apparatus is dropped, as `RICE-GUIDE.md` states outright. This section is a summary for
> that reason: the conformance tables and the high-contrast overrides it used to carry are
> web mechanisms with no desktop equivalent. The git history holds the full text.

---

## 17 Anti-patterns

What the system **does not** do, regardless of context:

**Colour**
- Blueing the darkness. Void is charcoal; if the background looks like "a screen at night",
  it is wrong.
- Using bordeaux for error or bronze for warning. Identity ≠ semantics (P.03).
- Ice + Ash in the same composition (cyber register). Ice + Bronze (competition without
  hierarchy).
- More than two accent families visible simultaneously in one view.
- Neon, saturated glow, vibrant gradients of any kind.

**Typography**
- More than three voices in a composition. Fraunces + Spectral together.
- Fraunces with high wonk/soft.
- Informational text below `ink-4`, or `ink-4` below 14px.
- Display serif in dense functional UI.

**Shape and surface**
- Border-radius between 3px and 9998px.
- Black box-shadow as the only elevation mechanism.
- Pure white (`#ffffff`) on any surface or text.

**Motion**
- Infinite loops outside loaders.
- Bounce, spring, overshoot.
- Animation without `prefers-reduced-motion`.

**Semantics and accessibility**
- Meaning conveyed by colour alone, without glyph or text.
- `outline: none` without a substitute focus ring.
- A semantic state without its glyph.
- A WCAG violation not named in section 16, deliberate is named; accidental is a bug.
- A project with no access to high-contrast mode (toggle or `prefers-contrast: more`).

**Image**
- App filters at any temperature, warm vintage or cold surveillance.
- White background behind images.
- Vibrant saturation competing with the system.

---

*Voidashi · Design Identity System*
*Companions: `AESTHETIC-DIRECTION.md` (why), `RICE-GUIDE.md` (desktop translation).*
