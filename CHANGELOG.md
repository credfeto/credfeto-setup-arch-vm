# Changelog
All notable changes to this project will be documented in this file.

<!--
Please ADD ALL Changes to the UNRELEASED SECTION and not a specific release
-->

## [Unreleased]
### Added
- SSH hardening with strong crypto, key-only auth, and no root login
- Additional sysctl hardening: ASLR, sysrq disable, source route blocking, RA disable, ICMP broadcast, filesystem protections, core dump prevention
- Core dump disabling via systemd DefaultLimitCORE=0
- Kernel module blacklist for unused network protocols and filesystems
- Hardened /tmp as noexec nosuid nodev tmpfs
- Diagnostic check that only linux-hardened kernel is installed and currently running
- logrotate installed and configured with daily rotation and 14-day retention
### Fixed
- Enable pkgstats.timer via symlink for static unit as it has no [Install] section and cannot be enabled with systemctl enable
- Remove --permanent flag from firewall-cmd --set-default-zone (incompatible options)
- Fix SSH cipher names: aes256-gcm and aes128-gcm (no hyphen after aes)
- Use systemctl restart tmp.mount instead of mount -o remount for systemd-managed /tmp
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
### Removed
### Deployment Changes

<!--
Releases that have at least been deployed to staging, BUT NOT necessarily released to live.  Changes should be moved from [Unreleased] into here as they are merged into the appropriate release branch
-->
## [0.0.0] - Project created