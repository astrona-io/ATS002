# Section 040: Mandatory Access Control — SELinux & AppArmor

Standard Unix permissions are Discretionary Access Control: the file's owner decides who gets in. Mandatory Access Control is a second, independent gate that sits behind DAC and that no file owner controls — a system-wide policy decides whether a process may touch a resource, and both gates have to open before an action succeeds. A process with textbook-perfect `chmod`/`chown` permissions can still get flatly denied. Recognizing that signature — correct DAC, still blocked — is one of the sharpest diagnostic instincts the LFCS exam tests.

**A note on how this section is structured, up front:** the official LFCS competency reads "create and enforce MAC using SELinux," and RHEL-family exam images run SELinux for real. This course's lab environment, however, is Ubuntu 24.04 — which ships **AppArmor**, not SELinux, as its actively-enforcing kernel security module. Enabling genuine SELinux on this image would mean swapping the kernel's security module at boot and relabeling the entire filesystem, which is too fragile to automate reliably in a graded lab. So this section teaches **AppArmor hands-on, with a real graded lab**, and teaches **SELinux as a fully worked conceptual walkthrough** — same scenario shape, same reasoning, RHEL-accurate commands, just without a VM under it. That split is deliberate and stated plainly in the module itself, not hidden.

---

## What You Will Master

By completing this section, you will acquire these Mandatory Access Control capabilities:
* **AppArmor Diagnosis (hands-on):** Using `aa-status` to check whether AppArmor is active and which mode each profile is in, and reading real denial events out of `journalctl -k` / `dmesg`.
* **AppArmor Profile Repair (hands-on):** Editing a path-based profile (or using the `aa-logprof` semi-interactive workflow) to close a genuine access gap, reloading it with `apparmor_parser -r`, and confirming enforcement is fully restored — not left in `complain` mode as a shortcut.
* **SELinux Fluency (conceptual):** Reading security contexts with `ls -Z`, applying the persistent `semanage fcontext` + `restorecon` fix pattern (versus the relabel-losing `chcon` shortcut), and extending port-type policy with `semanage port` — the exact workflow a RHEL-family exam host expects.

---

## The Learning & Lab Path

This section has one module, deliberately built around two parts — a real hands-on half and an honest conceptual half — paired with a hands-on practice lab covering the graded half:

### 1. AppArmor Profile Enforcement & the Other MAC System: SELinux
* **Module Reader:** **[Module 1: AppArmor Profile Enforcement & the Other MAC System: SELinux](./module-01/course.md)**
* **Practice Lab Sandbox:** **`labs/lab-041`**
* **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/lab-041
    ```
* **Hands-on Objective:** On `web-srv1`, diagnose why the `appservice` daemon — reconfigured to log to `/srv/applogs` — fails to write there despite fully correct DAC permissions, find the denial in the audit trail, close the gap in its AppArmor profile, and confirm the fix survives with the profile genuinely back in `enforce` mode.

### 2. Section Capstone Challenge
* **Comprehensive Challenge:** **`labs/lab-040` (Two Services, Two Denials)**
* **Lab Run Command:**
    ```bash
    astrona run --git git@github.com:astrona-io/ATS002.git -c labs/lab-040
    ```
* **Hands-on Objective:** Connect the dots across two independent services. Repair `logshipper`, whose profile blocks a *write* to its relocated log directory, and separately repair `metrics-agent`, whose profile blocks a *read* of its relocated credentials file — diagnosing and fixing each AppArmor denial from its own audit trail, with both profiles left genuinely enforcing at the end.

---

## Ready for Assessment?

Test your theoretical knowledge and diagnostic reasoning — across both AppArmor and SELinux — before tackling the practical lab missions:

* **[Take the Section 040 Knowledge Check Quiz](./quiz.md)**
