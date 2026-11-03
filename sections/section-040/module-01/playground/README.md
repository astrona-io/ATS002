# AppArmor Profile Enforcement Playground

- **Name:** `apparmor-mac-enforcement`
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground: a clean training ship with no task and no grading

This playground is one Ubuntu 24.04 virtual machine where AppArmor is the live, enforcing security module. It runs a demo service, `appservice`, behind an AppArmor profile that is too strict on purpose, so a real denial is always waiting for you to find and fix. Nothing to submit: explore, break things, remove it and start again.

## Run it

Start the playground and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-040/module-01/playground
astrona ssh astro-apparmor-mac-enforcement
```

When you are done, remove it:

```sh
astrona destroy apparmor-mac-enforcement
```

`astrona destroy` takes the playground's name (`apparmor-mac-enforcement`), not the folder path. `astrona submit` and `astrona test` do not apply, because there is no grading.

## What is in this folder

| Path | Purpose |
| --- | --- |
| `config.yaml` | The playground definition (the virtual machine and its setup step) |
| `bootstrap/prepare.sh` | The setup script that runs once when the playground starts |
| `docs/overview.md` | What the playground contains and ideas to try |
