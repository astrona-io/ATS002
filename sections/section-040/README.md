# Section 040: Mandatory Access Control — SELinux & AppArmor

Astronaut, normal Unix permissions are **Discretionary Access Control (DAC)**: the owner of a file decides who gets in, like the lock on each hatch of your ship. **Mandatory Access Control (MAC)** is a second, separate gate behind it. Picture it as the ship's security chief: a policy for the whole system, which no file owner controls, decides whether a process may touch a resource. Both gates must open before an action succeeds.

So a process with perfect `chmod` and `chown` permissions can still be flatly denied. Spotting that sign, correct permissions and still blocked, is one of the sharpest instincts the LFCS exam tests.

## How this section is built

AppArmor exercises use Ubuntu 24.04. The SELinux module uses a pinned Rocky Linux VM with enforcement enabled, so you can inspect real denials and prove the repair through Apache requests.

## What you will learn

- **Diagnose AppArmor (hands-on):** use `aa-status` to check whether AppArmor is active and which mode each profile is in, and read real denials from `journalctl -k` or `dmesg`.
- **Repair an AppArmor profile (hands-on):** add the missing path rule by hand or with `aa-logprof`, reload it with `apparmor_parser -r`, and confirm the profile is enforcing again, not parked in complain mode as a shortcut.
- **Work with SELinux:** read security contexts with `ls -Z`, apply the lasting `semanage fcontext` plus `restorecon` fix instead of the `chcon` shortcut that a relabel undoes, and extend port policy with `semanage port`.

## The modules

This section has two modules:

- **[AppArmor Profile Enforcement & the Other MAC System: SELinux](./module-01/course.md)**: two gates and which system you are on, AppArmor profiles and modes, reading and fixing an AppArmor denial, then SELinux labels, AVC denials and lasting fixes. It has its own playground and two graded missions: a service blocked from **writing** its new log folder, and a daemon blocked from **reading** its new key file.
- **[SELinux In Practice: Contexts, Booleans And Ports](./module-02/course.md)**: a live Rocky Linux exercise covering file contexts and `restorecon`, lasting fixes with `semanage fcontext`, booleans, ports and reading denials. Its mission checks live labels, policy and HTTP requests, including persistence after reboot.

## Knowledge check

Test your reasoning about both AppArmor and SELinux with the **[section quiz](./quiz.yaml)** before you take on the capstone.

## Capstone: Two Services, Two Denials

The capstone puts everything together on one training ship. You repair `logshipper`, whose profile blocks a *write* to its new log folder, and `metrics-agent`, whose profile blocks a *read* of its new credentials file. You find each denial in its own audit trail, fix each profile, and leave both profiles really enforcing.

Start it and open a terminal on it:

```bash
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-040/capstone/labs/lab-01
astrona ssh ats-002-lab-040
```

Read the task in [`question.md`](./capstone/labs/lab-01/question.md). When you think you are done, send it for grading, and remove the lab afterwards:

```bash
astrona submit -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-002-lab-040
```
