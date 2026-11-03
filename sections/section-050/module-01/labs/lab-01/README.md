# Third-Party Repositories & Package Pinning Lab

Welcome to a supply mission, astronaut. A vendor's signed APT repository is running on this training ship at `127.0.0.1`, and it offers its own build of `nginx`.

Your job is to trust that repository the modern way (a dedicated keyring and `signed-by=`, no `apt-key`), install the vendor's exact `nginx` version from it, and hold that version so a routine upgrade cannot move it. The repository is built and served on the machine itself, so the lab does not depend on any outside host.

## Launching the Lab

Run this command to start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-050/module-01/labs/lab-01
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-051
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-050/module-01/labs/lab-01
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-051
```
