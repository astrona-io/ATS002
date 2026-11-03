# Solution Walkthrough

Five onboarding tasks. Do Task 1 first: Task 2 needs `curl`, and this machine does not start with it. Run `astrona submit` after each task to see which checks already pass.

---

## Task 1: Install the baseline toolchain

```bash
sudo apt install curl git jq
```

All three in one command, planned as a single transaction: one consistent dependency plan instead of three separate ones. This also unblocks Task 2, which needs `curl` to download the vendor's key over HTTP.

---

## Task 2: Trust, install and hold the vendor's `telemetry-agent`

**Dedicated keyring directory:**

```bash
sudo install -d -m 0755 /etc/apt/keyrings
```

**Download and convert the vendor's key:**

```bash
curl -fsSL http://127.0.0.1:8200/app-tools-archive-keyring.asc | \
  sudo gpg --dearmor -o /etc/apt/keyrings/app-tools.gpg
```

This never touches the deprecated global `apt-key` keyring: the key lives only in this one dedicated file.

**Add the repository, tied to this key.** Save this as `/etc/apt/sources.list.d/app-tools.list`:

```text
deb [signed-by=/etc/apt/keyrings/app-tools.gpg] http://127.0.0.1:8200 app-tools main
```

**Refresh and check that it registered.** Apply it:

```bash
sudo apt update
```

Then check the result:

```bash
apt-cache policy telemetry-agent
```

```text
telemetry-agent:
  Installed: (none)
  Candidate: 2.4.0-1~apptoolsfake1
  Version table:
     2.4.0-1~apptoolsfake1 500
        500 http://127.0.0.1:8200 app-tools/main amd64 Packages
```

Copy that exact candidate version string for the next step.

**Install the exact vendor version and hold it:**

```bash
sudo apt install telemetry-agent=2.4.0-1~apptoolsfake1
sudo apt-mark hold telemetry-agent
apt-mark showhold
```

The `=version` form is an exact match: every character counts. `apt-mark hold` stops a routine `apt upgrade` or `apt full-upgrade` from moving this package, without removing it or switching off the repository.

---

## Task 3: Recover the stuck `tree` package

```bash
dpkg -l | grep tree
```

```text
iF  tree  2.1.1-2  amd64  displays an indented directory tree, in color
```

`iF` (half-configured) is the fingerprint of an interrupted install.

```bash
sudo dpkg --configure -a
sudo apt --fix-broken install
```

`--configure -a` finishes configuring every waiting package, not just the one you noticed. `apt --fix-broken install` is the safety net right after: it catches a dependency that is really missing, which `dpkg --configure -a` alone cannot fix.

```bash
dpkg -l | grep tree
# ii  tree  2.1.1-2  amd64  displays an indented directory tree, in color

sudo dpkg --audit
# (no output)
```

---

## Task 4: Find and hold the whole observability agent family

```bash
apt list --installed 2>/dev/null | grep -E '^obsagent-'
```

The `^` anchors the match to the start of the package name, so nothing unrelated that merely contains `obsagent-` is matched.

```bash
apt list --installed 2>/dev/null | grep -E '^obsagent-' | cut -d/ -f1 | xargs sudo apt-mark hold
apt-mark showhold
```

The whole family is held in one `apt-mark hold` call, not one package at a time. A family that depends on itself is only as version-safe as its least-protected member, so every member must be held.

---

## Task 5: Answer the onboarding research question

```bash
apt-cache policy redis-server
```

```text
redis-server:
  Installed: (none)
  Candidate: 5:7.0.15-1ubuntu0.24.04.1
  Version table:
     5:7.0.15-1ubuntu0.24.04.1 500
        500 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages
        500 http://archive.ubuntu.com/ubuntu noble/main amd64 Packages
```

This is purely read-only: nothing about `redis-server` gets installed. This recorded output may not match your machine: the source line may name another component (for example `universe` instead of `main`), and the version changes as the archive is updated. Record the candidate version and its source repository:

```bash
{
  echo "Candidate: 5:7.0.15-1ubuntu0.24.04.1"
  echo "Source: http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages"
} > /opt/course/onboarding/redis-candidate.txt
```

Your exact version and pocket may differ, depending on the current state of the archive mirror. Always copy them from your own `apt-cache policy redis-server` output, never retype them from memory. The grader checks that the file contains the live candidate version and the repository address of its first source line.

---

## Command Summary

```bash
# 1. Toolchain
sudo apt install curl git jq

# 2. Vendor repo: trust, pin, hold
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL http://127.0.0.1:8200/app-tools-archive-keyring.asc | sudo gpg --dearmor -o /etc/apt/keyrings/app-tools.gpg
```

Save `/etc/apt/sources.list.d/app-tools.list` with the line from Task 2, then:

```bash
sudo apt update
apt-cache policy telemetry-agent
sudo apt install telemetry-agent=<vendor-version>
sudo apt-mark hold telemetry-agent

# 3. Recover tree
dpkg -l | grep tree
sudo dpkg --configure -a
sudo apt --fix-broken install

# 4. obsagent family
apt list --installed 2>/dev/null | grep -E '^obsagent-' | cut -d/ -f1 | xargs sudo apt-mark hold
apt-mark showhold

# 5. Research answer
apt-cache policy redis-server
# write Candidate: / Source: into /opt/course/onboarding/redis-candidate.txt
```

When every check looks right, send the lab for grading:

```bash
astrona submit -c sections/section-050/capstone/labs/lab-01
```
