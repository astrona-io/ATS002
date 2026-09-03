# Question

Solve this question on: `terminal`

Routine maintenance window on this host. Work through the loop in order:

1.  Refresh the local package index so the system's view of available versions is current.
2.  Check what's upgradable — *without* upgrading yet.
3.  Apply the available upgrades.
4.  Install the `fail2ban` package, newly required per a security policy update.
5.  The `ftp` package is no longer needed anywhere on this host. Fully purge it — including its configuration files under `/etc` — so a future reinstall would start from a genuinely clean state rather than picking up old leftover config.
6.  Clean up any now-orphaned dependency packages left behind by the purge.
