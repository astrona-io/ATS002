# Solution Walkthrough

Follow these steps to trust the vendor's repository, install its exact `nginx` build and hold it. Run `astrona submit` after each step to see which checks already pass.

---

## Step 1: Create the dedicated keyring directory

```bash
sudo install -d -m 0755 /etc/apt/keyrings
```

`install -d` creates the directory with exactly the permissions you give it, in one step.

---

## Step 2: Download and convert the vendor's key

```bash
curl -fsSL http://127.0.0.1:8100/vendor-nginx-archive-keyring.asc | \
  sudo gpg --dearmor -o /etc/apt/keyrings/vendor-nginx.gpg
```

`curl -fsSL` fails loudly on an HTTP error, hides the progress meter and follows redirects. `gpg --dearmor` turns the ASCII-armored text key into the binary format that APT's `signed-by=` option expects. This never touches the deprecated global `apt-key` keyring: the key lives only in this one dedicated file.

---

## Step 3: Add the repository, tied to this key

Save this as `/etc/apt/sources.list.d/vendor-nginx.list`:

```text
deb [signed-by=/etc/apt/keyrings/vendor-nginx.gpg] http://127.0.0.1:8100 vendor-nginx main
```

The `[signed-by=...]` bracket ties trust to exactly this repository line. Nothing else on the system is affected by this key. The file lives under `/etc/apt/sources.list.d/`, separate from the shared `/etc/apt/sources.list` that holds Ubuntu's own repositories.

At this point `astrona submit` should pass the trust check.

---

## Step 4: Refresh and check that the repository registered

Apply it:

```bash
sudo apt update
```

Then check the result:

```bash
apt-cache policy nginx
```

If the key or the `signed-by=` path is wrong, `apt update` reports it here with a `NO_PUBKEY` or signature error, instead of failing silently later. `apt-cache policy nginx` should now show a version table with at least two entries: one from `http://127.0.0.1:8100` and one from Ubuntu's own archive. That is the "two depots, one package name" situation a real vendor repository creates.

```text
nginx:
  Installed: (none)
  Candidate: <ubuntu-or-vendor-version, whichever priority wins>
  Version table:
     1.25.4-1~vendorfake1 500
        500 http://127.0.0.1:8100 vendor-nginx/main amd64 Packages
     1.24.0-... 500
        500 http://archive.ubuntu.com/ubuntu noble-updates/main amd64 Packages
```

This output is shortened: the `Candidate:` line and Ubuntu's version are placeholders. Both lines have priority `500`, so the higher version wins the Candidate slot. Copy the vendor's exact version string (`1.25.4-1~vendorfake1`) from your own output for the next step.

---

## Step 5: Install the exact vendor version

```bash
sudo apt install nginx=1.25.4-1~vendorfake1
```

The `=version` form is an exact match. Every character counts, including the `~` and the revision suffix. One wrong character and APT reports that it cannot find a matching version at all.

At this point `astrona submit` should pass the exact-version check.

---

## Step 6: Hold the package at this version

```bash
sudo apt-mark hold nginx
```

This marks `nginx` so `apt upgrade` and `apt full-upgrade` skip it, without removing it or making it less usable. The vendor repository stays active and fully configured: the hold only stops *automatic* upgrades from touching this one package.

Confirm that the hold took:

```bash
apt-mark showhold
```

```text
nginx
```

---

## Command Summary

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL http://127.0.0.1:8100/vendor-nginx-archive-keyring.asc | sudo gpg --dearmor -o /etc/apt/keyrings/vendor-nginx.gpg
```

Save `/etc/apt/sources.list.d/vendor-nginx.list` with the line from Step 3, then:

```bash
sudo apt update
apt-cache policy nginx
sudo apt install nginx=1.25.4-1~vendorfake1
sudo apt-mark hold nginx
apt-mark showhold
```

When every check looks right, send the lab for grading:

```bash
astrona submit -c sections/section-050/module-01/labs/lab-01
```
