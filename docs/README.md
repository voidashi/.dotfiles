# Documentation

Six documents, each owning one question. When two of them seem to disagree, each
is authoritative only on the question it owns, and the mismatch is a bug in the
document rather than something to work around.

| Document | Answers |
|---|---|
| [`design/RICE-GUIDE.md`](design/RICE-GUIDE.md) | How the identity becomes a Linux desktop: the palette, the ANSI table, the rules for assigning colour. Read this before changing anything visual. |
| [`design/AESTHETIC-DIRECTION.md`](design/AESTHETIC-DIRECTION.md) | Why it looks like this, in sensory terms. No values, no tokens. Read it when a judgement call is not covered by the rules. |
| [`design/DESIGN-SYSTEM.md`](design/DESIGN-SYSTEM.md) | The canonical token reference. Written for web and document work, so the rice guide overrides it wherever the two differ for a desktop. |
| [`design/THEMING.md`](design/THEMING.md) | Which of the five mechanisms carries colour to each application, what every surface is set to, and which decisions are settled. |
| [`TURNING-POINTS.md`](TURNING-POINTS.md) | Why the repository is shaped the way it is, for the decisions whose result is visible but whose reason is not. |
| [`TODO.md`](TODO.md) | What is open, what is parked with the reasons already ruled out, and what has been decided against. |

The palette itself is not a document. It is `scripts/theme/palette.json`, which
`generate_theme.py` renders into every application's own format and
`check_palette.py` verifies. The rice guide is where the values come from; that
file is where they live.
