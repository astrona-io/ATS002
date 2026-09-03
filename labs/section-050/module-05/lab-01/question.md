# Question

Solve this question on: `terminal`

A development team needs a full local build toolchain in one shot: install the `build-essential` meta-package together with `git`, `cmake`, and `pkg-config`, all in a single `apt install` invocation so they're resolved as one transaction.

Separately, this host currently has a full PHP 8.1 module set installed — packages named like `php8.1-cli`, `php8.1-fpm`, `php8.1-mysql`, and others sharing the `php8.1-` prefix. Find every one of them by naming pattern rather than listing them by hand, and, ahead of an unrelated but risky upgrade elsewhere on the system, hold the *entire* PHP 8.1 family at its current versions together — not just one or two of them. Confirm the full hold list afterward.
