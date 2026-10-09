# Solution Guide: Zypper Package Information Lookup

This guide walks through four real `zypper` research tasks inside the `zypperbox` openSUSE Leap 15.6 container. Nothing is installed, removed or changed along the way: every command here only reads. The grader reads the four files in `/root/answers` and checks that `nginx` is still not installed.

---

## Step 0: Enter the zypperbox container

```bash
docker exec -it zypperbox bash
```

Every command from here on runs inside this shell, not on the Ubuntu host. If Docker refuses with a permission error on the host, run the same command with `sudo` in front. The lab setup has already created `/root/answers` for your findings.

---

## Step 1: Keyword search ("I do not know the exact name")

```bash
zypper search fail2ban | tee /root/answers/01-search.txt
```

`zypper search` (short form `zypper se`) matches package names and ignores upper and lower case. `tee` prints the output on screen and writes it to the file at the same time. Add `-d` to also search summaries and descriptions, so a rough keyword such as "ban" or "intrusion" can find the package without its exact name. The leading `S` column shows whether each hit is installed; here it should be empty, because `fail2ban` is not installed in this lab.

---

## Step 2: Full details for one exact package, without installing it

```bash
zypper info nginx | tee /root/answers/02-info.txt
```

`zypper info` only matches the exact package name. It does no partial matching and no description search the way `search -d` does. It prints the version, architecture, vendor, installed size, source repository and description, all from the cached repository metadata. Running it changes nothing that is installed; the `Installed` field in the output should read `No`. The grader looks for the `Name : nginx` line and a `Version` field.

---

## Step 3: Which package supplies a missing command

```bash
zypper what-provides /usr/sbin/ip | tee /root/answers/03-what-provides.txt
```

`zypper what-provides` searches the published metadata of the configured repositories for any package that would place a file at that exact path, whether it is installed or not. The result should name `iproute2`. It is the `zypper` version of `dnf provides`.

---

## Step 4: Filtered installed-only listing

```bash
zypper search --installed-only 'python3-*' | tee /root/answers/04-installed-python3.txt
# shorthand: zypper se -i 'python3-*'
```

The `-i` (`--installed-only`) option keeps only packages that match the pattern **and** are installed, in one `zypper` command. The lab setup installed `python3-base` and `python3-pip` so this step has real results. Both should appear with an `i` in the leading status column. The grader also fails the answer if any `python3-` row is not marked installed, which is what an unfiltered search would produce.

---

## Verification

```bash
cat /root/answers/01-search.txt
```
Expected: a row naming `fail2ban`.

```bash
cat /root/answers/02-info.txt
```
Expected: full details for `nginx`, including `Installed : No`.

```bash
cat /root/answers/03-what-provides.txt
```
Expected: a row naming `iproute2`.

```bash
cat /root/answers/04-installed-python3.txt
```
Expected: rows for `python3-base` and `python3-pip`, each marked `i` (installed) in the status column.

```bash
rpm -q nginx fail2ban 2>&1
```
Expected: both report "package ... is not installed", which confirms the lab stayed read-only.

Then leave the container with `exit` and send the lab for grading with `astrona submit -c sections/section-070/module-02/labs/lab-01`.
