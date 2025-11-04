# credfeto-setup-arch-vm

set up arch VM with docker and git

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
