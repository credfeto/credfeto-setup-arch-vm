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

- Add a changelog entry for **every** commit that changes behaviour.
- Run the tool **before** committing — include the updated `CHANGELOG.md` in the same commit.
- Entries go into `[Unreleased]` automatically; do not manually move or edit entries.
- Use a concise, user-facing description — not an internal implementation detail.
- If changing something that has happened before in the same branch that invalidates, then remove the previous entry and add a new one.
- Do not add entries for trivial changes like typos.
- Do not add entries for changes that are not visible to users.
- Do not add entries for changes that are not visible to developers.
- Do not add entries for changes to AI instructions.
