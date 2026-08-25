# Solution Walkthrough

All commands below run **inside the `rpmbox` container**. Get a shell first:
```bash
docker exec -it rpmbox bash
```

---

## Step 1: Check What's Upgradable

```bash
dnf check-update
```

## Step 2: Apply the Available Upgrades

```bash
sudo dnf upgrade
```

## Step 3: Install fail2ban Bundled With an Unwanted Package (Deliberately)

```bash
sudo dnf install fail2ban mtr
```
This is the deliberate stand-in for a colleague's real mistake: two unrelated things landing in one transaction.

## Step 4: Remove telnet and Clean Up Orphans

```bash
dnf list installed | grep telnet
sudo dnf remove telnet
sudo dnf autoremove
```

## Step 5: Find and Undo the Mixed Transaction

```bash
dnf history
```
Find the transaction ID for Step 3's install (it should list both `fail2ban` and `mtr`).
```bash
dnf history info <id>
```
Confirm both packages are in there before undoing anything.
```bash
sudo dnf history undo <id>
```
This reverses the exact set of changes that transaction made — removing both `fail2ban` and `mtr` — as one atomic operation.

## Step 6: Reinstall fail2ban Cleanly, On Its Own

```bash
sudo dnf install fail2ban
```

---

## Quick Verification

```bash
rpm -q fail2ban   # installed
rpm -q mtr        # NOT installed -- confirms the undo actually worked
rpm -q telnet     # NOT installed
dnf autoremove --assumeno   # nothing further pending
```
Once you're satisfied, run the local validation suite to pass the lab.
