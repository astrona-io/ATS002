# Proving The Fix And Boot Targets

A fix is not done when the error stops printing. It is done when you have proved that the service runs now *and* will come up again after the next launch. An exam task that says "running and starts on boot" checks both, and they are two separate facts. This part shows how to apply a fix the right way, how to prove it, and how the ship's flight mode (the boot target) decides which stations come up at launch.

## Applying the fix

The command that applies a fix depends on what you changed. A service's own configuration file only needs a restart. A unit file or drop-in needs `daemon-reload` first, so the duty officer reads the duty cards again:

<!-- astrona:playground:renew -->

```bash
# changed a service config file (e.g. /etc/apache2/...):
sudo systemctl restart apache2

# changed the unit or a drop-in:
sudo systemctl daemon-reload
sudo systemctl restart apache2
```

## Proving the fix

Then check. Ask three questions with three commands. "It did not print an error" is not one of them:

```bash
systemctl is-active apache2       # -> active
systemctl status apache2          # -> active (running), fresh Main PID, recent 'since'
journalctl -u apache2 -n 20       # -> clean start lines, nothing after the restart timestamp
```

`is-active` answers "is it up?". `status` shows a new main process and a recent start time, so you know this is your restart and not an old state. The journal shows clean start lines with no new errors after the restart.

## `active` is not `enabled`

`start` staffs the station right now. `enable` puts the station on the launch checklist, so it is staffed at every launch. This section shows how the two differ and how to set both.

### Two questions, two checks

| | `systemctl is-active` | `systemctl is-enabled` |
|---|---|---|
| Question | is it running *right now*? | will it start *on the next boot*? |
| Set by | `start` / `stop` / `restart` | `enable` / `disable` |
| Mechanism | a running process tracked by PID 1 | a symlink under `/etc/systemd/system/<target>.wants/` pointing at the unit, per its `[Install] WantedBy=` |

`enable` reads the `[Install]` section of the unit file. `WantedBy=multi-user.target` there means "create a link to this unit in `multi-user.target.wants/`". That link is what makes the station come up at launch.

### Set both at once

`enable --now` creates the link and starts the unit in one step:

```bash
sudo systemctl enable --now apache2     # enable (create the .wants symlink) AND start, in one
systemctl is-enabled apache2            # enabled
systemctl is-active  apache2            # active
```

A unit can be `active` but `disabled`: running now, gone after a reboot. That is the classic "I only ran `start`" mistake. It can also be `enabled` but `inactive`: the link is there and it will start at the next boot, but it is not running yet. `enable --now` and `disable --now` change both together.

### See it in your playground

In your playground, fix `apache2`, check it, and make the fix survive a reboot. First free port 80 by stopping the helper that holds it:

```bash
sudo systemctl stop port80-hog.service        # free :80
sudo systemctl restart apache2                 # config-level fix -> just restart
systemctl is-active apache2
systemctl is-enabled apache2
sudo systemctl enable --now apache2
systemctl is-enabled apache2
```

You should see something like this:

```text
active
disabled
Created symlink /etc/systemd/system/multi-user.target.wants/apache2.service -> ...
enabled
```

After the restart, `apache2` is `active` but still `disabled`: running now, gone after a reboot. `enable --now` creates the `.wants` link, so it also comes up at boot. "Running and starts on boot" needs both, and `is-active` and `is-enabled` are the two separate checks.

`port80-hog.service` is still enabled in the playground, so after a reboot it would grab port 80 first again. In a real system you would also disable the program you no longer need.

## Boot targets: the ship's flight mode

A **target** is a unit that groups other units. The **default target** is the ship's flight mode: it decides which stations come up at launch. This section shows how to read the flight mode and how to change it.

### The common targets

These are the targets you meet most often, from the smallest to the largest:

- `rescue.target`: a single-user maintenance mode with only the most basic services.
- `multi-user.target`: a full server with networking and all normal services, but no graphical desktop.
- `graphical.target`: everything in `multi-user.target`, plus a graphical login screen.

`graphical.target` pulls in `multi-user.target`. `rescue.target` is a separate, much smaller mode, and `poweroff.target` shuts the machine down. A server without a screen normally boots into `multi-user.target`.

### Read and change the default

Read the current flight mode with `systemctl get-default`. It prints the name of the default target:

```bash
systemctl get-default
readlink -f /etc/systemd/system/default.target
```

The default is a symlink: `/etc/systemd/system/default.target` points at the real target unit under `/usr/lib/systemd/system/`. `get-default` only reads where that link points.

To change the flight mode for every future launch, run `sudo systemctl set-default <target>`, with the target's full name, such as `rescue.target`. `systemd` removes the old link and creates a new one. Nothing changes on the running system; only the next boot is affected.

Two related commands change the mode in other ways. `sudo systemctl isolate <target>` switches the *running* system to that target now. Adding `systemd.unit=<target>` to the kernel line in the boot loader uses that target for one boot only. To see which targets are active right now, run `systemctl list-units --type=target`.

## Common pitfalls

> [!WARNING]
> - **Running `start` and calling it done.** The service is not `enabled`, so it is gone after the next reboot. Use `enable --now`.
> - **Checking only that no error printed.** Prove the fix with `is-active`, `status` and `journalctl -u`.
> - **Editing the unit and only restarting.** A changed unit file or drop-in needs `daemon-reload` before the restart.
> - **Using `isolate` when the task asks for the default.** `isolate` changes the running system only. The next boot uses whatever `set-default` set.

> *Apply a fix with the command that matches what you changed, prove it with `is-active`, `status` and `journalctl`, and use `enable --now` so it survives a reboot. The default boot target is a symlink that `get-default` reads and `set-default` changes.*

## Your mission: Set the Default Boot Target Lab

You can now read and change the flight mode the ship launches into. The mission gives you a headless server that is set to boot into the graphical mode, and asks you to make it boot into the right mode for a server.

The mission runs on its own training ship. Your playground cannot be paused, so remove it first. It always starts clean, so you lose nothing you need:

```sh
astrona destroy systemd-service-debugging
```

Then start the mission and open a terminal on it:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-06
astrona ssh ats-002-lab-016f
```

Read the task in [`question.md`](./labs/lab-06/question.md) and solve it on your own first. When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-06
```

When the mission is done, remove it and start your playground again:

```sh
astrona destroy ats-002-lab-016f
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/playground
```
