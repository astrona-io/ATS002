# Question

Solve this question on: `terminal`

Astronaut, a colleague has handed you a standalone `.deb` file under `/home/candidate/downloads/`. It holds an internal tool, `logtail-utils`, that is not available in any configured repository. Check the file's exact name first: the architecture part of the name depends on this machine.

1. Before installing anything, inspect the package's metadata (version, maintainer, declared dependencies) and its full file list, without installing it.
2. Install it with `dpkg`, so that it ends up fully installed (`ii` in `dpkg -l`) and `/usr/bin/logtail` is on disk and executable.
3. Confirm ownership in both directions: find which package owns `/usr/bin/logtail`, and list every file that `logtail-utils` placed on the system.

Separately, an unrelated package on this ship, `cowsay`, was left half-configured by an interrupted operation. Diagnose it (`dpkg -l` shows it is not in the clean `ii` state) and recover the system to a consistent package state.

The grader checks that `logtail-utils` has the status `install ok installed` and `/usr/bin/logtail` is executable, that `dpkg -S /usr/bin/logtail` answers `logtail-utils: /usr/bin/logtail` and `dpkg -L logtail-utils` lists `/usr/bin/logtail`, that `cowsay` has the status `install ok installed`, and that `sudo dpkg --audit` reports nothing.
