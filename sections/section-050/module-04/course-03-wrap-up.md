# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about read-only research: finding out what a package is, which version you would get and where it would come from, before you change anything.

**From [Finding And Describing A Package](./course-01-finding-and-describing.md):**

- `apt search <keyword>` matches names and descriptions; use it when you do not know the exact name.
- `apt list '<glob>'` matches names only; use it when you know roughly how the name is spelled.
- `apt show <name>` prints the cached metadata of one package (dependencies, sizes, description) and changes nothing.

**From [Installed Versus Candidate](./course-02-installed-vs-candidate.md):**

- `apt-cache policy <name>` shows Installed, Candidate and a version table with each version's priority and source repository.
- `apt list --installed | grep '^prefix'` lists installed packages whose names start with a prefix; the `^` anchor keeps the match precise.
- `dpkg -s <name>` reads the `dpkg` database directly and is the final word on what is installed.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [APT Package Information Lookup Lab](./labs/lab-01/README.md) | Installed Versus Candidate | searched, described and compared packages read-only, and saved each answer to a file under `/opt/course/apt-research/` |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. You need "something that blocks repeated failed SSH logins" but do not know its name. Which command do you start with?</summary>

`apt search <keyword>`, for example `apt search fail2ban`. It searches names and descriptions.
</details>

<details>
<summary>2. What is the difference between <code>apt search</code> and <code>apt list '&lt;glob&gt;'</code>?</summary>

`apt search` matches the keyword in names and descriptions. `apt list` with a glob matches package names only.
</details>

<details>
<summary>3. Which command tells you which repository a package's candidate version would come from?</summary>

`apt-cache policy <name>`. The version table names the repository of each version. `apt show` does not.
</details>

<details>
<summary>4. In <code>apt-cache policy</code>, two versions both have priority 500. Which one becomes the Candidate?</summary>

The higher version. When priorities tie, the higher version wins.
</details>

<details>
<summary>5. Why do you write <code>grep '^python3-'</code> and not <code>grep 'python3-'</code>?</summary>

The `^` anchors the match to the start of the line, so only names that begin with `python3-` match. Without it, names like `libpython3-...` and matches inside version strings sneak in.
</details>

<details>
<summary>6. The catalogue may be days old. Which command answers "is nginx installed right now" most reliably?</summary>

`dpkg -s nginx`. It reads the `dpkg` database directly and does not depend on the `apt` cache.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-054
```

Then check that everything is gone:

```sh
astrona list
```
