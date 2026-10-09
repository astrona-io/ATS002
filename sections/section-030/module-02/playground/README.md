# libvirt Virtual Machine Lifecycle Playground

- **Slug:** libvirt-vm-lifecycle
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground: a clean training ship, no task, no grading

This playground is a single Ubuntu 24.04 virtual machine that acts as your hangar. When it starts, it installs libvirt and QEMU, brings up the `default` network, places an empty disk image ready for a new domain, and then waits for you. There is nothing to submit.

## Run it

From the course repository:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-030/module-02/playground
astrona ssh astro-libvirt-vm-lifecycle
```

From inside this folder, `astrona run -c .` starts the same playground.

When you are done, remove it:

```sh
astrona destroy libvirt-vm-lifecycle
```

`astrona destroy` takes the playground's name (`libvirt-vm-lifecycle`, the `metadata.name` in `config.yaml`), not the folder path. `astrona submit` and `astrona test` do not apply, because nothing is graded.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Playground definition (the virtual machine and its start-up step only) |
| `bootstrap/prepare.sh` | Preparation that runs once when the playground starts |
| `docs/overview.md` | What the playground contains and ideas to try |
