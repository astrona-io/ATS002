# Question

Solve this question on: `terminal`

Someone has handed you a standalone `.deb` file under `/home/candidate/downloads/` (check its exact filename — the architecture suffix depends on this VM). It is an internal tool, `logtail-utils`, not available in any configured repository.

1.  Before installing anything, inspect the package's metadata (version, maintainer, declared dependencies) and its full file list, without installing it.
2.  Install it with `dpkg`.
3.  Confirm ownership in both directions: which package owns `/usr/bin/logtail`, and the complete list of every file `logtail-utils` placed on the system.

Separately, an unrelated package on this system — `cowsay` — was left in a half-configured state by an interrupted operation. Diagnose it (`dpkg -l` will show it is not in the clean `ii` state you'd expect) and fully recover the system to a consistent package state.
