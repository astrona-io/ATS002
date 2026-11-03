# Partition Table Backup and Restore Playground

- **Name:** `partition-table-bench`
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground: a training ship with no task and no grading

This playground is one Ubuntu 24.04 virtual machine set up with a spare GPT disk with two partitions and marker files. Nothing to submit: explore, break things, remove it and start again.

## Run it

Start the playground and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-080/module-03/playground
astrona ssh astro-partition-table-bench
```

When you are done, remove it:

```sh
astrona destroy partition-table-bench
```

`astrona destroy` takes the playground's name (`partition-table-bench`), not the folder path. `astrona submit` and `astrona test` do not apply, because there is no grading.

## What is in this folder

| Path | Purpose |
| --- | --- |
| `config.yaml` | The playground definition (the virtual machine and its setup step) |
| `bootstrap/` | The setup scripts that run once when the playground starts |
| `docs/overview.md` | What the playground contains and ideas to try |
