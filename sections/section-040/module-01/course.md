# AppArmor Profile Enforcement & the Other MAC System: SELinux

<!-- astrona:playground -->
> [!NOTE]
> 🧪 **Hands-on playground for this module** — a clean, throwaway machine to explore on. No task, no grading. Folder: [`playground/`](https://github.com/astrona-io/ATS002/tree/main/sections/section-040/module-01/playground)
>
> ```sh
> astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-040/module-01/playground
> astrona destroy apparmor-mac-enforcement
> ```

Every file on a Linux system already passes through one permission check — the owner, group, and rwx bits you know as **Discretionary Access Control (DAC)**. Mandatory Access Control is a *second* gate behind it: a system-wide policy, not controlled by any file's owner, that independently decides whether a process may touch a resource. Both gates must open. The signature that sends you here instead of to `chmod` is a denial where `ls -l` looks completely correct — that means the second gate, and the second gate is a **Linux Security Module**: AppArmor on Debian/Ubuntu/SUSE, SELinux on the RHEL family.

This module teaches **AppArmor hands-on** — the playground and lab run Ubuntu 24.04, where AppArmor is the live, enforcing LSM — and **SELinux as a fully worked conceptual walkthrough**, because the LFCS objective names SELinux and RHEL-family exam hosts run it, but this image has no SELinux kernel to practise against. The split is deliberate and called out where it happens, not hidden.

## How this module is organised

1. **[Part 1 — Two gates: DAC, MAC, and which system you're on](./course-01-two-gates-dac-mac-and-which-system.md)** — the DAC→MAC check order, the "correct permissions, still denied" signature, the distro→LSM map, and the one structural difference (AppArmor matches a path, SELinux matches a label).
2. **[Part 2 — AppArmor: profiles, modes, and what's loaded](./course-02-apparmor-profiles-and-modes.md)** — `aa-status`, profile file anatomy (path rules, access modes, includes, `capability` lines, the `local/` override), and the `enforce` vs `complain` mode distinction.
3. **[Part 3 — AppArmor: diagnosing and fixing a path denial](./course-03-apparmor-diagnosing-and-fixing.md)** — reading `apparmor="DENIED"` out of `journalctl -k` field by field, closing the gap via `/etc/apparmor.d/local/` or `aa-logprof`, reloading with `apparmor_parser -r`, and proving the profile is genuinely enforcing.
4. **[Part 4 — SELinux: labels, contexts, and the AVC denial](./course-04-selinux-labels-and-avc-denials.md)** — the `user:role:type:level` context, type-based policy, the three modes, and reading an AVC denial's `scontext` / `tcontext` (walkthrough — no VM).
5. **[Part 5 — SELinux: persistent fixes and the AppArmor contrast](./course-05-selinux-persistent-fixes-and-contrast.md)** — why `chcon` does not survive a relabel, the `semanage fcontext -a` + `restorecon -Rv` pair, port-type policy, and the two systems side by side (walkthrough — no VM).

## Learning objectives

After this module you can:

- **Recognise** the "correct DAC, still denied" signature and name which MAC system a given distribution enforces.
- **Explain** the difference between AppArmor's path matching and SELinux's label matching, and predict what happens to each when a file is moved to a new path.
- **Run** `aa-status` and state, for each profile, whether it is loaded and whether it is in `enforce` or `complain` mode.
- **Read** an AppArmor profile — distinguish path rules, access modes (`r`, `w`, `ix`, `rix`, `px`), `#include` lines, and `capability` lines.
- **Locate** an AppArmor denial in `journalctl -k` and identify the `profile=`, `operation=`, `name=`, and `denied_mask=` fields.
- **Fix** a path-based denial by editing `/etc/apparmor.d/local/` (or via `aa-logprof`), reload it with `apparmor_parser -r`, and confirm it is genuine enforcement, not a profile left in `complain`.
- **Read** an SELinux AVC denial's `scontext` and `tcontext`, and give the persistent fix (`semanage fcontext -a` + `restorecon`) plus why `chcon` alone does not survive a relabel.
- **Choose** between file-context policy and port-type policy (`semanage port`) for a given SELinux denial.

## Before you start

Assumed: comfort with Linux file permissions (`ls -l`, owner/group/mode), running commands under `sudo`, reading a plain-text config file, and the idea of a `systemd`-managed service. No prior AppArmor or SELinux experience.

The playground is an Ubuntu 24.04 host with AppArmor as the live LSM and `apparmor-utils` installed. It runs a demo service, **`appservice`**, that writes `/srv/applogs/app.log` every few seconds — behind a deliberately too-strict profile, loaded in **enforce** mode, that only permits the service's *old* log path. DAC on `/srv/applogs` is already correct, so a fresh `apparmor="DENIED"` record is always waiting in the kernel log. Get a shell with:

```bash
astrona ssh astro-apparmor-mac-enforcement
```

The **Try it** checkpoints in Parts 2–3 build on each other on one running host — diagnose the denial, then fix it. Parts 4–5 have no checkpoints: there is no SELinux kernel on this image, so those parts are read-only walkthroughs, RHEL-accurate but not runnable here. Every command block states the shell and privilege it assumes.

## Where this fits

MAC is the layer that turns a "the permissions are obviously fine, why is this broken" incident from a mystery into a two-minute diagnosis. It shows up whenever a service is reconfigured to a non-default path or port — a relocated docroot, a moved log directory, an alternate listen port — which is exactly the shape of the section lab and capstone. The hands-on half of Parts 2–3 is what `sections/section-040/module-01/labs/lab-01` grades; the section capstone repairs two independent AppArmor denials at once. Carry the path-vs-label distinction from Part 1 forward — it is the thing that tells you which toolset the host in front of you needs.
