# credfeto-setup-arch-vm

Sets up an Arch Linux VM with Docker, Git, and supporting tooling. The `install` script configures:

- **`linux-hardened` kernel** — security-hardened kernel with additional patches and stricter defaults
- **Docker** (with Docker Compose and Buildx)
- **firewalld** firewall
- **SSH hardening** — strong crypto only, key-based auth, no root login
- **sysctl hardening** — network, kernel, and filesystem protections, including persistent IPv4/IPv6 forwarding
- **Core dump disabling** — via sysctl and systemd
- **Kernel module blacklisting** — unused/dangerous protocols and filesystems
- **`/tmp` as noexec tmpfs** — prevents code execution from `/tmp`
- **pkgstats** — weekly anonymous package statistics submission
- **reflector** — automatic mirror ranking
- **pacman cache pruning** — weekly `paccache -r` via systemd timer

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
