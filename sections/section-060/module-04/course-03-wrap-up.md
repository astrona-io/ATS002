# Wrap-Up: Mission Debrief

Well flown, astronaut. You can now research any crate before you order it, and find the right crate for a missing command. Look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about read-only package research with `dnf` and `rpm`.

**From [Finding and Describing a Package](./course-01-search-and-describe.md):**

- `dnf search <keyword>` matches names and summaries; `dnf search all` adds the long description.
- `dnf list available '<glob>'` matches names only, when you know roughly how a name is spelled.
- `dnf info <name>` prints one package's full details from the catalogue and changes nothing. `--refresh` forces a fresh catalogue.

**From [Provides Lookups and Cross-Checking with rpm](./course-02-provides-and-cross-referencing.md):**

- `dnf provides <path>` searches every repository's catalogue for the package that would give you a file, installed or not. `'*/name'` matches a command in any directory.
- `rpm -qf` only knows installed packages, so it cannot answer "what would I install?".
- `dnf list installed | grep '^python3-'` lists installed packages by an anchored pattern.
- Use `dnf` for what is available and `rpm -qi` or `rpm -qf` for what is really installed.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [DNF Package Information Lookup Lab](./labs/lab-01/README.md) | Provides Lookups and Cross-Checking with rpm | searched, described and looked up packages without installing anything, and saved each answer |

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You need "something that blocks brute-force logins" and do not know the package name. Which command do you start with?</summary>

`dnf search <keyword>`. It matches names and summaries. If it finds nothing, try `dnf search all <keyword>`.
</details>

<details>
<summary>2. Does <code>dnf info httpd</code> install anything or show what is installed?</summary>

Neither. It prints details from the repository catalogue and changes nothing. `rpm -qi httpd` shows the installed copy, if there is one.
</details>

<details>
<summary>3. The <code>ip</code> command is missing. Why does <code>rpm -qf /usr/sbin/ip</code> not help?</summary>

`rpm -qf` only searches installed packages. If nothing installed owns that file, it has no answer. `dnf provides '*/ip'` searches the repository catalogue instead.
</details>

<details>
<summary>4. Why write <code>dnf provides '*/ip'</code> instead of <code>dnf provides /usr/bin/ip</code>?</summary>

You may not know the exact directory. `*/` matches any directory in front of the name.
</details>

<details>
<summary>5. Why use <code>grep '^python3-'</code> and not <code>grep 'python3-'</code>?</summary>

The `^` anchors the match to the start of the line, the package-name column. Without it you also match names such as `libpython3-...` and text in other columns.
</details>

<details>
<summary>6. Your catalogue may be old and you want to know exactly what is installed. Which tool do you trust?</summary>

`rpm` (`rpm -qi`, `rpm -qf`). It reads the local RPM database, which is always current and needs no network.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-064
```
