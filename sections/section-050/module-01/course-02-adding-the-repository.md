# Part 2 — Adding the repository and confirming it registered

> Prerequisite: [Part 1 — Scoped trust: keyrings and `signed-by`](./course-01-scoped-trust.md). Next: [Part 3 — Installing an exact version, and locking it](./course-03-exact-version-and-hold.md).

The key is imported and isolated. Now the repository line itself — where it lives, how it names the key, and how to confirm `apt` accepted it *before* you install anything. This part also introduces the command that shows you a package can come from more than one place at once.

## The repository line

```bash
# shell: host, root
echo 'deb [signed-by=/etc/apt/keyrings/vendor-nginx.gpg] https://vendor.example.com/nginx/ubuntu jammy main' \
  | sudo tee /etc/apt/sources.list.d/vendor-nginx.list
```

Field by field: `deb` (binary packages), `[signed-by=...]` (the scoping bracket from Part 1), the base URL, the **suite** (`jammy` — the Ubuntu codename), and the **component** (`main`).

Two placement facts:

- The line goes in its **own file** under `/etc/apt/sources.list.d/`, not appended to the shared `/etc/apt/sources.list` that governs Ubuntu's own repos. Removing the vendor later is then `rm` of one file, cleanly.
- Without `[signed-by=...]`, `apt` falls back to verifying against every key in the shared trusted set — exactly the loose model from Part 1.

(Newer Ubuntu also supports the `deb822` `.sources` format — a multi-line `Types:`/`URIs:`/`Signed-By:` stanza — but the one-line `.list` form above is still fully supported and is what most tasks expect.)

## Confirm `apt` accepted it

```bash
sudo apt update
apt-cache policy nginx
```

`apt update` re-fetches every configured repository's index, **including the new line**. A wrong key path or a bad `signed-by=` surfaces here — `NO_PUBKEY`, `signature verification failed`, `not signed` — not silently later.

`apt-cache policy nginx` then shows what `apt` now believes is available:

```text
nginx:
  Installed: (none)
  Candidate: 1.24.0-1~jammy
  Version table:
     1.24.0-1~jammy 500
        500 https://vendor.example.com/nginx/ubuntu jammy/main amd64 Packages
     1.24.0-2ubuntu7 500
        500 http://archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages
```

The key realisation: **two repositories can each publish a package with the exact same name.** Ubuntu's archive has its `nginx`; the vendor has theirs. `apt-cache policy` is where you see both side by side:

- **`Installed:`** — what is on the system now (`(none)` here).
- **`Candidate:`** — what a plain `apt install` / `apt upgrade` would pick right now.
- **Version table** — every available version, its **priority** (the `500` — higher wins; ties go to the higher version), and the exact repository and version string of each.

Copy the version string you want from this output verbatim — Part 3 needs it character for character.

> [!WARNING]
> - **Appending to `/etc/apt/sources.list`** instead of a dedicated `.list` under `sources.list.d/` → the vendor config is now tangled with the distro's; removal is fiddly and error-prone.
> - **Skipping `apt update` after adding the line** → `apt-cache policy` and any install still see the old world; the new repo's packages appear missing.
> - **Ignoring an `apt update` warning** (`NO_PUBKEY`, `InRelease` not signed) → the repo is present but untrusted; installs from it will refuse or prompt. Fix the key/path now.
> - **Assuming one repo = one version** → the same name can resolve to a distro build *or* a vendor build depending on priority. Read the version table.

> *Put the `deb [signed-by=…] …` line in its own file under `/etc/apt/sources.list.d/`, run `apt update` to make `apt` accept and verify it, then read `apt-cache policy <pkg>` — Installed, Candidate, and a version table that shows every repo offering that name.*

## Reference

- `man 5 sources.list` — the one-line `deb` format and the newer `deb822` `.sources` stanza.
- `man apt-cache` — `policy`: Installed vs Candidate, priorities, the version table.
- `man apt_preferences` — how the `500` priorities are assigned and how pinning changes them (Part 3 contrasts this with a hold).
