---
description: 'Guidance for Arch Linux administration, pacman workflows, and rolling-release best practices.'
applyTo: '**'
---

[Back to Local Instructions Index](index.md)

# Arch Linux Administration Guidelines

Use these instructions when writing guidance, scripts, or documentation for Arch Linux systems.

## Platform Alignment

- Emphasize the rolling-release model and the need for full upgrades.
- Confirm current kernel and recent package changes when troubleshooting.
- Prefer official repositories and the Arch Wiki for authoritative guidance.
- **The kernel is `linux-hardened`** — this provides additional security patches, stricter defaults, and enables hardening features referenced in GRUB parameters (e.g. `hardened_usercopy`, `init_on_alloc`, `slab_nomerge`). Always assume `linux-hardened` and `linux-hardened-headers` are installed.
- **`/tmp` is mounted by systemd's `tmp.mount` unit**, not via `/etc/fstab`. To change mount options (e.g. add `noexec`), use a drop-in at `/etc/systemd/system/tmp.mount.d/`. Never add a `/tmp` entry to `/etc/fstab` on Arch.

## Package Management

- Use `pacman -Syu` for full system upgrades; avoid partial upgrades.
- Inspect packages with `pacman -Qi`, `pacman -Ql`, and `pacman -Ss`.
- Use `paccache -r` (from `pacman-contrib`) to prune the package cache, keeping the 3 most recent versions per package.
- Schedule `paccache -r` via a weekly systemd timer to prevent unbounded cache growth.

## AUR Helpers — PROHIBITED

**Never install or recommend AUR helpers** (yay, yay-bin, paru, paru-bin, pikaur, trizen, aurutils, aura, bauerbill, pakku, pamac-aur, or any equivalent).

AUR helpers automate PKGBUILD execution from user-submitted sources. Recent AUR supply chain attacks have demonstrated that malicious PKGBUILDs can be pushed to the AUR and executed silently by helpers before any human review. The attack surface is unacceptable on managed systems.

If any AUR helper is found installed it **must be removed** immediately via `pacman -Rs`.

The Ansible role at `roles/packages/tasks/main.yml` enforces this by explicitly removing known AUR helper packages on every run.

### Permitted exception — Chaotic AUR

**Chaotic AUR is permitted** and is the only community repository approved for use. Packages in Chaotic AUR are pre-built by a maintained automated pipeline and externally reviewed, unlike raw AUR PKGBUILDs. Chaotic AUR is configured via `pacman.conf` and the signed keyring — **never** via an AUR helper.

## Configuration & Services

- Keep configuration under `/etc` and avoid editing files in `/usr`.
- Use systemd drop-ins in `/etc/systemd/system/<unit>.d/`.
- Use `systemctl` and `journalctl` for service control and logs.

## Security

- Note reboot requirements after kernel or core library upgrades.
- Recommend least-privilege `sudo` usage and minimal packages.
- Call out firewall tooling expectations (nftables/ufw) explicitly.

## Deliverables

- Provide commands in copy-paste-ready blocks.
- Include validation steps after changes.
- Offer rollback or cleanup steps for risky operations.
