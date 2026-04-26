---
description: 'Rules for testing changes to the Ansible roles and install script.'
applyTo: '**'
---

[Back to Local Instructions Index](index.md)

# Testing Guidelines

## Test VM

A dedicated Arch Linux VM is available for testing changes before applying them to production machines:

- **Host:** `arch-vm-test.lan`
- **User:** `test` (sudo user)
- **Connection:** `ssh test@arch-vm-test.lan`

Use this VM to validate Ansible role changes and install script modifications before committing or deploying to production hosts.

## When to Use the Test VM

- Before committing any change to an Ansible role, run it against the test VM to confirm it applies cleanly with `failed=0`.
- When diagnosing a role failure seen on a production machine, reproduce it on the test VM first.
- After fixing a role, re-run ansible-pull (or run the playbook directly) on the test VM to verify the fix.

## Running Tests

Apply the full playbook against the test VM:

```sh
ansible-pull -U https://github.com/credfeto/credfeto-setup-arch-vm.git -C main site.yml
```

Or run a specific role in isolation via a local playbook:

```sh
ansible-playbook -i arch-vm-test.lan, site.yml --tags <role>
```

The `test` user has `sudo` access, so any task requiring privilege escalation will work without additional configuration.
