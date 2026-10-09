# AppArmor: Repair a Read Denial Lab

Welcome to a security mission, astronaut. The `credsync` daemon on this training ship reads its API key from `/etc/credsync/api.key`, a new location. The file permissions are correct, but its AppArmor profile, in enforce mode, only allows the old location, so every read of the key is denied with `denied_mask="r"`.

Your job is to read the denial, add a read rule for the key, reload the profile, and keep it enforcing.

## Launching the lab

Start the virtual machine:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-040/module-01/labs/lab-02
```

Open a terminal on it:

```bash
astrona ssh ats-002-lab-042
```

When you think you have finished, send it for grading:

```bash
astrona submit -c sections/section-040/module-01/labs/lab-02
```

When you are done, remove the lab:

```bash
astrona destroy ats-002-lab-042
```
