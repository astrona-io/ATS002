# APT Package Information Lookup Lab

Welcome to a research mission, astronaut. Before anyone touches this training ship, mission control wants answers about its packages, and you must not change a thing while you find them.

Your job is to search for a package by keyword, read another package's full metadata, compare its installed and candidate versions and source repository, and list installed and upgradable packages by pattern. You save every answer to a file under `/opt/course/apt-research/`.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-050/module-04/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-054
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-050/module-04/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-054
```
