# Lynis Baseline

Maintained by the test-VM lynis audit described in
[ai/local/testing.instructions.md](ai/local/testing.instructions.md).
Ratchet rule: the hardening index must not drop below the value recorded
here, and any suggestion or warning not listed below is a new finding
that must be triaged before a PR is marked ready.

## Hardening index

**76** (lynis 3.1.7 on arch-vm-test.lan)

For reference: 74 before the #62 hardening changes (75 before the
review-pass fixes added the sshd Banner and the root core-dump limit).

## Expected warnings (dynamic conditions, not regressions)

- `KRNL-5830` (reboot needed) - appears whenever the installed kernel is
  newer than the running one; the reboot role reboots the host on its
  next scheduled run, so this clears itself.
- `PKGS-7322` (vulnerable packages found) - arch-audit reporting
  packages with published CVEs not yet fixed upstream; on a rolling
  release this is routinely non-empty and clears as fixed versions land
  via the hourly update. Investigate only if `arch-audit` shows
  something exploitable in a service this fleet actually exposes.

## Accepted suggestions

| Test | Suggestion | Reason accepted |
| ---- | ---------- | --------------- |
| AUTH-9230 | Configure password hashing rounds | lynis only recognises `SHA_CRYPT_*_ROUNDS`; Arch uses `ENCRYPT_METHOD YESCRYPT`, and the cost is hardened via `YESCRYPT_COST_FACTOR 7` (users role). Adding SHA rounds would be inert scanner-appeasement. |
| AUTH-9262 | PAM password strength module | Password authentication is disabled fleet-wide (key-only SSH, NOPASSWD sudo); there are no passwords to strength-test. |
| AUTH-9282 | Expire dates on password-protected accounts | No password-protected interactive accounts exist. |
| AUTH-9284 | Review/remove locked accounts | The locked accounts are standard system accounts owned by packages. |
| AUTH-9286 | Min/max password age | Password authentication is disabled; aging adds lockout risk with no benefit. |
| BOOT-5122 | GRUB boot loader password | Headless VMs recovered via console; a GRUB password blocks unattended recovery. Hypervisor access already implies full control. |
| BOOT-5264 | Harden systemd services | Real work, tracked separately - see the follow-up issue for per-service `systemd-analyze security` sandboxing. |
| KRNL-6000 | `kernel.modules_disabled=1` | Would block all module loading until reboot, breaking Docker (iptables/overlay module loads) and maintenance. |
| KRNL-6000 | `net.ipv4.conf.all.forwarding=0` | Forwarding is required by Docker; deliberately enabled by the sysctl role. |
| KRNL-6000 | `net.ipv4.conf.all.rp_filter=1` (strict) | Loose mode (2) is deliberate for Docker bridge traffic. |
| FILE-6310 | Separate /home and /var partitions | Partition layout is fixed at provisioning; not reachable from this playbook. |
| NAME-4028 | DNS domain name in config | Hosts use short names plus the .lan search domain by design (network role). |
| NAME-4404 | FQDN in /etc/hosts | Same resolver design; name resolution is served by the DNS hosts. |
| LOGG-2154 | External logging host | Tracked separately - see the follow-up issue for log shipping. |
| ACCT-9622 | Process accounting | auditd (audit role) already provides the audit trail; psacct adds load for little extra. |
| ACCT-9626 | sysstat | Telegraf already ships host metrics to metrics.markridgwell.com. |
| CRYP-7902 | Certificate expiry checks | No locally issued/terminated certificates on these hosts; TLS endpoints live elsewhere. |
| FINT-4350 | File integrity tool | Tracked separately - see the follow-up issue for AIDE/file integrity. |
| HRDN-7222 | Restrict compilers to root | pacman resets binary permissions on every package update, so a chmod would silently regress; compilers are needed by Docker build workflows. |
| HRDN-7230 | Malware scanner | Tracked separately - same follow-up issue as file integrity. |

---

Captured with lynis 3.1.7 on 2026-09-03 against branch feature/62-lynis-hardening (post-#62 hardening, including the review-pass fixes).
