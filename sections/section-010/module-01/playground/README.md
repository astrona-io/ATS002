# Reading and Reshaping the Live Kernel with sysctl: Playground

- **ID:** PLAYGROUND
- **Slug:** sysctl-live-kernel
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground: a clean training ship, no task, no grading

This playground starts one training ship (an Ubuntu 24.04 virtual machine), prepares it once, and keeps it running so you can explore kernel parameters on a clean machine. There is nothing to submit.

## Run it

Start the playground and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-01/playground
astrona ssh astro-sysctl-live-kernel
```

If you work from a local copy of the repository, you can also start it from inside this folder:

```sh
astrona run -c .
```

When you are done, remove it:

```sh
astrona destroy sysctl-live-kernel
```

`astrona destroy` takes the playground's name (`metadata.name` = `sysctl-live-kernel`), not its folder path. `astrona submit` and `astrona test` do not apply here, because nothing is graded.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | The playground definition (virtual machine and start-up steps only) |
| `bootstrap/prepare.sh` | Preparation that runs once when the machine starts |
| `docs/overview.md` | What is in the playground and ideas to try |
