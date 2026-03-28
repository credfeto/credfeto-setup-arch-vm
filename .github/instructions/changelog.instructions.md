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
export PATH="$PATH:$HOME/.dotnet/tools"
```

## Adding an Entry

```sh
changelog -f CHANGELOG.md -a <Type> -m "<message>"
```

Valid types: `Added`, `Fixed`, `Changed`, `Removed`, `Deployment Changes`

### Examples

```sh
changelog -f CHANGELOG.md -a Fixed -m "Enable pkgstats.timer via symlink for static unit"
changelog -f CHANGELOG.md -a Added -m "Configure reflector for automatic mirror ranking"
changelog -f CHANGELOG.md -a Changed -m "Switch firewall backend from iptables to nftables"
```

## Rules

- Add a changelog entry for **every** commit that changes behaviour.
- Run the tool **before** committing — include the updated `CHANGELOG.md` in the same commit.
- Entries go into `[Unreleased]` automatically; do not manually move or edit entries.
- Use a concise, user-facing description — not an internal implementation detail.

## Remembering New Rules

When you discover something that should be remembered for future work (a tool to use, a pattern to follow, a gotcha to avoid), add it to the most relevant file in `.github/instructions/`. If no existing file fits, create a new `<topic>.instructions.md` there and add it to the index in `.ai-instructions`.
