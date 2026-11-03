# Debugging a Service That Won't Start with systemctl and journalctl — Playground

- **ID:** PLAYGROUND
- **Slug:** systemd-service-debugging
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground: a clean training ship, no task, no grading

This playground is one training ship (an Ubuntu 24.04 virtual machine) where `apache2` has already failed to start, because another unit holds port 80. It starts, runs its setup script once, and then waits for you, so you can practise reading `systemctl status` and `journalctl` on a real failed service. There is nothing to submit.

## Run it

Start the playground, open a terminal on it, and remove it when you are done:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/playground
astrona ssh systemd-service-debugging
astrona destroy systemd-service-debugging
```

`astrona ssh` and `astrona destroy` take the playground's name (`metadata.name` = `systemd-service-debugging`), not its folder path. The `astro-` prefix in front of the name, as in `astrona ssh astro-systemd-service-debugging`, is optional. `astrona submit` and `astrona test` do not apply, because there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Playground definition (virtual machine and setup only) |
| `bootstrap/prepare.sh` | Setup script that runs once at startup |
| `docs/overview.md` | What the playground contains and ideas to try |
