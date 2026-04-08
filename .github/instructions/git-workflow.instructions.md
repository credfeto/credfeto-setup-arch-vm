---
description: 'Git branching, commit, and PR rules for this repository.'
applyTo: '**'
---

> **Index:** `.ai-instructions` is the index of all instruction files in this repository.

# Git Workflow

**Never commit directly to `main`.** All changes must be made on a feature branch.

Before starting any work:
1. Switch to `main`: `git checkout main`
2. Pull the latest: `git pull`
3. Create a feature branch: `git checkout -b <branch-name>`
4. Make all commits on that branch
5. Push the branch and open a PR — do not push to `main` directly

**If asked to fix or extend something already on an open branch, commit to that same branch and push to origin — do not create a new branch.**

## Commit Messages

- Follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format.
- Keep commits small and focused, each with a descriptive message.
- Always include the Co-authored-by trailer:
  ```
  Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
  ```

## Issue Assignment

- Before picking up an issue, assign it to yourself: `gh issue edit <number> --add-assignee @me`
- Do not pick up issues already assigned to someone else.
- Do not work on issues labelled `on-hold`.

## Pull Requests

- PRs must be reviewed by at least one other maintainer before merging.
- All changes must be tested and verified before merging.
- Always add yourself as assignee when creating or updating a PR: `gh pr edit <number> --add-assignee @me`
