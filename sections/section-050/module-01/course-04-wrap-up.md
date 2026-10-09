# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and both missions in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about taking crates from a depot Ubuntu does not run: trusting its seal for that depot only, choosing an exact version and keeping it there.

**From [Scoped Trust With Keyrings And signed-by](./course-01-scoped-trust.md):**

- `apt-key add` is deprecated because it puts a key in one global keyring that vouches for every repository.
- The modern way keeps each vendor's key in its own file under `/etc/apt/keyrings/`, converted with `gpg --dearmor`.
- `curl -fsSL` downloads the key safely, and `gpg --show-keys` lets you check it before you trust it.

**From [Adding The Repository And Checking It](./course-02-adding-the-repository.md):**

- The `deb [signed-by=...] <address> <suite> <component>` line goes in its own file under `/etc/apt/sources.list.d/`.
- `sudo apt update` applies the new line and is the first check: key problems show up here as `NO_PUBKEY` or signature errors.
- `apt-cache policy <package>` shows Installed, Candidate and a version table, including every depot that offers the same name.

**From [Installing An Exact Version And Holding It](./course-03-exact-version-and-hold.md):**

- `apt install <package>=<version>` needs the version copied character for character; `~` sorts before everything.
- `apt-mark hold` freezes one installed package against upgrades; always confirm with `apt-mark showhold`.
- A pin (a file under `/etc/apt/preferences.d/`) changes priorities and the Candidate; switching off a repository stops new versions arriving. Neither is a hold.

## Your missions

You proved these skills in graded missions, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Third-Party Repositories & Package Pinning Lab](./labs/lab-01/README.md) | Installing An Exact Version And Holding It | trusted a signed local depot with `signed-by=`, installed the vendor's exact `nginx` version and held it |
| [APT Pinning (not a hold) Lab](./labs/lab-02/README.md) | Installing An Exact Version And Holding It | pinned `curl` to Ubuntu's release pocket so `apt-cache policy` shows that version as the Candidate |

If you skipped one, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why is <code>signed-by=</code> safer than <code>apt-key add</code>?</summary>

`apt-key add` puts the key in a global keyring that `apt` uses for every repository. `signed-by=` ties a key in its own file to one repository line, so a stolen key only affects that one depot.
</details>

<details>
<summary>2. What does <code>gpg --dearmor</code> do, and why is it needed?</summary>

It turns an ASCII-armored text key into the binary keyring format that `signed-by=` expects. Without it, `apt update` fails with a signature or format error.
</details>

<details>
<summary>3. You added a repository file, but <code>apt-cache policy</code> does not show the vendor's version. What did you probably forget?</summary>

`sudo apt update`. Until it runs, `apt` still uses the old catalogue and knows nothing about the new depot.
</details>

<details>
<summary>4. In <code>apt-cache policy</code>, what is the difference between <code>Installed:</code> and <code>Candidate:</code>?</summary>

`Installed:` is the version on the system now. `Candidate:` is the version a plain `apt install` or `apt upgrade` would pick right now.
</details>

<details>
<summary>5. Is <code>1.24.0-1~jammy</code> newer or older than <code>1.24.0-1</code>?</summary>

Older. The tilde `~` sorts before everything, even before an empty string.
</details>

<details>
<summary>6. <code>sudo apt-mark hold nginx</code> exited with status 0. Is the package held?</summary>

Not proven. Run `apt-mark showhold` and check that `nginx` is in the list.
</details>

<details>
<summary>7. What is the difference between a hold and a pin?</summary>

A hold freezes one installed package so upgrades skip it. A pin changes priorities in a file under `/etc/apt/preferences.d/`, so a different version or depot becomes the Candidate; the package can still upgrade toward that target.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If a mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-051
astrona destroy ats-002-lab-051b
```

Then check that everything is gone:

```sh
astrona list
```
