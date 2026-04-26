---
description: 'Rules for editing the install script — idempotency, style, and tooling checks.'
applyTo: '**'
---

[Back to Local Instructions Index](index.md)

# Install Script Guidelines

Use the Arch Linux instructions as basic guidance.

## Scope

Keep all changes in the `install` script unless explicitly specified in the request.

## Hardening

**Only harden services that the script itself configures.** Do NOT add systemd drop-ins for services that are installed solely via the package manager and left at their upstream defaults. The upstream package maintainer owns the security posture of those services; overriding them adds maintenance burden and risks breaking the service in hard-to-diagnose ways.

**Exception:** a drop-in MAY be added for a package-managed service only when ALL of the following are true:
1. There is a documented, specific, credible security risk with the upstream default.
2. The fix cannot be achieved by configuration alone (e.g. a sysctl or conf file).
3. The drop-in setting is well-understood and provably safe for that service.

When an exception applies:
- The drop-in **must** include an inline comment citing the source (CVE, upstream issue URL, or authoritative advisory URL).
- That source **must** also be referenced in the commit message.

For services the script does configure:
- If a package exposes a network service, harden its configuration (e.g. strong crypto, least-privilege, minimal attack surface).
- If a package has known security knobs (sysctl, config file options, systemd settings), apply them.
- Hardening config for a service belongs in the same section of the script as that service's setup.

## Idempotency

The `install` script must be safe to run multiple times without duplicating or breaking configuration.

- Before writing a config value, check whether it is already present and correct.
- If a file already has the exact expected content, skip writing it and emit a `skip` indicator.
- If a file is missing or has different content, write it and emit an `ok` indicator.

## Apply Changes Live and Persistently

**Every configuration change must take effect immediately, not only after a reboot.** Write the persistent form (file, symlink, or config entry) first, then apply the live equivalent in the same step.

| Subsystem | Persistent form | Live application |
|---|---|---|
| kernel parameters | `/etc/sysctl.d/*.conf` | `sysctl -w key=value` |
| systemd unit state | `systemctl enable` | `systemctl enable --now` or `systemctl start` |
| systemd mounts | drop-in + `daemon-reload` | `systemctl restart <unit>.mount` |
| firewall rules | `firewall-cmd --permanent …` | `firewall-cmd --reload` |
| module blacklist | `/etc/modprobe.d/*.conf` | `modprobe -r <module>` (if currently loaded) |

Rules:
- If the persistent file is already correct (idempotency check passes), emit `skip` — do not re-apply the live change.
- If the persistent file is written or updated, always apply the live change immediately afterwards and `die` on failure.
- Do not apply a live change without also writing the persistent form.

## Script Style

- The script **must** start with the shebang `#!/bin/sh` (or `#!/usr/bin/env sh`) — never omit it.
- Use HEREDOC rather than multiple `echo` statements.
- Use `sh` (POSIX shell) — avoid bash-specific syntax.
- Validate all scripts with `shellcheck` before committing.
- Validate all scripts with `checkbashisms` to confirm POSIX `sh` compatibility.

## Documentation

- Update `README.md` to reflect any new features configured by the script.
- Update `CHANGELOG.md` for every change.
