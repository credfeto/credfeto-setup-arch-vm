---
description: 'Rules ensuring all configuration is compatible with the active container runtime (Docker, Podman or none).'
applyTo: '**'
---

# Container Runtime Compatibility

[Back to Local Instructions Index](index.md)

The active container runtime is controlled by the `container_runtime` variable (default: `docker`, set in `group_vars/all.yml`). All settings must be compatible with whichever runtime is active.

Never add a kernel parameter, sysctl value, or any other configuration that will break the active container runtime or container-based workloads.

When evaluating any new setting, verify it does not interfere with:

- Container bridge networking (e.g. `docker0`, `br-*`, or `cni-*` for Podman)
- Container network namespaces and veth pairs
- Rootless or privileged container operation

## Known Incompatible Settings

The following must **never** be added regardless of runtime:

| Setting | Reason |
| --- | --- |
| `kernel.unprivileged_userns_clone=0` | Breaks networking and rootless containers for both Docker and Podman |

## Firewalld and Docker (`container_runtime: docker`)

firewalld's `filter_FORWARD` chain (priority `filter+10`) runs after Docker's own nft rules (priority `filter`). New outbound connections from containers hit the public zone's empty `filter_FWD_public_allow` chain and are rejected.

To allow Docker containers to reach LAN hosts, the `172.16.0.0/12` subnet (covers all default Docker bridge ranges) must be assigned as a source to the `docker` firewalld zone, which has `target: ACCEPT`. This is managed by the `firewall` role under the `container_runtime == 'docker'` guard and must not be removed.

## Firewalld and Podman (`container_runtime: podman`)

Podman (rootful) uses CNI or netavark networking. No dedicated firewalld zone is required; the `docker` zone tasks are skipped entirely when `container_runtime == 'podman'`.

## No Container Runtime (`container_runtime: none`)

Hosts that must run neither Docker nor Podman set `container_runtime: none`. Both the `docker` and `podman` roles skip every task, no companion packages or `docker` firewalld zone are installed, the telegraf `docker` input is omitted, and the `services` role removes any stale `docker-cleanup` and `podman-cleanup` units left from a previous runtime.

## Per-Host Overrides

Override the default for a single host in `host_vars/<ansible_nodename>.yml` (the full node name, e.g. `host_vars/proxy.lan.yml`). `site.yml` loads this file explicitly in `pre_tasks`, because the play targets `localhost` under `ansible-pull` and Ansible's own `host_vars` lookup never matches the real hostname. `site.yml` also fails the run if `container_runtime` is not `docker`, `podman` or `none`.

## Runtime Selection

| Variable value | Runtime installed | Companion packages | Firewall zone | Cleanup timer |
| --- | --- | --- | --- | --- |
| `docker` (default) | `docker` | `docker-buildx`, `docker-compose` | `docker` zone (ACCEPT, 172.16.0.0/12) | `docker-cleanup.timer` |
| `podman` | `podman`, `buildah` | `podman-compose` | None | `podman-cleanup.timer` |
| `none` | None | None | None | None (stale units from either runtime removed) |
