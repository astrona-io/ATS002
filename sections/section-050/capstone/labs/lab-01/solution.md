# Solution Walkthrough

Five onboarding tasks. Do Task 1 first — Task 2 needs `curl`, which this VM does not start with.

---

## Task 1: Install the baseline toolchain

```bash
sudo apt install curl git jq
```

All three in one invocation, resolved as a single transaction — the same reasoning as any other "install these together" task: one consistent dependency resolution instead of three independent ones. This also unblocks Task 2, which needs `curl` to fetch the vendor's key over HTTP.

---

## Task 2: Trust, pin, and hold the vendor's `telemetry-agent`

**Dedicated keyring directory:**

```bash
sudo install -d -m 0755 /etc/apt/keyrings
```

**Fetch and dearmor the vendor's key:**

```bash
curl -fsSL http://127.0.0.1:8200/app-tools-archive-keyring.asc | \
  sudo gpg --dearmor -o /etc/apt/keyrings/app-tools.gpg
```

This never touches the deprecated global `apt-key` keyring — the key lives only in this one dedicated file.

**Add the repository, scoped to this key:**

```bash
echo "deb [signed-by=/etc/apt/keyrings/app-tools.gpg] http://127.0.0.1:8200 app-tools main" | \
  sudo tee /etc/apt/sources.list.d/app-tools.list
```

**Refresh and confirm it registered:**

```bash
sudo apt update
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

The `=version` syntax is an exact match — every character matters. `apt-mark hold` stops routine `apt upgrade`/`apt full-upgrade` from moving this specific package without uninstalling it or disabling the repository.

---

## Task 3: Recover the stuck `tree` package

```bash
dpkg -l | grep tree
```

```text
iF  tree  2.1.1-2  amd64  displays an indented directory tree, in color
```

`iF` — half-configured — is the fingerprint of an interrupted install.

```bash
sudo dpkg --configure -a
sudo apt --fix-broken install
```

`--configure -a` resumes configuration for every pending package, not just the one you noticed. `apt --fix-broken install` is the safety net immediately after — it catches a genuinely missing dependency that `dpkg --configure -a` alone can't resolve.

```bash
dpkg -l | grep tree
# ii  tree  2.1.1-2  amd64  displays an indented directory tree, in color

sudo dpkg --audit
# (no output)
```

---

## Task 4: Find and bulk-hold the observability agent family

```bash
apt list --installed 2>/dev/null | grep -E '^obsagent-'
```

Anchored (`^`) and matched against the exact prefix — this avoids accidentally matching anything unrelated.

```bash
apt list --installed 2>/dev/null | grep -E '^obsagent-' | cut -d/ -f1 | xargs sudo apt-mark hold
apt-mark showhold
```

The whole family is held together in one `apt-mark hold` call, not one at a time — the same reasoning as the PHP module family exercise: an interdependent set is only as version-safe as its least-held member.

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

This is purely read-only — nothing about `redis-server` gets installed. Record the candidate version and its source repository:

```bash
{
  echo "Candidate: 5:7.0.15-1ubuntu0.24.04.1"
  echo "Source: http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages"
} > /opt/course/onboarding/redis-candidate.txt
```

(Your exact version/pocket may differ depending on the currently mirrored archive state — always copy it from your own `apt-cache policy redis-server` output, never retype it from memory.)

---

## Command Summary

```bash
# 1. Toolchain
sudo apt install curl git jq

# 2. Vendor repo: trust, pin, hold
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL http://127.0.0.1:8200/app-tools-archive-keyring.asc | sudo gpg --dearmor -o /etc/apt/keyrings/app-tools.gpg
echo "deb [signed-by=/etc/apt/keyrings/app-tools.gpg] http://127.0.0.1:8200 app-tools main" | sudo tee /etc/apt/sources.list.d/app-tools.list
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

Once verified, run the local validation suite to pass the lab!
