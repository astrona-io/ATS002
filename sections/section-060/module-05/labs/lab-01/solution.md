# Solution Walkthrough

This walkthrough runs the full group cycle: find, inspect, install, confirm, remove and check. The lab's setup installed `automake` on its own and made sure the `"Development Tools"` group is not installed yet.

All commands below run **inside the `rpmbox` container**. Get a shell first:
```bash
docker exec -it rpmbox bash
```

If Docker answers with a permission error, run it with `sudo` in front. Inside the container you are the root user, so if `sudo` is not installed there, run the commands below without it.

---

## Step 1: Discover which groups exist

```bash
dnf group list
```
This lists every group the configured, enabled repositories show by default. If `"Development Tools"` does not appear (some systems hide less common groups by default), check the complete listing:
```bash
dnf group list --hidden
```

---

## Step 2: Inspect the real members before installing

```bash
dnf group info "Development Tools"
```
Read all three lists before you touch anything. **Mandatory Packages** always install, **Default Packages** install unless you exclude them, and **Optional Packages** do *not* install with a plain group install; they need to be named or `--with-optional` passed.

---

## Step 3: Install the group

```bash
sudo dnf group install "Development Tools"
```
This installs every mandatory and default member as one transaction, using the list from the repository catalogue rather than a hand-typed package list.

---

## Step 4: Confirm what landed

```bash
dnf group info "Development Tools"
dnf group list installed
rpm -q gcc
```
Run again after the install, `dnf group info` shows an installed marker next to each installed member. `dnf group list installed` now lists `"Development Tools"`. `gcc`, which was not there before this step, proves that real packages landed, not just a label.

---

## Step 5: Remove the group cleanly

```bash
sudo dnf group remove "Development Tools"
```
By default this removes the packages `dnf` recorded as installed *for this group*, not every package the group's definition lists as a member.

---

## Step 6: Check the aftermath, do not assume it

```bash
rpm -q automake
rpm -q gcc
```
Expected: `automake` is **still installed**. It was on the ship before the group install ran, for an unrelated reason, so `dnf` never recorded it as part of the group. `gcc`, by contrast, is **gone**. It was installed *because of* the group in Step 3, and nothing else needed it, so the group removal took it.

This is the distinction to remember: "removed the group" and "removed every package the group lists as a member" are not the same claim. `dnf` tracks where a package came from, not just which groups list it.

```bash
dnf group list installed
```
Confirm that `"Development Tools"` no longer appears.

---

## Quick verification

```bash
dnf group list installed | grep -i "development tools"   # expect: no match
rpm -q automake                                            # expect: still installed
rpm -q gcc                                                 # expect: not installed
sudo dnf check                                              # expect: clean exit
```

These are the four things the grader checks.

From your own computer, not the lab machine, send the lab for grading:

```bash
astrona submit -c sections/section-060/module-05/labs/lab-01
```
