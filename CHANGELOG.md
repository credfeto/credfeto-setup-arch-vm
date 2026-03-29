# Changelog
All notable changes to this project will be documented in this file.

<!--
Please ADD ALL Changes to the UNRELEASED SECTION and not a specific release
-->

## [Unreleased]
### Added
- AI instructions for changelog tool and self-documenting rules workflow
- Security review workflow using GitHub Copilot to analyse and harden the install script
- linux-hardened kernel and linux-hardened-headers packages
- SSH hardening with strong crypto, key-only auth, and no root login
- Additional sysctl hardening: ASLR, sysrq disable, source route blocking, RA disable, ICMP broadcast, filesystem protections, core dump prevention
- Core dump disabling via systemd DefaultLimitCORE=0
- Kernel module blacklist for unused network protocols and filesystems
- Hardened /tmp as noexec nosuid nodev tmpfs
- Diagnostic check that only linux-hardened kernel is installed and currently running
- Install script instruction: every installed package or service must also be hardened
- logrotate installed and configured with daily rotation and 14-day retention
- Arch Linux instruction noting /tmp is managed by systemd tmp.mount, not fstab
- generate-pr-description composite action for diffing commits and generating Copilot PR description text
- pull-request-template instruction rule for automated workflows
### Fixed
- Enable pkgstats.timer via symlink for static unit as it has no [Install] section and cannot be enabled with systemctl enable
- Run apt-get update before installing shellcheck/devscripts to avoid stale package cache
- Validate generated install script with shellcheck and checkbashisms before saving; reject output with bashisms
- Add retry loop feeding shellcheck errors back to model when generated script fails validation
- Strip local declarations from script before sending to model; use compact retry requests to avoid 413 token limit
- Always checkout and branch from head of main in security review workflow
- Remove --permanent flag from firewall-cmd --set-default-zone (incompatible options)
- Fix SSH cipher names: aes256-gcm and aes128-gcm (no hyphen after aes)
- Upgrade actions/github-script from v7 to v8.0.0 to fix Node.js 20 deprecation warning
- Use mount -o remount /tmp instead of invalid systemctl remount command
- Use systemctl restart tmp.mount instead of mount -o remount for systemd-managed /tmp
### Changed
- Use dotnet changelog invocation instead of direct changelog command to avoid PATH configuration
- Move remembering-new-rules guidance from changelog instructions to .ai-instructions index
- Git workflow instruction to push to origin after committing to an existing branch
- AI instruction to re-read all instructions before starting work on a feature
- SSH hardening config split to one setting per file in sshd_config.d/, mirroring sysctl pattern
- linux-hardened kernel is now a prerequisite verified by diagnostic, not installed by the script
- PasswordAuthentication only disabled over SSH if at least one user has authorized_keys configured, preventing lockout
- Disable KbdInteractiveAuthentication and ChallengeResponseAuthentication alongside PasswordAuthentication when authorized_keys are present
- sshd only reloaded if already running; config is written regardless but service is not started if not already active
- Docker daemon.json hardened: icc=false, no-new-privileges=true, userland-proxy=false, log rotation; idempotency now checks file content
- firewalld default zone set to drop; SSH added to public zone; docker0 added to trusted zone
- Harden /tmp via systemd tmp.mount drop-in (noexec) instead of fstab entry, which is the correct approach for Arch Linux
- maintain-pr-description workflow refactored to use shared generate-pr-description action
- Simplify PR description approach: generate-pr-description action takes base/head SHAs and returns description text; workflows own template composition
- Only install shellcheck/devscripts if not already present; skip apt-get update when not needed
- Use build-tools and dotnet-tool-run actions for dotnet and changelog tool setup
- Pass NUGET_PUBLIC_RESTORE_FEED to build-tools action, falling back to public NuGet v3 feed
- Blacklist each kernel module in its own /etc/modprobe.d/blacklist.<module>.conf file with a detailed comment explaining why it is blacklisted, using a new blacklist_module function
### Removed
### Deployment Changes

<!--
Releases that have at least been deployed to staging, BUT NOT necessarily released to live.  Changes should be moved from [Unreleased] into here as they are merged into the appropriate release branch
-->
## [0.0.0] - Project created