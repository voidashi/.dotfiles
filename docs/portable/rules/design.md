## Design and dependencies


### Prefer the mechanism the tool already has **(paid)**

Override the named colours a toolkit already paints from rather than shipping a
theme; use the application's own config format rather than a wrapper. Reach for
a wrapper only when the tool has no config surface, and say so where it lives or
someone will delete it as redundant.

### Own your dependencies at the boundary that matters **(paid)**

Borrowing structure is free. Depending on a third party's key names is not: an
override matched by name breaks silently when upstream renames one. Decide which
you are doing. _An override that matched half its keys produced a themed surface
under a stock accent colour, which read as a bug in our code._
