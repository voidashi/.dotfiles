# Voidashi Rice Guide

*How the Voidashi design identity applies to a Linux desktop.*
*Read this before theming anything in this repository.*

---

## What this document is

The Voidashi design system was written for web and document work. A desktop is a
different medium: no DOM, no cascade, no shared stylesheet, dozens of independent
programs, each with its own config format, each rendering pixels next to the others on
one screen. This guide is the translation layer.

Three documents, three jobs:

| Document | Job |
|---|---|
| `AESTHETIC-DIRECTION.md` | Why the system looks the way it does, sensory references, no values |
| `DESIGN-SYSTEM.md` | The canonical tokens and rules, written for web/document work |
| `RICE-GUIDE.md` (this) | How those tokens and rules become a Linux desktop |

**When they conflict for desktop work, this document wins.** It exists because some
system rules do not survive the medium, and some desktop concerns have no web equivalent.

**Aesthetics are the priority here.** The accessibility apparatus in `DESIGN-SYSTEM.md`
(WCAG conformance tables, the high-contrast alternate mode) does not carry over. Keep
things legible because illegible is ugly, not because a criterion says so.

---

## What carries over, what adapts, what is dropped

| From the system | Status on the desktop |
|---|---|
| Colour palette (all families, all hex values) | **Carries over unchanged**: this is the anchor |
| Warm-neutral darkness (charcoal, not blue-black) | **Carries over**: the single most important rule |
| Sharp geometry, no rounded corners | **Carries over** |
| Restraint: no neon, no glow, no vibrant gradients | **Carries over** |
| Mono type stack | **Carries over**: and becomes dominant |
| Motion: short, no bounce, no overshoot | **Carries over**, with tighter numbers |
| Density modes | **Adapts**: becomes a per-surface property, not a toggle |
| Semantic states + glyphs | **Adapts**: becomes system status + Nerd Font glyphs |
| Surface elevation scale | **Adapts**: maps to desktop layers |
| Identity / Function / Expression contexts | **Dropped**: replaced by role-based assignment |
| Editorial serif voice | **Mostly dropped**: narrow exceptions only |
| 12-column grid, px type scale, 70ch measure | **Dropped**: no equivalent |
| WCAG conformance, high-contrast alternate mode | **Dropped**: not a goal in this medium |

### Why the three contexts are dropped

On the web, one artifact belongs to one context: a portfolio is Identity, a dashboard is
Function. A desktop is all of them at once, permanently, on the same screen. Assigning
contexts per application produces arbitrary lines: is the music player Expression or
Function? Is the terminal Function or Identity?

The desktop is **one continuous surface**. Colour is assigned by **role**, not by
context. See "Role-based colour assignment" below.

---

## Palette

The canonical values. Never introduce a colour that is not derived from these.

### Surfaces: Void

Warm-neutral darkness. If a background reads as blue-black or as "screen at night", it
is wrong.

| Token | Hex | Desktop role |
|---|---|---|
| `void-00` | `#0a0908` | Deepest layer, terminal background, fullscreen apps, root window |
| `void-10` | `#121110` | Bars, panels, docks |
| `void-20` | `#191817` | Popups, menus, notification bodies |
| `void-30` | `#201f1d` | Dialogs, floating windows, launcher input fields |
| `void-40` | `#272625` | Tooltips, topmost transient layers |

### Borders: Edge

| Token | Hex | Desktop role |
|---|---|---|
| `edge-10` | `#1e1d1b` | Internal separators, module dividers |
| `edge-20` | `#2a2927` | Default borders, popups, panels |
| `edge-30` | `#393835` | Unfocused window borders, input outlines |
| `edge-40` | `#4f4d4a` | Emphasis borders, hover |

### Text: Ink

Pure neutral, zero chroma.

| Token | Hex | Desktop role |
|---|---|---|
| `ink-0` | `#e8e8e8` | Primary foreground, focused text, bright terminal white |
| `ink-1` | `#cecece` | Emphasis text |
| `ink-2` | `#b1b1b1` | Default terminal foreground, body text |
| `ink-3` | `#929292` | Secondary text, bar modules at rest |
| `ink-4` | `#6c6c6c` | Metadata, timestamps, disabled |
| `ink-5` | `#4d4d4d` | Decorative only, never carries information |

### Accent families

| Family | 300 | 400 | 500 | 600 | 700 | deep |
|---|---|---|---|---|---|---|
| **Bordeaux**: wine, oxblood | `#c76870` | `#b44955` | `#99303f` | `#7f1f2f` | `#621321` | `#1c0b0c` |
| **Ice**: steel, instrument | `#6aa3c7` | `#498bb2` | `#307399` | `#215b7c` | `#124560` | `#0a141b` |
| **Moss**: patina, lichen | `#6da97d` | `#4e9162` | `#3d784f` | `#2c5f3c` | `#23462d` | `#0b140d` |
| **Ash Violet**: mist | `#a98abc` | `#9270a7` | `#7a598e` | `#614572` | `#493258` | `#150f18` |
| **Bronze**: matte medal | `#bb8f58` | `#a57636` | `#896027` | `#6e4a19` | `#53360a` | `#171008` |

Full 100–900 ramps live in `DESIGN-SYSTEM.md`. On a desktop, levels 300–600 do nearly
all the work: 100–200 are too light for dark surfaces, 800–900 nearly vanish against
them.

### Alert tones

Separate from the identity families on purpose: brighter and more saturated, so
"something needs attention" never reads as "this is branding".

| Token | Hex | Meaning |
|---|---|---|
| `alert-critical` | `#e14b39` | Failure, disconnected, critically low |
| `alert-caution` | `#d89529` | Warning, degraded, low |
| `alert-good` | `#57a26d` | Healthy, connected, complete |
| `alert-neutral` | `#5697bf` | Informational |

### Terminal extension: Verdigris

The palette has no cyan, but ANSI needs one. This family is derived specifically for
terminal slots and stays materially consistent: oxidised copper, verdigris on bronze.

| Token | Hex |
|---|---|
| `verdigris-300` | `#64a9a9` |
| `verdigris-400` | `#459192` |
| `verdigris-500` | `#2b797a` |

Verdigris exists for ANSI slots 6 and 14 and for syntax highlighting. Do not use it as a
UI accent in bars, launchers, or window decorations; those belong to the five identity
families.

---

## ANSI 16-colour mapping

This mapping is canonical and identical across every terminal, TUI, and shell in the
repository. Do not re-derive it per application; inconsistent ANSI is the most visible
way a rice falls apart.

| # | Name | Hex | Source |
|---|---|---|---|
| 0 | black | `#191817` | void-20, lifted off the background so it stays visible |
| 1 | red | `#b44955` | bordeaux-400 |
| 2 | green | `#4e9162` | moss-400 |
| 3 | yellow | `#a57636` | bronze-400 |
| 4 | blue | `#498bb2` | ice-400 |
| 5 | magenta | `#9270a7` | ash-400 |
| 6 | cyan | `#459192` | verdigris-400 |
| 7 | white | `#b1b1b1` | ink-2 |
| 8 | bright black | `#4f4d4a` | edge-40 |
| 9 | bright red | `#e14b39` | alert-critical |
| 10 | bright green | `#6da97d` | moss-300 |
| 11 | bright yellow | `#d89529` | alert-caution |
| 12 | bright blue | `#6aa3c7` | ice-300 |
| 13 | bright magenta | `#a98abc` | ash-300 |
| 14 | bright cyan | `#64a9a9` | verdigris-300 |
| 15 | bright white | `#e8e8e8` | ink-0 |

Plus the non-indexed slots:

| Slot | Hex |
|---|---|
| background | `#0a0908` (void-00) |
| foreground | `#b1b1b1` (ink-2) |
| cursor | `#c76870` (bordeaux-300) |
| cursor text | `#0a0908` |
| selection background | `#215b7c` (ice-600) |
| selection foreground | `#e8e8e8` |

**On slots 9 and 11:** bright red and bright yellow deliberately use the alert tones
rather than lighter identity tones. In a terminal, bright red means *error* and bright
yellow means *warning*, so mapping them to the alert family makes program output
semantically correct with no per-program configuration.

### Colour depth

| Capability | Approach |
|---|---|
| Truecolor (`COLORTERM=truecolor`) | Full palette. Preferred everywhere it is available. |
| 256-colour | Nearest xterm-256 index to each hex. Accept the drift; do not re-pick by eye. |
| 16-colour only | The table above is already the answer. |

Prefer truecolor wherever the program supports it, and make sure the shell configs
export `COLORTERM` so programs detect it. For programs that ship their own theme format,
generate the theme from the table rather than hand-picking approximations.

---

## Role-based colour assignment

This replaces the three-context matrix. Every coloured element on the desktop serves one
of these roles. Same role, same colour, everywhere; that consistency is what makes a
rice feel designed rather than assembled.

| Role | Colour | Examples |
|---|---|---|
| **Focus / active / selected** | Ice | Focused window border, active workspace, selected launcher entry, current tab, cursor line |
| **Identity / primary action** | Bordeaux | Terminal cursor, prompt accent, launcher prompt, power menu, lockscreen accent |
| **Persistent good state** | Moss | Connected, charged, mounted, service running, VCS clean |
| **Media / ambient** | Ash Violet | Music player accents, visualisers, screensaver, wallpaper-adjacent chrome |
| **Rare highlight** | Bronze | Recording indicator, uptime milestones, anything genuinely exceptional |
| **Attention** | Alert tones | Battery low, disk full, urgent notification, failed unit, disconnected |
| **Inert** | Ink / Edge | Everything else, which is most things |

### The accent budget

At rest, with no notifications and nothing urgent, **no more than two accent families should be
visible at once** across the entire screen. Ice for focus plus Bordeaux for identity is
the normal pairing. Everything else stays ink and surface until something happens.

A bar where every module has its own colour is a dashboard, not a rice. Modules sit at
`ink-3` by default; colour is what a module earns by changing state.

### Pairs to avoid

Two prohibitions carry over from the system:

- **Ice + Ash Violet adjacent**: two cold families together push the desktop into a
  cyber register the identity rejects.
- **Ice + Bronze adjacent**: steel and amber compete without hierarchy.

"Adjacent" means visible in the same module group or the same popup, not merely somewhere
on the same screen.

---

## Surface hierarchy

The desktop is a stack of layers. Deeper is darker; each step up gains lightness *and* a
border. Never rely on a shadow alone; most compositors either cannot draw one or draw it
badly over a dark background.

```
wallpaper           ── outside the scale; see "Wallpaper"
  void-00           ── terminals, fullscreen apps, root window
    void-10         ── bars, docks, panels                    + edge-20
      void-20       ── menus, notifications, popups           + edge-20
        void-30     ── dialogs, launcher fields, floating     + edge-30
          void-40   ── tooltips                               + edge-30
```

### Transparency and blur

The system's first principle is material over digital. Heavy transparency and blur are
the most digital effects available on a desktop; they announce a compositor.

- **Bars and panels:** opaque, or at most ~92% opacity.
- **Terminals:** 92% opacity, the same value in every emulator. The number matters less
  than the agreement: a terminal you can read through is a terminal you cannot read, and
  four emulators at three different opacities is the same failure as four different ANSI
  tables.
- **Popups, launchers, notifications:** opaque.
- **Blur:** small, or none. This desktop runs a small blur on the compositor
  (`size=5, passes=1`) behind the terminals' 92%, deliberately, not by default. The rule
  it has to satisfy is that the surface still reads as clearly darker than whatever is
  behind it. A blur radius large enough to notice as an effect is the thing to avoid.

Stone is not translucent. Iron is barely. Neither is this desktop, much.

---

## Typography

The desktop inverts the system's balance: mono is the default voice, not the technical
accent.

| Voice | Face | Where |
|---|---|---|
| **Mono, primary** | Iosevka Extended | Terminals, editors, TUIs, prompts, non-toolkit bar text, anywhere fixed-width helps |
| **Mono, glyphs** | Hack Nerd Font | Surfaces needing Nerd Font icons where Iosevka's glyph coverage falls short |
| **Sans, secondary** | Instrument Sans | GTK/Qt application UI, dialog text, settings windows |
| **Serif, exceptional** | Spectral | Lockscreens, greeters, fetch banners, wallpaper typography. Nowhere else. |

**"Bar modules" means the bar's own rendering**, not a GTK/Qt-toolkit status bar. Waybar
(and anything else built on GTK) is a GTK application first; it uses Instrument Sans per
the GTK/Qt row below, with the previous font kept as a fallback ahead of generic
`monospace`. The mono-primary row applies to bars that render text themselves outside a
toolkit (rare on this desktop).

**Rules:**

- Never use a serif in a bar, launcher, notification, or any dense small-text surface. It
  reads as a mistake at those sizes.
- Nerd Font glyphs are the desktop's equivalent of the system's semantic glyphs: state is
  never communicated by colour alone. A module that turns red also changes its glyph.
- Uppercase with wide letter-spacing is the system's label treatment and suits bar module
  labels and workspace names; use it sparingly, not on everything.
- Keep terminal font size consistent across every emulator in the repo. Different sizes
  in different emulators is the same failure as different ANSI.

---

## Form

- **Radius is decided by whether a surface floats.** A surface that floats over other
  content (a window, a launcher, a notification, a menu, a dialog) takes **4px**. A
  surface docked to a screen edge, the bar above all, takes **0**. The distinction is
  physical, not decorative: a floating thing has an edge you can see all the way round,
  and at 4px that edge reads as *cut*, which is the identity. A docked thing has no such
  edge to soften, and rounding one corner of something flush to the screen only makes it
  look like it slipped.
- **4px is the ceiling, and it is not a scale.** There is no 8px, no 12px, no per-surface
  tuning. Two values exist, 4 and 0, and which one applies is answered by the question
  above, not by taste. Anything larger reads as moulded rather than cut and belongs to a
  different design language.
- Where a toolkit refuses both values, accept its minimum rather than fighting it.
- **The values live in `scripts/theme/palette.json`** under `geometry`, alongside the UI
  font weight. GTK3 (waybar, wofi, wlogout) has no CSS custom properties, so those
  stylesheets carry the literal with a comment pointing back; GTK4 (swaync) and Hyprland
  read it. Change it there, not in an app.
- **Borders over shadows.** A 1px `edge-*` border is the separation mechanism.
- **Window gaps:** even, and derived from the spacing scale: 4, 8, 12, 16, 24. Inner and
  outer gaps may differ; both come from the scale.
- **Border widths:** 1px for panel and popup chrome; 2px for focused window borders where
  the compositor supports separate widths. Unfocused uses `edge-30`, focused uses Ice.

---

## Motion

Compositor animations are the desktop's motion layer. A window manager animation is felt
dozens of times an hour, so it has to stay short, but a full window crossing the screen
is not a button changing colour, and web-tight numbers read as abrupt at that size. These
are the durations actually in use.

| Interaction | Duration | Curve |
|---|---|---|
| Window open / close | 300 ms | ease-out |
| Workspace switch | 350 ms | ease-out or a standard cubic curve |
| Bar / popup reveal | 200 ms | ease-out |
| Hover, focus change | 150 ms | ease-out |
| Notification enter | 180–220 ms | ease-out |

The ceiling is roughly 400 ms. Past that an animation stops being feedback and starts
being something you wait for, which is exactly what these values replaced.

**Never:** bounce, spring, overshoot, elastic, wobbly windows, or any curve that returns
past its endpoint. The system does not bounce.

**Never:** infinite loops on anything that is not a loader or a genuine progress state.
No pulsing bar modules, no breathing borders, no animated wallpapers as ambience.

If a compositor's defaults include overshoot, replace the curves rather than disabling
animation entirely.

---

## Density

On the web, density is a toggle. On a desktop it is a property of each surface, chosen
once and kept consistent.

| Density | Surfaces |
|---|---|
| **Compact** | Bars, system monitors, TUIs, tables, anything showing many values at once |
| **Standard** | Launchers, notifications, menus, dialogs |
| **Spacious** | Lockscreens, greeters, fetch output, wallpaper-adjacent surfaces |

Padding comes from the spacing scale: 4, 8, 12, 16, 24, 32, 48, 64. Compact surfaces live
in the 4–12 range, standard in 12–24, spacious in 24–64.

---

## Wallpaper

The wallpaper is the largest single surface on the desktop and the easiest place to undo
everything else.

- Must sit at or below `void-00` in perceived lightness. A wallpaper brighter than the
  darkest UI surface inverts the whole hierarchy.
- Warm-neutral or neutral. No blue cast, no teal-and-orange grading, no synthwave.
- Heavily desaturated. Stone, charcoal, fog, weathered wood, film grain, architecture,
  long-exposure landscape.
- Abstract or textural is safer than representational; a photograph with a clear subject
  competes with the interface in front of it.
- Solid `void-00` is always legitimate, and often the strongest choice.
- Never: neon, glow, vibrant gradients, saturated primaries.

If an image needs treatment to comply, the photography rules in `AESTHETIC-DIRECTION.md`
apply: heavy desaturation, neutral temperature, slightly warm shadows, faintly cool
highlights.

---

## Working rules

How to make changes here without eroding the system. These are the rules that
theming this desktop actually taught, and each one is here because breaking it cost
something.

**Single source of truth.** Colour values live in this palette. When theming an
application, derive from the tables above; never sample a hex from another config file,
and never carry a colour over from an upstream theme.

**Never invent a colour.** If a program needs a role this document does not cover, use
the nearest existing token and say so. If a genuinely new value seems necessary, stop and
ask rather than deriving one silently. One improvised hex becomes the source of the next.

**Preserve behaviour when retheming.** A theming change touches colours, fonts, padding,
borders, radii. It does not change keybindings, module ordering, scripts, or functional
options. If a functional change seems required to reach a visual goal, raise it
separately.

**Check the class, not just the file.** After theming one terminal, the others must match:
same ANSI, same font size, same padding, same cursor. Same for every bar, launcher, and
notification daemon in the repo.

**Respect each format.** Use the application's own idioms: its native colour syntax, its
include mechanism, its comment style. Do not restructure a config to resemble another.

**Comment the mapping, not the value.** `# ice-400, focus` is useful; `# blue` is not. A
future reader needs to know which role a colour is serving.

**State what you assumed.** This guide deliberately leaves most per-application decisions
open. Make the call, then write it down in one line, in a comment beside the value or in
the commit message, so a later reader can tell a decision from an accident.

**When in doubt, remove.** A module carrying no information, a colour marking nothing, a
separator between things already separated; cut it.

---

## Application classes

Principle-level guidance by category. Specific programs come and go; these categories
persist. Nothing here dictates a particular configuration; those decisions belong to
whoever is doing the work.

**Terminal emulators.** ANSI table verbatim, identical across all of them. Opaque
background, Bordeaux cursor, padding from the spacing scale and matched between
emulators.

**Shell and prompt.** The prompt is the most-seen typography on the machine. Ink for the
path, Bordeaux as the identity mark, Moss and alert tones for VCS and exit status. Keep
it short; restraint applies to text as much as to pixels.

**Bars and panels.** `void-10`, an `edge-20` edge border, compact density. Modules at
`ink-3` at rest; colour only on state change, always with a glyph. Separators from
`edge-10`, or none at all.

**Launchers and menus.** `void-20` or `void-30` surface, `edge-20` border, sharp corners,
standard density. Selected entry in Ice, prompt in Bordeaux, input field one step lighter
than the list.

**Notifications.** `void-20`, bordered, standard density. Urgency maps to the alert tones
plus a glyph: low is inert ink, normal gets a subtle accent, critical gets
`alert-critical` and a border in the same family.

**Window manager and compositor.** Focused border Ice, unfocused `edge-30`, gaps from the
scale, animations per the motion table. Windows float, so they take the 4px radius; the
small blur is permitted here and nowhere else; see "Form" and "Transparency and blur".
No shadow theatrics.

**Lockscreen, greeter, fetch.** The one place the editorial voice is welcome: Spectral,
spacious density, minimal information. This is the desktop's cover page: an identity
surface, not a functional one.

**System monitors and TUIs.** Compact density, ANSI-derived colours, tabular alignment.
Graphs and gauges use Ice for normal ranges and alert tones for thresholds, never a
rainbow ramp.

**Editors and syntax themes.** Ink for text, the five identity families plus Verdigris
for syntax categories, `void-00` background, Ice for selection and cursor line. Comments
at `ink-4`: visible, recessive.

**GTK / Qt application theming.** Instrument Sans for UI text at **weight 500**, palette
surfaces mapped to the toolkit's layer names, the radius rule from "Form". Regular weight
optically erodes on surfaces this dark; the stroke thins out and small labels start to
look washed rather than quiet, which is a different thing from restraint. Expect imperfect
control: get background, foreground, and accent right, accept the rest.

---

## Anti-patterns

- Blue-black backgrounds. The darkness is charcoal; this is the fastest way to break the
  identity.
- Neon, glow, saturated gradients, RGB effects of any kind.
- More than two accent families visible at rest.
- Every bar module a different colour.
- Any radius other than the two the system has: 4px on a floating surface, 0 when docked.
- Heavy transparency, or a blur wide enough to notice as an effect.
- Bounce, spring, or overshoot animation; infinite loops outside loaders.
- Inconsistent ANSI, font sizes, or padding between programs of the same class.
- Serif type in bars, launchers, or notifications.
- Bright, saturated, or blue-cast wallpapers.
- State communicated by colour with no accompanying glyph.
- Colours carried in from an upstream theme instead of derived from the palette.
- A hex value that appears in a config but not in this document.

---

*Voidashi · Rice Guide*
*Companions: `AESTHETIC-DIRECTION.md` (why), `DESIGN-SYSTEM.md` (canonical tokens).*
