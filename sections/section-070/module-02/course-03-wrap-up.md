# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about researching packages with `zypper` before you change anything, and knowing when `rpm` is the better tool.

**From [Search, Info and What-Provides](./course-01-the-three-questions.md):**

- `zypper search` finds packages by name when you know the topic but not the exact name. Add `-d` to search summaries and descriptions too.
- `zypper info` needs the exact package name and prints its full details without installing it.
- `zypper what-provides <path>` reads repository metadata to name the package that would supply a file, even one that is not installed.
- All three only read; none needs `sudo`.

**From [Installed-Only Search and the rpm Fallback](./course-02-installed-only-and-rpm-fallback.md):**

- `zypper search --installed-only '<pattern>'` (short form `-i`) lists only installed matches, with no `grep` needed.
- `rpm -qi` and `rpm -qf` read the local RPM database: no network, always current, but blind to packages that are not installed.
- Use `zypper` for "what is out there" and `rpm` for "what is really here".

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Zypper Package Information Lookup Lab](./labs/lab-01/README.md) | Installed-Only Search and the rpm Fallback | found `fail2ban` by keyword, read `nginx`'s details without installing it, named `iproute2` as the supplier of `/usr/sbin/ip`, and listed installed `python3-*` packages |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You only know you need "something that blocks brute-force logins". Which command do you start with?</summary>

`zypper search`, with a keyword. Add `-d` so it also looks through summaries and descriptions. `zypper info` would need the exact name, which you do not know yet.
</details>

<details>
<summary>2. Does <code>zypper info nginx</code> install or change anything?</summary>

No. It only reads the cached repository metadata and prints the details. The `Installed` field tells you whether the package is on the system.
</details>

<details>
<summary>3. A script fails because <code>/usr/sbin/ip</code> is missing. Why does <code>rpm -qf /usr/sbin/ip</code> not help?</summary>

`rpm -qf` only searches the RPM database of installed packages. The file is not installed, so no installed package owns it. `zypper what-provides /usr/sbin/ip` searches repository metadata instead and names the package.
</details>

<details>
<summary>4. How do you list only installed packages whose names start with <code>python3-</code>?</summary>

`zypper search --installed-only 'python3-*'`, or the short form `zypper se -i 'python3-*'`. The quotes stop the shell from expanding the `*`.
</details>

<details>
<summary>5. Why is <code>zypper se -i</code> better than <code>zypper se 'python3-*' | grep</code>?</summary>

The built-in filter is exact. Scanning the status column with `grep` or by eye is slower and easy to get wrong across many rows.
</details>

<details>
<summary>6. Which tool needs no network and always shows what is installed this second?</summary>

`rpm` (`rpm -qi`, `rpm -qf`, `rpm -qa`). It reads the local RPM database.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-072
```
