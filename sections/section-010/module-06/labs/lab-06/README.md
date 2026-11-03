# Set the Default Boot Target Lab

Astronaut, this training ship is a server without a screen, but it is set to launch in graphical flight mode: its default boot target is `graphical.target`. It should launch in `multi-user.target`, the normal mode for a server.

Your job: change the default target with `systemctl set-default`, and prove it with `systemctl get-default` and the `/etc/systemd/system/default.target` link.

## Launching the lab

Start the virtual machine:

```sh
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-06/labs/lab-06
```

Open a terminal on it:

```sh
astrona ssh ats-002-lab-016f
```

When you think you have finished, send it for grading:

```sh
astrona submit -c sections/section-010/module-06/labs/lab-06
```

When you are done, remove the lab:

```sh
astrona destroy ats-002-lab-016f
```
