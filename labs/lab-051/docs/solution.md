# Solution Walkthrough

Follow these steps to trust, pin, and hold the vendor's `nginx` build.

---

## Step 1: Create the dedicated keyring directory

```bash
sudo install -d -m 0755 /etc/apt/keyrings
```

`install -d` creates the directory with the exact permissions given, in one step.

---

## Step 2: Fetch and dearmor the vendor's key

```bash
curl -fsSL http://127.0.0.1:8100/vendor-nginx-archive-keyring.asc | \
  sudo gpg --dearmor -o /etc/apt/keyrings/vendor-nginx.gpg
```

`curl -fsSL` fails loudly on an HTTP error, suppresses the progress meter, and follows redirects. `gpg --dearmor` converts the ASCII-armored key into the binary format APT's `signed-by=` option expects. This never touches the deprecated global `apt-key` keyring — the key lives only in this one dedicated file.

---

## Step 3: Add the repository, scoped to this key

```bash
echo "deb [signed-by=/etc/apt/keyrings/vendor-nginx.gpg] http://127.0.0.1:8100 vendor-nginx main" | \
  sudo tee /etc/apt/sources.list.d/vendor-nginx.list
```

The `[signed-by=...]` bracket scopes trust to exactly this repository line — nothing else on the system is affected by this key. The file lives under `/etc/apt/sources.list.d/`, entirely separate from the shared `/etc/apt/sources.list` governing Ubuntu's own default repositories.

---

## Step 4: Refresh and confirm the repository registered

```bash
sudo apt update
apt-cache policy nginx
```

If the key or `signed-by=` path is wrong, `apt update` reports it here — a `NO_PUBKEY` or signature-verification error — rather than silently failing later. `apt-cache policy nginx` should now show a version table with (at least) two entries: one from `http://127.0.0.1:8100`, one from Ubuntu's own archive, exactly the "two sources, same package name" situation a real vendor repository creates.

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

Copy the vendor's exact version string (`1.25.4-1~vendorfake1`) from this output for the next step.

---

## Step 5: Install the exact vendor version

```bash
sudo apt install nginx=1.25.4-1~vendorfake1
```

The `=version` syntax is an exact match — every character, including the `~` and the revision suffix, matters. A single mismatched character makes APT report it can't find a matching candidate at all.

---

## Step 6: Hold the package at this version

```bash
sudo apt-mark hold nginx
```

This marks `nginx` so `apt upgrade`/`apt full-upgrade` skip it, without uninstalling it or making it any less usable. The vendor repository stays active and fully configured — the hold only stops *automatic* upgrade operations from touching this one package.

Confirm the hold actually took:

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
echo "deb [signed-by=/etc/apt/keyrings/vendor-nginx.gpg] http://127.0.0.1:8100 vendor-nginx main" | sudo tee /etc/apt/sources.list.d/vendor-nginx.list
sudo apt update
apt-cache policy nginx
sudo apt install nginx=1.25.4-1~vendorfake1
sudo apt-mark hold nginx
apt-mark showhold
```

Once verified, run the local validation suite to pass the lab!
