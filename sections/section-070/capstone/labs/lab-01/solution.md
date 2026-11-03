# Solution Guide: Zypper Research-Then-Act Capstone

This capstone joins the two halves of `zypper` work: research a package thoroughly before you touch the system, then act on that research with real patch, install and remove operations. Everything runs inside the real openSUSE Leap 15.6 `zypperbox` container. The grader reads the three files in `/root/answers` and checks which packages are installed.

---

## Step 0: Enter the zypperbox container

```bash
docker exec -it zypperbox bash
```

Every command from here on runs inside this shell, not on the Ubuntu host. Docker opens the shell as root. If Docker refuses with a permission error on the host, run the same command with `sudo` in front. The lab setup has already created `/root/answers` for your findings.

---

## Step 1: Refresh repository metadata

```bash
zypper refresh
```

`zypper` downloads fresh package and patch metadata for every configured repository, including the `network-utilities` repository the setup added for `telnet-server`. Nothing installed changes.

---

## Step 2: Research the first change with a keyword search

```bash
zypper search fail2ban | tee /root/answers/01-research-search.txt
```

`zypper search` matches package names, so a keyword such as "fail2ban" or "ban" finds the candidate. Add `-d` to also search summaries and descriptions, which lets a word like "intrusion" find it too. `tee` prints the output and saves it to the file at the same time.

---

## Step 3: Confirm before installing with the full details

```bash
zypper info fail2ban | tee /root/answers/02-research-info.txt
```

`zypper info` prints the candidate's full details (version, size, summary) without installing anything. That lets you confirm it really is the right package before you commit to an install.

---

## Step 4: Research the second change: confirm before removing

```bash
zypper search --installed-only telnet-server | tee /root/answers/03-confirm-telnet-installed.txt
```

This confirms that `telnet-server` really is on this host, using `zypper`'s own installed-only filter, instead of assuming so from the request alone. The row should start with `i` in the status column.

---

## Step 5: Apply the conservative patch policy

```bash
zypper patch
```

This applies only the updates that a currently published patch covers, which is the conservative choice for a security-focused policy. Any newer version that no patch covers is left alone. `zypper update` would apply more than this policy allows.

---

## Step 6: Act on the research: install and remove

```bash
zypper install fail2ban
zypper remove telnet-server
```

Both actions now rest on the research you saved in steps 2 to 4, not on guesswork.

---

## Step 7: Review the operation history

```bash
zypper history | tail -15
```

This confirms that the patch run, the `fail2ban` install and the `telnet-server` removal all happened, each with a timestamp, in the order they ran. If your `zypper` answers that `history` is an unknown command, read the log file directly with `tail -n 15 /var/log/zypp/history`. Remember that this is an audit log, not a rollback tool like `dnf history undo`.

---

## Verification

```bash
cat /root/answers/01-research-search.txt
```
Expected: a row naming `fail2ban`.

```bash
cat /root/answers/02-research-info.txt
```
Expected: the full `fail2ban` details, including a `Version` field.

```bash
cat /root/answers/03-confirm-telnet-installed.txt
```
Expected: a row for `telnet-server` marked `i` (installed) in the status column.

```bash
rpm -q fail2ban
```
Expected: a version string, which confirms the install.

```bash
rpm -q telnet-server
```
Expected: `package telnet-server is not installed`, which confirms the removal.

```bash
zypper history | tail -15
```
Expected: the `fail2ban` install entry, followed later by the `telnet-server` removal entry, in the order you ran them.

Then leave the container with `exit` and send the lab for grading with `astrona submit -c sections/section-070/capstone/labs/lab-01`.
