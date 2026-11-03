# RPM Database Rebuild Playground

- **Name:** `rpm-database-repair`
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground: a training ship with no task and no grading

This playground is one Ubuntu 24.04 virtual machine set up with an RPM database that is really damaged. Nothing to submit: explore, break things, remove it and start again.

## Run it

Start the playground and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-060/module-02/playground
astrona ssh astro-rpm-database-repair
```

When you are done, remove it:

```sh
astrona destroy rpm-database-repair
```

`astrona destroy` takes the playground's name (`rpm-database-repair`), not the folder path. `astrona submit` and `astrona test` do not apply, because there is no grading.

## What is in this folder

| Path | Purpose |
| --- | --- |
| `config.yaml` | The playground definition (the virtual machine and its setup step) |
| `bootstrap/` | The setup scripts that run once when the playground starts |
| `docs/overview.md` | What the playground contains and ideas to try |
