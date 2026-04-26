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
