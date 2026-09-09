# Solution Walkthrough

All commands below run **inside the `rpmbox` container**. Get a shell first:
```bash
docker exec -it rpmbox bash
```

---

## Step 1: Discover What Groups Exist

```bash
dnf group list
```
Lists every group visible by default from configured, enabled repositories. If `"Development Tools"` doesn't appear (some environments hide less common groups by default), check the complete listing:
```bash
dnf group list --hidden
```

---

## Step 2: Inspect Real Membership Before Installing

```bash
dnf group info "Development Tools"
```
Read all three sections before touching anything: **Mandatory Packages** always install, **Default Packages** install unless explicitly excluded, and **Optional Packages** do *not* install with a plain group install — they'd need to be named explicitly or `--with-optional` passed.

---

## Step 3: Install the Group

```bash
sudo dnf group install "Development Tools"
```
This installs every mandatory and default member as one transaction, resolved from repository metadata rather than a hand-typed package list.

---

## Step 4: Confirm What Landed

```bash
dnf group info "Development Tools"
dnf group list installed
rpm -q gcc
```
`dnf group info` re-run after install shows an installed-indicator next to each currently-installed member. `dnf group list installed` should now list `"Development Tools"`. `gcc` — not present before this step — confirms real packages actually landed, not just a metadata label.

---

## Step 5: Remove the Group Cleanly

```bash
sudo dnf group remove "Development Tools"
```
By default, this removes packages `dnf` tracked as having been installed *specifically as part of this group installation* — not every package the group's metadata lists as a member.

---

## Step 6: Determine the Aftermath — Don't Assume It

```bash
rpm -q automake
rpm -q gcc
```
Expected: `automake` is **still installed** — it was present on this host before the group install ever ran, for an unrelated reason, so `dnf`'s group-removal tracking never counted it as belonging to that transaction. `gcc`, by contrast, is **gone** — it was installed *because of* the group in Step 3, and nothing else independently needed it, so the group removal correctly took it with it.

This is the exact distinction to internalize: "removed the group" and "removed every package the group happens to list as a member" are not the same claim. `dnf` tracks provenance, not raw membership overlap.

```bash
dnf group list installed
```
Confirm `"Development Tools"` no longer appears.

---

## Quick Verification

```bash
dnf group list installed | grep -i "development tools"   # expect: no match
rpm -q automake                                            # expect: still installed
rpm -q gcc                                                 # expect: not installed
sudo dnf check                                              # expect: clean exit
```
Once you're satisfied, run the local validation suite to pass the lab.
