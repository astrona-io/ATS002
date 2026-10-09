# Wrap-Up: Mission Debrief

Well flown, astronaut. You have finished every part and the mission in this module. Before you move on, look back at what you learned, check yourself, and clean up anything still running.

## What you learned

This module was about handling packages as groups: one transaction, one pattern and one checked bulk action.

**From [One Transaction And Finding A Family](./course-01-one-transaction-and-finding-a-family.md):**

- Give every related package to one `apt install` call, so their dependencies are planned together as one transaction.
- `build-essential` is a metapackage: it only pulls in the toolchain packages as dependencies.
- `grep -E '^php8\.1-'` matches a family precisely: `\.` is a literal dot, and `^` anchors to the start of the name. `cut -d/ -f1` leaves only the names.

**From [Bulk Actions Across A Matched Set](./course-02-bulk-actions-across-a-set.md):**

- `... | cut -d/ -f1 | xargs sudo apt-mark hold` holds every matched package in one call.
- A partial hold on a family that depends on itself lets the unheld members drift to a newer release.
- `apt-mark showhold`, compared line for line with your match, proves the hold; the pipeline's exit code does not. `xargs -r` skips the command on empty input.

## Your missions

You proved these skills in a graded mission, right after the part that taught the last of them:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [APT Package Groups & Bulk Operations Lab](./labs/lab-01/README.md) | Bulk Actions Across A Matched Set | installed a toolchain in one transaction and held every installed `php8.1-*` package |

If you skipped it, go back to it now. The exam asks for exactly these skills.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Why install <code>build-essential git cmake pkg-config</code> in one call instead of four?</summary>

`apt` plans the dependencies of all four together as one transaction, so it finds one set of versions that suits all of them. Separate calls each plan on their own and are more fragile and slower.
</details>

<details>
<summary>2. What is a metapackage?</summary>

An empty package whose only job is to pull in other packages as dependencies, for example `build-essential`.
</details>

<details>
<summary>3. Why does <code>grep 'php8.1-'</code> give a wrong match set?</summary>

The unescaped `.` matches any character, and without `^` the pattern also matches in the middle of a line. Use `grep -E '^php8\.1-'`.
</details>

<details>
<summary>4. Why do you need <code>cut -d/ -f1</code> before <code>apt-mark</code>?</summary>

`apt list` prints `name/repo,now version arch [installed]`. `cut -d/ -f1` keeps only the name, which is what `apt-mark` takes.
</details>

<details>
<summary>5. Why is holding only <code>php8.1-cli</code> and <code>php8.1-fpm</code> risky?</summary>

The other family members can still upgrade to a newer PHP release, which leaves a mixed installation whose parts no longer fit together.
</details>

<details>
<summary>6. The hold pipeline exited with status 0. How do you prove the whole family is held?</summary>

Run `apt-mark showhold` and compare it line for line with the names your pattern matched.
</details>

## Clean up

Each mission runs a virtual machine on your computer. When you are done with this module, remove any mission that is still running.

First, see what is still running:

```sh
astrona list
```

If the mission is still there, remove it. The command takes its **name**, not its folder path:

```sh
astrona destroy ats-002-lab-055
```

Then check that everything is gone:

```sh
astrona list
```
