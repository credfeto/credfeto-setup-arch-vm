# Changelog
All notable changes to this project will be documented in this file.

<!--
Please ADD ALL Changes to the UNRELEASED SECTION and not a specific release
-->

## [Unreleased]
### Security
### Added
- Git workflow instructions: never-squash-commits rule to preserve the full commit history however messy the path
- AI instructions: mandatory git identity and GPG signing check before any commit — abort if identity is `andy@nanoclaw.ai` or GPG signing is disabled
- SSH hardening with strong crypto, key-only auth, and no root login
- Additional sysctl hardening: ASLR, sysrq disable, source route blocking, RA disable, ICMP broadcast, filesystem protections, core dump prevention
- Core dump disabling via systemd DefaultLimitCORE=0
- Kernel module blacklist for unused network protocols and filesystems
- Hardened /tmp as noexec nosuid nodev tmpfs
- Diagnostic check that only linux-hardened kernel is installed and currently running
- logrotate installed and configured with daily rotation and 14-day retention
- Install and configure fail2ban with 1h ban time, firewalld rich-rules backend, and aggressive SSH jail
- Show reboot required warning if running kernel no longer matches installed kernel
- Write /etc/sudoers.d/01_markr with NOPASSWD when yay installed, password-required otherwise
- Log martian (impossible source) packets via net.ipv4.conf.all/default.log_martians
- Explicitly enforce kernel.perf_event_paranoid=3 to restrict perf_event_open to CAP_SYS_ADMIN
- Blacklist n_hdlc (CVE-2017-2636), ax25, netrom, x25, can, vivid, usb_storage, bluetooth, btusb modules on Proxmox VM where hardware is absent
- install script creates a security script in the current working directory
- Install ansible and configure ansible-pull systemd timer to automatically apply latest system configuration every 6 hours, replacing the manual security script
- Add site.yml Ansible playbook entry point for ansible-pull
- Harden default umask to 027 via /etc/profile.d/umask.sh
- Install and enable AppArmor service with community profiles enforced for sshd, docker-default, and fail2ban
- Install audit package alongside AppArmor for kernel-level audit logging
- Enable auditd service for AppArmor audit event logging
- Remove orphaned packages inline after package install step rather than via a systemd timer
- Enforce signed kernel modules via module.sig_enforce=1 GRUB parameter to prevent loading of unsigned modules
- Improve ASLR entropy via vm.mmap_rnd_bits=32 and vm.mmap_rnd_compat_bits=16
- Persist net.ipv6.conf.all.forwarding=1 and net.ipv6.conf.default.forwarding=1 for routed Docker/VM traffic
- Block newly connected USB devices after boot via kernel.deny_new_usb=1 to prevent BadUSB attacks on a headless server VM
- Add mitigations=auto to GRUB to explicitly enable all applicable CPU vulnerability mitigations (Spectre, Meltdown, MDS, etc.)
- Add mce=0 to GRUB to panic immediately on uncorrectable hardware memory errors
- Disable TCP SACK (net.ipv4.tcp_sack=0) to reduce remote kernel exploit surface (CVE-2019-11477, CVE-2019-11478, CVE-2019-11479)
- Enable IOMMU in GRUB (intel_iommu=on, amd_iommu=on, iommu=force) to provide DMA protection against malicious devices
- Add oops=panic to GRUB to cause an immediate kernel panic on any kernel oops, preventing post-oops exploitation
- Ansible playbook with 11 roles (packages, users, docker, sysctl, grub, ssh, firewall, network, apparmor, services, ansible_pull) replacing the monolithic install script with native Ansible tasks using ansible.posix and community.general collections
- ansible-lint job added to pull-request.yml CI workflow
- requirements.yml listing ansible.posix and community.general collections
- Mount /proc with hidepid=2 and gid=proc to prevent cross-user process visibility
- Blacklist kernel modules esp4, esp6, and rxrpc affected by Dirty Frag (CVE-2026-43284, CVE-2026-43500) to prevent local privilege escalation
- Schedule reboot 60 s after Ansible run when kernel image or GRUB config changed since last boot
- Ensure user 'markr' exists with sudo NOPASSWD, SSH-only login, and authorized SSH keys from GitHub
- Configure sshd AuthorizedKeysCommand to look up SSH public keys from keys.markridgwell.com
- Podman as the default container runtime for new VMs (controlled by container_runtime variable)
- Podman registries mirror configuration via /etc/containers/registries.conf
- podman-cleanup.timer to prune unused Podman images weekly
- Enable kernel.unprivileged_userns_clone=1 when Podman is installed for rootless container support
- Blacklist unused kernel modules to reduce LPE attack surface (DCCP, SCTP, RDS, TIPC, legacy protocols, unused filesystems)
- Daily Podman container security audit: shellcheck-clean POSIX sh script checks each running container for privileged mode, root user, writable rootfs, CAP_SYS_ADMIN, host network, and missing memory/PID limits; wired to a systemd timer via Ansible
- Configure auditd with kernel syscall auditing rules for security monitoring
- Pin IPv6AcceptRA=no on the primary interface so systemd-networkd doesn't override the sysctl role's RA-acceptance hardening for that link
- Set Domains=~. in the systemd-resolved global config so unqualified lookups are never suffixed with a search domain, matching the static resolv.conf's search .
- Fail the run with a clear error if network_nameservers_ipv4 and network_nameservers_ipv6 are ever configured with different lengths, instead of silently dropping the extra entries from dns-?? hosts' resolv.conf
### Fixed
- Add --needed flag to chaotic-aur package installs to skip reinstalling already-up-to-date packages
- Add --needed to pacman -U for Chaotic AUR keyring and mirrorlist installs to avoid re-installing on every script run
- Enable pkgstats.timer via symlink for static unit as it has no [Install] section and cannot be enabled with systemctl enable
- Remove --permanent flag from firewall-cmd --set-default-zone (incompatible options)
- Fix SSH cipher names: aes256-gcm and aes128-gcm (no hyphen after aes)
- Use systemctl restart tmp.mount instead of mount -o remount for systemd-managed /tmp
- sysctl_set no longer aborts when a key is absent from /proc/sys (e.g. kernel.kexec_load_disabled on linux-hardened with CONFIG_KEXEC=n) — persistent config is still written, live apply is skipped with a clear message
- Detect physical network interface on VMs by matching common prefixes (eth, enp, ens) instead of using 'type ether' filter
- Restrict autoupdate sudoers to /usr/bin/pacman only instead of unrestricted root access
- Corrected typo in sshd config filename logingraceime to loginGraceTime and clean up old misnamed file
- Correct RFC 1918 firewalld CIDR for 172.16.0.0 range from /20 to /12 and remove any legacy /20 rules
- Consolidate Docker restarts to avoid restarting twice when both daemon.json and legacy drop-in change
- Enable post-quantum key exchange algorithms (mlkem768x25519-sha256, sntrup761x25519-sha512) in SSH server to prevent store-now-decrypt-later attacks
- Ensure sshd host keys are generated before SSH configuration on fresh installs
- Add idempotency checks to paccache-cleanup service and timer configuration
- Skip manual reflector.service start when reflector.timer is already active
- Add idempotency check for reflector.conf configuration
- Disable TCP timestamps (net.ipv4.tcp_timestamps=0) to prevent uptime leakage and OS fingerprinting
- set net.bridge.bridge-nf-call-iptables=0 via sysctl; enable firewalld masquerade with --add-masquerade
- change rp_filter from strict (1) to loose (2) to allow Docker container routing; persist net.ipv4.ip_forward=1 so container traffic survives sysctl reloads
- net.bridge.bridge-nf-call-iptables corrected to 1 (was incorrectly set to 0 in #111) — value 1 enables iptables filtering on bridged traffic, required for Docker networking rules to apply to container traffic
- Docker daemon.json: set firewall-backend to nftables so Docker uses nftables for its NAT/filtering rules, consistent with the system firewall (firewalld running in nftables mode)
- Clarify TCP timestamps comment: document PAWS-bypass mitigation and relationship with net.ipv4.tcp_rfc1337=1
- Pass -H flag to sudo when running ansible-pull as autoupdate user so HOME is set correctly
- Run sysctl role before docker role so ip_forward and bridge sysctls are set before Docker starts
- Load br_netfilter module before applying net.bridge.bridge-nf-call-iptables sysctl so the setting succeeds on first provision
- Replace unsupported ignore_errors task keyword with module's own ignoreerrors: true parameter for kernel.kexec_load_disabled and kernel.deny_new_usb sysctl tasks
- Ensure docker firewalld zone exists on fresh VM before assigning Docker bridge subnet
- Run mkinitcpio -P after GRUB config changes to ensure initramfs stays in sync
- Static /etc/resolv.conf on dns-?? hosts interleaves IPv6/IPv4 nameservers (offset so adjacent lines are never the same physical host) instead of listing all IPv6 first, so glibc's 3-line limit still gives 3 different hosts instead of only IPv6 ones
- Exclude temporary and deprecated-flagged addresses from IPv4/IPv6 detection on the primary interface, so a rotating privacy-extension or expiring address never gets pinned into a static Address= line in eth0.network
### Changed
- SSH hardening config split to one setting per file in sshd_config.d/, mirroring sysctl pattern
- linux-hardened kernel is now a prerequisite verified by diagnostic, not installed by the script
- PasswordAuthentication only disabled over SSH if at least one user has authorized_keys configured, preventing lockout
- Disable KbdInteractiveAuthentication and ChallengeResponseAuthentication alongside PasswordAuthentication when authorized_keys are present
- sshd only reloaded if already running; config is written regardless but service is not started if not already active
- Docker daemon.json hardened: icc=false, no-new-privileges=true, userland-proxy=false, log rotation; idempotency now checks file content
- firewalld default zone set to drop; SSH added to public zone; docker0 added to trusted zone
- Harden /tmp via systemd tmp.mount drop-in (noexec) instead of fstab entry, which is the correct approach for Arch Linux
- Blacklist each kernel module in its own /etc/modprobe.d/blacklist.<module>.conf file with a detailed comment explaining why it is blacklisted, using a new blacklist_module function
- Apply Copilot security analysis improvements to install script
- Generate descriptive commit title and PR title from actual diff in security review workflow
- Restrict systemd drop-ins to services the script configures; require cited source for any package-manager service exception
- Remove systemd security drop-ins for docker, firewalld, and sshd; clean up any previously installed files
- Refactor firewalld rules into firewalld_allow_private function with idempotency and ok/skip/die output
- Add IPv6 private range rules (ULA fc00::/7, link-local fe80::/10) to firewalld_allow_private function
- Apply sysctl changes live with sysctl -w in addition to writing persistent /etc/sysctl.d file
- Add rule that all configuration changes must be applied live and persistently in the same step
- Use yay -Syyu in auto-update service when yay is installed, falling back to pacman
- Run auto-update service as markr user when yay is installed; set NOPASSWD sudoers accordingly
- Replace markr sudoers management with dedicated autoupdate system user (nologin, no home) for yay auto-update
- autoupdate user always created regardless of whether yay is installed
- auto-update service always runs as autoupdate user; wrapper uses sudo pacman as fallback when yay is absent
- Add integrity LSM to GRUB lsm= kernel parameter for IMA support alongside AppArmor
- Consolidated all unconditional pacman package installs into a single sorted call
- install script reduced to a thin bootstrap: installs ansible+git, creates autoupdate system user with NOPASSWD:ALL sudoers, writes and enables the hourly ansible-pull service+timer, then runs ansible-pull once immediately
- ansible-pull timer changed from 6-hourly to hourly (OnUnitActiveSec=1h)
- autoupdate sudoers broadened from NOPASSWD:/usr/bin/pacman to NOPASSWD:ALL so ansible-pull can become root for all configuration tasks
- security: add checks to prevent overwriting existing config files
- Simplify install script to bootstrap only: install ansible+git, install Galaxy collections, run ansible-pull once — all further configuration (user, sudoers, service, timer) is now managed exclusively by the playbook
- security-review: rewrite workflow to analyse Ansible role YAML files (`roles/**/tasks/main.yml`, `site.yml`) instead of the install shell script; security findings are now reported as GitHub issues labelled `AI-Work` rather than opening pull requests with direct code changes; added `AI-Work` label definition to `.github/labels.yml`
- Randomise systemd timer offsets to prevent simultaneous runs across VMs
- Docker packages (docker-buildx, docker-compose) only installed when container_runtime is set to docker
- Docker firewalld zone only created when container_runtime is set to docker
- Explicitly set insecure = false on the Podman registry mirror to enforce HTTPS, matching the docker registry-mirrors configuration
- Route DNS via systemd-resolved (fleet-wide DNS=, DNSSEC=allow-downgrade, LLMNR/MulticastDNS disabled) instead of a static /etc/resolv.conf, except on dns-?? hosts which keep the static file so a systemd-resolved restart/crash can't cut them off from their own upstream nameservers
- Renumber fleet nameservers from 192.168.42.251-254 / 2a02:8010:61d5:42::251-254 (4 servers) to 192.168.42.101-105 / 2a02:8010:61d5:42::101-105 (5 servers)
- eth0.network now writes an Address= line for every address detected on the primary interface per IPv4/IPv6 family, instead of only the first, so hosts with a manually added secondary address are handled without being skipped
- Remove the redundant per-link DNS= from eth0.network; the fleet nameservers are now configured in exactly one place (the global systemd-resolved drop-in) instead of twice for every non-dns-?? host
### Removed
- Remove criu and pigz packages — neither is used or configured by the script
- Remove curl-based security script in favour of ansible-pull timer
- auto-update bash script, service, and timer — superseded by the packages role running pacman -Syyu on every hourly ansible-pull run
### Deployment Changes
- Already-provisioned hosts have /etc/resolv.conf replaced (static file on dns-?? hosts, symlink to systemd-resolved's stub on every other host) and systemd-resolved restarted on their next ansible-pull run
<!--
Releases that have at least been deployed to staging, BUT NOT necessarily released to live.  Changes should be moved from [Unreleased] into here as they are merged into the appropriate release branch
-->
## [0.0.0] - Project created