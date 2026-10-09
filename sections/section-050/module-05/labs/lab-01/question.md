# Question

Solve this question on: `terminal`

Astronaut, a development team needs a full local build toolchain in one go. Install the `build-essential` metapackage together with `git`, `cmake` and `pkg-config`, all in a single `apt install` command, so they are resolved as one transaction.

Separately, this ship has a full PHP 8.1 module set installed: packages named like `php8.1-cli`, `php8.1-fpm`, `php8.1-mysql` and others that share the `php8.1-` prefix. An unrelated but risky upgrade is planned elsewhere on the system. Find every one of these packages by naming pattern, not by listing them by hand, and hold the *entire* PHP 8.1 family at its current versions, not just one or two of them. Confirm the full hold list afterwards.

The grader checks that `build-essential`, `git`, `cmake` and `pkg-config` all have the status `install ok installed`, and that every installed package whose name starts with `php8.1-` appears in `apt-mark showhold`.
