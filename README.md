# credfeto-setup-arch-vm

Sets up an Arch Linux VM with Docker, Git, and supporting tooling. The `install` script configures:

- **Docker** (with Docker Compose and Buildx)
- **firewalld** firewall
- **pkgstats** — weekly anonymous package statistics submission (timer activated via symlink, as it is a static unit)
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
