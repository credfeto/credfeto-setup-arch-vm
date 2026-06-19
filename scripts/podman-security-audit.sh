#!/bin/sh
# Podman container security audit.
# Checks each running container against the security baseline.
# Exits non-zero if any container fails any check.
# Output is captured to the journal when run via the podman-security-audit.service unit.

FINDINGS=0

audit_container() {
    cid="$1"
    cname=$(podman inspect --format '{{.Name}}' "$cid" 2>/dev/null | sed 's|^/||')

    if [ -z "$cname" ]; then
        printf 'WARN cid=%s detail="could not inspect container"\n' "$cid"
        return
    fi

    # Check: privileged mode must be absent
    priv=$(podman inspect --format '{{.HostConfig.Privileged}}' "$cid" 2>/dev/null)
    if [ "$priv" = "true" ]; then
        printf 'FAIL container=%s check=privileged detail="privileged mode enabled"\n' "$cname"
        FINDINGS=$((FINDINGS + 1))
    fi

    # Check: must not run as root (UID 0)
    cuser=$(podman inspect --format '{{.Config.User}}' "$cid" 2>/dev/null)
    if [ -z "$cuser" ] || [ "$cuser" = "root" ] || [ "$cuser" = "0" ]; then
        printf 'FAIL container=%s check=root_user detail="container runs as root (UID 0)"\n' "$cname"
        FINDINGS=$((FINDINGS + 1))
    fi

    # Check: root filesystem must be read-only
    ro=$(podman inspect --format '{{.HostConfig.ReadonlyRootfs}}' "$cid" 2>/dev/null)
    if [ "$ro" != "true" ]; then
        printf 'FAIL container=%s check=readonly_rootfs detail="root filesystem is not read-only"\n' "$cname"
        FINDINGS=$((FINDINGS + 1))
    fi

    # Check: CAP_SYS_ADMIN must not be present in added capabilities
    caps=$(podman inspect --format '{{.HostConfig.CapAdd}}' "$cid" 2>/dev/null)
    if printf '%s' "$caps" | grep -q 'SYS_ADMIN'; then
        printf 'FAIL container=%s check=cap_sys_admin detail="CAP_SYS_ADMIN is granted"\n' "$cname"
        FINDINGS=$((FINDINGS + 1))
    fi

    # Check: host network mode must not be used
    netmode=$(podman inspect --format '{{.HostConfig.NetworkMode}}' "$cid" 2>/dev/null)
    if [ "$netmode" = "host" ]; then
        printf 'FAIL container=%s check=network_mode detail="host network mode in use"\n' "$cname"
        FINDINGS=$((FINDINGS + 1))
    fi

    # Check: memory limit must be set (0 means unlimited)
    mem=$(podman inspect --format '{{.HostConfig.Memory}}' "$cid" 2>/dev/null)
    if [ "$mem" = "0" ] || [ -z "$mem" ]; then
        printf 'FAIL container=%s check=memory_limit detail="no memory limit set (unlimited)"\n' "$cname"
        FINDINGS=$((FINDINGS + 1))
    fi

    # Check: PID limit must be set (0 or -1 means unlimited)
    pids=$(podman inspect --format '{{.HostConfig.PidsLimit}}' "$cid" 2>/dev/null)
    if [ "$pids" = "0" ] || [ "$pids" = "-1" ] || [ -z "$pids" ]; then
        printf 'FAIL container=%s check=pids_limit detail="no PID limit set (unlimited)"\n' "$cname"
        FINDINGS=$((FINDINGS + 1))
    fi
}

while IFS= read -r cid; do
    [ -z "$cid" ] && continue
    audit_container "$cid"
done <<CONTAINER_LIST
$(podman ps -q 2>/dev/null)
CONTAINER_LIST

if [ "$FINDINGS" -gt 0 ]; then
    printf 'RESULT status=FAIL findings=%d\n' "$FINDINGS"
    exit 1
fi

printf 'RESULT status=PASS findings=0\n'
