# Overview: APT Package Groups and Bulk Operations Playground

This is a **playground**, not a lab. The training ship starts clean, runs its setup script, and then waits for you. There is no task, no `astrona submit` and no pass or fail. Explore, break things, remove it with `astrona destroy` and start over.

## What is in the box

- One Ubuntu 24.04 virtual machine. Open a terminal on it with `astrona ssh astro-apt-package-families`.
- Six small `php8.1-*` packages installed (version `8.1.2-1ubuntu2.14`), built on the machine as stand-ins. They share one name prefix and install no real PHP program.
- `build-essential`, `git`, `cmake` and `pkg-config` not installed, so installing them is a real transaction.
- The normal `apt`, `apt-mark` and `dpkg` tools.

## Things to try

- Install the four tools in one `apt install` command and read the plan before you confirm it.
- Find the family with `dpkg -l 'php8.1-*'` and with `apt list --installed 'php8.1-*'`.
- Hold the whole family in one command with `apt-mark hold`, using the names from `dpkg-query -W -f='${binary:Package}\n' 'php8.1-*'`, then check with `apt-mark showhold`.
- Release the family again with `apt-mark unhold`.

## When you are done

```sh
astrona destroy apt-package-families
```

`astrona destroy` takes the playground's name, `apt-package-families`, not the folder path. The running machine is called `astro-apt-package-families`.
