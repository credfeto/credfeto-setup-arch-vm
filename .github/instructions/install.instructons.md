---
description: 'Guidance for updaing.'
applyTo: '**'
---

# Updating Guidelines

Use the arch linux instructions as basic guidance.

## Git Workflow

**Never commit directly to `main`.** All changes must be made on a feature branch.

Before starting any work:
1. Switch to `main`: `git checkout main`
2. Pull the latest: `git pull`
3. Create a feature branch: `git checkout -b <branch-name>`
4. Make all commits on that branch
5. Push the branch and open a PR — do not push to `main` directly

**If asked to fix or extend something already on an open branch, commit to that same branch — do not create a new branch.**

Keep all changes in the 'install' script unless explicitly specified in the request.

Make the install script run in such a way that it can be run many times without breaking or introducing duplicate configuration or unwanted configuration... 

e.g. if making a change to say /etc/pacman.conf then it should not make the change if it is already present.

## Docker Compatibility

**All settings must be compatible with Docker.** Never add a kernel parameter, sysctl value, or any other configuration that will break Docker or Docker-based workloads.

Known settings that break Docker and must never be added:
- `kernel.unprivileged_userns_clone=0` — breaks Docker networking and rootless containers
