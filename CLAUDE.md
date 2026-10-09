# Writing style for this repo

All study text here (course pages, lab docs, READMEs, comments in YAML and
scripts) is for people learning a technical subject, often for a
certification exam. Many of them are not native English speakers and have no
university degree.

## Plain English

Write the text in Plain English for a general adult audience (18+) without a
university degree. The content must be highly accessible and easy to
understand for non-technical readers, without feeling childish.

Strict guidelines:

1. Target a Flesch-Kincaid Grade Level of 8 or 9 (equivalent to a standard
   newspaper article).
2. Avoid all technical jargon, acronyms, and corporate buzzwords. If a
   technical term is necessary, explain it immediately using an everyday
   analogy.
3. Keep sentences conversational and direct. Split long sentences into two.
4. Use short paragraphs (max 3-4 sentences per paragraph) and clear
   subheadings to make the text scannable.
5. Use the active voice (e.g., "We did this" instead of "This was done by us").

## How this applies to course material

- **Know which file you are in.** A module has a short landing page and a few
  deep-dive parts. The landing page is a map: goals, what to know first, the
  order of the parts, where it fits. The real teaching goes in the parts. A lab
  has a task, a step-by-step solution and a short intro. Keep each file to its
  job. Do not add "Prerequisite: ... Next: ..." navigation lines to pages;
  the landing page and the course outline already give the order.
- **Keep each part short.** One idea per part, about 5 to 8 minutes of
  reading and at most about 8 command blocks, so a learner can finish it with
  the playground in one sitting of about 15 minutes. Split at a natural seam
  where each half ends with something the learner has seen work. Never split
  only to hit a number. When you split, renumber the files, fix every "Part N"
  reference in the module, the wrap-up links and `astrona.yaml`.
- **Every heading gets an intro.** A `##` section that has `###`
  subsections starts with one to three sentences that say what the section
  is about and why it matters, before the first `###`. Never put a `###`
  directly under a `##`.
- **Every module stands on its own.** Never refer to other sections or
  modules: no "see section 040", "as module 3 showed", "you met this in
  section 000", and no links to pages in another module. If the reader needs
  a fact from elsewhere, state the fact directly in one or two sentences.
  This also goes for parts of the same module: never write "Part 2 shows",
  "from Part 1" or "as in Part 3". Say the fact itself ("the commands below
  need the `dataproc` user created first"). The wrap-up page is the one
  exception: it recaps each part and links to it.
  The landing page does not have a "Where this fits" section.
- **Write words out in full.** Do not use informal short forms in prose:
  write "communications", "configuration", "repository", "administrator",
  "for example" and "that is", never "comms", "config", "repo", "admin",
  "e.g." or "i.e.". Names in code, commands and file paths stay as they are.
- **Exam terms stay.** The product's own names are what the reader must learn
  (for example a resource kind, a field, a command). Keep them, but explain
  each one in plain words, with an everyday analogy, the first time it appears
  in a file. Spell out acronyms on first use, with a short plain meaning.
- **Analogies come from space, and the reader is an astronaut.** When a term
  needs an everyday picture, use space: spaceships, planets, solar systems,
  space stations, mission control, signals, docking, star charts, airlocks,
  even the Death Star. Talk to the reader as an astronaut (for example "your
  first mission", "astronaut, check your flight log"), but not in every
  sentence. Requests are **signals** that ships send to each other. Use one
  analogy per hard idea, keep it short, and keep it the same everywhere (if
  the repository has an analogy glossary, use it). The analogy helps the reader; it
  never replaces the real term, and it never changes code or output.
- **Show one real example before the rule.** Start with a concrete case the
  reader can run, then give the general rule.
- **Say which part does the work.** Readers often mix up the parts of a system
  that sit close together. Whenever something happens, say which component
  did it.
- **Never change code to fit the style.** Commands, configuration files, field
  names, resource names, log lines and command output stay exactly as they
  are. They were run and checked on a real system. Never make up command
  output. If you shorten it, say that you did.
- **Prose only.** The grade-level and sentence rules apply to explanations.
  They do not apply to code blocks, tables of field names or reference lists
  (those may stay short and dense).
- **Keep the page furniture the same.** Hands-on steps are normal page
  content, not boxes: a short `###` subsection (for example "See it in your
  playground") with one sentence saying what to do, the command, the real
  output, and one or two sentences saying what it shows. A `> [!TIP]` box is
  only for a real tip: advice the reader can reuse beyond this one step (a
  habit, a shortcut, how to spot a problem, an exam habit). Everything else
  is a normal sentence: notes about the current step ("if the log line is
  old, run it again"), background facts, optional extra steps, and plain
  information. Never a command snippet, never two in a row, and most pages
  need zero or one tip. Each part ends with a
  `## Common pitfalls` `> [!WARNING]` block for that part only. Use a Mermaid
  diagram for a flow, an order or a state change, keep it under about 12
  boxes, and follow it with one sentence that says what it shows.
- **Labs come right after the part they practise.** Do not collect all
  graded labs at the end of a module. In `astrona.yaml`, put each lab (its
  `question.md` reading and the `lab` entry) right after the reading part it
  tests. If a part teaches a gradeable skill and no lab covers it, create a
  new lab. That part then ends with a `## Your mission: <lab title>` section:
  one sentence on what the reader can now do, one on what the mission asks,
  then pause the playground (`astrona stop <playground name>`), the
  `astrona run` and `astrona submit` commands, and finally
  `astrona destroy <lab name>` plus `astrona start <playground name>`. The
  wrap-up lists the missions and ends with cleaning up the playground
  (`astrona list`, `astrona destroy <playground name>`).
- **Renew the playground before hands-on work.** Every reading part that
  runs commands has `<!-- astrona:playground:renew -->` exactly once, on its
  own line, right before the first hands-on step (the first "Save this as"
  or the first command block), so the playground timer is reset before the
  learner needs the playground. Not on landing pages (they carry
  `<!-- astrona:playground -->`), wrap-up pages or pages without commands.
- **Mermaid without HTML.** The platform renders Mermaid with HTML labels
  switched off, so `<br/>` and any other HTML tag break the drawing. Rules:
  - One line per box, no `<br/>`, no HTML. Keep the box to the thing's name
    (`"systemd"`, `"/etc/fstab"`, `"reportd.service"`).
  - Put the logic on the arrows: `P -->|"fork"| C`,
    `U -->|"daemon-reload"| S`, `M -->|"modprobe"| K`. Keep edge labels short.
  - Quote every label. Prefer `flowchart TB`; use `LR` only for a short chain.
  - Sequence diagrams: short participant aliases (`participant S as shell`)
    and short message text.
  - Anything longer (full paths, full hostnames) goes in the sentence under
    the diagram.
- **No links to outside sources.** Course pages, labs and playground docs do
  not link to or point at outside websites (the one exception is the
  `resources` field of a lab entry in `astrona.yaml`) (official docs, GitHub, blogs,
  RFCs), and they have no "Reference" or "Official docs" lists. Everything the
  reader needs is explained on the page itself. Not affected: addresses the
  reader actually uses in a command or browser (`http://127.0.0.1:8080`,
  `docker pull rockylinux:9`), and the Mission Briefing's contributors and
  "report a mistake" links.
- **Configuration goes to a file first.** Whenever the reader should apply
  a configuration file (a sysctl drop-in, a unit file, a udev rule, a
  repository source, a domain XML) in course parts, playground docs or labs,
  use three separate steps:
  1. "Save this as `/etc/sysctl.d/99-ip-forward.conf`:" followed by a plain
     block (` ```ini `, ` ```bash `, ` ```xml `) with only the file's
     content. No `cat > file <<'EOF'`, no `sudo tee file <<EOF`, no shell
     around it.
  2. "Apply it:" followed by a ` ```sh ` block with only the command that
     makes the system use the file (`sudo sysctl --system`,
     `sudo systemctl daemon-reload`, `sudo udevadm control --reload`).
  3. "Then check the result:" followed by the check commands, if any.
  The file name says what the file is for. If a value must come from the
  reader's machine (a disk serial, a UUID), use a placeholder like `<UUID>`
  in the file and say how to get the value (`blkid`); never put shell
  variables inside a configuration file that does not expand them. Apply a
  file the first time its content appears; do not show it once "to read" and
  paste it again later. Never tell the reader to apply something from the
  playground's `examples/` folder: they start the playground with
  `astrona run`, so that folder is not on their machine.
- **Helpers have readable names.** Shell helper functions and variables use
  names that say what they do (`count_tasks`, `show_limits`,
  `$TARGET_DISK`), never single letters.


## About this repo (ATS002 only)

Everything above is general and can be copied to other course repositories. This
section is only true for this one.

### What the student is trying to learn

- **The goal:** pass the **Operations Deployment** domain of the **Linux
  Foundation Certified System Administrator (LFCS)** exam. It is 25% of the
  exam, the largest single domain.
- **What the exam really tests:** doing real administration work on a live
  Linux machine, from a terminal, under time pressure, and leaving the
  machine in the right state, often after a reboot. So the student must *do*
  things (persist a kernel setting, raise a limit, blacklist a module, fix a
  failed service, schedule a job, run a container, define a virtual machine,
  fix an AppArmor denial, pin a package, rebuild a package database, repair
  a system that will not boot), not just recognise words. Every explanation
  should lead to something they can run, and every result should be proved
  with a check command (`sysctl -n`, `systemctl status`, `journalctl -u`,
  `docker inspect`, `virsh dominfo`, `aa-status`, `apt-cache policy`,
  `rpm -V`, `sgdisk -p`).
- **The exam topics this course covers:** configuring kernel parameters
  (persistent and non-persistent); diagnosing, managing and troubleshooting
  processes and services; scheduling jobs; configuring container engines
  and managing containers; building software from source and managing
  virtual machines with libvirt; mandatory access control with AppArmor and
  SELinux; searching for, installing, validating and maintaining packages
  and repositories (Debian, RHEL-family and SUSE); and recovering from
  hardware, operating system and filesystem failures.
- **The sections:**

  | Section | Title | Exam topic |
  | --- | --- | --- |
  | 010 | Kernel Tuning, Process Limits, and Device Forensics | Kernel parameters; processes and services; devices |
  | 020 | Scheduled & Containerized Workloads | Scheduling jobs; containers |
  | 030 | Building & Virtualizing Systems | Software from source; virtual machines (libvirt) |
  | 040 | Mandatory Access Control — SELinux & AppArmor | Mandatory access control |
  | 050 | Debian Package Management: Repositories, dpkg & APT | Packages and repositories (Debian family) |
  | 060 | RPM/DNF Package Management: rpm, dnf & Package Groups | Packages and repositories (RHEL family) |
  | 070 | SUSE Package Management: Zypper | Packages and repositories (SUSE family) |
  | 080 | System Disaster Recovery | Recovering from boot, filesystem and disk failures |

  A final domain quiz (`sections/final-domain-quiz.md`) closes the course.
- **The version:** every lab and playground runs on **Ubuntu 24.04** in a
  `qemu` virtual machine built from
  `ghcr.io/astrona-io/ubuntu-qcow2-image:24.04-lfcs-{ARCH}`, with **bash**
  as the shell, **systemd** as the service manager and **AppArmor** as the
  mandatory access control system. Section 060 runs the real RHEL-family
  tools inside a **Rocky Linux 9** container (`rpmbox`) and section 070 the
  real SUSE tools inside an **openSUSE Leap 15.6** container (`zypperbox`),
  both on the Ubuntu machine. SELinux (section 040) and `rd.break`
  (section 080) are taught as worked walkthroughs, because the Ubuntu image
  cannot run them for real. Do not teach options or behaviour from other
  distributions without saying so.
- **The main sources:** the manual pages on the lab machine (`man sysctl`,
  `man systemd.exec`, `man modprobe.d`, `man udev`, `man strace`,
  `man crontab`, `man systemd.timer`, `man virsh`, `man apparmor`,
  `man apt-get`, `man dpkg`, `man rpm`, `man dnf`, `man zypper`,
  `man sgdisk`, `man grub-install`) and the official project documentation
  listed under "Where to find trusted sources". Check every page against
  them.

### Space analogy glossary

Use these pictures for these terms, in every course page, lab and playground.
Keep them consistent so the astronaut builds one picture of the universe. It
is the same universe as the other Astrona courses: the learner is an
astronaut, and a single Linux machine is one spaceship. Most pages written
before these rules have no space analogies yet; add them when you rework a
page, using this table.

**The ship**

| Term | Space picture |
| --- | --- |
| The learner | An astronaut (a cadet on their first missions) |
| Linux machine / virtual machine | A spaceship |
| Lab or playground virtual machine (`qemu`) | A training ship in the simulator |
| Kernel | The ship's reactor core: it runs everything and hands out power and time |
| Kernel parameter (sysctl key) | A dial on the reactor control panel |
| `/proc/sys` | The reactor's live gauge panel: each file is one dial, read and turned while the reactor runs |
| `sysctl -w` (runtime change) | Turning a dial by hand: it holds until the next restart of the reactor |
| `/etc/sysctl.d/*.conf` and `sysctl --system` | The written dial settings in the start-up checklist, and reading that checklist out now |
| Reboot | Shutting the reactor down and starting it cold |
| Kernel module | A plug-in reactor part (a driver) that can be fitted or removed while flying |
| `modprobe` / `depmod` | The engineer who fits a part with everything it depends on / the parts catalogue that engineer reads |
| Module parameter / `options` line | A setting chosen when the part is fitted |
| Blacklist | A "never fit this part" note on the start-up checklist |
| Device (disk) and `/dev/sdX` | A cargo bay, and the bay number the ship hands out in arrival order |
| udev and a udev rule | The dock master who names each arriving bay, and the dock master's rule card |
| Stable name (serial, `/dev/disk/by-id`) | The bay's hull serial number: it never changes, whatever order bays arrive in |

**The crew**

| Term | Space picture |
| --- | --- |
| Process | A crew member doing one job |
| Thread | A pair of hands of the same crew member |
| PID and `kernel.pid_max` | The crew badge number, and the number of badges the ship can print |
| `ulimit -u` (`RLIMIT_NPROC`) | How many crew members one officer may have on duty at once |
| `TasksMax=` (cgroup) | How many crew members one station may hold, whoever they work for |
| Shell (`bash`) | The bridge console where the astronaut types orders |
| `sudo` / `root` | Borrowing the captain's authority / the captain |
| User and group | A name on the crew roster, and a team on that roster |
| System call | A crew member asking the reactor core for something (open a hatch, send a signal) |
| `strace` | The flight recorder clipped onto one crew member: it writes down every request they make to the core |
| Signal (`SIGTERM`, `SIGKILL`) | An order shouted to a crew member: "finish up and leave" / "out of the airlock now" |

**Stations and schedules**

| Term | Space picture |
| --- | --- |
| `systemd` | The ship's duty officer: it starts every station, watches it and restarts it |
| Service (unit) | A station that must always be staffed |
| Unit file | The duty card for one station |
| Drop-in override (`systemctl edit`) | A sticky note on the duty card that changes one line |
| `daemon-reload` | Telling the duty officer to read the duty cards again |
| `enable` / `start` | Putting the station on the launch checklist / staffing it right now |
| `Requires=`, `After=` | "This station needs that one staffed first" |
| Restart limit (`start-limit-hit`) | The duty officer giving up after too many failed attempts in a row |
| Journal (`journalctl`) and `journald` | The ship's log, and the log keeper who writes it (in memory only, or kept on disk) |
| Boot target (`multi-user.target`) | The ship's flight mode: which stations come up at launch |
| Port | A radio channel; only one station can listen on one channel |
| Cron job / crontab | A standing order on the ship's duty roster: "at 02:00, do this" |
| systemd timer | An alarm clock on the duty officer's desk that starts one station on schedule |
| `OnCalendar=` | The time written on that alarm clock |

**Containers and virtual machines**

| Term | Space picture |
| --- | --- |
| Container image | A sealed crate with a ready-to-run module inside |
| Container | A sealed pod docked to the ship: its own crew and air, sharing the ship's reactor |
| Docker engine (`dockerd`) | The docking bay crew that docks, starts and stops the pods |
| Port mapping (`-p 9090:80`) | Patching one of the ship's radio channels through to a pod's channel |
| Bind mount / volume | A hatch between a pod and one of the ship's cargo holds |
| Source tarball and `./configure`, `make`, `make install` | A kit of parts, the fitting plan for this ship, building it, and bolting it into place |
| libvirt / `virsh` | The hangar control system / its control console |
| Domain (virtual machine) | A smaller ship flown inside the hangar |
| Domain XML | The smaller ship's blueprint |
| Persistent vs transient domain | A ship with a registered blueprint on file / a ship launched from a blueprint nobody filed |
| Autostart | "Launch this ship whenever the hangar opens" |
| `shutdown` vs `destroy` | Asking the pilot to land / cutting the engines |
| qcow2 disk | The smaller ship's cargo hold, stored as one file in the hangar |

**Security: who may open which hatch**

| Term | Space picture |
| --- | --- |
| File permissions (DAC) | The lock on each hatch: the crate owner decides who gets a key |
| Mandatory access control (MAC) | The ship's security chief: a second check that overrides the owner's keys |
| AppArmor profile | The security chief's list of hatches one crew member may use, by path |
| Enforce mode / complain mode | Blocking and logging / only logging |
| `DENIED` audit line | The security chief's report of a hatch they kept shut |
| SELinux label (context) | A security tag stuck on every crew member and every crate; the rules compare tags, not paths |
| AVC denial | SELinux's report of a tag that did not match |

**Supply runs: packages**

| Term | Space picture |
| --- | --- |
| Package | A supply crate with a parts list, a version and the crates it needs |
| Repository | A supply depot that ships crates |
| Package index (`apt update`, `dnf makecache`, `zypper refresh`) | The depot's catalogue, downloaded to the ship |
| Signing key and `signed-by` | The depot's wax seal, and the rule that only crates with this seal are accepted from this depot |
| Package manager (`apt`, `dnf`, `zypper`) | The quartermaster: orders crates and every crate they depend on |
| Low-level tool (`dpkg`, `rpm`) | The loading crew: unpacks one crate it is handed, without ordering anything |
| Package database (`/var/lib/dpkg/status`, the RPM database) | The quartermaster's ledger of every crate on board |
| Hold / pin | A "do not replace" tag on one crate / a standing order to prefer one depot or version |
| Package group | A ready-made bundle of crates for one job |
| Patch (`zypper patch`) | A safety notice from the depot that names exactly which crates to replace |

**Emergency repairs**

| Term | Space picture |
| --- | --- |
| Boot | The launch sequence |
| GRUB and `grub.cfg` | The launch computer, and its launch checklist |
| `grub>` prompt | The launch computer with no checklist, waiting for typed orders |
| `/etc/fstab` | The list of cargo decks to attach at launch |
| Rescue shell / emergency mode | The emergency bridge with only life support running |
| `chroot` | Stepping into the damaged ship's bridge from a rescue ship, so its own controls work again |
| Bind-mounting `/dev`, `/proc`, `/sys` | Running power cables from the rescue ship into the damaged one |
| `/etc/shadow` | The locked roster of crew passwords |
| Partition table (GPT) | The deck plan that says where each cargo deck starts and ends |
| Partition table backup (`sgdisk --backup`) | A copy of the deck plan kept in another ship's safe |

### The lab machines and what they contain

There is no shared sample application. Every lab and playground boots its
own training ship (one Ubuntu 24.04 virtual machine with 2 CPUs, 2048 MB of
memory and a 15 GB disk; 20 GB in section 030; 3072 MB and 20 GB in
sections 060 and 070). Its `bootstrap/` scripts set up a small scenario.
Use these names exactly as the scripts create them:

| Lab (`metadata.name`) | Folder | What the bootstrap sets up |
| --- | --- | --- |
| `ats-002-lab-011` | `section-010/module-01/labs/lab-01` | `/opt/course` and `net.ipv4.ip_forward=1` persisted in `/etc/sysctl.d/` |
| `ats-002-lab-012` | `section-010/module-02/labs/lab-01` | User `dataproc` with a low process limit, a low `kernel.pid_max`, `data-ingest.service` with a low `TasksMax` |
| `ats-002-lab-012b` | `section-010/module-02/labs/lab-02` | Only `dataproc`'s `ulimit -u` is too low |
| `ats-002-lab-012c` | `section-010/module-02/labs/lab-03` | Only `data-ingest.service`'s `TasksMax=64` is too low |
| `ats-002-lab-013` | `section-010/module-03/labs/lab-01` | The `pcspkr` module loaded |
| `ats-002-lab-014` | `section-010/module-04/labs/lab-01` | An extra 1 GB disk (serial `lab014-backup-drive`) with one ext4 partition |
| `ats-002-lab-015` | `section-010/module-05/labs/lab-01` | Services `collector1`, `collector2`, `collector3`; only `collector2` calls `kill()` |
| `ats-002-lab-016` | `section-010/module-06/labs/lab-01` | `reportd.service` with a wrong `ExecStart` path (`status=203/EXEC`) |
| `ats-002-lab-017` | `section-010/module-06/labs/lab-02` | `metricsd.service` cannot write `/var/lib/metricsd` (`Permission denied`) |
| `ats-002-lab-018` | `section-010/module-06/labs/lab-03` | `webreport.service` cannot bind port 8080; `portsquatter.service` holds it |
| `ats-002-lab-019` | `section-010/module-06/labs/lab-04` | `ingest.service` requires a broken `ingest-db.service` and has hit its start limit |
| `ats-002-lab-016e` | `section-010/module-06/labs/lab-05` | `journald` at its defaults: volatile, no size cap |
| `ats-002-lab-016f` | `section-010/module-06/labs/lab-06` | Default target set to `graphical.target` |
| `ats-002-lab-010` | `section-010/capstone/labs/lab-01` | Low `kernel.pid_max`, `pcspkr` loaded, a telemetry disk (serial `lab010-telemetry`), a hung `telemetry-agent.service` |
| `ats-002-lab-021` | `section-020/module-01/labs/lab-01` | User `asset-manager` with `nightly-sync.sh` and `clean.sh`, and `/etc/cron.d/asset-cleanup` |
| `ats-002-lab-022` | `section-020/module-02/labs/lab-01` | Docker with containers `frontend_v1` and `frontend_v2` |
| `ats-002-lab-023` | `section-020/module-03/labs/lab-01` | `/usr/local/sbin/report.sh`, `/usr/local/sbin/dbclean.sh` and a cron job for `dbclean.sh` |
| `ats-002-lab-020` | `section-020/capstone/labs/lab-01` | Docker, container `billing_v1` holding host port 9090, user `ops-monitor` |
| `ats-002-lab-031` | `section-030/module-01/labs/lab-01` | `/tools/links-2.14.tar.bz2` and `build-essential` |
| `ats-002-lab-032` | `section-030/module-02/labs/lab-01` | libvirt with its `default` network and `/var/lib/libvirt/images/inventory-db.qcow2` |
| `ats-002-lab-033` | `section-030/module-02/labs/lab-02` | Transient domain `metrics-cache` and `/root/metrics-cache.xml` |
| `ats-002-lab-034` | `section-030/module-02/labs/lab-03` | Persistent domain `web-db`, too small (512 MiB, 1 vCPU), shut off |
| `ats-002-lab-030` | `section-030/capstone/labs/lab-01` | `/tools/vmreport-1.0.tar.gz`, libvirt and `/var/lib/libvirt/images/build-agent.qcow2` |
| `ats-002-lab-041` | `section-040/module-01/labs/lab-01` | The `appservice` daemon and a too-strict AppArmor profile in enforce mode |
| `ats-002-lab-042` | `section-040/module-01/labs/lab-02` | The `credsync` daemon; its profile denies `/etc/credsync/api.key` |
| `ats-002-lab-040` | `section-040/capstone/labs/lab-01` | Services `logshipper` and `metrics-agent`, each with a too-strict profile |
| `ats-002-lab-051` | `section-050/module-01/labs/lab-01` | A local signed APT repository on `127.0.0.1` with a stub `nginx` package |
| `ats-002-lab-051b` | `section-050/module-01/labs/lab-02` | `curl` with a newer version in `noble-updates` than in `noble` |
| `ats-002-lab-052` | `section-050/module-02/labs/lab-01` | A `logtail-utils` `.deb` in `/home/candidate/downloads/` and a half-configured `cowsay` |
| `ats-002-lab-053` | `section-050/module-03/labs/lab-01` | `ftp` installed with a configuration file; `fail2ban` not installed |
| `ats-002-lab-054` | `section-050/module-04/labs/lab-01` | Some `python3-*` packages and `/opt/course/apt-research` |
| `ats-002-lab-055` | `section-050/module-05/labs/lab-01` | A locally built `php8.1-*` package family; no build tools installed |
| `ats-002-lab-050` | `section-050/capstone/labs/lab-01` | A local vendor repository with `telemetry-agent`, a half-configured `tree`, an `obsagent-*` family, `/opt/course/onboarding` |
| `ats-002-lab-061` | `section-060/module-01/labs/lab-01` | `rpmbox` with a built `logship-agent-2.1.0-1` package |
| `ats-002-lab-062` | `section-060/module-02/labs/lab-01` | `rpmbox` with a corrupted RPM database |
| `ats-002-lab-066` | `section-060/module-02/labs/lab-02` | `rpmbox` with an unmet dependency (looks like corruption, is not) |
| `ats-002-lab-063` | `section-060/module-03/labs/lab-01` | `rpmbox` with EPEL, `telnet` installed, `fail2ban` and `mtr` not installed |
| `ats-002-lab-064` | `section-060/module-04/labs/lab-01` | `rpmbox` with EPEL and some `python3-*` packages |
| `ats-002-lab-065` | `section-060/module-05/labs/lab-01` | `rpmbox` with `automake` installed outside any group |
| `ats-002-lab-060` | `section-060/capstone/labs/lab-01` | `rpmbox` with a staged `metrics-shipper` package and a corrupted RPM database |
| `ats-002-lab-071` | `section-070/module-01/labs/lab-01` | `zypperbox` with `telnet-server` installed and `fail2ban` not installed |
| `ats-002-lab-072` | `section-070/module-02/labs/lab-01` | `zypperbox` with `python3-base` and `python3-pip`, and `/root/answers` |
| `ats-002-lab-070` | `section-070/capstone/labs/lab-01` | `zypperbox` with the `network-utilities` repository, `telnet-server`, `/root/answers` |
| `ats-002-lab-081` | `section-080/module-01/labs/lab-01` | A 2 GB disk (serial `lab081-data001`) holding a stand-in `data-001` root with a mistyped UUID in its `/etc/fstab` |
| `ats-002-lab-085` | `section-080/module-01/labs/lab-02` | A 2 GB disk (serial `lab085-data002`): `data-002` root whose `/etc/fstab` gives the wrong filesystem type |
| `ats-002-lab-082` | `section-080/module-02/labs/lab-01` | A 1 GB disk (serial `lab082-data001`) holding a stand-in root with a locked root account |
| `ats-002-lab-083` | `section-080/module-03/labs/lab-01` | A 2 GB disk (serial `lab083-vdc`) with a GPT table, two ext4 partitions and marker files |
| `ats-002-lab-084` | `section-080/module-04/labs/lab-01` | `/boot/grub/grub.cfg` removed from the running machine |
| `ats-002-lab-080` | `section-080/capstone/labs/lab-01` | `grub.cfg` removed, and a 2 GB disk (serial `lab080-vdc`) whose GPT table was wiped |

The playgrounds (no task, no grading):

| Playground (`metadata.name`) | Folder | What is in the box |
| --- | --- | --- |
| `sysctl-live-kernel` | `section-010/module-01/playground` | A clean machine; `procps` and `systemd` are already there |
| `process-limits-ceilings` | `section-010/module-02/playground` | User `dataproc` and a demo service with a low `TasksMax` |
| `kernel-modules-lab` | `section-010/module-03/playground` | `kmod` tools; the `dummy` and `pcspkr` modules are available, nothing loaded |
| `udev-stable-naming` | `section-010/module-04/playground` | An extra 1 GB disk with serial `BACKUPWD42` |
| `strace-process-forensics` | `section-010/module-05/playground` | `strace` and three `collector` background processes |
| `systemd-service-debugging` | `section-010/module-06/playground` | `apache2`, failing because port 80 is already taken |
| `libvirt-vm-lifecycle` | `section-030/module-02/playground` | libvirt with its `default` network and `/var/lib/libvirt/images/inventory-db.qcow2` |
| `apparmor-mac-enforcement` | `section-040/module-01/playground` | The `appservice` daemon writing to `/srv/applogs` and a too-strict profile in enforce mode |

Modules in sections 020, 030 (module 1) and 050 to 080 have no
playground. Course pages there use small examples the reader can try on
any Ubuntu 24.04 machine or inside a running lab. When a page shows a
lab's own names, they must match the tables above.

### Environment facts the text must respect

- **Labs and playgrounds are virtual machines, not clusters.** Every one
  uses `runtime.type: "qemu"`. The learner reaches it with
  `astrona ssh <name>`; the `astro-` prefix in front of the name (as in
  `astrona ssh astro-sysctl-live-kernel`) is optional. There is no
  `kubectl`.
- **`astrona stop` and `astrona start` do not support `qemu` labs yet.** So
  a `## Your mission` section in a module with a playground cannot pause the
  playground. It removes it instead (`astrona destroy <playground name>`)
  before the mission, and after the mission brings it back with the
  playground's `astrona run` command (a playground always starts clean).
  When the command line tool supports `qemu` stop and start, switch to
  `astrona stop` and `astrona start`.
- **Extra disks are found by serial.** Labs in sections 010 and 080 and the
  udev playground add a small disk. Its device letter is not fixed, so
  scripts reach it through `/dev/disk/by-id/virtio-<serial>`. Never tell
  the reader the disk is always `/dev/vdb`.
- **Recovery is practised on a spare disk.** Section 080 stages the broken
  root filesystem, the locked account and the wiped partition table on a
  disposable extra disk, so the lab machine itself always stays reachable
  over SSH. Only the GRUB labs touch the running machine's own
  `/boot/grub/grub.cfg`.
- **Other distributions run in containers.** Sections 060 and 070 install
  Docker on the Ubuntu machine and run `rockylinux:9`-based `rpmbox` and
  `opensuse/leap:15.6`-based `zypperbox` as long-lived privileged
  containers. Commands run inside them (`sudo docker exec -it rpmbox bash`).
  The package tools inside are real; only the host is different.
- **Ubuntu-only gaps.** Real SELinux enforcement, `rd.break` and the
  RHEL-family boot flow cannot run on the Ubuntu image. Pages teach them as
  worked walkthroughs and say so plainly; never pretend the reader can run
  them in a lab.
- **Local package repositories.** Section 050 labs serve their own signed
  APT repository on `127.0.0.1` (built with `reprepro`) and build their own
  `.deb` files, so they do not depend on outside vendors.

### Where things are in this repo

| What | Where |
| --- | --- |
| Course outline the platform reads: every reading page and lab, in order. Never list `solution.md` here | `astrona.yaml` |
| Overview, sections table, how to run things | `README.md` |
| Section overview and its modules | `sections/section-0N0/README.md` |
| Module reading: landing page, deep-dive parts, wrap-up | `sections/section-0N0/module-0M/course.md`, `course-0N-*.md` |
| Section knowledge check (multiple choice) | `sections/section-0N0/quiz.md` |
| Final domain quiz | `sections/final-domain-quiz.md` |
| Graded lab: task, walkthrough, setup, grader | `.../labs/lab-0N/` (`question.md`, `solution.md`, `bootstrap/`, `validation/`) |
| Ungraded sandbox for a module | `.../playground/` (`config.yaml`, `bootstrap/`, `docs/overview.md` says what is in the box) |
| One graded integration lab per section | `sections/section-0N0/capstone/labs/lab-01/` |

A lab folder holds:

| Path | Purpose |
| --- | --- |
| `config.yaml` | Lab definition; `metadata.docs` has `question: "question.md"` and `solution: "solution.md"` |
| `README.md` | Short intro with the run command |
| `question.md` | The exam-style task. Starts with `# Question` and `Solve this question on: \`terminal\`` |
| `solution.md` | Step-by-step walkthrough with real output |
| `bootstrap/` | Starting state of the machine, never the graded result |
| `validation/` | Grading scripts that check the machine's real state |

### Lab metadata in `astrona.yaml`

`astrona.yaml` has one entry per section under `modules:` (`module-010`
to `module-080`, plus `module-090` for the final domain quiz). Each
section's `content` lists, in order: the section `README.md`, then for each
module its landing page, its parts, and right after the part a lab tests, a
`Question` reading (`labs/lab-0N/question.md`) followed by the `type: lab`
entry; the module's wrap-up page comes last. The section quiz and then the
section capstone close the section. Playgrounds are not listed: the landing
page's `<!-- astrona:playground -->` marker shows them.

Every `type: lab` entry (module labs and capstones) carries these fields, in
this order:

```yaml
      - type: reading
        title: Question
        path: sections/section-010/module-01/labs/lab-01/question.md
      - type: lab
        title: "sysctl Live Kernel State Lab"
        path: sections/section-010/module-01/labs/lab-01
        difficulty: intermediate
        estimated_duration: 15m
        topic: kernel-parameters
        task_kind: build
        tags: [uname, sysctl, proc-sys, timedatectl, redirection]
        learning_goals:
          - Write the running kernel release into a file with the right uname option
          - Read a live kernel parameter value without any extra text
        resources:
          - name: "sysctl(8) manual page"
            url: https://man7.org/linux/man-pages/man8/sysctl.8.html
```

- `difficulty`: `beginner`, `intermediate` or `advanced`.
- `estimated_duration`: realistic time to solve it, for example `15m`, `30m`, `45m`.
- `topic`: exactly one of `kernel-parameters`, `process-limits`,
  `kernel-modules`, `devices`, `process-forensics`, `services`,
  `scheduling`, `containers`, `building-software`, `virtual-machines`,
  `mandatory-access-control`, `debian-packages`, `rpm-packages`,
  `suse-packages`, `system-recovery`.
- `task_kind`: exactly one of `build` (create the result from scratch),
  `troubleshooting` (find and fix what is broken) or `migration` (move a
  working setup to another form or place, for example a cron job to a
  systemd timer). The platform filters labs by it, so it is a field of its
  own, never a tag.
- `tags`: 4 to 8 ids, only from the tag list below. Add a new tag to the list
  first if nothing fits.
- `learning_goals`: 2 or 3 plain sentences, each starting with a verb, saying
  what the learner proves in this lab.
- `resources`: 1 to 4 documentation pages, each with a `name` and a `url`
  that loads. This is the **only** place outside links are allowed: the
  platform shows them as optional further reading next to the lab.

**Tag list** (lower case, hyphens, never synonyms):

- Kernel: `uname`, `sysctl`, `proc-sys`, `sysctl-d`, `kernel-modules`,
  `modprobe`, `modprobe-d`, `module-parameters`, `blacklist`, `lsmod`
- Processes and limits: `pid-max`, `ulimit`, `limits-conf`, `tasksmax`,
  `cgroups`, `strace`, `syscalls`, `signals`, `kill`, `pgrep`
- Devices and disks: `udev`, `udev-rules`, `udevadm`, `disk-serial`,
  `block-devices`, `blkid`, `mount`
- Services: `systemd`, `systemctl`, `unit-files`, `drop-in-override`,
  `daemon-reload`, `journalctl`, `journald`, `exit-status`,
  `file-permissions`, `port-conflict`, `unit-dependencies`,
  `restart-policy`, `boot-target`, `timedatectl`, `redirection`
- Scheduling: `cron`, `crontab`, `cron-d`, `systemd-timers`, `oncalendar`
- Containers: `docker`, `container-lifecycle`, `docker-inspect`,
  `port-mapping`, `bind-mounts`, `resource-limits`
- Building and virtual machines: `source-build`, `tarball`, `configure`,
  `make`, `libvirt`, `virsh`, `virt-install`, `domain-xml`, `qcow2`,
  `autostart`, `transient-domain`, `vm-resources`
- Mandatory access control: `apparmor`, `aa-status`, `apparmor-profiles`,
  `enforce-mode`, `complain-mode`, `audit-log`, `selinux`
- Debian packages: `apt`, `apt-cache`, `dpkg`, `apt-repositories`,
  `gpg-keyring`, `signed-by`, `apt-pinning`, `apt-mark-hold`,
  `package-versions`, `purge`, `autoremove`, `package-search`,
  `package-ownership`, `interrupted-install`
- RPM packages: `rpm`, `rpm-verify`, `rpm-database`, `rpmdb-rebuild`,
  `dnf`, `dnf-history`, `dnf-groups`, `dnf-provides`, `epel`,
  `dependency-check`
- SUSE packages: `zypper`, `zypper-patch`, `zypper-update`,
  `zypper-search`, `zypper-what-provides`, `zypper-repositories`
- Recovery: `chroot`, `fstab`, `rescue-shell`, `password-reset`,
  `etc-shadow`, `partition-table`, `gpt`, `sgdisk`, `grub`,
  `grub-install`, `update-grub`, `boot-recovery`

### Running things

```bash
# Playground (ungraded)
astrona run --git ssh://git@github.com/astrona-io/ATS002.git -c sections/section-010/module-01/playground
astrona ssh sysctl-live-kernel          # open a terminal on the playground machine
astrona destroy sysctl-live-kernel      # takes metadata.name from config.yaml, not the path

# Lab or capstone (graded against the live virtual machine)
astrona run --git git@github.com:astrona-io/ATS002.git -c sections/section-010/module-01/labs/lab-01
astrona ssh ats-002-lab-011
astrona submit -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-002-lab-011

# Authors: run a local, uncommitted copy and check its configuration
astrona run -c sections/section-010/module-01/labs/lab-01
astrona validate -c sections/section-010/module-01/labs/lab-01
astrona test -c sections/section-010/module-01/labs/lab-01
```

Names: a playground keeps its short topic name (`sysctl-live-kernel`,
`libvirt-vm-lifecycle`; see the table above). Labs are
`ats-002-lab-<section><module>` (`ats-002-lab-011`) and capstones
`ats-002-lab-<section>0` (`ats-002-lab-010`); extra labs in one module
took a letter (`ats-002-lab-012b`) or the next free number
(`ats-002-lab-066`). Keep those names. A new lab takes a name no other lab
uses. The local developer build of `astrona validate` may report
`unknown field "solution"` and `"question"` in `metadata.docs`; that is a
validator issue, not a lab issue.

Graders check **the machine's real state** (a live kernel value and its
persistent file, a running or enabled service, a container's state, a
domain's definition, a loaded profile, an installed package version, a
restored partition table), not what the learner typed. A lab's
`question.md` and `solution.md` must match what its `validation/` scripts
actually check.

Test machines on the maintainer's computer: one at a time. Podman has 10 GiB
and also runs the platform stack; parallel labs run it out of memory.

### Where to find trusted sources

Check facts here before writing them down. Prefer these over memory.

- **Manual pages:** <https://man7.org/linux/man-pages/> (`sysctl(8)`,
  `sysctl.d(5)`, `proc(5)`, `modprobe(8)`, `modprobe.d(5)`, `udev(7)`,
  `udevadm(8)`, `strace(1)`, `crontab(5)`, `getrlimit(2)`), and
  <https://manpages.ubuntu.com/> for the 24.04 (noble) versions the labs run.
- **systemd:** <https://www.freedesktop.org/software/systemd/man/latest/>
  (`systemd.unit`, `systemd.service`, `systemd.exec`,
  `systemd.resource-control`, `systemd.timer`, `systemd.time`,
  `journald.conf`, `systemctl`, `journalctl`).
- **Containers:** <https://docs.docker.com/reference/cli/docker/>.
- **Building software:** the GNU make manual
  <https://www.gnu.org/software/make/manual/> and the Autoconf manual
  <https://www.gnu.org/software/autoconf/manual/>.
- **Virtual machines:** <https://libvirt.org/manpages/virsh.html> and the
  domain XML format <https://libvirt.org/formatdomain.html>.
- **Mandatory access control:** <https://ubuntu.com/server/docs/how-to/security/apparmor/>,
  <https://gitlab.com/apparmor/apparmor/-/wikis/Documentation>, and the
  Red Hat SELinux guide
  <https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_selinux/>.
- **Packages:** the Debian `apt` and `dpkg` manual pages
  (<https://manpages.debian.org/>), `apt_preferences(5)` for pinning,
  <https://dnf.readthedocs.io/>, <https://rpm.org/documentation.html>, and
  the openSUSE Zypper documentation <https://en.opensuse.org/SDB:Zypper_manual>.
- **Recovery:** the GNU GRUB manual <https://www.gnu.org/software/grub/manual/grub/>,
  `sgdisk(8)` and `fstab(5)`.
- **The exam itself:** the LFCS page on the Linux Foundation training site
  lists the official curriculum. The domain weight (25%) and the exam topic
  names above come from this repository's README and `astrona.yaml` and have
  not been re-checked against it.

### Skills to use here

The `astrona-course-*` skills do most authoring jobs in this repository: planning
(`domain-plan`), creating the tree (`domain-scaffold`), building modules
(`domain-build`), deep-dive parts (`deep-dive`), labs and playgrounds (`lab`),
lab docs (`lab-docs`), challenges (`create-challenge`), quizzes
(`generate-assessment`) and fact-checking (`review-accuracy`).
