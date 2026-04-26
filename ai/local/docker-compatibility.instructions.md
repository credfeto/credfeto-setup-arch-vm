---
description: 'Rules ensuring all configuration is compatible with Docker.'
applyTo: '**'
---

[Back to Local Instructions Index](index.md)

# Docker Compatibility

**All settings must be compatible with Docker.** Never add a kernel parameter, sysctl value, or any other configuration that will break Docker or Docker-based workloads.

When evaluating any new setting, verify it does not interfere with:
- Docker bridge networking (`docker0`, `br-*`)
- Container network namespaces and veth pairs
- Rootless or privileged container operation

## Known Incompatible Settings

The following must **never** be added:

| Setting | Reason |
|---|---|
| `kernel.unprivileged_userns_clone=0` | Breaks Docker networking and rootless containers |

## Firewalld and Docker

firewalld's `filter_FORWARD` chain (priority `filter+10`) runs after Docker's own nft rules (priority `filter`). New outbound connections from containers hit the public zone's empty `filter_FWD_public_allow` chain and are rejected.

To allow Docker containers to reach LAN hosts, the `172.16.0.0/12` subnet (covers all default Docker bridge ranges) must be assigned as a source to the `docker` firewalld zone, which has `target: ACCEPT`. This is managed by the `firewall` role and must not be removed.
