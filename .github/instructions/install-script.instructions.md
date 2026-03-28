---
description: 'Rules for editing the install script — idempotency, style, and tooling checks.'
applyTo: '**'
---

> **Index:** `.ai-instructions` is the index of all instruction files in this repository.

# Install Script Guidelines

Use the Arch Linux instructions as basic guidance.

## Scope

Keep all changes in the `install` script unless explicitly specified in the request.

## Hardening

**Every package or service installed by the script must also be hardened.**

- If a package exposes a network service, its configuration must be hardened (e.g. strong crypto, least-privilege, minimal attack surface).
- If a package has known security knobs (sysctl, config file options, systemd settings), apply them.
- Do not install a package and leave it in its default, unhardened state.
- Hardening config for a service belongs in the same section of the script as that service's setup.

## Idempotency

The `install` script must be safe to run multiple times without duplicating or breaking configuration.

- Before writing a config value, check whether it is already present and correct.
- If a file already has the exact expected content, skip writing it and emit a `skip` indicator.
- If a file is missing or has different content, write it and emit an `ok` indicator.

## Script Style

- The script **must** start with the shebang `#!/bin/sh` (or `#!/usr/bin/env sh`) — never omit it.
- Use HEREDOC rather than multiple `echo` statements.
- Use `sh` (POSIX shell) — avoid bash-specific syntax.
- Validate all scripts with `shellcheck` before committing.
- Validate all scripts with `checkbashisms` to confirm POSIX `sh` compatibility.

## Documentation

- Update `README.md` to reflect any new features configured by the script.
- Update `CHANGELOG.md` for every change.
