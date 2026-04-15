# Changelog
All notable changes to this project will be documented in this file.

<!--
Please ADD ALL Changes to the UNRELEASED SECTION and not a specific release
-->

## [Unreleased]
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
### Removed
- Remove criu and pigz packages — neither is used or configured by the script
- Remove curl-based security script in favour of ansible-pull timer
### Deployment Changes

<!--
Releases that have at least been deployed to staging, BUT NOT necessarily released to live.  Changes should be moved from [Unreleased] into here as they are merged into the appropriate release branch
-->
## [0.0.0] - Project created