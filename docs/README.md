# Documentation

Eight documents. Each owns one question, and each says who it is for, because most of
them you will never need.

**If you just want to use these dotfiles, you need two:** [`SETUP.md`](SETUP.md) to
install and adapt them, and [`design/RICE-GUIDE.md`](design/RICE-GUIDE.md) if you want
to change how they look. Everything else is here for whoever maintains the repository,
or for anyone curious about why it looks the way it does.

| Document | Answers | For |
|---|---|---|
| [`SETUP.md`](SETUP.md) | How to install it, what to change for your own hardware, and what to do when something does not work. | Using it |
| [`design/RICE-GUIDE.md`](design/RICE-GUIDE.md) | The palette, the ANSI table, and the rules for how colour gets assigned. The authority on anything visual. | Changing how it looks |
| [`design/THEMING.md`](design/THEMING.md) | Which mechanism carries colour to each application, what every surface is set to, and which decisions are settled. | Changing how it looks |
| [`MAINTENANCE.md`](MAINTENANCE.md) | What the management scripts really do, every architecture pitfall this repo has paid for, and how to validate a change. | Editing the repo |
| [`TODO.md`](TODO.md) | What is open, grouped by the session that would do it, and what is parked with the explanations already ruled out. Decisions taken are in `TURNING-POINTS.md`, not here. | Anyone |
| [`TURNING-POINTS.md`](TURNING-POINTS.md) | Why the repository is shaped the way it is, for decisions whose result is visible but whose reason is not. | Curious |
| [`design/AESTHETIC-DIRECTION.md`](design/AESTHETIC-DIRECTION.md) | Why it looks like this, in sensory terms. No values, no tokens. | Curious |
| [`design/DESIGN-SYSTEM.md`](design/DESIGN-SYSTEM.md) | The canonical token reference, written for web and document work rather than for a desktop. **Not required reading** to use or change these dotfiles. | Curious |

When two documents seem to disagree, each is authoritative only on the question it
owns, and the mismatch is a bug in the document rather than something to work around.
For desktop work specifically, `RICE-GUIDE.md` overrides `DESIGN-SYSTEM.md` wherever
they differ.

The palette itself is not a document. It is `scripts/theme/palette.json`, which
`generate_theme.py` renders into every application's own format and `check_palette.py`
verifies. The rice guide is where the values come from; that file is where they live.
