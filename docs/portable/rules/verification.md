## Verification


### Convention, then checker, then hook **(paid)**

Three rungs, climbed as a rule proves violable. Prose is advisory, a checker is
a script you remember to run, a hook fires on the event and cannot be reasoned
out of. Write the checker the first time the convention is broken, because that
is the proof it can be, and reserve prose for judgement calls. _A documented
rule to mirror theming across two window managers went unenforced through an
entire retheme; a twenty line checker found it in one run._

The rungs have names. Prose is a rule in these files. A checker is a script, and
once there are several, a skill that runs them all and shows what each returned
beats remembering which ones exist: here that is `/verify-repo`. Above that,
`/goal` holds a session to a completion condition that a separate model re-checks
after every turn, a Stop hook gates the turn on your own script, and a PreToolUse
hook blocks an action outright regardless of what the agent decides. Instructions
are context and can be reasoned around; hooks cannot.

### Verify by measuring the result, not by reading the config **(paid)**

Reading a config tells you what it says, not what happened. Sample the pixel,
read the value back out of the running program, diff generated output against
what the generator produces now. Pointed at the agent this is the same rule:
**give it a check it can run itself**, in the same instruction as the work, or
you are the verification loop. _Three things here were configured, looked
configured, and did nothing, with no error message in any of the three._

### Report the measurement, not the conclusion **(paid)**

"It works now" is not a result, it is a claim about one. Show what was run and
what came back, so the reader can catch a misread before it becomes a decision.
A measurement quoted in full also survives into the next session; a verdict does
not. _Twice in one session a conclusion was reported as verified and was wrong:
a pixel sampled at the wrong coordinates after the window moved, and a bug
called fixed on the strength of a log line that meant something else. Both were
caught by the person who had actually watched the screen, which is the loop this
rule exists to close._

### Generated files must be marked and verified **(paid)**

A `GENERATED` header, and a check that regeneration is idempotent. Without the
second half a hand edit survives until the next regeneration silently discards
it. _Applies to any project with codegen; skip it if nothing is generated._

### The author is the wrong reviewer **(borrowed)**

An agent reviewing its own diff still holds the reasoning that produced it and
will defend it. Review in a fresh context, scoped: gaps against stated
requirements and correctness, style ruled out explicitly. Anything asked to find
problems will find some.
