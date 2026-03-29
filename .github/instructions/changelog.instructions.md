---
description: 'Rules for maintaining CHANGELOG.md using the credfeto.changelog.cmd dotnet tool.'
applyTo: '**'
---

> **Index:** `.ai-instructions` is the index of all instruction files in this repository.

# Changelog Guidelines

**Always use `credfeto.changelog.cmd` to update `CHANGELOG.md`.** Never edit it manually.

## Setup

The tool is a .NET global tool. Install once if not present:

```sh
dotnet tool install -g Credfeto.Changelog.Cmd
```

## Adding an Entry

Use `dotnet changelog` — no PATH changes needed:

```sh
dotnet changelog -f CHANGELOG.md -a <Type> -m "<message>"
```

Valid types: `Added`, `Fixed`, `Changed`, `Removed`, `Deployment Changes`

Always run the tool **before** committing and include the updated `CHANGELOG.md` in the same commit.

### Examples

Adding
```sh
dotnet changelog -f CHANGELOG.md -a Fixed -m "Enable pkgstats.timer via symlink for static unit"
dotnet changelog -f CHANGELOG.md -a Added -m "Configure reflector for automatic mirror ranking"
dotnet changelog -f CHANGELOG.md -a Changed -m "Switch firewall backend from iptables to nftables"
```

Removing
```sh
dotnet changelog -f CHANGELOG.md -r Changed -m "Switch firewall backend from iptables to nftables"
```

## Rules

An entry is required for every commit that changes **what the script installs, configures, hardens, or how it behaves on a target system**. The audience is someone running the `install` script — describe what changed on their system, not how the code changed internally.

### When to add an entry

| Section | Use when… |
|---|---|
| `Added` | A new package, service, configuration, or security control is introduced |
| `Fixed` | Incorrect or broken behaviour in the script is corrected |
| `Changed` | Existing behaviour is altered (different config values, restructured setup, etc.) |
| `Removed` | A package, service, or configuration is removed from the script |
| `Deployment Changes` | A change requires manual steps or re-running the script to take effect |

### When NOT to add an entry

- Changes to AI instructions or `.github/instructions/` files
- Changes to CI/GitHub Actions workflows
- Internal refactoring that produces **identical system behaviour** (e.g., variable renames, restructuring without output change)
- Typo or comment-only fixes that do not affect script output or system state
- Changes to documentation that do not accompany a script change

### Keeping entries accurate

- If a previous `[Unreleased]` entry on the same branch is superseded, remove it with `-r` and add a replacement — do not leave stale entries.
- When an `[Unreleased]` entry is no longer valid, remove it.
- Do not manually move or edit entries — use the tool only.