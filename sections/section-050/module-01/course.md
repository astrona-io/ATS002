# Chapter 1: Third-Party Repositories & Package Pinning

Ubuntu's default archive is enormous, but it is not infinite. Sooner or later a team hands you a request like this: "We need the vendor's own build of this software, not the one packaged in the distro." Maybe it's a newer feature release, maybe it's a build compiled with an option Ubuntu's maintainers didn't enable, maybe it's software that simply never made it into the distro's archive at all. Whatever the reason, the fix is the same: teach `apt` about a repository the distro's maintainers don't control, and then be disciplined about exactly what you trust and exactly what version you keep.

In this chapter we add a third-party repository the correct, modern way, install one exact version from it, and then lock that version in place so it survives routine maintenance untouched.

---

## Part I: Why Trust Is the First Problem, Not an Afterthought

Before a single package installs from anywhere outside Ubuntu's own archive, `apt` needs a reason to believe the packages it downloads are genuinely what the vendor published, and not something altered in transit or swapped out by a hostile network. That reason is a cryptographic signature, and the thing that verifies it is a GPG public key.

For years, the standard way to add that trust was a command called `apt-key add`. If you open its manual page today:

```bash
man apt-key
```

You will find a deprecation notice right at the top. `apt-key add` drops a vendor's key into one enormous, shared, global keyring — the same keyring APT consults when verifying *every single repository it knows about*, not just the one you were trying to add. Picture it like handing a stranger a master key to every apartment in the building because you only wanted to let them into your own unit. If that vendor's key is ever compromised, or if the vendor turns out to be less trustworthy than you assumed, the blast radius is the entire system's trust model — not just that one repository.

The modern replacement narrows the blast radius back down to exactly one repository. It has two parts: a dedicated keyring file that holds *only* this vendor's key, and a `signed-by=` option inside the repository's own definition line that says, explicitly, "only this specific key may vouch for packages from this specific line — nothing else on the system is affected."

---

## Part II: Importing the Key the Modern Way

The convention on modern Debian and Ubuntu systems is to keep third-party keys in their own directory, `/etc/apt/keyrings/`, with one file per vendor:

```bash
sudo install -d -m 0755 /etc/apt/keyrings
```

`install -d` creates the directory (if it doesn't already exist) with the permissions you specify in one step — a small habit worth adopting over a plain `mkdir`, since it guarantees the mode is exactly what you intended rather than whatever your current umask happens to produce.

A vendor typically publishes their signing key as an ASCII-armored text block — human-readable, safe to paste into an email, but not the binary format APT actually wants to consume. You fetch it and convert it in one pipeline:

```bash
curl -fsSL https://vendor.example.com/nginx/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/vendor-nginx.gpg
```

`gpg --dearmor` strips the ASCII-armor wrapper and writes the raw binary keyring APT's `signed-by=` option expects. The `curl` flags matter here too: `-f` tells curl to fail loudly on an HTTP error instead of saving an error page as if it were the key, `-s` suppresses the progress meter, and `-L` follows redirects — a combination worth memorizing, since it shows up constantly whenever you're piping a remote resource straight into another command.

---

## Part III: Scoping Trust With `signed-by`

With the key safely isolated in its own file, the repository definition itself references it directly:

```bash
echo "deb [signed-by=/etc/apt/keyrings/vendor-nginx.gpg] https://vendor.example.com/nginx/ubuntu jammy main" | \
  sudo tee /etc/apt/sources.list.d/vendor-nginx.list
```

Read that line slowly. The `[signed-by=...]` bracket is the entire point: it tells APT that *this specific source line*, and only this line, should be verified against the key at that path. Without it, APT falls back to checking the package's signature against every key in the system's shared trusted set — precisely the loosely-scoped model `apt-key` relied on, and precisely what we're trying to avoid.

Notice, too, where each file lives. The key lives under `/etc/apt/keyrings/`. The repository line lives under `/etc/apt/sources.list.d/` as its own dedicated `.list` file, entirely separate from the shared `/etc/apt/sources.list` that governs Ubuntu's own default repositories. Keeping third-party configuration physically separate from the distro's own is not just tidiness — it means removing a vendor later is a matter of deleting one file, cleanly, with nothing else to untangle.

---

## Part IV: Confirming the Repository Registered

Before installing anything, refresh APT's view of the world and ask it what it now knows:

```bash
sudo apt update
apt-cache policy nginx
```

`apt update` re-fetches every configured repository's package index — including the new vendor line you just added. If the key or the `signed-by=` path is wrong, this is where you'll find out, with an error like `NO_PUBKEY` or a signature verification failure, rather than silently failing later.

`apt-cache policy nginx` then shows you, package by package, exactly what APT currently believes is available for `nginx` and from where:

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

This is worth pausing on: two different repositories can both legitimately offer a package sharing the exact same name. Ubuntu's own archive has its `nginx` build; the vendor has theirs. `apt-cache policy` is how you see both candidates side by side, along with the numeric priority (higher wins ties) and the exact version string each source publishes — the version string you'll need, copied verbatim, for the next step.

---

## Part V: Installing an Exact Version, Not "Latest"

Most of the time, `apt install nginx` is exactly right — grab whatever the highest-priority candidate is and move on. But "the vendor's specific build, exactly" calls for something more precise: APT's `=version` syntax.

```bash
sudo apt install nginx=1.24.0-1~jammy
```

That `=1.24.0-1~jammy` is not decorative. Debian-style version strings are exact-match — the tilde (`~`), the revision suffix, every character matters. Copy it verbatim from the `apt-cache policy` output rather than retyping it from a task description or from memory; a single mismatched character and APT reports it can't find a candidate matching the request at all, rather than guessing at the closest version.

---

## Part VI: Locking the Version With a Hold

Installing the right version is only half the job. Left alone, the very next `apt upgrade` will cheerfully move `nginx` to whatever newer build the vendor (or Ubuntu's own archive) publishes next. If your team specifically needs this exact build — because it was validated, because a newer one broke something, because a client contract specifies it — you need to tell APT to leave this one package alone.

```bash
sudo apt-mark hold nginx
```

Think of a hold as sticking a "do not touch" note directly onto one package's file in APT's records. `apt upgrade` and `apt full-upgrade` will still cheerfully upgrade everything else on the system; they will simply skip over `nginx` every time, without uninstalling it or making it any less usable in the meantime. If you ever do want to move it later — a deliberate, planned upgrade — `apt-mark unhold nginx` removes the note, and a normal `apt install`/`apt upgrade` can touch it again.

Confirm the hold actually took:

```bash
apt-mark showhold
```

```text
nginx
```

This last step matters more than it looks. A hold applied through a script or in a hurry can silently fail to apply, or apply to the wrong package name (a metapackage instead of the binary you meant). `apt-mark showhold` is cheap insurance — always check the actual resulting state, not just that the command exited without complaint.

---

## Part VII: Two Separate Mechanisms, Easy to Confuse

It's worth being precise about what a hold *is not*. `apt-mark hold` is not APT's "pinning" system (the separate `/etc/apt/preferences.d/` mechanism, governed by `man apt_preferences`), and it doesn't stop you from deliberately reinstalling or downgrading the package yourself later — it only stops *automatic* upgrade operations from touching it. And a hold does not deactivate the repository itself: the vendor's line stays active, still publishing new versions, still fully functional for anything else you might want from it. If someone later removes the hold without first checking what the vendor has since published, the next upgrade can jump several versions at once, silently.

---

## Self-Check and Verification

Test your understanding before moving to the hands-on lab:
1.  **Blast Radius**: In one sentence, explain why `signed-by=` is a narrower trust model than `apt-key add`. *(Answer: `signed-by=` scopes a key to verifying only the one repository line that references it, while `apt-key add` places the key in a global keyring trusted for every configured repository on the system.)*
2.  **File Locations**: Where does a third-party repository's GPG keyring file conventionally live, and where does the repository's own `.list` definition live? *(Answer: the key lives under `/etc/apt/keyrings/`; the repository definition lives under `/etc/apt/sources.list.d/` as its own file, separate from the shared `/etc/apt/sources.list`.)*
3.  **Two Mechanisms**: If you hold a package with `apt-mark hold` and then someone runs `apt-get dist-upgrade --allow-change-held-packages`, what happens? *(Answer: the override flag explicitly bypasses the hold, and the package can be upgraded anyway — a hold is a default-behavior safeguard, not an unbreakable lock.)*
