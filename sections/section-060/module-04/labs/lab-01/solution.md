# Solution Walkthrough

This walkthrough answers each research question with one read-only command and saves the output with `tee`, so you see it on screen and in the file at the same time. The lab's setup enabled EPEL and installed `python3-pip`, `python3-setuptools` and `python3-requests`, so the `python3-` list has real content.

All commands below run **inside the `rpmbox` container**. Get a shell first:
```bash
docker exec -it rpmbox bash
mkdir -p /home/candidate/answers
```

If Docker answers with a permission error, run `docker exec` with `sudo` in front.

---

## Step 1: Search by keyword

```bash
dnf search fail2ban | tee /home/candidate/answers/search.txt
```
`dnf search` matches package names *and* summary text, so it finds relevant hits even when you do not know the exact name. A search for a word from the summary works too, as long as the saved output mentions `fail2ban`, which the grader checks.

---

## Step 2: Pull full details, without installing

```bash
dnf info httpd | tee /home/candidate/answers/info.txt
```
This only reads `dnf`'s copy of the repository catalogue; the set of installed packages does not change. `rpm -q httpd` gives the same "not installed" answer before and after. The grader checks the file for the `Name` and `Version` lines and checks that `httpd` is still not installed.

---

## Step 3: Find what provides a command that is not installed

```bash
dnf provides '*/ip' | tee /home/candidate/answers/provides.txt
```
The `*/ip` glob matches the command name in any directory (`/usr/sbin/ip` here), which is more robust than guessing an exact path. Expect the answer to point at the `iproute` package. The grader checks that the file mentions `iproute` and a path ending in `/ip`.

---

## Step 4: List installed packages by pattern

```bash
dnf list installed | grep '^python3-' | tee /home/candidate/answers/python-packages.txt
```
The `^` anchors the match to the start of the line, the package-name column, so a `python3-` that appears elsewhere in a line does not count. The grader looks for lines starting with `python3-pip.`, `python3-setuptools.` and `python3-requests.`.

---

## Quick verification

```bash
cat /home/candidate/answers/search.txt | grep -i fail2ban
cat /home/candidate/answers/info.txt | grep -E '^(Name|Version)'
cat /home/candidate/answers/provides.txt | grep -i iproute
cat /home/candidate/answers/python-packages.txt | grep -c '^python3-'
```

From your own computer, not the lab machine, send the lab for grading:

```bash
astrona submit -c sections/section-060/module-04/labs/lab-01
```
