# Question

Solve this question on: `terminal`

This VM is a freshly provisioned application server that needs to be fully onboarded before it goes into service. Work through the checklist below. Read all of it before you start — one step depends on tooling installed by another.

1.  **Baseline toolchain.** Install `curl`, `git`, and `jq` — all in a single `apt install` invocation. Every app server on this platform gets these three. `curl` in particular is required for step 2 below, so it makes sense to do this one first.

2.  **Vendor package.** Your team ships `telemetry-agent` from an internal vendor repository, not Ubuntu's own archive. It's already running locally at `http://127.0.0.1:8200`, under codename `app-tools`, component `main`. The vendor's GPG public key is published at `http://127.0.0.1:8200/app-tools-archive-keyring.asc`.
    - Import the key the current, non-deprecated way — dearmored into its own dedicated file under `/etc/apt/keyrings/` (do **not** use `apt-key`).
    - Add the repository to APT using a `signed-by=` reference to that dedicated keyring, as its own file under `/etc/apt/sources.list.d/`. The suite/codename is `app-tools`, component `main`.
    - Refresh APT's index and install the **exact** version of `telemetry-agent` the vendor publishes (copy the version string verbatim from `apt-cache policy telemetry-agent` — do not guess or retype it).
    - Hold `telemetry-agent` at that version so a routine upgrade cannot move it.

3.  **Stuck package.** A previous provisioning attempt on this host was interrupted midway. `tree` is stuck in a half-configured state. Diagnose it and fully recover the system to a consistent package state.

4.  **Observability agent family.** This host already carries a full observability-agent module family installed — packages sharing the `obsagent-` prefix. Find every one of them by naming pattern rather than listing them by hand, and hold the *entire* family together ahead of a planned platform upgrade next week.

5.  **Onboarding question.** Before this server goes live, Ops wants to know exactly what version of `redis-server` would be installed if someone ran `apt install redis-server` right now, and which repository it would come from — without installing anything. Record both answers into `/opt/course/onboarding/redis-candidate.txt` (already created for you).
