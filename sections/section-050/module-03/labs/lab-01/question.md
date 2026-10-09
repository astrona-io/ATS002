# Question

Solve this question on: `terminal`

Astronaut, this ship has a routine maintenance window. Start it the usual way: refresh the local package index, check what is upgradable without upgrading yet, and then apply the available upgrades. The grader does not check these first steps, but they are the normal start of every maintenance window.

Then finish the window:

1. Install the `fail2ban` package. A security policy update now requires it.
2. The `ftp` package is no longer needed anywhere on this host. Purge it completely, including its configuration file `/etc/ftp.conf`, so a future reinstall would start from a clean state instead of picking up old settings.
3. Clean up any dependency packages that are now orphaned, that is, installed automatically and no longer needed by anything.

The grader checks that `fail2ban` has the status `install ok installed`, that `dpkg` has no record of `ftp` at all and `/etc/ftp.conf` no longer exists, and that `apt-get autoremove --dry-run` has nothing left to remove.
