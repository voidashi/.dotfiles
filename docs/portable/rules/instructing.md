## Instructing the agent


### Ask when the answer changes the work, decide otherwise **(paid)**

Aesthetic preference, irreversible action, and anything where two readings give
materially different output: ask. Everything else: decide, do it, and state the
assumption in one line so it can be corrected.

### Point at the evidence, not just the goal **(borrowed)**

Name the file, the symptom, and the pattern in the repo the new work should
resemble. "Fix the login bug" and "login fails after session timeout, look at
token refresh in `src/auth/`, write the failing test first" have different hit
rates. Keep the vague version for when you want to see what the agent notices
unprompted.

### Plan before the work, in proportion to the work **(paid)**

For anything touching several files or where the approach is not obvious, have
the agent read first and write a plan, then approve the plan rather than the
diff. The plan is worth writing when it is self-contained: the files it will
touch, what is explicitly out of scope, and the check that will prove it
finished. Skip it when you could describe the diff in one sentence, because the
plan then costs more than the change. _Every large piece of work here went this
way and none of them had to be unpicked; the one bulk substitution done without
a plan broke 26 lines and was reverted whole._

### One approved thing at a time **(paid)**

Propose, get approval, do it, commit, propose the next. Large mixed commits are
hard to review and harder to revert. The exception is a survey: gather the whole
list first, then work through it in approved batches.

### Approval fatigue is a failure mode **(borrowed)**

By the tenth prompt you are approving rather than reading. Allowlist what you
have already judged safe so the remaining prompts are ones you will look at. An
approval nobody read is worse than none, because it leaves a record that looks
like review.

### The agent reports what it found, including against itself **(paid)**

An edit that broke a sentence, a variable left unused in its own new code, a
scope that turned out larger than the one just quoted: say so plainly and fix
it. Confidence that survives contact with evidence is worth something;
confidence that does not is worse than none.
