# credfeto-setup-arch-vm

Sets up an Arch Linux VM with Docker, Git, and supporting tooling. The `install` script configures:

- **`linux-hardened` kernel**: security-hardened kernel with additional patches and stricter defaults
- **Docker** (with Docker Compose and Buildx)
- **firewalld** firewall
- **SSH hardening**: strong crypto only, key-based auth, no root login; keys are looked up from the key server by a dedicated `sshkeys` user, which caches each user's last good answer in `/var/cache/ssh-authorized-keys` and serves it while the key server is unreachable (for example during a firewalld reload)
- **fail2ban**: bans hosts after repeated failed SSH logins (`sshd` jail in aggressive mode, nftables ban action in its own `inet f2b-table`, which firewalld never flushes and which runs before firewalld so it also covers `docker`-zone sources, 1h ban time); firewalld reloads and restarts leave the bans in place, and fail2ban restores them from its database whenever it restarts
- **AppArmor**: enforces the upstream `sshd` profile and installs a custom `fail2ban-server` profile, in complain mode until it has been observed on the test VM (see [AppArmor profile for fail2ban](#apparmor-profile-for-fail2ban))
- **sysctl hardening**: network, kernel, and filesystem protections, including persistent IPv4/IPv6 forwarding
- **Core dump disabling**: via sysctl and systemd
- **Kernel module blacklisting**: unused/dangerous protocols and filesystems
- **`/tmp` as noexec tmpfs**: prevents code execution from `/tmp`
- **pkgstats**: weekly anonymous package statistics submission
- **arch-audit**: vulnerable-package detection against the Arch security tracker
- **reflector**: automatic mirror ranking (not on DNS hosts, which use only the internal pacman cache)
- **pacman cache pruning**: weekly `paccache -r` via systemd timer
- **Telegraf**: reports host and (on Docker hosts) container metrics to `https://metrics.markridgwell.com`

```bash
curl -sSL https://raw.githubusercontent.com/credfeto/credfeto-setup-arch-vm/refs/heads/main/install | sh
```

also

/etc/systemd/network/eth0.conf

```config
[Match]
Name=eth0

[Network]
Address=192.168.xxx.yy/24
Gateway=192.168.xxx.1
DNS=192.168.xxx.1

IPv6PrivacyExtensions=yes
```

## Proxmox QEMU Guest Agent

The playbook installs `qemu-guest-agent` and starts it when the virtio serial port exists. In Proxmox enable **Options > QEMU Guest Agent** for the VM, then do a full VM stop/start (not a reboot) so `/dev/virtio-ports/org.qemu.guest_agent.0` is created. Without it the role skips cleanly.

## AppArmor profile for fail2ban

The Arch `apparmor` package ships no profile for `fail2ban-server`, so the `apparmor` role installs its own as `/etc/apparmor.d/usr.bin.fail2ban-server` from `roles/apparmor/files/usr.bin.fail2ban-server`. It ships in complain mode: nothing is denied, and every access the profile does not allow is logged as an `apparmor="ALLOWED"` audit event. Site-specific rules go in `/etc/apparmor.d/local/usr.bin.fail2ban-server`, which the profile includes.

The role loads the profile with `apparmor_parser -r` and restarts fail2ban the first time, because a profile only attaches when the process starts. On a host whose kernel does not have AppArmor enabled yet, the file is installed and the boot that enables AppArmor loads it.

To move the profile from complain to enforce:

1. Apply the playbook to the test VM and confirm the profile is loaded in complain mode:

   ```sh
   sudo aa-status | grep fail2ban-server
   ```

2. Run fail2ban normally for an observation period, including a restart and a ban and unban:

   ```sh
   sudo systemctl restart fail2ban
   sudo fail2ban-client set sshd banip 192.0.2.1
   sudo fail2ban-client set sshd unbanip 192.0.2.1
   ```

3. Look for accesses the profile would have denied:

   ```sh
   sudo ausearch -m apparmor -i | grep fail2ban-server
   sudo journalctl -k --grep 'apparmor="ALLOWED".*fail2ban-server'
   ```

   Add a rule to the profile for each legitimate access found (`aa-logprof` can suggest them) and repeat until a full period shows none.

4. Set `apparmor_fail2ban_enforce: true` (default `false`, in `roles/apparmor/defaults/main.yml`). The role then installs the profile without the complain flag and reloads it in place; fail2ban does not need restarting.

5. Confirm `aa-status` lists `fail2ban-server` in enforce mode and that `fail2ban-client ping` and a ban and unban still work. To go back, set the variable to `false` again.

## Retrying failed handlers

A handler that fails (or never runs because the play stopped) would otherwise never be retried: the task that changed the file reports `ok` on the next run and does not notify again. The `handler_retry` role, which runs first in `site.yml`, closes that gap with marker files in `/var/lib/ansible-pending-handlers` (owned by `root`, mode `0750`, set by `handler_retry_dir`):

1. When a notifying task reports `changed`, the task directly after it writes a marker named after each handler it notifies.
2. The handler removes the marker as its last step, once it has succeeded.
3. At the start of each run `handler_retry` notifies every handler whose marker is still present.

To wire up a new notifying task:

- Give the task a `register` and, directly after it, record its handlers as pending:

  ```yaml
  - name: Record Restart example as pending
    ansible.builtin.include_role:
      name: handler_retry
      tasks_from: pending
    vars:
      handler_retry_pending: [Restart example]
    when: example_config is changed
  ```

- Add a uniquely named clear listener as the last handler on that topic, with the same guard as the handler it follows so that a skipped or refused handler keeps its marker:

  ```yaml
  - name: Clear pending marker for Restart example
    ansible.builtin.file:
      path: "{{ handler_retry_dir }}/Restart example"
      state: absent
    listen: Restart example
  ```

  This example has no `when:` because its handler has none; copy the handler's `when:` onto the clear when it has one.
- Write every handler guard so that it is safe when the variables it reads are undefined: a handler notified from a marker can run in a play that failed before the role that sets them.

The marker file name is the handler name verbatim. After renaming a handler, delete any marker left under its old name by hand (`/var/lib/ansible-pending-handlers/<old name>`), otherwise every run tries to notify a handler that no longer exists.
