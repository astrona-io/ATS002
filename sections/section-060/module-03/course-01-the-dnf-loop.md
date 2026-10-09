# The Everyday dnf Loop

Astronaut, this is the routine supply run you will fly again and again: see what is out of date, bring it up to date, and order something new. `dnf`, the quartermaster, does all three. This part also shows where `dnf` is *not* like Debian's `apt`, because that is where people coming from Ubuntu slip.

## Check what can be upgraded

The first question of any maintenance window is "what is waiting?". `dnf` answers it without changing anything.

### dnf check-update

```bash
# shell: inside the rpmbox container
dnf check-update
```

This lists every installed package that has a newer version in the configured repositories. It **exits with code `100`** when updates are found, and `0` when there are none, so a script can act on that number. Running it changes nothing.

### No separate catalogue step

The **package index** is the depot's catalogue, downloaded to the ship. On Debian you must refresh it yourself with `apt update` before you upgrade. `dnf` keeps its catalogue current by itself: it refreshes it inside most commands whenever the local copy is judged too old. There is no "did you `apt update` first" step to forget.

If you want a refresh anyway, `dnf makecache` forces one, and `--refresh` on any command does the same for that one run. How old "too old" is comes from the `metadata_expire` setting in `/etc/dnf/dnf.conf`.

## Apply the upgrades

Once you know what is waiting, one command brings everything up to date.

### dnf upgrade

```bash
sudo dnf upgrade
```

This installs the newer version of every installed package that has one. The dependency solver works out any related changes **in the same transaction**. Debian splits this into `upgrade` and the more aggressive `full-upgrade`. `dnf` has no such split for routine upgrades: it computes one plan and applies it.

`dnf upgrade` and the older `dnf update` mean the same thing; `upgrade` is the current spelling.

Inside `rpmbox` you are already the root user. If the container answers `sudo: command not found`, run the same command without `sudo`.

## Install something new

Installing works the way you would expect, with one habit worth learning for the exam.

### dnf install

```bash
sudo dnf install fail2ban
```

This works out and installs `fail2ban` plus everything it depends on. To install several packages, put all the names in one call.

### The EPEL habit

If a package does not show up, check whether it lives in **EPEL** (Extra Packages for Enterprise Linux). EPEL is the standard extra repository most RHEL and Rocky Linux servers enable. `fail2ban` is an EPEL package. On a real system you enable EPEL with `dnf install epel-release`; `rpmbox` has it enabled already.

## Common pitfalls

> [!WARNING]
> - **Looking for a `dnf update` step before `dnf upgrade`.** `dnf` refreshes the catalogue itself; `check-update` and `upgrade` do it for you.
> - **Looking for a `full-upgrade` equivalent.** `dnf upgrade` already shows and applies one complete plan, including any additions and removals the solver needs.
> - **Deciding a package "does not exist" because `dnf search` finds nothing.** Check EPEL first (`dnf install epel-release` on a real system; already enabled in `rpmbox`).
> - **Treating exit code `100` from `check-update` as an error in a script.** `100` means "updates available".
