# Question

Solve this question on: `terminal`

Astronaut, this training ship is a freshly built application server, and it must be fully onboarded before it goes into service. Work through the checklist below. Read all of it before you start: one step needs a tool that another step installs.

1. **Baseline toolchain.** Install `curl`, `git` and `jq`, all in a single `apt install` command. Every application server on this platform gets these three. Step 2 needs `curl`, so it makes sense to do this step first.

2. **Vendor package.** Your team ships `telemetry-agent` from an internal vendor repository, not from Ubuntu's own archive. That repository is already running locally at `http://127.0.0.1:8200`, under the suite (codename) `app-tools` and the component `main`. The vendor's GPG public key is published at `http://127.0.0.1:8200/app-tools-archive-keyring.asc`.
    - Import the key the current, non-deprecated way: converted with `gpg --dearmor` into its own dedicated keyring file under `/etc/apt/keyrings/`, with a name ending in `.gpg`. Do **not** use `apt-key`.
    - Add the repository to APT as its own `.list` file under `/etc/apt/sources.list.d/`, with a `signed-by=` reference to that keyring file. The suite is `app-tools` and the component is `main`.
    - Refresh APT's package index and install the **exact** version of `telemetry-agent` that the vendor publishes. Copy the version string from `apt-cache policy telemetry-agent`; do not guess or retype it.
    - Hold `telemetry-agent` at that version so a routine upgrade cannot move it.

3. **Stuck package.** An earlier provisioning attempt on this host was interrupted halfway. `tree` is stuck in a half-configured state. Diagnose it and recover the system to a consistent package state.

4. **Observability agent family.** This host already carries a full family of observability-agent modules: packages that share the `obsagent-` prefix. Find every one of them by naming pattern, not by listing them by hand, and hold the *entire* family together ahead of a planned platform upgrade next week.

5. **Onboarding question.** Before this server goes live, the operations team wants to know exactly which version of `redis-server` would be installed if someone ran `apt install redis-server` right now, and which repository it would come from. Find out without installing anything. Record both answers in `/opt/course/onboarding/redis-candidate.txt` (the directory is already created for you).

The grader checks that `curl`, `git` and `jq` have the status `install ok installed`; that a `.list` file under `/etc/apt/sources.list.d/` contains `signed-by=/etc/apt/keyrings/<name>.gpg` pointing at a valid keyring, `telemetry-agent` is fully installed at exactly the vendor's version, and `apt-mark showhold` lists it; that `tree` has the status `install ok installed` and `sudo dpkg --audit` reports nothing; that every installed `obsagent-*` package appears in `apt-mark showhold`; and that `redis-candidate.txt` contains the live candidate version of `redis-server` and the address of the repository it comes from (for example `http://archive.ubuntu.com/ubuntu`).
