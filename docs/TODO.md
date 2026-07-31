# Open work

What is not finished, what is parked and why, and what has been decided against. Check
here before assuming something is undone: several of the entries below record an
elimination that is expensive to repeat.

The first section is what to do next and is ordered; everything after it is grouped by
kind and is not.

Each piece of work carries a **difficulty** and a **priority**, rated separately.
Difficulty is how much work it is and how much can go wrong; priority is how much it costs
to leave alone. They are independent: a one-line fix can be urgent and a rewrite optional.
The entries under "Pending actions" are unrated on purpose, being things to do rather than
work to plan.

What lives here is work, plus the decisions that were made *against* doing something,
because those are what stop a question being reopened. What does not live here is settled
knowledge: pitfalls and validators are in [`MAINTENANCE.md`](MAINTENANCE.md), how the
palette reaches each application is in [`design/THEMING.md`](design/THEMING.md), and why
the repository is shaped as it is belongs to
[`TURNING-POINTS.md`](TURNING-POINTS.md).

## Start here next session

Highest priority, before anything else. All three come from a third review, by someone
told to be an ordinary Linux user who wants a good-looking desktop without spending a
weekend on it, and who can google anything obvious. The two earlier reviews were done by
people who could read code, which is why none of this surfaced then. Every finding below
was re-verified by hand.

Two of the five are done. "Say how to get into the session" put `greetd` and
`greetd-tuigreet` in `packages.conf` and both launch paths in `SETUP.md` step 6, and what
it left behind is under "Pending actions" and "Features not built". "Make `--dry-run` the
first install step" is now steps 1 and 3 of the install, with the README's warning
offering the simulation instead of demanding an audit. That one turned up three defects in
`backup-configs.sh`, all fixed and recorded under Housekeeping, so it stopped being a
documentation task halfway through.

The script audit that grew out of it is also done and has moved to Housekeeping, along
with an explicit list of what it did not cover. It found 26 defects, five of which
destroyed files, and it closed the reason a reviewer said they would install this on a
spare machine and not on their laptop: there is an `uninstall` now, and it is the one
the documents point at.

1. **Write the recipe for changing the accent colour.** The README's headline promise is
   "change one hex and everything moves together", and that promise is what makes people
   want the repo. It is also the one thing no document lets them act on. Measured:
   `palette.json` has no accent key at all, the identity colour is a ten-value `bordeaux`
   ramp, and the same values are typed again as literals in `terminal.cursor` (`#c76870`)
   and `ansi16` slot 1 (`#b44955`). The reviewer spent ten minutes across five files and
   gave up. Meanwhile `RICE-GUIDE.md`, which the index recommends for changing appearance,
   answers "never introduce a colour that is not derived from these", which is the
   opposite of what they wanted.

   So: a short section in `SETUP.md` naming the exact keys to edit, the two places the
   values are duplicated, and one worked example ending in the two commands that already
   exist. Fifteen lines. It stays true and gets shorter once the generator gains a roles
   layer, below.
   *Difficulty: low. Priority: maximum, since it is the repo's best promise with nothing
   behind it.*

2. **Make the two things a reader has to guess at explicit.** The README offers "you can
   lift the terminal colours, or the bar, or just the palette generator, and ignore the
   rest", and no document says how, while the installer brings the whole of
   `packages.conf` including both compositors, both notification daemons and both file
   managers. Write the cheap path in three lines, or drop the offer. The code change
   that would make it one command has its own entry under Housekeeping, "Let `install`
   take paths"; this item is the documentation half and does not wait on it.

   Separately, the Iosevka step is the one place the reader has to pattern-match alone:
   "the Iosevka SGr TTC build" is not a filename, the releases page is a wall of
   near-identical archives, and the theme wants "Iosevka Extended", a third name. Give the
   exact asset or a `curl` line. The penalty for guessing wrong is a default-looking
   terminal, which is the whole point of the repo.
   *Difficulty: low. Priority: maximum.*

3. **Rewrite the README's opening as an introduction that holds the reader.** "Is this for
   you?" is good and the reviewer said so, but it opens by qualifying rather than by
   selling, so it does not hold someone who just opened the repo. The page should lead
   with what this is and why it looks good, then what it contains, and only then filter
   with "is this for you". Keep the honesty that earned trust: the reviewer named "Known
   gaps" as the single thing that most made them believe the rest.
   *Difficulty: low. Priority: maximum.*

Worth keeping from that review, because it is easy to lose: the parts that worked on this
reader were "Is this for you?", the symptom-first troubleshooting section, `docs/README.md`
telling them only two documents matter, `MAINTENANCE.md` letting them back out in one line,
and "Known gaps". Do not lose those while fixing the above. Their verdict was that they
would install it on a spare machine but not on the laptop they work on, for exactly two
reasons: being told to read scripts they cannot read, and not knowing how to reach the
session.

## Pending actions, not work

- **The clipboard and idle daemons need one login to start.** `cliphist`, `hypridle` and
  `swayidle` are installed and configured, but a compositor session started before the
  autostart lines existed will not be running them. Confirm with the commands rather than
  by pressing the keybind, because a dead daemon and an empty history look identical:
  `pgrep -x hypridle`, `pgrep -x wl-paste`, `cliphist list | wc -l`.
- **The greetd path has never been run.** It is now documented in `SETUP.md` step 6 and
  declared in `packages.conf`, but this machine reaches its desktop through
  `plasmalogin` and greetd is not installed here, so nothing has exercised the config or
  the unit. What was verified is narrow and worth not re-doing: both packages exist in
  `extra` (`pacman -Si greetd greetd-tuigreet`), the config format and the tuigreet flags
  come from upstream's own README, and `/usr/share/wayland-sessions/` already holds
  `hyprland.desktop` and `sway.desktop` from the compositor packages. What is unverified
  is the whole path end to end: that the unit name is right, that the config parses, and
  that tuigreet lists both sessions. A spare machine or a VM is the honest test, and
  until then `SETUP.md` should not gain any sentence claiming it was tried.
- **`CLAUDE.md` and `.claude/` are deleted at publication.** The content moved to
  [`MAINTENANCE.md`](MAINTENANCE.md). Before deleting, run both checks, because the first
  one alone was trusted once and was not enough:

  ```bash
  # 1. no repo knowledge left in the file itself
  grep -icE "kded6|8-digit hex|process cwd|swaylock-effects" CLAUDE.md   # expect 0
  # 2. nothing anywhere points at either path. Code counts, not just docs.
  grep -rn "CLAUDE\.md\|\.claude/" --exclude-dir=.git .
  ```

  The second check exists because the first was run with `--include="*.md"` and reported
  clean while eight references sat in six config and script files. What it may legitimately
  return, so the list is checkable rather than a judgement call: this entry's own text,
  `CLAUDE.md`'s title line, the `.claude/worktrees/` rule in `.gitignore`, and any hit
  inside the gitignored `scripts/package_install.log`. Anything else is a real reference
  that has to be dealt with before the file goes.

## Known defects

- **Workspace buttons in the bar do not respond to clicks**, and it is not this
  configuration. A full bisect ruled out everything on our side, so it is parked rather
  than solved. Established:

  - Not the stylesheet. It fails identically with `/etc/xdg/waybar/style.css`.
  - Not the layer. It fails on both `bottom` and `top`.
  - Not `persistent-workspaces`. It fails with the legacy `{"1": [], ...}` form and with
    the documented `{"*": 5}` form.
  - Not a missing handler. Probes on `on-click`, `on-click-right`, `on-click-middle` and
    `on-scroll-up` running `notify-send` never fired once.
  - Not the bar's input in general. `clock` toggles, `custom/power` opens the menu, and
    hovering a workspace button highlights it, so the widget receives motion events.
  - Nothing reaches Hyprland either: with `-l debug` a click produces no dispatch line
    and no `workspace>>` event, while a keyboard switch produces both.

  So in waybar 0.15.0 those buttons take motion events and no button events at all.
  Next avenues in order of cost: check upstream issues for this version, try a different
  build, or replace the module with a `custom` one that renders and dispatches
  workspaces itself, which would cost the live updates. Three genuine config defects
  were fixed along the way and are worth keeping regardless: `layer` is `top`,
  `persistent-workspaces` uses the documented form, and a `disable-scroll` belonging to
  `sway/workspaces` was removed.
  *Difficulty: high, now that the cheap explanations are gone. Priority: medium, since
  keyboard switching works and this is a convenience.*

- **The launcher and the keybinding open different terminals.**
  `.config/wofi/config` sets `term=alacritty` while
  `.config/hypr/conf/programs.lua:10` sets `terminal = "kitty"`, so a terminal
  application started from the launcher lands in a different emulator from
  `Super`+`Return`. All four are themed identically so nothing looks wrong, which is
  why it went unnoticed. Pick one and make both agree.
  *Difficulty: trivial. Priority: low.*

- **hyprlauncher's radius contradicts the floating rule.**
  `.config/hypr/hyprtoolkit.conf:32-33` sets `rounding_large` and `rounding_small` to 0,
  but a launcher floats, and the guide's Form rule gives a floating surface 4px. It went
  unnoticed because hyprlauncher is commented out in `conf/programs.lua` in favour of
  wofi, so nothing renders it. Fix it before switching back, or the launcher arrives with
  the one geometry the design does not allow.
  *Difficulty: trivial. Priority: low while hyprlauncher stays off.*

- **The bar carries laptop-only modules with no guard.** `battery` and `backlight` are
  in `modules-right` unconditionally, so on a desktop they are empty or absent.
  `SETUP.md` tells a reader to remove them, which is a workaround rather than a fix.
  Waybar has no conditional module mechanism, so the honest options are a second
  `modules-right` in the per-compositor files or accepting the manual step.
  *Difficulty: low. Priority: low.*

## Features not built

- **Bring the greeter onto the palette.** `tuigreet` takes a `--theme` flag in
  `component=color` form, which is why it was chosen over the alternatives, and today it
  is declared and documented unthemed. The obstacle is not the flag: greetd's config is
  root-owned and outside `$HOME`, so `generate_theme.py` has nowhere to write and
  `check_palette.py` has nothing to check, and the login screen would be the one surface
  that drifts off-palette with no validator noticing. Decide first whether generating a
  file outside `$HOME` is something this repo does at all, because the same question
  governs power profiles below. Depends on the item under "Pending actions": theming a
  path nobody has booted is the wrong order.
  *Difficulty: low once the scope question is answered. Priority: low, and it is the
  first surface a visitor sees, which argues it up once greetd is actually in use.*

- **Power profiles.** Idle handling exists; switching a CPU governor or a platform
  profile does not. `power-profiles-daemon` is the usual answer and it needs
  `systemctl enable`, which is a system service rather than a dotfile, so
  `backup-configs.sh` has no way to manage it. `supergfxctl` is already declared here,
  which suggests the graphics half was once considered. The question of whether this
  repository should carry system services at all comes before the work.
  *Difficulty: low. Priority: low, and it is a scope decision more than a task.*

- **Per-application workspace layouts.** Something real exists underneath, so this is
  an extension rather than a build: `hypr/conf/window_rules.lua:10-16` already drops
  gaps and borders when a workspace holds a single window, through Hyprland's `w[tv1]`
  and `f[1]` selectors. What does not exist is any application-to-workspace assignment.
  Decide what the rule should be before writing it, because a workspace map that fights
  how you work is worse than none. Whatever it becomes has to be mirrored in the Sway
  config, which has no equivalent of those selectors and would need explicit `assign`
  rules.
  *Difficulty: low to write, and the design is the real work. Priority: low.*

## Housekeeping

- **The script audit is done, and this is what it did not cover.** `install-packages.sh`
  and `backup-configs.sh` are the only code here that can damage a real `$HOME`. Four
  reviewers went over what were then three scripts, with different lenses: correctness,
  architecture, output and ergonomics, and a non-expert reading them beside the README.
  `shellcheck` was run for the first time, and the correctness pass reproduced every
  defect it reported in a throwaway `HOME=` before reporting it. Twenty-six were found;
  the fixes are in `MAINTENANCE.md` and the git history, and
  `scripts/tests/test-dotfiles.sh` holds them fixed. The third script,
  `unlink-dotfiles.sh`, was deleted rather than repaired further; see the decision below.

  **Not covered, and this is the part that matters here.** Nothing touching `sudo`,
  `apt`, `pacman -Syy` or `dnf` was ever executed: `add_repos` and `update_pkg_db` are
  reasoned from reading only, including the unchecked `wget | gpg | tee` that writes an
  empty repository key when the download fails and leaves every later `apt-get update`
  broken. `run_hooks` was analysed by running its awk program standalone; the `system()`
  call was never allowed to execute anything. Everything ran on one CachyOS machine, so
  only the pacman branches saw a real package manager. `install_fonts` and
  `init_dotfiles` were read but not exercised. Concurrency, meaning two runs sharing a
  `$TIMESTAMP`, and behaviour under an empty `$HOME`, were reasoned about and not
  reproduced.

  **Known and left alone**, with reasons, so nobody re-derives them. Three MEDIUM
  defects in `install-packages.sh` are still open: a hook command containing an `=` is
  truncated at the first one, because awk splits the whole line and only `$2` is run; a
  hook key is interpolated into a regex rather than compared literally, so a key of
  `pipesXsh` fires for the package `pipes.sh`; and `add_repos` discards
  `update_pkg_db`'s status, so a failed database refresh is followed straight into the
  install loop. All three are in the awk-embedded-in-bash section, no hook is
  uncommented in `packages.conf` today, and the honest fix is to replace that awk with a
  bash read loop rather than patch it three times.
  *Difficulty: low each, medium together with the awk replacement. Priority: low while
  no hooks exist, medium the day one is uncommented.*

- **Decided: `unlink-dotfiles.sh` is deleted, and no `unadopt` replaces it.** It moved
  the repo's files out into `$HOME` and emptied the clone, which is the inverse of `add`
  and not of `install`. Once `uninstall` existed, its entire documentary footprint was
  disclaimers: six places existed only to tell a reader this was not the script they
  wanted, and every future edit to those documents paid that tax.

  A per-path `unadopt` subcommand was proposed to replace it and rejected: too little
  function to justify a command, for an operation the author performs about once and can
  do with `mv`. Documenting that `mv` was also rejected, on the same grounds. Reopen only
  if the manual step turns out to be taken often enough to hurt.

  This also closes the older question of whether to fold the script into
  `backup-configs.sh`. There is nothing left to fold, and the third copy of the
  repo-path mapping went with it.


- **Let `install` take paths, so the README's offer is true.** The README says you can
  lift the terminal colours, or the bar, and ignore the rest, and `backup-configs.sh
  install` is still every path in `config_files.conf` or nothing. `install-packages.sh` gained positional
  package names in the audit and this is the same change on the other script:
  `install_dotfiles`, `check_dotfiles` and `uninstall_dotfiles` are each a loop over
  `load_dotfiles`, so filtering that loop by positional arguments is roughly ten lines
  and needs no config format change. `add_dotfile` already takes one path.
  *Difficulty: low. Priority: medium, and it is the cheapest way for a stranger to try
  this without committing to all of it.*

- **Rethink how the generator decides colour, and consider a roles layer.** Today
  `palette.json` holds raw ramps plus a few roles expressed as duplicated literals:
  `terminal.cursor` and `focus_ring` are semantic keys carrying a hex that also exists in
  a scale. The idea worth exploring is to make that systematic, so a role points at a
  token by name rather than repeating its value: `"accent_identity": "bordeaux-400"`,
  `"surface_panel": "void-10"`, and so on. That is not a new pattern here. The Neovim
  theme already works exactly this way in three layers, raw palette then semantic roles
  then highlight groups, and this would lift the same structure up into the source of
  truth.

  Three things to settle before writing any of it, one of which is a hard boundary.

  **ANSI must not follow the accent.** Slot 1 is red because red means red. If someone
  swaps the identity family to Ash, ANSI red has to stay red, so `ansi16` remains a
  canonical table that no role touches. Getting this wrong is the obvious way to break the
  non-negotiable that ANSI is identical everywhere.

  **The guide still constrains which family suits which role.** Ash is media and never
  functional UI, so a free accent swap can produce a configuration `RICE-GUIDE.md`
  forbids. The mechanism becomes one key; the design position does not change. Whoever
  clones this and wants a different look is entitled to ignore the guide, and saying so
  explicitly keeps the two documents from appearing to contradict each other.

  **Roles only reach the generated half.** Ten files are generated and would follow a role
  change automatically. Eight are hand-written because colour mixes with structure there,
  swaylock among them with `key-hl-color=b44955` spelled out, and those would not. So "one
  key" would be true of half the system, and any claim in the README has to say which
  half. The natural complement is a check for orphaned literals: a hex in a hand-written
  file that no role uses any more.

  This is a generator refactor with ten generated files to re-verify, so it wants its own
  plan rather than being folded into a documentation pass.
  *Difficulty: medium, and the design questions are most of it. Priority: medium, and it
  makes the recipe in item 3 above shorter rather than replacing it.*

- **catnap's tracked config dies on the next upstream bump.** Upstream is at 2.1.1, and
  catnap 2.0 replaced the TOML config with a `.cat` language, saying outright that
  `config.toml` and `distros.toml` are not compatible with v2. The AUR package is still
  1.1.1, so today it works. When it moves, both tracked files need rewriting rather than
  editing, and the payoff is real: v2 takes hex, RGB and theme imports, so the palette
  becomes reachable exactly instead of through seven ANSI tokens with no grey among them.
  The validator battery runs catnap and reports its exit code, so this surfaces as a
  failed check rather than as a broken greeter.
  *Difficulty: low, and it is a rewrite of two files. Priority: low until the AUR moves,
  then blocking for anyone using catnap as their greeter.*

- **Four packages are installed for programs nothing launches.** `dunst`, `hyprpaper`,
  `hyprlauncher` and `catnap`. All four configs are deliberate keeps and those decisions
  are settled in [`TURNING-POINTS.md`](TURNING-POINTS.md), but a reference config does not
  need its program on a stranger's machine, and the question was only ever asked of
  `dunst`. `pfetch-rs` is the same shape with no config at all: its only invocation is a
  commented line in `config.fish`, and it carries seven lines of AUR justification.
  *Difficulty: trivial. Priority: low.*

- **The noise audit is done, and this is its list.** Four reviewers with different lenses:
  a plain user reading only what the index sends them to, an orphan sweep over the whole
  tree, a document editor, and a software architect. Wording, formatting and bug hunting
  were out of scope for all four. A fifth then argued against every proposal they made,
  which is why several entries below record a decision *not* to cut rather than work: the
  cheapest thing this list can do is stop a bad deletion being proposed twice.

  Closed during the audit, so they are not reopened: `.config/catnap/`, the dormant
  fastfetch presets, the unused Hack and Instrument Sans faces and `DESIGN-SYSTEM.md` all
  stay, and the first four are now named in `TURNING-POINTS.md` as deliberate keeps.

  Fixed in the same session: four dead `SKIP_PARTS` in `check_palette.py`, two surviving
  "three scripts", the false `@import` claim in `MAINTENANCE.md`, a hyprtoolkit header
  claiming a keybind it does not have, a stale test count in the README, and a tracked
  gitlink that had come back (see below, since that one needs a check rather than a fix).

  **Features with no users.**

  - `[hooks]` in `packages.conf` has zero entries and one commented example, and
    `run_hooks()` is 15 lines of awk-inside-bash carrying the three open defects and the
    repair plan recorded above. Deleting the feature closes those three with it.
    *Difficulty: trivial. Priority: medium, because work is scheduled on something nobody
    uses.*
  - The apt and dnf machinery has never run. The Microsoft repository key at
    `install-packages.sh:133-137` was reported as serving a VSCode nothing declares, and
    that is wrong: `code` is declared at `packages.conf:107` under `[common]`. The key is
    not an orphan, it is apt-only machinery for a package that arrives another way on the
    one platform this repository supports, so it stands or falls with the apt branch rather
    than separately. It is smaller than first claimed: 14 non-comment lines mention apt or
    dnf, in the low thirties
    counting whole `case` branches and the `repos` dispatch, not 90. Two costs the first
    pass missed. `SETUP.md:12` and `README.md:157` advertise cross-distro support to a
    reader, so this is a documentation edit as well. And `install_all()` reaches
    `update_pkg_db()` only through `add_repos()`, so deleting that function without
    rewiring first drops `pacman -Syy` from every Arch install, which is the supported
    path.
    *Difficulty: low. Priority: medium.*
  - **Decided, do not repropose: `backup-configs.sh init` is not dead code.** It was called
    unreachable and is not. `DOTFILES_DIR` is overridable and is not derived from
    `SCRIPT_DIR`, `add` fills the repository it creates, and
    `scripts/tests/test-dotfiles.sh` relies on that override for all 20 of its cases. Its
    body also carries a paid fix, since `--dry-run` once reached neither guard and created
    the directory for real. The only honest argument against it is that this is not a
    general-purpose dotfiles tool, which is a scope decision rather than a defect.
  - `config_files.conf` carries "Optional Configurations" and "Template Examples", eight
    commented lines whose content is `~/.EXAMPLE_FILE`, for a format that is one path per
    line.
    *Difficulty: trivial. Priority: low.*

  **Documentation that outweighs what it documents.**

  - **Decided, do not repropose: `RICE-GUIDE.md`'s rules stay where they are.** About 150
    of its 504 lines were accused of addressing a contributor or the agent inside a
    document the index sends a *user* to. That did not survive review. "Working rules"
    opens by saying each rule is there because breaking it cost something, and two are
    traceable in the tree. `CLAUDE.md:21-22` points at that section and at "Anti-patterns"
    by name and says not to restate them here, which is the one point-do-not-restate
    structure in this repository working correctly; moving the owner leaves the pointer
    dangling. The index files this document under "Changing how it looks", which is exactly
    who those rules address. The genuinely agent-facing text is one clause, "stop and ask
    rather than deriving one silently". Two counts in the accusation were also wrong: 13
    anti-pattern bullets, not 12, and 10 application-class paragraphs, not 9.
  - `THEMING.md:159-166` carries open work eight lines after its own opening says this file
    owns it, and its three items are verbatim from here. Its first three "Settled
    decisions" bullets (138-146) restate `RICE-GUIDE.md`. Bullets 4 and 5 must survive:
    the relaxed accent budget for fetches, and "Rollback is git, not a directory".
    *Difficulty: trivial. Priority: medium.*
  - **Decided, do not repropose: the Qt entry at `SETUP.md:342-369` keeps its 28 lines.**
    It was read as a second copy of the cause in `MAINTENANCE.md:186-196`. It is a
    two-cause diagnostic and only the first cause duplicates. The second, that
    `plasma-integration` is missing so the variable is set and nothing reads it, is the
    only copy on a reader's path, carries its own check, and is this repository's signature
    failure in one sentence. `SETUP.md:152-159` is not a third statement either: it is the
    setup-time instruction against the troubleshooting entry, which is two reader states
    rather than one fact twice.
  - `SETUP.md:118-143` explains greetd's stock config, its flags and `systemctl enable`,
    which are greetd's own README and `tuigreet --help`. The "enable, not `enable --now`"
    footgun is the part that earns its place.
    *Difficulty: trivial. Priority: low.*
  - `AESTHETIC-DIRECTION.md` prints the temperature map (160-177) a second time against
    `DESIGN-SYSTEM.md:238-248`, and photography direction sits in three documents for a
    repository that has no photography. Its irreplaceable content is the material
    references, "The right temperature of darkness", "What the system is not" and the note
    on coherence over time.
    *Difficulty: low. Priority: low.*

  **Duplicated knowledge.**

  - The two compositors describe every runtime service twice and have already diverged.
    The autostart set at `autostart.lua:15-35` against `sway/config:237-265`; the idle
    schedule 300/360/1800 in two syntaxes, with a comment asking future editors to keep
    them in step; three screenshot binds under Hyprland against one bare `grim` under Sway;
    different launcher keys. Sway also carries nine hand-pasted hex while Hyprland reads a
    generated `palette.lua`, so the two sit on opposite sides of this repo's most important
    seam. `TURNING-POINTS.md` records waybar learning exactly this lesson. The cheap half is
    generating a Sway palette include, about 15 lines in `generate_theme.py`, which moves
    nine literals off the drift surface. Whether Sway should exist at all depends on
    whether it is ever booted, which nothing here records.
    *Difficulty: low for the include, high for the rest. Priority: medium.*
  - The two management scripts are two CLIs for one job. The rehearsal is `preview`, a
    subcommand, on one and `--dry-run`, a flag, on the other, and the README prints both in
    one code block. Four flags exist on one and not the other for no reason arising from
    its job. Pick one vocabulary; nothing learned from the first script transfers today.
    *Difficulty: low. Priority: medium.*
  - `.claude/skills/verify-repo/SKILL.md` is the only artefact that runs all nine checks,
    and "Pending actions" above commits to deleting `.claude/` at publication. Its content
    is duplicated as prose in `MAINTENANCE.md:384-444`, the two have already diverged
    (`MAINTENANCE.md` runs two the skill does not), neither runs
    `scripts/tests/test-dotfiles.sh` despite the skill claiming every validator, and the
    skill hardcodes "32 valid" and "31 paths". Worse than a stale number: that block's
    `valid:` figure measures nothing. It counts `SUCCESS` lines out of `backup-configs.sh`,
    which gates them behind `--verbose`, which the block does not pass, so it prints
    `valid: 0` on a healthy tree beside a summary line reading "Valid: 32". A check that
    has been reporting zero for as long as that flag has existed, in the repository whose
    stated signature bug is a thing that looks configured and does nothing. A
    `scripts/verify.sh` that both call is the obvious answer and is the precondition for
    deleting `.claude/` without loss. Two checks belong in it that nothing runs today: the
    test suite, and a guard that `git ls-files -s` holds no gitlink, for the reason in the
    entry below.
    *Difficulty: low. Priority: medium, high the day publication is real.*
  - `CLAUDE.md` claims it "can be deleted without losing anything". True of four of its five
    rules. "Never write a count that a config file owns" exists nowhere under `docs/`, and
    the pre-deletion greps in "Pending actions" would not catch it, since they look for
    pitfall strings and for references to the path. Move it to `MAINTENANCE.md` first, and
    move the general form with it: a file must not restate a fact another file owns, only
    point at the owner. The count is the narrow case. `hyprtoolkit.conf` carried the wide
    one twice, first naming a keybind that `conf/programs.lua` owns and then, in the fix
    for that, naming which launcher was live, which the same file owns.
    *Difficulty: trivial. Priority: medium, because it is lost silently at deletion.*

  **Smaller, one edit each.**

  - `generate_theme.py:626-631` has `if __name__ == "__main__": main()` twice, both at top
    level, so every run generates all ten files twice and runs the in-place edits twice.
    There are three of those, not two: `inline_block`, `merge_kde_globals` and
    `merge_kcm_input`. The comment at line 618 says "These two" and is where the wrong
    count came from, so it goes in the same edit. Invisible only because the writes are
    idempotent.
    *Difficulty: trivial. Priority: medium, since those three edit files in place.*
  - `wallpapers/Topography.png` and `Topography.jpg` are one image at one size, and both
    match the picker's glob, so a fresh clone randomises between two copies of the same
    wallpaper while `README.md:161` promises one. Only the dimensions were compared, not
    the pixels.
    *Difficulty: trivial. Priority: low.*
  - **Decided, do not repropose: `mediaplayer.py` stays beside the bar.** It was proposed
    for `scripts/wm/`, which `MAINTENANCE.md` defines as helpers *the compositors* call,
    and waybar is not a compositor. The script is also bound by a serialisation contract to
    `common.jsonc`, which its own docstring names, so separating the two is worse than the
    inconsistency, and moving it would break the README's offer that the bar can be lifted
    on its own.
  - Comments in about 8 of the 17 files under `.config/hypr/` are in Portuguese while the
    rest of the tree is English, including the note at `autostart.lua:12` on why absolute
    paths are used, which is worth reading. Translate on touch, like the double hyphens.
    *Difficulty: trivial per file. Priority: low.*
  - Declared with no config, no launch and no bind: `ranger` (a third file manager beside
    themed yazi and dolphin), `supergfxctl`, `cava`, `zathura`, `cmatrix`, `hyprpicker`.
    *Difficulty: trivial. Priority: low.*
  - **The brightness keys are dead on this machine right now.** `binds.lua:91-92` and
    `sway/config:178-179` bind them to `brightnessctl`, which is neither installed nor
    declared. `nm-applet` is in the same position, autostarted by `autostart.lua:10` and
    absent. The other six binaries first listed as undeclared (`rfkill`, `playerctl`,
    `wpctl`, `pactl`, `grim`, `swaynag`) arrive as hard dependencies of packages that are
    declared, so they are not a problem. `grim` and `slurp` come with `hyprshot`, which
    means the claim that a fresh Sway clone gets a dead `Print` key was wrong: it came from
    a grep of `packages.conf` with no dependency resolution behind it.
    *Difficulty: trivial. Priority: medium, and it is a live defect rather than tidying.*

  **Not covered, so nobody assumes it was.** `.config/nvim/`, 22 files and the largest
  unexamined subtree, where an unused plugin spec is exactly the shape being hunted.
  Whether four terminal emulators earn four configs. Nothing was executed except greps,
  `wc`, `find` and `check_palette.py`.

- **A tracked gitlink came back through a merge, and prose did not stop it.**
  `.claude/worktrees/greetd-session-entry` was swept into the index by `1539f95`, removed
  on purpose by `5ab0358`, which added the `.gitignore` rule and said "it cannot happen
  again". That commit sat on a side branch; `a7317e1` updated the gitlink on `main`
  without it, and the merge `f214f52` kept the other side. `git merge-base --is-ancestor
  5ab0358 a7317e1` returns false. A fresh clone got a phantom empty directory and a
  `160000` entry with no `.gitmodules`. It is untracked again as of this branch, but the
  sentence in `5ab0358` is still false as written, because git ignores `.gitignore` for a
  path that is already tracked. Prose has now failed at this twice, so what is owed is the
  check named above: `git ls-files -s | grep '^160000'` must come back empty. It would
  have caught both occurrences.
  *Difficulty: trivial. Priority: high, because it survives a merge and nothing notices.*

- **`check_palette.py` should walk `git ls-files` rather than the filesystem.** Its
  docstring promises "a colour in a tracked config" and it walks `REPO_ROOT.rglob("*")`
  instead, which is why `SKIP_PARTS` keeps growing entries that patch around what git
  already knows: `.git/`, and now `.claude/worktrees/`. Walking the index makes both
  unnecessary, makes the docstring true, and means the next ignored directory needs no
  edit here at all. Three entries would legitimately remain, since `fish_variables`,
  `lazy-lock.json` and `palette.json` are tracked and are content exceptions rather than
  scope ones.
  *Difficulty: low, about ten lines. Priority: medium, and it removes a class of edit
  rather than an instance of one.*

- **Decide whether `minimal/` survives its own rule.** `THEMING.md:153-157` settles
  "Rollback is git, not a directory. Do not reintroduce a legacy directory", and
  `.config/fastfetch/minimal/` is five files whose own header calls them frozen snapshots
  "NOT kept in sync". The presets are now a recorded keep, so the two statements disagree
  and one has to move: either `minimal/` is the documented exception to that rule, or it is
  the thing the rule was written about.
  *Difficulty: trivial, and it is a decision rather than work. Priority: low.*

- **`DESIGN-SYSTEM.md` leaves when it stops being useful *here*.** It is 733 lines, 22% of
  the prose in this repository, cited by no config file, and every one of its 76 hexes
  except pure white already lives in `palette.json`. It is permanent reference for web and
  print work, so "is it still useful" is the wrong question: it always is. The only
  question this repository gets to ask is whether it still earns a place in this tree, and
  it stays while it is consulted from here. The day it is not, it moves to wherever the web
  work lives rather than being deleted, and `RICE-GUIDE.md:111`, which sends a reader here
  for the full ramps, points at `palette.json` instead.
  *Difficulty: trivial when the day comes. Priority: none until then.*

## Needs assets, not code

- **Wallpaper curation** is the largest remaining visual gap. It needs images chosen
  against the Wallpaper section of [`design/RICE-GUIDE.md`](design/RICE-GUIDE.md):
  material, desaturated, dark, sitting at or below `void-00` in perceived lightness.
  *Difficulty: medium, blocked on sourcing images. Priority: medium.*

- **The screenshots in the README predate the current theme.** They were committed in
  April 2025 and show the Kanagawa desktop this repo no longer contains. They stay until
  replaced, since a stale screenshot still beats none.
  *Difficulty: low. Priority: high, because it is the first thing a visitor sees.*

- **Dolphin's icons are still `breeze-dark`**, so folders come out blue against a
  Voidashi window. Every alternative installed here is worse aligned, so this waits on
  an icon set being chosen, which is an asset decision rather than a config one.
  *Difficulty: low once a set is chosen. Priority: low.*

## Provisional, not wrong

Three things about the bar are settled only until they have been lived with: whether
numerals beat application glyphs on the workspace buttons, whether the right-hand
modules want separators or should stay spaced only, and whether 15px at weight 500 is
the right text size.

## Writing standard

Every document here is at zero em dashes, verified rather than assumed. The standard,
not a task: no em dashes, and never state a thing then restate it inverted.

The double hyphens that stood in for a dash are **not** finished. They are out of the
shell scripts and remain in comments throughout `.config/`, including the stylesheets,
the waybar and swaync JSON, `hyprtoolkit.conf`, several Lua comment bodies and
`palette.json`. Clean each when something else takes you into the file.

No count here on purpose: this one is genuinely hard to grep, which is why the figure
that used to sit in this paragraph was both stale and scoped too narrowly. `--` is Lua's
comment marker and the prefix of every long CLI flag, so a naive search returns hundreds
of legitimate lines. The pattern that actually finds them is two hyphens with a space on
both sides, `[[:alnum:],)] -- [[:alnum:]]`, and even that needs reading. `set -- "$@"` in
bash is real syntax and stays.
*Difficulty: trivial per file. Priority: low.*

Worth keeping from having done it three times, because a blanket substitution does not
work. An em dash between two independent clauses wants a semicolon, one introducing an
explanation wants a colon, one around a parenthetical wants parentheses, and some
sentences want rewording because no punctuation mark carries the sense. Comma everywhere
produces comma splices; semicolon everywhere produces fragments. The changed lines have
to be reread afterwards, and doing that caught a broken sentence in two of the three
passes.
