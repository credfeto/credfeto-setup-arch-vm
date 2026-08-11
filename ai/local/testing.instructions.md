---
description: 'Rules for testing changes to the Ansible roles and install script.'
applyTo: '**'
---

# Testing Guidelines

[Back to Local Instructions Index](index.md)

## Test VM

A dedicated Arch Linux VM is available for testing changes before applying them to production machines:

- **Host:** `arch-vm-test.lan`
- **User:** `markr` (sudo user)
- **Connection:** `ssh markr@arch-vm-test.lan`

Use this VM to validate Ansible role changes and install script modifications before committing or deploying to production hosts.

> The VM also has a `test` user documented/keyed for this purpose, but its
> key (`~/.ssh/id_arch-vm-test.lan`) is currently rejected by the VM
> (`Permission denied (publickey)`) — use `markr@` until that's fixed.

## When to Use the Test VM

- Before committing any change to an Ansible role, run it against the test VM to confirm it applies cleanly with `failed=0`.
- When diagnosing a role failure seen on a production machine, reproduce it on the test VM first.
- After fixing a role, re-run ansible-pull (or run the playbook directly) on the test VM to verify the fix.

## Running Tests

Apply the full playbook against the test VM:

```sh
ssh markr@arch-vm-test.lan "sudo -n ansible-pull -U https://github.com/credfeto/credfeto-setup-arch-vm.git -C main site.yml"
```

Or, for a branch under test rather than `main`, pass that branch to `-C` instead. Running `ansible-pull` *on* the VM (over SSH) rather than `ansible-playbook` *against* it from your own machine avoids tripping any local command-allowlisting some environments apply to `ansible-playbook`.

Alternatively, run a specific role in isolation via a local playbook, targeting the VM over SSH:

```sh
ansible-playbook -i arch-vm-test.lan, -u markr site.yml --tags <role>
```

The `markr` user has `sudo` access, so any task requiring privilege escalation will work without additional configuration.

## Permissions

This VM is exclusively for testing. Feel free to:

- Reboot it at any time to verify persistent changes survive a restart.
- Break and reconfigure it as needed to reproduce or diagnose issues.
- Make destructive changes (reinstall packages, wipe config files, etc.) to test idempotency and recovery.

There is no need to ask permission before rebooting or making significant changes to this VM.

## Cleanup After Testing

After testing is complete, **revert the VM to its pre-test state** so it is clean for the next test run:

- Undo any manual config changes made during testing.
- If the playbook was applied, re-run it after reverting to confirm idempotency.
- If the VM state is uncertain or too messy to cleanly revert, reboot it and re-run the playbook from scratch to restore a known-good baseline.
