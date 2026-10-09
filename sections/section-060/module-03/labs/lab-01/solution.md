# Solution Walkthrough

This walkthrough runs the maintenance window in order and finishes by undoing the mixed install. The lab's setup enabled EPEL (`epel-release`), installed `telnet`, and made sure `fail2ban` and `mtr` are not installed.

All commands below run **inside the `rpmbox` container**. Get a shell first:
```bash
docker exec -it rpmbox bash
```

If Docker answers with a permission error, run it with `sudo` in front. Inside the container you are the root user, so if `sudo` is not installed there, run the commands below without it.

---

## Step 1: Check what can be upgraded

```bash
dnf check-update
```

An exit code of `100` means updates are waiting; it is not an error.

## Step 2: Apply the available upgrades

```bash
sudo dnf upgrade
```

## Step 3: Install fail2ban bundled with an unwanted package, on purpose

```bash
sudo dnf install fail2ban mtr
```
This stands in for a colleague's real mistake: two unrelated packages landing in one transaction.

## Step 4: Remove telnet and clean up the leftovers

```bash
dnf list installed | grep telnet
sudo dnf remove telnet
sudo dnf autoremove
```

`dnf remove` does not touch the dependencies `telnet` pulled in; `dnf autoremove` removes the ones nothing else needs.

## Step 5: Find and undo the mixed transaction

```bash
dnf history
```
Find the transaction ID for the install in Step 3 (it lists both `fail2ban` and `mtr`).
```bash
dnf history info <id>
```
Confirm both packages are in it before you undo anything.
```bash
sudo dnf history undo <id>
```
This reverses exactly the changes that transaction made, removing both `fail2ban` and `mtr`, as one operation.

## Step 6: Install fail2ban again, on its own

```bash
sudo dnf install fail2ban
```

---

## Quick verification

```bash
rpm -q fail2ban   # installed
rpm -q mtr        # NOT installed -- confirms the undo actually worked
rpm -q telnet     # NOT installed
dnf autoremove --assumeno   # nothing further pending
```

These are the four things the grader checks. If the undo in Step 5 left a dependency behind, run `sudo dnf autoremove` once more.

From your own computer, not the lab machine, send the lab for grading:

```bash
astrona submit -c sections/section-060/module-03/labs/lab-01
```
