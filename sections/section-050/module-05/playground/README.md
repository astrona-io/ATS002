# APT Package Groups and Bulk Operations Playground

- **Name:** `apt-package-families`
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground: a training ship with no task and no grading

This playground is one Ubuntu 24.04 virtual machine set up with a family of installed packages that share a name prefix. Nothing to submit: explore, break things, remove it and start again.

## Run it

Start the playground and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-050/module-05/playground
astrona ssh astro-apt-package-families
```

When you are done, remove it:

```sh
astrona destroy apt-package-families
```

`astrona destroy` takes the playground's name (`apt-package-families`), not the folder path. `astrona submit` and `astrona test` do not apply, because there is no grading.

## What is in this folder

| Path | Purpose |
| --- | --- |
| `config.yaml` | The playground definition (the virtual machine and its setup step) |
| `bootstrap/` | The setup scripts that run once when the playground starts |
| `docs/overview.md` | What the playground contains and ideas to try |
